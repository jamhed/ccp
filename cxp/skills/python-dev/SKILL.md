---
name: python-dev
description: Expert Python development assistant for writing new code and reviewing existing codebases. Covers modern Python idioms (Python 3.14+), best practices, type safety, async patterns, JIT optimization, and idiomatic error handling.
---

# Python Development Assistant

Expert assistant for Python development, covering both writing new code and reviewing existing codebases with modern Python idioms (Python 3.14+) and best practices.

## Core Capabilities

### 1. Writing New Python Code
When writing new Python code:
- Use modern Python features (3.14+: JIT compiler, enhanced pattern matching, improved async)
- Use Python 3.13+ features (TypedDict for **kwargs, improved error messages)
- Use Python 3.12+ features (type parameter syntax, @override decorator)
- Use Python 3.11+ features (ExceptionGroup, Self type, TaskGroup)
- Apply type hints comprehensively (parameters, returns, attributes)
- Use pattern matching (`match`/`case`) for complex conditionals
- Implement proper error handling with specific exceptions and chaining
- **Apply fail-fast principles**: Validate inputs early, fail loudly, no silent failures
- **Start simple and iterate**: Build minimal solution first, add complexity only when needed
- Use structured logging with `logging` module or `structlog`
- Apply async/await patterns correctly (no blocking in async functions)
- Use dataclasses, pydantic models for data structures
- Follow PEP 8 and modern Python conventions

**Reference**: [references/modern-python-2025.md](references/modern-python-2025.md)

### 2. Reviewing Existing Python Code
When reviewing Python code:
- Check for type safety (comprehensive type hints, no `Any` abuse)
- **Check fail-fast patterns**: Input validation at entry, no silent failures, fail loudly on errors
- **Check early development patterns**: Simple before complex, easily testable, quick to iterate
- Identify async/await anti-patterns
- Review error handling (specific exceptions, proper chaining, no returning None on errors)
- Look for performance issues (N+1 queries, blocking calls)
- Validate security patterns (SQL injection, command injection, XSS)
- Check testing patterns (pytest best practices, fixtures, mocks)
- Review code style (PEP 8 compliance)

**References**:
- [references/modern-python-2025.md](references/modern-python-2025.md)
- [references/type-safety-patterns.md](references/type-safety-patterns.md)
- [references/async-patterns.md](references/async-patterns.md)

### 3. Web Framework Specialization (Optional)
When working with FastAPI, Django, or Flask:
- Apply framework-specific best practices
- Review request/response handling
- Check middleware and dependency injection
- Validate authentication/authorization patterns
- Review database query patterns (ORM usage)

**References**:
- [references/fastapi-patterns.md](references/fastapi-patterns.md)
- [references/django-patterns.md](references/django-patterns.md)

## When to Use This Skill

Use this skill when:
- Writing new Python functions, modules, or applications
- Reviewing Python code for best practices
- Refactoring Python code to modern idioms
- Implementing type safety and error handling
- Working with async/await patterns
- Optimizing Python code performance
- Implementing web APIs (FastAPI, Django, Flask)

## Workflow

### For Writing New Code

1. **Understand requirements**
   - Ask clarifying questions about the desired functionality
   - Identify the type of code (CLI, API, library, data pipeline, etc.)

2. **Design approach**
   - Choose appropriate patterns from [references/modern-python-2025.md](references/modern-python-2025.md)
   - For async code: review [references/async-patterns.md](references/async-patterns.md)
   - For web APIs: review [references/fastapi-patterns.md](references/fastapi-patterns.md)

3. **Implement code**
   - **Start simple**: Build minimum viable solution first, iterate based on tests
   - Use modern Python 3.14+ features (enhanced pattern matching, improved async, JIT-friendly patterns)
   - Use Python 3.13+ features (TypedDict for **kwargs, improved type hints)
   - Use type unions with `|`, pattern matching, ExceptionGroup, type parameter syntax
   - Add comprehensive type hints with modern syntax
   - **Apply fail-fast**: Validate inputs at entry, fail loudly with clear exceptions
   - Implement proper error handling (specific exceptions, no returning None on errors)
   - **Use strict validation**: Pydantic `strict=True`, no lenient defaults
   - Use async/await correctly with improved 3.14 features
   - Add docstrings for public APIs

4. **Review implementation**
   - Self-review against best practices
   - Check fail-fast patterns (input validation, no silent failures)
   - Verify simplicity (no unnecessary complexity)
   - Run type checker (mypy/pyright)
   - Suggest improvements if needed

### For Reviewing Existing Code

