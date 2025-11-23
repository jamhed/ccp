# Modern Python Development (2025)

Practical guide to developing Python applications using modern features from Python 3.10+ through 3.14+.

## Core Modern Features to Use

### Type Hints - Use Everywhere

```python
# Modern union syntax (3.10+)
def process(value: int | str | None) -> dict[str, str | int]:
    """Always use type hints for better IDE support and type checking."""
    return {"value": value, "type": type(value).__name__}

# Generic types with new syntax (3.12+)
def first[T](items: list[T]) -> T | None:
    """Type parameters for generic functions."""
    return items[0] if items else None

# TypedDict for **kwargs (3.13+)
from typing import TypedDict, Unpack

class UserKwargs(TypedDict):
    name: str
    age: int
    email: str | None

def create_user(**kwargs: Unpack[UserKwargs]) -> dict[str, str | int]:
    """Typed keyword arguments for better validation."""
    return {"name": kwargs["name"], "age": kwargs["age"]}
```

### Pattern Matching - For Complex Conditionals

```python
def handle_response(response: dict) -> str:
    """Use pattern matching instead of long if/elif chains."""
    match response:
        case {"status": 200, "data": data}:
            return f"Success: {data}"
        case {"status": 404}:
            return "Not found"
        case {"status": code, "error": msg} if code >= 500:
            return f"Server error {code}: {msg}"
        case {"status": code}:
            return f"Status: {code}"
        case _:
            return "Unknown response"

# Pattern matching with dict unpacking
def process_event(event: dict) -> str:
    match event:
        case {"type": "user", "action": "create", **data}:
            return f"Creating user: {data}"
        case {"type": "order", "amount": amount} if amount > 1000:
            return "Large order"
        case _:
            return "Unknown event"
```

### Dataclasses - For Data Models

```python
from dataclasses import dataclass, field
from typing import ClassVar

@dataclass(slots=True)  # Memory efficient (use slots=True)
class User:
    """Always use dataclasses for data structures."""
    user_id: int
    name: str
    email: str
    is_active: bool = True
    tags: list[str] = field(default_factory=list)  # Never use mutable defaults

    # Class variables
    MAX_NAME_LENGTH: ClassVar[int] = 100

    def __post_init__(self) -> None:
        """Validation after initialization."""
        if len(self.name) > self.MAX_NAME_LENGTH:
            raise ValueError(f"Name too long: {len(self.name)}")

# Frozen dataclass for immutable data
@dataclass(frozen=True, slots=True)
class Point:
    x: int
    y: int
```

### Async/Await - For I/O Operations

```python
import asyncio

# Basic async function
async def fetch_data(url: str) -> dict[str, str]:
    """Use async for I/O operations."""
    await asyncio.sleep(1)  # Simulate I/O
    return {"url": url, "status": "ok"}

# Concurrent execution with TaskGroup (3.11+)
async def fetch_all(urls: list[str]) -> list[dict[str, str]]:
    """Run multiple async operations concurrently."""
    async with asyncio.TaskGroup() as tg:
        tasks = [tg.create_task(fetch_data(url)) for url in urls]
    return [t.result() for t in tasks]
```

**For comprehensive async patterns**, see [async-patterns.md](async-patterns.md):
- Async context managers, generators, iterators
- Synchronization primitives (Lock, Semaphore, Event, Queue)
- Timeouts with `asyncio.timeout()` and `wait_for()`
- Error handling, task cancellation, exception groups
- Common patterns (rate limiting, connection pools, background tasks)
- Testing async code with pytest-asyncio

### Error Handling - Specific and Explicit

```python
# Specific exceptions (never use bare except)
def process_user_data(data: dict[str, str]) -> dict[str, str]:
    """Always use specific exception types."""
    try:
        user_id = int(data["id"])
        email = data["email"]
        return {"id": user_id, "email": email}
    except KeyError as e:
        raise ValueError(f"Missing required field: {e}") from e
    except ValueError as e:
        raise ValueError(f"Invalid user ID: {e}") from e

# Exception groups for multiple errors (3.11+)
def process_batch(items: list[str]) -> None:
    """Group multiple exceptions together."""
    errors = []
    for item in items:
        try:
            process_item(item)
        except ValueError as e:
            errors.append(e)

    if errors:
        raise ExceptionGroup("Batch failed", errors)

# Catching exception groups
try:
    process_batch(items)
except* ValueError as eg:  # Catch specific exceptions from group
    for exc in eg.exceptions:
        log_error(exc)

# Custom exceptions with context
class AppError(Exception):
    """Base application exception."""
    def __init__(self, message: str, code: str | None = None) -> None:
        super().__init__(message)
        self.code = code

class NotFoundError(AppError):
    """Resource not found."""
    def __init__(self, resource: str, resource_id: int) -> None:
        super().__init__(
            f"{resource} with id {resource_id} not found",
            code="NOT_FOUND"
        )
```

