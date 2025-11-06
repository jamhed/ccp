# Type Safety Patterns in Python

Comprehensive guide to writing type-safe Python code using mypy and pyright with modern type hints, including Python 3.13+ and 3.14+ features.

## Python 3.13+ Type System Improvements

### TypedDict for **kwargs (PEP 692, Python 3.13+)

```python
from typing import TypedDict, Unpack

# Define typed kwargs structure
class PersonKwargs(TypedDict):
    name: str
    age: int
    email: str
    city: str | None  # Optional field

def create_person(**kwargs: Unpack[PersonKwargs]) -> dict[str, str | int]:
    """Function with typed **kwargs."""
    return {
        "name": kwargs["name"],
        "age": kwargs["age"],
        "email": kwargs["email"],
        "city": kwargs.get("city", "Unknown"),
    }

# Type checker validates kwargs at call site
create_person(name="Alice", age=30, email="alice@example.com", city="NYC")  # ✅
create_person(name="Bob", age="30", email="bob@example.com")  # ❌ Type error: age must be int
create_person(name="Charlie")  # ❌ Type error: missing required kwargs

# Partial kwargs with Required/NotRequired
from typing import Required, NotRequired

class PartialKwargs(TypedDict):
    name: Required[str]  # Required
    age: Required[int]   # Required
    email: NotRequired[str]  # Optional
    city: NotRequired[str]   # Optional

def create_user(**kwargs: Unpack[PartialKwargs]) -> dict[str, str | int]:
    """Only name and age are required."""
    result = {
        "name": kwargs["name"],
        "age": kwargs["age"],
    }
    if "email" in kwargs:
        result["email"] = kwargs["email"]
    return result

# Works with defaults
create_user(name="Alice", age=30)  # ✅ email and city optional
```

### Enhanced Type Parameter Syntax (Python 3.12+, Improved in 3.14)

```python
# Old way (still works)
from typing import TypeVar, Generic

T = TypeVar('T')

class Stack(Generic[T]):
    def push(self, item: T) -> None: ...

# New way (Python 3.12+)
class Stack[T]:
    """Generic stack with new syntax."""
    def __init__(self) -> None:
        self._items: list[T] = []

    def push(self, item: T) -> None:
        self._items.append(item)

    def pop(self) -> T:
        return self._items.pop()

# Generic functions with new syntax
def first[T](items: list[T]) -> T | None:
    """Get first item with type safety."""
    return items[0] if items else None

def map_values[K, V, R](d: dict[K, V], func: Callable[[V], R]) -> dict[K, R]:
    """Map dictionary values with full type safety."""
    return {k: func(v) for k, v in d.items()}

# Multiple type parameters
def merge[K, V1, V2](
    d1: dict[K, V1],
    d2: dict[K, V2]
) -> dict[K, V1 | V2]:
    """Merge two dicts with different value types."""
    return {**d1, **d2}
```

## Type Hint Fundamentals

### Basic Types

```python
from typing import Any

# Built-in types
name: str = "Alice"
age: int = 30
price: float = 19.99
is_active: bool = True

# Collections
numbers: list[int] = [1, 2, 3]
names: tuple[str, str] = ("Alice", "Bob")
scores: dict[str, int] = {"Alice": 95, "Bob": 87}
unique_ids: set[int] = {1, 2, 3}

# Multiple types (Union)
id_value: int | str = "user_123"  # Python 3.10+
count: int | None = None          # Optional[int]

# Any (avoid when possible)
data: Any = {"anything": "goes"}  # No type checking
```

### Function Signatures

```python
def greet(name: str, age: int) -> str:
    """Complete function signature."""
    return f"Hello {name}, age {age}"

def process(
    value: int,
    multiplier: float = 1.0,
    *args: str,
    debug: bool = False,
    **kwargs: int,
) -> dict[str, int | float]:
    """Function with various parameter types."""
    result = value * multiplier
    return {"result": result, "args_count": len(args), **kwargs}

# No return value
def log_message(message: str) -> None:
    print(message)

# Never returns (always raises)
def fail(message: str) -> Never:  # Python 3.11+
    raise RuntimeError(message)
```

## Advanced Type Hints

### Generic Types

