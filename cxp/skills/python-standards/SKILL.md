---
name: python-standards
description: Python 3.14+ development standards (2025) - common reference for file naming, status markers, modern patterns, fail-fast principles, uv package management, test execution
---

# Python Standards Reference (2025)

Common reference material for Python 3.14+ development in 2025. This skill provides standardized conventions, best practices, and patterns used across all cxp agents and workflows.

## File Naming Conventions

**CRITICAL**: Always use lowercase filenames for all issue-related files.

**Correct** ✅:
- `problem.md`
- `solution.md`
- `validation.md`
- `review.md`
- `implementation.md`
- `testing.md`

**Incorrect** ❌:
- `Problem.md`
- `PROBLEM.md`
- `Solution.MD`

## Directory Structure

All issue-related files reside in:

```
<PROJECT_ROOT>/issues/[issue-name]/
├── problem.md          # Issue definition
├── validation.md       # Problem Validator findings
├── review.md           # Solution Reviewer analysis
├── implementation.md   # Solution Implementer report
├── testing.md          # Code review and test results
└── solution.md         # Final documentation

<PROJECT_ROOT>/archive/[issue-name]/
└── [all files above after resolution]
```

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
- ❌ **Never claim "memory leak"** without memory_profiler/tracemalloc output showing actual memory growth
- ❌ **Never claim "performance issue"** without cProfile/py-spy benchmarks with concrete numbers
- ❌ **Never claim "High/Critical severity"** without reproducing the bug with actual error output
- ✅ **Include actual profiling data** - Attach cProfile output, memory graphs, or benchmark results
- ✅ **Use concrete metrics** - "3-5 second delay" not "slow", "250MB leak" not "memory issue"

**Example**:
```markdown
❌ Bad: "This causes a memory leak affecting production (High severity)"
✅ Good: "memory_profiler shows 250MB growth per 1000 iterations (attached profile.png). Extrapolated: 2.5GB/day in production (High severity)"

❌ Bad: "Performance bottleneck in query handler (Critical)"
✅ Good: "cProfile shows 4.8s p95 latency, 99% time in db.execute() (N+1 queries). Target: <100ms (High severity)"
```

## Priority Levels (Features)

- **High** - Core functionality, blocking other work, user-facing impact
- **Medium** - Important improvements, developer experience, performance enhancements
- **Low** - Nice-to-have, optimizations, convenience features

## Modern Python Best Practices (3.14+)

### Python Version Features

**Python 3.14** (Oct 2025 - current):
- **t-strings** (PEP 750) for template literals
- **Deferred annotations** evaluation
- REPL syntax highlighting
- Improved free-threading performance
- JIT compiler improvements

**Python 3.13** (Oct 2024):
- TypedDict for **kwargs (PEP 692)
- Improved error messages with color
- JIT compiler (experimental)
- Free-threaded mode (experimental - GIL-free)
- New interactive interpreter

**Python 3.12**:
- Type parameter syntax `[T]`
- `@override` decorator

**Python 3.11**:
- ExceptionGroup for multiple errors
- Self type for method chaining
- TaskGroup for structured concurrency
- Pattern matching (`match`/`case`)

### Modern Patterns to Use

- **Type hints**: All functions with parameter and return types
- **Deferred annotations**: Python 3.14+ evaluation model
- **Type unions**: Use `|` instead of `Union`
- **Pattern matching**: Use `match`/`case` for complex conditionals (3.11+)
- **Async/await**: Proper async patterns, no blocking in async functions
- **Error handling**: Specific exceptions, proper chaining with `from`
- **Dataclasses**: Use `@dataclass` for data structures (with `slots=True` for performance)
- **Context managers**: Use `with` for resource management
- **Generators**: Use generators for large datasets
- **Free-threading**: Consider for CPU-bound tasks (3.13+ experimental)

### Anti-Patterns to Avoid

- ❌ Bare `except:` (use specific exceptions)
- ❌ Catching broad `Exception` in library code (only allowed in CLI, executors, tools, tests)
- ❌ Mutable default arguments
- ❌ Using `Any` without justification
- ❌ Blocking calls in async functions
- ❌ Silent failures (swallowed exceptions)
- ❌ Returning None/False on errors (fail loudly instead)
- ❌ Thin wrapper functions that just forward calls
- ❌ Magic numbers (use constants)
- ❌ Deep nesting (>3 levels)
- ❌ God functions (>50 lines)

## Fail-Fast Principles (CRITICAL)

**DO NOT use defensive programming. Use fail-fast instead.**

### Defensive Programming Anti-Patterns (❌ NEVER DO)

