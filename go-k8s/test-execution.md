# Test Execution Guide

Common test execution instructions for all agents.

## Test Types

| Type | Use Case | Location | Agent Phase |
|------|----------|----------|-------------|
| **Unit Test** | Logic bugs, edge cases, validation | `*_test.go` files | Problem Validator, Solution Implementer, Code Reviewer |
| **E2E Chainsaw** | Controller behavior, reconciliation, features | `tests/e2e/*/chainsaw-test.yaml` | Problem Validator (features), Solution Implementer |
| **Full Suite** | Regression verification | All tests | Code Reviewer, Solution Implementer |

## When to Create Tests

### For Bugs
- **Unit tests**: Logic bugs, edge cases, validation issues
- **E2E Chainsaw**: Controller behavior, reconciliation, resource management
- **Before creating**: Verify existing tests don't already cover this scenario

### For Features
- **E2E Chainsaw**: **REQUIRED** for all features ✅
- **Unit tests**: Optional for specific functions
- Features adding controller logic, webhooks, or resource management **MUST** have E2E tests

## Test Execution Commands

### Unit Tests
```bash
# Run specific test
go test ./path/to/package/... -v -run TestName

# Run package tests
go test ./internal/controller/... -v

# Run with coverage
go test ./... -v -cover
```

### E2E Chainsaw Tests
```bash
# Run specific test directory
chainsaw test tests/e2e/test-name/

# Run all E2E tests
chainsaw test tests/e2e/

# Run with verbose output
chainsaw test tests/e2e/test-name/ -v
```

### Full Test Suite
```bash
# Run all tests
make test

# Or directly
go test ./... -v
```

## Expected Test Behavior

| Test Type | Before Fix/Implementation | After Fix/Implementation |
|-----------|---------------------------|--------------------------|
| **Bug unit test** | FAIL (proves bug exists) | PASS (proves fix works) |
| **Bug E2E test** | FAIL (demonstrates issue) | PASS (validates resolution) |
| **Feature E2E test** | FAIL (feature not implemented) | PASS (feature complete) |
| **Regression tests** | PASS (no existing breakage) | PASS (no new breakage) |

## Creating E2E Chainsaw Tests

**ALWAYS use chainsaw-tester skill**:
```
Skill(go-k8s:chainsaw-tester)
```

The chainsaw-tester skill provides:
- Expert guidance on Chainsaw test structure and file naming
- JP assertion patterns (preferred over shell scripts)
- RBAC configuration best practices
- Mock service deployment patterns
- Debugging and flakiness resolution
- CRD schema validation guidance

**References**:
- `docs/web/chainsaw/assertion-patterns.md` - JP assertion examples
- `docs/web/chainsaw/jp-functions.md` - JP function reference
- `docs/web/chainsaw/operator-testing.md` - Operator testing guide

## Test Documentation Template

Document test creation in your report:

```markdown
## Test Case Created

**Type**: Unit / E2E Chainsaw
**Location**: `[file path:line]` or `tests/e2e/[test-name]/`
**Test Name**: `[TestFunctionName]` or `chainsaw-test.yaml`
**Status**: FAILING / PASSING
**Test Run Command**: `[exact command used]`

### Test Scenarios Covered (for E2E tests)
- [Scenario 1: e.g., resource creation]
- [Scenario 2: e.g., status validation]
- [Scenario 3: e.g., reconciliation behavior]
- [Scenario 4: e.g., edge cases]

### Test Output
```
[ACTUAL output from running the test - never use placeholder text]
```
```

## Critical Requirements

### ALWAYS Run Tests After Creation
- **Never skip test execution** after creating a test
- **Always capture actual output** in reports
- **Never use placeholder or hypothetical output**

If a test unexpectedly passes when it should fail:
- Reconsider bug confirmation (bug might not exist)
- Feature might already be implemented
- Test might not correctly validate the scenario

### Test Output in Reports

**REQUIRED**: Include actual test execution output:
```markdown
### Test Output
```
=== RUN TestFeatureName
--- FAIL: TestFeatureName (0.01s)
    feature_test.go:45: expected status to be "Ready", got "Pending"
FAIL
```
```

**NEVER use**:
```markdown
### Test Output
```
[Test fails as expected, showing the bug exists]
```
```

## Test File Naming

### Unit Tests
- Test file: `[original_file]_test.go`
- Test function: `Test[FunctionName][Scenario]`
- Example: `controller_test.go` with `TestReconcileBackupCreation`

### E2E Chainsaw Tests
- Directory: `tests/e2e/[feature-name]/`
- Test file: `chainsaw-test.yaml`
- Supporting files: `00-[resource].yaml`, `01-assert.yaml`, etc.
- Example: `tests/e2e/backup-validation/chainsaw-test.yaml`

## Common Issues

### Test Flakiness
- Use chainsaw-tester skill for E2E test debugging
- Check for timing issues in assertions
- Verify proper wait conditions

### Missing Dependencies
- Ensure CRDs are installed
- Check RBAC permissions
- Verify test namespace setup

### Test Not Failing as Expected
- Verify test actually exercises the bug condition
- Check that assertions are correct
- Ensure test isolation (no side effects from other tests)
