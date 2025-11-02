# Agent Report Templates

Base report structures for agent audit trail files. Each agent customizes sections specific to their phase.

## Common Report Header

```markdown
# [Report Type]: [Issue Name]

**Agent**: [Agent Name]
**Date**: [YYYY-MM-DD]
**Issue Type**: BUG 🐛 / FEATURE ✨
**Issue Path**: `<PROJECT_ROOT>/issues/[issue-name]/`
```

## Common Status Section

```markdown
## Status

**Phase**: [Validation / Review / Implementation / Testing / Documentation]
**Result**: [APPROVED ✅ / NEEDS CHANGES ⚠️ / REJECTED ❌ / COMPLETE ✅]
**Next Step**: [What happens next]
```

## Files Modified Section

```markdown
## Files Modified

| File | Lines | Changes |
|------|-------|---------|
| `path/to/file.go` | 45-67 | Added validation logic |
| `path/to/file_test.go` | 123-145 | Added test case |
```

## Test Results Section

```markdown
## Test Results

### Test Execution
**Command**: `[exact command used]`
**Status**: PASSING ✅ / FAILING ❌

### Output
```
[Actual test output]
```
```

## Recommendations Section

```markdown
## Recommendations

**Selected Approach**: [Approach name/description]

**Justification**:
- [Reason 1]
- [Reason 2]
- [Reason 3]

**Implementation Notes**:
- [Note 1]
- [Note 2]
```

---

# Agent-Specific Templates

## validation.md (Problem Validator)

```markdown
# Problem Validation Report: [Issue Name]

**Agent**: Problem Validator
**Date**: [YYYY-MM-DD]
**Issue Type**: BUG 🐛 / FEATURE ✨
**Issue Path**: `<PROJECT_ROOT>/issues/[issue-name]/`

## 1. Problem Confirmation

**Status**: CONFIRMED ✅ / NOT A BUG ❌ / MISUNDERSTOOD 📝
**Evidence**: [Concrete evidence]
**Root Cause**: [Analysis or why not a bug]

<!-- If NOT A BUG, skip to Recommendation -->

## 2. Proposed Solutions

### Solution A: [Name]
**Pros**:
- [Pro 1]
- [Pro 2]

**Cons**:
- [Con 1]
- [Con 2]

**Complexity**: Low / Medium / High
**Risk**: Low / Medium / High

### Solution B: [Name]
[Same format]

### Solution C: [Name]
[Same format]

## 3. Test Case

**Type**: Unit / E2E Chainsaw
**Location**: `[path]`
**Test Name**: `[name]`
**Status**: FAILING / PASSING
**Test Run Command**: `[command]`

### Test Output
```
[Actual output]
```

## 4. Recommendation

**Selected Approach**: Solution [A/B/C]

**Justification**:
- [Reason 1]
- [Reason 2]

**Implementation Guidance**:
- [Guidance 1]
- [Guidance 2]
```

## review.md (Solution Reviewer)

```markdown
# Solution Review Report: [Issue Name]

**Agent**: Solution Reviewer
**Date**: [YYYY-MM-DD]
**Issue Type**: BUG 🐛 / FEATURE ✨
**Issue Path**: `<PROJECT_ROOT>/issues/[issue-name]/`

## 1. Solutions Evaluated

| Solution | Correctness | Best Practices | Performance | Maintainability | Risk |
|----------|-------------|----------------|-------------|-----------------|------|
| A: [Name] | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | LOW |
| B: [Name] | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | MEDIUM |
| C: [Name] | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | HIGH |

## 2. Selected Solution

**Choice**: Solution [A/B/C]

**Justification**:
- [Reason 1 - why best]
- [Reason 2 - why better than alternatives]
- [Reason 3 - risk/benefit analysis]

## 3. Implementation Guidance

**Patterns to Use**:
- [Pattern 1]
- [Pattern 2]

**Edge Cases to Handle**:
- [Edge case 1]
- [Edge case 2]

**Code Locations**:
- `[file:lines]` - [What to change]
- `[file:lines]` - [What to add]
```

## implementation.md (Solution Implementer)

```markdown
# Implementation Report: [Issue Name]

**Agent**: Solution Implementer
**Date**: [YYYY-MM-DD]
**Issue Type**: BUG 🐛 / FEATURE ✨
**Issue Path**: `<PROJECT_ROOT>/issues/[issue-name]/`

## 1. Implementation Summary

**Approach Used**: [Selected solution approach]
**Files Modified**: [Count]
**Tests Created**: [Count]

## 2. Code Changes

### [File path]
**Lines**: [line range]
**Changes**:
- [Change description]

**Patterns Used**:
- [Go pattern 1]
- [Go pattern 2]

### [File path 2]
[Same format]

## 3. Build Verification

**Command**: `go build ./...`
**Result**: SUCCESS ✅ / FAILED ❌

## 4. Test Execution

**Command**: `[test command]`
**Result**: PASSING ✅ / FAILING ❌

### Test Output
```
[Actual output]
```

## 5. Summary

**Implementation Status**: COMPLETE ✅ / NEEDS REVISION ⚠️
**Build Status**: SUCCESS ✅
**Test Status**: PASSING ✅
**Ready for Review**: YES / NO
```

