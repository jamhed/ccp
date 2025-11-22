---
name: issue-management
description: Python issue management patterns and documentation structures for the cxp problem-solving workflow - problem definitions, solution docs, validation reports, audit trails
---

# Python Issue Management (2025)

Common patterns and structures for managing Python issues through the cxp multi-phase problem-solving workflow. This skill defines the documentation formats, workflow phases, and issue lifecycle used across all cxp agents.

## Issue Lifecycle Overview

```
1. Problem Research → issues/[issue-name]/problem.md (OPEN)
2. Problem Validation → issues/[issue-name]/validation.md
3. Solution Proposal → Updates validation.md with proposals
4. Solution Review → issues/[issue-name]/review.md
5. Implementation → issues/[issue-name]/implementation.md
6. Testing & Review → issues/[issue-name]/testing.md
7. Documentation → issues/[issue-name]/solution.md (RESOLVED/REJECTED)
8. Archive → archive/[issue-name]/ (all files moved)
```

## Directory Structure

### Active Issues (Work in Progress)

```
<PROJECT_ROOT>/issues/[issue-name]/
├── problem.md          # Issue definition (Status: OPEN)
├── validation.md       # Problem Validator findings (optional, during workflow)
├── review.md           # Solution Reviewer analysis (optional, during workflow)
├── implementation.md   # Solution Implementer report (optional, during workflow)
├── testing.md          # Code review and test results (optional, during workflow)
└── solution.md         # Final documentation (created at end)
```

### Archived Issues (Completed)

```
<PROJECT_ROOT>/archive/[issue-name]/
├── problem.md          # Original issue (Status: RESOLVED or REJECTED)
├── validation.md       # Audit trail
├── review.md           # Audit trail
├── implementation.md   # Audit trail
├── testing.md          # Audit trail
└── solution.md         # Final summary
```

## Issue Naming Convention

Use descriptive kebab-case names that clearly indicate the issue:

**Format**: `[type]-[brief-description]`

**Examples**:
- `bug-async-unhandled-exception`
- `bug-off-by-one-pagination`
- `feature-user-export-csv`
- `perf-n-plus-one-query-users`
- `refactor-split-user-service`

**Type Prefixes**:
- `bug-` - Bug fixes
- `feature-` - New features
- `perf-` - Performance improvements
- `refactor-` - Code refactoring
- `debt-` - Technical debt
- `arch-` - Architecture changes

## Problem Definition Structure (problem.md)

### Header Format

```markdown
# [Type]: [Issue Name]

**Status**: OPEN
**Type**: BUG 🐛 | FEATURE ✨ | PERFORMANCE ⚡
**Severity** (bugs): Critical | High | Medium | Low (evidence-based)
**Priority** (features): High | Medium | Low
**Location**: [File paths or module names]
**Created**: [YYYY-MM-DD]
```

### Required Sections

#### For Bugs

```markdown
## Problem Description
[Clear, concise description of the bug]

## Evidence
[Concrete evidence - stack traces, error output, profiling data]

## Root Cause Analysis
[Technical analysis of why the bug occurs]

## Code Analysis
**File**: [path/to/file.py]
**Lines**: [line numbers]
[Code snippet showing the bug]

## Impact
[Consequences of the bug - crashes, data issues, user impact]

## Reproduction Steps
1. [Step by step to reproduce]
2. [Include actual commands: `uv run pytest -n auto tests/test_file.py::test_name`]

## Third-Party Solutions (if applicable)
[Research of existing packages/libraries that could help]

## Recommended Fix
[Brief approach - 1-2 sentences per option, 2-3 options max]

## Acceptance Criteria
- [ ] [Specific, testable criteria]
- [ ] [Test requirements: "pytest test should pass"]
```

#### For Features

```markdown
## Feature Description
[Clear description of what needs to be built]

## Use Cases
[Who needs this and why]

## Requirements
[Specific functionality requirements]

## Third-Party Solutions
[Research of existing packages/libraries - REQUIRED]
**Researched Packages**:
- **[package-name]**: [brief evaluation - pros/cons, fit, license]
- **[package-name-2]**: [brief evaluation]

**Recommendation**: [Use package X | Custom implementation because...]

## Proposed Implementation
[High-level approach - 2-3 options with 1-2 sentences each]

## Acceptance Criteria
- [ ] [Specific, testable criteria]
- [ ] [Integration test requirements]
```

