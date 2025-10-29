---
name: github-cicd
description: Expert skill for setting up and debugging GitHub Actions CI/CD pipelines for Go projects, covering reusable workflows, Docker builds, Kubernetes deployments, and troubleshooting
---

# GitHub CI/CD Expert

Expert assistant for GitHub Actions CI/CD pipelines. Helps with designing, implementing, debugging, and optimizing workflows for Go projects, Docker builds, and Kubernetes deployments.

## Core Capabilities

### 1. Workflow Design and Setup
When designing CI/CD workflows:
- Create reusable workflows with proper input/output parameters
- Set up job dependencies and conditional execution
- Configure appropriate event triggers (push, PR, tags, workflow_dispatch)
- Implement path-based filtering for monorepo support
- Use proper permissions (contents, id-token, packages)
- **Leverage aggressive caching for dependencies, builds, and tools**

**References**:
- [references/workflow-basics.md](references/workflow-basics.md)
- [references/reusable-workflows.md](references/reusable-workflows.md)
- [references/caching-strategies.md](references/caching-strategies.md)

### 2. Semantic Versioning and Docker Builds
When implementing versioning and Docker builds in CI/CD:
- **Automate semantic versioning from git tags and history**
- Calculate versions using commit count, tag parsing, or conventional commits
- Create git tags automatically on successful builds
- Use BuildKit caching with GitHub Actions cache
- Create PR-specific builds with artifact exports
- Push production builds with semantic version tags (v1.2.3, v1.2, v1, latest)
- Integrate with container registries (ECR, GHCR, Docker Hub)

**References**:
- [references/docker-build-patterns.md](references/docker-build-patterns.md)
- [references/workflow-basics.md](references/workflow-basics.md)

### 3. Testing Strategies
When setting up testing workflows:
- Configure unit tests with coverage reporting
- Set up linting and code quality checks
- Implement E2E tests with ephemeral clusters (Kind)
- Cache test dependencies for faster runs
- Upload test artifacts and coverage reports

**References**:
- [references/testing-strategies.md](references/testing-strategies.md)
- [references/workflow-basics.md](references/workflow-basics.md)

### 4. Kubernetes Deployment
When deploying to Kubernetes:
- Use OIDC authentication for cloud providers
- Implement Helm-based deployments
- Handle environment-specific configurations
- Create automatic version tagging
- Validate deployments with kubectl wait

**References**:
- [references/kubernetes-deployment.md](references/kubernetes-deployment.md)
- [references/workflow-basics.md](references/workflow-basics.md)

### 5. Debugging and Troubleshooting
When debugging workflow failures:
- Analyze workflow logs and step outputs
- Use debug mode and re-run with debug logging
- Implement proper error handling and debug output
- Add conditional cleanup steps (always())
- Create artifacts for post-failure inspection

**References**:
- [references/debugging-workflows.md](references/debugging-workflows.md)
- [references/workflow-basics.md](references/workflow-basics.md)

## When to Use This Skill

Use this skill when:
- Setting up new GitHub Actions workflows
- Creating reusable workflow components
- Implementing CI/CD for Go projects
- Building and publishing Docker images
- Deploying to Kubernetes (EKS, GKE, AKS, etc.)
- **Debugging failed workflow runs**
- **Optimizing workflow performance**
- **Setting up monorepo CI/CD with path filtering**
- **Implementing semantic versioning**
- **Troubleshooting authentication issues (OIDC, tokens)**

## Workflow Structure

### Basic Workflow Anatomy

```yaml
name: Workflow Name

on:
  push:
    branches: [ main ]
  pull_request:
    types: [ opened, synchronize ]

jobs:
  job-name:
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - uses: actions/checkout@v4
      - name: Step name
        run: echo "Hello"
```

### Reusable Workflow Pattern

**Caller Workflow:**
```yaml
jobs:
  test:
    uses: ./.github/workflows/test-go.yaml
    with:
      component_path: app
      enable_coverage: true
```

**Called Workflow:**
```yaml
on:
  workflow_call:
    inputs:
      component_path:
        required: true
        type: string
```

## Key Principles

1. **Security First**: Pin actions to SHA, use OIDC (not secrets), least-privilege permissions, audit supply chain
2. **Reusability**: Create reusable workflows for jobs, composite actions for steps
3. **Aggressive Caching**: Cache dependencies, builds, tools, Docker layers (actions/cache@v4, 80-90% speedup)
4. **Performance**: Shallow clones, matrix optimization, job parallelization, self-hosted for heavy builds
5. **Conditional Execution**: Path filters, environment gates, required checks
6. **Semantic Versioning**: Automate from git tags, create tags automatically, multiple tag formats
7. **Observability**: Detailed error output, artifacts for debugging, environment protection logs
8. **Least Privilege**: Explicit permissions, environment protection rules, short-lived OIDC tokens

## Common Patterns

### Security: Pin Actions to SHA

```yaml
steps:
  - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11  # v4.1.1
  - uses: docker/build-push-action@4a13e500e55cf31b7a5d59a38ab2040ab0f42f56  # v5.1.0
```

### Security: OIDC with Environment Protection

```yaml
jobs:
  deploy:
    environment:
      name: production
    permissions:
      id-token: write
      contents: read
    steps:
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789:role/github-prod
          aws-region: us-east-1
```

### Semantic Versioning Automation

