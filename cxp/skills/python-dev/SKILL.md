---
name: python-dev
description: Expert Python development assistant for writing new code and reviewing existing codebases. Covers modern Python idioms (Python 3.13+), best practices, type safety, async patterns, structured logging, and idiomatic error handling.
---

# Python Development Assistant

Expert assistant for Python development, covering both writing new code and reviewing existing codebases with modern Python idioms (Python 3.13+) and best practices.

## Core Capabilities

### 1. Writing New Python Code
When writing new Python code:
- **Use modern Python 3.11-3.13 features**:
  - Python 3.13: TypedDict for **kwargs, improved error messages, improved typing
  - Python 3.12: type parameter syntax, @override decorator
  - Python 3.11: ExceptionGroup, Self type, TaskGroup, pattern matching (`match`/`case`)
- Apply type hints comprehensively (parameters, returns, attributes)
- **Implement specific exception handling**: Catch specific exceptions, never broad `Exception` in library code
- **Apply fail-fast principles**: Validate inputs early, fail loudly, no silent failures
- **Start simple and iterate**: Build minimal solution first, add complexity only when needed
- **Use structured logging**: `logger.debug("event key=%s", value)` format with % formatting (NOT f-strings)
- Apply async/await patterns correctly (no blocking in async functions)
- **Avoid thin wrappers**: Only create wrappers that add transformation, logging, or coordination value
- Use dataclasses, pydantic models for data structures
- Follow PEP 8 and modern Python conventions

**Reference**: [references/modern-python-2025.md](references/modern-python-2025.md)

### 2. Reviewing Existing Python Code
When reviewing Python code:
- Check for type safety (comprehensive type hints, no `Any` abuse)
- **Check exception handling**: Specific exceptions in library code, broad catches only in allowed modules (CLI, executors, tools)
- **Check fail-fast patterns**: Input validation at entry, no silent failures, fail loudly on errors
- **Check early development patterns**: Simple before complex, easily testable, quick to iterate
- **Check for thin wrappers**: Identify functions that just forward calls without adding value
- **Check logging format**: Structured `event key=value` format, % formatting (not f-strings), lowercase with underscores
- Identify async/await anti-patterns
- Review error handling (specific exceptions, proper chaining with `from e`, no returning None on errors)
- Look for performance issues (N+1 queries, blocking calls)
- Validate security patterns (SQL injection, command injection, XSS)
- Check testing patterns (pytest best practices, fixtures, mocks, manual CLI testing)
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
   - **Use modern Python 3.11-3.13 features**:
     - Python 3.13: TypedDict for **kwargs, improved type hints, improved error messages
     - Python 3.12: type parameter syntax, @override decorator
     - Python 3.11: ExceptionGroup, Self type, TaskGroup, pattern matching
   - Add comprehensive type hints with modern syntax
   - **Catch specific exceptions**: Never catch broad `Exception` in library code, only in allowed modules (CLI, executors, tools, tests)
   - **Apply fail-fast**: Validate inputs at entry, fail loudly with clear exceptions, use exception chaining with `from e`
   - **Avoid thin wrappers**: Only create functions that add transformation, logging, error context, or coordination
   - **Use structured logging**: Format as `logger.debug("event key=%s", value)` with % formatting, lowercase event names
   - **Use strict validation**: Pydantic `strict=True`, no lenient defaults
   - Use async/await correctly
   - Add docstrings for public APIs

4. **Review implementation**
   - Self-review against best practices
   - Check exception handling (specific exceptions, proper use of broad catches)
   - Check fail-fast patterns (input validation, no silent failures)
   - Verify simplicity (no unnecessary complexity, no thin wrappers)
   - Check logging format (structured, % formatting, lowercase)
   - Run type checker (mypy/pyright)
   - **Perform manual CLI testing** if implementing CLI commands
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

### Exception Handling Analysis
- **Specific exceptions**: Does library code catch specific exceptions, not broad `Exception`?
- **Broad catches**: Are broad catches only in allowed modules (CLI, executors, tools, tests)?
- **Exception chaining**: Does code use `from e` to preserve original exceptions?
- **Documented catches**: Are broad catches documented with clear rationale?

### Fail-Fast Analysis
- **Input validation**: Does code validate inputs at function entry?
- **Error handling**: Does code fail loudly with clear exceptions (no returning None/False on errors)?
- **Silent failures**: Are exceptions caught and logged/re-raised, or swallowed?
- **Strict validation**: Is Pydantic using `strict=True` where appropriate?
- **Early detection**: Are preconditions checked early?

