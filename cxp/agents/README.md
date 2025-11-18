# cxp Agents - Python Development

Multi-phase problem-solving workflow agents for Python 3.11+ development with specialized focus on modern Python idioms, type safety, async patterns, and comprehensive testing. These agents work together to provide a complete problem-solving pipeline from issue identification through implementation to documentation.

## Agent Overview

### Problem-Solving Workflow Agents

These agents execute sequentially as part of the `/cxp:solve` workflow:

#### 1. Problem Researcher
**File**: `problem-researcher.md`
**Purpose**: Researches Python codebases to identify bugs, performance issues, and feature requirements

**Key Capabilities**:
- Analyzes Python source code for bugs, anti-patterns, and performance issues
- Specializes in async/await patterns, type safety, and FastAPI development
- Searches for existing Python packages/libraries that could help
- Creates comprehensive problem definitions with evidence
- Documents context, third-party solutions, and acceptance criteria
- Uses severity levels (Critical, High, Medium, Low) based on evidence

**Triggered by**: `/cxp:problem [description]` or `/cxp:refine [issue-name]`

**Output**: Creates `issues/[issue-name]/problem.md`

#### 2. Problem Validator
**File**: `problem-validator.md`
**Purpose**: Validates issues, proposes solution approaches, and develops test cases

**Key Capabilities**:
- Confirms whether reported issue is valid or "NOT A BUG"
- Classifies issue type (bug/feature/refactor/performance)
- Assesses feasibility and implementation complexity
- Proposes multiple solution approaches with Python-specific considerations
- Provides pros/cons and comparison for each approach
- Creates pytest test cases to prove the issue exists
- Evaluates integration points and dependencies

**Triggered by**: `/cxp:solve [issue-name]` (Step 1)

**Output**: Creates `issues/[issue-name]/validation.md`

**Special Behavior**: If issue is "NOT A BUG", creates `solution.md` and skips directly to Documentation Updater

#### 3. Solution Proposer
**File**: `solution-proposer.md`
**Purpose**: Researches existing solutions and proposes 3-4 solution approaches with thorough analysis

**Key Capabilities**:
- Researches existing Python packages and libraries
- Reviews codebase for similar patterns and solutions
- Proposes 3-4 distinct solution approaches (A, B, C, D)
- Provides detailed pros/cons for each approach
- Considers modern Python features (3.11+: ExceptionGroup, Self, @override)
- Evaluates third-party libraries vs custom implementation
- Creates solution comparison table

**Triggered by**: `/cxp:solve [issue-name]` (Step 2, optional in some workflows)

**Output**: Creates or updates `issues/[issue-name]/validation.md` with solution proposals

#### 4. Solution Reviewer
**File**: `solution-reviewer.md`
**Purpose**: Critically evaluates proposed solutions and selects optimal approach

**Key Capabilities**:
- Analyzes complexity, risk, and effort for each proposed solution
- Evaluates type safety and async compatibility
- Considers maintainability and testability
- Provides recommendation with justification
- Documents key decision factors
- Assesses impact on existing codebase
- Selects best approach aligned with Python best practices

**Triggered by**: `/cxp:solve [issue-name]` (Step 2 or 3)

**Output**: Creates `issues/[issue-name]/review.md`

#### 5. Solution Implementer
**File**: `solution-implementer.md`
**Purpose**: Implements fixes using modern Python 3.11+ best practices

**Key Capabilities**:
- Implements the selected solution approach
- Uses modern Python idioms (type hints, pattern matching, async/await)
- Follows PEP 8 and Python best practices
- Implements comprehensive type hints (avoiding `Any`)
- Uses appropriate data structures (dataclasses, Pydantic models)
- Handles errors with specific exceptions and chaining
- Documents design patterns and rationale
- Creates comprehensive implementation notes

**Triggered by**: `/cxp:solve [issue-name]` (Step 3 or 4)

**Output**: Creates `issues/[issue-name]/implementation.md`

#### 6. Code Reviewer & Tester
**File**: `code-reviewer-tester.md`
**Purpose**: Reviews code quality, runs linters, type checkers, and tests

