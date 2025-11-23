# Pytest Patterns and Best Practices (2025)

Comprehensive guide to pytest patterns including fixtures, parametrization, markers, configuration, and advanced patterns for Python testing.

## Agent Quick Reference: Pytest Patterns

**When to Use Each Pattern**:
```
Need test data/setup? → Use FIXTURE
Testing multiple inputs? → Use PARAMETRIZE
Categorizing tests? → Use MARKERS
Complex setup/teardown? → Use FIXTURE with yield
Same data across class? → Use CLASS-SCOPED FIXTURE
Expensive setup (DB, etc)? → Use MODULE/SESSION-SCOPED FIXTURE
```

**Agent Fixture Selection Guide**:
| Scenario | Pattern | Example |
|----------|---------|---------|
| Simple test data | Function fixture | `@pytest.fixture def user_data(): return {...}` |
| Database connection | Module fixture + yield | `@pytest.fixture(scope="module")` |
| Multiple test cases | Parametrize | `@pytest.mark.parametrize("input,expected", [...])` |
| Test categorization | Markers | `@pytest.mark.unit`, `@pytest.mark.integration` |
| Multiple instances | Factory fixture | Return a function that creates objects |

**Common Agent Commands**:
```bash
# Run tests with markers
uv run pytest -m unit           # Unit tests only
uv run pytest -m "not slow"     # Exclude slow tests
uv run pytest -m "unit and fast" # Combine markers

# Run with fixtures
uv run pytest --fixtures        # List all available fixtures
uv run pytest -v                # Verbose output shows fixture usage

# Run parametrized tests
uv run pytest -k "test_name"    # Run specific parametrized test
```

## Fixtures

### What are Fixtures?

Fixtures provide a fixed baseline for tests to run reliably and repeatedly. They handle setup/teardown, dependency injection, and test isolation.

**Benefits**:
- Explicit dependencies (better than setUp/tearDown)
- Modular and composable
- Scalable across test suites
- Automatic cleanup with yield

### Basic Fixture Pattern

```python
import pytest

@pytest.fixture
def user_data():
    """Provide test user data."""
    return {
        "name": "Alice",
        "email": "alice@example.com",
        "age": 30
    }

def test_user_creation(user_data):
    """Test user creation with fixture data."""
    user = User(**user_data)
    assert user.name == "Alice"
    assert user.email == "alice@example.com"
```

### Fixture Scopes

Pytest offers five fixture scopes: **function**, **class**, **module**, **package**, and **session**.

```python
# Function scope (default) - runs once per test function
@pytest.fixture
def db_connection():
    """Create fresh DB connection for each test."""
    conn = create_connection()
    yield conn
    conn.close()

# Class scope - runs once per test class
@pytest.fixture(scope="class")
def api_client():
    """Create API client once per test class."""
    client = APIClient()
    yield client
    client.cleanup()

# Module scope - runs once per test module
@pytest.fixture(scope="module")
def database():
    """Setup database once per module."""
    db = Database()
    db.create_schema()
    yield db
    db.drop_schema()

# Session scope - runs once per test session
@pytest.fixture(scope="session")
def docker_services():
    """Start Docker services once for entire session."""
    compose = DockerCompose()
    compose.up()
    yield compose
    compose.down()
```

### Fixture Scope Best Practices

**Scope Selection Guidelines** (2025):
- Use **function** scope (default) for test isolation
- Use **class** scope for test classes with shared setup
- Use **module** scope for expensive setup (databases, services)
- Use **session** scope sparingly (containers, global resources)

**Rules**:
- ✅ Fixtures can use broader-scoped fixtures
- ❌ Broader-scoped fixtures cannot use narrower-scoped fixtures
- ✅ Favor narrower scopes when possible
- ❌ Avoid session scope with mutable state

### Fixture with Setup/Teardown (yield)