### Function Abstraction Analysis
- **Thin wrappers**: Are there functions that just forward calls without adding value?
- **Wrapper value**: Do wrappers add transformation, logging, error context, or coordination?
- **Naming**: Could internal functions be public with better names?

### Logging Standards Analysis
- **Format**: Is logging using `event key=value` structured format?
- **Lazy evaluation**: Using % formatting (not f-strings)?
- **Capitalization**: Lowercase with underscores (snake_case)?
- **Log levels**: INFO for user-visible, DEBUG for implementation details?

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

### Testing Review (if applicable)
- **Test markers**: Are tests properly marked (unit, integration, slow, fast)?
- **Manual testing**: For CLI commands, is manual smoke testing documented/performed?
- **Coverage**: Are edge cases and error paths tested?
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

1. **Modern Python Features** (3.11-3.13): TypedDict for **kwargs (3.13), improved error messages (3.13), type parameter syntax (3.12), @override decorator (3.12), ExceptionGroup (3.11), Self type (3.11), TaskGroup (3.11), pattern matching (3.11)
2. **Type Safety**: Comprehensive type hints, use of generics, Protocol, TypeVar, TypedDict for **kwargs
3. **Exception Handling**: Catch specific exceptions in library code, broad catches only in allowed modules (CLI, executors, tools, tests), always chain with `from e`
4. **Fail-Fast**: Validate inputs early, fail loudly with clear exceptions, no silent failures, no returning None on errors
5. **Simplicity First**: Start with minimal solution, add complexity only when needed, easy to test and iterate
6. **Function Abstraction**: Avoid thin wrappers that just forward calls, only create wrappers that add transformation, logging, error context, or coordination
7. **Structured Logging**: Format as `logger.debug("event key=%s", value)` with % formatting (NOT f-strings), lowercase event names, INFO for user-visible, DEBUG for implementation
8. **Async Correctness**: No blocking in async, proper cancellation, task lifecycle
9. **Code Style**: PEP 8 compliance, clear naming, focused functions
10. **Testing**: pytest, fixtures, mocks, async testing with pytest-asyncio, **manual CLI smoke testing required**, test immediately after implementation
11. **Security**: No SQL/command injection, secrets in environment, input validation at entry points
12. **Performance**: Generators, avoid N+1 queries, profile before optimizing
13. **Documentation**: Docstrings for public APIs, type hints as documentation

## Reference Files

- **modern-python-2025.md**: Modern Python 3.11-3.13 features, type hints, error handling, async/await, best practices
- **type-safety-patterns.md**: Type hints, generics, Protocol, TypeVar, TypedDict, avoiding Any, type narrowing
- **async-patterns.md**: Async/await best practices, task management, cancellation, common pitfalls
- **fastapi-patterns.md**: FastAPI-specific patterns, dependency injection, request validation, error handling
- **uv-guide.md**: UV package manager usage, project setup, dependency management, workflows

Load references as needed based on the task at hand.

## Modern Python Best Practices Summary

This skill incorporates modern Python development best practices:

- **Exception Handling Policy**: Specific exceptions in library code, documented broad catches only in allowed modules
- **Function Abstraction Guidelines**: Avoid thin wrappers, decision framework for creating wrappers
- **Logging Standards**: Structured format `event key=value`, % formatting, lowercase, appropriate log levels
- **Manual Testing**: Always perform manual CLI smoke testing after implementation
- **Test Organization**: Use markers (unit, integration, slow, fast), separate test suites, proper fixtures
- **Development Workflow**: `make dev` (lint + fast tests), `make ci` (full workflow), manual testing checklist

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

**User**: "Help me refactor this old Python 3.7 code to modern Python 3.13"

**Assistant**:
1. Loads modern-python-2025.md
2. Identifies opportunities:
   - Replace `Union[X, None]` with `X | None`
   - Use TypedDict for **kwargs (3.13)
   - Use type parameter syntax (3.12)
   - Use @override decorator (3.12)
   - Use pattern matching for complex conditionals (3.11)
   - Use ExceptionGroup for multiple errors (3.11)
   - Use Self type for method chaining (3.11)
   - Add comprehensive type hints with modern syntax
   - Catch specific exceptions, avoid broad `Exception`
   - Use structured logging with % formatting
   - Use dataclasses or Pydantic models
3. Provides refactored code with explanations
