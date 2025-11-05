---
name: pytest-tester
description: Expert for writing, debugging, and reviewing pytest tests. Covers fixtures, parametrize, mocks, async testing, and test organization best practices.
---

# Pytest Testing Expert

Expert skill for writing high-quality pytest tests, debugging test failures, and reviewing test code for Python projects.

## Core Capabilities

### 1. Writing Pytest Tests
When writing new tests:
- Use pytest idioms (assert statements, fixtures, parametrize)
- Organize tests clearly (test_file.py, test classes, descriptive names)
- Use fixtures for setup/teardown and dependency injection
- Apply parametrize for testing multiple scenarios
- Mock external dependencies properly
- Test async code with pytest-asyncio
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

### Async Testing

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

## Pytest Configuration

### pytest.ini

```ini
[pytest]
minversion = 7.0
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
    unit: Unit tests
    integration: Integration tests
    slow: Slow tests (run with -m slow)
    asyncio: Async tests
asyncio_mode = auto
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

## Common Pytest Commands

```bash
# Run all tests
pytest

# Run with verbose output
pytest -v

# Run specific test file
pytest tests/test_user.py

# Run specific test function
pytest tests/test_user.py::test_create_user

# Run specific test class
pytest tests/test_user.py::TestUserService

# Run tests matching pattern
pytest -k "test_create"

# Run tests with specific marker
pytest -m integration

# Run last failed tests
pytest --lf

# Run failed tests first
pytest --ff

# Stop on first failure
pytest -x

# Show local variables in tracebacks
pytest -l

# Enter debugger on failure
pytest --pdb

# Show print statements
pytest -s

# Run with coverage
pytest --cov=app --cov-report=term-missing

# Run only tests that changed
pytest --testmon

# Parallel execution
pytest -n auto  # requires pytest-xdist
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
