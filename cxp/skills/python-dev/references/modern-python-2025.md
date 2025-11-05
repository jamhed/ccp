# Modern Python 2025 - Best Practices Guide

Comprehensive guide to modern Python development using Python 3.11+ features, idioms, and best practices.

## Python Version Features

### Python 3.10 (Released Oct 2021)

**Pattern Matching (Structural)**:
```python
# Match statements for complex conditionals
def process_command(command: dict) -> str:
    match command:
        case {"action": "create", "resource": resource, "name": name}:
            return f"Creating {resource}: {name}"
        case {"action": "delete", "resource": resource}:
            return f"Deleting {resource}"
        case {"action": "list"}:
            return "Listing all resources"
        case _:
            return "Unknown command"

# Pattern matching with guards
def classify_point(point: tuple[int, int]) -> str:
    match point:
        case (0, 0):
            return "Origin"
        case (0, y):
            return f"Y-axis at {y}"
        case (x, 0):
            return f"X-axis at {x}"
        case (x, y) if x == y:
            return f"Diagonal at {x}"
        case (x, y):
            return f"Point at ({x}, {y})"
```

**Union Types with `|`**:
```python
# New union syntax (preferred over Union)
from typing import Optional

# Old way (still works)
from typing import Union
def old_way(value: Union[int, str]) -> Union[int, None]:
    pass

# New way (Python 3.10+)
def new_way(value: int | str) -> int | None:
    pass

# Optional is now syntactic sugar
def process(value: str | None = None) -> None:  # Same as Optional[str]
    pass
```

**TypeAlias**:
```python
from typing import TypeAlias

# Explicit type aliases
UserId: TypeAlias = int
UserName: TypeAlias = str
UserDict: TypeAlias = dict[str, str | int]

def get_user(user_id: UserId) -> UserDict:
    return {"id": user_id, "name": "John"}
```

### Python 3.11 (Released Oct 2022)

**Exception Groups**:
```python
# Handle multiple exceptions
def process_batch(items: list[str]) -> None:
    errors = []
    for item in items:
        try:
            process_item(item)
        except ValueError as e:
            errors.append(e)

    if errors:
        raise ExceptionGroup("Batch processing failed", errors)

# Catch exception groups
try:
    process_batch(items)
except* ValueError as eg:
    for exc in eg.exceptions:
        print(f"ValueError: {exc}")
except* KeyError as eg:
    for exc in eg.exceptions:
        print(f"KeyError: {exc}")
```

**Self Type**:
```python
from typing import Self

class Builder:
    def __init__(self) -> None:
        self.data: dict[str, str] = {}

    def add(self, key: str, value: str) -> Self:  # Returns same type
        self.data[key] = value
        return self

    def build(self) -> dict[str, str]:
        return self.data

# Works correctly with inheritance
class ExtendedBuilder(Builder):
    def add_multiple(self, **kwargs: str) -> Self:  # Returns ExtendedBuilder
        self.data.update(kwargs)
        return self

builder = ExtendedBuilder().add("a", "1").add_multiple(b="2", c="3")
```

**Task and TaskGroup**:
```python
import asyncio

async def process_urls(urls: list[str]) -> list[str]:
    async with asyncio.TaskGroup() as tg:
        tasks = [tg.create_task(fetch_url(url)) for url in urls]

    # All tasks completed or exception raised
    return [task.result() for task in tasks]
```

**Better Error Messages**:
```python
# Python 3.11 shows exact location of errors
result = calculate_total(
    price=100,
    quantity=5,
    discount=0.1
          # ^ Syntax error here clearly marked
)
```

### Python 3.12 (Released Oct 2023)

**Type Parameter Syntax**:
```python
# Old way
from typing import TypeVar, Generic

T = TypeVar('T')

class OldStack(Generic[T]):
    def push(self, item: T) -> None: ...

# New way (3.12+)
class Stack[T]:
    def push(self, item: T) -> None: ...

def first[T](items: list[T]) -> T | None:
    return items[0] if items else None
```

**@override Decorator**:
```python
from typing import override

class Base:
    def method(self) -> str:
        return "base"

class Derived(Base):
    @override  # Type checker ensures this actually overrides
    def method(self) -> str:
        return "derived"

    @override
    def typo_method(self) -> str:  # Error: doesn't override anything
        return "oops"
```

