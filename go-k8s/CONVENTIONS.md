# Agent Conventions & Standards

Common conventions used across all go-k8s agents.

## File Naming

**Always use lowercase filenames**:
- `problem.md` ✅
- `solution.md` ✅
- `validation.md` ✅
- `review.md` ✅
- `implementation.md` ✅
- `testing.md` ✅

**Never use**:
- `Problem.md` ❌
- `PROBLEM.md` ❌
- `Solution.MD` ❌

## Directory Structure

All issue-related files reside in:
```
<PROJECT_ROOT>/issues/[issue-name]/
├── problem.md          # Issue definition
├── validation.md       # Problem Validator findings (audit trail)
├── review.md           # Solution Reviewer analysis (audit trail)
├── implementation.md   # Solution Implementer report (audit trail)
├── testing.md          # Code review and test results (audit trail)
└── solution.md         # Final documentation (summary)
```

**`<PROJECT_ROOT>`**: Git repository root directory

## Status Markers

### Issue Status
- `OPEN` - Issue needs work
- `RESOLVED` - Issue fixed/implemented and committed
- `REJECTED` - Issue determined to be invalid (NOT A BUG)

### Validation Status
- `CONFIRMED ✅` - Bug verified or feature requirements clear
- `NOT A BUG ❌` - Reported bug is incorrect
- `PARTIALLY CORRECT ⚠️` - Some aspects correct, report misleading
- `NEEDS INVESTIGATION 🔍` - Cannot confirm without runtime testing
- `MISUNDERSTOOD 📝` - Reporter misunderstood code/requirements

### Approval Status
- `APPROVED ✅` - Ready to proceed
- `NEEDS CHANGES ⚠️` - Requires modifications
- `REJECTED ❌` - Not acceptable

## Issue Type Markers

- `BUG 🐛` - Defect or incorrect behavior
- `FEATURE ✨` - New functionality or enhancement

## Severity Levels (Bugs)

- **High** - Crashes, data loss, security issues, critical functionality broken
- **Medium** - Important features impaired, workarounds exist
- **Low** - Minor issues, cosmetic problems, edge cases

## Priority Levels (Features)

- **High** - Core functionality, blocking other work, customer commitments
- **Medium** - Important improvements, performance enhancements
- **Low** - Nice-to-have, optimizations, convenience features

## Commit Message Prefixes

Follow conventional commit format:
- `fix:` - Bug fixes
- `feat:` - New features
- `test:` - Test additions or changes
- `refactor:` - Code refactoring
- `docs:` - Documentation only (including issue rejections)
- `chore:` - Maintenance tasks

## Common Tools

- **Read** - Read files
- **Write** - Create new files
- **Edit** - Modify existing files
- **Bash** - Execute commands (git, go test, chainsaw, make, etc.)
- **Glob** - Find files by pattern
- **Grep** - Search file contents
- **Task** - Launch specialized agents
- **TodoWrite** - Track progress through phases

## Common Skills

- **Skill(go-k8s:go-dev)** - Go development expertise, modern idioms, best practices
- **Skill(go-k8s:chainsaw-tester)** - E2E Chainsaw test creation and debugging
- **Skill(go-k8s:github-cicd)** - CI/CD pipeline configuration
- **Skill(go-k8s:web-doc)** - Fetch and cache web documentation
- **Skill(go-k8s:issue-manager)** - Manage issues folder

## Progress Tracking

All agents should use TodoWrite to track progress:
- Mark tasks as `in_progress` before starting
- Mark as `completed` immediately upon finishing
- Keep exactly ONE task `in_progress` at a time
- Update todos in real-time, don't batch completions
