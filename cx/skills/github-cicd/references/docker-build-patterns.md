# Docker Build Patterns in CI/CD

Docker container build strategies, caching, versioning, and registry patterns for GitHub Actions.

## Table of Contents
1. [Build Strategies](#build-strategies)
2. [BuildKit and Caching](#buildkit-and-caching)
3. [Versioning and Tagging](#versioning-and-tagging)
4. [Registry Integration](#registry-integration)
5. [Multi-Architecture Builds](#multi-architecture-builds)
6. [Optimization Techniques](#optimization-techniques)

## Build Strategies

### PR vs Production Builds

**Pattern: Build but don't push on PRs, export as artifact**

```yaml
jobs:
  build-pr:
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3

      - uses: docker/build-push-action@v6
        with:
          context: .
          push: false
          tags: myapp:pr-${{ github.event.pull_request.number }}
          outputs: type=docker,dest=/tmp/image.tar

      - uses: actions/upload-artifact@v4
        with:
          name: docker-image
          path: /tmp/image.tar
          retention-days: 1

  build-prod:
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3

      - uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: |
            ghcr.io/${{ github.repository }}:latest
            ghcr.io/${{ github.repository }}:${{ github.sha }}
```

### Loading Exported Image

**Use exported image in E2E tests:**

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: docker/build-push-action@v6
        with:
          outputs: type=docker,dest=/tmp/image.tar
      - uses: actions/upload-artifact@v4
        with:
          name: docker-image
          path: /tmp/image.tar

  test-e2e:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/download-artifact@v4
        with:
          name: docker-image
          path: /tmp

      - name: Load image into Kind
        run: |
          kind create cluster --name test
          kind load image-archive /tmp/image.tar --name test

      - name: Run tests
        run: kubectl apply -f test-deployment.yaml
```

## BuildKit and Caching

### GitHub Actions Cache

**Best practice: Use GitHub Actions cache backend**

```yaml
- uses: docker/setup-buildx-action@v3

- uses: docker/build-push-action@v6
  with:
    context: .
    cache-from: type=gha,scope=myapp
    cache-to: type=gha,mode=max,scope=myapp
```

**Cache scopes for multi-component projects:**

```yaml
# Component A
- uses: docker/build-push-action@v6
  with:
    context: ./services/api
    cache-from: type=gha,scope=api
    cache-to: type=gha,mode=max,scope=api

# Component B
- uses: docker/build-push-action@v6
  with:
    context: ./services/worker
    cache-from: type=gha,scope=worker
    cache-to: type=gha,mode=max,scope=worker
```

### Cache Modes

```yaml
# mode=min: Only cache final layers (smaller cache, faster upload)
cache-to: type=gha,mode=min,scope=myapp

# mode=max: Cache all intermediate layers (larger cache, faster builds)
cache-to: type=gha,mode=max,scope=myapp
```

### Registry Cache

**Alternative: Use registry as cache backend**

```yaml
- uses: docker/build-push-action@v6
  with:
    context: .
    cache-from: type=registry,ref=ghcr.io/${{ github.repository }}:buildcache
    cache-to: type=registry,ref=ghcr.io/${{ github.repository }}:buildcache,mode=max
```

### Multi-Stage Build Caching

**Dockerfile optimization for caching:**

```dockerfile
FROM golang:1.23 AS deps
WORKDIR /build
COPY go.mod go.sum ./
RUN go mod download

FROM deps AS builder
COPY . .
RUN CGO_ENABLED=0 go build -o app ./cmd/app

FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=builder /build/app /app
ENTRYPOINT ["/app"]
```

**Leverage cache mounts:**

```dockerfile
FROM golang:1.23 AS builder
WORKDIR /build

RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=bind,source=go.sum,target=go.sum \
    --mount=type=bind,source=go.mod,target=go.mod \
    go mod download

RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=bind,target=. \
    CGO_ENABLED=0 go build -o /app ./cmd/app

FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=builder /app /app
ENTRYPOINT ["/app"]
```

## Versioning and Tagging

### Semantic Versioning from Git

**Pattern: Calculate version from git tags and history**

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      version: ${{ steps.version.outputs.version }}
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Fetch all history

      - name: Calculate semantic version
        id: version
        run: |
          # Get latest tag
          LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
          # Count commits since tag
          COMMITS=$(git rev-list ${LATEST_TAG}..HEAD --count)
          # Extract version number
          VERSION=${LATEST_TAG#v}

          if [ "$COMMITS" -gt 0 ]; then
            # Bump patch version
            IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION"
            VERSION="$MAJOR.$MINOR.$((PATCH + 1))"
          fi

          echo "version=$VERSION" >> $GITHUB_OUTPUT
          echo "Calculated version: $VERSION"

      - name: Create git tag
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git tag -a "v${{ steps.version.outputs.version }}" \
            -m "Release v${{ steps.version.outputs.version }}"
          git push origin "v${{ steps.version.outputs.version }}"
```

### Docker Metadata Action

**Best practice: Use docker/metadata-action for consistent tagging**

```yaml
- uses: docker/metadata-action@v5
  id: meta
  with:
    images: ghcr.io/${{ github.repository }}
    tags: |
      # Semantic version tags
      type=semver,pattern={{version}},value=v${{ steps.version.outputs.version }}
      type=semver,pattern={{major}}.{{minor}},value=v${{ steps.version.outputs.version }}
      type=semver,pattern={{major}},value=v${{ steps.version.outputs.version }}

      # SHA-based tags
      type=sha,prefix={{date 'YYYYMMDD'}}-
      type=sha,format=long

      # Branch-based tags
      type=ref,event=branch
      type=ref,event=pr

      # Date tags
      type=raw,value={{date 'YYYYMMDD'}}-{{sha}}
    flavor: |
      latest=true  # Always tag as 'latest' on main

- uses: docker/build-push-action@v6
  with:
    tags: ${{ steps.meta.outputs.tags }}
    labels: ${{ steps.meta.outputs.labels }}
```

### Common Tagging Strategies

**PR builds:**
```yaml
tags: |
  type=ref,event=pr,prefix=pr-
```

**Branch builds:**
```yaml
tags: |
  type=ref,event=branch
  type=sha
```

**Production builds with semantic versioning:**
```yaml
tags: |
  type=semver,pattern={{version}}
  type=semver,pattern={{major}}.{{minor}}
  type=semver,pattern={{major}}
  type=sha
  type=raw,value=latest
```

### Build Args for Versioning

```yaml
- uses: docker/build-push-action@v6
  with:
    build-args: |
      VERSION=${{ steps.version.outputs.version }}
      GIT_COMMIT=${{ github.sha }}
      BUILD_TIME=${{ github.event.head_commit.timestamp }}
```

**In Dockerfile:**
```dockerfile
ARG VERSION=dev
ARG GIT_COMMIT=unknown
ARG BUILD_TIME=unknown

FROM golang:1.23 AS builder
WORKDIR /build

COPY . .
RUN CGO_ENABLED=0 go build \
    -ldflags "-X main.Version=${VERSION} \
              -X main.GitCommit=${GIT_COMMIT} \
              -X main.BuildTime=${BUILD_TIME}" \
    -o app ./cmd/app

FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=builder /build/app /app
ENTRYPOINT ["/app"]
```

## Registry Integration

### GitHub Container Registry (GHCR)

```yaml
permissions:
  contents: read
  packages: write

steps:
  - uses: docker/login-action@v3
    with:
      registry: ghcr.io
      username: ${{ github.actor }}
      password: ${{ secrets.GITHUB_TOKEN }}

  - uses: docker/build-push-action@v6
    with:
      push: true
      tags: ghcr.io/${{ github.repository }}/myapp:latest
```

### AWS ECR

**With OIDC authentication:**

```yaml
permissions:
  id-token: write
  contents: read

steps:
  - uses: aws-actions/configure-aws-credentials@v4
    with:
      aws-region: us-east-1
      role-to-assume: arn:aws:iam::123456789:role/github-actions

  - uses: aws-actions/amazon-ecr-login@v2
    id: ecr

  - uses: docker/build-push-action@v6
    with:
      push: true
      tags: ${{ steps.ecr.outputs.registry }}/myapp:${{ github.sha }}
```

### Docker Hub

```yaml
steps:
  - uses: docker/login-action@v3
    with:
      username: ${{ secrets.DOCKERHUB_USERNAME }}
      password: ${{ secrets.DOCKERHUB_TOKEN }}

  - uses: docker/build-push-action@v6
    with:
      push: true
      tags: |
        myorg/myapp:latest
        myorg/myapp:${{ github.sha }}
```

### Multi-Registry Push

```yaml
- uses: docker/metadata-action@v5
  id: meta
  with:
    images: |
      ghcr.io/${{ github.repository }}/myapp
      ${{ steps.ecr.outputs.registry }}/myapp
    tags: |
      type=semver,pattern={{version}}
      type=sha

- uses: docker/build-push-action@v6
  with:
    push: true
    tags: ${{ steps.meta.outputs.tags }}
```

## Multi-Architecture Builds

### Basic Multi-Arch Build

```yaml
- uses: docker/setup-qemu-action@v3

- uses: docker/setup-buildx-action@v3

- uses: docker/build-push-action@v6
  with:
    platforms: linux/amd64,linux/arm64
    push: true
    tags: myapp:latest
```

### Platform-Specific Builds

```yaml
strategy:
  matrix:
    platform:
      - linux/amd64
      - linux/arm64
      - linux/arm/v7

steps:
  - uses: docker/build-push-action@v6
    with:
      platforms: ${{ matrix.platform }}
      outputs: type=image,name=myapp,push-by-digest=true

  # Later: Create multi-arch manifest
  - uses: docker/build-push-action@v6
    with:
      platforms: linux/amd64,linux/arm64,linux/arm/v7
      tags: myapp:latest
```

### Conditional Platform Builds

```yaml
- uses: docker/build-push-action@v6
  with:
    # Only build ARM on main branch (slower)
    platforms: ${{ github.ref == 'refs/heads/main' && 'linux/amd64,linux/arm64' || 'linux/amd64' }}
    push: true
    tags: myapp:latest
```

## Optimization Techniques

### Layer Optimization

**Bad: Rebuilds dependencies every time**
```dockerfile
FROM golang:1.23
WORKDIR /app
COPY . .
RUN go build -o app ./cmd/app
```

**Good: Cache dependencies separately**
```dockerfile
FROM golang:1.23 AS builder
WORKDIR /app

# Copy and download dependencies first (cached layer)
COPY go.mod go.sum ./
RUN go mod download

# Then copy source and build (only invalidated on source changes)
COPY . .
RUN CGO_ENABLED=0 go build -o app ./cmd/app

FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=builder /app/app /app
ENTRYPOINT ["/app"]
```

### Parallel Builds

```yaml
strategy:
  matrix:
    component: [ api, worker, scheduler ]

steps:
  - uses: docker/build-push-action@v6
    with:
      context: ./services/${{ matrix.component }}
      tags: ${{ matrix.component }}:latest
      cache-from: type=gha,scope=${{ matrix.component }}
      cache-to: type=gha,mode=max,scope=${{ matrix.component }}
```

### Build Time Reduction

**1. Use BuildKit cache mounts:**
```dockerfile
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    go build -o app
```

**2. Use smaller base images:**
```dockerfile
# Instead of: golang:1.23 (1GB+)
FROM golang:1.23-alpine AS builder  # ~300MB

# Or even better for runtime:
FROM gcr.io/distroless/static-debian12:nonroot  # ~2MB
```

**3. Pre-warm caches:**
```yaml
- name: Pre-build dependencies
  uses: docker/build-push-action@v6
  with:
    context: .
    target: deps  # Stop at dependencies stage
    cache-from: type=gha,scope=deps
    cache-to: type=gha,mode=max,scope=deps

- name: Build application
  uses: docker/build-push-action@v6
  with:
    context: .
    cache-from: |
      type=gha,scope=deps
      type=gha,scope=app
    cache-to: type=gha,mode=max,scope=app
```

### Security Scanning

```yaml
- uses: docker/build-push-action@v6
  id: build
  with:
    push: false
    load: true
    tags: myapp:test

- name: Scan image
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: myapp:test
    format: 'sarif'
    output: 'trivy-results.sarif'

- name: Upload scan results
  uses: github/codeql-action/upload-sarif@v3
  with:
    sarif_file: 'trivy-results.sarif'

- name: Push if scan passes
  uses: docker/build-push-action@v6
  with:
    push: true
    tags: ghcr.io/${{ github.repository }}:latest
```

## Best Practices

### Performance
- Use BuildKit caching with GitHub Actions cache
- Separate dependency installation from build steps
- Use multi-stage builds for smaller images
- Cache at appropriate scopes for monorepos
- Consider parallel builds for multiple components

### Security
- Use OIDC authentication for cloud registries
- Scan images before pushing to production
- Use minimal base images (distroless, alpine)
- Don't include secrets in images
- Pin base image versions with digests

### Versioning
- Use semantic versioning for releases
- Tag with both version and SHA
- Include build metadata as labels
- Create tags automatically from git

### Organization
- Export PR images as artifacts, don't push to registry
- Push production images with multiple tags
- Use consistent tagging strategies
- Clean up old tags/images periodically

### Debugging
- Keep build logs for failed builds
- Use `load: true` to test images before pushing
- Include version info in image labels
- Save build artifacts for inspection