```python
from typing import TypeVar, Generic

T = TypeVar('T')
K = TypeVar('K')
V = TypeVar('V')

class Container(Generic[T]):
    """Generic container."""

    def __init__(self, value: T) -> None:
        self.value: T = value

    def get(self) -> T:
        return self.value

    def set(self, value: T) -> None:
        self.value = value

# Usage
int_container: Container[int] = Container(42)
str_container: Container[str] = Container("hello")

# Generic function
def first[T](items: list[T]) -> T | None:  # Python 3.12+
    return items[0] if items else None

# Or with TypeVar (older syntax)
def first_old(items: list[T]) -> T | None:
    return items[0] if items else None
```

### Bounded TypeVars

```python
from typing import TypeVar

# Bound to specific type
class Animal:
    def speak(self) -> str:
        return "..."

class Dog(Animal):
    def speak(self) -> str:
        return "Woof!"

AnimalType = TypeVar('AnimalType', bound=Animal)

def make_speak(animal: AnimalType) -> str:
    return animal.speak()  # Type checker knows .speak() exists

# Constrained to specific types
NumberType = TypeVar('NumberType', int, float)

def add(a: NumberType, b: NumberType) -> NumberType:
    return a + b  # Works with int or float only
```

### Protocol (Structural Typing)

```python
from typing import Protocol, runtime_checkable

class Closable(Protocol):
    """Protocol for closable objects."""

    def close(self) -> None: ...

class Drawable(Protocol):
    """Protocol for drawable objects."""

    def draw(self) -> str: ...
    def move(self, x: int, y: int) -> None: ...

# Any class implementing these methods automatically conforms
class Window:
    def close(self) -> None:
        print("Closing window")

class Circle:
    def draw(self) -> str:
        return "Drawing circle"

    def move(self, x: int, y: int) -> None:
        print(f"Moving to ({x}, {y})")

def close_resource(resource: Closable) -> None:
    resource.close()

def render(obj: Drawable) -> str:
    return obj.draw()

# Runtime checkable protocol
@runtime_checkable
class Sized(Protocol):
    def __len__(self) -> int: ...

def process_sized(obj: object) -> int:
    if isinstance(obj, Sized):  # Runtime check
        return len(obj)
    return 0
```

### TypedDict

```python
from typing import TypedDict, Required, NotRequired

# Basic TypedDict
class UserDict(TypedDict):
    name: str
    age: int
    email: str

# Optional fields (Python 3.11+)
class ConfigDict(TypedDict):
    host: str
    port: int
    ssl: NotRequired[bool]  # Optional
    timeout: NotRequired[int]  # Optional

# Or using total=False
class PartialDict(TypedDict, total=False):
    optional_field1: str
    optional_field2: int

# Mixed required/optional (Python 3.11+)
class MixedDict(TypedDict):
    required_field: Required[str]
    optional_field: NotRequired[int]

# Usage
user: UserDict = {
    "name": "Alice",
    "age": 30,
    "email": "alice@example.com",
}

config: ConfigDict = {
    "host": "localhost",
    "port": 8080,
    # ssl is optional
}
```

### Literal Types

```python
from typing import Literal

# Specific allowed values
Mode = Literal["read", "write", "append"]

def open_file(path: str, mode: Mode) -> None:
    print(f"Opening {path} in {mode} mode")

open_file("data.txt", "read")    # OK
open_file("data.txt", "delete")  # Error: invalid literal

# Multiple literals
Status = Literal["pending", "running", "completed", "failed"]
LogLevel = Literal["DEBUG", "INFO", "WARNING", "ERROR"]

def log(message: str, level: LogLevel = "INFO") -> None:
    print(f"[{level}] {message}")
```

### Final

```python
from typing import Final, final

# Final variable (cannot be reassigned)
MAX_CONNECTIONS: Final[int] = 100

# Final method (cannot be overridden)
class Base:
    @final
    def critical_method(self) -> str:
        return "Must not be overridden"

class Derived(Base):
    def critical_method(self) -> str:  # Error: Cannot override final method
        return "Override attempt"

# Final class (cannot be subclassed)
@final
class ImmutableConfig:
    def __init__(self, value: str) -> None:
        self.value: Final[str] = value

class Extended(ImmutableConfig):  # Error: Cannot subclass final class
    pass
```

## Type Narrowing

### isinstance() Checks

```python
def process_value(value: int | str | None) -> str:
    if value is None:
        # Type narrowed to None
        return "empty"

    if isinstance(value, int):
        # Type narrowed to int
        return f"number: {value * 2}"

    # Type narrowed to str (only remaining option)
    return f"text: {value.upper()}"
```

