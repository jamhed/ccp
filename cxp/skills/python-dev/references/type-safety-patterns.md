# Type Safety with Fail-Fast Principles

Guide to writing type-safe Python code that fails early and loudly. Type hints + strict validation = bugs caught at development time, not production.

## Core Principle: Fail Early, Fail Loudly

```python
# ❌ WRONG: Silent failures hide bugs
def get_user_age(user_id: int) -> int:
    user = find_user(user_id)  # Returns User | None
    if user is None:
        return 0  # Silent failure - hides missing user!
    return user["age"]

# ✅ CORRECT: Fail immediately with clear error
def get_user_age(user_id: int) -> int:
    user = find_user(user_id)
    if user is None:
        raise ValueError(f"User {user_id} not found")  # Fail loudly
    return user["age"]
```

**Why fail-fast matters**: Silent failures let bugs propagate. By the time you discover `age=0` is wrong, you're far from the root cause. Failing immediately shows exactly where and why.

## Essential Patterns for Safe Code

### 1. Validate Inputs Immediately

```python
# ❌ WRONG: Accept anything, hope it's valid
def process_user_data(data: dict) -> None:
    # Process data without validation
    user_id = data.get("id", 0)  # Defaults hide missing data
    email = data.get("email", "")  # Empty string is not valid!

# ✅ CORRECT: Validate structure at boundary
from typing import TypedDict

class UserData(TypedDict):
    id: int
    email: str
    name: str

def process_user_data(data: UserData) -> None:
    """Process user data. Type checker ensures structure is correct."""
    # No validation needed - TypedDict guarantees structure
    user_id = data["id"]  # Type checker ensures this exists
    email = data["email"]  # Type checker ensures this is str

# At system boundary (API, CLI, file input), validate early:
def handle_request(raw_data: dict) -> None:
    """Validate at boundary, then pass typed data internally."""
    # Fail fast if structure is wrong
    if "id" not in raw_data:
        raise ValueError("Missing required field: id")
    if "email" not in raw_data:
        raise ValueError("Missing required field: email")
    if not isinstance(raw_data["id"], int):
        raise TypeError(f"id must be int, got {type(raw_data['id'])}")

    # Now safe to cast - structure validated
    validated: UserData = raw_data  # type: ignore[assignment]
    process_user_data(validated)
```

### 2. Never Return None on Errors

```python
# ❌ WRONG: Returning None hides errors
def parse_config(path: str) -> dict[str, str] | None:
    try:
        with open(path) as f:
            return json.load(f)
    except Exception:
        return None  # Lost all error information!

# Caller doesn't know what went wrong:
config = parse_config("config.json")
if config is None:
    # Was it missing file? Parse error? Permission denied? Unknown!
    config = {}  # Wrong - hides real problem

# ✅ CORRECT: Raise exceptions with context
def parse_config(path: str) -> dict[str, str]:
    """
    Parse config file.

    Raises:
        FileNotFoundError: Config file not found
        JSONDecodeError: Invalid JSON syntax
        ValueError: Config has wrong structure
    """
    try:
        with open(path) as f:
            data = json.load(f)
    except FileNotFoundError as e:
        raise FileNotFoundError(f"Config file not found: {path}") from e
    except json.JSONDecodeError as e:
        raise ValueError(f"Invalid JSON in {path}: {e}") from e

    # Validate structure
    if not isinstance(data, dict):
        raise ValueError(f"Config must be dict, got {type(data)}")

    return data

# Caller handles specific errors explicitly:
try:
    config = parse_config("config.json")
except FileNotFoundError:
    # Specific handling for missing file
    raise RuntimeError("Config file required for startup") from None
except ValueError as e:
    # Specific handling for invalid config
    raise RuntimeError(f"Invalid configuration: {e}") from e
```

### 3. Validate at System Boundaries

