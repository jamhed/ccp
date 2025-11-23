# Test Organization and CI/CD (2025)

Comprehensive guide to test strategy, organization, directory structure, markers, parallel execution, and CI/CD integration.

## Agent Guidance: Test Type Selection

**Quick Decision Tree**:
- **Pure function/calculation** → UNIT TEST
- **Database operation** → INTEGRATION TEST
- **API endpoint** → INTEGRATION TEST
- **External service call** → INTEGRATION TEST (mock) or E2E TEST (real)
- **Complete user workflow** → E2E TEST
- **Business logic with invariants** → UNIT TEST + PROPERTY-BASED TEST
- **Critical path after deployment** → SMOKE TEST

**Agent Instructions**:
1. **DEFAULT** to unit tests (70% of tests)
2. **ADD** integration tests for component boundaries (20% of tests)
3. **LIMIT** E2E tests to critical workflows only (10% of tests)
4. **WRITE** tests from bottom up: Unit → Integration → E2E
5. **NEVER** skip unit tests in favor of integration/E2E tests

## Testing Pyramid Strategy

### Test Distribution (70/20/10)

**Unit Tests (70%)**:
- Fast execution (<1ms each)
- Test individual functions/classes in isolation
- Cheapest to maintain
- Most reliable and deterministic
- Best for TDD workflow

**Integration Tests (20%)**:
- Medium speed (10ms-1s per test)
- Test component interactions and contracts
- Use real dependencies (DB, services)
- Moderate maintenance cost

**End-to-End Tests (10%)**:
- Slowest execution (seconds to minutes)
- Test complete user workflows
- Most expensive to maintain
- Most brittle (depend on full system)
- Highest value for critical paths

**Context-Specific Adjustments**:
- Microservices: May need more integration tests (60/30/10)
- UI-heavy apps: May need more E2E tests (60/25/15)
- APIs/libraries: Can focus more on unit tests (80/15/5)

### Test Type Characteristics

| Test Type | Speed | Marker | Scope | When to Use |
|-----------|-------|--------|-------|-------------|
| **Unit** | <1ms | `@pytest.mark.unit` | Single function | Pure logic, calculations |
| **Integration** | <1s | `@pytest.mark.integration` | Component interaction | DB, API, services |
| **E2E** | >1s | `@pytest.mark.e2e` | Full system | Critical user flows |
| **Property-Based** | Varies | `@pytest.mark.property` | Invariants | Complex logic, parsers |
| **Smoke** | Fast | `@pytest.mark.smoke` | Critical paths | Deployment verification |
| **Regression** | Varies | `@pytest.mark.regression` | Bug prevention | After bug fixes |

### Test Coverage Goals

**By Test Type**:
- Unit tests: >80% code coverage
- Integration tests: All major components
- E2E tests: All critical user paths

**By Code Area**:
- Business logic: >90% coverage
- API endpoints: 100% coverage
- Utilities: >80% coverage
- UI components: 60-70% coverage

**Don't chase 100%** - Focus on meaningful tests, not metrics.

## Directory Structure

### Recommended Structure

```
project/
├── src/
│   └── myapp/
│       ├── __init__.py
│       ├── models.py
│       ├── services.py
│       └── utils.py
├── tests/
│   ├── conftest.py          # Shared fixtures
│   ├── __init__.py
│   ├── unit/
│   │   ├── conftest.py      # Unit test fixtures
│   │   ├── test_models.py
│   │   ├── test_services.py
│   │   └── test_utils.py
│   ├── integration/
│   │   ├── conftest.py      # Integration test fixtures
│   │   ├── test_api.py
│   │   ├── test_database.py
│   │   └── test_external_services.py
│   └── e2e/
│       ├── conftest.py      # E2E test fixtures
│       └── test_user_workflows.py
├── pytest.ini
└── pyproject.toml
```

### Flat Structure (Simple Projects)

```
project/
├── myapp/
│   ├── __init__.py
│   └── module.py
└── tests/
    ├── conftest.py
    ├── test_module.py
    └── test_integration.py
```

### Feature-Based Structure

