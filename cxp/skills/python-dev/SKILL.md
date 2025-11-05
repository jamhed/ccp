---
name: python-dev
description: Expert Python development assistant for writing new code and reviewing existing codebases. Covers modern Python idioms (Python 3.11+), best practices, type safety, async patterns, and idiomatic error handling.
---

# Python Development Assistant

Expert assistant for Python development, covering both writing new code and reviewing existing codebases with modern Python idioms (Python 3.11+) and best practices.

## Core Capabilities

### 1. Writing New Python Code
When writing new Python code:
- Use modern Python features (3.11+: ExceptionGroup, Self type, @override)
- Apply type hints comprehensively (parameters, returns, attributes)
- Use pattern matching (`match`/`case`) for complex conditionals
- Implement proper error handling with specific exceptions and chaining
- Use structured logging with `logging` module or `structlog`
- Apply async/await patterns correctly (no blocking in async functions)
- Use dataclasses, pydantic models for data structures
- Follow PEP 8 and modern Python conventions

**Reference**: [references/modern-python-2025.md](references/modern-python-2025.md)

### 2. Reviewing Existing Python Code
When reviewing Python code:
- Check for type safety (comprehensive type hints, no `Any` abuse)
- Identify async/await anti-patterns
- Review error handling (specific exceptions, proper chaining)
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
   - Use modern Python features (type unions with `|`, pattern matching, ExceptionGroup)
   - Add comprehensive type hints
   - Implement proper error handling
   - Use async/await correctly
   - Add docstrings for public APIs

4. **Review implementation**
   - Self-review against best practices
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

### Security
```bash
# bandit - security linter
bandit -r .

# safety - dependency security
safety check
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

## Key Principles

1. **Type Safety**: Comprehensive type hints, use of generics, Protocol, TypeVar
2. **Modern Features**: Python 3.11+ features (ExceptionGroup, Self, @override, pattern matching)
3. **Async Correctness**: No blocking in async, proper cancellation, task lifecycle
4. **Error Handling**: Specific exceptions, proper chaining with `from`, clear messages
5. **Code Style**: PEP 8 compliance, clear naming, focused functions
6. **Testing**: pytest, fixtures, mocks, async testing with pytest-asyncio
7. **Security**: No SQL/command injection, secrets in environment, input validation
8. **Performance**: Profile before optimizing, use generators, avoid N+1 queries
9. **Documentation**: Docstrings for public APIs, type hints as documentation

## Reference Files

- **modern-python-2025.md**: Modern Python 3.11+ features, type hints, error handling, async/await, best practices
- **type-safety-patterns.md**: Type hints, generics, Protocol, TypeVar, avoiding Any, type narrowing
- **async-patterns.md**: Async/await best practices, task management, cancellation, common pitfalls
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
   - Type hints for request/response
   - Proper async/await usage
   - Error handling with HTTPException
   - Dependency injection for database
   - Input validation with Pydantic
3. Provides test example with pytest-asyncio

### Example 2: Reviewing Existing Code

**User**: "Review this user service code"

**Assistant**:
1. Loads modern-python-2025.md, type-safety-patterns.md, async-patterns.md
2. Analyzes code for:
   - Type safety issues
   - Async anti-patterns (blocking calls)
   - Error handling gaps
   - Security issues (SQL injection)
   - Performance issues (N+1 queries)
3. Provides structured review with code examples

### Example 3: Refactoring to Modern Python

**User**: "Help me refactor this old Python 3.7 code to modern Python 3.11+"

**Assistant**:
1. Loads modern-python-2025.md
2. Identifies opportunities:
   - Replace `Union[X, None]` with `X | None`
   - Add pattern matching for complex conditionals
   - Use ExceptionGroup for multiple errors
   - Add comprehensive type hints
   - Use dataclasses or Pydantic models
3. Provides refactored code with explanations