```python
# ❌ WRONG: Trust external data
def create_user(request_data: dict) -> User:
    # Assume data is valid
    user = User(
        email=request_data["email"],  # Might not exist
        age=request_data["age"]  # Might be string "25"
    )
    return user

# ✅ CORRECT: Validate external data immediately
from typing import TypedDict

class CreateUserRequest(TypedDict):
    email: str
    age: int
    name: str

def validate_create_user_request(data: dict) -> CreateUserRequest:
    """
    Validate external request data.

    Raises:
        ValueError: Missing required field or invalid type
    """
    # Check required fields exist
    required = {"email", "age", "name"}
    missing = required - set(data.keys())
    if missing:
        raise ValueError(f"Missing required fields: {missing}")

    # Validate types
    if not isinstance(data["email"], str):
        raise ValueError(f"email must be str, got {type(data['email'])}")
    if not isinstance(data["age"], int):
        raise ValueError(f"age must be int, got {type(data['age'])}")
    if not isinstance(data["name"], str):
        raise ValueError(f"name must be str, got {type(data['name'])}")

    # Validate values
    if not data["email"] or "@" not in data["email"]:
        raise ValueError(f"Invalid email: {data['email']}")
    if data["age"] < 0 or data["age"] > 150:
        raise ValueError(f"Invalid age: {data['age']}")

    return data  # type: ignore[return-value]

def create_user(request_data: dict) -> User:
    """Create user from external request."""
    # Validate at boundary - fail fast if invalid
    validated = validate_create_user_request(request_data)

    # Now safe to use - guaranteed valid structure
    user = User(
        email=validated["email"],
        age=validated["age"],
        name=validated["name"]
    )
    return user
```

### 4. No Defensive Defaults - Fail Instead

```python
# ❌ WRONG: Defensive defaults hide missing data
def get_user_email(user_id: int) -> str:
    user = db.get_user(user_id)
    return user["email"] if user else ""  # Empty string hides missing user!

def send_notification(user_id: int) -> None:
    email = get_user_email(user_id)
    if email:  # Silently skips if empty
        send_email(email, "notification")
    # Bug: User exists but has no email? Or user doesn't exist? Unknown!

# ✅ CORRECT: Fail if data is missing
def get_user_email(user_id: int) -> str:
    """
    Get user email.

    Raises:
        ValueError: User not found
    """
    user = db.get_user(user_id)
    if user is None:
        raise ValueError(f"User {user_id} not found")
    if "email" not in user:
        raise ValueError(f"User {user_id} has no email")
    return user["email"]

def send_notification(user_id: int) -> None:
    """Send notification. Fails if user not found or has no email."""
    email = get_user_email(user_id)  # Raises if invalid
    send_email(email, "notification")
```

### 5. Type Narrowing with Strict Checks

```python
# ❌ WRONG: Lenient type handling
def process_value(value: int | str | None) -> str:
    # Convert everything to string
    return str(value) if value is not None else "null"
    # Loses distinction between 0 and None, "" and None

# ✅ CORRECT: Strict type handling with clear errors
def process_value(value: int | str | None) -> str:
    """
    Process value with strict type handling.

    Raises:
        ValueError: Value is None (not allowed)
    """
    if value is None:
        raise ValueError("Value cannot be None")  # Fail fast

    if isinstance(value, int):
        return f"number:{value}"

    # Type checker knows value is str here
    return f"text:{value}"

# Caller must handle None explicitly:
def handle_input(input_value: int | str | None) -> None:
    if input_value is None:
        raise ValueError("Input is required")  # Fail at boundary
    result = process_value(input_value)  # Safe - not None
```

### 6. Literal Types for Strict Validation

```python
from typing import Literal

# ❌ WRONG: Runtime validation only
def set_log_level(level: str) -> None:
    # Accepts any string, validates at runtime
    if level not in ("DEBUG", "INFO", "ERROR"):
        level = "INFO"  # Silent default hides typo!
    logger.setLevel(level)

# ✅ CORRECT: Type-checked at development time
LogLevel = Literal["DEBUG", "INFO", "ERROR"]

def set_log_level(level: LogLevel) -> None:
    """Set log level. Type checker ensures valid value."""
    logger.setLevel(level)  # No runtime check needed

# Type checker catches typos:
set_log_level("DEBUG")   # ✅
set_log_level("DEBGU")   # ❌ Type error at development time

# For external input, validate explicitly:
def set_log_level_from_input(level_str: str) -> None:
    """Set log level from external input."""
    valid_levels: set[LogLevel] = {"DEBUG", "INFO", "ERROR"}
    if level_str not in valid_levels:
        raise ValueError(
            f"Invalid log level: {level_str}. "
            f"Must be one of: {', '.join(valid_levels)}"
        )
    set_log_level(level_str)  # type: ignore[arg-type]
```