**f-string Improvements**:
```python
# Can now include quotes and backslashes
name = "World"
print(f"Hello, {name!r}")  # Hello, 'World'
print(f"Path: {os.path.join('a', 'b')}")  # Works now

# Multiline expressions
result = f"""
Total: {
    sum(
        item.price * item.quantity
        for item in items
    )
}
"""
```

## Type Hints Best Practices

### Comprehensive Type Coverage

```python
from typing import Protocol, TypeVar, Generic, Callable
from collections.abc import Sequence, Mapping, Iterable

# Function signatures
def process_user(
    user_id: int,
    name: str,
    email: str | None = None,
    tags: list[str] | None = None,
) -> dict[str, str | int]:
    """Process user with complete type hints."""
    result: dict[str, str | int] = {"id": user_id, "name": name}
    if email:
        result["email"] = email
    return result

# Class with type hints
class User:
    def __init__(
        self,
        user_id: int,
        name: str,
        email: str | None = None,
    ) -> None:
        self.user_id: int = user_id
        self.name: str = name
        self.email: str | None = email

    def to_dict(self) -> dict[str, str | int]:
        data: dict[str, str | int] = {
            "id": self.user_id,
            "name": self.name,
        }
        if self.email:
            data["email"] = self.email
        return data
```

### Generic Types

```python
from typing import TypeVar, Generic, Protocol

T = TypeVar('T')
K = TypeVar('K')
V = TypeVar('V')

class Stack(Generic[T]):
    """Generic stack implementation."""

    def __init__(self) -> None:
        self._items: list[T] = []

    def push(self, item: T) -> None:
        self._items.append(item)

    def pop(self) -> T:
        return self._items.pop()

    def peek(self) -> T | None:
        return self._items[-1] if self._items else None

# Usage
int_stack: Stack[int] = Stack()
int_stack.push(1)
int_stack.push(2)

str_stack: Stack[str] = Stack()
str_stack.push("hello")
```

### Protocol (Structural Subtyping)

```python
from typing import Protocol

class Drawable(Protocol):
    """Protocol for drawable objects."""

    def draw(self) -> str: ...
    def move(self, x: int, y: int) -> None: ...

class Circle:
    """Implements Drawable implicitly."""

    def draw(self) -> str:
        return "Drawing circle"

    def move(self, x: int, y: int) -> None:
        print(f"Moving circle to ({x}, {y})")

def render(obj: Drawable) -> str:
    """Works with any Drawable."""
    return obj.draw()

circle = Circle()
render(circle)  # Type checks correctly
```

### Callable Types

```python
from typing import Callable

# Simple callable
Validator = Callable[[str], bool]

def validate_email(email: str) -> bool:
    return "@" in email

def process_input(value: str, validator: Validator) -> str | None:
    return value if validator(value) else None

# Complex callable with multiple parameters
TransformFunc = Callable[[int, str], dict[str, int | str]]

def transform(n: int, s: str) -> dict[str, int | str]:
    return {"number": n, "text": s}
```

## Dataclasses and Pydantic

### Dataclasses

```python
from dataclasses import dataclass, field
from typing import ClassVar

@dataclass
class User:
    """User data model."""

    user_id: int
    name: str
    email: str
    is_active: bool = True
    tags: list[str] = field(default_factory=list)

    # Class variable
    MAX_NAME_LENGTH: ClassVar[int] = 100

    def __post_init__(self) -> None:
        """Validate after initialization."""
        if len(self.name) > self.MAX_NAME_LENGTH:
            raise ValueError(f"Name too long: {len(self.name)}")

# Frozen dataclass (immutable)
@dataclass(frozen=True)
class Point:
    x: int
    y: int

# Dataclass with slots (memory efficient)
@dataclass(slots=True)
class Coordinate:
    lat: float
    lon: float
```

### Pydantic Models

