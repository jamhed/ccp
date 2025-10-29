# Kubernetes Operator Testing with Chainsaw

Comprehensive guide to testing Kubernetes operators, Custom Resource Definitions (CRDs), and controllers using Chainsaw.

## Table of Contents
1. [Operator Testing Fundamentals](#operator-testing-fundamentals)
2. [CRD Schema Validation](#crd-schema-validation)
3. [Resource Dependencies](#resource-dependencies)
4. [Testing Custom Resources](#testing-custom-resources)
5. [Admission Webhooks](#admission-webhooks)
6. [Controller Reconciliation](#controller-reconciliation)
7. [RBAC Testing](#rbac-testing)

## Operator Testing Fundamentals

### What to Test

When testing Kubernetes operators:

1. **CRD Installation**
   - CRD is installed correctly
   - Schema validation works
   - Default values are set

2. **Custom Resource Creation**
   - Resources can be created
   - Spec fields are validated
   - Admission webhooks work correctly

3. **Controller Reconciliation**
   - Controller processes resources
   - Status fields are updated
   - Dependent resources are created

4. **RBAC**
   - ServiceAccounts have correct permissions
   - Roles and RoleBindings are correct
   - Controller can access required resources

5. **Error Handling**
   - Invalid resources are rejected
   - Error messages are clear
   - Status reflects error state

### Test Structure

```yaml
apiVersion: chainsaw.kyverno.io/v1alpha1
kind: Test
metadata:
  name: operator-test
spec:
  description: Test operator functionality
  steps:
  # 1. Setup: RBAC, secrets, dependencies
  - name: setup
    try:
    - apply:
        file: manifests/00-rbac.yaml
    - apply:
        file: manifests/01-secrets.yaml

  # 2. Create: Custom resources
  - name: create-resources
    try:
    - apply:
        file: manifests/02-custom-resource.yaml

  # 3. Validate: Reconciliation and status
  - name: validate-reconciliation
    try:
    - assert:
        timeout: 2m
        resource:
          apiVersion: example.com/v1
          kind: CustomResource
          metadata:
            name: test-resource
          status:
            phase: Ready
            (observedGeneration == metadata.generation): true

  # 4. Test: Functionality
  - name: test-functionality
    try:
    - apply:
        file: manifests/03-test-action.yaml
    - assert:
        timeout: 2m
        resource:
          kind: TestAction
          status:
            phase: Complete
```

## CRD Schema Validation

### Check CRD Schema

Always verify the CRD schema before writing tests:

```bash
# List CRDs
kubectl get crds

# Get CRD schema
kubectl get crd queries.ark.mckinsey.com -o yaml

# Explain resource fields
kubectl explain query
kubectl explain query.spec
kubectl explain query.status
kubectl explain query.status.responses
```

### Validate Field Names and Types

```yaml
# ✅ GOOD: Check schema first
# kubectl explain query.status
# FIELD: phase <string>
# FIELD: responses <[]Object>

- assert:
    resource:
      apiVersion: ark.mckinsey.com/v1alpha1
      kind: Query
      status:
        phase: done  # Correct field name
        (length(responses)): 1  # Correct field name

# ❌ BAD: Using wrong field names
status:
  state: completed  # Wrong field (should be 'phase')
  results: []  # Wrong field (should be 'responses')
```

### Schema Evolution

When CRD schema changes:

```yaml
# Before: v1alpha1
apiVersion: example.com/v1alpha1
kind: MyResource
spec:
  oldField: value

# After: v1beta1 (field renamed)
apiVersion: example.com/v1beta1
kind: MyResource
spec:
  newField: value  # Field renamed

# Update tests accordingly
```

## Resource Dependencies

### Dependency Order

Apply resources in the correct order based on dependencies:

```
00-namespace.yaml      → Namespace
01-rbac.yaml           → ServiceAccounts, Roles, RoleBindings
02-secrets.yaml        → Secrets, ConfigMaps
03-crds.yaml           → Custom Resource Definitions
04-dependencies.yaml   → Resources that others depend on
05-main-resource.yaml  → Primary resource under test
06-test-trigger.yaml   → Action that triggers test behavior
```

### Numeric Prefixes

Use numeric prefixes to control application order:

```
manifests/
├── a00-namespace.yaml
├── a01-rbac.yaml
├── a02-secrets.yaml
├── a03-model.yaml
├── a04-agent.yaml
├── a05-team.yaml
└── a06-query.yaml
```

### Example: Correct Dependency Order

```yaml
apiVersion: chainsaw.kyverno.io/v1alpha1
kind: Test
metadata:
  name: dependency-order-test
spec:
  steps:
  # Step 1: RBAC first
  - name: setup-rbac
    try:
    - apply:
        file: manifests/a01-rbac.yaml

  # Step 2: Secrets and ConfigMaps
  - name: setup-secrets
    try:
    - apply:
        file: manifests/a02-secrets.yaml

  # Step 3: Dependencies (e.g., Model, Agent)
  - name: setup-dependencies
    try:
    - apply:
        file: manifests/a03-model.yaml
    - apply:
        file: manifests/a04-agent.yaml

  # Step 4: Wait for dependencies to be ready
  - name: wait-for-dependencies
    try:
    - assert:
        timeout: 2m
        resource:
          apiVersion: ark.mckinsey.com/v1alpha1
          kind: Model
          metadata:
            name: test-model
          status:
            phase: ready

  # Step 5: Main resource
  - name: create-main-resource
    try:
    - apply:
        file: manifests/a05-team.yaml
```

## Testing Custom Resources

### Basic CR Creation

```yaml
# Step 1: Create Custom Resource
- name: create-cr
  try:
  - apply:
      resource:
        apiVersion: example.com/v1
        kind: CustomResource
        metadata:
          name: test-cr
        spec:
          field1: value1
          field2: value2

# Step 2: Assert CR exists
- name: verify-cr-exists
  try:
  - assert:
      resource:
        apiVersion: example.com/v1
        kind: CustomResource
        metadata:
          name: test-cr
```

### Validate Status Updates

```yaml
# Assert controller updates status
- name: validate-status
  try:
  - assert:
      timeout: 2m
      resource:
        apiVersion: example.com/v1
        kind: CustomResource
        metadata:
          name: test-cr
        status:
          # Phase or state
          phase: Ready

          # ObservedGeneration matches metadata.generation
          (observedGeneration == metadata.generation): true

          # Conditions
          (length(conditions) > `0`): true
          (contains(conditions[*].type, 'Ready')): true
          (contains(conditions[*].status, 'True')): true
```

### Validate Dependent Resources

Test that the controller creates dependent resources:

```yaml
# Assert controller created a Deployment
- name: validate-deployment-created
  try:
  - assert:
      timeout: 2m
      resource:
        apiVersion: apps/v1
        kind: Deployment
        metadata:
          name: test-cr-deployment
          labels:
            app: test-cr
        status:
          (readyReplicas > `0`): true
```

## Admission Webhooks

### Validating Admission Webhooks

Test that admission webhooks validate resources correctly:

```yaml
# Test: Valid resource is accepted
- name: test-valid-resource
  try:
  - apply:
      resource:
        apiVersion: example.com/v1
        kind: CustomResource
        metadata:
          name: valid-resource
        spec:
          validField: value

# Test: Invalid resource is rejected
- name: test-invalid-resource
  try:
  - error:  # Expect this to fail
      resource:
        apiVersion: example.com/v1
        kind: CustomResource
        metadata:
          name: invalid-resource
        spec:
          invalidField: bad-value  # Should be rejected by webhook
```

### Webhook Timeout Issues

See [debugging.md#webhook-timeout-race-conditions](debugging.md#webhook-timeout-race-conditions) for handling webhook race conditions.

### Multi-Step for Webhook Validation

```yaml
# Step 1: Create dependencies that webhooks validate
- name: create-dependencies
  try:
  - apply:
      file: manifests/a03-agent.yaml

# Step 2: Wait for dependencies
- name: wait-for-dependencies
  try:
  - assert:
      resource:
        apiVersion: ark.mckinsey.com/v1alpha1
        kind: Agent
        metadata:
          name: test-agent

# Step 3: Create resource that webhook validates
- name: create-validated-resource
  try:
  - apply:
      file: manifests/a04-team.yaml  # Webhook validates agents exist
```

## Controller Reconciliation

### Test Reconciliation Behavior

```yaml
# Test 1: Create resource
- name: create-resource
  try:
  - apply:
      resource:
        apiVersion: example.com/v1
        kind: CustomResource
        metadata:
          name: test-cr
        spec:
          replicas: 3

# Test 2: Verify reconciliation
- name: verify-reconciliation
  try:
  - assert:
      timeout: 2m
      resource:
        apiVersion: example.com/v1
        kind: CustomResource
        metadata:
          name: test-cr
        status:
          # Controller updated status
          phase: Ready
          observedGeneration: 1

# Test 3: Verify dependent resources created
- name: verify-dependent-resources
  try:
  - assert:
      resource:
        apiVersion: apps/v1
        kind: Deployment
        metadata:
          name: test-cr
        spec:
          replicas: 3
        status:
          (readyReplicas == `3`): true
```

### Test Update Reconciliation

```yaml
# Step 1: Create resource
- name: create-resource
  try:
  - apply:
      resource:
        apiVersion: example.com/v1
        kind: CustomResource
        metadata:
          name: test-cr
        spec:
          replicas: 1

# Step 2: Wait for initial reconciliation
- name: wait-initial-reconciliation
  try:
  - assert:
      timeout: 2m
      resource:
        apiVersion: example.com/v1
        kind: CustomResource
        metadata:
          name: test-cr
        status:
          phase: Ready
          observedGeneration: 1

# Step 3: Update resource
- name: update-resource
  try:
  - update:
      resource:
        apiVersion: example.com/v1
        kind: CustomResource
        metadata:
          name: test-cr
        spec:
          replicas: 3  # Increase replicas

# Step 4: Verify update reconciliation
- name: verify-update-reconciliation
  try:
  - assert:
      timeout: 2m
      resource:
        apiVersion: example.com/v1
        kind: CustomResource
        metadata:
          name: test-cr
        status:
          phase: Ready
          observedGeneration: 2  # Generation incremented
  - assert:
      resource:
        apiVersion: apps/v1
        kind: Deployment
        metadata:
          name: test-cr
        status:
          (readyReplicas == `3`): true  # Replicas updated
```

### Test Deletion and Finalizers

```yaml
# Test finalizer behavior
- name: test-deletion-with-finalizer
  try:
  # Create resource with finalizer
  - apply:
      resource:
        apiVersion: example.com/v1
        kind: CustomResource
        metadata:
          name: test-cr
          finalizers:
          - example.com/finalizer

  # Wait for ready
  - assert:
      timeout: 2m
      resource:
        apiVersion: example.com/v1
        kind: CustomResource
        metadata:
          name: test-cr
        status:
          phase: Ready

  # Delete resource
  - delete:
      ref:
        apiVersion: example.com/v1
        kind: CustomResource
        name: test-cr

  # Verify resource has deletionTimestamp but still exists (finalizer prevents deletion)
  - assert:
      timeout: 30s
      resource:
        apiVersion: example.com/v1
        kind: CustomResource
        metadata:
          name: test-cr
          (deletionTimestamp != null): true
          finalizers:
          - example.com/finalizer

  # Wait for controller to remove finalizer
  - assert:
      timeout: 2m
      resource:
        apiVersion: example.com/v1
        kind: CustomResource
        metadata:
          name: test-cr
        (metadata.finalizers == null || length(metadata.finalizers) == `0`): true

  # Verify resource is eventually deleted
  - script:
      content: |
        kubectl wait --for=delete customresource/test-cr --timeout=30s
```

## RBAC Testing

### Test ServiceAccount Permissions

```yaml
# manifests/a01-rbac.yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: test-sa
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: test-role
rules:
- apiGroups: ["ark.mckinsey.com"]
  resources: ["queries"]
  verbs: ["get", "list", "create"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: test-rolebinding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: test-role
subjects:
- kind: ServiceAccount
  name: test-sa
```

### Verify RBAC Permissions

```yaml
# Test that ServiceAccount has correct permissions
- name: verify-rbac
  try:
  - script:
      content: |
        # Check if ServiceAccount can create queries
        kubectl auth can-i create queries \
          --as=system:serviceaccount:$NAMESPACE:test-sa \
          -n $NAMESPACE

        # Check if ServiceAccount can list queries
        kubectl auth can-i list queries \
          --as=system:serviceaccount:$NAMESPACE:test-sa \
          -n $NAMESPACE
      env:
      - name: NAMESPACE
        value: ($namespace)
```

### Test Resource Creation with ServiceAccount

```yaml
# Create resource using ServiceAccount
- name: create-with-sa
  try:
  - apply:
      resource:
        apiVersion: ark.mckinsey.com/v1alpha1
        kind: Query
        metadata:
          name: test-query
        spec:
          serviceAccountName: test-sa  # Use test ServiceAccount
          prompt: "test prompt"
```

## Best Practices

### 1. Always Verify CRD Schema First

```bash
# Before writing tests
kubectl get crd queries.ark.mckinsey.com -o yaml
kubectl explain query.spec
kubectl explain query.status
```

### 2. Apply Resources in Dependency Order

```yaml
# ✅ GOOD: Explicit dependency order
- apply:
    file: manifests/a01-rbac.yaml
- apply:
    file: manifests/a02-secrets.yaml
- apply:
    file: manifests/a03-model.yaml

# ❌ BAD: All at once (may fail due to dependencies)
- apply:
    file: manifests/*.yaml
```

### 3. Wait for Reconciliation

```yaml
# ✅ GOOD: Wait for controller to reconcile
- assert:
    timeout: 2m  # Allow time for reconciliation
    resource:
      kind: CustomResource
      status:
        phase: Ready

# ❌ BAD: No timeout (uses default, may be too short)
- assert:
    resource:
      kind: CustomResource
      status:
        phase: Ready
```

### 4. Validate ObservedGeneration

```yaml
# ✅ GOOD: Verify controller processed current generation
status:
  (observedGeneration == metadata.generation): true

# Ensures status reflects current spec, not stale state
```

### 5. Test Both Positive and Negative Cases

```yaml
# Positive: Valid resource accepted
- name: test-valid
  try:
  - apply:
      resource:
        spec:
          validField: value

# Negative: Invalid resource rejected
- name: test-invalid
  try:
  - error:  # Expect failure
      resource:
        spec:
          invalidField: bad-value
```

### 6. Include RBAC in Tests

```yaml
# ✅ GOOD: Test includes RBAC setup
steps:
- name: setup-rbac
  try:
  - apply:
      file: manifests/a01-rbac.yaml

# ❌ BAD: Assumes RBAC exists (test may fail)
steps:
- name: create-resource
  try:
  - apply:
      file: manifests/query.yaml
```

### 7. Test Webhook Validation Separately

```yaml
# Step 1: Test valid resource (webhook accepts)
- name: test-valid-resource
  try:
  - apply:
      resource:
        spec:
          validField: value

# Step 2: Test invalid resource (webhook rejects)
- name: test-invalid-resource
  try:
  - error:
      resource:
        spec:
          invalidField: bad-value
```

## Common Patterns

### Pattern 1: Full Operator Test

```yaml
apiVersion: chainsaw.kyverno.io/v1alpha1
kind: Test
metadata:
  name: full-operator-test
spec:
  description: Complete operator functionality test
  steps:
  # 1. Setup
  - name: setup
    try:
    - apply:
        file: manifests/a01-rbac.yaml
    - apply:
        file: manifests/a02-secrets.yaml

  # 2. Create dependencies
  - name: create-dependencies
    try:
    - apply:
        file: manifests/a03-model.yaml
    - assert:
        timeout: 2m
        resource:
          kind: Model
          metadata:
            name: test-model
          status:
            phase: ready

  # 3. Create main resource
  - name: create-resource
    try:
    - apply:
        file: manifests/a04-custom-resource.yaml

  # 4. Validate reconciliation
  - name: validate-reconciliation
    try:
    - assert:
        timeout: 2m
        resource:
          kind: CustomResource
          metadata:
            name: test-resource
          status:
            phase: Ready
            (observedGeneration == metadata.generation): true

  # 5. Validate dependent resources
  - name: validate-dependents
    try:
    - assert:
        resource:
          kind: Deployment
          metadata:
            name: test-resource-deployment
          status:
            (readyReplicas > `0`): true

  # 6. Test update
  - name: test-update
    try:
    - update:
        resource:
          kind: CustomResource
          metadata:
            name: test-resource
          spec:
            field: new-value
    - assert:
        timeout: 2m
        resource:
          kind: CustomResource
          status:
            observedGeneration: 2

  # 7. Test deletion
  - name: test-deletion
    try:
    - delete:
        ref:
          kind: CustomResource
          name: test-resource
    - script:
        content: |
          kubectl wait --for=delete customresource/test-resource --timeout=30s
```

### Pattern 2: Webhook Validation Test

```yaml
apiVersion: chainsaw.kyverno.io/v1alpha1
kind: Test
metadata:
  name: webhook-validation-test
spec:
  description: Test admission webhook validation
  steps:
  # Test 1: Valid resource accepted
  - name: test-valid
    try:
    - apply:
        resource:
          apiVersion: example.com/v1
          kind: CustomResource
          metadata:
            name: valid-resource
          spec:
            requiredField: value
            validField: correct-value

  # Test 2: Missing required field rejected
  - name: test-missing-required
    try:
    - error:
        resource:
          apiVersion: example.com/v1
          kind: CustomResource
          metadata:
            name: invalid-resource
          spec:
            validField: value
            # Missing requiredField

  # Test 3: Invalid field value rejected
  - name: test-invalid-value
    try:
    - error:
        resource:
          apiVersion: example.com/v1
          kind: CustomResource
          metadata:
            name: invalid-value
          spec:
            requiredField: value
            validField: invalid-value  # Wrong format
```

### Pattern 3: Status Condition Testing

```yaml
# Test that controller updates conditions correctly
- name: validate-conditions
  try:
  - assert:
      timeout: 2m
      resource:
        apiVersion: example.com/v1
        kind: CustomResource
        metadata:
          name: test-resource
        status:
          # Check Ready condition exists and is True
          (length(conditions[?type=='Ready']) > `0`): true
          (conditions[?type=='Ready'].status | [0]): 'True'
          (conditions[?type=='Ready'].reason | [0]): 'ReconcileSuccess'

          # Check no Error conditions
          (length(conditions[?type=='Error']) == `0`): true
```

## Anti-Patterns

### ❌ Don't Skip CRD Schema Validation

```yaml
# ❌ BAD: Asserting non-existent field
status:
  state: Ready  # Field doesn't exist in CRD

# ✅ GOOD: Check schema first
# kubectl explain customresource.status
status:
  phase: Ready  # Actual field name
```

### ❌ Don't Apply All Resources at Once with Webhooks

```yaml
# ❌ BAD: Race condition with webhooks
- apply:
    file: manifests/*.yaml

# ✅ GOOD: Separate steps
- name: apply-dependencies
  try:
  - apply:
      file: manifests/a0[0-5]*.yaml
- name: wait-for-dependencies
  try:
  - assert:
      resource:
        kind: Dependency
- name: apply-main
  try:
  - apply:
      file: manifests/a06-*.yaml
```

### ❌ Don't Ignore ObservedGeneration

```yaml
# ❌ BAD: May be stale status
status:
  phase: Ready

# ✅ GOOD: Verify current generation
status:
  phase: Ready
  (observedGeneration == metadata.generation): true
```

### ❌ Don't Forget RBAC

```yaml
# ❌ BAD: No RBAC setup
- apply:
    file: manifests/query.yaml  # May fail without RBAC

# ✅ GOOD: Setup RBAC first
- apply:
    file: manifests/a01-rbac.yaml
- apply:
    file: manifests/a05-query.yaml
```