### 7. Protocol for Interface Enforcement

```python
from typing import Protocol

# ❌ WRONG: Duck typing without verification
def save_all(items: list) -> None:
    for item in items:
        item.save()  # Hope it has save()!

# ✅ CORRECT: Protocol enforces interface
class Saveable(Protocol):
    def save(self) -> None:
        """Save the item."""
        ...

def save_all(items: list[Saveable]) -> None:
    """Save all items. Type checker ensures all have save()."""
    for item in items:
        item.save()  # Type-safe

# Type checker catches missing methods:
class User:
    def save(self) -> None:
        db.save_user(self)

class Document:
    pass  # No save() method

save_all([User()])  # ✅
save_all([Document()])  # ❌ Type error: Document not Saveable
```

### 8. Use Abstract Types for Arguments

```python
from collections.abc import Sequence, Mapping, Iterable

# ❌ WRONG: Require specific concrete types
def process_items(items: list[int]) -> int:
    """Only accepts list - rejects tuple, range, etc."""
    return sum(items)

def merge_configs(config1: dict[str, int], config2: dict[str, int]) -> dict[str, int]:
    """Only accepts dict - rejects OrderedDict, etc."""
    return {**config1, **config2}

# ✅ CORRECT: Accept abstract types (more flexible)
def process_items(items: Sequence[int]) -> int:
    """Accept any sequence: list, tuple, range, etc."""
    if not items:
        raise ValueError("Items cannot be empty")
    return sum(items)

# Works with any sequence type:
process_items([1, 2, 3])        # ✅ list
process_items((1, 2, 3))        # ✅ tuple
process_items(range(1, 4))      # ✅ range

def merge_configs(
    config1: Mapping[str, int],
    config2: Mapping[str, int]
) -> dict[str, int]:
    """
    Accept any mapping type as input.
    Return concrete dict for implementation.

    Raises:
        ValueError: If either config is empty
    """
    if not config1 or not config2:
        raise ValueError("Both configs must be non-empty")
    return {**config1, **config2}

# Common abstract types from collections.abc:
# - Sequence: list, tuple, range, str
# - Mapping: dict, OrderedDict, ChainMap
# - Iterable: Any iterable including generators
# - Set: set, frozenset

# ✅ Use Iterable for large data (memory efficient)
def process_large_dataset(data: Iterable[int]) -> int:
    """Accept any iterable - including generators."""
    total = 0
    for value in data:
        if value < 0:
            raise ValueError(f"Negative value not allowed: {value}")
        total += value
    return total

# Works with generators (memory efficient):
process_large_dataset(x**2 for x in range(1000000))  # ✅
```

