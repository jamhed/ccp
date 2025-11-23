# Async Testing Patterns (2025)

Comprehensive guide to testing asynchronous Python code with pytest-asyncio 1.3.0+, AsyncMock, and async testing patterns.

## Agent Quick Reference: Async Testing

**Decision Tree for Async Tests**:
```
What are you testing?
├─ Async function (async def)? → Use @pytest.mark.asyncio
├─ Async database operation? → Use async fixture + @pytest.mark.asyncio
├─ Async API call? → Mock with AsyncMock
├─ Concurrent operations? → Use asyncio.gather in test
├─ Timeout behavior? → Use asyncio.wait_for
└─ Sync function? → Use regular pytest (no asyncio marker)
```

**Agent Instructions**:
1. **ALWAYS** mark async tests with `@pytest.mark.asyncio`
2. **USE** `AsyncMock` for mocking async functions (NOT regular Mock)
3. **USE** `await` for all async calls in tests
4. **AVOID** blocking calls (`time.sleep`) in async tests - use `asyncio.sleep`
5. **USE** `asyncio.gather` for concurrent test setup

**Common Agent Mistakes to Avoid**:
- ❌ Using `Mock` instead of `AsyncMock` for async functions
- ❌ Forgetting `await` keyword
- ❌ Using `time.sleep()` instead of `await asyncio.sleep()`
- ❌ Not marking async tests with `@pytest.mark.asyncio`
- ❌ Creating circular async fixture dependencies