## Validation Documentation Structure (validation.md)

### Header Format

```markdown
# Validation Report: [Issue Name]

**Validation Status**: CONFIRMED ✅ | NOT A BUG ❌ | PARTIALLY CORRECT ⚠️ | NEEDS INVESTIGATION 🔍
**Validated**: [YYYY-MM-DD]
**Issue Type**: BUG 🐛 | FEATURE ✨ | PERFORMANCE ⚡
**Severity/Priority**: [Level]
```

### For CONFIRMED Issues

```markdown
## Validation Summary
[Confirmation of the issue]

## Test Case
**Test Name**: [test_name]
**Test Location**: [path/to/test_file.py]
**Expected Behavior**: FAIL before fix, PASS after fix

```python
# Test code with pytest-asyncio 1.3.0+, AsyncMock if needed
```

**Test Results**:
```
[Actual pytest output from `uv run pytest -n auto`]
```

## Solution Proposals
[Will be filled by Solution Proposer agent - omit from validator output]
```

### For NOT A BUG (REJECTED)

```markdown
## Validation Summary
**Status**: NOT A BUG ❌

## Why This Is Not A Bug
[Clear explanation with evidence]

## Contradicting Evidence
[Code, tests, logic showing correct behavior]

## Recommendation
**Action**: REJECT ISSUE
**Next Step**: Documentation Updater will create solution.md and close issue
```

## Solution Review Structure (review.md)

```markdown
# Solution Review: [Issue Name]

**Reviewed**: [YYYY-MM-DD]
**Approaches Evaluated**: [A, B, C, D]
**Recommendation**: APPROVED ✅ | NEEDS CHANGES ⚠️ | REJECTED ❌

## Solution Analysis

### Approach A: [Name]
**Complexity**: Low | Medium | High
**Risk**: Low | Medium | High
**Effort**: [1-2 days | 3-5 days | 1-2 weeks]

**Strengths**:
- [Specific strengths]

**Weaknesses**:
- [Specific weaknesses]

**Type Safety**: [Assessment]
**Async Compatibility**: [Assessment]

### Approach B: [Name]
[Same structure]

## Recommended Solution

**Selected**: Approach [X]

**Justification**:
[Why this approach is best]

**Key Decision Factors**:
- [Factor 1]
- [Factor 2]

## Implementation Guidance
[Specific patterns, libraries, edge cases to consider]
```

## Implementation Documentation Structure (implementation.md)

```markdown
# Implementation Report: [Issue Name]

**Implemented**: [YYYY-MM-DD]
**Approach**: [Selected approach from review.md]

## Changes Summary

### Files Modified
| File | Change Type | Lines Changed |
|------|-------------|---------------|
| [path] | Modified | +X -Y |
| [path] | Created | +X |

## Implementation Details

### File: [path/to/file.py]
**Changes**: [Description]

**Before**:
```python
# Original code
```

**After**:
```python
# New code with t-strings, deferred annotations, modern patterns
```

**Rationale**: [Why this change]

## Modern Python Patterns Applied
- [ ] t-strings (PEP 750)
- [ ] Deferred annotations
- [ ] Type hints with modern syntax
- [ ] Async/await patterns
- [ ] Fail-fast error handling
- [ ] [Other patterns]

## Edge Cases Handled
- [Edge case 1 and how it's handled]
- [Edge case 2]

## Tests Created/Modified
[Test files and what they validate]

## Code Quality Checks Run

**Linting** (`uv run ruff check .`):
```
[Output]
```

**Type Checking** (`uv run pyright [files]`):
```
[Output]
```

**Tests** (`uv run pytest -n auto -v`):
```
[Output]
```
```

## Testing Documentation Structure (testing.md)

