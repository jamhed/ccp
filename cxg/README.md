# cxg Plugin - Go & Kubernetes Development

Comprehensive toolkit for modern Go 1.23+ and Kubernetes operator development with specialized skills, agents, and commands for building production-ready applications.

## Skills

- **go-dev**: Expert Go development assistant covering modern Go 1.23+ idioms (generics, fail-early patterns, cmp.Or defaults), error handling with %w wrapping, and Kubernetes operator patterns
- **chainsaw-tester**: E2E testing expert for Kubernetes operators using Chainsaw, JP assertions, webhook validation, and mock services
- **github-cicd**: CI/CD pipeline specialist for GitHub Actions workflows, Docker builds, semantic versioning, and Kubernetes deployments
- **issue-manager**: Manage project issues in the issues folder. List open issues, archive solved issues, and refine problem definitions
- **web-doc**: Fetches and caches technical documentation locally in `docs/web/` for offline reference

## Agents

Multi-phase problem-solving workflow agents (see [agents/README.md](agents/README.md) for details):

- **Problem Researcher**: Researches Go codebases to identify bugs, performance issues, and feature requirements
- **Problem Validator**: Validates issues, proposes solution approaches, and develops test cases
- **Solution Reviewer**: Critically evaluates solutions and selects optimal approach
- **Solution Implementer**: Implements fixes using modern Go best practices
- **Code Reviewer & Tester**: Reviews code quality, runs linters and tests
- **Documentation Updater**: Creates solution documentation and git commits

## Commands

All commands are scoped to the plugin and should be invoked as `/cxg:command`.

### /cxg:problem [description]

Research and define a new problem using the Problem Researcher agent.

**Usage**: `/cxg:problem [brief description of the issue]`

**What it does**:
- Analyzes the Go codebase to identify the root cause
- Gathers evidence with file paths and line numbers
- Creates a structured problem.md file in issues/[issue-name]/
- Documents context, follow-up actions, and acceptance criteria

**Example**: `/cxg:problem telemetry spans exceeding attribute limits`

### /cxg:refine [issue-name]

Refine an existing problem definition using the Problem Researcher agent.

**Usage**: `/cxg:refine [issue-name]`

**What it does**:
- Re-analyzes the issue in issues/[issue-name]/problem.md
- Updates evidence and clarifies requirements
- Improves acceptance criteria
- Ensures problem is well-defined before solving

**Example**: `/cxg:refine bug-telemetry-nested-attribute-limit`

### /cxg:solve [issue-name]

Orchestrates the complete problem-solving workflow from validation through implementation to documentation.

**Usage**: `/cxg:solve [issue-name]`

**What it does**:
Executes all agents in sequence for issues/[issue-name]/problem.md:

1. **Problem Validator** - Validates issue and proposes solutions (creates validation.md)
   - If "NOT A BUG": creates solution.md and skips to step 5
   - If confirmed: continues to step 2
2. **Solution Reviewer** - Evaluates approaches and selects best one (creates review.md)
3. **Solution Implementer** - Implements the fix (creates implementation.md)
4. **Code Reviewer & Tester** - Reviews code and runs tests (creates testing.md)
5. **Documentation Updater** - Creates solution.md summary and commits changes

Each agent creates an audit trail file documenting its phase, providing complete traceability from problem to solution.

