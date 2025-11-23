# Test-Driven Development (TDD) Workflow

Comprehensive guide to Test-Driven Development methodology, the Red-Green-Refactor cycle, and TDD best practices for Python development.

## Agent Guidance: When to Apply TDD

**Decision Tree**:
```
User asks to implement feature/fix bug
    ├─ Is this a spike/prototype/POC? → NO TDD (prototype first)
    ├─ Is this simple CRUD? → OPTIONAL TDD
    ├─ Is this complex logic? → YES, use TDD
    ├─ Is this bug fix? → YES, write failing test first
    └─ Is this new feature? → YES, use TDD
```

**Agent Instructions**:
1. **ALWAYS** use TDD for: complex business logic, bug fixes, new features, API development
2. **SKIP** TDD for: UI prototypes, proof-of-concepts, one-off scripts
3. **FOLLOW** this sequence: Red (failing test) → Green (minimal code) → Refactor (improve)
4. **NEVER** skip the refactor step
5. **ENSURE** only ONE failing test at a time

## The Red-Green-Refactor Cycle

TDD follows a simple three-step cycle:

1. **Red**: Write a failing test that defines desired functionality
2. **Green**: Write the minimum code required to make the test pass
3. **Refactor**: Improve code quality without changing behavior

## TDD Process Flow

```python
# 1. RED - Write a failing test
def test_calculate_total_price():
    cart = ShoppingCart()
    cart.add_item(Product("Book", 10.00), quantity=2)
    cart.add_item(Product("Pen", 1.50), quantity=3)

    assert cart.total_price() == 24.50  # Test fails - method doesn't exist

# 2. GREEN - Write minimum code to pass
class ShoppingCart:
    def __init__(self):
        self.items = []

    def add_item(self, product, quantity):
        self.items.append((product, quantity))

    def total_price(self):
        return sum(product.price * qty for product, qty in self.items)

# 3. REFACTOR - Improve code quality
class ShoppingCart:
    def __init__(self):
        self._items: list[tuple[Product, int]] = []

    def add_item(self, product: Product, quantity: int) -> None:
        if quantity <= 0:
            raise ValueError("Quantity must be positive")
        self._items.append((product, quantity))

    def total_price(self) -> Decimal:
        """Calculate total price with proper decimal precision."""
        return sum(
            Decimal(str(product.price)) * quantity
            for product, quantity in self._items
        )
```

## Agent Quick Reference: TDD Workflow

**Step-by-Step Agent Procedure**:
1. **Understand requirement** - Clarify what needs to be implemented
2. **Write failing test** - Test describes expected behavior
3. **Run test** - Verify it fails (Red)
4. **Write minimal code** - Just enough to pass the test
5. **Run test** - Verify it passes (Green)
6. **Refactor** - Improve code quality, run tests again
7. **Repeat** - Next requirement/edge case

**Test Naming Convention for Agents**:
```python
def test_<function>_<scenario>_<expected_outcome>():
    """Test that <function> <action> when <scenario>."""
```

**Example**:
```python
def test_add_item_raises_error_when_quantity_negative():
    """Test that add_item raises ValueError when quantity is negative."""
```

## TDD Best Practices

**Do's**:
- ✅ Write tests first, code second
- ✅ Keep tests simple and focused (one assertion per test)
- ✅ Write minimum code to pass the test
- ✅ Refactor continuously
- ✅ Never have more than one failing test at a time
- ✅ Use descriptive test names
- ✅ Follow Arrange-Act-Assert (AAA) structure
- ✅ Cover edge cases before happy paths

**Don'ts**:
- ❌ Write all tests before any implementation
- ❌ Skip the refactoring step
- ❌ Write complex tests that are hard to understand
- ❌ Test implementation details
- ❌ Skip edge case testing

## TDD Benefits (Research-Backed)

Studies show significant benefits:
- **40-90% reduction** in pre-release defect density
- **40% decrease** in defect rates for TDD-adopting organizations
- **15-30% increase** in initial development time
- Better code design through testability requirements
- Living documentation through test suites

## When to Use TDD

**Ideal for**:
- ✅ New feature development
- ✅ Bug fixing (write test that reproduces bug first)
- ✅ Complex business logic
- ✅ API development
- ✅ Library/framework development

**Less suitable for**:
- ❌ UI/UX prototyping and design exploration
- ❌ Spike solutions and proof-of-concepts
- ❌ Simple CRUD operations
- ❌ Legacy code without tests (refactor first)

