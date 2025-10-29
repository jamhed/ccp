# GitHub Actions Workflow Basics

Fundamentals of GitHub Actions workflows for CI/CD pipelines.

## Table of Contents
1. [Workflow Structure](#workflow-structure)
2. [Event Triggers](#event-triggers)
3. [Jobs and Steps](#jobs-and-steps)
4. [Contexts and Expressions](#contexts-and-expressions)
5. [Permissions](#permissions)
6. [Secrets and Variables](#secrets-and-variables)
7. [Caching](#caching)
8. [Artifacts](#artifacts)

## Workflow Structure

### Basic Workflow Format

```yaml
name: Workflow Name

on:
  push:
    branches: [ main ]

permissions:
  contents: read

jobs:
  job-id:
    name: Job Display Name
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11  # v4.1.1
        with:
          fetch-depth: 1

      - name: Run command
        run: echo "Hello World"
```

### Workflow File Location

- Workflows must be in `.github/workflows/` directory
- File extension: `.yml` or `.yaml`
- Multiple workflows can exist in the same repository
- Workflow files are versioned with the code

### Workflow Components

1. **name**: Workflow display name (appears in GitHub UI)
2. **on**: Event triggers that start the workflow
3. **jobs**: One or more jobs to execute
4. **env**: Environment variables (workflow-level)
5. **defaults**: Default settings for all jobs

## Event Triggers

### Push Events

```yaml
on:
  push:
    branches:
      - main
      - 'releases/**'
    paths:
      - 'src/**'
      - '!src/docs/**'
    tags:
      - 'v*'
```

### Pull Request Events

```yaml
on:
  pull_request:
    types: [ opened, synchronize, reopened ]
    branches: [ main ]
    paths:
      - 'app/**'
```

**Common PR types:**
- `opened` - PR created
- `synchronize` - New commits pushed
- `reopened` - Closed PR reopened
- `closed` - PR closed or merged
- `ready_for_review` - Draft marked ready

### Manual Triggers

```yaml
on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy'
        required: true
        type: choice
        options:
          - dev
          - staging
          - prod
      debug:
        description: 'Enable debug mode'
        required: false
        type: boolean
        default: false
```

### Schedule (Cron)

```yaml
on:
  schedule:
    # Run at 2:00 AM UTC every day
    - cron: '0 2 * * *'
    # Run every Monday at 9:00 AM UTC
    - cron: '0 9 * * 1'
```

### Multiple Events

```yaml
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:
```

### Reusable Workflow Trigger

```yaml
on:
  workflow_call:
    inputs:
      config-path:
        required: true
        type: string
    secrets:
      token:
        required: true
    outputs:
      result:
        description: 'Build result'
        value: ${{ jobs.build.outputs.result }}
```

## Jobs and Steps

### Job Structure

```yaml
jobs:
  job-id:
    name: Job Display Name
    runs-on: ubuntu-latest
    timeout-minutes: 30
    permissions:
      contents: read
    env:
      JOB_VAR: value
    outputs:
      output-name: ${{ steps.step-id.outputs.value }}
    steps:
      - name: Step 1
        run: echo "Hello"
```

### Runners

**GitHub-hosted runners:**
```yaml
runs-on: ubuntu-latest      # Ubuntu (latest)
runs-on: ubuntu-22.04       # Ubuntu 22.04 (pinned)
runs-on: windows-latest     # Windows
runs-on: macos-latest       # macOS
```

**Self-hosted runners:**
```yaml
runs-on: [ self-hosted, linux, x64 ]
runs-on: my-custom-runner
```

### Job Dependencies

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Building..."

  test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - run: echo "Testing..."

  deploy:
    needs: [ build, test ]
    runs-on: ubuntu-latest
    steps:
      - run: echo "Deploying..."
```

### Conditional Job Execution

```yaml
jobs:
  test:
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    steps:
      - run: echo "Running tests on PR"

  deploy:
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - run: echo "Deploying to production"
```

### Job Outputs

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      version: ${{ steps.version.outputs.version }}
      image-tag: ${{ steps.build.outputs.tag }}
    steps:
      - id: version
        run: echo "version=1.2.3" >> $GITHUB_OUTPUT

      - id: build
        run: echo "tag=latest" >> $GITHUB_OUTPUT

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - run: echo "Deploying version ${{ needs.build.outputs.version }}"
```

### Matrix Strategy

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        go-version: [ '1.21', '1.22', '1.23' ]
        os: [ ubuntu-latest, macos-latest ]
    steps:
      - uses: actions/setup-go@v5
        with:
          go-version: ${{ matrix.go-version }}
      - run: go test ./...
```

**With exclusions:**
```yaml
strategy:
  matrix:
    os: [ ubuntu-latest, macos-latest, windows-latest ]
    go-version: [ '1.21', '1.22', '1.23' ]
    exclude:
      - os: macos-latest
        go-version: '1.21'
```

**Fail-fast control:**
```yaml
strategy:
  fail-fast: false  # Continue other jobs if one fails
  matrix:
    go-version: [ '1.21', '1.22', '1.23' ]
```

### Step Types

**Using Actions:**
```yaml
steps:
  - uses: actions/checkout@v4
  - uses: actions/setup-go@v5
    with:
      go-version: '1.23'
      cache: true
```

**Running Commands:**
```yaml
steps:
  - name: Run tests
    run: go test ./...

  - name: Multi-line script
    run: |
      echo "Building..."
      go build -o app ./cmd/app
      ./app --version
```

**Running Scripts:**
```yaml
steps:
  - name: Run shell script
    run: ./scripts/build.sh
    shell: bash

  - name: Run in working directory
    run: make test
    working-directory: ./subproject
```

**Conditional Steps:**
```yaml
steps:
  - name: Run only on main
    if: github.ref == 'refs/heads/main'
    run: echo "On main branch"

  - name: Run on success
    if: success()
    run: echo "Previous steps succeeded"

  - name: Run on failure
    if: failure()
    run: echo "A step failed"

  - name: Always run
    if: always()
    run: echo "Cleanup"
```

## Contexts and Expressions

### GitHub Context

```yaml
steps:
  - name: Print context values
    run: |
      echo "Repository: ${{ github.repository }}"
      echo "Ref: ${{ github.ref }}"
      echo "SHA: ${{ github.sha }}"
      echo "Event: ${{ github.event_name }}"
      echo "Actor: ${{ github.actor }}"
```

**Common github context values:**
- `github.repository` - `owner/repo`
- `github.ref` - Git ref (e.g., `refs/heads/main`)
- `github.sha` - Commit SHA
- `github.event_name` - Event that triggered workflow
- `github.event.pull_request.number` - PR number
- `github.actor` - User who triggered workflow
- `github.run_id` - Workflow run ID
- `github.run_number` - Workflow run number

### Environment Context

```yaml
steps:
  - name: Print environment
    run: |
      echo "Runner OS: ${{ runner.os }}"
      echo "Runner Arch: ${{ runner.arch }}"
      echo "Workspace: ${{ github.workspace }}"
```

### Job/Step Outputs Context

```yaml
jobs:
  job1:
    runs-on: ubuntu-latest
    outputs:
      result: ${{ steps.compute.outputs.value }}
    steps:
      - id: compute
        run: echo "value=42" >> $GITHUB_OUTPUT

  job2:
    needs: job1
    runs-on: ubuntu-latest
    steps:
      - run: echo "Result: ${{ needs.job1.outputs.result }}"
```

### Expressions and Functions

**Comparison operators:**
```yaml
if: github.ref == 'refs/heads/main'
if: github.event_name != 'pull_request'
if: steps.test.outputs.coverage > 80
```

**Logical operators:**
```yaml
if: github.event_name == 'push' && github.ref == 'refs/heads/main'
if: github.event_name == 'pull_request' || github.event_name == 'push'
if: "!startsWith(github.ref, 'refs/tags/')"
```

**String functions:**
```yaml
if: startsWith(github.ref, 'refs/tags/v')
if: endsWith(github.ref, '-beta')
if: contains(github.event.head_commit.message, '[skip ci]')
if: format('v{0}', steps.version.outputs.version)
```

**Status check functions:**
```yaml
if: success()           # All previous steps succeeded
if: failure()           # Any previous step failed
if: always()            # Always run
if: cancelled()         # Workflow was cancelled
```

## Permissions

### Default Permissions

```yaml
# Workflow-level permissions
permissions:
  contents: read
  pull-requests: write

jobs:
  job1:
    # Job-level permissions (overrides workflow-level)
    permissions:
      contents: write
      id-token: write
```

**Common permission scopes:**
- `contents` - Repository contents (read/write)
- `pull-requests` - PRs (read/write)
- `issues` - Issues (read/write)
- `packages` - GitHub Packages (read/write)
- `id-token` - OIDC token (write for AWS/Azure/GCP auth)
- `deployments` - Deployments (read/write)

### Minimal Permissions Pattern

```yaml
# Read-only by default
permissions:
  contents: read

jobs:
  deploy:
    # Escalate only where needed
    permissions:
      contents: write
      id-token: write
    steps:
      - name: Deploy
        run: ./deploy.sh
```

### OIDC Authentication

```yaml
permissions:
  id-token: write  # Required for OIDC
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789:role/github-actions
          aws-region: us-east-1
```

## Secrets and Variables

### Using Secrets

```yaml
steps:
  - name: Use secret
    env:
      API_KEY: ${{ secrets.API_KEY }}
    run: |
      echo "API_KEY is set"
      # Never echo the secret value!
```

**Types of secrets:**
- **Repository secrets**: Available to all workflows in repo
- **Environment secrets**: Available only to specific environment
- **Organization secrets**: Shared across repos

### Using Variables

```yaml
env:
  # Repository variable
  API_URL: ${{ vars.API_URL }}
  # Environment variable
  REGION: ${{ vars.REGION }}

steps:
  - run: echo "API URL: $API_URL"
```

### Environment Variables

**Workflow-level:**
```yaml
env:
  GO_VERSION: '1.23'
  BUILD_ENV: production

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Go version: $GO_VERSION"
```

**Job-level:**
```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    env:
      COMPONENT: api
    steps:
      - run: echo "Building $COMPONENT"
```

**Step-level:**
```yaml
steps:
  - name: Build
    env:
      CGO_ENABLED: 0
      GOOS: linux
    run: go build -o app
```

### Default Environment Variables

GitHub provides default environment variables:
- `CI=true`
- `GITHUB_WORKSPACE` - Working directory path
- `GITHUB_SHA` - Commit SHA
- `GITHUB_REF` - Git ref
- `GITHUB_REPOSITORY` - owner/repo
- `GITHUB_ACTOR` - User who triggered
- `GITHUB_TOKEN` - Auto-generated token

## Caching

### Actions Cache

```yaml
steps:
  - uses: actions/setup-go@v5
    with:
      go-version: '1.23'
      cache: true  # Auto-cache Go modules

  - uses: actions/cache@v4
    with:
      path: |
        ~/.cache/go-build
        ~/go/pkg/mod
      key: ${{ runner.os }}-go-${{ hashFiles('**/go.sum') }}
      restore-keys: |
        ${{ runner.os }}-go-
```

### Cache Strategies

**Exact match:**
```yaml
key: ${{ runner.os }}-deps-${{ hashFiles('**/package-lock.json') }}
```

**Fallback (restore-keys):**
```yaml
key: ${{ runner.os }}-deps-${{ hashFiles('**/package-lock.json') }}
restore-keys: |
  ${{ runner.os }}-deps-
  ${{ runner.os }}-
```

### Docker Layer Caching

```yaml
- uses: docker/setup-buildx-action@v3

- uses: docker/build-push-action@v6
  with:
    context: .
    cache-from: type=gha,scope=myapp
    cache-to: type=gha,mode=max,scope=myapp
```

## Artifacts

### Upload Artifacts

```yaml
steps:
  - name: Build
    run: make build

  - uses: actions/upload-artifact@v4
    with:
      name: binary
      path: dist/app
      retention-days: 7
```

**Multiple paths:**
```yaml
- uses: actions/upload-artifact@v4
  with:
    name: build-outputs
    path: |
      dist/
      logs/
      !dist/*.map
```

### Download Artifacts

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: make build
      - uses: actions/upload-artifact@v4
        with:
          name: binary
          path: dist/app

  test:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - uses: actions/download-artifact@v4
        with:
          name: binary
          path: ./bin
      - run: ./bin/app --version
```

### Artifact Patterns

**Build once, use many times:**
```yaml
jobs:
  build:
    steps:
      - run: make build
      - uses: actions/upload-artifact@v4
        with:
          name: app
          path: dist/

  test:
    needs: build
    steps:
      - uses: actions/download-artifact@v4
        with:
          name: app
      - run: ./test.sh

  deploy:
    needs: [ build, test ]
    steps:
      - uses: actions/download-artifact@v4
        with:
          name: app
      - run: ./deploy.sh
```

## Security Best Practices (2025 Update)

### Action Security

**Pin to commit SHA (not tags):**
```yaml
- uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11  # v4.1.1
- uses: docker/build-push-action@4a13e500e55cf31b7a5d59a38ab2040ab0f42f56  # v5.1.0
```

**Why:** Mutable tags can be updated by attackers. The tj-actions/changed-files compromise (March 2025) demonstrated this risk. Commit SHAs are immutable.

**Only use verified publishers:**
- GitHub official actions (actions/*)
- Major cloud providers (aws-actions/*, azure/*, google-github-actions/*)
- Well-established, audited community actions

### Permission Security

**Always set explicit permissions:**
```yaml
permissions:
  contents: read
  id-token: write
  packages: write
```

**Default (GITHUB_TOKEN) is too permissive. Set least-privilege explicitly.**

### OIDC for Credentialless Workflows

```yaml
permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    environment: production
    steps:
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789:role/github-prod
          aws-region: us-east-1
```

**Benefits:**
- No long-lived secrets stored in GitHub
- 60-minute token expiration
- Trust conditions based on repository/branch/environment
- Auditability through cloud IAM

### Environment Protection Rules

```yaml
jobs:
  deploy:
    environment:
      name: production
      url: https://app.example.com
    steps:
      - run: deploy.sh
```

Configure in GitHub UI:
- Required reviewers
- Wait timer
- Branch restrictions
- Environment secrets

### Secret Management

```yaml
- name: Use secret
  env:
    API_KEY: ${{ secrets.API_KEY }}
  run: |
    curl -H "Authorization: Bearer $API_KEY" https://api.example.com
```

**Best practices:**
- Use OIDC when possible (no secrets)
- Rotate secrets regularly
- Use environment-specific secrets
- Never log secrets: `echo $API_KEY` ❌

## Best Practices

### Workflow Organization
- One workflow per major pipeline (CI, CD, release)
- Use reusable workflows for common patterns
- Keep workflows focused and composable
- Document complex logic with comments

### Performance
- Cache dependencies aggressively with actions/cache@v4
- Use shallow clones: `fetch-depth: 1`
- Use path filters to avoid unnecessary runs
- Leverage matrix builds for parallel testing
- Consider self-hosted runners for heavy builds
- Use artifacts to share build outputs

### Maintainability
- Pin actions to commit SHA
- Use descriptive job and step names
- Add conditional cleanup steps
- Include debugging output for failures
- Version reusable workflows

### Debugging
- Use `if: always()` for cleanup steps
- Log relevant context on failures
- Upload artifacts for inspection
- Use workflow_dispatch for manual testing