### Context Managers - For Resource Management

```python
from contextlib import contextmanager
from pathlib import Path

# Always use context managers for resources
def read_file(path: Path) -> str:
    """Automatic resource cleanup."""
    with path.open() as f:
        return f.read()

# Custom context manager
@contextmanager
def timer(name: str):
    """Measure execution time."""
    import time
    start = time.time()
    try:
        yield
    finally:
        elapsed = time.time() - start
        print(f"{name}: {elapsed:.2f}s")

with timer("Operation"):
    expensive_operation()
```

## Development Patterns

### Protocol for Interfaces

```python
from typing import Protocol

class Drawable(Protocol):
    """Define interfaces without inheritance."""
    def draw(self) -> str: ...
    def move(self, x: int, y: int) -> None: ...

class Circle:
    """Implicitly implements Drawable."""
    def draw(self) -> str:
        return "Drawing circle"

    def move(self, x: int, y: int) -> None:
        self.x, self.y = x, y

def render(obj: Drawable) -> str:
    """Works with any Drawable."""
    return obj.draw()

# Type checker validates Circle is Drawable
render(Circle())  # ✅
```

### Generic Types

```python
from typing import TypeVar, Generic

T = TypeVar('T')

class Stack[T]:  # Modern generic syntax (3.12+)
    """Type-safe container."""
    def __init__(self) -> None:
        self._items: list[T] = []

    def push(self, item: T) -> None:
        self._items.append(item)

    def pop(self) -> T:
        return self._items.pop()

    def peek(self) -> T | None:
        return self._items[-1] if self._items else None

# Usage with type hints
int_stack: Stack[int] = Stack()
int_stack.push(42)
```

### @override Decorator

```python
from typing import override

class Base:
    def method(self) -> str:
        return "base"

class Derived(Base):
    @override  # Type checker ensures this actually overrides
    def method(self) -> str:
        return "derived"

    # @override
    # def typo_method(self) -> str:  # ❌ Error: doesn't override anything
    #     return "oops"
```

### Self Type for Method Chaining

```python
from typing import Self

class Builder:
    """Fluent interface with Self type."""
    def __init__(self) -> None:
        self.data: dict[str, str] = {}

    def add(self, key: str, value: str) -> Self:
        """Returns same type, even in subclasses."""
        self.data[key] = value
        return self

    def build(self) -> dict[str, str]:
        return self.data

# Works correctly with inheritance
class ExtendedBuilder(Builder):
    def add_multiple(self, **kwargs: str) -> Self:
        self.data.update(kwargs)
        return self

# Type hints work correctly through inheritance
result = ExtendedBuilder().add("a", "1").add_multiple(b="2")
```

## Best Practices

### Use Pathlib Over os.path

```python
from pathlib import Path

# Modern path handling
path = Path("data") / "users" / "file.txt"

if path.exists():
    content = path.read_text()

path.mkdir(parents=True, exist_ok=True)
path.write_text("data")

# Path properties
path.parent    # Parent directory
path.stem      # Filename without extension
path.suffix    # Extension (.txt)
path.name      # Full filename
```

### Comprehensions Over Loops

```python
# List comprehension
numbers = [i * 2 for i in range(10) if i % 2 == 0]

# Dict comprehension
squares = {x: x**2 for x in range(5)}

# Set comprehension
unique_lengths = {len(word) for word in words}

# Generator expression (memory efficient for large data)
sum_squares = sum(x**2 for x in range(1_000_000))
```

### F-strings for Formatting

```python
name = "Alice"
age = 30

# Modern string formatting
message = f"Hello, {name}. You are {age} years old."

# Expressions in f-strings
message = f"Next year: {age + 1}"

# Formatting
pi = 3.14159
formatted = f"Pi: {pi:.2f}"

# Debug format (3.8+)
print(f"{name=}, {age=}")  # name='Alice', age=30

# Multiline with expressions (3.12+)
result = f"""
User: {name}
Status: {"Adult" if age >= 18 else "Minor"}
Categories: {", ".join(categories)}
"""
```


### Walrus Operator for Assignment in Expressions

```python
# Assign and use in one expression (3.8+)
if (data := fetch_data()) is not None:
    process(data)

# In comprehensions
results = [
    result
    for item in items
    if (result := process(item)) is not None
]

# In while loops
while (line := file.readline()) != "":
    process(line)
```

### Enumerate Instead of Range

```python
items = ["a", "b", "c"]

# Don't use range(len(...))
for i in range(len(items)):
    print(i, items[i])

# Use enumerate
for i, item in enumerate(items):
    print(i, item)

# With custom start
for i, item in enumerate(items, start=1):
    print(f"Item {i}: {item}")
```

