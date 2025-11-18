# Assertion Patterns

Comprehensive guide to writing effective assertions in Chainsaw tests using JP (JMESPath) expressions.

## Table of Contents
1. [Assertion Basics](#assertion-basics)
2. [Resource State Assertions](#resource-state-assertions)
3. [Status Field Validation](#status-field-validation)
4. [Array and Collection Assertions](#array-and-collection-assertions)
5. [JSON Content Validation](#json-content-validation)
6. [Conditional Assertions](#conditional-assertions)
7. [Common Patterns](#common-patterns)

## Assertion Basics

### Syntax

Assertions validate resource state using JP (JMESPath) expressions wrapped in parentheses:

```yaml
- assert:
    resource:
      apiVersion: v1
      kind: Pod
      metadata:
        name: test-pod
      status:
        # Direct field match
        phase: Running

        # JP expression (parentheses)
        (length(conditions)): 3
        (containerStatuses[0].ready): true
```

### When to Use JP Expressions

Use JP expressions (parentheses) for:
- Comparisons: `>`, `<`, `>=`, `<=`, `==`, `!=`
- Functions: `length()`, `contains()`, `join()`, `type()`
- Complex validation: nested fields, array operations
- Computed values: `json_parse()`, arithmetic

Use direct field matching for:
- Simple equality: `phase: Running`
- Static values: `name: expected-name`

## Resource State Assertions

### Assert Resource Exists

```yaml
# GOOD: Minimal existence check
- assert:
    resource:
      apiVersion: v1
      kind: Pod
      metadata:
        name: test-pod

# GOOD: With namespace
- assert:
    resource:
      apiVersion: v1
      kind: Pod
      metadata:
        name: test-pod
        namespace: test-namespace
```

### Assert Resource Status

```yaml
# GOOD: Simple status field
- assert:
    resource:
      apiVersion: v1
      kind: Pod
      metadata:
        name: test-pod
      status:
        phase: Running

# GOOD: Multiple status fields
- assert:
    resource:
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: test-deployment
      status:
        availableReplicas: 3
        readyReplicas: 3
        updatedReplicas: 3
```

### Assert Spec Configuration

```yaml
# GOOD: Validate spec fields
- assert:
    resource:
      apiVersion: v1
      kind: Service
      metadata:
        name: test-service
      spec:
        type: ClusterIP
        ports:
        - port: 80
          targetPort: 8080
```

## Status Field Validation

### Phase and State

```yaml
# Pod phases
status:
  phase: Running  # or Pending, Succeeded, Failed, Unknown

# Job status
status:
  (conditions[?type=='Complete'].status | [0]): 'True'

# Custom Resource phases
status:
  phase: ready  # Custom phase names vary by CRD
```

### Conditions

```yaml
# GOOD: Check condition exists
- assert:
    resource:
      status:
        (length(conditions) > `0`): true

# GOOD: Validate specific condition
- assert:
    resource:
      status:
        (contains(conditions[*].type, 'Ready')): true
        (contains(conditions[*].status, 'True')): true

# GOOD: Condition with reason
- assert:
    resource:
      status:
        conditions:
        - type: Ready
          status: 'True'
          reason: SuccessfulReconcile
```

### Replica Counts

```yaml
# GOOD: Deployment replica validation
- assert:
    resource:
      apiVersion: apps/v1
      kind: Deployment
      status:
        (readyReplicas == replicas): true
        (availableReplicas == replicas): true
        (updatedReplicas == replicas): true

# GOOD: Minimum replicas
- assert:
    resource:
      status:
        (readyReplicas >= `1`): true

# GOOD: StatefulSet ready
- assert:
    resource:
      apiVersion: apps/v1
      kind: StatefulSet
      status:
        (readyReplicas == currentReplicas): true
```

## Array and Collection Assertions

### Array Length

```yaml
# GOOD: Exact length
(length(items)): 3

# GOOD: Minimum length
(length(items) > `0`): true
(length(items) >= `2`): true

# GOOD: Range validation
(length(items) >= `2` && length(items) <= `5`): true

# GOOD: Empty array
(length(items)): 0
```

### Array Contains

```yaml
# GOOD: Check value present
(contains(names, 'expected-name')): true

# GOOD: Check multiple values
(contains(tags, 'production')): true
(contains(tags, 'stable')): true

# GOOD: Check value absent
(contains(names, 'excluded-name')): false

# GOOD: Project and contains
(contains(items[*].name, 'target-name')): true
(contains(pods[*].status.phase, 'Running')): true
```

### Array Projection

```yaml
# GOOD: Extract field from array
(items[*].name): ['item1', 'item2', 'item3']

# GOOD: Extract nested fields
(pods[*].status.podIP): ['10.0.0.1', '10.0.0.2']

# GOOD: Filter and project
(items[?active==`true`].name): ['active1', 'active2']
```

### Array Filtering

```yaml
# GOOD: Filter by field value
(items[?type=='production']): [...]

# GOOD: Filter by condition
(pods[?status.phase=='Running']): [...]

# GOOD: Count filtered items
(length(items[?active==`true`])): 2

# GOOD: Check filtered result
(length(pods[?status.phase=='Failed']) == `0`): true
```

## JSON Content Validation

### Parse JSON Strings

```yaml
# GOOD: Parse and validate structure
- assert:
    resource:
      status:
        (json_parse(data).field != null): true
        (json_parse(data).nested.value): 'expected'

# GOOD: Validate JSON types
- assert:
    resource:
      status:
        (type(json_parse(response).count) == 'number'): true
        (type(json_parse(response).name) == 'string'): true
        (type(json_parse(response).items) == 'array'): true
```

### Nested JSON Validation

```yaml
# GOOD: Deep field access
- assert:
    resource:
      status:
        (json_parse(config).database.host): 'localhost'
        (json_parse(config).database.port): 5432
        (json_parse(config).features.enabled): true

# GOOD: Validate array in JSON
- assert:
    resource:
      status:
        (length(json_parse(data).items) > `0`): true
        (contains(json_parse(data).items[*].name, 'item1')): true
```

### JSON Schema Validation

```yaml
# GOOD: Validate required fields exist
- assert:
    resource:
      status:
        (json_parse(schema).type != null): true
        (json_parse(schema).properties != null): true
        (json_parse(schema).required != null): true

# GOOD: Validate field types
- assert:
    resource:
      status:
        (json_parse(schema).type): 'object'
        (type(json_parse(schema).properties) == 'object'): true
        (type(json_parse(schema).required) == 'array'): true
```

## Conditional Assertions

### Null Checks

```yaml
# GOOD: Field exists (not null)
(field != null): true

# GOOD: Field is null
(field == null): true

# GOOD: Nested field null check
(status.error == null): true
(status.result != null): true
```

### Boolean Validation

```yaml
# GOOD: Boolean field
(enabled): true
(disabled): false

# GOOD: Computed boolean
(readyReplicas == replicas): true
(length(errors) == `0`): true
```

### String Matching

```yaml
# GOOD: Exact match
(name): 'expected-name'

# GOOD: Contains substring
(contains(message, 'success')): true

# GOOD: Regex match
(regex_match('^pod-[0-9]+$', name)): true

# GOOD: Case-insensitive
(lower(status) == 'running'): true
```

### Numeric Comparisons

```yaml
# GOOD: Greater than
(count > `0`): true
(replicas > `2`): true

# GOOD: Range validation
(priority >= `1` && priority <= `10`): true

# GOOD: Equality with backticks
(replicas == `3`): true
```

## Common Patterns

### Pod Readiness

```yaml
# GOOD: Pod running and ready
- assert:
    resource:
      apiVersion: v1
      kind: Pod
      metadata:
        name: test-pod
      status:
        phase: Running
        (length(conditions[?type=='Ready' && status=='True']) > `0`): true
        (containerStatuses[0].ready): true
```

### Deployment Health

```yaml
# GOOD: Deployment fully available
- assert:
    resource:
      apiVersion: apps/v1
      kind: Deployment
      metadata:
        name: test-deployment
      status:
        (readyReplicas == spec.replicas): true
        (availableReplicas == spec.replicas): true
        (updatedReplicas == spec.replicas): true
        (length(conditions[?type=='Available' && status=='True']) > `0`): true
```

### Service Endpoints

```yaml
# GOOD: Service has endpoints
- assert:
    resource:
      apiVersion: v1
      kind: Endpoints
      metadata:
        name: test-service
      subsets:
      - (length(addresses) > `0`): true
```

### ConfigMap/Secret Data

```yaml
# GOOD: Validate data keys exist
- assert:
    resource:
      apiVersion: v1
      kind: ConfigMap
      metadata:
        name: test-config
      data:
        (length(keys(@))): 3
        (contains(keys(@), 'key1')): true
        (contains(keys(@), 'key2')): true
```

### Custom Resource Status

```yaml
# GOOD: CR reconciled successfully
- assert:
    resource:
      apiVersion: example.com/v1
      kind: CustomResource
      metadata:
        name: test-cr
      status:
        phase: ready
        (observedGeneration == metadata.generation): true
        (length(conditions[?type=='Ready' && status=='True']) > `0`): true
```

### Event Validation

```yaml
# GOOD: Check events via script (events can't be asserted directly)
- script:
    content: |
      EVENTS=$(kubectl get events --field-selector involvedObject.name=test-pod -o json)

      if echo "$EVENTS" | jq -e '.items | length > 0'; then
        echo "Events found"
      else
        echo "No events found"
        exit 1
      fi
```

## Anti-Patterns

### Don't Use Shell Scripts for Assertions

```yaml
# ❌ BAD: Shell script for validation
- script:
    content: |
      PHASE=$(kubectl get pod test-pod -o jsonpath='{.status.phase}')
      if [ "$PHASE" != "Running" ]; then
        exit 1
      fi

# ✅ GOOD: Use JP assertion
- assert:
    resource:
      apiVersion: v1
      kind: Pod
      metadata:
        name: test-pod
      status:
        phase: Running
```

### Don't Forget Backticks for Numbers

```yaml
# ❌ BAD: Number without backticks (treated as string)
(length(items) > 0): true

# ✅ GOOD: Number with backticks
(length(items) > `0`): true
```

### Don't Assert Non-existent Status Fields

```yaml
# ❌ BAD: Asserting status.phase on resource without it
- assert:
    resource:
      apiVersion: example.com/v1
      kind: NoStatusPhase
      status:
        phase: ready  # This field doesn't exist!

# ✅ GOOD: Assert only existing fields
- assert:
    resource:
      apiVersion: example.com/v1
      kind: NoStatusPhase
      metadata:
        name: test-resource
```

### Don't Use Exact Count for Events

```yaml
# ❌ BAD: Exact event count (flaky)
if [ "$event_count" -eq 1 ]; then
  echo "Success"
fi

# ✅ GOOD: Check for presence
if [ "$event_count" -gt 0 ]; then
  echo "Success"
fi
```

## Debugging Assertions

### Add Catch Blocks

```yaml
- name: validate-resource
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
  - describe:
      apiVersion: v1
      kind: Pod
      name: test-pod
  - script:
      content: |
        kubectl get pod test-pod -o yaml
        kubectl logs test-pod
```

### Test JP Expressions

Use `kubectl` with `jsonpath` to test expressions:

```bash
# Test JP expression
kubectl get pod test-pod -o jsonpath='{.status.phase}'

# Test array projection
kubectl get pods -o jsonpath='{.items[*].metadata.name}'

# Test filtering
kubectl get pods -o jsonpath='{.items[?(@.status.phase=="Running")].metadata.name}'
```

### Incremental Assertions

Build complex assertions incrementally:

```yaml
# Step 1: Assert exists
- assert:
    resource:
      apiVersion: v1
      kind: Pod
      metadata:
        name: test-pod

# Step 2: Assert phase
- assert:
    resource:
      apiVersion: v1
      kind: Pod
      metadata:
        name: test-pod
      status:
        phase: Running

# Step 3: Assert conditions
- assert:
    resource:
      apiVersion: v1
      kind: Pod
      metadata:
        name: test-pod
      status:
        phase: Running
        (length(conditions[?type=='Ready' && status=='True']) > `0`): true
```