```
project/
├── src/myapp/
│   ├── users/
│   │   ├── models.py
│   │   ├── services.py
│   │   └── tests/
│   │       ├── test_user_model.py
│   │       └── test_user_service.py
│   └── orders/
│       ├── models.py
│       ├── services.py
│       └── tests/
│           ├── test_order_model.py
│           └── test_order_service.py
└── tests/
    └── integration/
        └── test_user_orders.py
```

## Testing Tools Setup

### pytest-asyncio Setup

pytest-asyncio enables testing of asynchronous Python code with pytest.

#### Installation

```bash
# Install pytest-asyncio (supports Python 3.10-3.14)
uv add --dev pytest-asyncio==1.3.0
```

#### Configuration

```ini
# pytest.ini
[pytest]
asyncio_mode = auto
asyncio_default_fixture_loop_scope = function
```

```toml
# pyproject.toml
[tool.pytest.ini_options]
asyncio_mode = "auto"
asyncio_default_fixture_loop_scope = "function"
```

**asyncio_mode options**:
- `auto`: Automatically detect and run async tests
- `strict`: Only run tests marked with `@pytest.mark.asyncio`

### pytest-xdist Setup

pytest-xdist enables parallel test execution for faster test runs.

```bash
# Install pytest-xdist
uv add --dev pytest-xdist
```