**Why abstract types**: Official [Python typing best practices](https://typing.python.org/en/latest/reference/best_practices.html) recommend: "Arguments: Favor abstract types and protocols. Return Types: Prefer concrete types."

### 9. Use `object` for Any Value, Not `Any`

```python
from typing import Any

# ❌ WRONG: Using Any disables type checking
def log_value(value: Any) -> None:
    """Any disables all type checking."""
    print(value)

def format_output(data: Any) -> str:
    """Any hides type errors."""
    return str(data)

# ✅ CORRECT: Use object when accepting any value
def log_value(value: object) -> None:
    """Accept any value, type checking still works."""
    print(value)  # str() accepts object

def format_output(data: object) -> str:
    """Convert any value to string."""
    return str(data)  # Type-safe

# ✅ Use Any ONLY when type system cannot express it
def deserialize_json(json_str: str) -> Any:
    """
    JSON can be any structure - Any is appropriate.

    Raises:
        ValueError: Invalid JSON syntax
    """
    try:
        return json.loads(json_str)
    except json.JSONDecodeError as e:
        raise ValueError(f"Invalid JSON: {e}") from e

# ✅ Use object for callbacks that ignore return value
def execute_callbacks(callbacks: list[Callable[[int], object]]) -> None:
    """Callback return values ignored - use object, not Any."""
    for callback in callbacks:
        callback(42)  # Return value ignored
```

**Why object over Any**: Official docs say: "Reserve `Any` for situations where a type cannot be expressed appropriately with the current type system. Prefer `object` when a function accepts any value."

## Catching Bugs with Fail-Fast + Types

### Bug: Silent None Handling

```python
# ❌ BUG: Returns 0 when user not found - hides error
def get_user_age_defensive(user_id: int) -> int:
    user = db.get_user(user_id)
    if user is None:
        return 0  # Silent default
    return user.get("age", 0)  # More silent defaults!

# Causes bug far from root cause:
age = get_user_age_defensive(999)  # Returns 0
if age < 18:
    # Wrong! User doesn't exist, but we treat as age=0
    restrict_access()

# ✅ FIXED: Fail immediately at source
def get_user_age(user_id: int) -> int:
    """
    Get user age.

    Raises:
        ValueError: User not found or has no age
    """
    user = db.get_user(user_id)
    if user is None:
        raise ValueError(f"User {user_id} not found")
    if "age" not in user:
        raise ValueError(f"User {user_id} has no age field")
    return user["age"]

# Caller handles error explicitly:
try:
    age = get_user_age(999)
    if age < 18:
        restrict_access()
except ValueError as e:
    # Clear error: user not found
    logger.error(f"Cannot check age: {e}")
    deny_access()  # Correct behavior
```

### Bug: Accepting Invalid Input

```python
# ❌ BUG: Accepts negative prices
def calculate_discount(price: float, percent: float) -> float:
    return price * (1 - percent)

# Caller can pass invalid values:
discount = calculate_discount(-100, 0.5)  # Negative price!
discount = calculate_discount(100, 1.5)   # 150% discount!

# ✅ FIXED: Validate inputs immediately
def calculate_discount(price: float, percent: float) -> float:
    """
    Calculate discounted price.

    Args:
        price: Original price (must be > 0)
        percent: Discount percent (0.0 to 1.0)

    Raises:
        ValueError: Invalid price or percent
    """
    if price <= 0:
        raise ValueError(f"Price must be positive, got {price}")
    if not 0 <= percent <= 1:
        raise ValueError(f"Percent must be 0-1, got {percent}")

    return price * (1 - percent)

# Catches bugs immediately:
calculate_discount(-100, 0.5)  # ✅ Raises ValueError immediately
calculate_discount(100, 1.5)   # ✅ Raises ValueError immediately
```

### Bug: Mutable Defaults

```python
# ❌ BUG: Shared mutable default
def add_tag(tag: str, tags: list[str] = []) -> list[str]:
    tags.append(tag)
    return tags

# Shared state bug:
tags1 = add_tag("python")  # ["python"]
tags2 = add_tag("go")      # ["python", "go"] - Bug!

# ✅ FIXED: Fail if None, don't use mutable default
def add_tag(tag: str, tags: list[str] | None = None) -> list[str]:
    """
    Add tag to list.

    Args:
        tag: Tag to add
        tags: Existing tags (creates new list if None)

    Raises:
        ValueError: tag is empty
    """
    if not tag:
        raise ValueError("Tag cannot be empty")

    if tags is None:
        tags = []

    tags.append(tag)
    return tags

tags1 = add_tag("python")  # ["python"]
tags2 = add_tag("go")      # ["go"] - Correct
```

## Advanced Fail-Fast Patterns

### Validation at Construction

```python
from dataclasses import dataclass

# ❌ WRONG: Allow invalid state
@dataclass
class User:
    email: str
    age: int

# Can create invalid users:
user = User(email="", age=-5)  # Invalid but allowed!

# ✅ CORRECT: Validate in __post_init__
@dataclass
class User:
    email: str
    age: int

    def __post_init__(self) -> None:
        """Validate user data immediately after construction."""
        if not self.email or "@" not in self.email:
            raise ValueError(f"Invalid email: {self.email}")
        if self.age < 0 or self.age > 150:
            raise ValueError(f"Invalid age: {self.age}")

# Fails immediately on construction:
user = User(email="", age=30)     # ✅ Raises ValueError
user = User(email="a@b.com", age=-5)  # ✅ Raises ValueError
```

### Type-Safe Error Handling

```python
# ❌ WRONG: Generic exceptions
def get_user(user_id: int) -> User:
    user = db.query(user_id)
    if not user:
        raise Exception("Error")  # Vague, loses context

# ✅ CORRECT: Specific exception types
class UserError(Exception):
    """Base exception for user operations."""
    pass

class UserNotFoundError(UserError):
    """User not found."""
    def __init__(self, user_id: int) -> None:
        super().__init__(f"User {user_id} not found")
        self.user_id = user_id

class UserInvalidError(UserError):
    """User data is invalid."""
    def __init__(self, user_id: int, reason: str) -> None:
        super().__init__(f"User {user_id} invalid: {reason}")
        self.user_id = user_id
        self.reason = reason

def get_user(user_id: int) -> User:
    """
    Get user by ID.

    Raises:
        UserNotFoundError: User doesn't exist
        UserInvalidError: User data is invalid
    """
    if user_id <= 0:
        raise ValueError(f"Invalid user_id: {user_id}")

    user = db.query(user_id)
    if user is None:
        raise UserNotFoundError(user_id)

    if not user.get("email"):
        raise UserInvalidError(user_id, "missing email")

    return user

# Caller can handle specific errors:
try:
    user = get_user(user_id)
except UserNotFoundError:
    # Specific handling for not found
    create_default_user(user_id)
except UserInvalidError as e:
    # Specific handling for invalid data
    logger.error(f"Invalid user: {e.reason}")
    raise
```

### Strict Async Validation

```python
import asyncio
from typing import Awaitable

# ❌ WRONG: Silent timeout handling
async def fetch_with_timeout(url: str, timeout: float = 5.0) -> dict | None:
    try:
        async with asyncio.timeout(timeout):
            return await fetch(url)
    except asyncio.TimeoutError:
        return None  # Silent failure!

# ✅ CORRECT: Fail loudly on timeout
async def fetch_with_timeout(url: str, timeout: float = 5.0) -> dict:
    """
    Fetch URL with timeout.

    Args:
        url: URL to fetch
        timeout: Timeout in seconds (must be > 0)

    Raises:
        ValueError: Invalid timeout
        asyncio.TimeoutError: Request timed out
    """
    if timeout <= 0:
        raise ValueError(f"Timeout must be positive, got {timeout}")

    try:
        async with asyncio.timeout(timeout):
            return await fetch(url)
    except asyncio.TimeoutError as e:
        raise asyncio.TimeoutError(
            f"Request to {url} timed out after {timeout}s"
        ) from e

# Caller handles timeout explicitly:
try:
    data = await fetch_with_timeout(url, timeout=5.0)
except asyncio.TimeoutError:
    logger.error("Timeout - will retry")
    raise
```

### Pydantic Strict Mode for Validation

```python
from pydantic import BaseModel, Field, ValidationError

# ❌ WRONG: Pydantic coerces types by default
class UserCreate(BaseModel):
    """Default Pydantic coerces types - hides bugs."""
    email: str
    age: int

# Silent type coercion hides bugs:
user = UserCreate(email="user@example.com", age="25")  # String "25" coerced to int!
print(user.age)  # 25 (int) - looks correct but input was wrong type

# ✅ CORRECT: Strict mode prevents coercion
class UserCreateStrict(BaseModel):
    """Strict validation - no type coercion, fail fast."""
    email: str = Field(..., strict=True)
    age: int = Field(..., strict=True, ge=0, le=150)

# Fails fast on invalid types:
try:
    user = UserCreateStrict(email="user@example.com", age="25")  # String age
except ValidationError as e:
    # Raises immediately: age must be int, not str
    print(e)  # Input should be a valid integer [type=int_type, ...]

# ✅ Works only with correct types
user = UserCreateStrict(email="user@example.com", age=25)  # ✅ Correct

# ✅ Validates constraints immediately
try:
    user = UserCreateStrict(email="user@example.com", age=200)  # Out of range
except ValidationError as e:
    # Raises: age must be <= 150
    print(e)

# ✅ Enable strict mode globally
class StrictBase(BaseModel):
    """Base class with strict validation."""
    model_config = {"strict": True}

class User(StrictBase):
    """Inherits strict validation."""
    email: str = Field(..., pattern=r".+@.+\..+")
    age: int = Field(..., ge=0, le=150)
    name: str = Field(..., min_length=1, max_length=100)

# All fields validated strictly - no coercion:
try:
    User(email="invalid", age=30, name="Alice")  # Invalid email
except ValidationError as e:
    print(e)  # String should match pattern '.+@.+\..+'
```

**Why strict mode**: Default Pydantic coerces `"123"` to `123`, `"true"` to `True`. Strict mode fails fast on type mismatches, catching bugs at validation time instead of hiding them.

## Type Checker Configuration for Fail-Fast

**pyproject.toml** (strict settings):
```toml
[tool.mypy]
python_version = "3.14"
strict = true
warn_return_any = true
warn_unused_ignores = true
warn_unreachable = true
warn_no_return = true
disallow_untyped_defs = true
disallow_any_generics = true
no_implicit_optional = true
strict_optional = true
warn_redundant_casts = true

# Fail on missing imports
ignore_missing_imports = false
```

**pyrightconfig.json** (strict settings):
```json
{
  "typeCheckingMode": "strict",
  "pythonVersion": "3.14",
  "reportMissingTypeStubs": true,
  "reportUnknownParameterType": "error",
  "reportUnknownArgumentType": "error",
  "reportUnknownMemberType": "error",
  "reportOptionalMemberAccess": "error"
}
```

## Fail-Fast Checklist for Code Review

✅ **Input Validation**:
- [ ] All external inputs validated immediately at boundary
- [ ] Invalid inputs raise exceptions (never return None/defaults)
- [ ] Validation errors have clear messages

✅ **Error Handling**:
- [ ] Never return None on errors - raise exceptions
- [ ] Specific exception types (not generic Exception)
- [ ] Exception messages include context (values, reasons)
- [ ] No silent `try/except: pass`

✅ **Type Safety**:
- [ ] All functions have type hints
- [ ] TypedDict used for dict structures
- [ ] Literal types for fixed values
- [ ] Protocol types for interfaces

✅ **No Defensive Programming**:
- [ ] No defensive defaults (empty strings, 0, empty lists)
- [ ] No mutable default arguments
- [ ] No lenient validation ("accept anything")
- [ ] No silent error swallowing

✅ **Fail-Fast Principles**:
- [ ] Validate early (at function entry, at construction)
- [ ] Fail loudly (raise, don't return error codes)
- [ ] Fail immediately (don't propagate invalid state)
- [ ] Fail with context (helpful error messages)

## Summary: Type Safety + Fail-Fast

**Type hints catch bugs at development time. Fail-fast catches bugs at runtime - as early as possible.**

1. **Validate at boundaries** - Check external input immediately
2. **Raise, don't return None** - Errors are exceptional, treat them that way
3. **No defensive defaults** - Hiding errors with defaults makes debugging hard
4. **Strict type checking** - Configure mypy/pyright for maximum strictness
5. **Specific exceptions** - Generic errors lose information
6. **Validate in constructors** - Never allow invalid objects to exist
7. **No silent failures** - Every error should be visible

**Remember**: A crash during development is better than silent corruption in production. Fail early, fail loudly, fail with context.
