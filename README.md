# Claude Code Plugin Collection

Custom Claude Code plugins for modern software development workflows.

## Available Plugins

### cx Plugin - Go & Kubernetes Development

Comprehensive toolkit for Go 1.23+ and Kubernetes operator development with specialized skills, agents, and commands.

### cxp Plugin - Modern Python Development

Comprehensive toolkit for Python 3.11+ development with specialized skills, agents, and commands for building high-quality Python applications.

## cx Plugin

Comprehensive toolkit for Go 1.23+ and Kubernetes operator development with specialized skills, agents, and commands.

### Skills

- **go-dev**: Expert Go development assistant covering modern Go 1.23+ idioms, fail-early patterns, error handling, and Kubernetes operator patterns
- **chainsaw-tester**: E2E testing expert for Kubernetes operators using Chainsaw, JP assertions, webhook validation, and mock services
- **github-cicd**: CI/CD pipeline specialist for GitHub Actions workflows, Docker builds, semantic versioning, and Kubernetes deployments
- **issue-manager**: Manage project issues in the issues folder. List open issues, archive solved issues, and refine problem definitions
- **web-doc**: Fetches and caches technical documentation locally in `docs/web/` for offline reference

### Agents

Multi-phase problem-solving workflow agents:

- **Problem Validator**: Validates issues, proposes solution approaches, and develops test cases
- **Solution Reviewer**: Critically evaluates solutions and selects optimal approach
- **Solution Implementer**: Implements fixes using modern Go best practices
- **Code Reviewer & Tester**: Reviews code quality, runs linters and tests
- **Documentation Updater**: Creates solution documentation and git commits

### Commands

All commands are scoped to the plugin and should be invoked as `/cx:command`.

#### /cx:problem [description]

Research and define a new problem using the Problem Researcher agent.

**Usage**: `/cx:problem [brief description of the issue]`

**What it does**:
- Analyzes the codebase to identify the root cause
- Gathers evidence with file paths and line numbers
- Creates a structured problem.md file in issues/[issue-name]/
- Documents context, follow-up actions, and acceptance criteria

**Example**: `/cx:problem telemetry spans exceeding attribute limits`

#### /cx:refine [issue-name]

Refine an existing problem definition using the Problem Researcher agent.

**Usage**: `/cx:refine [issue-name]`

**What it does**:
- Re-analyzes the issue in issues/[issue-name]/problem.md
- Updates evidence and clarifies requirements
- Improves acceptance criteria
- Ensures problem is well-defined before solving

**Example**: `/cx:refine bug-telemetry-nested-attribute-limit`

#### /cx:solve [issue-name]

Orchestrates the complete problem-solving workflow from validation through implementation to documentation.

**Usage**: `/cx:solve [issue-name]`

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

**Example**: `/cx:solve bug-telemetry-nested-attribute-limit`

### Scripts

Helper scripts for batch operations:

- **scripts/solve_unsolved_issues.sh**: Batch solver that processes all unsolved issues (issues with problem.md but no solution.md) sequentially using the `/cx:solve` workflow

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
- E2E test results (if applicable)
- Linting results
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

## cxp Plugin

Comprehensive toolkit for modern Python 3.11+ development with specialized skills, agents, and commands for building high-quality Python applications.

### Skills

- **python-dev**: Expert Python development assistant covering modern Python 3.11+ idioms, type safety, async patterns, and idiomatic error handling
- **pytest-tester**: Testing expert for writing, debugging, and reviewing pytest tests with fixtures, parametrize, mocks, and async testing
- **fastapi-dev**: FastAPI specialist for API design, dependency injection, async patterns, middleware, and comprehensive testing
- **issue-manager**: Manage project issues in the issues folder. List open issues, archive solved issues, and refine problem definitions
- **web-doc**: Fetches and caches technical documentation locally in `docs/web/` for offline reference

### Agents

Multi-phase problem-solving workflow agents for Python projects:

- **Problem Researcher**: Researches Python codebases to identify bugs, performance issues, and feature requirements
- **Problem Validator**: Validates issues, proposes solution approaches, and develops test cases
- **Solution Reviewer**: Critically evaluates solutions and selects optimal approach
- **Solution Implementer**: Implements fixes using modern Python best practices
- **Code Reviewer & Tester**: Reviews code quality, runs linters, type checkers (pyright), and tests (pytest)
- **Documentation Updater**: Creates solution documentation and git commits

### Commands

All commands are scoped to the plugin and should be invoked as `/cxp:command`.

#### /cxp:problem [description]

Research and define a new problem using the Problem Researcher agent for Python projects.

**Usage**: `/cxp:problem [brief description of the issue]`

**What it does**:
- Analyzes the Python codebase to identify the root cause
- Searches for existing Python packages/libraries that could help
- Gathers evidence with file paths and line numbers
- Creates a structured problem.md file in issues/[issue-name]/
- Documents context, third-party solutions, and acceptance criteria

**Example**: `/cxp:problem async exception handling in user creation endpoint`

#### /cxp:refine [issue-name]

Refine an existing problem definition using the Problem Researcher agent.

**Usage**: `/cxp:refine [issue-name]`

**Example**: `/cxp:refine bug-async-unhandled-exception`

#### /cxp:solve [issue-name]

Orchestrates the complete problem-solving workflow for Python projects from validation through implementation to documentation.

**Usage**: `/cxp:solve [issue-name]`

**What it does**:
Executes all agents in sequence for issues/[issue-name]/problem.md:

1. **Problem Validator** - Validates issue and proposes Python-specific solutions (creates validation.md)
2. **Solution Reviewer** - Evaluates approaches and selects best one (creates review.md)
3. **Solution Implementer** - Implements the fix using modern Python best practices (creates implementation.md)
4. **Code Reviewer & Tester** - Reviews code, runs linters (ruff check + format), type checkers (pyright), and tests (pytest) (creates testing.md)
5. **Documentation Updater** - Creates solution.md summary and commits changes

**Example**: `/cxp:solve bug-async-unhandled-exception`

### Python Best Practices Covered

- **Package Management**: UV for fast package management (10-100x faster than pip), lock files
- **Modern Python 3.11+**: Type hints, pattern matching, ExceptionGroup, Self type, @override
- **Type Safety**: Comprehensive type hints, avoiding Any, Protocol, generics
- **Async Patterns**: Proper async/await, no blocking in async, task management
- **Error Handling**: Specific exceptions, chaining with `from`, clear messages
- **Testing**: pytest, fixtures, parametrize, mocks, pytest-asyncio, >80% coverage
- **FastAPI**: Pydantic models, dependency injection, async routes, HTTPException
- **Code Quality**: ruff (check + format), pyright, bandit, safety

See [cxp/README.md](cxp/README.md) for complete documentation.

## Install and update

```sh
# add marketplace
/plugin marketplace add jamhed/ccp

# install cx plugin (Go/Kubernetes)
/plugin install cx@ccp

# install cxp plugin (Python)
/plugin install cxp@ccp
```

After that just check your `~/.claude/plugins/marketplace` folder, to update agents pull and restart Claude.