```python
@pytest.fixture
def temp_file():
    """Create temporary file, clean up after test."""
    # Setup
    file_path = "/tmp/test_data.txt"
    with open(file_path, "w") as f:
        f.write("test data")

    # Provide to test
    yield file_path

    # Teardown
    if os.path.exists(file_path):
        os.remove(file_path)

def test_file_reading(temp_file):
    """Test reading from temporary file."""
    with open(temp_file) as f:
        content = f.read()
    assert content == "test data"
```

### Autouse Fixtures

Autouse fixtures run automatically for all tests in scope:

```python
@pytest.fixture(autouse=True)
def reset_database():
    """Reset database before each test."""
    database.clear()
    yield
    # Optional teardown

@pytest.fixture(autouse=True, scope="session")
def configure_logging():
    """Configure logging once for entire session."""
    logging.basicConfig(level=logging.DEBUG)
```

**When to use autouse**:
- ✅ Global setup required for all tests
- ✅ Database/state reset between tests
- ✅ Logging configuration

**When NOT to use autouse**:
- ❌ Test-specific setup (use explicit fixtures)
- ❌ Complex dependencies (makes tests unclear)
- ❌ Most cases (explicit is better than implicit)

**Best Practice**: Use autouse sparingly. Explicit fixture injection is clearer and easier to debug.

### Fixture Factories

Create fixtures that return factory functions for flexible test data:

```python
@pytest.fixture
def user_factory(db_session):
    """Factory for creating test users."""
    created_users = []

    def create_user(**kwargs):
        defaults = {
            "name": "Test User",
            "email": f"user{len(created_users)}@test.com",
            "active": True
        }
        user = User(**{**defaults, **kwargs})
        db_session.add(user)
        db_session.commit()
        created_users.append(user)
        return user

    yield create_user

    # Cleanup all created users
    for user in created_users:
        db_session.delete(user)
    db_session.commit()

def test_user_relationships(user_factory):
    """Test user relationships with factory."""
    admin = user_factory(name="Admin", role="admin")
    user1 = user_factory(name="User1", role="user")
    user2 = user_factory(name="User2", role="user")

    assert admin.role == "admin"
    assert len([u for u in [user1, user2] if u.role == "user"]) == 2
```

### Fixture Composition

Fixtures can use other fixtures:

```python
@pytest.fixture
def database():
    """Provide database connection."""
    db = Database()
    yield db
    db.close()

@pytest.fixture
def user_repository(database):
    """Provide user repository with database."""
    return UserRepository(database)

@pytest.fixture
def authenticated_user(user_repository):
    """Create and return authenticated user."""
    user = user_repository.create({
        "name": "Test",
        "email": "test@example.com"
    })
    user.authenticate()
    yield user
    user_repository.delete(user.id)

def test_user_permissions(authenticated_user):
    """Test with fully setup authenticated user."""
    assert authenticated_user.is_authenticated
    assert authenticated_user.can_access("/dashboard")
```

## Parametrization

### Basic Parametrization

Test the same logic with different inputs:

```python
import pytest

@pytest.mark.parametrize("input,expected", [
    (2, 4),
    (3, 9),
    (4, 16),
    (5, 25),
])
def test_square(input, expected):
    """Test square function with multiple inputs."""
    assert square(input) == expected
```

### Multiple Parameters

```python
@pytest.mark.parametrize("x,y,expected", [
    (1, 1, 2),
    (2, 3, 5),
    (10, 5, 15),
    (-1, 1, 0),
    (0, 0, 0),
])
def test_addition(x, y, expected):
    """Test addition with various inputs."""
    assert add(x, y) == expected
```

### Named Test IDs

Make test output more readable:

```python
@pytest.mark.parametrize("email,valid", [
    ("user@example.com", True),
    ("invalid", False),
    ("@example.com", False),
    ("user@", False),
], ids=["valid", "no_at", "no_local", "no_domain"])
def test_email_validation(email, valid):
    """Test email validation."""
    assert validate_email(email) == valid
```

### Indirect Parametrization

Pass parameters through fixtures for complex setup:

