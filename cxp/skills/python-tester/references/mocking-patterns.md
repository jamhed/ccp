# Mocking Patterns and Test Doubles (2025)

Comprehensive guide to mocking in Python tests using unittest.mock, pytest-mock, and test doubles patterns.

## Agent Quick Reference: When to Mock

**Decision Tree**:
```
What are you testing?
├─ HTTP/API call? → MOCK (use responses or Mock)
├─ Database operation? → DON'T MOCK (use test database)
├─ File I/O? → MOCK (use mock_open)
├─ Time/random? → MOCK (use freezegun or Mock)
├─ External service? → MOCK (use Mock or AsyncMock)
├─ Internal business logic? → DON'T MOCK (test directly)
└─ Your own classes? → DON'T MOCK (refactor or use real instances)
```

**Agent Instructions**:
1. **MOCK** external dependencies only (APIs, external services, time)
2. **DON'T MOCK** internal code (business logic, your classes)
3. **USE** autospec=True for type safety
4. **PATCH** where code is used, not where it's defined
5. **USE** AsyncMock for async functions, Mock for sync functions

**Golden Rule for Agents**: If you own the code, don't mock it. Test it directly.

## Agent Quick Reference: Mock vs AsyncMock

| What You're Mocking | Use This | Example |
|---------------------|----------|---------|
| Sync function | `Mock` | `mock = Mock(return_value=42)` |
| Async function | `AsyncMock` | `mock = AsyncMock(return_value=42)` |
| HTTP request | `Mock` or `responses` library | `@patch('requests.get')` |
| Database | Real test DB, not mock | Use fixture with test database |
| File operations | `mock_open` | `@patch('builtins.open', mock_open(...))` |
| Time | `freezegun` | `@freeze_time("2025-01-01")` |

## Test Doubles Overview

### Types of Test Doubles

**Mock**: Records calls and verifies interactions
- Used to verify that methods were called
- Can assert call count, arguments, order

**Stub**: Returns predefined responses
- Used to provide controlled data
- Doesn't verify calls, just returns values

**Fake**: Working implementation (simplified)
- Real implementation with shortcuts (e.g., in-memory DB)
- More complex than mocks/stubs

**Spy**: Records calls while delegating to real object
- Wraps real object
- Records interactions for verification

## unittest.mock Library

### Basic Mock Usage

```python
from unittest.mock import Mock, MagicMock

# Create mock
mock = Mock()
mock.method.return_value = 42

# Use mock
result = mock.method()
assert result == 42

# Verify calls
mock.method.assert_called_once()
mock.method.assert_called_with()
```

### Mock vs MagicMock

```python
from unittest.mock import Mock, MagicMock

# Mock - basic mock object
mock = Mock()
mock.method.return_value = "value"

# MagicMock - includes magic methods (__len__, __str__, etc.)
magic_mock = MagicMock()
len(magic_mock)  # Works - returns 0 by default
str(magic_mock)  # Works - returns mock string

# Use MagicMock when testing magic methods
magic_mock.__len__.return_value = 5
assert len(magic_mock) == 5
```

### Patch Decorator

**Best Practice**: Patch where it's used, not where it's defined

```python
from unittest.mock import patch

# ❌ WRONG - Patching where defined
@patch('myapp.database.Database')
def test_service(mock_db):
    # This won't work if service imports Database differently
    service = UserService()

# ✅ CORRECT - Patching where used
@patch('myapp.services.user_service.Database')
def test_service(mock_db):
    # Patches Database in user_service module
    service = UserService()
    service.get_users()
    mock_db().query.assert_called_once()
```

### Patch Context Manager

```python
from unittest.mock import patch

def test_api_call():
    """Test API call with context manager patch."""
    with patch('requests.get') as mock_get:
        # Setup mock response
        mock_get.return_value.status_code = 200
        mock_get.return_value.json.return_value = {"status": "ok"}

        # Test code
        response = fetch_data("https://api.example.com")

        # Assertions
        assert response == {"status": "ok"}
        mock_get.assert_called_once_with("https://api.example.com")
```

### autospec Parameter

**Best Practice**: Use `autospec=True` to ensure mock has same signature as real object