**Key Capabilities**:
- Creates and validates pytest test cases
- Runs unit tests with pytest (parallel mode with `-n auto`)
- Runs type checking with pyright
- Executes linting with ruff (check + format)
- Performs comprehensive code quality review
- Validates test coverage (target >80%)
- Identifies improvements and refactoring opportunities
- Enforces validation test refactoring (converts behavioral or deletes)
- Analyzes regression risks

**Triggered by**: `/cxp:solve [issue-name]` (Step 4 or 5)

**Output**: Creates `issues/[issue-name]/testing.md`

#### 7. Documentation Updater
**File**: `documentation-updater.md`
**Purpose**: Creates solution documentation and git commits

**Key Capabilities**:
- Summarizes the entire workflow
- Creates comprehensive solution.md
- Generates clean git commits with descriptive messages
- Archives issue to `archive/[issue-name]/`
- Creates follow-up issues if needed
- Marks original issue as RESOLVED
- Ensures no structural tests remain after implementation

**Triggered by**: `/cxp:solve [issue-name]` (Step 5 or 6)

**Output**: Creates `archive/[issue-name]/solution.md` and git commit

### Standalone Code Quality Agents

These agents can be invoked independently for code quality analysis:

#### 8. Code Quality Reviewer
**File**: `code-quality-reviewer.md`
**Purpose**: Reviews Python code to identify refactoring opportunities, code duplication, and complexity issues

**Key Capabilities**:
- Identifies code duplication (repeated logic across files)
- Detects god classes/functions (complexity, SRP violations)
- Finds architecture issues (tight coupling, missing patterns)
- Identifies type safety gaps (missing type hints on public APIs)
- Detects performance issues with profiling evidence (N+1 queries)
- Suggests modern Python 3.11+ upgrade opportunities
- Creates individual refactoring issues in `issues/` folder
- Prioritizes by impact and effort (High/Medium/Low)
- Generates summary report with quick wins

**Triggered by**: `/cxp:review [scope]`

**Output**: Multiple `issues/refactor-[name]/problem.md` + `code-review-summary-[timestamp].md`

#### 9. Bug Hunter
**File**: `bug-hunter.md`
**Purpose**: Critically reviews code to identify logic errors, oversights, refactoring remnants, and edge cases

**Key Capabilities**:
- Detects logic errors (off-by-one, wrong operators, boolean mistakes)
- Identifies oversights (missing None checks, boundary conditions)
- Finds refactoring remnants (dead code, unused variables, TODOs)
- Validates type safety (missing type hints leading to runtime errors)
- Detects async/await issues (blocking I/O, missing await, race conditions)
- Finds unhandled exceptions and silent failures
- Identifies basic security issues (SQL injection, hardcoded secrets)
- Detects performance issues with evidence
- Creates individual bug issues in `issues/` folder
- Prioritizes by severity (Critical/High/Medium/Low)
- Generates comprehensive audit report

**Triggered by**: `/cxp:audit [scope]`

**Output**: Multiple `issues/bug-[name]/problem.md` + `audit-report-[timestamp].md`

## Workflow Execution

### Complete Workflow (`/cxp:solve [issue-name]`)

```
issues/[issue-name]/problem.md
    ↓
[Problem Validator] → validation.md
    ↓
    ├─ NOT A BUG → solution.md → [Documentation Updater] → archive/
    │
    └─ CONFIRMED ↓
[Solution Proposer] → validation.md (with proposals)
    ↓
[Solution Reviewer] → review.md
    ↓
[Solution Implementer] → implementation.md
    ↓
[Code Reviewer & Tester] → testing.md
    ↓
[Documentation Updater] → solution.md + git commit → archive/
```

### Code Quality Workflow (`/cxp:review [scope]`)

```
/cxp:review services/user
    ↓
[Code Quality Reviewer]
    ↓
Creates multiple issues:
├── issues/refactor-split-user-service/problem.md
├── issues/refactor-extract-validation/problem.md
├── issues/refactor-add-type-hints/problem.md
└── code-review-summary-[timestamp].md

Then solve each:
/cxp:solve refactor-split-user-service
```

