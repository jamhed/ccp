---
name: python-dev
description: Expert Python development assistant for 2025 - Python 3.14+, t-strings, deferred annotations, free-threading, uv package manager, async patterns, type safety, fail-fast principles
---

# Python Development Assistant (2025)

Expert assistant for Python development in 2025, covering modern Python 3.14+ features (t-strings, deferred annotations, free-threading), uv package manager, async patterns, and production-ready best practices.

## Core Capabilities

### 1. Writing New Python Code (2025)
When writing new Python code in 2025:
- **Use modern Python 3.14+ features** (current 2025 version):
  - **Python 3.14** (Oct 2025 - current): t-strings (PEP 750) for templates, deferred annotations evaluation, REPL syntax highlighting, improved free-threading
  - **Python 3.13** (Oct 2024): TypedDict for **kwargs, improved error messages with color, JIT compiler (experimental), free-threaded mode (experimental), new interactive interpreter
  - **Python 3.12**: type parameter syntax, @override decorator
  - **Python 3.11**: ExceptionGroup, Self type, TaskGroup, pattern matching (`match`/`case`)
- Apply type hints comprehensively with deferred annotations (3.14+)
- **Use uv package manager** (2025 standard - 10-100x faster than pip)
- **Implement specific exception handling**: Catch specific exceptions, never broad `Exception` in library code
- **Apply fail-fast principles**: Validate inputs early, fail loudly, no silent failures
- **Start simple and iterate**: Build minimal solution first, add complexity only when needed
- **Use structured logging**: `logger.debug("event key=%s", value)` format with % formatting (NOT f-strings)
- Apply async/await patterns correctly (no blocking in async functions, use asyncio.gather for concurrency)
- **Consider free-threading** for CPU-bound tasks (Python 3.13+, GIL-free experimental mode)
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

3. **Implement code (2025)**
   - **Use uv for dependencies**: `uv add package-name` (10-100x faster than pip)
   - **Start simple**: Build minimum viable solution first, iterate based on tests
   - **Use modern Python 3.14+ features** (2025 current):
     - **Python 3.14**: t-strings for templates, deferred annotations, REPL syntax highlighting, improved free-threading
     - **Python 3.13**: TypedDict for **kwargs, improved error messages with color, JIT compiler, free-threaded mode, new interactive interpreter
     - **Python 3.12**: type parameter syntax, @override decorator
     - **Python 3.11**: ExceptionGroup, Self type, TaskGroup, pattern matching
   - Add comprehensive type hints with deferred annotations (3.14+)
   - **Catch specific exceptions**: Never catch broad `Exception` in library code, only in allowed modules (CLI, executors, tools, tests)
   - **Apply fail-fast**: Validate inputs at entry, fail loudly with clear exceptions, use exception chaining with `from e`
   - **Avoid thin wrappers**: Only create functions that add transformation, logging, error context, or coordination
   - **Use structured logging**: Format as `logger.debug("event key=%s", value)` with % formatting, lowercase event names
   - **Use strict validation**: Pydantic `strict=True`, no lenient defaults
   - Use async/await correctly (asyncio.gather for concurrency, avoid deadlocks)
   - **Consider free-threading** for CPU-bound tasks if using Python 3.13+
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

**CRITICAL**: Apply fail-fast principles to catch errors early and prevent silent failures.

**Fail-Fast Summary**:
- ✅ Validate inputs early at function entry
- ✅ Fail loudly with specific exceptions (not None/False)
- ✅ No silent errors (no catch-and-ignore)
- ✅ Strict validation (Pydantic `strict=True`)

**Early Development**:
- ✅ Start simple, add complexity when needed
- ✅ Test immediately after implementation
- ✅ Iterate quickly, refactor fearlessly

**For comprehensive fail-fast patterns and examples**, see [references/type-safety-patterns.md](references/type-safety-patterns.md):
- Input validation strategies
- Error handling patterns
- Type narrowing and strict checks
- Avoiding defensive programming
- Validation at construction time
- Type-safe error handling

## Key Principles (2025)

