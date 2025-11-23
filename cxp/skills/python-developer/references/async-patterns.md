# Async/Await Patterns in Python

Comprehensive guide to asynchronous programming in Python using async/await with asyncio, including Python 3.14+ improvements.

**For Python syntax and features**, see [modern-python-2025.md](modern-python-2025.md). This document focuses on async/await patterns, best practices, and production-ready code.

## Python 3.14+ Async Improvements

### Enhanced asyncio.timeout() (3.14+)

```python
import asyncio

# More ergonomic timeout API with better error messages
async def fetch_with_improved_timeout[T](coro: Awaitable[T], timeout: float) -> T:
    """Generic timeout with enhanced error context."""
    async with asyncio.timeout(timeout):  # Better cancellation semantics in 3.14
        return await coro

# Improved timeout reschedule (adjust timeout dynamically)
async def adaptive_timeout_fetch(url: str) -> dict[str, str]:
    """Timeout that adapts based on progress."""
    timeout_cm = asyncio.timeout(5.0)
    async with timeout_cm:
        # Can now reschedule timeout mid-operation (3.14+)
        data = await fetch_partial(url)
        if data["needs_more_time"]:
            timeout_cm.reschedule(asyncio.get_event_loop().time() + 10.0)
        return await fetch_complete(url, data)
```

### Improved TaskGroup Error Handling (3.14+)

```python
# Enhanced TaskGroup with better exception aggregation
async def fetch_all_improved(urls: list[str]) -> list[dict[str, str]]:
    """Better error handling and cancellation in TaskGroup."""
    results = []
    async with asyncio.TaskGroup() as tg:
        tasks = [tg.create_task(fetch_data(url), name=f"fetch-{url}") for url in urls]

    # Better exception context in 3.14 - includes task names in traceback
    for task in tasks:
        try:
            results.append(task.result())
        except Exception as e:
            # Enhanced error messages show which task failed
            print(f"Task {task.get_name()} failed: {e}")
            results.append({"error": str(e)})

    return results

# Improved cancellation propagation
async def cancelable_batch_processing(items: list[str]) -> None:
    """Better cancellation handling in 3.14."""
    try:
        async with asyncio.TaskGroup() as tg:
            for item in items:
                tg.create_task(process_item(item))
    except asyncio.CancelledError:
        # In 3.14, cancellation is more graceful and predictable
        print("Batch cancelled, all tasks properly cleaned up")
        raise
```

### JIT-Friendly Async Patterns (3.14+)

```python
# Write async code that plays well with JIT compiler
async def jit_optimized_loop(items: list[int]) -> int:
    """Async loop optimized for JIT compilation."""
    total = 0
    # Avoid excessive dynamic dispatch - JIT can optimize better
    process = lambda x: x * 2  # Inline simple operations

    for item in items:
        # JIT can optimize tight loops with minimal async overhead
        if item % 100 == 0:
            await asyncio.sleep(0)  # Yield control periodically
        total += process(item)

    return total

# Avoid anti-patterns that hurt JIT performance
async def jit_friendly_fetch(urls: list[str]) -> list[str]:
    """Fetch pattern that JIT compiler can optimize."""
    # Pre-allocate results list (helps JIT)
    results: list[str] = [""] * len(urls)

    async with asyncio.TaskGroup() as tg:
        for i, url in enumerate(urls):
            # Use closure to capture index (JIT-friendly)
            async def fetch_and_store(idx: int, u: str) -> None:
                results[idx] = await fetch_data(u)

            tg.create_task(fetch_and_store(i, url))

    return results
```

## Async Basics

### Async Functions

```python
import asyncio

# Async function definition
async def fetch_data(url: str) -> dict[str, str]:
    """Asynchronous function."""
    await asyncio.sleep(1)  # Simulate I/O
    return {"url": url, "status": "ok"}

# Calling async functions
async def main() -> None:
    result = await fetch_data("http://example.com")
    print(result)

# Run async code
asyncio.run(main())
```

### Async vs Sync