### Positional-Only and Keyword-Only Parameters

```python
def function(
    pos_only, /,          # Positional-only (before /)
    pos_or_kw,            # Positional or keyword
    *,                    # Keyword-only separator
    kw_only               # Keyword-only (after *)
) -> None:
    """Clear parameter semantics."""
    pass

# Usage
function(1, 2, kw_only=3)           # ✅
function(1, pos_or_kw=2, kw_only=3) # ✅
function(pos_only=1, ...)           # ❌ Error
function(1, 2, 3)                   # ❌ Error
```

## Performance

### Generators for Large Data

```python
from typing import Iterator

# Don't load everything in memory
def get_users() -> Iterator[dict[str, str]]:
    """Stream results instead of loading all."""
    for user in db.query_all():
        yield user

# Process without loading all in memory
for user in get_users():
    process(user)
```

### __slots__ for Memory Efficiency

```python
class Point:
    """Regular class uses dict for attributes."""
    def __init__(self, x: int, y: int) -> None:
        self.x = x
        self.y = y

class OptimizedPoint:
    """Slots save 40-50% memory for many instances."""
    __slots__ = ('x', 'y')

    def __init__(self, x: int, y: int) -> None:
        self.x = x
        self.y = y

# Or use dataclass with slots
@dataclass(slots=True)
class FastPoint:
    x: int
    y: int
```

### Caching Expensive Operations

```python
from functools import lru_cache, cache

@lru_cache(maxsize=128)  # Bounded cache
def fibonacci(n: int) -> int:
    if n < 2:
        return n
    return fibonacci(n - 1) + fibonacci(n - 2)

@cache  # Unbounded cache (3.9+)
def expensive_computation(param: str) -> dict[str, str]:
    # Expensive operation
    return result
```

## Python 3.14+ Awareness

### Forward References Without Quotes

```python
# Python 3.14+ defers annotation evaluation by default
# This means forward references work without quotes

class Node:
    """Self-referencing class - works in 3.14+ without quotes."""
    def add_child(self, child: Node) -> None:  # ✅ No quotes needed in 3.14+
        self.children.append(child)

# For compatibility with Python 3.10-3.13, still use quotes:
class NodeCompat:
    """Self-referencing class - compatible with all versions."""
    def add_child(self, child: "NodeCompat") -> None:  # ✅ Works everywhere
        self.children.append(child)

# AGENT GUIDANCE: Use quotes for forward references unless project requires 3.14+
```

### Experimental Features (Not for Production Use)

```python
# Python 3.14 includes experimental features that agents should NOT recommend:

# ❌ JIT Compiler (-X jit flag)
# - Experimental, mixed results (~8% faster overall, but often slower)
# - Not production-ready as of Python 3.14
# - Agents should NOT suggest using this

# ❌ Free-threading (No-GIL build)
# - Requires special Python build (python3.14t)
# - Not available in standard environments
# - Agents should NOT write code assuming this

# ❌ T-strings (template string literals)
# - Too new, most projects on Python 3.10-3.13
# - Agents should NOT use t"..." syntax

# AGENT GUIDANCE: Stick to stable, widely-supported features (3.10-3.13)
# Only use 3.14-specific features if project explicitly requires Python 3.14+
```

## Summary of Essential Modern Features

**Always Use** (Python 3.10+ compatible):
- Type hints everywhere (functions, classes, variables)
- Dataclasses with `slots=True` for data models
- Pattern matching for complex conditionals
- Async/await for I/O operations
- Context managers for resource management
- Pathlib for file operations
- F-strings for string formatting
- Comprehensions over loops
- Union types with `|` instead of `Union`

**Python 3.11+**:
- Exception groups with `except*`
- `Self` type for method chaining
- `TaskGroup` for async operations

**Python 3.12+**:
- Type parameter syntax `[T]` for generics
- `@override` decorator for explicit overrides

**Python 3.13+**:
- `TypedDict` with `Unpack` for `**kwargs`

**Python 3.14+**:
- Forward references without quotes (automatic deferred evaluation)
- ❌ **Do NOT use**: JIT compiler, free-threading, t-strings (experimental/requires opt-in)

**Agent Guidelines**:
- Default to Python 3.10-3.13 compatibility unless project specifies 3.14+
- Use quotes for forward references for broader compatibility
- Avoid experimental features (JIT, no-GIL, t-strings)
- Focus on stable, widely-supported patterns

Focus on writing clean, type-safe, idiomatic Python code using production-ready features for better performance, maintainability, and developer experience.

## Related References

- **[async-patterns.md](async-patterns.md)** - Comprehensive async/await patterns, TaskGroup, timeouts, error handling
- **[type-safety-patterns.md](type-safety-patterns.md)** - Type safety, fail-fast principles, input validation, error handling