### Type Guards

```python
from typing import TypeGuard

def is_string_list(val: list[object]) -> TypeGuard[list[str]]:
    """Type guard checking if list contains only strings."""
    return all(isinstance(item, str) for item in val)

def process_items(items: list[object]) -> None:
    if is_string_list(items):
        # Type checker knows items is list[str]
        for item in items:
            print(item.upper())  # OK: str method

# More complex type guard
def is_dict_with_id(val: object) -> TypeGuard[dict[str, int]]:
    return (
        isinstance(val, dict) and
        "id" in val and
        isinstance(val["id"], int)
    )
```

### assert_type (Python 3.11+)

```python
from typing import assert_type

def process(value: int | str) -> None:
    if isinstance(value, int):
        # Verify type narrowing works
        assert_type(value, int)  # Passes
        # assert_type(value, str)  # Error: Type is int, not str

    assert_type(value, str)  # After if, type must be str
```

## Avoiding `Any`

### Use Specific Types

```python
# Don't: Too permissive
def process_data(data: Any) -> Any:
    return data["result"]

# Do: Specific types
def process_data(data: dict[str, int]) -> int:
    return data["result"]

# If truly dynamic, use TypedDict
class ResultDict(TypedDict):
    result: int
    status: str

def process_data_typed(data: ResultDict) -> int:
    return data["result"]
```

### Use Generics

```python
from typing import TypeVar

T = TypeVar('T')

# Don't: Using Any
def first_item_any(items: list[Any]) -> Any:
    return items[0] if items else None

# Do: Using generic
def first_item(items: list[T]) -> T | None:
    return items[0] if items else None

# Type is preserved
nums = [1, 2, 3]
first = first_item(nums)  # Type inferred as int | None
```

### Use Protocol for Duck Typing

```python
from typing import Protocol, Any

# Don't: Accept anything
def process_any(obj: Any) -> str:
    return obj.to_string()  # Hope it has to_string()

# Do: Define protocol
class Stringable(Protocol):
    def to_string(self) -> str: ...

def process_stringable(obj: Stringable) -> str:
    return obj.to_string()  # Type-safe
```

## Common Patterns

### Optional Values

```python
from typing import Optional

# Old style
def find_user_old(user_id: int) -> Optional[dict[str, str]]:
    # ...
    return None

# New style (Python 3.10+)
def find_user(user_id: int) -> dict[str, str] | None:
    user = db.query(user_id)
    return user if user else None

# Handling optional values
def process_user(user_id: int) -> str:
    user = find_user(user_id)

    if user is None:
        return "User not found"

    # Type narrowed to dict[str, str]
    return user["name"]
```

### Callable Types

```python
from typing import Callable
from collections.abc import Callable as ABCCallable  # Python 3.9+

# Simple callable
Handler = Callable[[str], None]

def register_handler(handler: Handler) -> None:
    handler("test")

# Multiple parameters
Transformer = Callable[[int, str], dict[str, int]]

# Generic callable
T = TypeVar('T')
R = TypeVar('R')

Mapper = Callable[[T], R]

def map_items(items: list[T], mapper: Mapper[T, R]) -> list[R]:
    return [mapper(item) for item in items]
```

### Sequence and Mapping

```python
from collections.abc import Sequence, Mapping, Iterable, Iterator

# Accept any sequence (list, tuple, etc.)
def process_sequence(items: Sequence[int]) -> int:
    return sum(items)

process_sequence([1, 2, 3])      # OK: list
process_sequence((1, 2, 3))      # OK: tuple
process_sequence(range(1, 4))    # OK: range

# Accept any mapping (dict, OrderedDict, etc.)
def process_mapping(data: Mapping[str, int]) -> int:
    return sum(data.values())

# Iterable for large data
def process_large_data(items: Iterable[int]) -> int:
    total = 0
    for item in items:
        total += item
    return total
```

### Overload

```python
from typing import overload

@overload
def process(value: int) -> int: ...

@overload
def process(value: str) -> str: ...

def process(value: int | str) -> int | str:
    """Process different types differently."""
    if isinstance(value, int):
        return value * 2
    return value.upper()

# Type checker knows return type based on input
result1: int = process(5)         # OK
result2: str = process("hello")   # OK
result3: str = process(5)         # Error: result is int, not str
```

## Dataclass Type Hints

