# Chainsaw Testing Basics

Fundamentals of writing Chainsaw tests for Kubernetes operators.

## Table of Contents
1. [What is Chainsaw](#what-is-chainsaw)
2. [Test Structure](#test-structure)
3. [File Organization](#file-organization)
4. [Resource Application](#resource-application)
5. [Timeouts and Error Handling](#timeouts-and-error-handling)

## What is Chainsaw

Chainsaw is a declarative Kubernetes end-to-end testing tool from the Kyverno project. Key features:

- **Declarative**: Tests defined entirely in YAML
- **Kubernetes-native**: Built for testing operators and controllers
- **JMESPath powered**: Uses JP (JMESPath) for assertions
- **Comprehensive**: Supports create, update, delete, assert operations

### Core Concepts

- **Tests**: Top-level Test resources defining test scenarios
- **Steps**: Ordered sequences of operations within a test
- **Operations**: Individual actions (apply, assert, script, delete, etc.)
- **Assertions**: Validation of expected resource states using JP expressions

## Test Structure

### Basic Test Format

```yaml
apiVersion: chainsaw.kyverno.io/v1alpha1
kind: Test
metadata:
  name: test-name
spec:
  description: Brief description of what this test validates
  steps:
  - name: step-1
    try:
    # Operations to execute
    catch:
    # Operations to run on failure (optional)
    finally:
    # Operations to always run (optional)
```

### Test Lifecycle

1. **Setup**: Apply resources, run scripts
2. **Execution**: Perform operations
3. **Validation**: Assert expected states
4. **Cleanup**: Delete resources (automatic unless `--skip-delete`)

### Step Structure

```yaml
steps:
  - name: descriptive-step-name
    try:
      - apply:
          file: manifests/*.yaml
      - assert:
          resource:
            apiVersion: v1
            kind: Pod
            metadata:
              name: test-pod
            status:
              phase: Running
    catch:
      - events: {}
      - describe:
          apiVersion: v1
          kind: Pod
          name: test-pod
    finally:
      - script:
          content: echo "Step completed"
```

## File Organization

### Recommended Directory Structure

```
tests/
├── test-name/
│   ├── chainsaw-test.yaml
│   ├── README.md
│   └── manifests/
│       ├── a00-namespace.yaml
│       ├── a01-rbac.yaml
│       ├── a02-secrets.yaml
│       ├── a03-dependencies.yaml
│       ├── a04-custom-resource.yaml
│       └── a05-validation.yaml
```

### File Naming Conventions

Use 'a' prefix with numeric suffixes to control application order:
- `a00-` - Namespaces
- `a01-` - RBAC (Roles, RoleBindings, ServiceAccounts)
- `a02-` - ConfigMaps and Secrets
- `a03-` - Dependencies (CRDs, other required resources)
- `a04+` - Main resources under test

### README Documentation

Each test directory should include a README.md:

```markdown
# Test Name

Brief description of what the test validates.

## What it tests
- Specific functionality being tested
- Key components or integrations
- Expected behaviors or outcomes

## Running
\```bash
chainsaw test tests/test-name/
\```

## Expected Outcome
One sentence explaining what successful test completion validates.
```

## Resource Application

### Apply Operations

#### File-based Application

```yaml
# Apply single file
- apply:
    file: manifests/resource.yaml

# Apply all files matching glob
- apply:
    file: manifests/*.yaml

# Apply specific files
- apply:
    file: manifests/a01-rbac.yaml
- apply:
    file: manifests/a02-config.yaml
```

#### Inline Resources

```yaml
# Apply resource defined inline
- apply:
    resource:
      apiVersion: v1
      kind: ConfigMap
      metadata:
        name: test-config
      data:
        key: value
```

### Create vs Apply

```yaml
# Create - fails if resource exists
- create:
    resource:
      apiVersion: v1
      kind: Pod
      metadata:
        name: test-pod

# Apply - creates or updates
- apply:
    resource:
      apiVersion: v1
      kind: Pod
      metadata:
        name: test-pod
```

### Update and Patch

```yaml
# Update existing resource
- update:
    resource:
      apiVersion: v1
      kind: ConfigMap
      metadata:
        name: existing-config
      data:
        new-key: new-value

# Patch resource
- patch:
    resource:
      apiVersion: v1
      kind: Pod
      metadata:
        name: test-pod
      spec:
        containers:
        - name: main
          image: new-image:tag
```

### Delete Operations

```yaml
# Delete specific resource
- delete:
    ref:
      apiVersion: v1
      kind: Pod
      name: test-pod

# Delete using resource definition
- delete:
    resource:
      apiVersion: v1
      kind: ConfigMap
      metadata:
        name: test-config
```

## Timeouts and Error Handling

### Operation Timeouts

All timeout configurations should be set in `.chainsaw.yaml` configuration file rather than in individual test operations. This ensures consistent timeout behavior across all tests.

### Error Handling: catch Blocks

Catch blocks execute only when the try block fails:

```yaml
- name: test-resource
  try:
  - assert:
      resource:
        apiVersion: v1
        kind: Pod
        metadata:
          name: test-pod
        status:
          phase: Running
  catch:
  # Log events for debugging
  - events: {}

  # Describe failed resource
  - describe:
      apiVersion: v1
      kind: Pod
      name: test-pod

  # Run debug script
  - script:
      content: |
        kubectl logs test-pod
        kubectl describe pod test-pod
```

### Finally Blocks

Finally blocks always execute, regardless of success or failure:

```yaml
- name: test-with-cleanup
  try:
  - apply:
      file: test-resources.yaml
  - assert:
      resource:
        status:
          ready: true
  finally:
  # Always clean up, even on failure
  - delete:
      ref:
        apiVersion: v1
        kind: ConfigMap
        name: test-data

  # Always log completion
  - script:
      content: echo "Test completed at $(date)"
```

### Error Operations

Test for expected errors:

```yaml
# Expect resource creation to fail
- error:
    file: invalid-resource.yaml

# Expect specific resource to be rejected
- error:
    resource:
      apiVersion: example.com/v1
      kind: CustomResource
      metadata:
        name: invalid
      spec:
        invalidField: value
```

## Scripts and Bindings

### Script Operations

```yaml
# Simple script
- script:
    content: echo "Running test"

# Script with environment variables
- script:
    content: |
      kubectl get pods -n $NAMESPACE
    env:
    - name: NAMESPACE
      value: default

# Skip log output for sensitive data
- script:
    skipLogOutput: true
    content: |
      echo "$SECRET_VALUE"
```

### Capturing Script Output

```yaml
# Capture stdout as binding
- script:
    content: |
      echo '{"key": "value"}'
    outputs:
    - name: json_output
      value: (json_parse($stdout))

# Use captured output in resources
- apply:
    resource:
      apiVersion: v1
      kind: Secret
      metadata:
        name: dynamic-secret
      data:
        token: (base64_encode($json_output.key))
```

### Environment Variable Bindings

```yaml
# Access environment variable
- script:
    content: |
      echo "$MY_VAR"
    env:
    - name: MY_VAR
      value: test-value

# Use namespace binding
- script:
    content: |
      kubectl get pods -n $NAMESPACE
    env:
    - name: NAMESPACE
      value: ($namespace)
```

## Assertions

### Resource Assertions

```yaml
# Assert resource exists
- assert:
    resource:
      apiVersion: v1
      kind: Pod
      metadata:
        name: test-pod

# Assert resource with status
- assert:
    resource:
      apiVersion: v1
      kind: Pod
      metadata:
        name: test-pod
      status:
        phase: Running

# Assert with JP expressions
- assert:
    resource:
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: test-deployment
      status:
        (readyReplicas == replicas): true
        (availableReplicas > `0`): true
```

### File-based Assertions

```yaml
# Assert against file
- assert:
    file: expected-state.yaml

# Assert against multiple files
- assert:
    file: assertions/*.yaml
```

## Test Execution

### Getting Help

```bash
# Get complete list of available flags and options
chainsaw test --help

# Get general chainsaw help
chainsaw --help
```

**Always check `chainsaw test --help` for the authoritative and up-to-date list of flags for your version.**

### Basic Execution

```bash
# Run all tests
chainsaw test tests/

# Run specific test
chainsaw test tests/test-name/

# Run multiple test directories
chainsaw test tests/integration/ tests/e2e/
```

### Common Patterns

#### Development and Debugging

```bash
# Debug: pause on failure and keep resources for inspection
chainsaw test tests/ --pause-on-failure --skip-delete

# Keep resources after test (skip cleanup)
chainsaw test tests/ --skip-delete
```

#### Parallel Execution

```bash
# Run tests in parallel (4 concurrent test files)
chainsaw test tests/ --parallel 4

# Run tests in parallel (8 concurrent test files)
chainsaw test tests/ --parallel 8
```

**Note:** `--parallel` controls the number of TEST FILES running concurrently, not steps within a single test.

#### CI/CD Integration

```bash
# CI/CD: parallel with JUnit reports
chainsaw test tests/ \
  --parallel 8 \
  --fail-fast \
  --report-format JUNIT-TEST \
  --report-path ./junit-results \
  --no-color

# Distributed testing across 3 CI runners
# Runner 1: chainsaw test tests/ --shard-count 3 --shard-index 0
# Runner 2: chainsaw test tests/ --shard-count 3 --shard-index 1
# Runner 3: chainsaw test tests/ --shard-count 3 --shard-index 2
```

#### Test Selection

```bash
# Run only tests matching pattern
chainsaw test tests/ --include-test-regex "integration.*"

# Exclude slow tests
chainsaw test tests/ --exclude-test-regex ".*slow"

# Filter by labels
chainsaw test tests/ --selector env=production
```

#### Reliability Testing

```bash
# Detect flaky tests: run multiple times
chainsaw test tests/flaky-test/ --repeat-count 10

# Fail fast on first failure
chainsaw test tests/ --fail-fast
```

### Key Flags Summary

Use `chainsaw test --help` for complete options. Most commonly used:

- `--parallel N` - Run N tests concurrently
- `--skip-delete` - Keep resources after test
- `--pause-on-failure` - Pause for manual inspection
- `--fail-fast` - Stop on first failure
- `--repeat-count N` - Run each test N times
- `--include-test-regex` - Filter tests to run
- `--exclude-test-regex` - Exclude tests
- `--report-format` - Generate test reports (JSON, XML, JUNIT-TEST, etc.)
- `--quiet` - Minimal output
- `--no-color` - Disable colored output (CI/CD)

### Test Configuration

Global configuration via `.chainsaw.yaml`:

```yaml
apiVersion: chainsaw.kyverno.io/v1alpha2
kind: Configuration
metadata:
  name: default
spec:
  # Global timeout for all operations - configure here instead of in individual tests
  timeout: 5m

  # Skip resource deletion
  skipDelete: false

  # Fail fast on first error
  failFast: false

  # Parallel test execution
  parallel: 1

  # Test directory
  testDirs:
  - tests/
```

**Note:** All timeout values should be configured in `.chainsaw.yaml` rather than in individual test operations to ensure consistency.

## Best Practices

### Test Organization
- One test per file
- Clear, descriptive test names
- Logical step names
- Document test purpose in README

### Resource Management
- Use numeric prefixes for ordering
- Apply dependencies before dependents
- Clean up resources in finally blocks
- Use namespaces for isolation

### Assertions
- Prefer JP assertions over shell scripts
- Validate both existence and state
- Use appropriate timeouts
- Add catch blocks for debugging

### Error Handling
- Include events and describe in catch blocks
- Use finally for guaranteed cleanup
- Test error cases with error operation
- Provide context in failure messages

### Performance
- Use parallel execution when possible
- Minimize script operations
- Reuse resources across steps
- Skip unnecessary assertions
