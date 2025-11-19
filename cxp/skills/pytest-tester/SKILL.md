---
name: pytest-tester
description: Expert for pytest testing in 2025 - pytest-asyncio 1.3.0+, AsyncMock, async fixtures, asyncio.gather optimization, uv parallel testing, Python 3.14+ support
---

# Pytest Testing Expert (2025)

Expert skill for writing high-quality pytest tests in 2025 with pytest-asyncio 1.3.0+ (supports Python 3.10-3.14), async patterns, and modern testing practices.

## Core Capabilities (2025)

### 1. Writing Pytest Tests (2025)
When writing new tests in 2025:
- Use pytest idioms (assert statements, fixtures, parametrize)
- Organize tests clearly (test_file.py, test classes, descriptive names)
- Use fixtures for setup/teardown and dependency injection
- **Use async fixtures with pytest-asyncio 1.3.0+** (supports Python 3.10-3.14)
- Apply parametrize for testing multiple scenarios
- **Use AsyncMock for async mocking** (Python 3.8+)
- **Optimize with asyncio.gather** for concurrent async test setup
- Test async code with @pytest.mark.asyncio
- **Run tests in parallel** with `uv run pytest -n auto`
- Achieve good coverage (>80%)

### 2. Debugging Test Failures
When tests fail:
- Analyze failure output and stack traces
- Identify root cause (test bug vs code bug)
- Use pytest debugging features (-v, -s, --pdb, --lf, --ff)
- Check fixture lifecycle and scope
- Verify mock configurations
- Review async test execution

### 3. Reviewing Test Code
When reviewing tests:
- Check test clarity and organization
- Verify proper use of fixtures
- Review mock usage (not over-mocking)
- Ensure tests are isolated and deterministic
- Check async test patterns
- Validate coverage of edge cases

## When to Use This Skill

Use this skill when:
- Writing new pytest tests (unit, integration, E2E)
- Debugging failing tests
- Reviewing test code quality
- Setting up pytest configuration
- Implementing test fixtures
- Testing async code
- Improving test coverage

## Manual Testing Best Practices

**CRITICAL**: Always perform manual smoke testing of CLI commands after implementation.

### Why Manual Testing Matters

- Integration tests may mock async execution or miss edge cases
- Runtime warnings (coroutines, async/await bugs) only appear in actual execution
- CLI UX issues (formatting, error messages) need human verification

### Lesson Learned

**Issue Example**:
- Tool execution had missing `await` wrapper
- Result: Returned coroutine object instead of executing, RuntimeWarning
- Root cause: Async code path not manually tested
- Discovery: User ran command and encountered error
- All integration tests passed, but didn't catch the runtime async bug

### Manual Testing Checklist

1. Run automated tests: `pytest tests/integration/cli/test_<command>.py -v`
2. Manual smoke test: Run actual CLI command with real data
3. Test all output formats: `--output-format=text|json|query` (or equivalent)
4. Test error conditions (invalid input, missing resources)
5. Test with verbose logging: `-v`, `-vv` (catch warnings)

### Example Manual Testing

```bash
# Test primary code path with real data
python -m myapp command --args

# Test all output formats
python -m myapp command --output-format=json
python -m myapp command --output-format=query

# Test error conditions
python -m myapp command invalid-input  # Invalid input
python -m myapp nonexistent-command   # Missing command

# Test with verbose logging to catch warnings
python -m myapp command -vv
```

## Pytest Best Practices

### Test Organization