## testing.md (Code Reviewer & Tester)

```markdown
# Code Review & Testing Report: [Issue Name]

**Agent**: Code Reviewer & Tester
**Date**: [YYYY-MM-DD]
**Issue Type**: BUG 🐛 / FEATURE ✨
**Issue Path**: `<PROJECT_ROOT>/issues/[issue-name]/`

## 1. Code Review

**Review Status**: APPROVED ✅ / NEEDS CHANGES ⚠️

### Review Findings

| Dimension | Rating | Notes |
|-----------|--------|-------|
| Correctness | ⭐⭐⭐⭐⭐ | Solves problem completely |
| Go 1.23+ Practices | ⭐⭐⭐⭐ | Uses modern idioms |
| Performance | ⭐⭐⭐⭐⭐ | No overhead |
| Maintainability | ⭐⭐⭐⭐⭐ | Clear and simple |
| Risk | LOW | Well-tested |

## 2. Improvements Made

### [File:lines]
- [Improvement 1]
- [Improvement 2]

## 3. Linting

**Command**: `golangci-lint run`
**Result**: PASSED ✅ / FAILED ❌

## 4. Test Results

### Specific Test
**Command**: `[test command]`
**Result**: PASSING ✅

### Full Test Suite
**Command**: `make test`
**Result**: PASSING ✅
**Tests Run**: [count]
**Tests Passed**: [count]

## 5. Final Approval

**Decision**: APPROVED ✅ / REQUEST CHANGES ⚠️

**Approval Checklist**:
- ✅ Correctness verified
- ✅ Best practices applied
- ✅ Linter passing
- ✅ Tests passing
- ✅ No regressions
```

## solution.md (Documentation Updater)

```markdown
# Solution: [Issue Name]

**Resolved**: [YYYY-MM-DD]
**Resolved By**: Issue Resolver Agent (Orchestrated)
**Status**: RESOLVED ✅ / REJECTED ❌

## Problem Summary

[Brief description from problem-validator]

**Severity/Priority**: [Level]
**Root Cause**: [Analysis]
**Impact**: [What was affected]

## Solution Approach

**Selected Solution**: [Solution name]

**Approach Description**:
[Detailed explanation]

**Why This Approach**:
- [Reason 1]
- [Reason 2]

**Alternatives Considered**:
1. [Alternative 1] - Rejected because [reason]
2. [Alternative 2] - Rejected because [reason]

## Implementation Details

### Files Modified

| File | Changes |
|------|---------|
| `file.go:45-67` | Added validation logic using cmp.Or |
| `file_test.go:123-145` | Added test case |

### Modern Go Patterns Applied
- [Pattern 1]
- [Pattern 2]

### Edge Cases Handled
1. [Edge case 1]
2. [Edge case 2]

## Testing

**Test Name**: [name]
**Test Location**: `[path]`
**Test Type**: Unit / E2E

**Before Fix**: FAILED
**After Fix**: PASSED

### Validation Results
- ✅ Specific Test: PASSING
- ✅ Full Test Suite: PASSING
- ✅ Linter: PASSING
- ✅ Build: SUCCESS

## References
- Problem Definition: `<PROJECT_ROOT>/issues/[issue-name]/problem.md`
- Validation Report: `<PROJECT_ROOT>/issues/[issue-name]/validation.md`
- Solution Review: `<PROJECT_ROOT>/issues/[issue-name]/review.md`
- Implementation Details: `<PROJECT_ROOT>/issues/[issue-name]/implementation.md`
- Testing Report: `<PROJECT_ROOT>/issues/[issue-name]/testing.md`
```

## Rejected Issue solution.md

```markdown
# Solution: [Issue Name] - NOT A BUG

**Status**: REJECTED ❌
**Validated**: [YYYY-MM-DD]
**Validated By**: Problem Validator Agent

## Original Report Summary

**Claimed Issue**: [What was reported]
**Reported Severity**: [from problem.md]
**Reported Location**: [from problem.md]

## Validation Results

**Status**: NOT A BUG ❌
**Evidence**: [Concrete evidence showing code is correct]

### Why This Is Not A Bug

[Clear explanation]

### What The Code Actually Does

[Correct behavior explanation]

### Contradicting Evidence

- **Code Evidence**: [Relevant code showing correct implementation]
- **Test Evidence**: [Existing tests that validate correct behavior]
- **Logic Evidence**: [Why the reported scenario cannot occur]

## Analysis

**Reporter's Claim**: [Detailed breakdown]
**Reality**: [Actual behavior]
**Possible Cause of Confusion**: [Why misunderstanding occurred]

## Recommendation

**Action**: CLOSE ISSUE
**Reason**: Code is correct, no bug exists

**Optional Improvements**: [If applicable, suggestions for clarity]
```

## Usage

Each agent should:
1. Use the appropriate template for their report file
2. Customize sections specific to their analysis
3. Save the report to `<PROJECT_ROOT>/issues/[issue-name]/[report-file].md`
4. Include all required sections with actual data (no placeholders)