### Bug Audit Workflow (`/cxp:audit [scope]`)

```
/cxp:audit services/user
    ↓
[Bug Hunter]
    ↓
Creates multiple issues:
├── issues/bug-off-by-one-pagination/problem.md
├── issues/bug-missing-none-check/problem.md
├── issues/bug-async-blocking-call/problem.md
└── audit-report-[timestamp].md

Then solve each:
/cxp:solve bug-off-by-one-pagination
```

### File Structure

**Active Issue**:
```
issues/[issue-name]/
└── problem.md          # Created by Problem Researcher
```

**During Workflow** (`/cxp:solve` execution):
```
issues/[issue-name]/
├── problem.md          # Initial definition
├── validation.md       # Problem Validator + Solution Proposer
├── review.md           # Solution Reviewer
├── implementation.md   # Solution Implementer
└── testing.md          # Code Reviewer & Tester
```

**Archived (Solved)**:
```
archive/[issue-name]/
├── problem.md          # Original issue (Status: RESOLVED)
├── validation.md       # Audit trail
├── review.md           # Audit trail
├── implementation.md   # Audit trail
├── testing.md          # Audit trail
└── solution.md         # Final summary
```

## Python-Specific Best Practices

All agents enforce modern Python 3.11+ development patterns:

### Language Features
- **Type Hints**: Comprehensive type annotations (avoiding `Any`)
- **Pattern Matching**: `match`/`case` for complex conditionals
- **Type Unions**: `|` instead of `Union` (3.10+)
- **ExceptionGroup**: Multiple error handling (3.11+)
- **Self Type**: Type-safe instance returns (3.11+)
- **@override**: Explicit override decorator (3.12+)
- **TypedDict**: Typed dictionary with **kwargs support (3.14+)

### Async Patterns
- **async/await**: Proper async function definitions
- **No blocking**: Avoid blocking I/O in async functions
- **Task management**: Proper task creation and cancellation
- **AsyncIO**: Best practices for event loops and coroutines
- **pytest-asyncio**: Async test support

### Error Handling
- **Specific exceptions**: Never use bare `except:`
- **Exception chaining**: Use `from` for context (`raise ValueError() from e`)
- **Custom exceptions**: Proper exception hierarchy
- **Clear messages**: Actionable error messages
- **No silent failures**: Always handle or propagate errors

### Testing with Pytest
- **Fixtures**: Setup/teardown with pytest fixtures
- **Parametrize**: Test multiple scenarios with `@pytest.mark.parametrize`
- **Mocking**: Mock external dependencies with pytest-mock
- **Async testing**: pytest-asyncio for async test functions
- **Coverage**: Target >80% code coverage
- **Parallel execution**: Run tests with `-n auto` for speed

### FastAPI Development
- **Pydantic models**: Request/response validation
- **Dependency injection**: Reusable dependencies
- **Async routes**: Proper async route handlers
- **HTTPException**: Standard error responses
- **Background tasks**: Non-blocking background operations
- **Middleware**: Request/response processing

### Code Quality Tools
- **ruff**: Fast linting and formatting (`ruff check` + `ruff format`)
- **pyright**: Static type checking
- **pytest**: Testing framework
- **vulture**: Dead code detection (used by Bug Hunter)
- **cProfile**: Performance profiling (used by Bug Hunter and Code Quality Reviewer)

### Package Management
- **UV**: Fast, reliable package management (10-100x faster than pip)
- **Lock files**: Reproducible builds with `uv.lock`
- **Virtual environments**: Isolated dependencies
- **Python version**: Managed with UV

## Usage Examples

### Define a New Problem
```bash
/cxp:problem async exception handling in user creation endpoint
```
Creates `issues/bug-async-unhandled-exception/problem.md`

### Refine Existing Problem
```bash
/cxp:refine bug-async-unhandled-exception
```
Updates `issues/bug-async-unhandled-exception/problem.md`

### Execute Complete Workflow
```bash
/cxp:solve bug-async-unhandled-exception
```
Executes all workflow agents sequentially, creates audit trail, archives issue