```python
from unittest.mock import patch

class RealService:
    def process(self, data: dict, timeout: int = 30) -> bool:
        pass

# ✅ GOOD - autospec ensures correct signature
@patch('myapp.services.RealService', autospec=True)
def test_with_autospec(mock_service):
    service = mock_service()

    # This works - correct signature
    service.process({"key": "value"}, timeout=60)

    # This fails - incorrect arguments (caught by autospec)
    # service.process("wrong")  # TypeError

# ❌ BAD - no autospec, accepts any arguments
@patch('myapp.services.RealService')
def test_without_autospec(mock_service):
    service = mock_service()

    # This incorrectly passes - should fail
    service.process("wrong", 1, 2, 3)
```

### side_effect for Complex Behavior

```python
from unittest.mock import Mock

# Return different values on successive calls
mock = Mock()
mock.side_effect = [1, 2, 3]
assert mock() == 1
assert mock() == 2
assert mock() == 3

# Raise exception
mock = Mock()
mock.side_effect = ValueError("Invalid input")
# mock() raises ValueError

# Custom function
def custom_behavior(arg):
    if arg > 10:
        return "big"
    return "small"

mock = Mock()
mock.side_effect = custom_behavior
assert mock(15) == "big"
assert mock(5) == "small"
```

## AsyncMock for Async Code

### Basic AsyncMock Usage

Since Python 3.8, `AsyncMock` is available for mocking async functions:

```python
from unittest.mock import AsyncMock
import pytest

@pytest.mark.asyncio
async def test_async_function():
    """Test async function with AsyncMock."""
    # Create async mock
    mock = AsyncMock(return_value=42)

    # Use async mock
    result = await mock()
    assert result == 42

    # Verify awaited
    mock.assert_awaited_once()
```

### Patching Async Functions

```python
from unittest.mock import patch, AsyncMock
import pytest

@pytest.mark.asyncio
@patch('myapp.services.fetch_data', new_callable=AsyncMock)
async def test_async_service(mock_fetch):
    """Test service that calls async function."""
    # Setup mock
    mock_fetch.return_value = {"data": "value"}

    # Test code
    result = await process_data()

    # Assertions
    assert result["data"] == "value"
    mock_fetch.assert_awaited_once()
```

### AsyncMock Assertions

```python
from unittest.mock import AsyncMock

mock = AsyncMock(return_value="result")
result = await mock(arg="value")

# Async-specific assertions
mock.assert_awaited()
mock.assert_awaited_once()
mock.assert_awaited_once_with(arg="value")
mock.assert_awaited_with(arg="value")
mock.assert_any_await(arg="value")

# Check await count
assert mock.await_count == 1

# Check await arguments
assert mock.await_args[1] == {"arg": "value"}
```

## pytest-mock Plugin

### Basic Usage

```python
# Using pytest-mock plugin
def test_with_mocker(mocker):
    """Test using pytest-mock plugin."""
    # Patch with mocker
    mock_get = mocker.patch('requests.get')
    mock_get.return_value.status_code = 200

    # Test code
    response = fetch_data()

    # Assertions
    assert response.status_code == 200
    mock_get.assert_called_once()
```

### spy() for Partial Mocking

```python
def test_spy(mocker):
    """Spy on real object while keeping functionality."""
    real_service = RealService()
    spy = mocker.spy(real_service, 'process')

    # Call real method (not mocked)
    result = real_service.process({"data": "value"})

    # Verify calls
    spy.assert_called_once_with({"data": "value"})

    # Real functionality still works
    assert result is not None
```

## Mocking External Dependencies

### Mocking HTTP Requests

```python
from unittest.mock import Mock, patch

def test_api_client():
    """Mock HTTP requests."""
    with patch('requests.get') as mock_get:
        # Setup mock response
        mock_response = Mock()
        mock_response.status_code = 200
        mock_response.json.return_value = {
            "users": [{"id": 1, "name": "Alice"}]
        }
        mock_get.return_value = mock_response

        # Test
        users = get_users()

        # Assertions
        assert len(users) == 1
        assert users[0]["name"] == "Alice"
        mock_get.assert_called_once_with(
            "https://api.example.com/users",
            headers={"Authorization": "Bearer token"}
        )
```

### Using responses Library