- **Silently catching errors**: `try/except: pass` or `try/except: return None`
- **Returning None on errors**: Functions that hide failures by returning None
- **Default fallbacks**: Silently using defaults when operations fail
- **Lenient validation**: Accepting invalid input and coercing it
- **Swallowing exceptions**: Catching without re-raising or logging
- **Guard clauses that hide bugs**: `if x is None: return default` when None shouldn't happen
- **Over-broad exception handling**: `except Exception:` in library code

### Why Defensive Programming is Bad

- **Hides bugs**: Errors fail silently, making debugging impossible
- **Delays detection**: Problems discovered in production, not development
- **Breaks fail-fast**: Violates principle of catching errors early
- **Reduces trust**: Can't trust function return values (is None an error or valid?)

### Fail-Fast Practices (✅ ALWAYS DO)

- ✅ **Validate inputs early**: Raise ValueError/TypeError immediately on invalid input
- ✅ **Fail loudly**: Raise specific exceptions with clear messages
- ✅ **Let exceptions propagate**: Don't catch unless adding context or handling specifically
- ✅ **Strict validation**: Use Pydantic `strict=True`, reject invalid input
- ✅ **No None returns on errors**: Return actual value or raise exception
- ✅ **Assertions for invariants**: Use `assert` for developer assumptions (disabled in production)
- ✅ **Strict parsing**: No lenient validation that accepts invalid input
- ✅ **Early error detection**: Check preconditions at function entry

### Example Comparison

```python
# ❌ DEFENSIVE PROGRAMMING (BAD)
def process_user(user_id: int | None) -> dict | None:
    if user_id is None:
        return None  # Hiding the bug
    try:
        user = get_user(user_id)
        return {"name": user.name}
    except Exception:
        return None  # Silent failure

# ✅ FAIL-FAST (GOOD)
def process_user(user_id: int) -> dict:
    if user_id <= 0:
        raise ValueError(f"Invalid user_id: {user_id}")

    user = get_user(user_id)  # Let exceptions propagate
    return {"name": user.name}
```

```python
# ❌ BAD: Lenient validation with defaults
class Config(BaseModel):
    max_retries: int = 3  # Silently uses default if invalid

# ✅ GOOD: Strict validation, fail on bad input
class Config(BaseModel):
    max_retries: int = Field(ge=0, le=10)  # Fails if out of range

    @field_validator('max_retries')
    @classmethod
    def validate_retries(cls, v: int) -> int:
        if v <= 0:
            raise ValueError("max_retries must be positive")
        return v
```

### When NOT to Fail-Fast

- User-facing operations (provide graceful degradation)
- Network/IO operations (retry with exponential backoff)
- Optional features (log warning and continue)

## Package Management with UV

**Use UV for all package and test operations** (10-100x faster than pip):

### Commands

- **Install dependencies**: `uv sync`
- **Add package**: `uv add package-name`
- **Add dev package**: `uv add --dev package-name`
- **Run tests**: `uv run pytest -n auto tests/ -v`
- **Run linter**: `uv run ruff check .`
- **Format code**: `uv run ruff format .`
- **Run type checker**: `uv run pyright`
- **Virtual environment**: `uv venv --python 3.14`
- **Python version**: `uv python install 3.14`

**NEVER use pip directly** - always use uv.

## Test Execution

### Commands (Always Use UV)

**Unit tests**:
```bash
uv run pytest -n auto tests/unit/ -v
```

**Integration tests**:
```bash
uv run pytest -n auto tests/integration/ -v
```

**Specific test**:
```bash
uv run pytest -n auto tests/test_file.py::test_name -v
```

**Coverage**:
```bash
uv run pytest -n auto --cov=package --cov-report=term-missing
```

**Full suite**:
```bash
uv run pytest -n auto -v
```

**Quick iteration** (stop at first failure):
```bash
uv run pytest -n auto -x -v
```

### Test Requirements

- ✅ **ALWAYS run tests after creation**
- ✅ **Include actual output** (never placeholders)
- ✅ **Features SHOULD have integration tests**
- ✅ **Use pytest-asyncio 1.3.0+ for async tests**
- ✅ **Use AsyncMock for async function mocking**

### Expected Behavior

- **Bug test**: FAIL before fix → PASS after
- **Feature test**: FAIL before impl → PASS after

## Async/Await Patterns (2025)

### Modern Async Practices

- ✅ **Proper async/await usage** with error chaining (`cause` property)
- ✅ **asyncio.gather for concurrency** - run multiple async operations concurrently
- ✅ **pytest-asyncio 1.3.0+** (Nov 2025) - supports Python 3.10-3.14
- ✅ **AsyncMock** for mocking async functions
- ✅ **Async fixtures** for test setup
- ✅ **TaskGroup for structured concurrency** (3.11+)
- ✅ **Proper cancellation handling** with AbortController patterns

