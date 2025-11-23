# Safe Development with Python Types

Practical guide to catching bugs early and writing safer Python code using type hints and type checkers (mypy/pyright).

## Why Type Safety Matters

Type hints help catch bugs before runtime:

```python
# Without types - bug discovered at runtime
def get_user_age(user):
    return user["age"] * 2  # Oops, multiplying age by 2

age = get_user_age({"name": "Alice"})  # KeyError at runtime!

# With types - bug caught by type checker
def get_user_age(user: dict[str, int]) -> int:
    return user["age"] * 2  # Type checker: "age" key might not exist

# Better - explicit structure
from typing import TypedDict

class User(TypedDict):
    name: str
    age: int

def get_user_age(user: User) -> int:
    return user["age"]  # Type-safe: "age" is guaranteed to exist

# Type checker catches this before you run code
get_user_age({"name": "Alice"})  # ❌ Error: Missing "age" key
```

## Essential Type Safety Patterns

### 1. Handle None Explicitly

```python
# Unsafe - crashes if user not found
def get_user_name(user_id: int) -> str:
    user = find_user(user_id)  # Returns User | None
    return user["name"]  # ❌ Type error: might be None

# Safe - handle None case
def get_user_name(user_id: int) -> str:
    user = find_user(user_id)
    if user is None:
        return "Unknown"
    return user["name"]  # ✅ Type narrowed to User

# Or use default
def get_user_name_alt(user_id: int) -> str:
    user = find_user(user_id)
    return user["name"] if user else "Unknown"
```

### 2. Type Narrow with isinstance()

```python
# Unsafe - assumes type without checking
def process_value(value: int | str | None) -> str:
    return value.upper()  # ❌ Error: int has no upper(), None crashes

# Safe - check type before using
def process_value(value: int | str | None) -> str:
    if value is None:
        return "empty"

    if isinstance(value, int):
        return f"number: {value}"

    # Type checker knows value is str here
    return f"text: {value.upper()}"
```

### 3. Use TypedDict for Dictionaries

```python
from typing import TypedDict, NotRequired

# Unsafe - no structure validation
def create_user(data: dict) -> dict:  # What keys? What types?
    return {
        "id": data["user_id"],  # Might be "id" not "user_id"
        "email": data["email"].lower(),  # Might not be string
    }

# Safe - explicit structure
class UserInput(TypedDict):
    user_id: int
    email: str
    phone: NotRequired[str]  # Optional field

class UserOutput(TypedDict):
    id: int
    email: str

def create_user(data: UserInput) -> UserOutput:
    return {
        "id": data["user_id"],
        "email": data["email"].lower(),
    }

# Type checker validates at call site
create_user({"user_id": 1, "email": "user@example.com"})  # ✅
create_user({"id": 1, "email": "user@example.com"})  # ❌ Wrong key
create_user({"user_id": "1", "email": "user@example.com"})  # ❌ Wrong type
```

### 4. Never Return None on Errors

```python
# Unsafe - errors hidden by None
def parse_config(path: str) -> dict[str, str] | None:
    try:
        with open(path) as f:
            return json.load(f)
    except Exception:
        return None  # ❌ Lost error information

# Safe - raise exceptions for errors
def parse_config(path: str) -> dict[str, str]:
    """Parse config file. Raises FileNotFoundError or JSONDecodeError."""
    with open(path) as f:
        return json.load(f)  # Let exceptions propagate

# Caller handles errors explicitly
try:
    config = parse_config("config.json")
except FileNotFoundError:
    config = get_default_config()
except json.JSONDecodeError as e:
    raise ValueError(f"Invalid config: {e}") from e
```

### 5. Use Literal for Fixed Values

```python
from typing import Literal

# Unsafe - accepts any string
def set_log_level(level: str) -> None:
    if level not in ("DEBUG", "INFO", "ERROR"):  # Runtime check
        raise ValueError(f"Invalid level: {level}")

# Safe - type checker enforces valid values
LogLevel = Literal["DEBUG", "INFO", "ERROR"]

def set_log_level(level: LogLevel) -> None:
    # No runtime check needed - type checker ensures correctness
    print(f"Setting level: {level}")

set_log_level("DEBUG")    # ✅
set_log_level("INVALID")  # ❌ Type error at development time
```

### 6. Protocol for Interface Safety

```python
from typing import Protocol

# Unsafe - accepts anything, hopes it has .save()
def save_all(items: list) -> None:
    for item in items:
        item.save()  # ❌ What if item has no save()?

# Safe - define required interface
class Saveable(Protocol):
    def save(self) -> None: ...

def save_all(items: list[Saveable]) -> None:
    for item in items:
        item.save()  # ✅ Type checker ensures save() exists

# Any class with save() method works
class User:
    def save(self) -> None:
        print("Saving user")

class Document:
    def save(self) -> None:
        print("Saving document")

save_all([User(), Document()])  # ✅ Both have save()
```

