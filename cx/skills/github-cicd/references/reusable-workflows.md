# Reusable Workflows

Creating and using reusable GitHub Actions workflows for DRY CI/CD pipelines.

## Table of Contents
1. [Why Reusable Workflows](#why-reusable-workflows)
2. [Composite Actions vs Reusable Workflows](#composite-actions-vs-reusable-workflows)
3. [Creating Reusable Workflows](#creating-reusable-workflows)
4. [Calling Reusable Workflows](#calling-reusable-workflows)
5. [Inputs and Outputs](#inputs-and-outputs)
6. [Secrets in Reusable Workflows](#secrets-in-reusable-workflows)
7. [Common Patterns](#common-patterns)

## Why Reusable Workflows

### Benefits
- **DRY Principle**: Write once, use many times
- **Consistency**: Same process across all components
- **Maintainability**: Update in one place
- **Composition**: Build complex pipelines from simple components
- **Testing**: Easier to test isolated workflow components

### Use Cases
- Testing workflows (unit, integration, E2E)
- Build workflows (compile, package, container)
- Deployment workflows (staging, production)
- Release workflows (versioning, tagging, publishing)

## Composite Actions vs Reusable Workflows

### When to Use Each

| Feature | Composite Actions | Reusable Workflows |
|---------|------------------|-------------------|
| **Level** | Step-level reuse | Job-level reuse |
| **Location** | `.github/actions/` | `.github/workflows/` |
| **Nesting** | Up to 10 layers | Cannot nest |
| **Jobs** | N/A (steps only) | Multiple jobs supported |
| **Runners** | Uses caller's runner | Can specify own runner |
| **Secrets** | Inherit from workflow | Explicit passing required |
| **Best for** | Related steps (build, scan, deploy) | Complete workflows (CI, CD) |

### Composite Action Example

**.github/actions/docker-build/action.yaml:**
```yaml
name: Docker Build
description: Build and scan Docker image

inputs:
  image-name:
    required: true
  context:
    default: '.'

outputs:
  image-tag:
    value: ${{ steps.build.outputs.tag }}

runs:
  using: composite
  steps:
    - uses: docker/setup-buildx-action@v3
      shell: bash

    - uses: docker/build-push-action@v6
      id: build
      shell: bash
      with:
        context: ${{ inputs.context }}
        tags: ${{ inputs.image-name }}:latest
        load: true

    - name: Scan image
      shell: bash
      run: trivy image ${{ inputs.image-name }}:latest
```

**Usage:**
```yaml
steps:
  - uses: ./.github/actions/docker-build
    with:
      image-name: myapp
      context: ./services/api
```

### Reusable Workflow Example

**.github/workflows/build-go.yaml:**
```yaml
on:
  workflow_call:
    inputs:
      go-version:
        required: false
        type: string
        default: '1.23'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: ${{ inputs.go-version }}
      - run: go build ./...
```

**Usage:**
```yaml
jobs:
  build:
    uses: ./.github/workflows/build-go.yaml
    with:
      go-version: '1.23'
```

### Decision Guide

**Use Composite Actions when:**
- Grouping 3-10 related steps
- Need to reuse step logic within a job
- Want to version step combinations
- Steps are tightly coupled (build → scan → push)
- Need deep nesting (up to 10 levels)

**Use Reusable Workflows when:**
- Defining complete CI/CD processes
- Need multiple jobs
- Want different runners per job
- Orchestrating job dependencies
- Sharing across repositories
- Need matrix strategies

## Creating Reusable Workflows

### Basic Structure

```yaml
name: Reusable Test Workflow

on:
  workflow_call:
    inputs:
      component_path:
        description: 'Path to component directory'
        required: true
        type: string
      go_version:
        description: 'Go version to use'
        required: false
        type: string
        default: '1.23'
    outputs:
      coverage:
        description: 'Test coverage percentage'
        value: ${{ jobs.test.outputs.coverage }}

jobs:
  test:
    runs-on: ubuntu-latest
    outputs:
      coverage: ${{ steps.test.outputs.coverage }}
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-go@v5
        with:
          go-version: ${{ inputs.go_version }}
          cache-dependency-path: ${{ inputs.component_path }}/go.sum

      - name: Run tests
        id: test
        working-directory: ${{ inputs.component_path }}
        run: |
          go test -v -coverprofile=cover.out ./...
          COVERAGE=$(go tool cover -func=cover.out | grep total | awk '{print $3}')
          echo "coverage=$COVERAGE" >> $GITHUB_OUTPUT
```

### Input Types

```yaml
inputs:
  # String input
  environment:
    type: string
    required: true
    description: 'Deployment environment'

  # Boolean input
  enable_linter:
    type: boolean
    required: false
    default: true
    description: 'Run linter'

  # Number input
  timeout:
    type: number
    required: false
    default: 30
    description: 'Timeout in minutes'

  # Choice input
  log_level:
    type: choice
    required: false
    default: 'info'
    description: 'Log level'
    options:
      - debug
      - info
      - warn
      - error
```

### Output Definition

```yaml
on:
  workflow_call:
    outputs:
      version:
        description: 'Built version'
        value: ${{ jobs.build.outputs.version }}
      image_tag:
        description: 'Docker image tag'
        value: ${{ jobs.build.outputs.image_tag }}

jobs:
  build:
    outputs:
      version: ${{ steps.version.outputs.version }}
      image_tag: ${{ steps.build.outputs.tag }}
    steps:
      - id: version
        run: echo "version=1.2.3" >> $GITHUB_OUTPUT
      - id: build
        run: echo "tag=latest" >> $GITHUB_OUTPUT
```

## Calling Reusable Workflows

### Basic Call

```yaml
name: CI Pipeline

on:
  pull_request:
    branches: [ main ]

jobs:
  test:
    uses: ./.github/workflows/test-go.yaml
    with:
      component_path: services/api
      go_version: '1.23'
```

### With Secrets

```yaml
jobs:
  deploy:
    uses: ./.github/workflows/deploy.yaml
    with:
      environment: production
    secrets:
      AWS_ROLE: ${{ secrets.AWS_PROD_ROLE }}
      API_KEY: ${{ secrets.PROD_API_KEY }}
```

### With Permissions

```yaml
jobs:
  build:
    uses: ./.github/workflows/build-container.yaml
    with:
      component_name: api
    permissions:
      id-token: write
      contents: read
```

### Using Outputs

```yaml
jobs:
  build:
    uses: ./.github/workflows/build.yaml
    with:
      component: api

  deploy:
    needs: build
    uses: ./.github/workflows/deploy.yaml
    with:
      image_tag: ${{ needs.build.outputs.image_tag }}
      version: ${{ needs.build.outputs.version }}
```

### Conditional Calls

```yaml
jobs:
  test:
    if: github.event_name == 'pull_request'
    uses: ./.github/workflows/test.yaml
    with:
      component: api

  deploy:
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    uses: ./.github/workflows/deploy.yaml
    with:
      environment: production
```

## Inputs and Outputs

### Input Usage in Reusable Workflow

```yaml
on:
  workflow_call:
    inputs:
      component_path:
        required: true
        type: string
      enable_coverage:
        required: false
        type: boolean
        default: false

jobs:
  test:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ${{ inputs.component_path }}
    steps:
      - uses: actions/checkout@v4

      - name: Run tests
        run: go test ./...

      - name: Generate coverage
        if: inputs.enable_coverage
        run: go test -coverprofile=cover.out ./...

      - name: Upload coverage
        if: inputs.enable_coverage
        uses: codecov/codecov-action@v4
        with:
          files: ./${{ inputs.component_path }}/cover.out
```

### Complex Output Patterns

```yaml
on:
  workflow_call:
    outputs:
      # Simple string output
      version:
        description: 'Semantic version'
        value: ${{ jobs.build.outputs.version }}

      # Composite output
      metadata:
        description: 'Build metadata JSON'
        value: ${{ jobs.build.outputs.metadata }}

jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      version: ${{ steps.version.outputs.version }}
      metadata: ${{ steps.metadata.outputs.json }}
    steps:
      - id: version
        run: echo "version=1.2.3" >> $GITHUB_OUTPUT

      - id: metadata
        run: |
          METADATA=$(jq -n \
            --arg version "1.2.3" \
            --arg commit "${{ github.sha }}" \
            --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
            '{version: $version, commit: $commit, timestamp: $timestamp}')
          echo "json=$METADATA" >> $GITHUB_OUTPUT
```

## Secrets in Reusable Workflows

### Defining Secrets

```yaml
on:
  workflow_call:
    inputs:
      environment:
        required: true
        type: string
    secrets:
      AWS_ROLE:
        required: true
        description: 'AWS IAM role ARN'
      DATABASE_URL:
        required: false
        description: 'Database connection string'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE }}
          aws-region: us-east-1

      - name: Deploy
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
        run: ./deploy.sh
```

### Passing Secrets

**Explicit secret passing:**
```yaml
jobs:
  deploy:
    uses: ./.github/workflows/deploy.yaml
    with:
      environment: production
    secrets:
      AWS_ROLE: ${{ secrets.AWS_PROD_ROLE }}
      DATABASE_URL: ${{ secrets.PROD_DATABASE_URL }}
```

**Inherit all secrets:**
```yaml
jobs:
  deploy:
    uses: ./.github/workflows/deploy.yaml
    with:
      environment: production
    secrets: inherit
```

## Common Patterns

### Pattern 1: Generic Go Testing

**Reusable workflow (`.github/workflows/test-go.yaml`):**
```yaml
name: Test Go Component

on:
  workflow_call:
    inputs:
      component_path:
        required: true
        type: string
      enable_linter:
        required: false
        type: boolean
        default: true
      enable_coverage:
        required: false
        type: boolean
        default: false

jobs:
  test:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ${{ inputs.component_path }}
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-go@v5
        with:
          go-version-file: ${{ inputs.component_path }}/go.mod
          cache-dependency-path: ${{ inputs.component_path }}/go.sum

      - name: Run unit tests
        run: make test

      - name: Run linter
        if: inputs.enable_linter
        run: make lint

      - name: Upload coverage
        if: inputs.enable_coverage
        uses: codecov/codecov-action@v4
        with:
          files: ./${{ inputs.component_path }}/cover.out
```

**Caller workflow:**
```yaml
jobs:
  test-api:
    uses: ./.github/workflows/test-go.yaml
    with:
      component_path: services/api
      enable_linter: true
      enable_coverage: true

  test-worker:
    uses: ./.github/workflows/test-go.yaml
    with:
      component_path: services/worker
      enable_linter: true
      enable_coverage: false
```

### Pattern 2: Generic Container Build

**Reusable workflow (`.github/workflows/build-container.yaml`):**
```yaml
name: Build Container

on:
  workflow_call:
    inputs:
      component_name:
        required: true
        type: string
      component_path:
        required: true
        type: string
      dockerfile_path:
        required: false
        type: string
        default: 'Dockerfile'
      registry:
        required: false
        type: string
        default: 'ghcr.io'
    outputs:
      image_tag:
        description: 'Built image tag'
        value: ${{ jobs.build.outputs.image_tag }}
    secrets:
      REGISTRY_TOKEN:
        required: false

permissions:
  contents: read
  packages: write

jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      image_tag: ${{ steps.meta.outputs.version }}
    steps:
      - uses: actions/checkout@v4

      - uses: docker/setup-buildx-action@v3

      - uses: docker/login-action@v3
        with:
          registry: ${{ inputs.registry }}
          username: ${{ github.actor }}
          password: ${{ secrets.REGISTRY_TOKEN || secrets.GITHUB_TOKEN }}

      - uses: docker/metadata-action@v5
        id: meta
        with:
          images: ${{ inputs.registry }}/${{ github.repository }}/${{ inputs.component_name }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=sha

      - uses: docker/build-push-action@v6
        with:
          context: ${{ inputs.component_path }}
          file: ${{ inputs.component_path }}/${{ inputs.dockerfile_path }}
          push: ${{ github.event_name != 'pull_request' }}
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha,scope=${{ inputs.component_name }}
          cache-to: type=gha,mode=max,scope=${{ inputs.component_name }}
```

**Caller workflow:**
```yaml
jobs:
  build-api:
    uses: ./.github/workflows/build-container.yaml
    with:
      component_name: api
      component_path: services/api
    permissions:
      contents: read
      packages: write

  build-worker:
    uses: ./.github/workflows/build-container.yaml
    with:
      component_name: worker
      component_path: services/worker
    permissions:
      contents: read
      packages: write
```

### Pattern 3: Orchestration Workflow

**Main workflow orchestrating multiple reusable workflows:**
```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    if: github.event_name == 'pull_request'
    uses: ./.github/workflows/test-go.yaml
    with:
      component_path: services/api
      enable_coverage: true

  build:
    uses: ./.github/workflows/build-container.yaml
    with:
      component_name: api
      component_path: services/api
    permissions:
      contents: read
      packages: write

  deploy:
    needs: [ test, build ]
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    uses: ./.github/workflows/deploy.yaml
    with:
      environment: production
      image_tag: ${{ needs.build.outputs.image_tag }}
    secrets:
      AWS_ROLE: ${{ secrets.AWS_PROD_ROLE }}
    permissions:
      id-token: write
      contents: read
```

### Pattern 4: Multi-Component Monorepo

**Main workflow with path filtering:**
```yaml
name: Monorepo CI/CD

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  # Detect changes
  changes:
    runs-on: ubuntu-latest
    outputs:
      api: ${{ steps.filter.outputs.api }}
      worker: ${{ steps.filter.outputs.worker }}
    steps:
      - uses: actions/checkout@v4
      - uses: dorny/paths-filter@v3
        id: filter
        with:
          filters: |
            api:
              - 'services/api/**'
            worker:
              - 'services/worker/**'

  # Test API only if changed
  test-api:
    needs: changes
    if: needs.changes.outputs.api == 'true'
    uses: ./.github/workflows/test-go.yaml
    with:
      component_path: services/api

  # Test Worker only if changed
  test-worker:
    needs: changes
    if: needs.changes.outputs.worker == 'true'
    uses: ./.github/workflows/test-go.yaml
    with:
      component_path: services/worker

  # Build API only if changed
  build-api:
    needs: [ changes, test-api ]
    if: needs.changes.outputs.api == 'true'
    uses: ./.github/workflows/build-container.yaml
    with:
      component_name: api
      component_path: services/api

  # Build Worker only if changed
  build-worker:
    needs: [ changes, test-worker ]
    if: needs.changes.outputs.worker == 'true'
    uses: ./.github/workflows/build-container.yaml
    with:
      component_name: worker
      component_path: services/worker
```

## Best Practices

### Design
- Keep reusable workflows focused and single-purpose
- Use descriptive input/output names
- Provide sensible defaults for optional inputs
- Document inputs and outputs with clear descriptions
- Make workflows generic enough to be reusable

### Organization
- Store reusable workflows in `.github/workflows/`
- Name with action verbs: `test-go.yaml`, `build-container.yaml`, `deploy-helm.yaml`
- Group related workflows in same directory
- Version workflows if making breaking changes

### Usage
- Prefer reusable workflows over composite actions for full jobs
- Use composite actions for step-level reusability
- Call reusable workflows from same repository (`./.github/workflows/`)
- Can call from other repositories (`org/repo/.github/workflows/name.yaml@ref`)

### Secrets
- Define required secrets explicitly
- Document secret requirements
- Use `secrets: inherit` only when all secrets are needed
- Prefer explicit secret passing for clarity

### Limitations
- Maximum 4 levels of nested reusable workflows
- Can't reference local actions from called workflow (use remote actions)
- Environment secrets must be passed explicitly
- Variables are inherited but secrets are not (unless `inherit`)

### Testing
- Test reusable workflows with `workflow_dispatch`
- Create test workflows that call with different inputs
- Validate outputs are correctly propagated
- Test error handling and edge cases