```python
import responses
import requests

@responses.activate
def test_with_responses():
    """Mock HTTP with responses library."""
    # Add mock response
    responses.add(
        responses.GET,
        "https://api.example.com/users",
        json={"users": [{"id": 1}]},
        status=200
    )

    # Test
    resp = requests.get("https://api.example.com/users")

    # Assertions
    assert resp.status_code == 200
    assert len(responses.calls) == 1
```

### Mocking Database

```python
from unittest.mock import MagicMock

def test_database_query(mocker):
    """Mock database operations."""
    # Mock database connection
    mock_db = mocker.patch('myapp.database.get_connection')
    mock_cursor = MagicMock()

    # Setup mock query results
    mock_cursor.fetchall.return_value = [
        (1, "Alice"),
        (2, "Bob")
    ]
    mock_db.return_value.cursor.return_value = mock_cursor

    # Test
    users = get_all_users()

    # Assertions
    assert len(users) == 2
    mock_cursor.execute.assert_called_once_with("SELECT * FROM users")
```

### Mocking Filesystem

```python
from unittest.mock import mock_open, patch

def test_file_reading():
    """Mock file operations."""
    mock_data = "line 1\nline 2\nline 3"

    with patch("builtins.open", mock_open(read_data=mock_data)):
        content = read_file("test.txt")

        assert "line 1" in content
        assert "line 2" in content
```

### Mocking Time

```python
from unittest.mock import patch
from datetime import datetime

def test_time_dependent():
    """Mock datetime."""
    fixed_time = datetime(2025, 1, 1, 12, 0, 0)

    with patch('myapp.utils.datetime') as mock_datetime:
        mock_datetime.now.return_value = fixed_time

        result = get_current_timestamp()

        assert result == fixed_time
```

### Using freezegun

```python
from freezegun import freeze_time
from datetime import datetime

@freeze_time("2025-01-01 12:00:00")
def test_with_frozen_time():
    """Test with frozen time."""
    now = datetime.now()
    assert now.year == 2025
    assert now.month == 1
    assert now.day == 1
    assert now.hour == 12
```

## Mocking Best Practices

### Do's ✅

1. **Mock external dependencies only**
```python
# ✅ GOOD - Mock external API
@patch('requests.get')
def test_api_call(mock_get):
    pass

# ❌ BAD - Don't mock internal business logic
@patch('myapp.services.calculate_total')
def test_checkout(mock_calc):
    pass  # Test the real calculation instead
```

2. **Use autospec for type safety**
```python
# ✅ GOOD
@patch('myapp.service.RealClass', autospec=True)

# ❌ BAD - No autospec allows incorrect usage
@patch('myapp.service.RealClass')
```

3. **Patch where used, not where defined**
```python
# ✅ GOOD
@patch('myapp.views.User')  # Patch in views module

# ❌ BAD
@patch('myapp.models.User')  # Patch in models module
```

4. **Reset mocks between tests**
```python
@pytest.fixture
def mock_service(mocker):
    """Fixture that provides clean mock for each test."""
    return mocker.patch('myapp.Service')

# Pytest fixtures automatically reset between tests
```

5. **Use spec parameter**
```python
# ✅ GOOD - Spec ensures mock matches real object
mock = Mock(spec=RealClass)

# ❌ BAD - No spec allows any attribute access
mock = Mock()
```

### Don'ts ❌

1. **Don't over-mock**
```python
# ❌ BAD - Mocking everything defeats the test
@patch('myapp.service1')
@patch('myapp.service2')
@patch('myapp.service3')
@patch('myapp.service4')
def test_everything_mocked():
    pass  # Not testing anything real
```

2. **Don't mock what you don't own**
```python
# ❌ BAD - Mocking internal functions
@patch('myapp.utils.helper_function')

# ✅ GOOD - Mock external dependencies only
@patch('requests.get')
```

3. **Don't create brittle mocks**
```python
# ❌ BAD - Tied to implementation details
mock.method.assert_called_once_with(
    arg1, arg2, internal_flag=True, _private_arg=False
)

# ✅ GOOD - Test behavior, not implementation
mock.method.assert_called()
assert result.status == "success"
```

4. **Don't use mocks for value objects**
```python
# ❌ BAD - Mocking simple value objects
mock_user = Mock()
mock_user.name = "Alice"

# ✅ GOOD - Use real value objects
user = User(name="Alice")
```

## Common Patterns

### Mock Method Call Chain