```python
# tests/test_user_service.py

import pytest
from app.services.user import UserService
from app.models import User

class TestUserService:
    """Tests for UserService"""

    def test_create_user_success(self, db_session):
        """Should create user with valid data"""
        service = UserService(db_session)
        user = service.create_user(name="John", email="john@example.com")

        assert user.id is not None
        assert user.name == "John"
        assert user.email == "john@example.com"

    def test_create_user_invalid_email(self, db_session):
        """Should raise ValueError for invalid email"""
        service = UserService(db_session)

        with pytest.raises(ValueError, match="Invalid email"):
            service.create_user(name="John", email="invalid")

    @pytest.mark.parametrize("name,email,expected_error", [
        ("", "valid@example.com", "Name required"),
        ("John", "", "Email required"),
        ("A", "valid@example.com", "Name too short"),
    ])
    def test_create_user_validation(self, db_session, name, email, expected_error):
        """Should validate user input"""
        service = UserService(db_session)

        with pytest.raises(ValueError, match=expected_error):
            service.create_user(name=name, email=email)
```

### Fixtures

```python
# tests/conftest.py

import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.database import Base

@pytest.fixture(scope="session")
def engine():
    """Create test database engine"""
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(engine)
    yield engine
    engine.dispose()

@pytest.fixture(scope="function")
def db_session(engine):
    """Create database session for each test"""
    Session = sessionmaker(bind=engine)
    session = Session()
    yield session
    session.rollback()
    session.close()

@pytest.fixture
def user_factory(db_session):
    """Factory for creating test users"""
    def create_user(**kwargs):
        defaults = {"name": "Test User", "email": "test@example.com"}
        user = User(**{**defaults, **kwargs})
        db_session.add(user)
        db_session.commit()
        return user
    return create_user
```

### Mocking

```python
# tests/test_api_client.py

import pytest
from unittest.mock import Mock, patch, AsyncMock
from app.clients.api import APIClient

def test_fetch_user_success():
    """Should fetch user from API"""
    mock_response = Mock()
    mock_response.json.return_value = {"id": 1, "name": "John"}
    mock_response.status_code = 200

    with patch("requests.get", return_value=mock_response) as mock_get:
        client = APIClient()
        user = client.fetch_user(user_id=1)

        assert user["name"] == "John"
        mock_get.assert_called_once_with(
            "https://api.example.com/users/1",
            timeout=10
        )

@pytest.mark.asyncio
async def test_fetch_user_async():
    """Should fetch user asynchronously"""
    mock_client = AsyncMock()
    mock_client.get.return_value.json.return_value = {"id": 1, "name": "John"}

    with patch("httpx.AsyncClient", return_value=mock_client):
        client = APIClient()
        user = await client.fetch_user_async(user_id=1)

        assert user["name"] == "John"
```

### Async Testing (2025 with pytest-asyncio 1.3.0+)

**pytest-asyncio 1.3.0** (Nov 10, 2025) - Latest version supporting Python 3.10-3.14

```python
# tests/test_async_service.py

import pytest
import asyncio
from app.services.async_service import process_batch

@pytest.mark.asyncio
async def test_process_batch():
    """Should process items concurrently"""
    items = [1, 2, 3, 4, 5]
    results = await process_batch(items)

    assert len(results) == 5
    assert all(r is not None for r in results)

@pytest.mark.asyncio
async def test_process_with_timeout():
    """Should timeout long-running operations"""
    with pytest.raises(asyncio.TimeoutError):
        await asyncio.wait_for(process_batch([1, 2, 3]), timeout=0.1)
```

### Async Fixtures (2025 Best Practice)

**Async fixtures** are the backbone of well-structured async tests:

```python
# tests/conftest.py

import pytest
import httpx
from app.database import AsyncSession, engine

@pytest.fixture
async def async_db_session():
    """Async database session for each test"""
    async with AsyncSession() as session:
        yield session
        await session.rollback()

@pytest.fixture
async def http_client():
    """Shared async HTTP client"""
    async with httpx.AsyncClient() as client:
        yield client

@pytest.fixture
async def initialized_user(async_db_session):
    """Create and return a test user"""
    user = User(name="Test", email="test@example.com")
    async_db_session.add(user)
    await async_db_session.commit()
    return user
```

### Performance Optimization with asyncio.gather (2025)

**Concurrent preconditions** reduce test setup time dramatically:

```python
# tests/test_api.py

import pytest
import asyncio

@pytest.fixture
async def setup_data(async_db_session):
    """Setup multiple resources concurrently"""
    # ❌ BAD: Sequential (6 seconds for 2x 3-second operations)
    # user = await create_user()
    # posts = await create_posts()

    # ✅ GOOD: Concurrent with asyncio.gather (3 seconds total)
    user, posts = await asyncio.gather(
        create_user(async_db_session),
        create_posts(async_db_session)
    )
    return user, posts

@pytest.mark.asyncio
async def test_user_with_posts(setup_data):
    """Test with concurrently prepared data"""
    user, posts = setup_data
    assert len(posts) == 10
    assert posts[0].user_id == user.id
```

### AsyncMock for Mocking Async Functions (2025)

**Python 3.8+** includes `AsyncMock` for async mocking:

```python
# tests/test_api_client.py

import pytest
from unittest.mock import AsyncMock, patch

@pytest.mark.asyncio
async def test_fetch_user_async():
    """Should fetch user from API with AsyncMock"""
    # Create AsyncMock
    mock_get = AsyncMock(return_value={"id": 1, "name": "John"})

    with patch("httpx.AsyncClient.get", mock_get):
        from app.clients import fetch_user
        user = await fetch_user(user_id=1)

        assert user["name"] == "John"
        mock_get.assert_called_once()

@pytest.mark.asyncio
async def test_service_with_multiple_async_mocks():
    """Test with multiple async dependencies"""
    mock_db = AsyncMock()
    mock_cache = AsyncMock()

    mock_db.fetch_user.return_value = {"id": 1, "name": "Alice"}
    mock_cache.get.return_value = None

    from app.services import UserService
    service = UserService(db=mock_db, cache=mock_cache)
    user = await service.get_user(user_id=1)

    assert user["name"] == "Alice"
    mock_db.fetch_user.assert_awaited_once_with(user_id=1)
    mock_cache.get.assert_awaited_once()
```

### Avoiding Deadlocks in Async Tests (2025)

**Manage fixture dependencies** carefully to prevent deadlocks:

```python
# tests/conftest.py

import pytest

# ❌ BAD: Potential deadlock with circular dependencies
@pytest.fixture
async def fixture_a(fixture_b):
    await asyncio.sleep(0.1)
    return "a"

@pytest.fixture
async def fixture_b(fixture_a):  # Circular!
    await asyncio.sleep(0.1)
    return "b"

# ✅ GOOD: Clear dependency chain, event loop remains unblocked
@pytest.fixture
async def database():
    """Base resource"""
    async with create_db_pool() as pool:
        yield pool

@pytest.fixture
async def user_repository(database):
    """Depends on database"""
    return UserRepository(database)

@pytest.fixture
async def user_service(user_repository):
    """Depends on repository"""
    return UserService(user_repository)
```

### Parametrize

```python
# tests/test_validators.py

import pytest
from app.validators import validate_email

@pytest.mark.parametrize("email", [
    "valid@example.com",
    "user.name+tag@example.co.uk",
    "test_123@test-domain.com",
])
def test_validate_email_valid(email):
    """Should accept valid emails"""
    assert validate_email(email) is True

@pytest.mark.parametrize("email,error_message", [
    ("", "Email required"),
    ("invalid", "Invalid format"),
    ("@example.com", "Missing local part"),
    ("user@", "Missing domain"),
], ids=["empty", "no_at", "no_local", "no_domain"])
def test_validate_email_invalid(email, error_message):
    """Should reject invalid emails"""
    with pytest.raises(ValueError, match=error_message):
        validate_email(email)
```

## Test Markers and Organization (2025)

Use markers for selective test execution (recommended markers):

- `@pytest.mark.unit` - Unit tests (< 1s, fast, parallel)
- `@pytest.mark.integration` - Integration tests (fast subset)
- `@pytest.mark.slow` - Slow tests (> 1s, timeout tests, sequential)
- `@pytest.mark.fast` - Fast tests (< 1s, parallel)
- `@pytest.mark.asyncio` - Async tests requiring pytest-asyncio 1.3.0+
- `@pytest.mark.timeout` - Tests involving timeout behavior