### 7. Generic Functions for Type Preservation

```python
from typing import TypeVar

T = TypeVar('T')

# Unsafe - loses type information
def get_first_unsafe(items: list) -> object | None:
    return items[0] if items else None

result = get_first_unsafe([1, 2, 3])  # Type: object | None
# result + 5  # ❌ Can't add int to object

# Safe - preserves type
def get_first(items: list[T]) -> T | None:
    return items[0] if items else None

result = get_first([1, 2, 3])  # Type: int | None
if result is not None:
    value = result + 5  # ✅ Type checker knows it's int
```

## Catching Common Bugs with Types

### Bug: Forgetting to Check None

```python
# Bug: crashes if user not found
def get_email(user_id: int) -> str:
    user = db.get_user(user_id)  # Returns User | None
    return user.email  # ❌ AttributeError if None

# Fixed: type checker forces None check
def get_email(user_id: int) -> str:
    user = db.get_user(user_id)
    if user is None:
        raise ValueError(f"User {user_id} not found")
    return user.email  # ✅ Type narrowed to User
```

### Bug: Mixing Incompatible Types

```python
# Bug: accidentally passing wrong type
def calculate_discount(price: float, percent: float) -> float:
    return price * (1 - percent)

discount = calculate_discount(100, "10%")  # ❌ Type error: str is not float
# Would crash at runtime with: TypeError: can't multiply sequence

# Fixed: type checker prevents this at development time
discount = calculate_discount(100, 0.10)  # ✅ Correct types
```

### Bug: Wrong Dictionary Keys

```python
# Bug: typo in key name
user_data = {"name": "Alice", "age": 30}
email = user_data["email"]  # ❌ KeyError at runtime

# Fixed with TypedDict
from typing import TypedDict

class UserData(TypedDict):
    name: str
    age: int

user: UserData = {"name": "Alice", "age": 30}
email = user["email"]  # ❌ Type error: "email" not in UserData
```

### Bug: Forgetting Return Value

```python
# Bug: forgot to return in some paths
def get_status(active: bool) -> str:
    if active:
        return "active"
    # ❌ Type error: Missing return statement
    # Would return None at runtime

# Fixed: type checker catches missing return
def get_status(active: bool) -> str:
    if active:
        return "active"
    return "inactive"  # ✅ All paths return str
```

### Bug: Mutating Shared State

```python
# Bug: mutable default argument
def add_tag(tag: str, tags: list[str] = []) -> list[str]:  # ❌ Dangerous!
    tags.append(tag)
    return tags

# Shared state bug:
tags1 = add_tag("python")  # ["python"]
tags2 = add_tag("go")      # ["python", "go"] - Oops!

# Fixed: type checker warns about mutable defaults (with strict settings)
def add_tag(tag: str, tags: list[str] | None = None) -> list[str]:
    if tags is None:
        tags = []
    tags.append(tag)
    return tags

tags1 = add_tag("python")  # ["python"]
tags2 = add_tag("go")      # ["go"] - Correct
```

## Advanced Safety Patterns

### Type-Safe Error Handling

```python
# Define specific error types
class UserError(Exception):
    """User-related errors."""
    pass

class NotFoundError(UserError):
    """Resource not found."""
    def __init__(self, resource: str, resource_id: int) -> None:
        super().__init__(f"{resource} {resource_id} not found")
        self.resource = resource
        self.resource_id = resource_id

class ValidationError(UserError):
    """Validation failed."""
    def __init__(self, field: str, message: str) -> None:
        super().__init__(f"{field}: {message}")
        self.field = field

# Type-safe error handling
def get_user(user_id: int) -> User:
    """Get user by ID. Raises NotFoundError if not found."""
    user = db.query_user(user_id)
    if user is None:
        raise NotFoundError("User", user_id)
    return user

# Caller knows exactly what errors to expect
try:
    user = get_user(123)
except NotFoundError as e:
    print(f"User not found: {e.resource_id}")
except ValidationError as e:
    print(f"Validation failed: {e.field}")
```

### Type-Safe Builder Pattern

```python
from typing import Self

class QueryBuilder:
    """Type-safe query builder."""

    def __init__(self) -> None:
        self._table: str | None = None
        self._where: list[str] = []

    def table(self, name: str) -> Self:
        """Set table name. Returns self for chaining."""
        self._table = name
        return self

    def where(self, condition: str) -> Self:
        """Add where condition. Returns self for chaining."""
        self._where.append(condition)
        return self

    def build(self) -> str:
        """Build query. Raises ValueError if table not set."""
        if self._table is None:
            raise ValueError("Table not set")

        query = f"SELECT * FROM {self._table}"
        if self._where:
            query += " WHERE " + " AND ".join(self._where)
        return query

# Type-safe method chaining
query = (
    QueryBuilder()
    .table("users")
    .where("age > 18")
    .where("active = true")
    .build()
)
```