```yaml
- name: Calculate semantic version
  id: version
  run: |
    LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
    COMMITS=$(git rev-list ${LATEST_TAG}..HEAD --count)
    VERSION=${LATEST_TAG#v}

    if [ "$COMMITS" -gt 0 ]; then
      IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION"
      VERSION="$MAJOR.$MINOR.$((PATCH + 1))"
    fi

    echo "version=$VERSION" >> $GITHUB_OUTPUT

- name: Tag release
  run: |
    git config user.name "github-actions[bot]"
    git config user.email "github-actions[bot]@users.noreply.github.com"
    git tag -a "v${{ steps.version.outputs.version }}" -m "Release v${{ steps.version.outputs.version }}"
    git push origin "v${{ steps.version.outputs.version }}"
```

### Conditional Job Execution

```yaml
jobs:
  test:
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    steps:
      - run: make test

  deploy:
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - run: make deploy
```

### Job Dependencies

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - run: make test

  build:
    runs-on: ubuntu-latest
    steps:
      - run: make build

  deploy:
    needs: [test, build]
    if: success()
    runs-on: ubuntu-latest
    steps:
      - run: make deploy
```

### Path Filtering (Monorepo)

```yaml
on:
  push:
    paths:
      - 'component-a/**'
      - 'shared/**'
  pull_request:
    paths:
      - 'component-a/**'
```

### Dependency and Build Caching

```yaml
- uses: actions/setup-go@v5
  with:
    go-version: '1.23'
    cache: true

- uses: actions/cache@v4
  with:
    path: |
      ~/.cache/go-build
      ~/go/pkg/mod
    key: ${{ runner.os }}-go-${{ hashFiles('**/go.sum') }}
    restore-keys: |
      ${{ runner.os }}-go-
```

### Docker Build with Caching

```yaml
- uses: docker/setup-buildx-action@v3

- uses: docker/build-push-action@v6
  with:
    context: .
    push: false
    tags: myapp:pr-${{ github.event.pull_request.number }}
    cache-from: type=gha,scope=myapp
    cache-to: type=gha,mode=max,scope=myapp
```

### OIDC Authentication (AWS)

```yaml
permissions:
  id-token: write
  contents: read

steps:
  - uses: aws-actions/configure-aws-credentials@v4
    with:
      aws-region: us-east-1
      role-to-assume: arn:aws:iam::123456789:role/github-actions
```

### Artifact Upload/Download

```yaml
- uses: actions/upload-artifact@v4
  with:
    name: build-output
    path: dist/

- uses: actions/download-artifact@v4
  with:
    name: build-output
    path: dist/
```

### Debugging with kubectl

```yaml
- name: Deploy application
  run: |
    kubectl apply -f manifests/
    if ! kubectl wait --for=condition=ready pod -l app=myapp --timeout=300s; then
      echo "Deployment failed. Debug information:"
      kubectl get pods
      kubectl describe pod -l app=myapp
      kubectl logs -l app=myapp --tail=100 || true
      exit 1
    fi
```

## Reference Files

- **workflow-basics.md**: GitHub Actions fundamentals, syntax, events, jobs, steps
- **reusable-workflows.md**: Creating and using reusable workflows, inputs/outputs, secrets
- **docker-build-patterns.md**: Docker builds, multi-arch, caching, registries, semantic versioning
- **testing-strategies.md**: Unit tests, E2E tests, coverage, linting, Kind clusters
- **kubernetes-deployment.md**: Helm deployments, OIDC, kubectl validation, multi-environment
- **debugging-workflows.md**: Troubleshooting failures, logs, debug mode, common issues
- **gh-cli-patterns.md**: GitHub CLI for PRs, releases, workflows, API access
- **caching-strategies.md**: Comprehensive caching patterns for builds, tests, and dependencies

Load references as needed based on the CI/CD task at hand.

## Anti-Patterns to Avoid

❌ **Don't:**
- Hardcode credentials in workflows
- Use `@main`, `@master`, or mutable tags for third-party actions
- Skip action security audits (supply chain attacks are real - see tj-actions compromise 2025)
- Use overly permissive GITHUB_TOKEN permissions
- Skip error handling and debugging output
- Run all tests on every path change without path filtering
- Deploy without validation
- Skip caching for repetitive operations
- Create monolithic workflows that can't be reused
- Use actions from unverified publishers

✅ **Do:**
- Use OIDC for credentialless workflows (60-min tokens, no long-lived secrets)
- Pin actions to full commit SHA: `actions/checkout@abc123def...` (not tags)
- Only use verified publishers or audit action source code
- Set `permissions:` explicitly with least-privilege (id-token: write, contents: read)
- Use environment protection rules for production deployments
- Include detailed error output and cleanup steps
- Use path filters for targeted CI
- Validate deployments with kubectl wait
- Cache aggressively with actions/cache@v4 (v3 deprecated Feb 2025)
- Request minimal required permissions
- Create reusable workflows and composite actions
- Use shallow clones: `fetch-depth: 1` for performance

## Project Integration

When working with a specific project:
- Review existing workflows in `.github/workflows/`
- Check for project-specific scripts (e.g., `.github/scripts/`)
- Understand the project's deployment environments
- Identify authentication mechanisms (OIDC roles, tokens)
- Review Makefile targets used in CI
- Check for project-specific runners or infrastructure

## Example Projects

This skill includes patterns from real-world Go/Kubernetes projects:
- Reusable workflow orchestration
- Monorepo CI/CD with path filtering
- Semantic versioning automation
- Kind-based E2E testing
- Helm deployments with OIDC
- Docker BuildKit optimization

Adapt these patterns to your specific project's needs.