```bash
# Run only fast tests in parallel with uv (2025 standard)
uv run pytest -m fast -n auto

# Exclude slow tests
uv run pytest -m "not slow" -n auto

# Run timeout tests only
uv run pytest -m timeout -v

# Run all async tests
uv run pytest -m asyncio -v

# Run with coverage
uv run pytest --cov=app --cov-report=term-missing -n auto
```

## Pytest Configuration

### pytest.ini (2025)

```ini
[pytest]
minversion = 8.0
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
addopts =
    -v
    --strict-markers
    --strict-config
    --cov=app
    --cov-report=term-missing:skip-covered
    --cov-report=html
    --cov-fail-under=80
markers =
    unit: Unit tests (fast, parallel)
    integration: Integration tests
    slow: Slow tests (run with -m slow, sequential)
    fast: Fast tests (< 1s, parallel)
    asyncio: Async tests (pytest-asyncio 1.3.0+ required)
    timeout: Tests involving timeout behavior
# pytest-asyncio 1.3.0+ configuration (supports Python 3.10-3.14)
asyncio_mode = auto
asyncio_default_fixture_loop_scope = function
```

### pyproject.toml (alternative)

```toml
[tool.pytest.ini_options]
minversion = "7.0"
testpaths = ["tests"]
python_files = ["test_*.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
addopts = [
    "-v",
    "--strict-markers",
    "--cov=app",
    "--cov-report=term-missing",
]
markers = [
    "unit: Unit tests",
    "integration: Integration tests",
    "slow: Slow tests",
]
asyncio_mode = "auto"
```

## Common Pytest Commands (2025)

**ALWAYS use uv for running tests** (10-100x faster dependency resolution):

```bash
# Run all tests (2025 standard with uv)
uv run pytest

# Run with verbose output
uv run pytest -v

# Run in parallel (recommended for 2025)
uv run pytest -n auto

# Run specific test file
uv run pytest tests/test_user.py

# Run specific test function
uv run pytest tests/test_user.py::test_create_user

# Run specific test class
uv run pytest tests/test_user.py::TestUserService

# Run tests matching pattern
uv run pytest -k "test_create"

# Run tests with specific marker
uv run pytest -m integration
uv run pytest -m "not slow"        # Exclude slow tests
uv run pytest -m "fast and unit"   # Combine markers
uv run pytest -m asyncio           # Run only async tests

# Run last failed tests
uv run pytest --lf

# Run failed tests first
uv run pytest --ff

# Stop on first failure
uv run pytest -x

# Show local variables in tracebacks
uv run pytest -l

# Enter debugger on failure
uv run pytest --pdb

# Show print statements
uv run pytest -s

# Run with coverage (parallel)
uv run pytest --cov=app --cov-report=term-missing -n auto

# Run async tests with verbose asyncio debugging
uv run pytest -m asyncio -v -s

# Run only tests that changed
pytest --testmon

# Parallel execution
pytest -n auto  # requires pytest-xdist
```

## Development Workflow (recommended)

```bash
# Development cycle (lint + fast tests)
make dev

# CI workflow (lint + all tests + coverage)
make ci

# Specific test suites
make test-unit              # Unit tests (fast, parallel)
make test-integration       # Integration tests (fast, parallel)
make test-integration-slow  # Slow integration tests (sequential)
make test-all               # All tests

# Linting and formatting
make lint                   # All linting checks
uv run ruff format src/ tests/

# Debug specific tests
pytest tests/unit/test_file.py::test_name -v
pytest -m "not mcp" -n auto  # Exclude specific markers
```

## Debugging Test Failures

### 1. Verbose Output
```bash
pytest -v -s
```

### 2. Last Failed Tests
```bash
pytest --lf -v
```

### 3. PDB Debugger
```bash
pytest --pdb
```

