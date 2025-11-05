# cxp Plugin - Modern Python Development

Comprehensive toolkit for modern Python development (Python 3.11+) with specialized skills, agents, and commands for building high-quality Python applications.

## Skills

- **python-dev**: Expert Python development assistant covering modern Python 3.11+ idioms, type safety, async patterns, and idiomatic error handling
- **pytest-tester**: Testing expert for writing, debugging, and reviewing pytest tests with fixtures, parametrize, mocks, and async testing
- **fastapi-dev**: FastAPI specialist for API design, dependency injection, async patterns, middleware, and comprehensive testing
- **issue-manager**: Manage project issues in the issues folder. List open issues, archive solved issues, and refine problem definitions
- **web-doc**: Fetches and caches technical documentation locally in `docs/web/` for offline reference

## Agents

Multi-phase problem-solving workflow agents:

- **Problem Researcher**: Researches Python codebases to identify bugs, performance issues, and feature requirements
- **Problem Validator**: Validates issues, proposes solution approaches, and develops test cases
- **Solution Reviewer**: Critically evaluates solutions and selects optimal approach
- **Solution Implementer**: Implements fixes using modern Python best practices
- **Code Reviewer & Tester**: Reviews code quality, runs linters, type checkers, and tests
- **Documentation Updater**: Creates solution documentation and git commits

## Commands

All commands are scoped to the plugin and should be invoked as `/cxp:command`.

### /cxp:problem [description]

Research and define a new problem using the Problem Researcher agent.

**Usage**: `/cxp:problem [brief description of the issue]`

**What it does**:
- Analyzes the codebase to identify the root cause
- Gathers evidence with file paths and line numbers
- Searches for existing packages/libraries that could help
- Creates a structured problem.md file in issues/[issue-name]/
- Documents context, follow-up actions, and acceptance criteria

**Example**: `/cxp:problem async exception handling in user creation endpoint`

### /cxp:refine [issue-name]

Refine an existing problem definition using the Problem Researcher agent.

**Usage**: `/cxp:refine [issue-name]`

**What it does**:
- Re-analyzes the issue in issues/[issue-name]/problem.md
- Updates evidence and clarifies requirements
- Improves acceptance criteria
- Ensures problem is well-defined before solving

**Example**: `/cxp:refine bug-async-unhandled-exception`

### /cxp:solve [issue-name]

Orchestrates the complete problem-solving workflow from validation through implementation to documentation.

**Usage**: `/cxp:solve [issue-name]`

**What it does**:
Executes all agents in sequence for issues/[issue-name]/problem.md:

1. **Problem Validator** - Validates issue and proposes solutions (creates validation.md)
   - If "NOT A BUG": creates solution.md and skips to step 5
   - If confirmed: continues to step 2
2. **Solution Reviewer** - Evaluates approaches and selects best one (creates review.md)
3. **Solution Implementer** - Implements the fix (creates implementation.md)
4. **Code Reviewer & Tester** - Reviews code, runs linters, type checkers, and tests (creates testing.md)
5. **Documentation Updater** - Creates solution.md summary and commits changes

Each agent creates an audit trail file documenting its phase, providing complete traceability from problem to solution.

**Example**: `/cxp:solve bug-async-unhandled-exception`

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
└── solution.md         # Final documentation (summary)
```

Each agent in the workflow creates an audit trail file documenting its phase, providing complete traceability from problem to solution.

## Python Best Practices Covered

### Modern Python (3.11+)
- Type hints with generics, Protocol, TypeVar
- Pattern matching with `match`/`case`
- Type unions with `|` instead of `Union`
- ExceptionGroup for multiple errors (3.11+)
- Self type for returning instances (3.11+)
- @override decorator (3.12+)

### Type Safety
- Comprehensive type hints
- Avoiding `Any` without justification
- Proper use of Optional, Union, generics
- Type narrowing and guards
- Protocol for structural subtyping

### Async Patterns
- Proper async/await usage
- No blocking calls in async functions
- Task lifecycle management
- Proper cancellation handling
- AsyncIO best practices

### Error Handling
- Specific exception types (not bare `except:`)
- Exception chaining with `from`
- Custom exceptions with proper inheritance
- Clear error messages
- No silent failures

### Testing with Pytest
- Fixtures for setup/teardown
- Parametrize for multiple scenarios
- Mocking external dependencies
- Async testing with pytest-asyncio
- Coverage analysis (>80% target)

### FastAPI Development
- Pydantic models for validation
- Dependency injection
- Proper async route handlers
- Error handling with HTTPException
- Background tasks
- Middleware and CORS
- Authentication/authorization

### Code Quality
- Linting with ruff, black, isort
- Type checking with mypy/pyright
- Security scanning with bandit, safety
- PEP 8 compliance
- Clear naming and focused functions

## Installation

```sh
# Add marketplace
/plugin marketplace add jamhed/ccp

# Install cxp plugin
/plugin install cxp@ccp
```

After installation, check your `~/.claude/plugins/marketplace` folder. To update agents, pull latest changes and restart Claude.

## Example Workflow

### 1. Identify a Problem
```
/cxp:problem async user creation handler doesn't handle validation errors properly
```

**Result**: Creates `issues/bug-async-validation-error/problem.md` with:
- Root cause analysis
- Evidence (file paths, line numbers)
- Impact assessment
- Researched third-party solutions (Pydantic, FastAPI patterns)
- Recommended fix approach

### 2. Solve the Problem
```
/cxp:solve bug-async-validation-error
```

**Result**: Executes full workflow:
- Validates the problem exists
- Proposes multiple solutions (A: HTTPException, B: custom middleware, C: Pydantic validator)
- Selects best approach (A: HTTPException for simplicity)
- Implements the fix with type hints
- Runs tests: pytest, mypy, ruff, black
- Creates git commit with documentation

**Files created in archive/bug-async-validation-error/**:
- `problem.md` - Original issue
- `validation.md` - Validation and proposed solutions
- `review.md` - Solution selection and rationale
- `implementation.md` - Code changes with before/after
- `testing.md` - Test results, linting, type checking
- `solution.md` - Summary documentation

### 3. Archive
Issue automatically moved to `archive/bug-async-validation-error/` with all audit trail files.

## Skill Usage

### Python Development
```
Use the cxp:python-dev skill to help me review this code for type safety issues.
```

### Testing
```
Use the cxp:pytest-tester skill to help me write tests for the user service.
```

### FastAPI Development
```
Use the cxp:fastapi-dev skill to help me design a REST API for user management.
```

## Differences from cx Plugin

While `cx` focuses on Go and Kubernetes operator development, `cxp` specializes in:

| Feature | cx (Go/K8s) | cxp (Python) |
|---------|-------------|--------------|
| **Language** | Go 1.23+ | Python 3.11+ |
| **Type System** | Generics, interfaces | Type hints, Protocol, generics |
| **Async** | Goroutines, channels | async/await, asyncio |
| **Web Frameworks** | Kubernetes operators | FastAPI, Django, Flask |
| **Testing** | go test, Chainsaw E2E | pytest, pytest-asyncio |
| **Linting** | golangci-lint | ruff, black, isort, mypy |
| **Error Handling** | Error wrapping with %w | Exception chaining with `from` |
| **Data Validation** | Custom validation | Pydantic models |

## Contributing

This plugin is part of the Claude Code Plugin Collection (ccp). Contributions welcome at https://github.com/jamhed/ccp