1. **Modern Python Features** (3.14+): t-strings for templates (3.14), deferred annotations (3.14), free-threading improvements (3.14), TypedDict for **kwargs (3.13), improved error messages with color (3.13), JIT compiler (3.13), type parameter syntax (3.12), @override decorator (3.12), ExceptionGroup (3.11), Self type (3.11), TaskGroup (3.11), pattern matching (3.11)
2. **Package Management**: uv (2025 standard - 10-100x faster than pip), pipx for tools, no global pip installs
3. **Type Safety**: Comprehensive type hints with deferred annotations (3.14+), use of generics, Protocol, TypeVar, TypedDict for **kwargs
4. **Exception Handling**: Catch specific exceptions in library code, broad catches only in allowed modules (CLI, executors, tools, tests), always chain with `from e`
5. **Fail-Fast**: Validate inputs early, fail loudly with clear exceptions, no silent failures, no returning None on errors
6. **Simplicity First**: Start with minimal solution, add complexity only when needed, easy to test and iterate
7. **Function Abstraction**: Avoid thin wrappers that just forward calls, only create wrappers that add transformation, logging, error context, or coordination
8. **Structured Logging**: Format as `logger.debug("event key=%s", value)` with % formatting (NOT f-strings), lowercase event names, INFO for user-visible, DEBUG for implementation
9. **Async Correctness**: No blocking in async, asyncio.gather for concurrency, proper cancellation, task lifecycle, avoid deadlocks
10. **Free-Threading** (3.13+): Consider for CPU-bound tasks, experimental GIL-free mode
11. **Code Style**: PEP 8 compliance, clear naming, focused functions
12. **Testing**: pytest with pytest-asyncio 1.3.0+ (supports Python 3.10-3.14), fixtures, AsyncMock, **manual CLI smoke testing required**, test immediately after implementation
13. **Security**: No SQL/command injection, secrets in environment, input validation at entry points
14. **Performance**: Generators, avoid N+1 queries, asyncio.gather for concurrent I/O, profile before optimizing
15. **Documentation**: Docstrings for public APIs, type hints as documentation

## Reference Files (2025)

- **modern-python-2025.md**: Modern Python 3.14+ features (t-strings, deferred annotations, free-threading), Python 3.13 (TypedDict for **kwargs, JIT, free-threaded mode), type hints, error handling, async/await, best practices
- **type-safety-patterns.md**: Type hints with deferred annotations (3.14+), generics, Protocol, TypeVar, TypedDict, avoiding Any, type narrowing
- **async-patterns.md**: Async/await best practices, asyncio.gather for concurrency, task management, cancellation, avoiding deadlocks, pytest-asyncio 1.3.0+
- **fastapi-patterns.md**: FastAPI-specific patterns, dependency injection, request validation, error handling, async routes
- **uv-guide.md**: uv package manager (2025 standard - 10-100x faster than pip), project setup, dependency management, workflows

Load references as needed based on the task at hand.

## Modern Python Best Practices Summary

This skill incorporates modern Python development best practices:

- **Exception Handling Policy**: Specific exceptions in library code, documented broad catches only in allowed modules
- **Function Abstraction Guidelines**: Avoid thin wrappers, decision framework for creating wrappers
- **Logging Standards**: Structured format `event key=value`, % formatting, lowercase, appropriate log levels
- **Manual Testing**: Always perform manual CLI smoke testing after implementation
- **Test Organization**: Use markers (unit, integration, slow, fast), separate test suites, proper fixtures
- **Development Workflow**: `make dev` (lint + fast tests), `make ci` (full workflow), manual testing checklist

## Package Management with uv (2025 Standard)

**ALWAYS use uv for package management** - it's 10-100x faster than pip and the 2025 industry standard:

```bash
# Project setup (2025 workflow)
uv init my-project
uv venv
uv sync

# Add dependencies (10-100x faster than pip install)
uv add fastapi pydantic
uv add --dev pytest pytest-asyncio ruff pyright

# Run commands
uv run python script.py
uv run pytest -n auto  # Parallel testing
uv run ruff check .

# Python 3.14+ specific
uv python install 3.14  # Install Python 3.14
uv venv --python 3.14   # Create venv with Python 3.14
```

**Why uv in 2025**:
- 10-100x faster than pip
- Built in Rust, reliable dependency resolution
- Unified tool (replaces pip, pip-tools, virtualenv, pyenv)
- Industry standard for Python development

See [references/uv-guide.md](references/uv-guide.md) for complete uv documentation.

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

**User**: "Help me refactor this old Python 3.7 code to modern Python 3.14"

**Assistant**:
1. Loads modern-python-2025.md
2. Identifies 2025 opportunities:
   - Use t-strings (template strings) for string templating (3.14)
   - Use deferred annotations for faster module loading (3.14)
   - Replace `Union[X, None]` with `X | None`
   - Use TypedDict for **kwargs (3.13)
   - Use type parameter syntax (3.12)
   - Use @override decorator (3.12)
   - Use pattern matching for complex conditionals (3.11)
   - Use ExceptionGroup for multiple errors (3.11)
   - Use Self type for method chaining (3.11)
   - Add comprehensive type hints with deferred annotations
   - Catch specific exceptions, avoid broad `Exception`
   - Use structured logging with % formatting
   - Use uv for package management
   - Use async/await with asyncio.gather for concurrency
   - Consider free-threading for CPU-bound tasks (3.13+)
   - Use dataclasses or Pydantic models
3. Provides refactored code with explanations and 2025 best practices
