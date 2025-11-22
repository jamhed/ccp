---
name: issue-management
description: Issue workflow lifecycle, status markers, severity levels, and directory structure for cxp problem-solving workflow
---

# Issue Management (2025)

Defines the issue workflow lifecycle, status markers, severity levels, and directory structure for the cxp multi-phase problem-solving workflow.

## Issue Lifecycle

```
1. Problem Research → issues/[issue-name]/problem.md (Status: OPEN)
2. Problem Validation → issues/[issue-name]/validation.md
3. Solution Proposal → issues/[issue-name]/proposals.md
4. Solution Review → issues/[issue-name]/review.md
5. Implementation → issues/[issue-name]/implementation.md
6. Testing & Review → issues/[issue-name]/testing.md
7. Documentation → issues/[issue-name]/solution.md
8. Status Update → problem.md (Status: RESOLVED/REJECTED)
9. Archive → Move all files to archive/[issue-name]/
```

## Directory Structure

### Active Issues
```
<PROJECT_ROOT>/issues/[issue-name]/
├── problem.md          # Issue definition (Status: OPEN)
├── validation.md       # Problem Validator findings (optional)
├── proposals.md        # Solution Proposer proposals (optional)
├── review.md           # Solution Reviewer analysis (optional)
├── implementation.md   # Solution Implementer report (optional)
├── testing.md          # Code review and test results (optional)
└── solution.md         # Final documentation (created at end)
```

### Archived Issues
```
<PROJECT_ROOT>/archive/[issue-name]/
├── problem.md          # Original issue (Status: RESOLVED or REJECTED)
├── validation.md       # Audit trail
├── proposals.md        # Audit trail
├── review.md           # Audit trail
├── implementation.md   # Audit trail
├── testing.md          # Audit trail
└── solution.md         # Final summary
```

## Issue Naming Convention

Use descriptive kebab-case names: `[type]-[brief-description]`

**Examples**:
- `bug-async-unhandled-exception`
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

## File Naming Convention

**CRITICAL**: Always use lowercase filenames.

**Correct** ✅:
- `problem.md`
- `validation.md`
- `proposals.md`
- `review.md`
- `implementation.md`
- `testing.md`
- `solution.md`

**Incorrect** ❌:
- `Problem.md`
- `PROBLEM.md`
- `Solution.MD`

## Status Markers

### Issue Status
- **OPEN** - Active issue being worked on
- **RESOLVED** - Issue solved and verified
- **REJECTED** - Determined to be NOT A BUG

### Issue Type
- **BUG 🐛** - Defect or error in code
- **FEATURE ✨** - New functionality
- **PERFORMANCE ⚡** - Performance optimization
- **REFACTOR 🔧** - Code improvement without behavior change

### Validation Status
- **CONFIRMED ✅** - Issue validated and confirmed
- **NOT A BUG ❌** - Issue determined to be incorrect
- **PARTIALLY CORRECT ⚠️** - Some aspects valid, others not
- **NEEDS INVESTIGATION 🔍** - Requires more research
- **MISUNDERSTOOD 📝** - Issue based on misunderstanding

### Approval Status
- **APPROVED ✅** - Solution approach approved
- **NEEDS CHANGES ⚠️** - Requires modifications
- **REJECTED ❌** - Solution not acceptable

## Severity Levels (Evidence-Based)

**CRITICAL**: All severity claims require concrete evidence.

### Critical
**Evidence Required**: Crashes (stack traces), data corruption, security vulnerability (CVE)

**Examples**:
- Unhandled exception causing service crash
- SQL injection vulnerability
- Authentication bypass
- Data loss or corruption

### High
**Evidence Required**: Functional failure (failing tests), memory leak (profiling data), deadlock (thread dumps)

**Examples**:
- API endpoint returning 500 errors
- Infinite loop or resource exhaustion
- Memory leak with profiling evidence
- Broken core feature

### Medium
**Evidence Required**: Performance degradation (benchmarks), missing validation, type safety issues

**Examples**:
- N+1 queries with profiling data
- Missing error handling
- Lack of type hints on public APIs
- Inconsistent patterns

### Low
**Evidence Required**: Minor issues without functional impact

**Examples**:
- Code style inconsistencies
- Minor optimization opportunities
- Cosmetic issues
- Variable naming improvements

**Evidence Requirements**:
- ❌ Never claim "memory leak" without memory_profiler/tracemalloc output
- ❌ Never claim "performance issue" without cProfile/py-spy benchmarks
- ❌ Never claim "High/Critical severity" without reproducing the bug
- ✅ Include actual profiling data (cProfile output, memory graphs, benchmarks)
- ✅ Use concrete metrics ("3-5 second delay" not "slow", "250MB leak" not "memory issue")

