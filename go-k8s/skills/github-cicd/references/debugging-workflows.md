# Debugging GitHub Actions Workflows

Troubleshooting failed workflows, using debug mode, and diagnosing common CI/CD issues.

## Table of Contents
1. [Debug Mode](#debug-mode)
2. [Analyzing Failures](#analyzing-failures)
3. [Common Issues](#common-issues)
4. [Debugging Techniques](#debugging-techniques)
5. [Local Testing](#local-testing)
6. [Performance Issues](#performance-issues)

## Debug Mode

### Enable Debug Logging

**Method 1: Repository secrets**

Add these secrets to your repository:
- `ACTIONS_STEP_DEBUG` = `true` (step-level debug)
- `ACTIONS_RUNNER_DEBUG` = `true` (runner-level debug)

**Method 2: Re-run with debug logging**

In GitHub UI:
1. Go to failed workflow run
2. Click "Re-run jobs" dropdown
3. Select "Re-run jobs with debug logging"

### Debug Output in Workflows

```yaml
- name: Debug environment
  run: |
    echo "::debug::Debugging information"
    echo "::notice::Important notice"
    echo "::warning::Warning message"
    echo "::error::Error message"
```

### Print Context Information

```yaml
- name: Dump GitHub context
  run: echo '${{ toJSON(github) }}'

- name: Dump environment
  run: env | sort

- name: Dump job context
  run: echo '${{ toJSON(job) }}'

- name: Dump steps context
  run: echo '${{ toJSON(steps) }}'

- name: Dump runner context
  run: echo '${{ toJSON(runner) }}'
```

### Conditional Debug Steps

```yaml
- name: Debug info
  if: runner.debug == '1'
  run: |
    echo "Debug mode is enabled"
    kubectl get pods --all-namespaces
    docker images
    df -h
```

## Analyzing Failures

### Read Error Messages Carefully

**Pattern: Look for the actual error, not just "Exit code 1"**

```yaml
# BAD: Generic error
- run: make test
# Output: "Error: Process completed with exit code 1"

# GOOD: Capture detailed output
- name: Run tests
  run: |
    set -e
    make test 2>&1 | tee test.log
  continue-on-error: true

- name: Upload logs on failure
  if: failure()
  uses: actions/upload-artifact@v4
  with:
    name: test-logs
    path: test.log
```

### Check Previous Steps

```yaml
- name: Build
  id: build
  run: make build

- name: Test (depends on build)
  if: steps.build.outcome == 'success'
  run: make test

- name: Debug build failure
  if: steps.build.outcome == 'failure'
  run: |
    echo "Build failed!"
    ls -la dist/
    cat build.log || true
```

### Validate Step Outputs

```yaml
- name: Get version
  id: version
  run: echo "version=1.2.3" >> $GITHUB_OUTPUT

- name: Debug version output
  run: |
    echo "Version from output: ${{ steps.version.outputs.version }}"
    if [ -z "${{ steps.version.outputs.version }}" ]; then
      echo "::error::Version is empty!"
      exit 1
    fi
```

## Common Issues

### Permission Denied Errors

**Issue: Docker socket permission denied**

```yaml
# Problem: Can't access Docker socket
- run: docker ps
# Error: permission denied while trying to connect to the Docker daemon socket

# Solution: User is already in docker group on GitHub runners
# If running locally with act:
- run: sudo chmod 666 /var/run/docker.sock
```

**Issue: Can't write to directory**

```yaml
# Problem: Permission denied when writing files
- run: echo "test" > /usr/local/bin/myfile
# Error: Permission denied

# Solution: Use sudo or writable directory
- run: |
    sudo bash -c 'echo "test" > /usr/local/bin/myfile'
    # Or use user-writable location
    echo "test" > $HOME/.local/bin/myfile
```

### Authentication Failures

**Issue: Can't push Docker image**

```yaml
# Problem: Missing login
- uses: docker/build-push-action@v6
  with:
    push: true
    tags: ghcr.io/org/repo:latest
# Error: unauthorized: authentication required

# Solution: Login first
- uses: docker/login-action@v3
  with:
    registry: ghcr.io
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}

# Also ensure permissions are set
permissions:
  packages: write
```

**Issue: kubectl authentication failed**

```yaml
# Problem: kubeconfig not set
- run: kubectl get nodes
# Error: The connection to the server localhost:8080 was refused

# Solution: Configure kubectl access
- uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: ${{ secrets.AWS_ROLE }}
    aws-region: us-east-1

- run: aws eks update-kubeconfig --name my-cluster --region us-east-1

- run: kubectl get nodes
```

### Cache Issues

**Issue: Cache not restoring**

```yaml
# Problem: Cache key doesn't match
- uses: actions/cache@v4
  with:
    path: ~/.cache/go-build
    key: ${{ runner.os }}-go-${{ hashFiles('go.sum') }}
# Cache never hits because go.sum is in subdirectory

# Solution: Use correct path pattern
- uses: actions/cache@v4
  with:
    path: ~/.cache/go-build
    key: ${{ runner.os }}-go-${{ hashFiles('**/go.sum') }}
```

**Issue: Cache corrupted**

```yaml
# Solution: Change cache key to invalidate
- uses: actions/cache@v4
  with:
    path: ~/.cache/go-build
    key: v2-${{ runner.os }}-go-${{ hashFiles('**/go.sum') }}
    #    ^^ version prefix to force new cache
```

### Resource Not Found

**Issue: File not found**

```yaml
# Problem: Working directory confusion
- run: cat config.yaml
# Error: No such file or directory

# Debug: Check where you are
- run: |
    pwd
    ls -la
    find . -name config.yaml

# Solution: Use correct path or working-directory
- run: cat config.yaml
  working-directory: ./subproject
```

**Issue: Action not found**

```yaml
# Problem: Typo in action name
- uses: actions/checkout@4
# Error: Unable to resolve action `actions/checkout@4`

# Solution: Include 'v' prefix
- uses: actions/checkout@v4
```

### Timeout Issues

**Issue: Job timeout**

```yaml
# Problem: Default 6 hour timeout
jobs:
  build:
    runs-on: ubuntu-latest
    # Times out after 6 hours

# Solution: Set explicit timeout
jobs:
  build:
    runs-on: ubuntu-latest
    timeout-minutes: 30  # Fail fast
```

**Issue: Step hanging**

```yaml
# Problem: Command hangs waiting for input
- run: apt-get install package
# Hangs waiting for confirmation

# Solution: Use non-interactive flags
- run: |
    export DEBIAN_FRONTEND=noninteractive
    apt-get install -y package
```

### Syntax Errors

**Issue: YAML syntax error**

```yaml
# Problem: Invalid YAML
steps:
  - name: Test
  run: echo "test"  # Wrong indentation
# Error: mapping values are not allowed in this context

# Solution: Proper indentation
steps:
  - name: Test
    run: echo "test"
```

**Issue: Expression syntax error**

```yaml
# Problem: Incorrect expression syntax
if: ${{ github.ref = 'refs/heads/main' }}
# Error: Unexpected symbol: '='

# Solution: Use correct operator
if: github.ref == 'refs/heads/main'
# Note: ${{ }} is optional in if conditions
```

## Debugging Techniques

### Add Debug Steps

```yaml
- name: Debug step
  if: always()
  run: |
    echo "=== Environment ==="
    env | sort

    echo "=== Working Directory ==="
    pwd
    ls -la

    echo "=== Git Status ==="
    git status

    echo "=== Disk Space ==="
    df -h

    echo "=== Docker ==="
    docker ps -a
    docker images
```

### Use tmate for SSH Access

```yaml
- name: Setup tmate session
  if: failure()
  uses: mxschmitt/action-tmate@v3
  timeout-minutes: 30
  with:
    limit-access-to-actor: true
```

### Step-by-Step Debugging

```yaml
- name: Build (step 1)
  run: |
    echo "Starting build..."
    set -x  # Enable command tracing
    go build -v ./...

- name: Test (step 2)
  run: |
    set -x
    go test -v ./...

- name: Package (step 3)
  run: |
    set -x
    tar -czf app.tar.gz app
```

### Validate Inputs

```yaml
- name: Validate inputs
  run: |
    echo "::group::Input Validation"

    if [ -z "${{ inputs.component_path }}" ]; then
      echo "::error::component_path is required"
      exit 1
    fi

    if [ ! -d "${{ inputs.component_path }}" ]; then
      echo "::error::component_path directory does not exist: ${{ inputs.component_path }}"
      exit 1
    fi

    echo "All inputs valid"
    echo "::endgroup::"
```

### Test Conditionals

```yaml
- name: Test conditional logic
  run: |
    echo "Event: ${{ github.event_name }}"
    echo "Ref: ${{ github.ref }}"
    echo "Should deploy: ${{ github.event_name == 'push' && github.ref == 'refs/heads/main' }}"
```

### Capture Failure Context

```yaml
- name: Run tests
  id: test
  run: make test
  continue-on-error: true

- name: Capture failure context
  if: steps.test.outcome == 'failure'
  run: |
    echo "::group::Test Logs"
    cat test.log || true
    echo "::endgroup::"

    echo "::group::System Info"
    uname -a
    free -h
    df -h
    echo "::endgroup::"

    echo "::group::Process List"
    ps aux
    echo "::endgroup::"

- name: Fail if tests failed
  if: steps.test.outcome == 'failure'
  run: exit 1
```

### Use Artifacts for Debugging

```yaml
- name: Build
  run: make build
  continue-on-error: true

- name: Capture build artifacts
  if: always()
  uses: actions/upload-artifact@v4
  with:
    name: build-debug
    path: |
      build.log
      dist/
      *.deb
      *.rpm
```

## Local Testing

### Test with act

**Install act:**
```bash
# macOS
brew install act

# Linux
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
```

**Run workflow locally:**
```bash
# List workflows
act -l

# Run default event (push)
act

# Run specific event
act pull_request

# Run specific job
act -j test

# Use specific runner image
act -P ubuntu-latest=catthehacker/ubuntu:full-latest

# With secrets
act -s GITHUB_TOKEN=ghp_xxx

# Dry run (just show what would run)
act -n
```

**Debug with act:**
```bash
# Verbose output
act -v

# Very verbose
act -v -v

# Interactive debugging
act --bind

# Use host's Docker socket
act --use-gitea-instance
```

### Test Locally Without act

**Simulate workflow steps:**
```bash
# Set environment variables
export GITHUB_WORKSPACE=$(pwd)
export GITHUB_SHA=$(git rev-parse HEAD)
export GITHUB_REF=$(git symbolic-ref HEAD)
export GITHUB_REPOSITORY="owner/repo"

# Run commands from workflow
echo "Running tests..."
go test ./...

echo "Building..."
go build -o app ./cmd/app
```

### Validate Workflow Syntax

```bash
# Install actionlint
brew install actionlint  # macOS
# or: go install github.com/rhysd/actionlint/cmd/actionlint@latest

# Validate workflows
actionlint

# Validate specific file
actionlint .github/workflows/ci.yaml

# With detailed output
actionlint -verbose
```

## Performance Issues

### Slow Checkout

**Issue: Checking out large repo is slow**

```yaml
# Problem: Fetches all history
- uses: actions/checkout@v4
# Takes 5+ minutes for large repos

# Solution: Shallow clone
- uses: actions/checkout@v4
  with:
    fetch-depth: 1  # Only fetch latest commit

# Or if you need specific depth
- uses: actions/checkout@v4
  with:
    fetch-depth: 50  # Last 50 commits
```

### Slow Dependency Installation

**Issue: Installing dependencies every time**

```yaml
# Problem: No caching
- run: npm install  # Slow every time

# Solution: Use cache
- uses: actions/cache@v4
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}

- run: npm ci  # Faster than install
```

### Slow Docker Builds

**Issue: Rebuilding everything**

```yaml
# Problem: No cache
- uses: docker/build-push-action@v6
  with:
    context: .
# Rebuilds all layers every time

# Solution: Use BuildKit cache
- uses: docker/setup-buildx-action@v3

- uses: docker/build-push-action@v6
  with:
    context: .
    cache-from: type=gha,scope=myapp
    cache-to: type=gha,mode=max,scope=myapp
```

### Slow Tests

**Issue: Running all tests always**

```yaml
# Problem: All tests run even for docs changes
on:
  push:
    paths:
      - '**'  # Runs for any change

# Solution: Path filtering
on:
  push:
    paths:
      - 'src/**'
      - 'tests/**'
      - 'go.mod'
      - 'go.sum'
    paths-ignore:
      - 'docs/**'
      - '**.md'
```

### Parallel Execution

**Issue: Sequential job execution**

```yaml
# Problem: Jobs run one after another
jobs:
  test-unit:
    runs-on: ubuntu-latest
    # ...
  test-integration:
    needs: test-unit  # Waits for unit tests
    # ...

# Solution: Remove unnecessary dependencies
jobs:
  test-unit:
    runs-on: ubuntu-latest
    # ...
  test-integration:
    runs-on: ubuntu-latest  # Runs in parallel
    # ...
```

### Matrix Builds

**Issue: Testing one version at a time**

```yaml
# Problem: Sequential version testing
jobs:
  test-go-1-21:
    # ...
  test-go-1-22:
    # ...

# Solution: Use matrix
jobs:
  test:
    strategy:
      matrix:
        go-version: [ '1.21', '1.22', '1.23' ]
    steps:
      - uses: actions/setup-go@v5
        with:
          go-version: ${{ matrix.go-version }}
```

## Best Practices

### Debugging Workflow Design
- Add debug output at key steps
- Use meaningful step names
- Include context in error messages
- Upload artifacts for inspection
- Use continue-on-error strategically

### Error Handling
- Validate inputs early
- Provide clear error messages
- Include debug info on failures
- Always cleanup resources
- Use proper exit codes

### Performance
- Cache aggressively
- Use path filtering
- Parallelize where possible
- Use shallow clones
- Profile slow steps

### Maintenance
- Pin action versions
- Document complex logic
- Test locally with act
- Validate syntax with actionlint
- Review workflow logs regularly

### Security
- Don't log secrets
- Use OIDC over credentials
- Minimal permissions
- Review third-party actions
- Rotate secrets regularly