### Anti-Patterns to Avoid

- ❌ No blocking calls in async functions
- ❌ Avoid deadlocks - manage fixture dependencies carefully
- ❌ Don't mix sync/async without `asyncio.to_thread`

### Example

```python
# ✅ GOOD: Concurrent operations with asyncio.gather
async def fetch_user_data(user_id: int) -> UserData:
    user, posts, comments = await asyncio.gather(
        fetch_user(user_id),
        fetch_user_posts(user_id),
        fetch_user_comments(user_id)
    )
    return UserData(user=user, posts=posts, comments=comments)

# ❌ BAD: Sequential operations (slow)
async def fetch_user_data(user_id: int) -> UserData:
    user = await fetch_user(user_id)
    posts = await fetch_user_posts(user_id)
    comments = await fetch_user_comments(user_id)
    return UserData(user=user, posts=posts, comments=comments)
```

## Type Safety

### Best Practices

- ✅ **Comprehensive type hints** with deferred annotations (3.14+)
- ✅ **Avoid `Any` without justification** (use Protocol or generics)
- ✅ **Proper use of generics**, Protocol, TypeVar
- ✅ **Type narrowing** with type guards
- ✅ **TypedDict for **kwargs** (3.13+)
- ✅ **Modern type parameter syntax `[T]`** (3.12+)

### Type Checking

Always run type checking with pyright:

```bash
uv run pyright [files]
```

Enable strict mode for maximum type safety.

## Code Quality Standards

### Function Design

- ✅ **Functions are focused and single-purpose**
- ✅ **No functions >50 lines** (consider splitting)
- ✅ **No deep nesting (>3 levels)**
- ✅ **Clear variable names** (no single-letter except loops)
- ✅ **No magic numbers** (use constants)
- ✅ **Docstrings for public functions/classes**
- ✅ **No commented-out code**

### Linting and Formatting

Use ruff for both linting and formatting:

```bash
# Check for issues
uv run ruff check .

# Auto-fix issues
uv run ruff check --fix .

# Format code
uv run ruff format .
```

## Error Handling

### Best Practices

- ✅ **Specific exception types** (not bare `except:`)
- ✅ **Exception chaining** with `from` and `cause` property
- ✅ **Custom exceptions** with proper inheritance
- ✅ **ExceptionGroup** for multiple errors (3.11+)
- ✅ **Clear error messages**
- ✅ **Fail-fast principles** - no silent failures

### Example

```python
# ✅ GOOD: Specific exception with chaining
def process_file(path: str) -> Data:
    try:
        with open(path) as f:
            return parse_data(f.read())
    except FileNotFoundError as e:
        raise DataProcessingError(f"File not found: {path}") from e
    except ValueError as e:
        raise DataProcessingError(f"Invalid data in {path}") from e
```

## Security Best Practices

### Manual Review Checklist

- ✅ **No SQL injection** (use parameterized queries)
- ✅ **No command injection** (avoid `shell=True`)
- ✅ **No path traversal** (validate file paths)
- ✅ **Secrets not hardcoded** (use environment variables)
- ✅ **Input validation** for user data
- ✅ **No eval/exec usage**

## Performance Best Practices

- ✅ **No premature optimization** without profiling
- ✅ **Avoid N+1 queries** (use eager loading)
- ✅ **Use generators** for large datasets
- ✅ **Proper use of `__slots__`** for memory optimization (if needed)
- ✅ **asyncio.gather** for concurrent async operations
- ✅ **Free-threading** for CPU-bound tasks (3.13+ experimental)

## Commit Message Format

Use conventional commit format:

- `fix:` - Bug fixes
- `feat:` - New features
- `test:` - Test additions or changes
- `refactor:` - Code refactoring
- `docs:` - Documentation only
- `chore:` - Maintenance tasks
- `perf:` - Performance improvements

## When to Reference This Skill

Agents and users should reference this skill when they need:

- File naming conventions
- Status marker definitions
- Severity/priority level guidance
- Modern Python best practices (3.11-3.14+)
- Fail-fast vs defensive programming patterns
- UV package management commands
- Test execution commands
- Async/await patterns
- Type safety standards
- Code quality standards

## Usage

Reference this skill in agents:

```markdown
For Python standards, conventions, and best practices, see Skill(cxp:python-standards).
```

Or invoke directly:

```bash
Use cxp:python-standards skill for Python development standards reference
```