```python
from pydantic import BaseModel, Field, EmailStr, validator
from datetime import datetime

class UserCreate(BaseModel):
    """User creation model with validation."""

    name: str = Field(..., min_length=1, max_length=100)
    email: EmailStr
    age: int = Field(..., ge=0, le=150)
    tags: list[str] = Field(default_factory=list)

    @validator('name')
    def name_must_not_be_empty(cls, v: str) -> str:
        if not v.strip():
            raise ValueError('Name cannot be empty')
        return v.strip()

    class Config:
        json_schema_extra = {
            "example": {
                "name": "John Doe",
                "email": "john@example.com",
                "age": 30,
                "tags": ["admin", "user"],
            }
        }

class UserResponse(BaseModel):
    """User response model."""

    id: int
    name: str
    email: str
    created_at: datetime

    class Config:
        from_attributes = True  # Pydantic v2 (was orm_mode in v1)
```

## Async/Await Patterns

### Basic Async

```python
import asyncio
from typing import List

async def fetch_data(url: str) -> dict[str, str]:
    """Fetch data asynchronously."""
    await asyncio.sleep(1)  # Simulate I/O
    return {"url": url, "status": "ok"}

async def fetch_multiple(urls: list[str]) -> list[dict[str, str]]:
    """Fetch multiple URLs concurrently."""
    tasks = [fetch_data(url) for url in urls]
    return await asyncio.gather(*tasks)

# Run async code
async def main() -> None:
    urls = ["http://example.com", "http://example.org"]
    results = await fetch_multiple(urls)
    print(results)

asyncio.run(main())
```

### Async Context Managers

```python
from typing import AsyncIterator
import asyncio

class AsyncResource:
    """Async context manager for resources."""

    async def __aenter__(self) -> 'AsyncResource':
        print("Acquiring resource")
        await asyncio.sleep(0.1)
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb) -> None:
        print("Releasing resource")
        await asyncio.sleep(0.1)

async def use_resource() -> None:
    async with AsyncResource() as resource:
        print("Using resource")
```

### Async Generators

```python
from typing import AsyncIterator

async def generate_numbers(n: int) -> AsyncIterator[int]:
    """Async generator."""
    for i in range(n):
        await asyncio.sleep(0.1)
        yield i

async def consume_numbers() -> None:
    async for num in generate_numbers(5):
        print(num)
```

## Error Handling

### Specific Exceptions

```python
# Don't: Bare except
try:
    result = risky_operation()
except:  # Too broad!
    handle_error()

# Do: Specific exceptions
try:
    result = risky_operation()
except ValueError as e:
    handle_value_error(e)
except KeyError as e:
    handle_key_error(e)
except Exception as e:
    # Log unexpected errors
    logger.error(f"Unexpected error: {e}", exc_info=True)
    raise
```

### Exception Chaining

```python
class ValidationError(Exception):
    """Custom validation error."""
    pass

def validate_user(data: dict[str, str]) -> None:
    try:
        email = data["email"]
        if "@" not in email:
            raise ValueError("Invalid email format")
    except KeyError as e:
        # Chain exceptions to preserve context
        raise ValidationError(f"Missing required field: {e}") from e
    except ValueError as e:
        # Re-raise with more context
        raise ValidationError(f"Invalid user data: {e}") from e
```

### Custom Exceptions

```python
class AppError(Exception):
    """Base exception for application."""

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
        self.resource = resource
        self.resource_id = resource_id

# Usage
def get_user(user_id: int) -> dict[str, str]:
    user = db.query(user_id)
    if not user:
        raise NotFoundError("User", user_id)
    return user
```

## Best Practices

### Avoid Mutable Defaults

```python
# Don't: Mutable default argument
def add_item(item: str, items: list[str] = []) -> list[str]:  # Bug!
    items.append(item)
    return items

# Do: Use None and create new list
def add_item(item: str, items: list[str] | None = None) -> list[str]:
    if items is None:
        items = []
    items.append(item)
    return items
```

### Use Context Managers

```python
# Don't: Manual resource management
file = open("data.txt")
try:
    data = file.read()
finally:
    file.close()

# Do: Use context manager
with open("data.txt") as file:
    data = file.read()

# Custom context manager
from contextlib import contextmanager

@contextmanager
def timer(name: str):
    start = time.time()
    try:
        yield
    finally:
        elapsed = time.time() - start
        print(f"{name} took {elapsed:.2f}s")

with timer("Operation"):
    perform_operation()
```

### List/Dict Comprehensions