```python
@pytest.fixture
def user(request):
    """Create user based on request parameter."""
    role = request.param
    return User(name=f"{role}_user", role=role)

@pytest.mark.parametrize("user", ["admin", "user", "guest"], indirect=True)
def test_user_permissions(user):
    """Test permissions for different user roles."""
    if user.role == "admin":
        assert user.can_delete()
    elif user.role == "user":
        assert user.can_edit()
    else:
        assert user.can_read()
```

### Partial Indirect Parametrization

Apply indirect to specific parameters only:

```python
@pytest.fixture
def database(request):
    """Setup database based on parameter."""
    db_type = request.param
    return Database(type=db_type)

@pytest.mark.parametrize(
    "database,table_name",
    [("postgres", "users"), ("mysql", "customers")],
    indirect=["database"]  # Only database is indirect
)
def test_table_operations(database, table_name):
    """Test operations on different databases."""
    table = database.get_table(table_name)
    assert table is not None
```

### Combining Parametrization

```python
@pytest.mark.parametrize("x", [1, 2, 3])
@pytest.mark.parametrize("y", [4, 5, 6])
def test_multiplication(x, y):
    """Test all combinations of x and y (9 tests total)."""
    result = x * y
    assert result == x * y
    assert result > 0
```

## Markers

### Built-in Markers

```python
# Skip test
@pytest.mark.skip(reason="Not implemented yet")
def test_feature():
    pass

# Skip if condition
@pytest.mark.skipif(sys.platform == "win32", reason="Unix only")
def test_unix_feature():
    pass

# Expected to fail
@pytest.mark.xfail(reason="Known bug #123")
def test_buggy_feature():
    pass

# Expected to fail with condition
@pytest.mark.xfail(sys.version_info < (3, 10), reason="Requires Python 3.10+")
def test_new_syntax():
    pass
```

### Custom Markers

Define and use custom markers for test categorization:

```python
# pytest.ini or pyproject.toml
[pytest]
markers =
    unit: Unit tests (fast, isolated)
    integration: Integration tests
    slow: Slow tests (>1s execution)
    fast: Fast tests (<100ms)
    asyncio: Async tests
    smoke: Smoke tests for deployment
    regression: Regression tests for fixed bugs

# Usage in tests
@pytest.mark.unit
@pytest.mark.fast
def test_calculation():
    """Fast unit test."""
    assert add(2, 2) == 4

@pytest.mark.integration
@pytest.mark.slow
async def test_database_query():
    """Slow integration test."""
    result = await db.query("SELECT * FROM users")
    assert len(result) > 0

@pytest.mark.smoke
def test_api_health():
    """Smoke test for API health."""
    response = requests.get("/health")
    assert response.status_code == 200
```

### Running Tests by Marker

```bash
# Run only unit tests
pytest -m unit

# Run all except slow tests
pytest -m "not slow"

# Run fast unit tests
pytest -m "fast and unit"

# Run integration or e2e tests
pytest -m "integration or e2e"

# Run async tests
pytest -m asyncio
```

## Configuration

### pytest.ini

```ini
[pytest]
minversion = 8.0
testpaths = tests
python_files = test_*.py *_test.py
python_classes = Test* *Tests
python_functions = test_*

addopts =
    -v
    --strict-markers
    --strict-config
    --tb=short
    --cov=src
    --cov-report=term-missing
    --cov-report=html
    --cov-fail-under=80

markers =
    unit: Unit tests
    integration: Integration tests
    slow: Slow tests
    fast: Fast tests
    asyncio: Async tests
    smoke: Smoke tests

# pytest-asyncio configuration
asyncio_mode = auto
asyncio_default_fixture_loop_scope = function

# Timeout configuration
timeout = 300
timeout_method = thread
```

### pyproject.toml

