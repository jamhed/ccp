# Claude Code Plugin Collection

Custom Claude Code plugins for Go and Kubernetes development workflows.

## go-k8s Plugin

Comprehensive toolkit for Go 1.23+ and Kubernetes operator development with specialized skills, agents, and commands.

### Skills

- **go-dev**: Expert Go development assistant covering modern Go 1.23+ idioms, fail-early patterns, error handling, and Kubernetes operator patterns
- **chainsaw-tester**: E2E testing expert for Kubernetes operators using Chainsaw, JP assertions, webhook validation, and mock services
- **github-cicd**: CI/CD pipeline specialist for GitHub Actions workflows, Docker builds, semantic versioning, and Kubernetes deployments
- **web-doc**: Fetches and caches technical documentation locally in `docs/web/` for offline reference

### Agents

Multi-phase problem-solving workflow agents:

- **Problem Validator**: Validates issues, proposes solution approaches, and develops test cases
- **Solution Reviewer**: Critically evaluates solutions and selects optimal approach
- **Solution Implementer**: Implements fixes using modern Go best practices
- **Code Reviewer & Tester**: Reviews code quality, runs linters and tests
- **Documentation Updater**: Creates solution documentation and git commits

### Commands

- **/solve**: Orchestrates the complete problem-solving workflow from validation through implementation to documentation

## Issue Management System

The plugin uses a comprehensive issue tracking system with active and archived issues. Issues are located in your project's `issues/` directory, with solved issues moved to `archive/`.

### Issue Lifecycle

#### Active Issues
```
issues/[issue-name]/
└── problem.md          # Issue definition (Status: OPEN)
```

#### Archived (Solved) Issues
```
archive/[issue-name]/
├── problem.md          # Original issue (Status: RESOLVED)
├── validation.md       # Problem Validator findings (audit trail)
├── review.md           # Solution Reviewer analysis (audit trail)
├── implementation.md   # Solution Implementer report (audit trail)
├── testing.md          # Code review and test results (audit trail)
├── solution.md         # Final documentation (summary)
├── visited             # Marker file (empty)
└── .codex-reviewed     # Review marker (empty)
```

Each agent in the workflow creates an audit trail file documenting its phase, providing complete traceability from problem to solution.

### Workflow Files Reference

Each file in the workflow provides comprehensive documentation for that phase:

#### problem.md
**Created By**: Manual/Problem Researcher Agent
**Purpose**: Issue definition with evidence and acceptance criteria

**Contents**:
- Title and summary
- Context and background
- Evidence with file paths and line numbers
- Follow-up actions required
- Acceptance criteria for completion

#### validation.md
**Created By**: Problem Validator Agent
**Purpose**: Confirms the problem exists, assesses feasibility, validates requirements

**Contents**:
- Feature validation status (confirmed/rejected)
- Issue type classification (bug/feature/refactor)
- Feasibility assessment (high/medium/low)
- Implementation complexity analysis
- Integration points and dependencies
- Validation evidence (code references, test results)
- Requirements clarity assessment
- Additional considerations

#### review.md
**Created By**: Solution Reviewer Agent
**Purpose**: Evaluates 2-3 solution approaches, selects best one, explains tradeoffs

**Contents**:
- Multiple proposed approaches (A, B, C)
- Pros and cons for each approach
- Complexity assessment per approach
- Risk analysis per approach
- Effort estimation
- Solution comparison table
- Recommendation with justification
- Key decision factors

#### implementation.md
**Created By**: Solution Implementer Agent
**Purpose**: Documents code changes, patterns used, rationale for each change

**Contents**:
- Files modified/created with change descriptions
- Code changes with before/after snippets
- Modern Go patterns applied (if applicable)
- Design patterns and rationale
- Edge cases handled
- Implementation decisions explained

#### testing.md
**Created By**: Code Reviewer & Tester Agent
**Purpose**: Test results, linting, coverage analysis, quality metrics

**Contents**:
- Test case creation and validation
- Unit test results
- E2E test results (if applicable)
- Linting results
- Code review findings
- Quality metrics assessment
- Improvements made during review
- Regression risk analysis

#### solution.md
**Created By**: Documentation Updater Agent
**Purpose**: Executive summary of the entire workflow with commit info

**Contents**:
- Problem summary
- Solution approach selected
- Implementation details overview
- Code changes summary
- Testing results summary
- Related issues
- Commit information
- Next steps (if applicable)

### problem.md Format

**For Active Issues:**
```markdown
Title: [Brief title]
Summary: [One-line summary]
Context: [Background and context]
Evidence: [Code references with file:line numbers]
Follow-up Actions: [What needs to be done]
Acceptance Criteria: [Definition of done]
```

**For Archived Issues:**
```markdown
**Status**: RESOLVED
**Resolved**: YYYY-MM-DD - See solution.md
**Severity**: [High|Medium|Low]
**Location**: [source file path]
**Impact**: [description]

## Problem Description
[Detailed description of the issue]

## Recommended Fix
[Optional: suggested approach]
```

### solution.md (Auto-generated)

Created by the Documentation Updater agent with:
- Problem Summary
- Solution Approach (selected from alternatives)
- Implementation Details
- Code Changes (files modified)
- Testing Results (unit tests, E2E tests, linting)
- Build Status
- Related Issues
- Commit Information

### Archived Issue Examples

**Simple Bug Fix** (`telemetry-required-parsing-inconsistent`):
- Fixed environment variable parsing inconsistency
- Changed literal string comparison to use `strconv.ParseBool`
- Added comprehensive test coverage for all boolean formats
- 6 workflow files documenting complete solution

**Complex Test Coverage** (`mcp-e2e-coverage-gaps`):
- Identified 31 missing E2E test scenarios
- Proposed 5-week phased implementation plan
- Created mock server infrastructure for error testing
- Implemented first critical gap test
- Comprehensive documentation with traceability matrix

## Install and update

```sh
# add marketplace
/plugin marketplace add jamhed/ccp

# install go-k8s plugin
/plugin install go-k8s@ccp
```

After that just check your `~/.claude/plugins/marketplace` folder, to update agents pull and restart Claude.


