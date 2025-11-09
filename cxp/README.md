# cxp Plugin - Modern Python Development

Comprehensive toolkit for modern Python development (Python 3.14+) with specialized skills, agents, and commands for building high-quality Python applications. Includes support for JIT compilation, enhanced pattern matching, TypedDict for **kwargs, and improved async/await.

## Skills

- **python-dev**: Expert Python development assistant covering modern Python 3.14+ idioms (JIT, enhanced patterns, TypedDict **kwargs), type safety, async patterns, and idiomatic error handling
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

Standalone code quality agents:

- **Code Quality Reviewer**: Reviews Python code as a senior developer to identify refactoring opportunities, code duplication, complexity issues, and modern Python 3.14+ best practice improvements
- **Bug Hunter**: Critically reviews code to identify potential bugs, security vulnerabilities, performance bottlenecks, async issues, and edge cases

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

### /cxp:review [scope]

Analyze code quality and create refactoring issues ready for the `/cxp:solve` workflow.

**Usage**: `/cxp:review [file-path | module-name | "all"]`

**What it does**:
1. **Analyzes code** for refactoring opportunities:
   - Code duplication (repeated logic across files)
   - God classes/functions (complexity, SRP violations)
   - Architecture issues (tight coupling, missing patterns)
   - Type safety gaps (missing type hints on public APIs)
   - Performance issues (N+1 queries, with profiling evidence)
   - Modern Python 3.14+ upgrade opportunities

2. **Creates individual issues** in `issues/` folder:
   - Each issue is a focused, actionable refactoring opportunity
   - Includes clear problem statement with evidence (LOC, complexity scores, duplication count)
   - Prioritized by impact and effort (High/Medium/Low)
   - Ready for `/cxp:solve [issue-name]` workflow

3. **Generates summary report**:
   - Lists all created issues with priorities and categories
   - Identifies "quick wins" (high impact, low effort)
   - Provides recommended execution order
   - Estimates total impact if all issues are resolved

**Examples**:
- `/cxp:review services/user` - Review the user service module
- `/cxp:review app/api/handlers.py` - Review specific file
- `/cxp:review all` - Review entire codebase

**Output**:
- `issues/refactor-[name]/problem.md` - Individual refactoring issues (ready for `/cxp:solve`)
- `code-review-summary-[timestamp].md` - Summary report with all findings and recommendations

**Example Workflow**:
```bash
# 1. Review code
/cxp:review services/user

# Output: Created 5 issues
# - refactor-split-user-service-god-class (High priority)
# - refactor-extract-validation-logic (High priority - Quick Win!)
# - refactor-add-type-hints-user-module (Medium priority)
# - refactor-introduce-repository-pattern (Medium priority)
# - refactor-use-dataclasses-user-models (Low priority)

# 2. Start with quick wins
/cxp:solve refactor-extract-validation-logic

# 3. Tackle high priority issues
/cxp:solve refactor-split-user-service-god-class

# 4. Continue with remaining issues as capacity allows
```

### /cxp:audit [scope]

Critical security and bug audit to identify vulnerabilities, potential bugs, and performance issues.

**Usage**: `/cxp:audit [file-path | module-name | "critical" | "all"]`

**What it does**:
1. **Security scanning**:
   - Injection vulnerabilities (SQL, command, path traversal, XSS)
   - Authentication/authorization bypasses
   - Hardcoded secrets, weak cryptography
   - Insecure deserialization

2. **Bug detection**:
   - Logic errors (off-by-one, wrong operators, incorrect algorithms)
   - Edge cases (None checks, division by zero, index out of bounds)
   - Type safety issues (runtime type errors)
   - Error handling gaps (unhandled exceptions, silent failures)

3. **Performance analysis** (with profiling evidence):
   - N+1 query patterns
   - Memory leaks (with profiling data)
   - Blocking calls in async code
   - CPU bottlenecks

4. **Async/concurrency issues**:
   - Blocking I/O in async functions
   - Missing await statements
   - Race conditions, deadlocks
   - Task management issues

5. **Creates individual issues** in `issues/` folder:
   - Prioritized by severity (Critical/High/Medium/Low)
   - Includes evidence (tool output, profiling, reproduction steps)
   - Ready for `/cxp:solve [issue-name]` workflow