```python
# DON'T: Blocking call in async function
async def bad_fetch() -> str:
    import time
    time.sleep(5)  # Blocks entire event loop!
    return "data"

# DO: Use async operations
async def good_fetch() -> str:
    await asyncio.sleep(5)  # Non-blocking
    return "data"

# DON'T: Sync I/O in async function
async def bad_read_file() -> str:
    with open("file.txt") as f:  # Blocking!
        return f.read()

# DO: Use async I/O
async def good_read_file() -> str:
    async with aiofiles.open("file.txt") as f:
        return await f.read()
```

## Concurrent Execution

### asyncio.gather()

```python
# Run multiple coroutines concurrently
async def fetch_multiple(urls: list[str]) -> list[dict[str, str]]:
    """Fetch multiple URLs concurrently."""
    tasks = [fetch_data(url) for url in urls]
    results = await asyncio.gather(*tasks)
    return results

# With error handling
async def fetch_with_errors(urls: list[str]) -> list[dict[str, str] | None]:
    """Handle individual failures."""
    tasks = [fetch_data(url) for url in urls]
    results = await asyncio.gather(*tasks, return_exceptions=True)

    # Filter out exceptions
    return [r if not isinstance(r, Exception) else None for r in results]
```

### asyncio.create_task()

```python
# Create and schedule tasks
async def process_with_tasks() -> list[str]:
    """Create tasks for concurrent execution."""
    task1 = asyncio.create_task(fetch_data("url1"))
    task2 = asyncio.create_task(fetch_data("url2"))
    task3 = asyncio.create_task(fetch_data("url3"))

    # Do other work while tasks run
    await asyncio.sleep(0.1)

    # Wait for all tasks
    result1 = await task1
    result2 = await task2
    result3 = await task3

    return [result1, result2, result3]

# Task with name (for debugging)
task = asyncio.create_task(
    fetch_data("url"),
    name="fetch_important_data"
)
```

### asyncio.TaskGroup() (Python 3.11+, Enhanced in 3.14)

```python
# Structured concurrency with TaskGroup
async def fetch_with_taskgroup(urls: list[str]) -> list[dict[str, str]]:
    """Use TaskGroup for automatic cleanup."""
    async with asyncio.TaskGroup() as tg:
        tasks = [tg.create_task(fetch_data(url)) for url in urls]

    # All tasks completed or exception raised
    return [task.result() for task in tasks]

# TaskGroup handles errors properly
async def process_batch() -> None:
    try:
        async with asyncio.TaskGroup() as tg:
            tg.create_task(may_fail_1())
            tg.create_task(may_fail_2())
    except* ValueError as eg:  # Catch exception group
        print(f"Got {len(eg.exceptions)} ValueError exceptions")
```

## Timeouts

### asyncio.wait_for()

```python
# Timeout for single operation
async def fetch_with_timeout(url: str, timeout: float = 5.0) -> dict[str, str]:
    """Fetch with timeout."""
    try:
        result = await asyncio.wait_for(fetch_data(url), timeout=timeout)
        return result
    except asyncio.TimeoutError:
        print(f"Timeout fetching {url}")
        return {"error": "timeout"}

# Timeout for multiple operations
async def fetch_multiple_with_timeout(
    urls: list[str],
    timeout: float = 10.0
) -> list[dict[str, str]]:
    """Fetch multiple with overall timeout."""
    try:
        result = await asyncio.wait_for(
            fetch_multiple(urls),
            timeout=timeout
        )
        return result
    except asyncio.TimeoutError:
        return [{"error": "timeout"} for _ in urls]
```

### timeout context manager (Python 3.11+, Enhanced in 3.14)

```python
# Timeout context manager
async def process_with_timeout() -> dict[str, str]:
    """Use timeout context manager."""
    try:
        async with asyncio.timeout(5.0):
            result = await fetch_data("url")
            return result
    except asyncio.TimeoutError:
        return {"error": "timeout"}

# Nested timeouts
async def nested_timeouts() -> None:
    async with asyncio.timeout(10.0):  # Outer timeout
        async with asyncio.timeout(5.0):  # Inner timeout (tighter)
            await long_operation()
```

## Synchronization Primitives

### Lock

