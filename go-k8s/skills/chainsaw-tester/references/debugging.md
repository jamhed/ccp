# Debugging Chainsaw Tests

Comprehensive guide to debugging Chainsaw test failures, handling flaky tests, and resolving common issues.

## Table of Contents
1. [Debugging Test Failures](#debugging-test-failures)
2. [Flaky Test Patterns](#flaky-test-patterns)
3. [Webhook Timeout Race Conditions](#webhook-timeout-race-conditions)
4. [LLM-Dependent Assertions](#llm-dependent-assertions)
5. [Detecting Flakiness](#detecting-flakiness)
6. [Debugging Tools and Techniques](#debugging-tools-and-techniques)

## Debugging Test Failures

### Analyze the Failure

When a test fails:

1. **Read the test output and error messages**
   - Identify which step/assertion failed
   - Look for error messages in the output
   - Check the assertion that triggered the failure

2. **Check catch block outputs**
   - Review events captured in catch blocks
   - Examine describe output for resource state
   - Look for controller logs if available

3. **Examine resource status and conditions**
   - Check the actual state vs. expected state
   - Review status fields and conditions
   - Look for error messages in resource status

### Investigate Root Cause

Common root causes:

1. **Schema mismatches**
   ```bash
   # Verify CRD schema matches test expectations
   kubectl get crd <crd-name> -o yaml
   kubectl explain <resource>.<field>
   ```

2. **RBAC permission issues**
   ```bash
   # Check ServiceAccount permissions
   kubectl auth can-i --as=system:serviceaccount:<namespace>:<sa-name> <verb> <resource>
   ```

3. **Resource dependency order**
   - Verify dependencies are applied before dependents
   - Check numeric prefixes in manifest files (a00-, a01-, etc.)
   - Ensure resources exist before assertions

4. **Timing issues**
   - Check if timeouts are sufficient
   - Look for race conditions
   - Verify resources have time to reconcile

### Fix and Optimize

1. **Adjust assertions to match actual resource state**
   ```yaml
   # Before: Asserting non-existent field
   status:
     phase: ready  # Field doesn't exist on this CRD

   # After: Assert actual field
   status:
     state: Ready  # Actual field name
   ```

2. **Update timeouts for slow operations**
   ```yaml
   # Before: Default timeout too short
   - assert:
       resource:
         kind: Pod
         status:
           phase: Running

   # After: Explicit timeout
   - assert:
       timeout: 2m  # Allow time for image pull
       resource:
         kind: Pod
         status:
           phase: Running
   ```

3. **Fix resource dependency order**
   ```yaml
   # Before: Wrong order
   - apply:
       file: manifests/*.yaml  # Applies everything at once

   # After: Explicit order
   - apply:
       file: manifests/a00-namespace.yaml
   - apply:
       file: manifests/a01-rbac.yaml
   - apply:
       file: manifests/a02-secrets.yaml
   - apply:
       file: manifests/a03-custom-resource.yaml
   ```

4. **Replace shell scripts with JP assertions**
   ```yaml
   # ❌ BAD: Shell script
   - script:
       content: |
         COUNT=$(kubectl get pods -o json | jq '.items | length')
         if [ "$COUNT" -lt 1 ]; then
           exit 1
         fi

   # ✅ GOOD: JP assertion
   - assert:
       resource:
         apiVersion: v1
         kind: PodList
         items:
           (length(@) >= `1`): true
   ```

### Test Improvements

1. **Run with `--skip-delete` to verify**
   ```bash
   chainsaw test tests/my-test/ --skip-delete
   # Manually inspect resources
   kubectl get all -n chainsaw-test
   ```

2. **Check for flakiness by running multiple times**
   ```bash
   chainsaw test tests/my-test/ --repeat-count 10
   ```

3. **Validate improvements don't break other tests**
   ```bash
   chainsaw test tests/ --parallel 4
   ```

## Flaky Test Patterns

Flaky tests fail intermittently without code changes. Common patterns:

### Symptoms of Flakiness

- ✅ Passes locally, fails in CI
- ✅ Fails ~10-30% of the time
- ✅ Fails with timeout errors
- ✅ Fails with "resource not found" errors
- ✅ Fails only under load (parallel execution)

### Common Causes

1. **Race conditions** (webhooks, controllers)
2. **Insufficient timeouts** (slow reconciliation)
3. **Timing dependencies** (applying resources too quickly)
4. **Non-deterministic output** (LLM responses)
5. **External dependencies** (network, APIs)

## Webhook Timeout Race Conditions

### Symptom

Test fails intermittently with:
- `context deadline exceeded`
- Resource validation errors like `"Team not found"`
- Webhook timeout errors

### Root Cause

Admission webhooks validate dependencies by making API calls during resource creation. When resources are applied in rapid sequence (e.g., `manifests/*.yaml`), dependent resources may be created before webhook validation completes.

**Example Failure Pattern:**
```
Team webhook validates 3 agent members sequentially:
  researcher → analyst → summarizer (3 API GET calls)

Under CI load:
  Team creation timeout → "context deadline exceeded"

Race condition:
  Query applied before Team created → "Team not found" error
```

### Solution: Multi-Step Test Structure

Split resource application into separate steps to allow webhook validation to complete:

```yaml
apiVersion: chainsaw.kyverno.io/v1alpha1
kind: Test
metadata:
  name: team-query-test
spec:
  description: Test team query with webhook validation
  steps:
  # Step 1: Apply dependencies first (exclude resources that depend on webhooks)
  - name: setup-resources
    try:
    - apply:
        file: manifests/a0[0-6]*.yaml  # Excludes a07-query.yaml

  # Step 2: Wait for dependencies to be fully created
  - name: wait-for-dependencies
    try:
    - assert:
        resource:
          apiVersion: ark.mckinsey.com/v1alpha1
          kind: Team
          metadata:
            name: my-team
    - assert:
        resource:
          apiVersion: ark.mckinsey.com/v1alpha1
          kind: Agent
          metadata:
            name: member1

  # Step 3: Apply dependent resources after validation completes
  - name: run-query
    try:
    - apply:
        file: manifests/a07-query.yaml
    - assert:
        timeout: 2m
        resource:
          apiVersion: ark.mckinsey.com/v1alpha1
          kind: Query
          status:
            phase: done
```

### Key Strategies

1. **Split resource application into separate steps**
   - Apply webhook-validated resources first
   - Wait for them to exist
   - Then apply dependent resources

2. **Use glob patterns to exclude specific files**
   ```yaml
   # Apply files a00-a06, excluding a07
   file: manifests/a0[0-6]*.yaml

   # Apply only a07
   file: manifests/a07-*.yaml
   ```

3. **Add explicit assertions between steps**
   ```yaml
   - name: wait-for-team
     try:
     - assert:
         resource:
           kind: Team
           metadata:
             name: my-team
   ```

4. **Increase timeouts for webhook-validated resources**
   ```yaml
   - apply:
       timeout: 30s  # Allow time for webhook validation
       file: manifests/team.yaml
   ```

## LLM-Dependent Assertions

### Symptom

Test fails occasionally with content validation errors despite LLM producing valid output:
- String matching failures on valid responses
- Case-sensitive assertion failures
- Exact keyword matching failures on synonyms

### Root Cause

1. **LLMs don't always follow exact prompt instructions**
   - May use synonyms or rephrasing
   - May vary formatting or capitalization
   - May include extra context or explanations

2. **String matching is case-sensitive and brittle**
   - `"weather"` ≠ `"Weather"`
   - `"AI"` ≠ `"artificial intelligence"`

3. **Exact keyword matching fails on valid variations**
   - Looking for "SUMMARY:" fails on "Summary:" or "## Summary"

### Example Brittle Assertions

```yaml
# ❌ BAD: Exact prefix matching
- assert:
    resource:
      kind: Query
      status:
        (contains(responses[0].content, 'SUMMARY:')): true

# ❌ BAD: Case-sensitive keyword matching
- assert:
    resource:
      status:
        (contains(responses[0].content, 'artificial intelligence')): true
        # Fails on: "Artificial Intelligence", "AI", "A.I."

# ❌ BAD: Exact format expectations
- assert:
    resource:
      status:
        (contains(responses[0].content, '1.')): true
        # Fails if LLM uses "1)" or "•" instead
```

### Solution: Validate Functional Correctness

Focus on **structure and meaningful content**, not exact LLM phrasing:

```yaml
# ✅ GOOD: Validate structure and meaningful content
- assert:
    resource:
      apiVersion: ark.mckinsey.com/v1alpha1
      kind: Query
      status:
        # Functional validation
        phase: done

        # Response count
        (length(responses)): 1

        # Agent responded
        (contains(responses[*].target.name, 'agent-name')): true

        # Meaningful output length (not empty)
        (length(responses[0].content) > `50`): true

        # Combined content has substance
        (length(join('', responses[*].content)) > `200`): true

# ✅ GOOD: Validate JSON structure, not content
- assert:
    resource:
      status:
        phase: done
        (json_parse(responses[0].content).summary != null): true
        (type(json_parse(responses[0].content).score) == 'number'): true
        (length(json_parse(responses[0].content).tags) > `0`): true
```

### Key Strategies

1. **Assert completion status** (phase, state fields)
   ```yaml
   status:
     phase: done  # Not "running" or "error"
   ```

2. **Validate response count and structure**
   ```yaml
   (length(responses)): 2
   (contains(responses[*].target.name, 'agent-1')): true
   ```

3. **Check content length for meaningful output**
   ```yaml
   # At least 50 characters = not empty
   (length(responses[0].content) > `50`): true
   ```

4. **Avoid exact string matching on LLM output**
   ```yaml
   # ❌ BAD
   (contains(content, 'The weather is')): true

   # ✅ GOOD
   (length(content) > `20`): true
   (json_parse(content).temperature != null): true
   ```

5. **Focus on functional validation over content validation**
   ```yaml
   # Validate the query completed successfully
   status:
     phase: done
     (length(responses) > `0`): true

   # Not: validate exact wording in responses
   ```

## Detecting Flakiness

### Run Tests Multiple Times

Detect intermittent failures by running tests repeatedly:

```bash
# Run test 10 times to detect flakiness
chainsaw test tests/flaky-test/ --repeat-count 10

# Run in parallel to simulate CI load
chainsaw test tests/ --parallel 8

# Run specific test multiple times with skip-delete to inspect failures
chainsaw test tests/flaky-test/ --repeat-count 5 --skip-delete --pause-on-failure
```

### Analyze Failure Patterns

**Consistent failures** (100% failure rate):
- Likely a real bug or incorrect test
- Fix the test or the code

**Intermittent failures** (10-30% failure rate):
- Likely flakiness
- Check for race conditions
- Review timeout values
- Look for webhook/timing issues

**Timing-dependent failures**:
- Fails under load (parallel execution)
- Fails in CI but not locally
- Likely webhook/race condition issues
- → Apply multi-step test structure

**Content-dependent failures**:
- Fails on LLM output validation
- Fails with "expected 'X' but got 'Y'" on valid output
- Likely brittle assertion issues
- → Validate structure, not content

### Debugging Flaky Tests

1. **Enable verbose output**
   ```bash
   chainsaw test tests/flaky-test/ --repeat-count 10 -v
   ```

2. **Pause on failure for inspection**
   ```bash
   chainsaw test tests/flaky-test/ --pause-on-failure --skip-delete
   # Test pauses on failure, allowing manual inspection
   kubectl get all -n chainsaw-test
   ```

3. **Check events in catch blocks**
   ```yaml
   catch:
   - events: {}
   - describe:
       kind: Query
       name: test-query
   - script:
       content: |
         echo "=== Resource YAML ==="
         kubectl get query test-query -o yaml
         echo "=== Controller Logs ==="
         kubectl logs -l app=controller --tail=50
   ```

4. **Add intermediate assertions**
   ```yaml
   # Add assertions between steps to identify where failure occurs
   - name: apply-dependencies
     try:
     - apply:
         file: manifests/team.yaml
     - assert:
         resource:
           kind: Team
           metadata:
             name: my-team

   - name: apply-query
     try:
     - apply:
         file: manifests/query.yaml
   ```

## Debugging Tools and Techniques

### Catch Blocks for Error Handling

Always include catch blocks for debugging:

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
  # Capture events
  - events: {}

  # Describe failed resource
  - describe:
      apiVersion: v1
      kind: Pod
      name: test-pod

  # Run debug script
  - script:
      content: |
        echo "=== Pod Status ==="
        kubectl get pod test-pod -o yaml

        echo "=== Pod Logs ==="
        kubectl logs test-pod --all-containers=true

        echo "=== Events ==="
        kubectl get events --field-selector involvedObject.name=test-pod
```

### Finally Blocks for Cleanup

Use finally blocks for guaranteed cleanup:

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

### Incremental Assertions

Build complex assertions incrementally:

```yaml
# Step 1: Assert resource exists
- name: check-exists
  try:
  - assert:
      resource:
        apiVersion: v1
        kind: Pod
        metadata:
          name: test-pod

# Step 2: Assert phase
- name: check-running
  try:
  - assert:
      resource:
        apiVersion: v1
        kind: Pod
        metadata:
          name: test-pod
        status:
          phase: Running

# Step 3: Assert conditions
- name: check-ready
  try:
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

### Testing JP Expressions

Test JP expressions using `kubectl` with `jsonpath`:

```bash
# Test simple field access
kubectl get pod test-pod -o jsonpath='{.status.phase}'

# Test array projection
kubectl get pods -o jsonpath='{.items[*].metadata.name}'

# Test filtering
kubectl get pods -o jsonpath='{.items[?(@.status.phase=="Running")].metadata.name}'

# Test length
kubectl get pods -o jsonpath='{.items}' | jq 'length'

# Test contains (requires jq)
kubectl get query test-query -o jsonpath='{.status.responses[*].target.name}' | jq 'contains(["agent-1"])'
```

### Common Debug Commands

```bash
# View test resources in namespace
kubectl get all -n chainsaw-<test-name>

# Describe failed resource
kubectl describe pod test-pod -n chainsaw-<test-name>

# Get resource YAML
kubectl get pod test-pod -o yaml -n chainsaw-<test-name>

# View logs
kubectl logs test-pod -n chainsaw-<test-name>
kubectl logs test-pod --previous -n chainsaw-<test-name>  # Previous container

# View events
kubectl get events -n chainsaw-<test-name> --sort-by='.lastTimestamp'

# Check CRD schema
kubectl get crd queries.ark.mckinsey.com -o yaml
kubectl explain query.status
```

## Anti-Patterns to Avoid

### Don't Apply All Resources at Once with Webhooks

```yaml
# ❌ BAD: Causes race conditions
- apply:
    file: manifests/*.yaml  # Applies everything simultaneously

# ✅ GOOD: Split into steps
- name: setup-dependencies
  try:
  - apply:
      file: manifests/a0[0-6]*.yaml

- name: wait-for-dependencies
  try:
  - assert:
      resource:
        kind: Team
        metadata:
          name: my-team

- name: run-test
  try:
  - apply:
      file: manifests/a07-query.yaml
```

### Don't Assert Exact LLM Output

```yaml
# ❌ BAD: Brittle assertion
(contains(responses[0].content, 'The weather is sunny')): true

# ✅ GOOD: Functional validation
(length(responses[0].content) > `20`): true
(json_parse(responses[0].content).weather != null): true
```

### Don't Use Default Timeouts for Slow Operations

```yaml
# ❌ BAD: May timeout
- assert:
    resource:
      kind: Deployment
      status:
        readyReplicas: 3

# ✅ GOOD: Explicit timeout
- assert:
    timeout: 2m
    resource:
      kind: Deployment
      status:
        readyReplicas: 3
```

### Don't Skip Catch Blocks

```yaml
# ❌ BAD: No debugging context on failure
- name: test
  try:
  - assert:
      resource:
        kind: Pod
        status:
          phase: Running

# ✅ GOOD: Catch block provides debugging context
- name: test
  try:
  - assert:
      resource:
        kind: Pod
        status:
          phase: Running
  catch:
  - events: {}
  - describe:
      kind: Pod
      name: test-pod
```

## Best Practices Summary

✅ **Do:**
- Split resource application into steps when webhooks validate dependencies
- Use glob patterns to control application order: `a0[0-6]*.yaml`
- Wait for webhook-validated resources before creating dependents
- Validate LLM output structure and length, not exact content
- Include catch blocks with events and describe for all assertions
- Use appropriate timeouts for different operations
- Run tests multiple times to detect flakiness
- Add intermediate assertions to identify failure points

❌ **Don't:**
- Apply all resources with `manifests/*.yaml` when webhooks validate dependencies
- Assert exact LLM output strings (brittle, causes flakiness)
- Use exact string matching on LLM-generated content
- Use default timeouts for slow operations
- Skip catch blocks (loses debugging context)
- Assert non-existent status fields
- Use shell scripts for assertions (use JP functions)