See the [Parallel Execution](#parallel-execution) section for usage details.

## Test Markers

### Defining Markers

```ini
# pytest.ini
[pytest]
markers =
    unit: Unit tests (fast, isolated, no external dependencies)
    integration: Integration tests (database, external services)
    e2e: End-to-end tests (full system workflows)
    property: Property-based tests (hypothesis)
    slow: Slow tests (>1s execution time)
    fast: Fast tests (<100ms execution time)
    smoke: Smoke tests for deployment verification
    regression: Regression tests for fixed bugs
    asyncio: Async tests requiring pytest-asyncio
    skip_ci: Skip in CI environment
    requires_gpu: Requires GPU hardware
```

### Using Markers

```python
import pytest

@pytest.mark.unit
@pytest.mark.fast
def test_calculation():
    """Fast unit test."""
    assert add(2, 2) == 4

@pytest.mark.integration
@pytest.mark.slow
async def test_database():
    """Slow integration test with database."""
    users = await db.query("SELECT * FROM users")
    assert len(users) > 0

@pytest.mark.e2e
@pytest.mark.smoke
def test_user_login_flow():
    """E2E smoke test for critical path."""
    response = client.post("/login", json={
        "email": "user@example.com",
        "password": "password"
    })
    assert response.status_code == 200

@pytest.mark.regression
@pytest.mark.bug_1234
def test_negative_quantity_bug():
    """Regression test for bug #1234."""
    with pytest.raises(ValueError):
        cart.add_item(product, quantity=-1)

@pytest.mark.skipif(not HAS_GPU, reason="Requires GPU")
def test_gpu_processing():
    """Test that requires GPU."""
    result = process_on_gpu(data)
    assert result is not None
```

### Running Tests by Marker

```bash
# Run only unit tests
uv run pytest -m unit

# Run all except slow tests
uv run pytest -m "not slow"

# Run fast unit tests
uv run pytest -m "fast and unit"

# Run integration or e2e tests
uv run pytest -m "integration or e2e"

# Run smoke tests only
uv run pytest -m smoke

# Run async tests
uv run pytest -m asyncio

# Combine multiple conditions
uv run pytest -m "unit and not slow"
```

## Test Type Examples

### Unit Test Example

```python
@pytest.mark.unit
@pytest.mark.fast
def test_calculate_discount():
    """Test discount calculation logic."""
    # Arrange
    price = 100.00
    discount_percent = 20

    # Act
    result = calculate_discount(price, discount_percent)

    # Assert
    assert result == 20.00

@pytest.mark.unit
def test_calculate_discount_invalid_percent():
    """Test discount validation."""
    with pytest.raises(ValueError, match="Discount must be 0-100"):
        calculate_discount(100.00, discount_percent=150)
```

**When to use**:
- Testing pure functions
- Business logic validation
- Data transformations
- Algorithms and calculations
- Utility functions

### Integration Test Example

```python
@pytest.mark.integration
async def test_user_repository_crud(db_session):
    """Test user repository CRUD operations."""
    # Arrange
    repo = UserRepository(db_session)
    user_data = {"name": "Alice", "email": "alice@example.com"}

    # Act - Create
    user = await repo.create(user_data)
    assert user.id is not None

    # Act - Read
    fetched = await repo.get_by_id(user.id)
    assert fetched.name == "Alice"

    # Act - Update
    await repo.update(user.id, {"name": "Alice Smith"})
    updated = await repo.get_by_id(user.id)
    assert updated.name == "Alice Smith"

    # Act - Delete
    await repo.delete(user.id)
    deleted = await repo.get_by_id(user.id)
    assert deleted is None
```

**When to use**:
- Testing database operations
- Testing API clients
- Testing service interactions
- Testing message queue handlers
- Testing authentication/authorization

### E2E Test Example

```python
@pytest.mark.e2e
@pytest.mark.slow
async def test_complete_checkout_flow(browser, test_user):
    """Test complete user checkout workflow."""
    # Given - User is logged in
    await browser.goto("/login")
    await browser.fill("#email", test_user.email)
    await browser.fill("#password", "password123")
    await browser.click("#login-button")

    # When - User adds items to cart
    await browser.goto("/products")
    await browser.click("[data-product-id='123'] .add-to-cart")

    # And - Proceeds to checkout
    await browser.goto("/cart")
    await browser.click("#checkout-button")

    # And - Completes payment
    await browser.fill("#card-number", "4242424242424242")
    await browser.click("#pay-button")

    # Then - Order is confirmed
    await browser.wait_for_selector(".order-confirmation")
    confirmation = await browser.text_content(".order-number")
    assert confirmation.startswith("ORDER-")
```

**When to use**:
- Critical user workflows
- Checkout/payment flows
- User registration/login
- Data import/export
- Deployment smoke tests

### Property-Based Test Example

```python
from hypothesis import given, strategies as st

@pytest.mark.property
@given(
    items=st.lists(
        st.tuples(
            st.floats(min_value=0.01, max_value=1000.00),
            st.integers(min_value=1, max_value=100)
        ),
        min_size=1,
        max_size=50
    )
)
def test_cart_total_is_sum_of_items(items):
    """Property: Cart total always equals sum of (price * quantity)."""
    cart = ShoppingCart()
    expected_total = 0

    for price, quantity in items:
        product = Product("Test", price)
        cart.add_item(product, quantity)
        expected_total += price * quantity

    assert abs(cart.total_price() - expected_total) < 0.01
```

**When to use**:
- Complex business logic
- Parsers and serializers
- Mathematical operations
- Data validation
- Algorithms with invariants

### Regression Test Example

```python
@pytest.mark.regression
@pytest.mark.bug_123
def test_negative_quantity_validation():
    """Regression: Bug #123 - Negative quantities caused data corruption."""
    cart = ShoppingCart()
    product = Product("Test", 10.00)

    with pytest.raises(ValueError, match="Quantity must be positive"):
        cart.add_item(product, quantity=-5)
```

## Agent Test Templates

### Unit Test Template

```python
@pytest.mark.unit
@pytest.mark.fast
def test_<function>_<scenario>():
    """Test <function> <does what> when <scenario>."""
    # Arrange
    input_data = <test_data>

    # Act
    result = function_under_test(input_data)

    # Assert
    assert result == expected_value
```

### Integration Test Template

```python
@pytest.mark.integration
async def test_<component>_<interaction>(db_session):
    """Test <component> <interacts with> <other_component>."""
    # Arrange
    repo = Repository(db_session)

    # Act
    result = await repo.operation(data)

    # Assert
    assert result is not None
    # Verify database state
```

### E2E Test Template

```python
@pytest.mark.e2e
@pytest.mark.slow
async def test_<user_workflow>(browser):
    """Test complete <workflow> from start to finish."""
    # Given - Setup initial state
    await setup_user_state(browser)

    # When - Perform user actions
    await perform_workflow(browser)

    # Then - Verify end state
    assert await verify_final_state(browser)
```

## Parallel Execution

### Running Tests in Parallel

```bash
# Auto-detect CPU cores
uv run pytest -n auto

# Specific number of workers
uv run pytest -n 4

# Run unit tests in parallel
uv run pytest -m unit -n auto

# Parallel with coverage
uv run pytest -n auto --cov=src --cov-report=term-missing
```

### Parallel Execution Strategies

```bash
# Load balance (default) - distribute by execution time
uv run pytest -n auto --dist=load

# Load scope - group by class/module
uv run pytest -n auto --dist=loadscope

# Load file - group by file
uv run pytest -n auto --dist=loadfile

# Load group - use custom groups
uv run pytest -n auto --dist=loadgroup
```

### Marker for Sequential Tests

```python
# tests/integration/test_database.py

import pytest

@pytest.mark.no_parallel
def test_database_migration():
    """Must run sequentially - modifies shared database."""
    run_migration()
    assert db.schema_version() == 5
```

## Test Discovery

### pytest Discovery Rules

pytest discovers tests by:
1. Files matching `test_*.py` or `*_test.py`
2. Classes matching `Test*`
3. Functions matching `test_*`

### Custom Discovery

```ini
# pytest.ini
[pytest]
python_files = test_*.py *_test.py check_*.py
python_classes = Test* *Tests *TestCase
python_functions = test_* check_*
```

### Excluding Directories

```ini
# pytest.ini
[pytest]
testpaths = tests
norecursedirs = .git .tox dist build *.egg venv
```

## Naming Conventions

### Test File Names

```
✅ Good:
- test_user_service.py
- test_api_endpoints.py
- test_database_queries.py

❌ Bad:
- tests.py (too generic)
- user_test.py (doesn't start with test_)
- TestUserService.py (PascalCase, should be snake_case)
```

### Test Function Names

```python
# ✅ Good - Descriptive and clear
def test_user_creation_with_valid_email():
    pass

def test_password_validation_rejects_short_passwords():
    pass

def test_api_returns_404_for_missing_resource():
    pass

# ❌ Bad - Too vague
def test_user():
    pass

def test_1():
    pass

def test_password():
    pass
```

### Test Class Names

```python
# ✅ Good
class TestUserAuthentication:
    def test_login_with_valid_credentials(self):
        pass

    def test_login_with_invalid_password(self):
        pass

class TestShoppingCart:
    def test_add_item(self):
        pass

    def test_calculate_total(self):
        pass

# ❌ Bad
class Tests:  # Too generic
    pass

class UserTests:  # Doesn't start with Test
    pass
```

## CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ['3.10', '3.11', '3.12', '3.13', '3.14']

    steps:
    - uses: actions/checkout@v4

    - name: Install uv
      uses: astral-sh/setup-uv@v4

    - name: Set up Python ${{ matrix.python-version }}
      run: uv python install ${{ matrix.python-version }}

    - name: Install dependencies
      run: |
        uv sync --all-extras --dev

    - name: Run linters
      run: |
        uv run ruff check .
        uv run mypy src/

    - name: Run fast tests
      run: |
        uv run pytest -m "not slow" -n auto --cov=src --cov-report=xml

    - name: Run slow tests
      run: |
        uv run pytest -m slow -v

    - name: Upload coverage
      uses: codecov/codecov-action@v4
      with:
        file: ./coverage.xml
```

### GitLab CI

```yaml
# .gitlab-ci.yml
stages:
  - test
  - coverage

test:
  image: python:3.14
  stage: test
  before_script:
    - pip install uv
    - uv sync --all-extras --dev
  script:
    - uv run pytest -m "not slow" -n auto --junitxml=report.xml
  artifacts:
    reports:
      junit: report.xml

coverage:
  image: python:3.14
  stage: coverage
  script:
    - uv run pytest --cov=src --cov-report=term --cov-report=xml
  coverage: '/TOTAL.*\s+(\d+%)$/'
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage.xml
```

## Makefile Targets

### Development Workflow

```makefile
# Makefile

.PHONY: help install test lint format clean

help:
	@echo "Available targets:"
	@echo "  install     Install dependencies"
	@echo "  test        Run all tests"
	@echo "  test-unit   Run unit tests"
	@echo "  test-fast   Run fast tests"
	@echo "  lint        Run linters"
	@echo "  format      Format code"
	@echo "  coverage    Generate coverage report"
	@echo "  clean       Clean generated files"

install:
	uv sync --all-extras --dev

test:
	uv run pytest -v

test-unit:
	uv run pytest -m unit -n auto

test-integration:
	uv run pytest -m integration -v

test-fast:
	uv run pytest -m "not slow" -n auto

test-slow:
	uv run pytest -m slow -v

lint:
	uv run ruff check .
	uv run mypy src/
	uv run ruff format --check .

format:
	uv run ruff format .
	uv run ruff check --fix .

coverage:
	uv run pytest --cov=src --cov-report=html --cov-report=term-missing
	@echo "Open htmlcov/index.html to view coverage report"

dev: lint test-fast
	@echo "Development checks passed!"

ci: lint test coverage
	@echo "CI checks passed!"

clean:
	rm -rf .pytest_cache .coverage htmlcov .ruff_cache .mypy_cache
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name '*.pyc' -delete
```

### Usage

```bash
# Development cycle
make dev              # Lint + fast tests

# Full CI workflow
make ci               # Lint + all tests + coverage

# Specific test suites
make test-unit        # Unit tests only
make test-integration # Integration tests only
make test-fast        # Fast tests only
make test-slow        # Slow tests only

# Code quality
make lint             # Run all linters
make format           # Format code
make coverage         # Generate coverage report
```

## Test Reports

### JUnit XML Reports

```bash
# Generate JUnit XML for CI
uv run pytest --junitxml=report.xml

# With test durations
uv run pytest --junitxml=report.xml --durations=10
```

### HTML Reports

```bash
# Install pytest-html
uv add --dev pytest-html

# Generate HTML report
uv run pytest --html=report.html --self-contained-html
```

### Coverage Reports

```bash
# Terminal report
uv run pytest --cov=src --cov-report=term-missing

# HTML report
uv run pytest --cov=src --cov-report=html

# XML report (for CI)
uv run pytest --cov=src --cov-report=xml

# Multiple formats
uv run pytest --cov=src --cov-report=term-missing --cov-report=html --cov-report=xml
```

## Test Filtering

### By File/Directory

```bash
# Run tests in specific file
uv run pytest tests/unit/test_models.py

# Run tests in directory
uv run pytest tests/unit/

# Run specific test function
uv run pytest tests/unit/test_models.py::test_user_creation

# Run specific test class
uv run pytest tests/unit/test_models.py::TestUserModel

# Run specific method in class
uv run pytest tests/unit/test_models.py::TestUserModel::test_validation
```

### By Keyword

```bash
# Run tests matching keyword
uv run pytest -k "user"

# Exclude tests matching keyword
uv run pytest -k "not integration"

# Complex expressions
uv run pytest -k "user and not slow"
```

### By Marker

```bash
# Run tests with specific marker
uv run pytest -m integration

# Multiple markers
uv run pytest -m "integration or e2e"

# Exclude marker
uv run pytest -m "not slow"

# Complex expressions
uv run pytest -m "unit and fast and not skip_ci"
```

## Agent Implementation Checklist

When implementing tests for a feature, follow this checklist:

**Step 1: Identify What to Test**
- [ ] List all functions/methods in the feature
- [ ] Identify public API / external interfaces
- [ ] Note all error conditions
- [ ] List edge cases (empty, null, boundary values)

**Step 2: Write Unit Tests First (70%)**
- [ ] Test each function/method independently
- [ ] Test happy path
- [ ] Test error conditions
- [ ] Test edge cases
- [ ] Ensure all tests pass

**Step 3: Add Integration Tests (20%)**
- [ ] Test database interactions
- [ ] Test API endpoints
- [ ] Test service integrations
- [ ] Test authentication/authorization
- [ ] Ensure all tests pass

**Step 4: Add E2E Tests (10%)**
- [ ] Identify 2-3 critical user workflows
- [ ] Write E2E tests for critical paths only
- [ ] Test checkout flow (if applicable)
- [ ] Test registration/login (if applicable)
- [ ] Ensure all tests pass

**Step 5: Validate Coverage**
- [ ] Run coverage report: `uv run pytest --cov=src --cov-report=term-missing`
- [ ] Verify >80% coverage for critical code
- [ ] Identify and test uncovered critical paths
- [ ] Don't chase 100% - focus on meaningful coverage

## Best Practices

### Do's ✅

1. **Follow the testing pyramid**
   - 70% unit tests, 20% integration, 10% E2E
   - Test logic directly, not through HTTP
   - Write tests from bottom up

2. **Organize by test type**
   - Separate unit/, integration/, e2e/ directories
   - Use markers for categorization
   - Clear naming conventions

2. **Run tests in parallel**
   - Use `pytest -n auto` for speed
   - Mark sequential tests appropriately

3. **Use markers effectively**
   - Define all markers in configuration
   - Use markers for selective execution
   - Combine markers for filtering

4. **Integrate with CI/CD**
   - Run tests on every commit
   - Fast feedback (<5 min for unit tests)
   - Parallel execution in CI

5. **Generate reports**
   - Coverage reports for visibility
   - JUnit XML for CI integration
   - HTML reports for detailed analysis

### Don'ts ❌

1. **Don't mix test types**
   - Don't put unit and integration tests together
   - Don't put production code in test directories

2. **Don't skip test organization**
   - Don't have flat test directory for large projects
   - Don't use vague test names

3. **Don't run all tests always**
   - Don't run slow tests in development loop
   - Don't skip parallel execution

4. **Don't ignore CI/CD**
   - Don't skip CI configuration
   - Don't allow flaky tests in CI

5. **Don't skip unit tests**
   - Never skip unit tests in favor of E2E tests
   - Don't test business logic through HTTP endpoints
   - Don't write only integration/E2E tests

## Agent Anti-Patterns

### ❌ DON'T: Write only E2E tests

```python
# BAD - Everything is E2E
@pytest.mark.e2e
def test_everything():
    # 500 lines testing entire application
```

### ✅ DO: Follow the pyramid

```python
# GOOD - Unit test for logic
@pytest.mark.unit
def test_calculate_discount():
    assert calculate_discount(100, 20) == 20

# GOOD - Integration test for DB
@pytest.mark.integration
def test_save_order(db):
    order = save_order(db, {...})
    assert order.id is not None

# GOOD - E2E only for critical path
@pytest.mark.e2e
def test_checkout_flow(browser):
    # Test only the critical checkout workflow
```

### ❌ DON'T: Skip unit tests

```python
# BAD - No unit tests, only integration
@pytest.mark.integration
def test_business_logic_via_api(client):
    response = client.post("/calculate", json={...})
    # Testing business logic through HTTP is slow and brittle
```

### ✅ DO: Test logic directly

```python
# GOOD - Unit test for business logic
@pytest.mark.unit
def test_business_logic():
    result = calculate_business_logic(...)
    assert result == expected

# GOOD - Integration test for API
@pytest.mark.integration
def test_api_endpoint(client):
    response = client.post("/calculate", json={...})
    assert response.status_code == 200
```

## Summary

### Key Principles

1. **Follow the testing pyramid**: 70% unit, 20% integration, 10% E2E
2. **Test behavior, not implementation**: Focus on what, not how
3. **Organize by test type**: unit/, integration/, e2e/ directories
4. **Use markers**: Categorize and filter tests effectively
5. **Run in parallel**: Speed up test execution with pytest-xdist
6. **Keep tests fast**: Unit tests <1ms, integration <1s
7. **Integrate with CI/CD**: Automate testing on every commit
8. **Generate reports**: Track coverage and results
9. **Follow naming conventions**: Clear, descriptive names
10. **Focus on meaningful tests**: Coverage is a tool, not a goal

### Quick Commands

```bash
# Development
make dev                    # Lint + fast tests
uv run pytest -m unit -n auto

# CI
make ci                     # Full CI workflow
uv run pytest -n auto --cov=src

# Selective execution
uv run pytest -m "not slow" -n auto
uv run pytest -k "user and not integration"

# Reports
uv run pytest --cov=src --cov-report=html
uv run pytest --html=report.html
```

## Resources

For external documentation and references, see [external-sources.md](external-sources.md).