**Prerequisites**: See [test-organization.md](test-organization.md#pytest-asyncio-setup) for pytest-asyncio installation and configuration.

## Basic Async Test

```python
import pytest

@pytest.mark.asyncio
async def test_async_function():
    """Test async function."""
    result = await async_function()
    assert result == expected_value

@pytest.mark.asyncio
async def test_multiple_awaits():
    """Test with multiple async calls."""
    result1 = await fetch_data(1)
    result2 = await fetch_data(2)

    assert result1 != result2
    assert result1 is not None
```

## Async Fixtures

### Basic Async Fixture

```python
import pytest
import httpx

@pytest_asyncio.fixture
async def http_client():
    """Provide async HTTP client."""
    async with httpx.AsyncClient() as client:
        yield client
    # Cleanup happens automatically after yield

@pytest.mark.asyncio
async def test_api_call(http_client):
    """Test API call with async client."""
    response = await http_client.get("https://api.example.com")
    assert response.status_code == 200
```

### Async Database Fixture

```python
import pytest
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession

@pytest_asyncio.fixture(scope="session")
async def db_engine():
    """Create async database engine."""
    engine = create_async_engine("postgresql+asyncpg://...")
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    yield engine

    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
    await engine.dispose()

@pytest_asyncio.fixture
async def db_session(db_engine):
    """Provide async database session."""
    async with AsyncSession(db_engine) as session:
        yield session
        await session.rollback()

@pytest.mark.asyncio
async def test_user_crud(db_session):
    """Test async database operations."""
    # Create
    user = User(name="Alice", email="alice@example.com")
    db_session.add(user)
    await db_session.commit()

    # Read
    result = await db_session.execute(
        select(User).where(User.email == "alice@example.com")
    )
    fetched = result.scalar_one()
    assert fetched.name == "Alice"
```

### Async Fixture Scopes

```python
# Function scope (default) - new fixture per test
@pytest_asyncio.fixture
async def async_client():
    async with AsyncClient() as client:
        yield client

# Class scope - shared within test class
@pytest_asyncio.fixture(scope="class")
async def shared_resource():
    resource = await setup_expensive_resource()
    yield resource
    await cleanup_resource(resource)

# Module scope - shared within module
@pytest_asyncio.fixture(scope="module")
async def module_resource():
    resource = await create_resource()
    yield resource
    await destroy_resource(resource)

# Session scope - shared across entire test session
@pytest_asyncio.fixture(scope="session")
async def session_resource():
    resource = await initialize_global_resource()
    yield resource
    await shutdown_global_resource(resource)
```

## Concurrent Testing with asyncio.gather

### Testing Concurrent Operations

```python
import pytest
import asyncio

@pytest.mark.asyncio
async def test_concurrent_requests():
    """Test multiple concurrent async operations."""
    # Run multiple operations concurrently
    results = await asyncio.gather(
        fetch_data(1),
        fetch_data(2),
        fetch_data(3)
    )

    assert len(results) == 3
    assert all(r is not None for r in results)

@pytest.mark.asyncio
async def test_concurrent_with_timeout():
    """Test concurrent operations with timeout."""
    try:
        results = await asyncio.wait_for(
            asyncio.gather(
                slow_operation(),
                fast_operation()
            ),
            timeout=5.0
        )
        assert len(results) == 2
    except asyncio.TimeoutError:
        pytest.fail("Operations timed out")
```

### Optimizing Test Setup with gather

```python
@pytest_asyncio.fixture
async def test_data(db_session):
    """Setup multiple test resources concurrently."""
    # ❌ SLOW - Sequential setup (6 seconds for 3x 2-second operations)
    # user = await create_user(db_session)
    # posts = await create_posts(db_session)
    # comments = await create_comments(db_session)

    # ✅ FAST - Concurrent setup (2 seconds total)
    user, posts, comments = await asyncio.gather(
        create_user(db_session),
        create_posts(db_session),
        create_comments(db_session)
    )

    return {"user": user, "posts": posts, "comments": comments}

@pytest.mark.asyncio
async def test_with_concurrent_setup(test_data):
    """Test using concurrently prepared data."""
    assert test_data["user"] is not None
    assert len(test_data["posts"]) == 10
```

## Mocking Async Functions

### Using AsyncMock

```python
from unittest.mock import AsyncMock
import pytest

@pytest.mark.asyncio
async def test_async_service():
    """Test with AsyncMock."""
    # Create async mock
    mock_fetch = AsyncMock(return_value={"id": 1, "name": "Test"})

    # Use mock
    result = await mock_fetch(user_id=1)

    # Assertions
    assert result["name"] == "Test"
    mock_fetch.assert_awaited_once()
    mock_fetch.assert_awaited_once_with(user_id=1)
```

### Patching Async Functions

```python
from unittest.mock import patch, AsyncMock
import pytest

@pytest.mark.asyncio
@patch('myapp.services.fetch_user', new_callable=AsyncMock)
async def test_user_service(mock_fetch):
    """Test service with mocked async function."""
    # Setup mock
    mock_fetch.return_value = {
        "id": 1,
        "name": "Alice",
        "email": "alice@example.com"
    }

    # Test code
    user = await get_user_profile(user_id=1)

    # Assertions
    assert user["name"] == "Alice"
    mock_fetch.assert_awaited_once_with(user_id=1)
```

### AsyncMock with side_effect

```python
import pytest
from unittest.mock import AsyncMock

@pytest.mark.asyncio
async def test_retry_logic():
    """Test retry logic with failing async calls."""
    # First two calls fail, third succeeds
    mock_api = AsyncMock(
        side_effect=[
            ConnectionError("Failed"),
            ConnectionError("Failed"),
            {"status": "success"}
        ]
    )

    # Test retry mechanism
    result = await retry_async_call(mock_api, max_retries=3)

    # Assertions
    assert result["status"] == "success"
    assert mock_api.await_count == 3
```

## Testing Timeouts and Cancellation

### Testing Timeout Behavior

```python
import pytest
import asyncio

@pytest.mark.asyncio
async def test_timeout():
    """Test function respects timeout."""
    with pytest.raises(asyncio.TimeoutError):
        await asyncio.wait_for(
            slow_async_operation(),
            timeout=0.1
        )

@pytest.mark.asyncio
async def test_operation_within_timeout():
    """Test fast operation completes before timeout."""
    result = await asyncio.wait_for(
        fast_async_operation(),
        timeout=1.0
    )
    assert result is not None
```

### Testing Cancellation

```python
import pytest
import asyncio

@pytest.mark.asyncio
async def test_cancellation_handling():
    """Test task handles cancellation properly."""
    task = asyncio.create_task(cancellable_operation())

    # Let task start
    await asyncio.sleep(0.1)

    # Cancel task
    task.cancel()

    # Verify cancellation was handled
    with pytest.raises(asyncio.CancelledError):
        await task

@pytest.mark.asyncio
async def test_graceful_shutdown():
    """Test graceful shutdown on cancellation."""
    # Start long-running task
    task = asyncio.create_task(worker_task())

    await asyncio.sleep(0.1)

    # Cancel and verify cleanup
    task.cancel()
    try:
        await task
    except asyncio.CancelledError:
        pass

    # Verify cleanup happened
    assert worker_task.cleanup_called
```

## Testing Task Management

### Testing Background Tasks

```python
import pytest
import asyncio

@pytest.mark.asyncio
async def test_background_task():
    """Test background task execution."""
    result_queue = asyncio.Queue()

    # Start background task
    task = asyncio.create_task(
        background_worker(result_queue)
    )

    # Wait for results
    result = await asyncio.wait_for(
        result_queue.get(),
        timeout=5.0
    )

    # Cleanup
    task.cancel()

    assert result == expected_value
```

### Testing TaskGroup (Python 3.11+)

```python
import pytest
import asyncio

@pytest.mark.asyncio
async def test_task_group():
    """Test TaskGroup for concurrent operations."""
    results = []

    async with asyncio.TaskGroup() as group:
        task1 = group.create_task(async_operation(1))
        task2 = group.create_task(async_operation(2))
        task3 = group.create_task(async_operation(3))

    # All tasks completed
    assert len([task1, task2, task3]) == 3
```

## Avoiding Common Pitfalls

### Deadlock Prevention

```python
# ❌ BAD - Potential deadlock
@pytest_asyncio.fixture
async def fixture_a(fixture_b):
    await asyncio.sleep(0.1)
    return "a"

@pytest_asyncio.fixture
async def fixture_b(fixture_a):  # Circular dependency!
    await asyncio.sleep(0.1)
    return "b"

# ✅ GOOD - Clear dependency chain
@pytest_asyncio.fixture
async def database():
    """Base resource."""
    async with create_db_pool() as pool:
        yield pool

@pytest_asyncio.fixture
async def repository(database):
    """Depends on database."""
    return UserRepository(database)

@pytest_asyncio.fixture
async def service(repository):
    """Depends on repository."""
    return UserService(repository)
```

### Avoiding Blocking Calls

```python
# ❌ BAD - Blocking call in async function
@pytest.mark.asyncio
async def test_bad_async():
    result = time.sleep(1)  # Blocks event loop!
    assert result is None

# ✅ GOOD - Use async sleep
@pytest.mark.asyncio
async def test_good_async():
    await asyncio.sleep(1)  # Non-blocking
    assert True
```

### Proper Resource Cleanup

```python
# ✅ GOOD - Ensure cleanup with try/finally
@pytest_asyncio.fixture
async def resource():
    """Fixture with guaranteed cleanup."""
    res = await create_resource()
    try:
        yield res
    finally:
        await cleanup_resource(res)

# ✅ GOOD - Use async context manager
@pytest_asyncio.fixture
async def managed_resource():
    """Fixture using context manager."""
    async with AsyncResource() as res:
        yield res
    # Cleanup automatic
```

## Testing AsyncIterators

```python
import pytest

@pytest.mark.asyncio
async def test_async_iterator():
    """Test async iterator."""
    results = []

    async for item in async_data_stream():
        results.append(item)
        if len(results) >= 10:
            break

    assert len(results) == 10

@pytest.mark.asyncio
async def test_async_generator():
    """Test async generator."""
    gen = async_number_generator(start=1, count=5)

    numbers = [num async for num in gen]

    assert numbers == [1, 2, 3, 4, 5]
```

## Real-World Async Test Examples

### Testing FastAPI Endpoints

```python
import pytest
from httpx import AsyncClient
from myapp import app

@pytest_asyncio.fixture
async def client():
    """Provide async test client."""
    async with AsyncClient(app=app, base_url="http://test") as ac:
        yield ac

@pytest.mark.asyncio
async def test_create_user(client):
    """Test user creation endpoint."""
    response = await client.post(
        "/users",
        json={"name": "Alice", "email": "alice@example.com"}
    )

    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "Alice"
    assert "id" in data
```

### Testing Async Database Operations

```python
@pytest.mark.asyncio
async def test_user_repository(db_session):
    """Test async repository pattern."""
    repo = UserRepository(db_session)

    # Create
    user = await repo.create({
        "name": "Bob",
        "email": "bob@example.com"
    })
    assert user.id is not None

    # Read
    fetched = await repo.get_by_id(user.id)
    assert fetched.name == "Bob"

    # Update
    await repo.update(user.id, {"name": "Robert"})
    updated = await repo.get_by_id(user.id)
    assert updated.name == "Robert"

    # Delete
    await repo.delete(user.id)
    deleted = await repo.get_by_id(user.id)
    assert deleted is None
```

### Testing WebSocket Connections

```python
import pytest
from fastapi.testclient import TestClient
from myapp import app

@pytest.mark.asyncio
async def test_websocket():
    """Test WebSocket connection."""
    client = TestClient(app)

    with client.websocket_connect("/ws") as websocket:
        # Send message
        websocket.send_text("Hello")

        # Receive response
        data = websocket.receive_text()
        assert data == "Message received: Hello"
```

## Best Practices

### Do's ✅

- ✅ Use `@pytest.mark.asyncio` for async tests
- ✅ Use `AsyncMock` for mocking async functions
- ✅ Use `asyncio.gather` for concurrent test setup
- ✅ Set appropriate fixture scopes
- ✅ Test timeout and cancellation behavior
- ✅ Use async context managers for cleanup
- ✅ Avoid blocking calls in async code
- ✅ Test both success and error paths
- ✅ Use `pytest-asyncio 1.3.0+` for Python 3.10-3.14

### Don'ts ❌

- ❌ Don't use blocking calls (`time.sleep`, blocking I/O)
- ❌ Don't create circular fixture dependencies
- ❌ Don't forget to await async calls
- ❌ Don't mix sync and async code improperly
- ❌ Don't use regular `Mock` for async functions
- ❌ Don't ignore cleanup in async fixtures
- ❌ Don't create deadlocks with improper task management

## Summary

### Key Patterns

1. **Use pytest-asyncio 1.3.0+** for async testing (Python 3.10-3.14)
2. **Mark tests** with `@pytest.mark.asyncio`
3. **Use async fixtures** with `@pytest_asyncio.fixture`
4. **Mock async functions** with `AsyncMock`
5. **Optimize setup** with `asyncio.gather`
6. **Test timeouts** and cancellation
7. **Avoid blocking** calls in async code
8. **Clean up resources** properly

### Tools Summary

| Tool | Purpose |
|------|---------|
| `@pytest.mark.asyncio` | Mark async tests |
| `@pytest_asyncio.fixture` | Create async fixtures |
| `AsyncMock` | Mock async functions |
| `asyncio.gather` | Run concurrent operations |
| `asyncio.wait_for` | Test timeouts |
| `asyncio.TaskGroup` | Manage task groups (Python 3.11+) |

## Agent Implementation Checklist

When implementing async tests, verify:

**Test Markers**:
- [ ] All async tests marked with `@pytest.mark.asyncio`
- [ ] asyncio_mode configured in pytest.ini or pyproject.toml
- [ ] No sync tests accidentally marked with asyncio

**Async/Await Usage**:
- [ ] All async function calls use `await`
- [ ] No missing `await` keywords
- [ ] No blocking calls (`time.sleep`, sync I/O)
- [ ] Use `await asyncio.sleep()` instead of `time.sleep()`

**Mocking**:
- [ ] AsyncMock used for async functions
- [ ] Regular Mock used for sync functions only
- [ ] Mock assertions use `assert_awaited` methods
- [ ] Patches use `new_callable=AsyncMock` parameter

**Fixtures**:
- [ ] Async fixtures use `@pytest_asyncio.fixture`
- [ ] Appropriate fixture scopes (function/class/module/session)
- [ ] Fixture cleanup uses yield pattern
- [ ] No circular async fixture dependencies

**Concurrency**:
- [ ] asyncio.gather used for concurrent operations
- [ ] Timeout behavior tested with asyncio.wait_for
- [ ] Task cancellation handled properly
- [ ] No deadlocks or race conditions

## Resources

For external documentation and references, see [external-sources.md](external-sources.md).