**Example**: `/cxg:solve bug-telemetry-nested-attribute-limit`

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
├── .opencode           # Marker file (empty)
└── .codex              # Review marker (empty)
```

Each agent in the workflow creates an audit trail file documenting its phase, providing complete traceability from problem to solution.

### Workflow Files Reference

Each file in the workflow provides comprehensive documentation for that phase:

#### problem.md

- Title and summary
- Context and background
- Evidence with file paths and line numbers
- Follow-up actions required
- Acceptance criteria for completion

#### validation.md

- Feature validation status (confirmed/rejected)
- Issue type classification (bug/feature/refactor)
- Feasibility assessment (high/medium/low)
- Implementation complexity analysis
- Integration points and dependencies
- Validation evidence (code references, test results)
- Requirements clarity assessment
- Additional considerations
- Multiple proposed approaches (A, B, C)
- Pros and cons for each approach
- Solution comparison table

#### review.md

- Complexity assessment per approach
- Risk analysis per approach
- Effort estimation
- Recommendation with justification
- Key decision factors

#### implementation.md

- Files modified/created with change descriptions
- Code changes with before/after snippets
- Design patterns and rationale
- Edge cases handled
- Implementation decisions explained

#### testing.md

- Test case creation and validation
- Unit test results
- E2E test results (Chainsaw for Kubernetes operators)
- Linting results (golangci-lint)
- Code review findings
- Quality metrics assessment
- Improvements made during review
- Regression risk analysis

#### solution.md

- Problem summary
- Solution approach selected
- Implementation details overview
- Code changes summary
- Testing results summary
- Related issues
- Commit information
- Next steps (if applicable)

## Go Best Practices Covered

### Modern Go 1.23+
- **Generics**: Type-safe collections and algorithms
- **Fail-early patterns**: Guard clauses, early returns
- **cmp.Or**: Default value handling for zero values
- **Error wrapping**: `fmt.Errorf("context: %w", err)` for error chains
- **Context propagation**: Pass context.Context for cancellation

### Kubernetes Operator Patterns
- **Controller-runtime**: Reconciliation loops, predicates, watches
- **Custom Resources**: CRD definitions, validation, defaulting
- **Webhooks**: Admission control, mutation, validation
- **Error handling**: Requeue strategies, transient vs permanent errors
- **Testing**: Envtest for integration, Chainsaw for E2E

### Code Quality
- **Linting**: golangci-lint with comprehensive rules
- **Testing**: Table-driven tests, test fixtures
- **Error messages**: Clear, actionable, with context
- **Naming**: Idiomatic Go conventions
- **Documentation**: Package-level docs, exported symbols

### Anti-Patterns to Avoid
- panic() in production code
- Ignored errors
- Nested conditions (prefer guard clauses)
- Defensive nil checks on non-pointers
- String concatenation for errors
- time.Sleep() in controllers (use RequeueAfter)

## Installation

```sh
# Add marketplace
/plugin marketplace add jamhed/ccp

# Install cxg plugin
/plugin install cxg@ccp
```

After installation, check your `~/.claude/plugins/marketplace` folder. To update agents, pull latest changes and restart Claude.

## Example Workflow

### 1. Identify a Problem
```
/cxg:problem telemetry spans exceeding attribute limits in nested structures
```

**Result**: Creates `issues/bug-telemetry-nested-attribute-limit/problem.md` with:
- Root cause analysis
- Evidence (file paths, line numbers)
- Impact assessment
- Recommended fix approach

### 2. Solve the Problem
```
/cxg:solve bug-telemetry-nested-attribute-limit
```

**Result**: Executes full workflow:
- Validates the problem exists
- Proposes multiple solutions (A: limit depth, B: flatten attributes, C: skip large spans)
- Selects best approach (A: limit depth for backward compatibility)
- Implements the fix with error wrapping
- Runs tests: go test, chainsaw, golangci-lint
- Creates git commit with documentation

**Files created in archive/bug-telemetry-nested-attribute-limit/**:
- `problem.md` - Original issue
- `validation.md` - Validation and proposed solutions
- `review.md` - Solution selection and rationale
- `implementation.md` - Code changes with before/after
- `testing.md` - Test results, linting, E2E validation
- `solution.md` - Summary documentation

### 3. Archive
Issue automatically moved to `archive/bug-telemetry-nested-attribute-limit/` with all audit trail files.

## Skill Usage

### Go Development
```
Use the cxg:go-dev skill to help me review this controller for fail-early patterns.
```

### E2E Testing
```
Use the cxg:chainsaw-tester skill to help me debug this webhook validation test.
```

### GitHub CI/CD
```
Use the cxg:github-cicd skill to help me set up semantic versioning for releases.
```

## Differences from cxp Plugin

While `cxp` focuses on Python development, `cxg` specializes in:

| Feature | cxg (Go/K8s) | cxp (Python) |
|---------|-------------|--------------|
| **Language** | Go 1.23+ | Python 3.14+ |
| **Package Manager** | go mod | UV (10-100x faster than pip) |
| **Type System** | Generics, interfaces | Type hints, Protocol, generics |
| **Async** | Goroutines, channels | async/await, asyncio |
| **Web Frameworks** | Kubernetes operators | FastAPI, Django, Flask |
| **Testing** | go test, Chainsaw E2E | pytest, pytest-asyncio |
| **Linting** | golangci-lint | ruff (check + format) |
| **Type Checking** | go vet | pyright |
| **Error Handling** | Error wrapping with %w | Exception chaining with `from` |
| **Data Validation** | Custom validation | Pydantic models |

## Contributing

This plugin is part of the Claude Code Plugin Collection (ccp). Contributions welcome at https://github.com/jamhed/ccp
