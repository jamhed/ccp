# Caching Strategies for CI/CD

Comprehensive caching patterns to optimize build and test performance in GitHub Actions. **Updated for 2025: actions/cache@v4 required (v3 deprecated February 1, 2025).**

## Table of Contents
1. [GitHub Actions Cache](#github-actions-cache)
2. [Language-Specific Caching](#language-specific-caching)
3. [Docker BuildKit Cache](#docker-buildkit-cache)
4. [Tool and Dependency Caching](#tool-and-dependency-caching)
5. [Test Caching](#test-caching)
6. [Cache Optimization](#cache-optimization)
7. [Advanced Patterns (2025)](#advanced-patterns-2025)

## GitHub Actions Cache

### Basic Cache Usage

```yaml
- uses: actions/cache@v4
  with:
    path: ~/.cache/go-build
    key: ${{ runner.os }}-go-${{ hashFiles('**/go.sum') }}
    restore-keys: |
      ${{ runner.os }}-go-
```

### Multiple Paths

```yaml
- uses: actions/cache@v4
  with:
    path: |
      ~/.cache/go-build
      ~/go/pkg/mod
      vendor/
    key: ${{ runner.os }}-go-${{ hashFiles('**/go.sum') }}
```

### Cache Hit Detection

```yaml
- uses: actions/cache@v4
  id: cache
  with:
    path: node_modules
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}

- name: Install dependencies
  if: steps.cache.outputs.cache-hit != 'true'
  run: npm ci
```

### Version-Based Cache Keys

```yaml
- uses: actions/cache@v4
  with:
    path: ~/.cache
    key: v2-${{ runner.os }}-build-${{ hashFiles('**/*.go') }}
    restore-keys: |
      v2-${{ runner.os }}-build-
      v2-${{ runner.os }}-
```

## Language-Specific Caching

### Go Caching

**Automatic with setup-go:**

```yaml
- uses: actions/setup-go@v5
  with:
    go-version: '1.23'
    cache: true
    cache-dependency-path: '**/go.sum'
```

**Manual Go caching:**

```yaml
- uses: actions/cache@v4
  with:
    path: |
      ~/.cache/go-build
      ~/go/pkg/mod
    key: ${{ runner.os }}-go-${{ hashFiles('**/go.sum') }}
    restore-keys: |
      ${{ runner.os }}-go-

- run: go build ./...
```

**Monorepo Go caching:**

```yaml
- uses: actions/cache@v4
  with:
    path: |
      ~/.cache/go-build
      ~/go/pkg/mod
    key: ${{ runner.os }}-go-${{ hashFiles('services/*/go.sum') }}
    restore-keys: |
      ${{ runner.os }}-go-
```

### Node.js Caching

**Automatic with setup-node:**

```yaml
- uses: actions/setup-node@v4
  with:
    node-version: '20'
    cache: 'npm'
    cache-dependency-path: '**/package-lock.json'
```

**Manual npm caching:**

```yaml
- uses: actions/cache@v4
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}

- run: npm ci
```

**Yarn caching:**

```yaml
- uses: actions/cache@v4
  with:
    path: |
      ~/.yarn/cache
      node_modules
    key: ${{ runner.os }}-yarn-${{ hashFiles('**/yarn.lock') }}
```

### Python Caching

```yaml
- uses: actions/setup-python@v5
  with:
    python-version: '3.11'
    cache: 'pip'

- run: pip install -r requirements.txt
```

**Manual pip caching:**

```yaml
- uses: actions/cache@v4
  with:
    path: ~/.cache/pip
    key: ${{ runner.os }}-pip-${{ hashFiles('**/requirements.txt') }}

- run: pip install -r requirements.txt
```

### Rust Caching

```yaml
- uses: actions/cache@v4
  with:
    path: |
      ~/.cargo/bin/
      ~/.cargo/registry/index/
      ~/.cargo/registry/cache/
      ~/.cargo/git/db/
      target/
    key: ${{ runner.os }}-cargo-${{ hashFiles('**/Cargo.lock') }}
```

## Docker BuildKit Cache

### GitHub Actions Cache Backend

```yaml
- uses: docker/setup-buildx-action@v3

- uses: docker/build-push-action@v6
  with:
    context: .
    cache-from: type=gha,scope=myapp
    cache-to: type=gha,mode=max,scope=myapp
```

### Component-Specific Scopes

```yaml
strategy:
  matrix:
    component: [api, worker, scheduler]

steps:
  - uses: docker/build-push-action@v6
    with:
      context: ./services/${{ matrix.component }}
      cache-from: type=gha,scope=${{ matrix.component }}
      cache-to: type=gha,mode=max,scope=${{ matrix.component }}
```

### Registry Cache Backend

```yaml
- uses: docker/build-push-action@v6
  with:
    context: .
    cache-from: type=registry,ref=ghcr.io/${{ github.repository }}:buildcache
    cache-to: type=registry,ref=ghcr.io/${{ github.repository }}:buildcache,mode=max
```

### Multi-Stage Cache

```yaml
- uses: docker/build-push-action@v6
  with:
    context: .
    target: builder
    cache-from: |
      type=gha,scope=deps
      type=gha,scope=builder
    cache-to: type=gha,mode=max,scope=builder
```

### Inline Cache

```yaml
- uses: docker/build-push-action@v6
  with:
    context: .
    push: true
    tags: myapp:latest
    cache-from: type=registry,ref=myapp:latest
    cache-to: type=inline
```

## Tool and Dependency Caching

### Binary Tools

```yaml
- name: Cache tools
  uses: actions/cache@v4
  id: cache-tools
  with:
    path: |
      /tmp/kind
      /tmp/kubectl
      /tmp/helm
      /tmp/chainsaw
    key: tools-${{ runner.os }}-kind-v0.24.0-kubectl-v1.31-helm-v3.16-chainsaw-v0.2.13

- name: Install tools
  if: steps.cache-tools.outputs.cache-hit != 'true'
  run: |
    curl -sSLo /tmp/kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-amd64
    curl -sSLo /tmp/kubectl https://dl.k8s.io/release/v1.31.0/bin/linux/amd64/kubectl
    curl -sS https://get.helm.sh/helm-v3.16.0-linux-amd64.tar.gz | tar -xz -C /tmp
    chmod +x /tmp/{kind,kubectl,helm}
```

### Docker Images

```yaml
- name: Cache Docker images
  uses: actions/cache@v4
  with:
    path: /tmp/docker-images
    key: docker-${{ runner.os }}-${{ hashFiles('**/Dockerfile') }}

- name: Load cached images
  run: |
    if [ -d /tmp/docker-images ]; then
      for image in /tmp/docker-images/*.tar; do
        docker load -i "$image"
      done
    fi
```

### Helm Charts

```yaml
- name: Cache Helm charts
  uses: actions/cache@v4
  with:
    path: |
      ~/.cache/helm
      chart/charts
    key: ${{ runner.os }}-helm-${{ hashFiles('chart/Chart.lock') }}

- name: Update Helm dependencies
  if: steps.cache.outputs.cache-hit != 'true'
  run: helm dependency update chart/
```

### Build Artifacts

```yaml
- name: Cache compiled binaries
  uses: actions/cache@v4
  with:
    path: dist/
    key: ${{ runner.os }}-build-${{ github.sha }}

- name: Build
  if: steps.cache.outputs.cache-hit != 'true'
  run: make build
```

## Test Caching

### Test Results

```yaml
- name: Cache test results
  uses: actions/cache@v4
  with:
    path: |
      .testcache
      cover.out
    key: test-${{ runner.os }}-${{ hashFiles('**/*.go') }}
```

### Coverage Data

```yaml
- name: Cache coverage
  uses: actions/cache@v4
  with:
    path: |
      coverage/
      .coverage
      cover.out
    key: coverage-${{ runner.os }}-${{ hashFiles('**/*.go') }}
```

### Test Dependencies

```yaml
- name: Cache test tools
  uses: actions/cache@v4
  with:
    path: |
      ~/go/bin/gotestsum
      ~/go/bin/golangci-lint
    key: ${{ runner.os }}-test-tools-${{ hashFiles('tools.go') }}
```

## Cache Optimization

### Layered Cache Strategy

**Use multiple restore-keys for fallback:**

```yaml
- uses: actions/cache@v4
  with:
    path: ~/.cache/go-build
    key: ${{ runner.os }}-go-${{ hashFiles('**/go.sum') }}-${{ hashFiles('**/*.go') }}
    restore-keys: |
      ${{ runner.os }}-go-${{ hashFiles('**/go.sum') }}-
      ${{ runner.os }}-go-
      ${{ runner.os }}-
```

### Parallel Caching

```yaml
jobs:
  setup:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/cache@v4
        with:
          path: ~/.cache/go-build
          key: ${{ runner.os }}-go-${{ hashFiles('**/go.sum') }}

      - uses: actions/cache@v4
        with:
          path: node_modules
          key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
```

### Smart Cache Invalidation

**Hash specific files only:**

```yaml
key: ${{ runner.os }}-build-${{ hashFiles('src/**/*.go', 'go.sum') }}
```

**Exclude test files from build cache:**

```yaml
key: ${{ runner.os }}-build-${{ hashFiles('**/*.go', '!**/*_test.go') }}
```

**Use workflow file in key:**

```yaml
key: ${{ runner.os }}-${{ hashFiles('.github/workflows/ci.yaml') }}-${{ hashFiles('**/go.sum') }}
```

### Size Management

**Cache only necessary paths:**

```yaml
- uses: actions/cache@v4
  with:
    path: |
      ~/.cache/go-build
      ~/go/pkg/mod
    key: ${{ runner.os }}-go-${{ hashFiles('**/go.sum') }}
```

**Compress large artifacts:**

```yaml
- name: Create cached archive
  run: |
    tar -czf cache.tar.gz large-directory/

- uses: actions/cache@v4
  with:
    path: cache.tar.gz
    key: ${{ runner.os }}-data-${{ hashFiles('data/**') }}
```

### Cleanup Old Caches

**Automatic cleanup (GitHub manages):**
- Caches not accessed in 7 days are evicted
- Total cache size limit: 10 GB per repository

**Manual cache management:**

```yaml
- name: Clear old caches
  run: |
    gh api \
      -H "Accept: application/vnd.github+json" \
      "/repos/${{ github.repository }}/actions/caches" \
      --jq '.actions_caches[] | select(.last_accessed_at < (now - 604800)) | .id' \
      | xargs -I {} gh api --method DELETE "/repos/${{ github.repository }}/actions/caches/{}"
```

## Advanced Patterns

### Cross-Job Caching

```yaml
jobs:
  setup:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/cache@v4
        id: cache
        with:
          path: node_modules
          key: ${{ runner.os }}-deps-${{ hashFiles('**/package-lock.json') }}

      - if: steps.cache.outputs.cache-hit != 'true'
        run: npm ci

  test:
    needs: setup
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/cache@v4
        with:
          path: node_modules
          key: ${{ runner.os }}-deps-${{ hashFiles('**/package-lock.json') }}

      - run: npm test
```

### Matrix Caching

```yaml
strategy:
  matrix:
    go-version: ['1.21', '1.22', '1.23']

steps:
  - uses: actions/cache@v4
    with:
      path: |
        ~/.cache/go-build
        ~/go/pkg/mod
      key: ${{ runner.os }}-go${{ matrix.go-version }}-${{ hashFiles('**/go.sum') }}
```

### Conditional Caching

```yaml
- uses: actions/cache@v4
  if: github.event_name == 'pull_request'
  with:
    path: ~/.cache
    key: pr-${{ github.event.pull_request.number }}-${{ hashFiles('**/*.go') }}

- uses: actions/cache@v4
  if: github.event_name == 'push'
  with:
    path: ~/.cache
    key: main-${{ github.sha }}
```

### Warm Cache Strategy

```yaml
- name: Warm cache
  if: github.event_name == 'schedule'
  run: |
    go mod download
    go build ./...
    npm ci

- uses: actions/cache@v4
  with:
    path: |
      ~/.cache/go-build
      ~/go/pkg/mod
      ~/.npm
    key: warmup-${{ github.run_id }}
```

## Dockerfile Cache Optimization

### Cache Mount in Dockerfile

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

### Dependency Layer Separation

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

## Performance Benchmarks

### Typical Cache Hit Improvements

| Operation | Without Cache | With Cache | Improvement |
|-----------|--------------|------------|-------------|
| Go mod download | 30-60s | 2-5s | 85-90% |
| npm install | 45-90s | 5-10s | 85-90% |
| Docker build | 3-5min | 30-60s | 80-90% |
| Tool installation | 60-120s | 2-5s | 95-98% |

### Cache Size Recommendations

- **Go modules**: 100-500 MB
- **Node modules**: 200-800 MB
- **Docker layers**: 1-3 GB
- **Build artifacts**: 50-200 MB
- **Test tools**: 50-150 MB

## Advanced Patterns (2025)

### Cross-Job Cache with Restore/Save

**New pattern: Split cache operations for better control**

```yaml
jobs:
  setup:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11  # v4.1.1

      - uses: actions/cache/restore@v4
        id: cache
        with:
          path: node_modules
          key: ${{ runner.os }}-deps-${{ hashFiles('**/package-lock.json') }}

      - if: steps.cache.outputs.cache-hit != 'true'
        run: npm ci

      - uses: actions/cache/save@v4
        if: steps.cache.outputs.cache-hit != 'true'
        with:
          path: node_modules
          key: ${{ runner.os }}-deps-${{ hashFiles('**/package-lock.json') }}

  test:
    needs: setup
    runs-on: ubuntu-latest
    steps:
      - uses: actions/cache/restore@v4
        with:
          path: node_modules
          key: ${{ runner.os }}-deps-${{ hashFiles('**/package-lock.json') }}

      - run: npm test
```

### Matrix-Based Cache Keys

```yaml
strategy:
  matrix:
    node-version: [18, 20, 22]

steps:
  - uses: actions/cache@v4
    with:
      path: ~/.npm
      key: ${{ runner.os }}-node-${{ matrix.node-version }}-${{ hashFiles('**/package-lock.json') }}
      restore-keys: |
        ${{ runner.os }}-node-${{ matrix.node-version }}-
        ${{ runner.os }}-node-
```

### Selective Cache Invalidation

```yaml
- uses: actions/cache@v4
  with:
    path: dist/
    key: ${{ runner.os }}-build-${{ hashFiles('src/**/*.ts', 'package.json', '!src/**/*.test.ts') }}
```

### Performance Metrics from 2025

| Scenario | Without Cache | With Cache | Improvement |
|----------|--------------|------------|-------------|
| Go mod download | 45s | 3s | 93% |
| npm install (500 deps) | 75s | 8s | 89% |
| Docker build (multi-stage) | 4m 30s | 45s | 83% |
| Tool installation (Kind, kubectl, Helm) | 90s | 3s | 97% |

## Best Practices

### Cache Key Design
- Include OS in key: `${{ runner.os }}`
- Hash dependency files: `${{ hashFiles('**/go.sum') }}`
- Use version prefix for breaking changes: `v2-${{ ... }}`
- Make keys specific but not too granular
- Include matrix variables: `${{ matrix.node-version }}`

### Cache Path Selection
- Cache only what's expensive to recreate (>10s to regenerate)
- Don't cache generated artifacts you can rebuild quickly
- Exclude test files from production caches
- Keep total cache size under 5 GB when possible
- Use compression for large directories

### Restore Keys Strategy
- Primary key: Most specific (exact match)
- Restore keys: Progressively less specific
- Always include OS in restore keys
- Consider branch-specific restore keys
- Use workflow version in key for breaking changes

### Monitoring and Maintenance
- Monitor cache hit rates in workflow logs (target >80%)
- Invalidate caches when dependencies change
- Use different keys for different branches
- Clean up old caches periodically (auto-eviction after 7 days unused)
- GitHub limit: 10 GB total cache per repository

### Common Mistakes to Avoid
- ❌ Caching too much (slows uploads, wastes storage)
- ❌ Keys that never match (too specific, include timestamps)
- ❌ Keys that always match (too generic, never invalidate)
- ❌ Caching generated files that are fast to rebuild
- ❌ Not using restore-keys for fallback
- ❌ Same cache key across different workflows
- ❌ Not using actions/cache@v4 (v3 deprecated Feb 2025)

### 2025 Recommendations
- **Use actions/cache@v4** (required after February 1, 2025)
- **Split cache operations** with restore/save for complex scenarios
- **Matrix-based caching** for multi-version builds
- **Selective invalidation** using file patterns in hashFiles
- **Monitor cache hit rates** and optimize for 80%+ hits
- **Use shallow clones** (fetch-depth: 1) alongside caching