1. **Identify code type**
   - Standard Python application/library
   - Web API (FastAPI, Django, Flask)
   - Data pipeline (pandas, dask, etc.)
   - CLI tool
   - Async application

2. **Load relevant references**
   - Always load: [references/modern-python-2025.md](references/modern-python-2025.md)
   - For async: [references/async-patterns.md](references/async-patterns.md)
   - For web: [references/fastapi-patterns.md](references/fastapi-patterns.md)
   - For type safety: [references/type-safety-patterns.md](references/type-safety-patterns.md)

3. **Analyze code**
   - Check against patterns in references
   - Identify issues by severity (critical, important, nice-to-have)
   - Note positive patterns

4. **Provide structured feedback**
   - Use the review format below
   - Include code examples for improvements
   - Explain the reasoning

## Review Output Format

Structure code reviews as:

```markdown
## Review of <filename>

### Summary
Brief overview of the code and its purpose.

### Critical Issues
- **Line X**: <issue description>
  ```python
  # Current (problematic)
  <current code>

  # Suggested (improved)
  <improved code>
  ```
  **Why**: <explanation>

### Important Issues
<same format>

### Nice-to-Have Improvements
<same format>

### Positive Patterns
- <what the code does well>

### Fail-Fast Analysis
- **Input validation**: Does code validate inputs at function entry?
- **Error handling**: Does code fail loudly with clear exceptions (no returning None/False on errors)?
- **Silent failures**: Are exceptions caught and logged/re-raised, or swallowed?
- **Strict validation**: Is Pydantic using `strict=True` where appropriate?
- **Early detection**: Are preconditions checked early?

### Simplicity Analysis
- **Complexity**: Is the solution as simple as possible, or unnecessarily complex?
- **Testability**: Can this code be tested immediately in isolation?
- **Iterability**: Is it easy to refactor and improve?

### Type Safety Analysis (if applicable)
- <type hint coverage, Any usage, generic usage>

### Async Patterns Review (if applicable)
- <async/await correctness, blocking calls, cancellation handling>

### Security Review (if applicable)
- <SQL injection, command injection, XSS, secrets management>
```

## Tool Integration

When requested, run these tools:

### Linting and Formatting
```bash
# Black - code formatter
black --check .

# Ruff - fast linter
ruff check .

# isort - import sorter
isort --check-only .
```

### Type Checking
```bash
# mypy - static type checker
mypy . --strict

# pyright - alternative type checker
pyright .
```

### Testing
```bash
# pytest - test runner
pytest -v

# pytest with coverage
pytest --cov=package --cov-report=term-missing
```

## Context-Aware Guidance

The assistant adapts based on the codebase:

- **General Python project**: Focus on modern-python-2025.md and type-safety-patterns.md
- **FastAPI/Web API**: Add web-specific guidance from fastapi-patterns.md
- **Async application**: Emphasize async-patterns.md
- **CLI tool**: Focus on argparse/click, error messages, user experience
- **Library**: Emphasize API design, exported types, documentation
- **Data pipeline**: Focus on pandas/polars best practices, memory efficiency

## Fail-Fast and Early Development Principles

### Fail-Fast Practices

**CRITICAL**: Apply fail-fast principles to catch errors early and prevent silent failures.

- ✅ **Validate inputs early**: Check preconditions at function entry, fail immediately on invalid input
- ✅ **Fail loudly**: Raise specific exceptions with clear messages instead of returning None/False
- ✅ **No silent errors**: Never catch exceptions without logging or re-raising
- ✅ **Strict validation**: Use Pydantic `strict=True`, no lenient defaults
- ✅ **Early detection**: Use assertions for invariants (disabled in production)
- ✅ **No default fallbacks**: Don't silently fall back to defaults when operations fail

**Examples**:
```python
# ❌ BAD: Silent failure
def get_user(user_id: int) -> User | None:
    try:
        return db.query(User).filter(User.id == user_id).first()
    except Exception:
        return None  # Silently hides errors

# ✅ GOOD: Fail-fast with clear error
def get_user(user_id: int) -> User:
    if user_id <= 0:
        raise ValueError(f"Invalid user_id: {user_id}")

    user = db.query(User).filter(User.id == user_id).first()
    if user is None:
        raise UserNotFoundError(f"User {user_id} not found")
    return user
```

### Early Development Practices

- ✅ **Start simple**: Build minimum viable solution first, add complexity only when needed
- ✅ **Test immediately**: Write test before or right after implementation, run it
- ✅ **Iterate quickly**: Get working code fast, then refine
- ✅ **Validate assumptions**: Test edge cases early, don't wait for integration
- ✅ **Refactor fearlessly**: If design is wrong, fix it now (especially for features < 3 months old)