```python
# Protect shared state
class Counter:
    def __init__(self) -> None:
        self._value: int = 0
        self._lock = asyncio.Lock()

    async def increment(self) -> None:
        async with self._lock:
            # Critical section
            current = self._value
            await asyncio.sleep(0.1)  # Simulate work
            self._value = current + 1

    async def get_value(self) -> int:
        async with self._lock:
            return self._value

# Usage
counter = Counter()

async def worker(counter: Counter) -> None:
    for _ in range(10):
        await counter.increment()

async def main() -> None:
    await asyncio.gather(*[worker(counter) for _ in range(5)])
    print(f"Final value: {await counter.get_value()}")
```

### Semaphore

```python
# Limit concurrent operations
async def fetch_with_semaphore(
    urls: list[str],
    max_concurrent: int = 5
) -> list[dict[str, str]]:
    """Limit concurrent requests."""
    semaphore = asyncio.Semaphore(max_concurrent)

    async def fetch_limited(url: str) -> dict[str, str]:
        async with semaphore:
            return await fetch_data(url)

    tasks = [fetch_limited(url) for url in urls]
    return await asyncio.gather(*tasks)
```

### Event

```python
# Signal between coroutines
class DataProcessor:
    def __init__(self) -> None:
        self._data_ready = asyncio.Event()
        self._data: list[str] = []

    async def producer(self) -> None:
        """Produce data."""
        await asyncio.sleep(1)
        self._data = ["item1", "item2", "item3"]
        self._data_ready.set()  # Signal data is ready

    async def consumer(self) -> None:
        """Wait for and consume data."""
        await self._data_ready.wait()  # Wait for signal
        print(f"Processing {len(self._data)} items")

# Usage
async def main() -> None:
    processor = DataProcessor()
    await asyncio.gather(
        processor.producer(),
        processor.consumer()
    )
```

### Queue

```python
from asyncio import Queue

# Producer-consumer pattern
async def producer(queue: Queue[str], n: int) -> None:
    """Produce items."""
    for i in range(n):
        item = f"item_{i}"
        await queue.put(item)
        await asyncio.sleep(0.1)

    # Signal completion
    await queue.put(None)

async def consumer(queue: Queue[str | None]) -> None:
    """Consume items."""
    while True:
        item = await queue.get()
        if item is None:  # Completion signal
            queue.task_done()
            break

        print(f"Processing {item}")
        await asyncio.sleep(0.2)
        queue.task_done()

async def main() -> None:
    queue: Queue[str | None] = Queue(maxsize=10)

    await asyncio.gather(
        producer(queue, 5),
        consumer(queue)
    )

    await queue.join()  # Wait for all items to be processed
```

## Context Managers

### Async Context Manager

```python
class AsyncResource:
    """Async context manager for resource management."""

    async def __aenter__(self) -> 'AsyncResource':
        print("Acquiring resource")
        await asyncio.sleep(0.1)
        return self

    async def __aexit__(
        self,
        exc_type: type[BaseException] | None,
        exc_val: BaseException | None,
        exc_tb: object,
    ) -> None:
        print("Releasing resource")
        await asyncio.sleep(0.1)

    async def use(self) -> str:
        return "Using resource"

# Usage
async def use_resource() -> None:
    async with AsyncResource() as resource:
        result = await resource.use()
        print(result)
```

### asynccontextmanager

```python
from contextlib import asynccontextmanager
from typing import AsyncIterator

@asynccontextmanager
async def get_connection() -> AsyncIterator[Connection]:
    """Async context manager using decorator."""
    # Setup
    conn = await create_connection()

    try:
        yield conn
    finally:
        # Cleanup
        await conn.close()

# Usage
async def query_data() -> list[dict[str, str]]:
    async with get_connection() as conn:
        return await conn.execute("SELECT * FROM users")
```

## Async Generators

### Basic Async Generator

```python
from typing import AsyncIterator

async def generate_numbers(n: int) -> AsyncIterator[int]:
    """Async generator."""
    for i in range(n):
        await asyncio.sleep(0.1)
        yield i

# Consume async generator
async def consume() -> None:
    async for num in generate_numbers(5):
        print(num)

# List from async generator
async def to_list() -> list[int]:
    return [num async for num in generate_numbers(5)]
```

### Async Generator with Context Manager