```python
# Instead of loops
numbers = []
for i in range(10):
    if i % 2 == 0:
        numbers.append(i * 2)

# Use comprehension
numbers = [i * 2 for i in range(10) if i % 2 == 0]

# Dict comprehension
squares = {x: x**2 for x in range(5)}

# Set comprehension
unique_lengths = {len(word) for word in words}

# Generator expression (memory efficient)
sum_squares = sum(x**2 for x in range(1000000))
```

### Pathlib Over os.path

```python
from pathlib import Path

# Don't: os.path
import os
path = os.path.join("data", "users", "file.txt")
if os.path.exists(path):
    with open(path) as f:
        data = f.read()

# Do: pathlib
path = Path("data") / "users" / "file.txt"
if path.exists():
    data = path.read_text()

# Path operations
path.parent  # Parent directory
path.stem    # Filename without extension
path.suffix  # File extension
path.mkdir(parents=True, exist_ok=True)  # Create directory
```

### Enumerate Instead of Range

```python
# Don't
items = ["a", "b", "c"]
for i in range(len(items)):
    print(i, items[i])

# Do
for i, item in enumerate(items):
    print(i, item)

# With start index
for i, item in enumerate(items, start=1):
    print(f"Item {i}: {item}")
```

### F-strings for Formatting

```python
name = "Alice"
age = 30

# Don't: Old style
message = "Hello, %s. You are %d years old." % (name, age)
message = "Hello, {}. You are {} years old.".format(name, age)

# Do: F-strings
message = f"Hello, {name}. You are {age} years old."

# With expressions
message = f"Next year: {age + 1}"

# With formatting
pi = 3.14159
formatted = f"Pi is approximately {pi:.2f}"

# Debug format (Python 3.8+)
print(f"{name=}, {age=}")  # name='Alice', age=30
```

## Performance Tips

### Use Generators for Large Data

```python
# Don't: Load everything in memory
def get_all_users() -> list[dict[str, str]]:
    return [user for user in db.query_all()]  # Memory intensive

# Do: Use generator
def get_all_users() -> Iterator[dict[str, str]]:
    for user in db.query_all():
        yield user

# Process without loading all in memory
for user in get_all_users():
    process_user(user)
```

### Use `__slots__` for Many Instances

```python
# Regular class (uses dict for attributes)
class RegularPoint:
    def __init__(self, x: int, y: int) -> None:
        self.x = x
        self.y = y

# Optimized class (uses slots)
class OptimizedPoint:
    __slots__ = ('x', 'y')

    def __init__(self, x: int, y: int) -> None:
        self.x = x
        self.y = y

# 40-50% memory savings for millions of instances
```

### Cache Expensive Operations

```python
from functools import lru_cache, cache

@lru_cache(maxsize=128)
def fibonacci(n: int) -> int:
    if n < 2:
        return n
    return fibonacci(n - 1) + fibonacci(n - 2)

@cache  # Python 3.9+, unbounded cache
def expensive_operation(param: str) -> dict[str, str]:
    # Expensive computation
    return result
```

## Modern Python Idioms

### Walrus Operator (3.8+)

```python
# Without walrus
data = fetch_data()
if data:
    process(data)

# With walrus (assign and check)
if data := fetch_data():
    process(data)

# In comprehensions
results = [result for item in items if (result := process(item)) is not None]
```

### Positional-Only and Keyword-Only Parameters

```python
def function(
    pos_only, /,          # Positional-only
    pos_or_kw,            # Positional or keyword
    *,                    # Keyword-only separator
    kw_only               # Keyword-only
) -> None:
    pass

# Usage
function(1, 2, kw_only=3)           # OK
function(1, pos_or_kw=2, kw_only=3) # OK
function(pos_only=1, ...)           # Error: pos_only is positional-only
function(1, 2, 3)                   # Error: kw_only is keyword-only
```

### Type Guards (3.10+)

```python
from typing import TypeGuard

def is_string_list(val: list[object]) -> TypeGuard[list[str]]:
    """Type guard for list of strings."""
    return all(isinstance(item, str) for item in val)

def process(items: list[object]) -> None:
    if is_string_list(items):
        # Type checker knows items is list[str] here
        print(items[0].upper())
```

This guide covers modern Python development practices for Python 3.11+ with emphasis on type safety, async patterns, and idiomatic code.