```toml
[tool.pytest.ini_options]
minversion = "8.0"
testpaths = ["tests"]
python_files = ["test_*.py", "*_test.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]

addopts = [
    "-v",
    "--strict-markers",
    "--cov=src",
    "--cov-report=term-missing",
]

markers = [
    "unit: Unit tests (fast, isolated)",
    "integration: Integration tests",
    "slow: Slow tests (>1s)",
    "fast: Fast tests (<100ms)",
]

# pytest-asyncio
asyncio_mode = "auto"

# Coverage
[tool.coverage.run]
source = ["src"]
omit = ["*/tests/*", "*/test_*.py"]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "def __repr__",
    "raise AssertionError",
    "raise NotImplementedError",
    "if __name__ == .__main__.:",
]
```

## conftest.py

### Purpose

`conftest.py` provides shared fixtures and configuration for test directories:

```
tests/
├── conftest.py          # Shared fixtures for all tests
├── unit/
│   ├── conftest.py      # Fixtures for unit tests
│   └── test_models.py
└── integration/
    ├── conftest.py      # Fixtures for integration tests
    └── test_api.py
```

### Example conftest.py

```python
# tests/conftest.py

import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

@pytest.fixture(scope="session")
def database_engine():
    """Create database engine for test session."""
    engine = create_engine("sqlite:///:memory:")
    Base.metadata.create_all(engine)
    yield engine
    engine.dispose()

@pytest.fixture(scope="function")
def db_session(database_engine):
    """Provide database session for each test."""
    Session = sessionmaker(bind=database_engine)
    session = Session()
    yield session
    session.rollback()
    session.close()

@pytest.fixture
def client():
    """Provide test client."""
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

# Plugin hooks
def pytest_configure(config):
    """Configure pytest plugins."""
    config.addinivalue_line(
        "markers", "smoke: Smoke tests for deployment"
    )

def pytest_collection_modifyitems(config, items):
    """Modify test collection."""
    # Add slow marker to tests that take >1s
    for item in items:
        if "slow" not in item.keywords:
            # Auto-mark integration tests as slow
            if "integration" in item.keywords:
                item.add_marker(pytest.mark.slow)
```

## Advanced Patterns

### Fixture Parametrization

```python
@pytest.fixture(params=["postgres", "mysql", "sqlite"])
def database(request):
    """Parametrized database fixture."""
    db_type = request.param
    db = create_database(db_type)
    yield db
    db.close()

def test_query(database):
    """Test runs three times with different databases."""
    result = database.query("SELECT 1")
    assert result is not None
```

### Dynamic Fixture Generation

```python
def pytest_generate_tests(metafunc):
    """Dynamically generate test parameters."""
    if "browser" in metafunc.fixturenames:
        metafunc.parametrize(
            "browser",
            ["chrome", "firefox", "safari"],
            indirect=True
        )

@pytest.fixture
def browser(request):
    """Create browser based on parameter."""
    browser_type = request.param
    driver = create_driver(browser_type)
    yield driver
    driver.quit()

def test_website(browser):
    """Test runs on all browsers."""
    browser.get("https://example.com")
    assert "Example" in browser.title
```

### Context Manager Fixtures

```python
from contextlib import contextmanager

@pytest.fixture
def transaction():
    """Provide database transaction context."""
    @contextmanager
    def _transaction():
        conn = db.connect()
        trans = conn.begin()
        try:
            yield conn
            trans.commit()
        except:
            trans.rollback()
            raise
        finally:
            conn.close()

    return _transaction

def test_with_transaction(transaction):
    """Test with transaction context."""
    with transaction() as conn:
        conn.execute("INSERT INTO users ...")
        users = conn.execute("SELECT * FROM users")
        assert len(list(users)) > 0
```

## Common Patterns

### AAA Pattern (Arrange-Act-Assert)

```python
def test_user_creation():
    """Test user creation."""
    # Arrange - Setup test data
    user_data = {
        "name": "Alice",
        "email": "alice@example.com"
    }

    # Act - Perform action
    user = User.create(user_data)

    # Assert - Verify results
    assert user.id is not None
    assert user.name == "Alice"
    assert user.email == "alice@example.com"
```