```markdown
# Testing Report: [Issue Name]

**Tested**: [YYYY-MM-DD]
**All Tests**: PASSING ✅ | FAILING ❌
**Validation Tests Processed**: [count] converted, [count] deleted

## Test Execution Results

### Full Test Suite
```bash
uv run pytest -n auto -v
```

**Output**:
```
[Complete test output]
```

**Coverage**:
```
[Coverage report if run]
```

## Code Review Findings

### Critical Issues Found
[Issues that MUST be fixed]

### Implementation Bugs Found
[Bugs discovered during testing]

### Validation Tests Processed
[List of validation tests - what was done with each]
- `test_name`: Converted to behavioral test ✅
- `test_name_2`: Deleted (implementation proven) ✅

## Refactoring Opportunities

### High Priority (Create Follow-up Issues)
- [Opportunity 1]

### Medium Priority (Create Follow-up Issues)
- [Opportunity 2]

### Low Priority (Document Only)
- [Opportunity 3]

## Security Review
[Any security concerns found]

## Final Verdict
- [ ] All tests passing
- [ ] No critical issues remaining
- [ ] Validation tests processed
- [ ] Code quality checks passed
- [ ] Ready for documentation and commit
```

## Solution Documentation Structure (solution.md)

### For RESOLVED Issues

```markdown
# Solution: [Issue Name]

**Resolved**: [YYYY-MM-DD]
**Status**: RESOLVED ✅

## Problem Summary
**Type**: BUG 🐛 | FEATURE ✨ | PERFORMANCE ⚡
**Severity/Priority**: [Level]
**Root Cause**: [Brief technical explanation]
**Impact**: [What was affected]

## Solution Approach

**Selected Solution**: [Name/brief description]

**Why This Approach**:
[Reasons for selection]

**Alternatives Considered**:
- **Approach B**: Rejected because [reason]
- **Approach C**: Rejected because [reason]

## Implementation Details

### Files Modified
| File | Change Type | Description |
|------|-------------|-------------|
| [path] | Modified | [What changed] |
| [path] | Created | [What was added] |

### Modern Python Patterns Applied
- t-strings for template literals
- Deferred annotations for type hints
- asyncio.gather for concurrent operations
- Fail-fast error handling
- [Other patterns]

### Edge Cases Handled
- [Edge case 1]
- [Edge case 2]

## Testing

**Test Name**: [test_name]
**Test Location**: [path/to/test_file.py]
**Before Fix**: FAILED ❌
**After Fix**: PASSED ✅
**Validation**: All tests passing ✅

**Validation Tests**: [count] converted to behavioral tests, [count] deleted (implementation proven)

**Test Suite Results**:
```
[Final pytest output showing all tests passing]
```

## Follow-up Issues Created
- `refactor-[name]` - [Brief description]
- `perf-[name]` - [Brief description]

## References
- Problem Definition: [problem.md](problem.md)
- Validation Report: [validation.md](validation.md)
- Solution Review: [review.md](review.md)
- Implementation Details: [implementation.md](implementation.md)
- Testing Report: [testing.md](testing.md)

## Git Commit
**Commit Message**:
```
fix: [brief description]

[Detailed commit message]
```

**Commit Hash**: [hash]
```

### For REJECTED Issues (NOT A BUG)

```markdown
# Solution: [Issue Name] - NOT A BUG

**Status**: REJECTED ❌
**Validated**: [YYYY-MM-DD]

## Original Report Summary
[What was claimed in the bug report]

## Validation Results

**Status**: NOT A BUG ❌

**Evidence**: [Concrete evidence that code is correct]

### Why This Is Not A Bug
[Clear explanation of why the reported issue is not actually a bug]

### Contradicting Evidence
[Code snippets, tests, logic showing correct behavior]

**Example**:
```python
# Code showing correct behavior
```

## Recommendation

**Action**: CLOSE ISSUE
**Reason**: Code is working as designed, no bug exists

## References
- Problem Definition: [problem.md](problem.md)
- Validation Report: [validation.md](validation.md)
```

## Documentation Efficiency Standards

### Progressive Elaboration by Complexity

**Simple Issues** (<20 LOC, pattern-matching):
- **problem.md**: 100-150 lines
- **Minimal docs**: Focus on essentials only
- **Total workflow**: ~500 lines across all files

**Medium Issues** (20-100 LOC, some design):
- **problem.md**: 150-250 lines
- **Standard docs**: Complete but concise
- **Total workflow**: ~1000 lines across all files

**Complex Issues** (>100 LOC, multiple approaches):
- **problem.md**: 300-400 lines
- **Full docs**: Comprehensive documentation
- **Total workflow**: ~2000 lines across all files

### Eliminate Duplication

**Key Principles**:
- Each phase file is read by downstream agents
- Avoid redundant context across files
- Each agent adds NEW information only
- Focus on WHAT and WHERE, not extensive HOW in early phases