```python
@asynccontextmanager
async def stream_data(source: str) -> AsyncIterator[str]:
    """Stream data with cleanup."""
    # Setup
    stream = await open_stream(source)

    async def _generate() -> AsyncIterator[str]:
        try:
            while True:
                data = await stream.read()
                if not data:
                    break
                yield data
        finally:
            await stream.close()

    yield _generate()

# Usage
async def process_stream() -> None:
    async with stream_data("source") as generator:
        async for data in generator:
            process(data)
```

## Error Handling

### Try/Except in Async

```python
async def fetch_with_retry(
    url: str,
    max_retries: int = 3
) -> dict[str, str]:
    """Fetch with retry on failure."""
    for attempt in range(max_retries):
        try:
            result = await fetch_data(url)
            return result
        except asyncio.TimeoutError:
            if attempt == max_retries - 1:
                raise
            await asyncio.sleep(2 ** attempt)  # Exponential backoff

    raise RuntimeError("Max retries exceeded")

# Multiple exception types
async def robust_fetch(url: str) -> dict[str, str]:
    """Handle multiple error types."""
    try:
        result = await fetch_data(url)
        return result
    except asyncio.TimeoutError:
        return {"error": "timeout"}
    except ConnectionError as e:
        return {"error": f"connection: {e}"}
    except Exception as e:
        # Log unexpected errors
        logger.error(f"Unexpected error: {e}", exc_info=True)
        raise
```

### Exception Groups (Python 3.11+)

```python
# Handle multiple concurrent failures
async def process_batch(items: list[str]) -> None:
    """Process with exception group."""
    async def process_item(item: str) -> str:
        if "fail" in item:
            raise ValueError(f"Failed: {item}")
        return f"Processed: {item}"

    async with asyncio.TaskGroup() as tg:
        tasks = [tg.create_task(process_item(item)) for item in items]

# Catch specific exceptions from group
try:
    await process_batch(["item1", "fail2", "fail3"])
except* ValueError as eg:
    print(f"Got {len(eg.exceptions)} ValueError exceptions")
    for exc in eg.exceptions:
        print(f"  - {exc}")
```

## Task Management

### Task Cancellation

```python
async def long_running_task() -> None:
    """Long running task that can be cancelled."""
    try:
        while True:
            await asyncio.sleep(1)
            print("Working...")
    except asyncio.CancelledError:
        print("Task cancelled")
        # Cleanup
        raise  # Re-raise to propagate cancellation

# Cancel task
async def manage_task() -> None:
    task = asyncio.create_task(long_running_task())

    await asyncio.sleep(3)

    # Cancel task
    task.cancel()

    try:
        await task
    except asyncio.CancelledError:
        print("Task was cancelled")
```

### Task Completion Tracking

```python
async def wait_for_any(tasks: list[asyncio.Task]) -> tuple[set, set]:
    """Wait for any task to complete."""
    done, pending = await asyncio.wait(
        tasks,
        return_when=asyncio.FIRST_COMPLETED
    )

    # Cancel remaining tasks
    for task in pending:
        task.cancel()

    return done, pending

# Wait for all with timeout
async def wait_for_all_with_timeout(
    tasks: list[asyncio.Task],
    timeout: float
) -> tuple[set, set]:
    """Wait for all tasks with timeout."""
    done, pending = await asyncio.wait(
        tasks,
        timeout=timeout
    )

    # Cancel pending tasks
    for task in pending:
        task.cancel()

    return done, pending
```

## Common Patterns

### Rate Limiting

```python
class RateLimiter:
    """Rate limiter for async operations."""

    def __init__(self, rate: int, per: float) -> None:
        self.rate = rate
        self.per = per
        self._semaphore = asyncio.Semaphore(rate)
        self._loop = asyncio.get_event_loop()

    async def __aenter__(self) -> None:
        await self._semaphore.acquire()

    async def __aexit__(
        self,
        exc_type: type[BaseException] | None,
        exc_val: BaseException | None,
        exc_tb: object,
    ) -> None:
        self._loop.call_later(self.per, self._semaphore.release)

# Usage
async def fetch_with_rate_limit(urls: list[str]) -> list[dict[str, str]]:
    """Fetch with rate limiting."""
    rate_limiter = RateLimiter(rate=10, per=1.0)  # 10 requests per second

    async def fetch_limited(url: str) -> dict[str, str]:
        async with rate_limiter:
            return await fetch_data(url)

    tasks = [fetch_limited(url) for url in urls]
    return await asyncio.gather(*tasks)
```

