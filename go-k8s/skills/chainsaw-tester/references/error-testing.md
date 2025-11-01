# Error Testing and Negative Testing with Chainsaw

Comprehensive guide to testing expected errors, validation failures, and negative test cases in Chainsaw E2E tests.

## Table of Contents
1. [Built-in Error Bindings](#built-in-error-bindings)
2. [Testing Expected Errors](#testing-expected-errors)
3. [Error Message Validation](#error-message-validation)
4. [Webhook Validation Testing](#webhook-validation-testing)
5. [Script and Command Errors](#script-and-command-errors)
6. [Resource-Specific Error Testing](#resource-specific-error-testing)
7. [Common Patterns](#common-patterns)

## Built-in Error Bindings

Chainsaw provides the following bindings in check blocks for error testing:

| Binding | Type | Description | Available In |
|---------|------|-------------|--------------|
| `$error` | string | Error message if operation failed | All operations |
| `$stdout` | string | Standard output content | Script/command only |
| `$stderr` | string | Standard error output | Script/command only |
| `@` | any | Final resource state | All operations |

**Critical**: `$error` is a **string**, not an object. Access it directly as `$error`, not `$error.message`.

## Testing Expected Errors

### Basic Error Check

Test that an operation fails (negative testing):

```yaml
- apply:
    file: invalid-resource.yaml
    expect:
    - check:
        ($error != null): true
```

**Behavior**:
- ✅ Test **succeeds** if the operation **fails**
- ❌ Test **fails** if the operation **succeeds**

This is the foundation of negative testing - validating that invalid inputs are properly rejected.

### Testing Successful Operations

For operations that should succeed, **do not use `expect`**:

```yaml
# GOOD: Valid resource - no expect block
- apply:
    file: valid-agent.yaml

# Then assert the resource exists
- assert:
    resource:
      apiVersion: example.com/v1alpha1
      kind: Agent
      metadata:
        name: valid-agent
```

### Error vs Success Pattern

```yaml
# Test suite for webhook validation
steps:
- name: valid-resource-accepted
  description: Valid resource should be accepted
  try:
  - apply:
      file: manifests/valid-agent.yaml
  - assert:
      resource:
        apiVersion: ark.example.com/v1alpha1
        kind: Agent
        metadata:
          name: valid-agent

- name: invalid-resource-rejected
  description: Invalid resource should be rejected
  try:
  - apply:
      file: manifests/invalid-agent.yaml
      expect:
      - check:
          ($error != null): true
```

## Error Message Validation

### Using contains() Function

Validate specific error message content using the `contains()` JP function:

```yaml
- apply:
    file: invalid-agent.yaml
    expect:
    - check:
        ($error != null): true
        (contains($error, 'invalid template syntax')): true
        (contains($error, 'environment')): true
```

**Syntax**: `contains($error, 'substring')` returns `true` if the error message contains the substring.

### Multiple Error Conditions

Check for multiple substrings to validate comprehensive error messages:

```yaml
- apply:
    file: manifests/invalid-agent.yaml
    expect:
    - check:
        ($error != null): true
        (contains($error, 'template variable')): true
        (contains($error, 'undefinedParam')): true
        (contains($error, 'no corresponding parameter')): true
```

**All conditions must be true** for the test to pass.

### Error Substring Selection Best Practices

Choose error substrings that are:

1. **Specific**: Uniquely identify the error type
2. **Stable**: Won't change with minor code updates
3. **Meaningful**: Include key terms (variable names, error categories)
4. **Multiple**: Check 2-4 substrings for comprehensive validation

```yaml
# GOOD: Specific, stable substrings
expect:
- check:
    ($error != null): true
    (contains($error, 'template variable')): true      # Error category
    (contains($error, 'environment')): true             # Variable name
    (contains($error, 'no corresponding parameter')): true  # Root cause

# BAD: Exact error message (fragile)
expect:
- check:
    ($error == 'admission webhook "vagent-v1.ark.mckinsey.com" denied the request: template variable {{.environment}} in prompt has no corresponding parameter definition'): true

# BAD: Too generic
expect:
- check:
    ($error != null): true
    (contains($error, 'error')): true  # Too vague
```

## Webhook Validation Testing

### Admission Webhook Error Testing

Test that admission webhooks properly reject invalid resources:

```yaml
- name: test-undefined-template-variable
  description: Reject Agent with template variable lacking parameter definition
  try:
  - apply:
      file: manifests/invalid-agent.yaml
      expect:
      - check:
          ($error != null): true
          (contains($error, 'template variable')): true
          (contains($error, 'environment')): true
          (contains($error, 'no corresponding parameter')): true
```

**Expected webhook error message**:
```
admission webhook "vagent-v1.ark.mckinsey.com" denied the request:
template variable '{{.environment}}' in prompt has no corresponding parameter definition
```

**Test validates**:
- ✅ Operation failed (`$error != null`)
- ✅ Error mentions "template variable"
- ✅ Error mentions the specific variable "environment"
- ✅ Error mentions "no corresponding parameter"

### Multiple Webhook Validations

Test multiple validation rules in sequence:

```yaml
steps:
- name: test-missing-required-field
  description: Webhook should reject resource with missing required field
  try:
  - apply:
      file: manifests/missing-field.yaml
      expect:
      - check:
          ($error != null): true
          (contains($error, 'required field')): true
          (contains($error, 'model')): true

- name: test-invalid-field-format
  description: Webhook should reject resource with invalid field format
  try:
  - apply:
      file: manifests/invalid-format.yaml
      expect:
      - check:
          ($error != null): true
          (contains($error, 'invalid format')): true
          (contains($error, 'temperature')): true

- name: test-conflicting-fields
  description: Webhook should reject resource with conflicting fields
  try:
  - apply:
      file: manifests/conflicting-fields.yaml
      expect:
      - check:
          ($error != null): true
          (contains($error, 'conflict')): true
          (contains($error, 'cannot specify both')): true
```

### Webhook Timeout vs Validation Error

See [debugging.md#webhook-timeout-race-conditions](debugging.md#webhook-timeout-race-conditions) for distinguishing webhook timeouts from validation errors.

## Script and Command Errors

### Testing Script Failures

For scripts and commands, check both `$error` and `$stderr`:

```yaml
- script:
    content: kubectl foo
    check:
      ($error != null): true
      (contains($stderr, 'unknown command')): true
```

### Command Exit Codes

Validate command failure with specific exit codes:

```yaml
- script:
    content: |
      # This should fail with exit code 1
      kubectl get nonexistentresource
    check:
      ($error != null): true
      (contains($stderr, 'the server doesn\'t have a resource type')): true
```

### Expected vs Unexpected Failures

```yaml
# GOOD: Expected failure - test that invalid command fails
- name: test-invalid-command-fails
  try:
  - script:
      content: kubectl get invalidtype
      check:
        ($error != null): true
        (contains($stderr, 'resource type')): true

# GOOD: Valid command should succeed
- name: test-valid-command-succeeds
  try:
  - script:
      content: kubectl get pods -n default
  # No check block - script should succeed
```

## Resource-Specific Error Testing

### Testing Specific Resources in Multi-Resource Files

When a file contains multiple resources, use `match` to target specific ones:

```yaml
- apply:
    file: resources.yaml  # Contains multiple resources
    expect:
    - match:
        apiVersion: v1
        kind: ConfigMap
        metadata:
          name: should-fail
      check:
        ($error != null): true
        (contains($error, 'validation failed')): true
```

### CRD Schema Validation Errors

Test that CRD schema validation rejects invalid field types:

```yaml
- name: test-invalid-field-type
  description: CRD schema should reject wrong field type
  try:
  - apply:
      resource:
        apiVersion: example.com/v1
        kind: CustomResource
        metadata:
          name: invalid-type
        spec:
          replicas: "three"  # Should be integer, not string
      expect:
      - check:
          ($error != null): true
          (contains($error, 'invalid type')): true
          (contains($error, 'replicas')): true

- name: test-invalid-enum-value
  description: CRD schema should reject invalid enum value
  try:
  - apply:
      resource:
        apiVersion: example.com/v1
        kind: CustomResource
        metadata:
          name: invalid-enum
        spec:
          phase: InvalidPhase  # Not in allowed enum values
      expect:
      - check:
          ($error != null): true
          (contains($error, 'not one of')): true
          (contains($error, 'phase')): true
```

## Common Patterns

### Pattern: Comprehensive Validation Test Suite

```yaml
apiVersion: chainsaw.kyverno.io/v1alpha1
kind: Test
metadata:
  name: agent-validation-test
spec:
  description: Test admission webhook validation for Agent resources
  steps:
  # Test 1: Valid resource succeeds
  - name: valid-agent-accepted
    description: Valid Agent should be created successfully
    try:
    - apply:
        file: manifests/valid-agent.yaml
    - assert:
        resource:
          apiVersion: ark.example.com/v1alpha1
          kind: Agent
          metadata:
            name: valid-agent

  # Test 2: Missing required field fails
  - name: missing-required-field-rejected
    description: Agent missing required field should be rejected
    try:
    - apply:
        file: manifests/missing-model.yaml
        expect:
        - check:
            ($error != null): true
            (contains($error, 'required')): true
            (contains($error, 'model')): true

  # Test 3: Invalid template variable fails
  - name: undefined-template-variable-rejected
    description: Agent with undefined template variable should be rejected
    try:
    - apply:
        file: manifests/undefined-var-agent.yaml
        expect:
        - check:
            ($error != null): true
            (contains($error, 'template variable')): true
            (contains($error, 'no corresponding parameter')): true

  # Test 4: Invalid value format fails
  - name: invalid-value-format-rejected
    description: Agent with invalid value format should be rejected
    try:
    - apply:
        file: manifests/invalid-temperature.yaml
        expect:
        - check:
            ($error != null): true
            (contains($error, 'temperature')): true
            (contains($error, 'range')): true
```

### Pattern: Error Recovery Testing

Test that after an error, valid resources can still be created:

```yaml
steps:
# Step 1: Invalid resource is rejected
- name: create-invalid-resource
  try:
  - apply:
      file: manifests/invalid.yaml
      expect:
      - check:
          ($error != null): true

# Step 2: Valid resource succeeds after error
- name: create-valid-resource-after-error
  try:
  - apply:
      file: manifests/valid.yaml
  - assert:
      resource:
        kind: CustomResource
        metadata:
          name: valid-resource
```

### Pattern: Boundary Testing

Test edge cases and boundary conditions:

```yaml
steps:
- name: test-zero-value
  description: Test zero as edge case
  try:
  - apply:
      resource:
        apiVersion: example.com/v1
        kind: CustomResource
        spec:
          replicas: 0  # Edge case: zero replicas
      expect:
      - check:
          ($error != null): true
          (contains($error, 'must be positive')): true

- name: test-negative-value
  description: Test negative value rejection
  try:
  - apply:
      resource:
        apiVersion: example.com/v1
        kind: CustomResource
        spec:
          replicas: -1  # Invalid: negative
      expect:
      - check:
          ($error != null): true
          (contains($error, 'must be non-negative')): true

- name: test-maximum-value
  description: Test value exceeds maximum
  try:
  - apply:
      resource:
        apiVersion: example.com/v1
        kind: CustomResource
        spec:
          replicas: 1000000  # Edge case: very large
      expect:
      - check:
          ($error != null): true
          (contains($error, 'exceeds maximum')): true
```

## Best Practices

### Do's ✅

1. **Test both positive and negative cases**: Valid resources should succeed, invalid resources should fail
2. **Use specific error substrings**: Check for 2-4 key terms that uniquely identify the error
3. **Avoid fragile exact matches**: Don't check entire error messages that might change
4. **Test error recovery**: Ensure system works after errors occur
5. **Document expected behavior**: Use `description` field to explain what should happen
6. **Test boundary conditions**: Zero values, negative values, maximum values
7. **Validate error completeness**: Check error mentions field names, constraints, and reasons

### Don'ts ❌

1. **Don't use exact error message matching**: Error wording may change between versions
2. **Don't check only for `$error != null`**: Validate the error is the expected error
3. **Don't ignore `$stderr` in scripts**: Script errors often have useful details in stderr
4. **Don't test only happy paths**: Negative testing is critical for validation
5. **Don't use generic error substrings**: `'error'` or `'failed'` are too vague
6. **Don't mix positive/negative in same operation**: Keep error expectations separate

## Real-World Examples

### Example 1: Template Validation

```yaml
- name: test-undefined-template-variable
  description: Reject Agent with template variable lacking parameter definition
  try:
  - apply:
      file: manifests/a04-undefined-var-agent.yaml
      expect:
      - check:
          ($error != null): true
          (contains($error, 'template variable')): true
          (contains($error, 'environment')): true
          (contains($error, 'no corresponding parameter')): true
```

**Expected webhook error**:
```
admission webhook "vagent-v1.ark.example.com" denied the request:
template variable '{{.environment}}' in prompt has no corresponding parameter definition
```

### Example 2: Field Validation

```yaml
- name: test-invalid-model-value
  description: Reject Agent with invalid model value
  try:
  - apply:
      resource:
        apiVersion: ark.example.com/v1alpha1
        kind: Agent
        metadata:
          name: invalid-model
        spec:
          model: "unsupported-model"
      expect:
      - check:
          ($error != null): true
          (contains($error, 'invalid model')): true
          (contains($error, 'unsupported-model')): true
          (contains($error, 'supported models')): true
```

### Example 3: Cross-Field Validation

```yaml
- name: test-conflicting-configuration
  description: Reject resource with mutually exclusive fields both set
  try:
  - apply:
      resource:
        apiVersion: example.com/v1
        kind: CustomResource
        metadata:
          name: conflicting-config
        spec:
          useDefault: true
          customConfig: "value"  # Conflict: can't use both
      expect:
      - check:
          ($error != null): true
          (contains($error, 'conflict')): true
          (contains($error, 'useDefault')): true
          (contains($error, 'customConfig')): true
          (contains($error, 'cannot specify both')): true
```

## Troubleshooting Error Tests

### Test Passes When It Should Fail

If your error test succeeds but you expected it to catch an error:

1. **Check if the operation actually failed**:
   ```yaml
   # Add verbose error logging
   - check:
       ($error != null): true
       # Add this to see the error
       ($error): "$error"  # Will show in test output
   ```

2. **Verify webhook is running**: Webhook might not be deployed or might be failing silently

3. **Check error substring spelling**: Case-sensitive matching

### Test Fails When Error Should Occur

If your test expects an error but the operation succeeds:

1. **Verify the resource is actually invalid**: Resource might be valid despite expectations

2. **Check CRD schema**: Schema might allow the value you thought was invalid

3. **Webhook not triggered**: Webhook might not be configured for this resource type

### Error Message Changed

If tests start failing because error messages changed:

1. **Use multiple substrings**: More resilient than exact matches

2. **Focus on stable terms**: Field names, error types, not full sentences

3. **Update test expectations**: Adjust substrings if error format improved

## References

- [Chainsaw Negative Testing](https://kyverno.github.io/chainsaw/latest/examples/negative-testing/)
- [Chainsaw Built-in Bindings](https://kyverno.github.io/chainsaw/latest/reference/builtins/)
- [Chainsaw Operation Checks](https://kyverno.github.io/chainsaw/latest/general/checks/)
- [operator-testing.md](operator-testing.md) - Webhook validation patterns
- [debugging.md](debugging.md) - Debugging webhook timeouts