**Examples**:
- `/cxp:audit auth` - Audit authentication module for security issues
- `/cxp:audit app/api/handlers.py` - Audit specific file
- `/cxp:audit critical` - Audit only critical paths (auth, payments, data processing)
- `/cxp:audit all` - Audit entire codebase

**Output**:
- `issues/bug-[name]/problem.md` - Individual bug/security issues (ready for `/cxp:solve`)
- `audit-report-[timestamp].md` - Comprehensive audit summary

**Example Workflow**:
```bash
# 1. Audit authentication module
/cxp:audit auth

# Output: Created 4 issues
# - bug-sql-injection-login (Critical - FIX IMMEDIATELY!)
# - bug-weak-password-hash (Critical)
# - bug-missing-rate-limit (High)
# - bug-session-timeout-missing (Medium)

# 2. Fix critical security issues immediately
/cxp:solve bug-sql-injection-login

# 3. Fix remaining bugs
/cxp:solve bug-weak-password-hash
/cxp:solve bug-missing-rate-limit
```

**Difference from /cxp:review**:
- **`/cxp:audit`**: Finds **bugs, security vulnerabilities, crashes**
- **`/cxp:review`**: Finds **refactoring opportunities, code quality improvements**

**Tools used**: Bandit, Ruff (security checks), Pyright, cProfile, py-spy, manual security review

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

### Package Management
- **UV** for fast, reliable package management (10-100x faster than pip)
- Lock file support for reproducible builds
- Virtual environment management
- Python version management

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
- Linting and formatting with ruff
- Type checking with pyright
- PEP 8 compliance
- Clear naming and focused functions
- Manual security review practices

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
- Runs tests: pytest, pyright, ruff
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

### 4. Security & Bug Audit (Critical)
```
/cxp:audit auth
```

**Result**: Creates **4 bug/security issues** in `issues/` folder + audit report:
- `bug-sql-injection-login` (Critical - FIX IMMEDIATELY!)
- `bug-weak-password-hash` (Critical)
- `bug-missing-rate-limit` (High)
- `bug-session-timeout-missing` (Medium)

**Audit report** (`audit-report-[timestamp].md`) includes:
- All issues organized by severity (Critical/High/Medium)
- Security posture assessment
- Critical priorities (fix immediately)
- Tool findings (Bandit, Ruff, Pyright)

**Next step**: Fix critical issues immediately

```bash
# Fix critical security issues ASAP
/cxp:solve bug-sql-injection-login
/cxp:solve bug-weak-password-hash

# Then high severity bugs
/cxp:solve bug-missing-rate-limit
```

**Use this to**:
- Find security vulnerabilities before attackers do
- Identify potential crashes and data corruption
- Detect performance bottlenecks (with profiling evidence)
- Fix async/await issues and race conditions
- Handle edge cases and improve error handling

### 5. Proactive Code Quality Review (Recommended)
```
/cxp:review services/user
```

**Result**: Creates **5 refactoring issues** in `issues/` folder + summary report:
- `refactor-split-user-service-god-class` (High priority)
- `refactor-extract-validation-logic` (High priority - Quick Win!)
- `refactor-add-type-hints-user-module` (Medium priority)
- `refactor-introduce-repository-pattern` (Medium priority)
- `refactor-use-dataclasses-user-models` (Low priority)

**Summary report** (`code-review-summary-[timestamp].md`) includes:
- All issues organized by priority and category
- Quick wins identified (high impact, low effort)
- Estimated impact: ~200 LOC reduction, complexity from 42→8, type coverage 45%→95%
- Recommended execution order

**Next step**: Solve the issues one at a time using `/cxp:solve [issue-name]`

```bash
# Start with quick win
/cxp:solve refactor-extract-validation-logic

# Then tackle high priority
/cxp:solve refactor-split-user-service-god-class

# Continue with others as capacity allows
```

**Use this to**:
- Proactively identify and fix technical debt
- Reduce code duplication and complexity
- Modernize to Python 3.14+ features
- Improve architecture and testability
- Build a prioritized refactoring roadmap

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