```python
from dataclasses import dataclass, field
from typing import ClassVar

@dataclass
class User:
    """User with complete type hints."""

    user_id: int
    name: str
    email: str
    is_active: bool = True
    tags: list[str] = field(default_factory=list)
    metadata: dict[str, str] = field(default_factory=dict)

    # Class variable (not instance variable)
    MAX_NAME_LENGTH: ClassVar[int] = 100

    def to_dict(self) -> dict[str, str | int | bool | list[str]]:
        return {
            "user_id": self.user_id,
            "name": self.name,
            "email": self.email,
            "is_active": self.is_active,
            "tags": self.tags,
        }

@dataclass(frozen=True)
class Point:
    """Immutable point."""
    x: int
    y: int

    def distance_from_origin(self) -> float:
        return (self.x**2 + self.y**2)**0.5
```

## Mypy Configuration

### pyproject.toml

```toml
[tool.mypy]
python_version = "3.14"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true
disallow_any_generics = true
disallow_subclassing_any = true
disallow_untyped_calls = true
disallow_incomplete_defs = true
check_untyped_defs = true
disallow_untyped_decorators = true
no_implicit_optional = true
warn_redundant_casts = true
warn_unused_ignores = true
warn_no_return = true
warn_unreachable = true
strict_equality = true
strict = true

[[tool.mypy.overrides]]
module = "tests.*"
disallow_untyped_defs = false

[[tool.mypy.overrides]]
module = "third_party.*"
ignore_missing_imports = true
```

### mypy.ini

```ini
[mypy]
python_version = 3.14
warn_return_any = True
warn_unused_configs = True
disallow_untyped_defs = True
disallow_any_generics = True
disallow_subclassing_any = True
disallow_untyped_calls = True
disallow_incomplete_defs = True
check_untyped_defs = True
disallow_untyped_decorators = True
no_implicit_optional = True
warn_redundant_casts = True
warn_unused_ignores = True
warn_no_return = True
warn_unreachable = True
strict_equality = True

[mypy-tests.*]
disallow_untyped_defs = False

[mypy-third_party.*]
ignore_missing_imports = True
```

## Pyright Configuration

### pyrightconfig.json

```json
{
  "include": ["src"],
  "exclude": [
    "**/node_modules",
    "**/__pycache__",
    "**/.venv"
  ],
  "typeCheckingMode": "strict",
  "reportMissingTypeStubs": false,
  "reportUnknownMemberType": false,
  "pythonVersion": "3.14",
  "pythonPlatform": "Linux"
}
```

## Common Type Checking Errors

### Error: Incompatible return type

```python
# Error
def get_name() -> str:
    user = find_user()
    return user["name"]  # Error: might be None

# Fix with type narrowing
def get_name() -> str:
    user = find_user()
    if user is None:
        return "Unknown"
    return user["name"]

# Or with explicit default
def get_name() -> str:
    user = find_user()
    return user["name"] if user else "Unknown"
```

### Error: Argument type mismatch

```python
# Error
def process(value: int) -> str:
    return str(value)

result: int = process("hello")  # Error: str is not int

# Fix
result: str = process(123)  # OK
```

### Error: Missing type annotation

```python
# Error
def calculate(x, y):  # Error: Missing type annotations
    return x + y

# Fix
def calculate(x: int, y: int) -> int:
    return x + y
```

## Best Practices

### 1. Always Add Type Hints

```python
# Every function should have type hints
def process(data: dict[str, int]) -> list[str]:
    return [str(v) for v in data.values()]
```

### 2. Use Specific Collection Types

```python
# Don't: Too generic
def process(items: list) -> list:
    pass

# Do: Specific types
def process(items: list[int]) -> list[str]:
    return [str(item) for item in items]
```

### 3. Avoid Any When Possible

```python
# Only use Any when truly necessary
from typing import Any

def deserialize_json(data: str) -> Any:  # OK: JSON can be anything
    return json.loads(data)
```

### 4. Use Protocols for Flexibility

```python
# Instead of requiring specific class
from typing import Protocol

class Saveable(Protocol):
    def save(self) -> None: ...

def save_all(items: list[Saveable]) -> None:
    for item in items:
        item.save()
```

### 5. Run Type Checkers in CI

```bash
# In CI pipeline
mypy src/
pyright src/
```

This comprehensive guide covers type safety patterns essential for writing robust, maintainable Python code.
