# Testing Strategies in CI/CD

Testing patterns for Go projects in GitHub Actions: unit tests, linting, E2E tests, and coverage reporting.

## Table of Contents
1. [Unit Testing](#unit-testing)
2. [Linting and Code Quality](#linting-and-code-quality)
3. [E2E Testing with Kind](#e2e-testing-with-kind)
4. [Coverage Reporting](#coverage-reporting)
5. [Test Optimization](#test-optimization)
6. [Test Artifacts](#test-artifacts)

## Unit Testing

### Basic Go Testing

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-go@v5
        with:
          go-version: '1.23'
          cache: true  # Auto-cache modules and build cache

      - name: Run tests
        run: go test -v ./...
```

### With Makefile

```yaml
- name: Run tests
  run: make test

- name: Run integration tests
  run: make test-integration
```

**Example Makefile:**
```makefile
.PHONY: test
test:
	go test -v -race -coverprofile=cover.out ./...

.PHONY: test-integration
test-integration:
	go test -v -tags=integration ./...
```

### Test with Multiple Go Versions

```yaml
strategy:
  matrix:
    go-version: [ '1.21', '1.22', '1.23' ]

steps:
  - uses: actions/setup-go@v5
    with:
      go-version: ${{ matrix.go-version }}

  - name: Run tests
    run: go test ./...
```

### Race Detection

```yaml
- name: Run tests with race detector
  run: go test -race ./...
```

### Build Verification

```yaml
- name: Verify builds
  run: |
    go build -v ./...
    go build -v ./cmd/...
```

## Linting and Code Quality

### golangci-lint

```yaml
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-go@v5
        with:
          go-version: '1.23'

      - name: Run golangci-lint
        uses: golangci/golangci-lint-action@v6
        with:
          version: latest
          args: --timeout=5m
```

### With Custom Configuration

```yaml
- name: Run linter
  uses: golangci/golangci-lint-action@v6
  with:
    version: v1.62
    args: --config=.golangci.yml --timeout=10m
```

**Example `.golangci.yml`:**
```yaml
run:
  timeout: 5m
  go: '1.23'

linters:
  enable:
    - gofmt
    - govet
    - staticcheck
    - gosec
    - errcheck
    - ineffassign
    - unused

linters-settings:
  govet:
    enable-all: true
  staticcheck:
    checks: ["all"]
```

### Go Formatting Check

```yaml
- name: Check formatting
  run: |
    if [ "$(gofmt -s -l . | wc -l)" -gt 0 ]; then
      echo "Go code is not formatted:"
      gofmt -s -d .
      exit 1
    fi
```

### Go Vet

```yaml
- name: Run go vet
  run: go vet ./...
```

### Staticcheck

```yaml
- uses: dominikh/staticcheck-action@v1
  with:
    version: "latest"
    install-go: false
```

### Dependency Updates Check

```yaml
- name: Check go.mod is tidy
  run: |
    go mod tidy
    git diff --exit-code go.mod go.sum || \
      (echo "go.mod or go.sum needs updating" && exit 1)
```

## E2E Testing with Kind

### Basic Kind Setup

```yaml
jobs:
  e2e:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-go@v5
        with:
          go-version: '1.23'

      - name: Create Kind cluster
        uses: helm/kind-action@v1
        with:
          cluster_name: test
          version: v0.24.0
          node_image: kindest/node:v1.31.0

      - name: Verify cluster
        run: |
          kubectl cluster-info
          kubectl get nodes
```

### Manual Kind Setup with Caching

```yaml
- name: Cache test dependencies
  uses: actions/cache@v4
  id: cache-tools
  with:
    path: |
      /tmp/kind
      /tmp/kubectl
      /tmp/chainsaw
    key: test-tools-${{ runner.os }}-kind-v0.24.0-chainsaw-v0.2.13

- name: Install test dependencies
  if: steps.cache-tools.outputs.cache-hit != 'true'
  run: |
    curl -sSLo /tmp/kind \
      https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-amd64 &

    curl -sSLO "https://dl.k8s.io/release/$(curl -sSL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
      mv kubectl /tmp/kubectl &

    curl -sSL https://github.com/kyverno/chainsaw/releases/download/v0.2.13/chainsaw_linux_amd64.tar.gz | \
      tar -xzC /tmp chainsaw &

    wait
    chmod +x /tmp/{kind,kubectl,chainsaw}

- name: Setup tools
  run: |
    sudo mv /tmp/{kind,kubectl,chainsaw} /usr/local/bin/
    kind version
    kubectl version --client
    chainsaw version

- name: Pull Kind node image
  run: docker pull kindest/node:v1.31.0

- name: Create Kind cluster
  run: |
    kind create cluster \
      --name test \
      --wait 3m \
      --image kindest/node:v1.31.0

    kubectl cluster-info
    kubectl wait --for=condition=Ready nodes --all --timeout=2m
```

### Custom Kind Configuration

```yaml
- name: Create Kind cluster with config
  run: |
    cat <<EOF | kind create cluster --name test --wait 3m --config -
    kind: Cluster
    apiVersion: kind.x-k8s.io/v1alpha4
    nodes:
    - role: control-plane
      kubeadmConfigPatches:
      - |
        kind: ClusterConfiguration
        apiServer:
          extraArgs:
            "v": "1"
        controllerManager:
          extraArgs:
            "v": "1"
    - role: worker
    - role: worker
    EOF
```

### Load Docker Image into Kind

```yaml
- name: Build Docker image
  run: docker build -t myapp:test .

- name: Load image into Kind
  run: kind load docker-image myapp:test --name test
```

**Or from artifact:**
```yaml
- uses: actions/download-artifact@v4
  with:
    name: docker-image
    path: /tmp

- name: Load image archive into Kind
  run: kind load image-archive /tmp/image.tar --name test
```

### Install Dependencies in Kind

```yaml
- name: Install cert-manager
  run: |
    kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.2/cert-manager.yaml
    kubectl wait --for=condition=available --timeout=300s \
      deployment/cert-manager -n cert-manager
    kubectl wait --for=condition=available --timeout=300s \
      deployment/cert-manager-webhook -n cert-manager

- name: Install CRDs
  run: |
    make manifests
    kubectl apply -k config/crd

- name: Install operator
  env:
    IMAGE_NAME: myapp:test
  run: |
    cd config/manager
    kustomize edit set image controller=$IMAGE_NAME
    cd ../..
    kubectl apply -k config/default
    kubectl wait --for=condition=available --timeout=300s \
      deployment/myapp-controller -n myapp-system
```

### Run E2E Tests

**With Chainsaw:**
```yaml
- name: Run Chainsaw tests
  env:
    TEST_API_KEY: ${{ secrets.TEST_API_KEY }}
  run: chainsaw test tests/
```

**With custom test script:**
```yaml
- name: Run E2E tests
  run: |
    make test-e2e
  env:
    KUBECONFIG: ${{ env.KUBECONFIG }}
    E2E_TIMEOUT: 10m
```

### Cleanup

```yaml
- name: Cleanup Kind cluster
  if: always()
  run: kind delete cluster --name test
```

### Full E2E Example

```yaml
jobs:
  e2e:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-go@v5
        with:
          go-version: '1.23'

      - name: Create Kind cluster
        run: |
          curl -sSLo /tmp/kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-amd64
          chmod +x /tmp/kind
          sudo mv /tmp/kind /usr/local/bin/
          kind create cluster --wait 3m

      - name: Build and load image
        run: |
          docker build -t myapp:test .
          kind load docker-image myapp:test

      - name: Install operator
        run: |
          kubectl apply -k config/default
          kubectl wait --for=condition=available --timeout=300s \
            deployment/myapp-controller -n myapp-system || {
              echo "Deployment failed. Debug info:"
              kubectl get pods -n myapp-system
              kubectl describe deployment myapp-controller -n myapp-system
              kubectl logs -n myapp-system -l app=myapp --tail=100 || true
              exit 1
            }

      - name: Run tests
        run: make test-e2e

      - name: Cleanup
        if: always()
        run: kind delete cluster
```

## Coverage Reporting

### Generate Coverage

```yaml
- name: Run tests with coverage
  run: go test -coverprofile=cover.out -covermode=atomic ./...

- name: Generate coverage report
  run: go tool cover -html=cover.out -o coverage.html
```

### Upload to Codecov

```yaml
- name: Run tests with coverage
  run: go test -coverprofile=cover.out ./...

- name: Upload coverage to Codecov
  uses: codecov/codecov-action@v4
  with:
    files: ./cover.out
    flags: unittests
    name: codecov-umbrella
    fail_ci_if_error: false
```

### Upload to Coveralls

```yaml
- uses: coverallsapp/github-action@v2
  with:
    github-token: ${{ secrets.GITHUB_TOKEN }}
    path-to-lcov: cover.out
```

### Multiple Coverage Reports

```yaml
- name: Run unit tests
  run: go test -coverprofile=unit-cover.out ./pkg/...

- name: Run integration tests
  run: go test -coverprofile=integration-cover.out -tags=integration ./...

- name: Upload unit test coverage
  uses: codecov/codecov-action@v4
  with:
    files: ./unit-cover.out
    flags: unit

- name: Upload integration test coverage
  uses: codecov/codecov-action@v4
  with:
    files: ./integration-cover.out
    flags: integration
```

### Coverage Threshold Check

```yaml
- name: Check coverage threshold
  run: |
    COVERAGE=$(go tool cover -func=cover.out | grep total | awk '{print $3}' | sed 's/%//')
    THRESHOLD=80

    echo "Coverage: $COVERAGE%"

    if (( $(echo "$COVERAGE < $THRESHOLD" | bc -l) )); then
      echo "Coverage $COVERAGE% is below threshold $THRESHOLD%"
      exit 1
    fi
```

## Test Optimization

### Parallel Testing

```yaml
- name: Run tests in parallel
  run: go test -parallel 4 ./...
```

### Short Mode for Fast Feedback

```yaml
- name: Quick test
  run: go test -short ./...

- name: Full test suite
  if: github.event_name == 'push'
  run: go test ./...
```

### Selective Testing

```yaml
- name: Detect changed packages
  id: changes
  run: |
    PACKAGES=$(git diff --name-only ${{ github.event.before }} ${{ github.sha }} | \
      grep '\.go$' | \
      xargs -I {} dirname {} | \
      sort -u | \
      sed 's|^|./|' | \
      tr '\n' ' ')
    echo "packages=$PACKAGES" >> $GITHUB_OUTPUT

- name: Test changed packages
  if: steps.changes.outputs.packages != ''
  run: go test ${{ steps.changes.outputs.packages }}
```

### Test Caching

```yaml
- uses: actions/setup-go@v5
  with:
    go-version: '1.23'
    cache: true  # Caches go modules and build cache

- uses: actions/cache@v4
  with:
    path: |
      ~/.cache/go-build
      ~/go/pkg/mod
    key: ${{ runner.os }}-go-test-${{ hashFiles('**/go.sum') }}
```

### Tool Caching

```yaml
- uses: actions/cache@v4
  with:
    path: |
      ~/go/bin
      ~/.local/bin
    key: ${{ runner.os }}-tools-${{ hashFiles('tools.go', 'Makefile') }}

- name: Install tools
  if: steps.cache.outputs.cache-hit != 'true'
  run: make install-tools
```

## Test Artifacts

### Upload Test Results

```yaml
- name: Run tests
  run: |
    go test -json ./... > test-results.json || true
    go test -v ./... > test-output.txt || true

- uses: actions/upload-artifact@v4
  if: always()
  with:
    name: test-results
    path: |
      test-results.json
      test-output.txt
```

### JUnit XML Reports

```yaml
- name: Install gotestsum
  run: go install gotest.tools/gotestsum@latest

- name: Run tests with JUnit output
  run: |
    gotestsum --junitfile junit-report.xml --format testname -- -coverprofile=cover.out ./...

- uses: actions/upload-artifact@v4
  if: always()
  with:
    name: junit-report
    path: junit-report.xml

- name: Publish test results
  uses: EnricoMi/publish-unit-test-result-action@v2
  if: always()
  with:
    files: junit-report.xml
```

### Upload Coverage Artifacts

```yaml
- name: Generate coverage
  run: |
    go test -coverprofile=cover.out ./...
    go tool cover -html=cover.out -o coverage.html

- uses: actions/upload-artifact@v4
  with:
    name: coverage-report
    path: coverage.html
```

### Failed Test Debug Artifacts

```yaml
- name: Run tests
  id: test
  run: go test -v ./... 2>&1 | tee test.log
  continue-on-error: true

- name: Upload test logs on failure
  if: steps.test.outcome == 'failure'
  uses: actions/upload-artifact@v4
  with:
    name: test-failure-logs
    path: test.log

- name: Fail if tests failed
  if: steps.test.outcome == 'failure'
  run: exit 1
```

## Best Practices

### Test Organization
- Separate unit tests, integration tests, and E2E tests
- Use build tags for integration tests (`//go:build integration`)
- Keep tests fast (<5 minutes for unit tests)
- Run E2E tests only on important branches

### Performance
- Cache Go modules and build cache
- Use parallel testing where possible
- Run short tests on PRs, full suite on main
- Cache test tools (kind, kubectl, etc.)

### Coverage
- Aim for >80% coverage on new code
- Track coverage trends over time
- Don't fail CI for coverage unless critical
- Focus on meaningful coverage, not just numbers

### E2E Testing
- Use ephemeral clusters (Kind, k3s)
- Clean up resources after tests
- Include detailed debug output on failures
- Cache cluster images and tools
- Use realistic test data

### Debugging
- Upload test artifacts on failures
- Include detailed logs in test output
- Use `continue-on-error` with manual failure handling
- Add debug output for flaky tests
- Keep test logs for inspection

### CI Efficiency
- Run linting before tests (fail fast)
- Use matrix builds for multi-version testing
- Cache aggressively but invalidate properly
- Run expensive tests only when needed
- Provide quick feedback on PRs