**Cross-Referencing**:
- Reference related issues instead of repeating context
- Focus on the problem, not solution details (in problem.md)
- Use surgical code examples (10-20 lines max)
- Limit solution proposals in problem.md to 1-2 sentences each

## Status Transitions

### Issue Status Flow

```
OPEN → Problem being worked on
  ↓
RESOLVED → Successfully fixed/implemented
  OR
REJECTED → Determined to be NOT A BUG
```

### File Creation Timeline

1. **problem.md** - Created by Problem Researcher (Status: OPEN)
2. **validation.md** - Created by Problem Validator
3. **review.md** - Created by Solution Reviewer (if CONFIRMED)
4. **implementation.md** - Created by Solution Implementer (if CONFIRMED)
5. **testing.md** - Created by Code Reviewer & Tester (if CONFIRMED)
6. **solution.md** - Created by Documentation Updater
7. **problem.md updated** - Status changed to RESOLVED/REJECTED
8. **All files moved** - to `archive/[issue-name]/`

## Workflow Phases Detail

### Phase 1: Problem Research
**Agent**: Problem Researcher
**Output**: `problem.md` (OPEN)
**Purpose**: Identify and define the problem with evidence

### Phase 2: Problem Validation
**Agent**: Problem Validator
**Output**: `validation.md`
**Purpose**: Confirm issue exists and create test case
**Outcome**: CONFIRMED ✅ or NOT A BUG ❌

**Special Flow for NOT A BUG**:
- Validator creates `solution.md` immediately
- Skip to Phase 7 (Documentation Updater)
- No implementation needed

### Phase 3: Solution Proposal
**Agent**: Solution Proposer
**Output**: Updates `validation.md` with proposals
**Purpose**: Research and propose 3-4 solution approaches

### Phase 4: Solution Review
**Agent**: Solution Reviewer
**Output**: `review.md`
**Purpose**: Evaluate proposals and select best approach

### Phase 5: Implementation
**Agent**: Solution Implementer
**Output**: `implementation.md` + code changes
**Purpose**: Implement the selected solution

### Phase 6: Testing & Review
**Agent**: Code Reviewer & Tester
**Output**: `testing.md`
**Purpose**: Validate implementation, run tests, find bugs

**Critical**: Process all validation tests IN PLACE
- Convert to behavioral tests OR
- Delete if implementation proven

### Phase 7: Documentation & Commit
**Agent**: Documentation Updater
**Output**: `solution.md`, updated `problem.md`, git commit
**Purpose**: Document solution and close issue

**Actions**:
- Create `solution.md` (if not already created)
- Update `problem.md` status to RESOLVED/REJECTED
- Create follow-up issues from testing.md suggestions
- Create git commit
- Move all files to `archive/[issue-name]/`

## Follow-up Issue Creation

When creating follow-up issues for refactoring opportunities:

**Naming Convention**:
- `refactor-[brief-description]`
- `perf-[brief-description]`
- `debt-[brief-description]`
- `arch-[brief-description]`

**When to Create**:
- **High Priority**: ALWAYS create follow-up issue
- **Medium Priority**: ALWAYS create follow-up issue
- **Low Priority**: Document in testing.md only

**Structure**: Follow standard problem.md format with Type: REFACTOR 🔧

## Commit Message Format

Follow conventional commit format (from python-standards):

```
<type>: <brief description>

<detailed description>
```

**Types**:
- `fix:` - Bug fixes
- `feat:` - New features
- `test:` - Test additions or changes
- `refactor:` - Code refactoring
- `docs:` - Documentation only (including issue rejections)
- `chore:` - Maintenance tasks
- `perf:` - Performance improvements

## When to Reference This Skill

Agents and users should reference this skill when they need:

- Issue directory structure and file organization
- Problem definition format and required sections
- Validation report structure
- Solution review documentation format
- Implementation documentation structure
- Testing report format
- Solution documentation (resolved/rejected)
- Status transition flows
- Documentation efficiency standards
- Workflow phase details

## Usage

Reference this skill in agents:

```markdown
For issue management patterns, documentation structures, and workflow phases, see **Skill(cxp:issue-management)**.
```

Or invoke directly:

```bash
Use cxp:issue-management skill for issue documentation format reference
```