## TDD Workflow Example

### Example 1: Adding a New Feature

**Requirement**: Add discount functionality to shopping cart

**Step 1 - Red**: Write failing test
```python
def test_apply_discount():
    """Test applying percentage discount to cart."""
    cart = ShoppingCart()
    cart.add_item(Product("Book", 100.00), quantity=1)

    cart.apply_discount(20)  # 20% discount

    assert cart.total_price() == 80.00
```

**Step 2 - Green**: Implement minimum code
```python
class ShoppingCart:
    # ... existing code ...

    def apply_discount(self, percent: int) -> None:
        """Apply percentage discount to cart."""
        self.discount_percent = percent

    def total_price(self) -> Decimal:
        """Calculate total price with discount applied."""
        subtotal = sum(
            Decimal(str(product.price)) * quantity
            for product, quantity in self._items
        )

        if hasattr(self, 'discount_percent'):
            discount = subtotal * (Decimal(self.discount_percent) / 100)
            return subtotal - discount

        return subtotal
```

**Step 3 - Refactor**: Improve code quality
```python
class ShoppingCart:
    def __init__(self):
        self._items: list[tuple[Product, int]] = []
        self._discount_percent: Decimal = Decimal(0)

    def apply_discount(self, percent: int) -> None:
        """Apply percentage discount to cart."""
        if not 0 <= percent <= 100:
            raise ValueError("Discount must be between 0 and 100")
        self._discount_percent = Decimal(percent)

    def _calculate_subtotal(self) -> Decimal:
        """Calculate subtotal before discount."""
        return sum(
            Decimal(str(product.price)) * quantity
            for product, quantity in self._items
        )

    def _calculate_discount(self, subtotal: Decimal) -> Decimal:
        """Calculate discount amount."""
        return subtotal * (self._discount_percent / 100)

    def total_price(self) -> Decimal:
        """Calculate total price with discount applied."""
        subtotal = self._calculate_subtotal()
        discount = self._calculate_discount(subtotal)
        return subtotal - discount
```

### Example 2: Bug Fixing with TDD

**Bug Report**: "Cart allows negative quantities"

**Step 1 - Red**: Write test that reproduces bug
```python
def test_negative_quantity_rejected():
    """Test that negative quantities raise ValueError."""
    cart = ShoppingCart()
    product = Product("Book", 10.00)

    with pytest.raises(ValueError, match="Quantity must be positive"):
        cart.add_item(product, quantity=-5)
```

**Step 2 - Green**: Fix the bug
```python
def add_item(self, product: Product, quantity: int) -> None:
    """Add item to cart with quantity validation."""
    if quantity <= 0:
        raise ValueError("Quantity must be positive")
    self._items.append((product, quantity))
```

**Step 3 - Refactor**: Add more validation
```python
def add_item(self, product: Product, quantity: int) -> None:
    """Add item to cart with comprehensive validation."""
    if not isinstance(quantity, int):
        raise TypeError("Quantity must be an integer")
    if quantity <= 0:
        raise ValueError("Quantity must be positive")
    if quantity > 1000:  # Business rule
        raise ValueError("Quantity exceeds maximum allowed")

    self._items.append((product, quantity))
```

## Common TDD Patterns

### Arrange-Act-Assert (AAA)

```python
def test_user_creation():
    """Test user creation with AAA pattern."""
    # Arrange - Setup test data
    user_data = {
        "name": "Alice",
        "email": "alice@example.com",
        "age": 30
    }

    # Act - Perform action
    user = User.create(user_data)

    # Assert - Verify results
    assert user.id is not None
    assert user.name == "Alice"
    assert user.email == "alice@example.com"
    assert user.age == 30
```

### Test One Thing

```python
# ✅ GOOD - Tests one thing
def test_user_name_validation():
    """Test user name validation."""
    with pytest.raises(ValueError, match="Name cannot be empty"):
        User(name="", email="test@example.com")

def test_user_email_validation():
    """Test user email validation."""
    with pytest.raises(ValueError, match="Invalid email"):
        User(name="Alice", email="invalid")

# ❌ BAD - Tests multiple things
def test_user_validation():
    """Test user validation."""
    # Testing name validation
    with pytest.raises(ValueError):
        User(name="", email="test@example.com")

    # Testing email validation
    with pytest.raises(ValueError):
        User(name="Alice", email="invalid")

    # Hard to know which validation failed if test breaks
```