**When NOT to Fail-Fast**:
- User-facing operations (provide graceful degradation with clear error messages)
- Network/IO operations (retry with exponential backoff)
- Optional features (log warning and continue)

## Key Principles

1. **Type Safety**: Comprehensive type hints, use of generics, Protocol, TypeVar, TypedDict for **kwargs
2. **Fail-Fast**: Validate inputs early, fail loudly with clear exceptions, no silent failures, no returning None on errors
3. **Simplicity First**: Start with minimal solution, add complexity only when needed, easy to test and iterate
4. **Modern Features**: Python 3.14+ features (JIT compiler, enhanced pattern matching, improved async)
5. **Modern Features**: Python 3.13+ features (TypedDict **kwargs, improved error messages)
6. **Modern Features**: Python 3.12+ features (type parameter syntax, @override decorator)
7. **Modern Features**: Python 3.11+ features (ExceptionGroup, Self, TaskGroup, pattern matching)
8. **Async Correctness**: No blocking in async, proper cancellation, task lifecycle, use 3.14 improvements
9. **Error Handling**: Specific exceptions, proper chaining with `from`, clear messages, no lenient fallbacks
10. **Code Style**: PEP 8 compliance, clear naming, focused functions
11. **Testing**: pytest, fixtures, mocks, async testing with pytest-asyncio, test immediately after implementation
12. **Security**: No SQL/command injection, secrets in environment, input validation at entry points
13. **Performance**: Use JIT-friendly patterns, generators, avoid N+1 queries, profile before optimizing
14. **Documentation**: Docstrings for public APIs, type hints as documentation

## Reference Files

- **modern-python-2025.md**: Modern Python 3.14+ features (JIT, enhanced patterns), 3.13+ (TypedDict **kwargs), 3.12+ (type params, @override), 3.11+ features, type hints, error handling, async/await, best practices
- **type-safety-patterns.md**: Type hints, generics, Protocol, TypeVar, TypedDict, avoiding Any, type narrowing
- **async-patterns.md**: Async/await best practices with 3.14 improvements, task management, cancellation, common pitfalls
- **fastapi-patterns.md**: FastAPI-specific patterns, dependency injection, request validation, error handling
- **uv-guide.md**: UV package manager usage, project setup, dependency management, workflows

Load references as needed based on the task at hand.

## Package Management with UV

Use UV for all package management tasks:

```bash
# Project setup
uv init my-project
uv venv
uv sync

# Add dependencies
uv add fastapi pydantic
uv add --dev pytest ruff pyright

# Run commands
uv run python script.py
uv run pytest
uv run ruff check .
```

See [references/uv-guide.md](references/uv-guide.md) for complete UV documentation.

## Example Usage

### Example 1: Writing New Async API Endpoint

**User**: "Help me write an async FastAPI endpoint that creates a user"

**Assistant**:
1. Loads modern-python-2025.md and fastapi-patterns.md
2. Implements endpoint with:
   - **Fail-fast**: Input validation with Pydantic strict mode, early precondition checks
   - **Simple first**: Minimal endpoint implementation, easy to test
   - Type hints for request/response
   - Proper async/await usage
   - Error handling with HTTPException (fail loudly on errors, no returning None)
   - Dependency injection for database
   - Input validation with Pydantic (strict=True where appropriate)
3. Provides test example with pytest-asyncio

### Example 2: Reviewing Existing Code

**User**: "Review this user service code"

**Assistant**:
1. Loads modern-python-2025.md, type-safety-patterns.md, async-patterns.md
2. Analyzes code for:
   - **Fail-fast issues**: Missing input validation, silent failures (returning None), lenient validation
   - **Simplicity issues**: Unnecessary complexity, difficult to test in isolation
   - Type safety issues
   - Async anti-patterns (blocking calls)
   - Error handling gaps (no clear exceptions, catching without re-raising)
   - Security issues (SQL injection, missing input validation at entry)
   - Performance issues (N+1 queries)
3. Provides structured review with code examples including fail-fast improvements

### Example 3: Refactoring to Modern Python

**User**: "Help me refactor this old Python 3.7 code to modern Python 3.14+"

**Assistant**:
1. Loads modern-python-2025.md
2. Identifies opportunities:
   - Replace `Union[X, None]` with `X | None`
   - Use enhanced pattern matching (3.14)
   - Use TypedDict for **kwargs (3.13)
   - Use type parameter syntax (3.12)
   - Use ExceptionGroup for multiple errors (3.11)
   - Add comprehensive type hints with modern syntax
   - Use dataclasses or Pydantic models
   - Optimize for JIT compiler (3.14)
3. Provides refactored code with explanations