```python
# Mock chained calls: service.get().process().result()
mock = Mock()
mock.get.return_value.process.return_value.result.return_value = 42

result = mock.get().process().result()
assert result == 42
```

### Mock Context Manager

```python
# Mock context manager
mock_file = MagicMock()
mock_file.__enter__.return_value = mock_file
mock_file.read.return_value = "file content"

with patch("builtins.open", return_value=mock_file):
    with open("test.txt") as f:
        content = f.read()
    assert content == "file content"
```

### Mock Property

```python
# Mock property
mock = Mock()
type(mock).property_name = PropertyMock(return_value=42)

assert mock.property_name == 42
```

## When NOT to Mock

**Don't mock**:
- ❌ Pure functions (test them directly)
- ❌ Internal business logic
- ❌ Simple value objects
- ❌ Your own classes (refactor for testability instead)
- ❌ Libraries you trust (integration test instead)

**Do mock**:
- ✅ External APIs
- ✅ Databases
- ✅ File systems
- ✅ Network calls
- ✅ Time/random functions
- ✅ Third-party services

## Summary

### Key Principles

1. Mock external dependencies, not internal code
2. Use `autospec=True` for type safety
3. Patch where used, not where defined
4. Use `AsyncMock` for async functions
5. Reset mocks between tests
6. Keep mocks simple and focused
7. Prefer real objects over mocks when possible
8. Test behavior, not implementation

### Tools Summary

| Tool | Use Case |
|------|----------|
| `Mock` | Basic mocking |
| `MagicMock` | Mock with magic methods |
| `AsyncMock` | Mock async functions |
| `patch` | Replace objects during tests |
| `pytest-mock` | pytest integration |
| `responses` | Mock HTTP requests |
| `freezegun` | Mock time |

## Agent Implementation Checklist

When using mocks in tests, verify:

**Mock Selection**:
- [ ] Using AsyncMock for async functions (not Mock)
- [ ] Using Mock for sync functions only
- [ ] Using autospec=True for type safety
- [ ] Not mocking internal business logic

**Patching**:
- [ ] Patching where code is used, not where defined
- [ ] Patch decorator order correct (bottom-up execution)
- [ ] Using context managers for temporary patches
- [ ] Cleanup happens automatically

**Mock Configuration**:
- [ ] return_value set correctly
- [ ] side_effect used for exceptions or varying returns
- [ ] Mock method signatures match real objects (autospec)
- [ ] Mocks reset between tests (pytest fixtures handle this)

**Mock Assertions**:
- [ ] Using appropriate assertions (assert_called_once, assert_called_with, etc.)
- [ ] Verifying call arguments correctly
- [ ] Not over-asserting implementation details
- [ ] Testing behavior, not implementation

**Common Pitfalls Avoided**:
- [ ] Not mocking what you don't own
- [ ] Not over-mocking (creates brittle tests)
- [ ] Not using Mock for async functions
- [ ] Not forgetting to await AsyncMock calls in tests

## Agent Common Patterns

**Pattern 1: Mock External API**
```python
from unittest.mock import patch, Mock

@patch('requests.get')
def test_api_call(mock_get):
    # Configure mock
    mock_get.return_value = Mock(status_code=200, json=lambda: {"data": "value"})

    # Test
    result = fetch_data("https://api.example.com")

    # Verify
    mock_get.assert_called_once_with("https://api.example.com")
    assert result["data"] == "value"
```

**Pattern 2: Mock with Side Effect**
```python
from unittest.mock import Mock

def test_retry_logic():
    # Mock that fails twice, then succeeds
    mock = Mock(side_effect=[
        ConnectionError("Failed"),
        ConnectionError("Failed"),
        {"status": "success"}
    ])

    result = retry_function(mock, max_retries=3)

    assert result["status"] == "success"
    assert mock.call_count == 3
```

**Pattern 3: Mock Async Function**
```python
from unittest.mock import AsyncMock
import pytest

@pytest.mark.asyncio
async def test_async_call():
    # Configure AsyncMock
    mock_service = AsyncMock(return_value={"result": "ok"})

    # Test
    result = await call_service(mock_service)

    # Verify
    mock_service.assert_awaited_once()
    assert result["result"] == "ok"
```

## Resources

For external documentation and references, see [external-sources.md](external-sources.md).