### Descriptive Test Names

```python
# ✅ GOOD - Descriptive names
def test_total_price_includes_all_items():
    pass

def test_discount_reduces_price_by_correct_percentage():
    pass

def test_empty_cart_has_zero_total():
    pass

# ❌ BAD - Vague names
def test_price():
    pass

def test_cart():
    pass

def test_1():
    pass
```

## TDD Anti-Patterns to Avoid

### The Liar
Test that passes but doesn't actually test anything:
```python
# ❌ BAD - The Liar
def test_calculation():
    result = calculate_total()
    assert True  # Always passes!
```

### The Giant
Test that's too large and tests too many things:
```python
# ❌ BAD - The Giant
def test_entire_checkout_flow():
    # 100 lines of test code testing everything
    pass
```

### The Mockery
Test with too many mocks that doesn't test real behavior:
```python
# ❌ BAD - The Mockery
@patch('service1')
@patch('service2')
@patch('service3')
@patch('service4')
@patch('service5')
def test_business_logic(m1, m2, m3, m4, m5):
    # Not testing any real code
    pass
```

### The Slow Poke
Test that takes too long to run:
```python
# ❌ BAD - The Slow Poke
def test_data_processing():
    time.sleep(5)  # Simulating slow operation
    # Use mocks or smaller datasets instead
```

## TDD with pytest

### Using pytest Fixtures for Setup

```python
import pytest

@pytest.fixture
def shopping_cart():
    """Provide empty shopping cart for tests."""
    return ShoppingCart()

@pytest.fixture
def sample_products():
    """Provide sample products for tests."""
    return [
        Product("Book", 10.00),
        Product("Pen", 1.50),
        Product("Notebook", 5.00)
    ]

def test_add_single_item(shopping_cart, sample_products):
    """Test adding single item to cart."""
    cart = shopping_cart
    product = sample_products[0]

    cart.add_item(product, quantity=1)

    assert cart.total_price() == 10.00

def test_add_multiple_items(shopping_cart, sample_products):
    """Test adding multiple items to cart."""
    cart = shopping_cart

    cart.add_item(sample_products[0], quantity=2)
    cart.add_item(sample_products[1], quantity=3)

    assert cart.total_price() == 24.50
```

### Parametrized Tests for Edge Cases

```python
import pytest

@pytest.mark.parametrize("quantity,expected_error", [
    (-1, "Quantity must be positive"),
    (0, "Quantity must be positive"),
    (1001, "Quantity exceeds maximum"),
    ("abc", "Quantity must be an integer"),
])
def test_invalid_quantities(shopping_cart, sample_products, quantity, expected_error):
    """Test various invalid quantity scenarios."""
    product = sample_products[0]

    with pytest.raises((ValueError, TypeError), match=expected_error):
        shopping_cart.add_item(product, quantity=quantity)
```

## Agent Implementation Checklist

Before completing TDD implementation, verify:

**Test Quality**:
- [ ] All tests have descriptive names following convention
- [ ] Each test tests ONE thing only
- [ ] Tests follow Arrange-Act-Assert pattern
- [ ] Edge cases are covered (empty, null, boundary values)
- [ ] Error cases are tested with pytest.raises

**Code Quality**:
- [ ] Minimal code written to pass tests (no over-engineering)
- [ ] Code has been refactored for clarity
- [ ] Type hints added where appropriate
- [ ] No code duplication
- [ ] Functions are small and focused

**Test Execution**:
- [ ] All tests pass (`uv run pytest -v`)
- [ ] Tests run fast (<100ms for unit tests)
- [ ] Tests are independent (can run in any order)
- [ ] No test interdependencies

**Coverage**:
- [ ] Happy path covered
- [ ] Error paths covered
- [ ] Edge cases covered
- [ ] Coverage >80% for critical code

## Agent Decision Matrix: Test-First vs Code-First

| Scenario | Approach | Reason |
|----------|----------|--------|
| New feature | **Test-first** | Design through tests |
| Bug fix | **Test-first** | Reproduce bug with test |
| Complex logic | **Test-first** | Think through edge cases |
| Refactoring | **Test-first** | Ensure no regression |
| Prototype/POC | **Code-first** | Explore solution space |
| UI mockup | **Code-first** | Visual feedback needed |
| Simple CRUD | **Either** | Low complexity |

## Resources

For external documentation and references, see [external-sources.md](external-sources.md).
