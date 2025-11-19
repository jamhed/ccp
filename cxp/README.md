# cxp Plugin - Python Development (2025)

Comprehensive toolkit for Python 3.14+ development in 2025 with t-strings, deferred annotations, free-threading, uv package manager (10-100x faster), and modern testing with pytest-asyncio 1.3.0+.

## Skills

- **python-dev**: Expert Python 3.14+ development for 2025 - t-strings, deferred annotations, free-threading, uv (10-100x faster than pip), JIT compiler, async patterns with asyncio.gather, type safety
- **pytest-tester**: pytest expert for 2025 - pytest-asyncio 1.3.0+ (supports Python 3.10-3.14), AsyncMock, async fixtures, uv parallel testing (`uv run pytest -n auto`), asyncio.gather optimization
- **fastapi-dev**: FastAPI specialist for async API design, dependency injection, Pydantic v2, async patterns, middleware, and comprehensive testing

**Shared Skills** (from cx plugin):
- **issue-manager**: Manage project issues in the issues folder. List open issues, archive solved issues, and refine problem definitions
- **web-doc**: Fetches and caches technical documentation locally in `docs/web/` for offline reference

## Agents (2025)

Multi-phase problem-solving workflow agents using Python 3.14+ and 2025 best practices:

- **Problem Researcher**: Researches Python 3.14+ codebases - identifies bugs using t-strings, deferred annotations, free-threading, uv, async patterns
- **Problem Validator**: Validates issues and develops pytest-asyncio 1.3.0+ tests with AsyncMock, async fixtures, uv parallel testing
- **Solution Reviewer**: Evaluates solutions using t-strings, deferred annotations, free-threading, uv (10-100x faster), asyncio.gather, type safety
- **Solution Implementer**: Implements fixes using Python 3.14+, t-strings, free-threading, uv, pytest-asyncio 1.3.0+, AsyncMock
- **Code Reviewer & Tester**: Runs uv parallel testing (`uv run pytest -n auto`), pytest-asyncio 1.3.0+, ensures 2025 best practices
- **Documentation Updater**: Documents solution with uv pytest results, t-strings, deferred annotations, free-threading, AsyncMock tests

Standalone code quality agents:

- **Code Quality Reviewer**: Reviews Python 3.14+ code for refactoring opportunities, duplication, complexity, 2025 best practice improvements (t-strings, deferred annotations, free-threading, uv, async patterns)
- **Bug Hunter**: Critically reviews code for logic errors, oversights, edge cases, potential bugs using 2025 standards

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

Comprehensive bug audit to identify logic errors, oversights, refactoring remnants, and potential bugs.

**Usage**: `/cxp:audit [file-path | module-name | "all"]`

**What it does**:
1. **Logic error detection**:
   - Off-by-one errors, wrong operators, incorrect algorithms
   - Boolean logic mistakes, copy-paste errors

2. **Oversight detection**:
   - Missing None checks, empty collection handling
   - Boundary conditions, division by zero
   - Missing input validation

3. **Refactoring remnants**:
   - Dead code, unused variables/functions
   - Commented-out code, TODO/FIXME markers
   - Incomplete migrations, orphaned functions

4. **Type safety & error handling**:
   - Missing type hints leading to runtime errors
   - Unhandled exceptions, silent failures
   - Missing cleanup (context managers)

5. **Async/await issues**:
   - Blocking I/O in async functions
   - Missing await statements
   - Race conditions

6. **Performance issues** (with evidence):
   - N+1 query patterns
   - Blocking calls

7. **Basic security** (obvious cases only):
   - SQL injection, hardcoded secrets

8. **Creates individual issues** in `issues/` folder:
   - Prioritized by severity (Critical/High/Medium/Low)
   - Includes evidence (tool output, reproduction steps)
   - Ready for `/cxp:solve [issue-name]` workflow

**Examples**:
- `/cxp:audit services/user` - Audit user service for bugs and oversights
- `/cxp:audit app/api/handlers.py` - Audit specific file
- `/cxp:audit all` - Audit entire codebase

**Output**:
- `issues/bug-[name]/problem.md` - Individual bug/issue reports (ready for `/cxp:solve`)
- `audit-report-[timestamp].md` - Comprehensive audit summary

**Example Workflow**:
```bash
# 1. Audit user service
/cxp:audit services/user

# Output: Created 5 issues
# - bug-off-by-one-pagination (High - logic error)
# - bug-missing-none-check-user-email (High - oversight causing crashes)
# - bug-unused-function-old-validation (Medium - refactoring remnant)
# - bug-blocking-db-call-async (Medium - async issue)
# - bug-sql-injection-user-search (High - obvious security)

# 2. Fix high severity bugs first
/cxp:solve bug-off-by-one-pagination

# 3. Fix oversights
/cxp:solve bug-missing-none-check-user-email

# 4. Clean up refactoring remnants
/cxp:solve bug-unused-function-old-validation
```

**Difference from /cxp:review**:
- **`/cxp:audit`**: Finds **bugs, logic errors, oversights, refactoring remnants**
- **`/cxp:review`**: Finds **refactoring opportunities, code quality improvements**

**Tools used**: Ruff (bug detection), Pyright, Vulture (dead code), cProfile, manual code review

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