### Connection Pool

```python
class ConnectionPool:
    """Async connection pool."""

    def __init__(self, max_connections: int) -> None:
        self._semaphore = asyncio.Semaphore(max_connections)
        self._connections: list[Connection] = []

    @asynccontextmanager
    async def acquire(self) -> AsyncIterator[Connection]:
        """Acquire connection from pool."""
        async with self._semaphore:
            if self._connections:
                conn = self._connections.pop()
            else:
                conn = await self._create_connection()

            try:
                yield conn
            finally:
                self._connections.append(conn)

    async def _create_connection(self) -> Connection:
        """Create new connection."""
        return await create_connection()

# Usage
pool = ConnectionPool(max_connections=10)

async def query(sql: str) -> list[dict[str, str]]:
    async with pool.acquire() as conn:
        return await conn.execute(sql)
```

### Background Tasks

```python
class BackgroundTasks:
    """Manage background tasks."""

    def __init__(self) -> None:
        self._tasks: set[asyncio.Task] = set()

    def create_task(self, coro):
        """Create and track background task."""
        task = asyncio.create_task(coro)
        self._tasks.add(task)
        task.add_done_callback(self._tasks.discard)
        return task

    async def wait_all(self) -> None:
        """Wait for all background tasks."""
        await asyncio.gather(*self._tasks, return_exceptions=True)

# Usage
tasks = BackgroundTasks()

async def main() -> None:
    # Start background tasks
    tasks.create_task(background_job_1())
    tasks.create_task(background_job_2())

    # Do main work
    await main_work()

    # Wait for background tasks
    await tasks.wait_all()
```

## Testing Async Code

### pytest-asyncio

```python
import pytest

@pytest.mark.asyncio
async def test_fetch_data():
    """Test async function."""
    result = await fetch_data("http://example.com")
    assert result["status"] == "ok"

@pytest.mark.asyncio
async def test_concurrent_fetch():
    """Test concurrent execution."""
    urls = ["http://example.com", "http://example.org"]
    results = await fetch_multiple(urls)
    assert len(results) == 2

# Test with timeout
@pytest.mark.asyncio
async def test_with_timeout():
    """Test async with timeout."""
    with pytest.raises(asyncio.TimeoutError):
        await asyncio.wait_for(slow_operation(), timeout=1.0)
```

### Mocking Async Functions

```python
from unittest.mock import AsyncMock, patch

@pytest.mark.asyncio
async def test_with_mock():
    """Test with async mock."""
    mock_fetch = AsyncMock(return_value={"status": "ok"})

    with patch("module.fetch_data", mock_fetch):
        result = await fetch_data("url")

    assert result["status"] == "ok"
    mock_fetch.assert_called_once_with("url")
```

## Best Practices

### 1. Never Block the Event Loop

```python
# DON'T
async def bad():
    time.sleep(5)  # Blocks!
    requests.get("url")  # Blocks!
    open("file").read()  # Blocks!

# DO
async def good():
    await asyncio.sleep(5)
    async with aiohttp.ClientSession() as session:
        await session.get("url")
    async with aiofiles.open("file") as f:
        await f.read()
```

### 2. Use asyncio.run() for Entry Point

```python
# Entry point
async def main() -> None:
    result = await fetch_data("url")
    print(result)

if __name__ == "__main__":
    asyncio.run(main())
```

### 3. Handle CancelledError

```python
async def task() -> None:
    try:
        await long_operation()
    except asyncio.CancelledError:
        # Cleanup
        await cleanup()
        raise  # Re-raise
```

### 4. Use TaskGroup for Structured Concurrency (Python 3.11+, Enhanced in 3.14)

```python
# Prefer TaskGroup
async with asyncio.TaskGroup() as tg:
    tg.create_task(task1())
    tg.create_task(task2())
# Automatic cleanup and error handling
```

### 5. Set Timeouts

```python
# Always set timeouts for operations
async with asyncio.timeout(10.0):
    await fetch_data("url")
```

This comprehensive guide covers async/await patterns essential for writing efficient, non-blocking Python applications.