### Code Quality Review
```bash
/cxp:review services/user
```
Creates multiple refactoring issues ready for `/cxp:solve`

### Bug Audit
```bash
/cxp:audit services/user
```
Creates multiple bug issues with severity priorities

## Agent Coordination

### Data Flow
Each agent reads the outputs of previous agents to inform its decisions:

1. **Problem Validator** reads `problem.md`
2. **Solution Proposer** reads `problem.md` + `validation.md`
3. **Solution Reviewer** reads `problem.md` + `validation.md` (with proposals)
4. **Solution Implementer** reads `problem.md` + `validation.md` + `review.md`
5. **Code Reviewer & Tester** reads all previous outputs + runs tools
6. **Documentation Updater** synthesizes all outputs into `solution.md`

**Standalone Agents**:
- **Code Quality Reviewer** analyzes codebase independently
- **Bug Hunter** analyzes codebase independently

### Audit Trail
Every workflow agent creates a permanent record of its analysis and decisions, providing complete traceability from problem identification to final solution.

### Quality Gates
Each agent enforces quality standards:
- **Problem Validator**: Issue must be valid and well-defined
- **Solution Proposer**: Multiple approaches must be considered
- **Solution Reviewer**: Solution must be optimal and justified
- **Solution Implementer**: Code must follow Python best practices
- **Code Reviewer & Tester**: Tests must pass, linting clean, types checked
- **Documentation Updater**: Documentation must be comprehensive

## Integration with Commands

### `/cxp:problem`
Invokes **Problem Researcher** to create new issue

### `/cxp:refine`
Invokes **Problem Researcher** to refine existing issue

### `/cxp:solve`
Orchestrates all workflow agents in sequence for complete problem-solving

### `/cxp:review`
Invokes **Code Quality Reviewer** to analyze code and create refactoring issues

### `/cxp:audit`
Invokes **Bug Hunter** to find bugs, logic errors, and oversights

## Tools and Technologies

### Code Quality
- **ruff** (linting + formatting)
- **pyright** (static type checking)
- **vulture** (dead code detection)
- **pytest** (testing framework with parallel execution)
- **pytest-asyncio** (async test support)
- **pytest-mock** (mocking support)

### Performance Analysis
- **cProfile** (CPU profiling)
- **memory_profiler** (memory usage analysis)
- **py-spy** (sampling profiler)

### Web Frameworks
- **FastAPI** (async web framework)
- **Pydantic** (data validation)
- **SQLAlchemy** (ORM with async support)

### Package Management
- **UV** (fast package management)
- **pip-tools** (dependency management)

### Documentation
- Markdown formatting
- File path references with line numbers
- Evidence-based severity assessment
- Git commit message conventions

## Testing Best Practices

### Validation Test Refactoring
After implementation, **Code Reviewer & Tester** enforces:
1. **Convert to behavioral tests**: Rename and refactor to test behavior, not structure
2. **Delete redundant tests**: Remove tests that only verify implementation details

**Why?**
- Structural tests break on refactoring (brittle)
- Behavioral tests verify outcomes (resilient)
- Validation tests prove issues exist, then should be removed or converted

**Example**:
```python
# ❌ Structural (validation) - DELETE after fix
def test_user_service_has_validate_email_method():
    assert hasattr(UserService, 'validate_email')

# ✅ Behavioral - KEEP
def test_user_service_rejects_invalid_email():
    with pytest.raises(ValidationError):
        UserService.create_user(email='invalid')
```

### Parallel Test Execution
All pytest tests run with `-n auto` for parallel execution:
```bash
pytest -n auto  # Uses all CPU cores
```

Benefits:
- 3-10x faster test execution
- Early feedback on failures
- Better CI/CD performance

## See Also

- [cxp Plugin Documentation](../README.md) - Overview of cxp plugin
- [Main CCP Documentation](../../README.md) - Complete collection documentation
- [Issue Management System](../../README.md#issue-management-system) - Issue lifecycle details
- [Python Best Practices](../README.md#python-best-practices-covered) - Detailed Python guidelines