## Python 3.14+ Best Practices (2025)

### Modern Python (3.14+)
- **Python 3.14** (Oct 2025 - current): t-strings (PEP 750) for template literals, deferred annotations evaluation, REPL syntax highlighting, improved free-threading
- **Python 3.13** (Oct 2024): TypedDict for **kwargs, improved error messages with color, JIT compiler (experimental), free-threaded mode (experimental - GIL-free), new interactive interpreter
- **Python 3.12**: type parameter syntax `[T]`, @override decorator
- **Python 3.11**: ExceptionGroup, Self type, TaskGroup for structured concurrency, pattern matching (`match`/`case`)
- Type hints with deferred annotations (3.14+)
- Type unions with `|` instead of `Union`

### Package Management (2025 Standard)
- **uv**: Industry standard (10-100x faster than pip), unified tool replacing pip/pip-tools/virtualenv/pyenv
- Lock file support for reproducible builds
- Virtual environment management: `uv venv --python 3.14`
- Python version management: `uv python install 3.14`
- Parallel dependency resolution
- **Never use pip directly** - always use uv

### Type Safety (2025)
- Comprehensive type hints with deferred annotations (3.14+)
- Avoid `Any` without justification (use Protocol or generics)
- Proper use of generics, Protocol, TypeVar
- Type narrowing with type guards
- TypedDict for **kwargs (3.13+)
- Modern type parameter syntax `[T]` (3.12+)

### Async Patterns (2025)
- Proper async/await usage with error chaining (`cause` property)
- **asyncio.gather for concurrency** - run multiple async operations concurrently
- **pytest-asyncio 1.3.0+** (Nov 2025) - supports Python 3.10-3.14
- **AsyncMock** for mocking async functions
- **Async fixtures** for test setup
- **Avoid deadlocks** - manage fixture dependencies carefully
- No blocking calls in async functions
- Task lifecycle management with TaskGroup (3.11+)
- Proper cancellation handling with AbortController patterns

### Free-Threading (2025 - Experimental)
- **Python 3.13+** free-threaded mode - GIL-free experimental feature
- Consider for CPU-bound tasks
- Improved performance in Python 3.14
- Not production-ready yet, but worth experimenting

### Error Handling (2025)
- Specific exception types (not bare `except:`)
- Exception chaining with `from` and `cause` property
- Custom exceptions with proper inheritance
- ExceptionGroup for multiple errors (3.11+)
- Clear error messages
- Fail-fast principles - no silent failures

### Testing with Pytest (2025)
- **uv for test execution**: `uv run pytest -n auto` (parallel testing)
- **pytest-asyncio 1.3.0+**: Latest version supporting Python 3.10-3.14
- **AsyncMock**: For mocking async functions (Python 3.8+)
- **Async fixtures**: Backbone of well-structured async tests
- **asyncio.gather**: Concurrent test setup (reduce 6s to 3s)
- **Avoid deadlocks**: Careful fixture dependency management
- Parametrize for multiple scenarios
- Coverage analysis (>80% target)
- Test markers: unit, integration, slow, fast, asyncio

### FastAPI Development (2025)
- **Pydantic v2**: Faster validation, better error messages
- Dependency injection
- Proper async route handlers
- Error handling with HTTPException
- Background tasks
- Middleware and CORS
- Authentication/authorization
- Type-safe request/response models

### Code Quality (2025)
- **Linting and formatting**: ruff (fastest Python linter)
- **Type checking**: pyright or mypy --strict
- **PEP 8 compliance**
- **Modern Python features**: t-strings, deferred annotations, free-threading
- Clear naming and focused functions
- Manual security review practices
- **Always use uv** for dependency management

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

### 4. Bug Audit (Recommended)
```
/cxp:audit services/user
```

**Result**: Creates **5 bug/issue reports** in `issues/` folder + audit report:
- `bug-off-by-one-pagination` (High - logic error)
- `bug-missing-none-check-user-email` (High - oversight causing crashes)
- `bug-unused-function-old-validation` (Medium - refactoring remnant)
- `bug-blocking-db-call-async` (Medium - async issue)
- `bug-sql-injection-user-search` (High - obvious security)

**Audit report** (`audit-report-[timestamp].md`) includes:
- All issues organized by severity and category
- Bug type breakdown (logic errors, oversights, remnants)
- Priorities (fix high severity first)
- Tool findings (Ruff, Pyright, Vulture)

**Next step**: Fix high severity bugs first

```bash
# Fix logic errors
/cxp:solve bug-off-by-one-pagination

# Fix oversights causing crashes
/cxp:solve bug-missing-none-check-user-email

# Clean up refactoring remnants
/cxp:solve bug-unused-function-old-validation
```

**Use this to**:
- Find logic errors and off-by-one bugs
- Identify oversights (missing None checks, edge cases)
- Clean up refactoring remnants (dead code, unused variables)
- Fix type safety issues leading to runtime errors
- Detect async/await mistakes
- Find obvious security issues (SQL injection, hardcoded secrets)

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

## Contributing

This plugin is part of the Claude Code Plugin Collection (ccp). Contributions welcome at https://github.com/jamhed/ccp