### 4. Specific Test with Locals
```bash
pytest tests/test_file.py::test_name -l -v
```

### 5. Coverage for Specific Module
```bash
pytest --cov=app.services.user --cov-report=term-missing
```

## Anti-Patterns to Avoid

### Don't:
- Use `sleep()` in tests (use proper async/await or mocks)
- Have tests depend on execution order
- Have tests modify global state
- Over-mock (mock only external dependencies)
- Write tests without assertions
- Use bare `assert` without message for complex conditions
- Share fixtures with broad scope when not needed
- Ignore flaky tests (fix them)
- Skip coverage of error paths
- **Skip manual CLI testing** (automated tests may miss runtime async bugs)

### Do:
- Keep tests focused and isolated
- Use descriptive test names
- Test both success and error paths
- Use fixtures for common setup
- Parametrize similar tests
- Mock external dependencies (HTTP, DB, file system)
- Use async tests for async code
- Aim for >80% coverage
- Test edge cases
- **Always perform manual smoke testing for CLI commands**
- Use test markers (unit, integration, slow, fast) for selective test execution

## Example Test Suite Structure

```
tests/
├── conftest.py              # Shared fixtures
├── unit/                    # Unit tests
│   ├── test_models.py
│   ├── test_services.py
│   └── test_utils.py
├── integration/             # Integration tests
│   ├── test_api.py
│   ├── test_database.py
│   └── test_external_api.py
└── e2e/                     # End-to-end tests
    └── test_user_flow.py
```

## Coverage Analysis

```bash
# Generate coverage report
pytest --cov=app --cov-report=html

# View coverage in browser
open htmlcov/index.html

# Check coverage for specific module
pytest --cov=app.services.user --cov-report=term-missing

# Fail if coverage below threshold
pytest --cov=app --cov-fail-under=80
```

## Workflow

### Writing New Tests

1. **Identify what to test**: Function, class, integration, E2E
2. **Create test file**: `tests/test_<module>.py`
3. **Write test function**: `test_<functionality>()`
4. **Use fixtures**: For setup/teardown
5. **Add assertions**: Clear and specific
6. **Run test**: `pytest tests/test_file.py::test_name -v`
7. **Check coverage**: `pytest --cov=module --cov-report=term-missing`

### Debugging Failing Tests

1. **Run test with verbose**: `pytest -v -s`
2. **Check error message**: Understand what failed
3. **Use debugger**: `pytest --pdb`
4. **Check fixture values**: Add print statements or use -s
5. **Isolate test**: Run only the failing test
6. **Fix and re-run**: Verify fix works

### Reviewing Test Code

1. **Check organization**: Clear naming, logical structure
2. **Verify fixtures**: Proper scope, no over-use
3. **Review mocks**: Not over-mocking, correct usage
4. **Check coverage**: Edge cases, error paths
5. **Test isolation**: No dependencies between tests
6. **Async patterns**: Proper use of pytest-asyncio

## References

- **testing-patterns.md**: Comprehensive testing best practices
- **async-testing.md**: Async test patterns with pytest-asyncio
- **mock-patterns.md**: Mocking strategies and best practices
- **fixture-patterns.md**: Advanced fixture usage and patterns

## Best Practices Summary

This skill incorporates modern Python testing practices:

- **Manual Testing is Critical**: Integration tests may mock async execution or miss edge cases. Always perform manual smoke testing of CLI commands.
- **Test Markers**: Use markers (unit, integration, slow, fast, mcp, timeout) for selective test execution
- **Test Organization**: Separate unit (fast, parallel) from integration (may be slow, sequential) tests
- **Development Workflow**: `make dev` (lint + fast tests), `make ci` (full CI workflow)
- **Manual Testing Checklist**:
  1. Run automated tests
  2. Manual smoke test with real data
  3. Test all output formats
  4. Test error conditions
  5. Test with verbose logging to catch warnings
- **Lesson Learned**: Runtime warnings (async/await bugs) only appear in actual execution, not mocked tests