### Monkeypatch

```python
def test_with_environment_variable(monkeypatch):
    """Test with mocked environment variable."""
    monkeypatch.setenv("API_KEY", "test-key-123")
    assert os.getenv("API_KEY") == "test-key-123"

def test_with_mock_function(monkeypatch):
    """Test with mocked function."""
    def mock_get_user(user_id):
        return {"id": user_id, "name": "Mock User"}

    monkeypatch.setattr("myapp.services.get_user", mock_get_user)
    user = get_user(123)
    assert user["name"] == "Mock User"
```

### tmp_path Fixture

```python
def test_file_operations(tmp_path):
    """Test with temporary directory."""
    # Create test file
    test_file = tmp_path / "test.txt"
    test_file.write_text("test content")

    # Test file reading
    content = test_file.read_text()
    assert content == "test content"

    # tmp_path is automatically cleaned up
```

### capsys for Output Capture

```python
def test_print_output(capsys):
    """Test function that prints output."""
    print("Hello, World!")
    print("Testing output")

    captured = capsys.readouterr()
    assert "Hello, World!" in captured.out
    assert "Testing output" in captured.out
```

## Best Practices Summary

### Fixture Best Practices
- ✅ Use explicit fixture injection over autouse
- ✅ Prefer narrower scopes (function > class > module > session)
- ✅ Use yield for cleanup
- ✅ Compose fixtures for complex setup
- ✅ Use fixture factories for flexible test data
- ❌ Don't use mutable objects in session-scoped fixtures
- ❌ Don't create circular fixture dependencies

### Parametrization Best Practices
- ✅ Use descriptive test IDs
- ✅ Group related parameters together
- ✅ Use indirect for complex setup
- ✅ Keep parametrized tests simple
- ❌ Don't parametrize unrelated test cases
- ❌ Don't create too many parameter combinations

### Marker Best Practices
- ✅ Define all markers in configuration
- ✅ Use markers for test categorization
- ✅ Combine markers for filtering
- ✅ Document marker purposes
- ❌ Don't overuse markers
- ❌ Don't create overlapping marker categories

## Agent Implementation Checklist

When implementing pytest patterns, verify:

**Fixture Usage**:
- [ ] Fixtures use appropriate scope (function/class/module/session)
- [ ] Fixtures with cleanup use yield pattern
- [ ] No circular fixture dependencies
- [ ] Fixture names are descriptive
- [ ] Autouse fixtures used sparingly (only for global setup)

**Parametrization**:
- [ ] Test IDs are descriptive
- [ ] All parameter combinations are valid
- [ ] Parametrized tests are independent
- [ ] Use indirect=True for complex fixture parametrization

**Markers**:
- [ ] All markers defined in pytest.ini or pyproject.toml
- [ ] Markers applied consistently
- [ ] Test categorization is logical (unit/integration/e2e)
- [ ] Performance markers applied (fast/slow)

**Configuration**:
- [ ] pytest.ini or pyproject.toml exists
- [ ] Minimum pytest version specified
- [ ] Test paths configured
- [ ] Markers documented in configuration

## Agent Common Anti-Patterns

**❌ DON'T: Overuse autouse fixtures**
```python
# BAD - Autouse makes tests unclear
@pytest.fixture(autouse=True)
def setup_everything():
    # Hidden setup that all tests depend on
```

**✅ DO: Use explicit fixture injection**
```python
# GOOD - Clear what each test needs
def test_user(user_fixture):
    assert user_fixture.name == "Test"
```

**❌ DON'T: Create session fixtures with mutable state**
```python
# BAD - State shared across all tests
@pytest.fixture(scope="session")
def shared_list():
    return []  # Mutable, will accumulate data
```

**✅ DO: Use function scope for mutable data**
```python
# GOOD - Fresh data for each test
@pytest.fixture
def fresh_list():
    return []
```

## Resources

For external documentation and references, see [external-sources.md](external-sources.md).