**Example**:
```markdown
❌ Bad: "This causes a memory leak affecting production (High severity)"
✅ Good: "memory_profiler shows 250MB growth per 1000 iterations (attached profile.png). Extrapolated: 2.5GB/day in production (High severity)"
```

## Priority Levels (Features)

- **High** - Core functionality, blocking other work, user-facing impact
- **Medium** - Important improvements, developer experience, performance enhancements
- **Low** - Nice-to-have, optimizations, convenience features

## Workflow Phase Responsibilities

### Phase 1: Problem Research (Problem Researcher)
- **Creates**: `problem.md` (Status: OPEN)
- **Contains**: Problem definition with evidence, root cause, impact
- **Output format**: Defined by problem-researcher agent

### Phase 2: Problem Validation (Problem Validator)
- **Creates**: `validation.md`
- **Contains**: Validation status, test case, findings
- **Output format**: Defined by problem-validator agent
- **Special case**: For NOT A BUG, may create `solution.md` immediately

### Phase 3: Solution Proposal (Solution Proposer)
- **Creates**: `proposals.md`
- **Contains**: 3-4 solution approaches with analysis
- **Output format**: Defined by solution-proposer agent

### Phase 4: Solution Review (Solution Reviewer)
- **Creates**: `review.md`
- **Contains**: Solution evaluation and selection
- **Output format**: Defined by solution-reviewer agent

### Phase 5: Implementation (Solution Implementer)
- **Creates**: `implementation.md` + code changes
- **Contains**: Implementation details, code changes, patterns applied
- **Output format**: Defined by solution-implementer agent

### Phase 6: Testing & Review (Code Reviewer & Tester)
- **Creates**: `testing.md`
- **Contains**: Test results, code review, refactoring suggestions
- **Output format**: Defined by code-reviewer-tester agent

### Phase 7: Documentation & Commit (Documentation Updater)
- **Creates**: `solution.md`, updates `problem.md`
- **Contains**: Final summary, commit info
- **Output format**: Defined by documentation-updater agent
- **Actions**: Create git commit, move to archive/

## Status Transitions

### Standard Flow
```
OPEN (problem.md created)
  ↓
RESOLVED (problem.md updated after solution verified)
  ↓
Archived (all files moved to archive/[issue-name]/)
```

### NOT A BUG Flow
```
OPEN (problem.md created)
  ↓
REJECTED (validation finds NOT A BUG)
  ↓
solution.md created by validator
  ↓
problem.md updated to REJECTED
  ↓
Archived
```

## Follow-up Issue Creation

When creating follow-up issues for refactoring opportunities:

**Naming**:
- `refactor-[brief-description]`
- `perf-[brief-description]`
- `debt-[brief-description]`
- `arch-[brief-description]`

**When to Create**:
- **High Priority**: ALWAYS create follow-up issue
- **Medium Priority**: ALWAYS create follow-up issue
- **Low Priority**: Document in testing.md only

## Commit Message Format

Use conventional commit format:

```
<type>: <brief description>

<detailed description>
```

**Types**:
- `fix:` - Bug fixes
- `feat:` - New features
- `test:` - Test additions or changes
- `refactor:` - Code refactoring
- `docs:` - Documentation only
- `chore:` - Maintenance tasks
- `perf:` - Performance improvements

## Documentation Efficiency Standards

### Progressive Elaboration by Complexity

**Simple Issues** (<20 LOC, pattern-matching):
- Target: ~500 lines total across all workflow files
- Keep documentation concise

**Medium Issues** (20-100 LOC, some design):
- Target: ~1000 lines total across all workflow files
- Standard documentation depth

**Complex Issues** (>100 LOC, multiple approaches):
- Target: ~2000 lines total across all workflow files
- Comprehensive documentation

### Duplication Elimination

**Key Principles**:
- Each phase file is read by downstream agents
- Avoid redundant context across files
- Each agent adds NEW information only
- Reference previous files instead of repeating content

## When to Reference This Skill

Agents and users should reference this skill when they need:

- Issue lifecycle and workflow phases
- Directory structure for issues and archives
- File naming conventions for issue documentation
- Status marker definitions
- Severity and priority level guidance
- Commit message format
- Follow-up issue patterns

**Note**: For specific documentation formats (problem.md, solution.md, etc.), each agent defines its own output format.

## Usage

Reference this skill in agents:

```markdown
For issue management patterns, status markers, severity levels, and workflow phases, see **Skill(cxp:issue-management)**.
```

Or invoke directly:

```bash
Use cxp:issue-management skill for issue workflow and lifecycle reference
```