### Type-Safe Async Code

```python
from typing import Awaitable
import asyncio

# Type-safe async function
async def fetch_user(user_id: int) -> User:
    """Fetch user asynchronously."""
    await asyncio.sleep(0.1)  # Simulate I/O
    return User(id=user_id, name="Alice")

# Type-safe concurrent execution
async def fetch_multiple(user_ids: list[int]) -> list[User]:
    """Fetch multiple users concurrently."""
    async with asyncio.TaskGroup() as tg:
        tasks = [tg.create_task(fetch_user(uid)) for uid in user_ids]
    return [task.result() for task in tasks]

# Generic async wrapper with timeout
async def with_timeout[T](coro: Awaitable[T], timeout: float) -> T:
    """Execute coroutine with timeout. Type-safe return value."""
    async with asyncio.timeout(timeout):
        return await coro
```

## Development Workflow

### 1. Configure Strict Type Checking

**pyproject.toml** (for mypy):
```toml
[tool.mypy]
python_version = "3.14"
strict = true
warn_return_any = true
warn_unused_ignores = true
disallow_untyped_defs = true
disallow_any_generics = true
```

**pyrightconfig.json** (for pyright):
```json
{
  "typeCheckingMode": "strict",
  "pythonVersion": "3.14",
  "reportMissingTypeStubs": false
}
```

### 2. Run Type Checkers in Development

```bash
# Fast type checking with pyright
pyright .

# Comprehensive checking with mypy
mypy .

# Run before commit
git commit && pyright && mypy
```

### 3. Fix Type Errors Progressively

```python
# Start with basic types
def process(data):  # No types
    return data

# Add function signature
def process(data: dict) -> dict:
    return data

# Add specific types
def process(data: dict[str, int]) -> dict[str, str]:
    return {k: str(v) for k, v in data.items()}

# Add TypedDict for structure
class InputData(TypedDict):
    user_id: int
    count: int

class OutputData(TypedDict):
    user_id: str
    count: str

def process(data: InputData) -> OutputData:
    return {
        "user_id": str(data["user_id"]),
        "count": str(data["count"]),
    }
```

### 4. Use Type Checkers in CI/CD

```yaml
# .github/workflows/ci.yml
- name: Type checking
  run: |
    pip install mypy pyright
    mypy src/
    pyright src/
```

## Common Type Safety Pitfalls

### Pitfall 1: Using Any Instead of Unknown Types

```python
from typing import Any

# ❌ Bad: Disables type checking
def process_json(data: Any) -> Any:
    return data["result"]

# ✅ Good: Use TypedDict for structure
class JsonResponse(TypedDict):
    result: str
    status: int

def process_json(data: JsonResponse) -> str:
    return data["result"]
```

### Pitfall 2: Ignoring None in Union Types

```python
# ❌ Bad: Assumes value is never None
def get_length(text: str | None) -> int:
    return len(text)  # Crashes if None!

# ✅ Good: Handle None explicitly
def get_length(text: str | None) -> int:
    return len(text) if text is not None else 0
```

### Pitfall 3: Not Using Specific Collection Types

```python
# ❌ Bad: Generic list/dict
def process_users(users: list) -> dict:
    return {user["id"]: user for user in users}

# ✅ Good: Specific types
class User(TypedDict):
    id: int
    name: str

def process_users(users: list[User]) -> dict[int, User]:
    return {user["id"]: user for user in users}
```

### Pitfall 4: Silent Type: ignore Comments

```python
# ❌ Bad: Hiding real type errors
result = unsafe_operation()  # type: ignore

# ✅ Good: Fix the underlying issue or use specific ignores
result = unsafe_operation()  # type: ignore[no-untyped-call]
# TODO: Add types to unsafe_operation()
```

## Quick Reference: Type Safety Checklist

✅ **Always do**:
- Add type hints to all functions (parameters and return types)
- Handle `None` explicitly with type narrowing
- Use `TypedDict` for dictionary structures
- Use `Literal` for fixed string/int values
- Use `Protocol` for duck-typed interfaces
- Run type checkers (`pyright` or `mypy`) before committing
- Configure strict type checking in CI/CD

❌ **Never do**:
- Return `None` on errors (raise exceptions instead)
- Use `Any` when you can use specific types
- Ignore type errors with `# type: ignore` without investigation
- Use mutable default arguments
- Skip type hints on public APIs
- Disable type checking for entire modules

## Summary

Type hints are your first line of defense against bugs. They:

1. **Catch bugs at development time** - Before code runs
2. **Document expected types** - Self-documenting code
3. **Enable better IDE support** - Autocomplete, refactoring
4. **Prevent None crashes** - Force explicit None handling
5. **Catch typos** - Dictionary keys, attribute names
6. **Ensure API contracts** - Function signatures enforced

**The type checker is your automated code reviewer** - use it to catch bugs before they reach production.
