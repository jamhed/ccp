# Behavior-Driven Development (BDD) Workflow

Comprehensive guide to Behavior-Driven Development methodology, Given-When-Then syntax, and pytest-bdd implementation for Python.

## Agent Guidance: When to Use BDD

**Decision Tree**:
```
User asks to implement feature
    ├─ Is this user-facing functionality? → YES, consider BDD
    ├─ Does user mention "user story" or "acceptance criteria"? → YES, use BDD
    ├─ Is this internal utility/helper function? → NO, use pytest directly
    ├─ Are non-technical stakeholders involved? → YES, use BDD
    ├─ Is this API contract testing? → YES, consider BDD
    └─ Is this unit test for logic? → NO, use pytest directly
```

**Agent Instructions**:
1. **USE BDD** for: user-facing features, acceptance tests, stakeholder collaboration
2. **SKIP BDD** for: unit tests, performance tests, internal utilities
3. **WRITE** scenarios in business language (avoid technical jargon)
4. **FOCUS** on behavior (what) not implementation (how)
5. **REUSE** step definitions across scenarios

## Agent Quick Reference: BDD Workflow

**Step-by-Step Procedure**:
1. **Create feature file** - `features/<feature_name>.feature`
2. **Write scenario** - Given-When-Then format
3. **Implement step definitions** - `tests/step_defs/test_<feature_name>.py`
4. **Run scenario** - Verify it fails (Red)
5. **Implement feature** - Application code
6. **Run scenario** - Verify it passes (Green)
7. **Refactor** - Clean up code

**Gherkin Template for Agents**:
```gherkin
Feature: <Feature Name>
  As a <user role>
  I want to <goal>
  So that <benefit>

  Scenario: <Specific behavior>
    Given <precondition>
    When <action>
    Then <expected outcome>
```

## BDD Overview

Behavior-Driven Development (BDD) extends TDD by writing tests in business-readable language that describes behavior from the user's perspective.

**Key Principles**:
- Write scenarios in business language (Gherkin)
- Focus on behavior, not implementation
- Collaborate with non-technical stakeholders
- Create living documentation
- Enable specification by example

## Given-When-Then Syntax

BDD uses the Gherkin language to describe behavior:

```gherkin
Feature: Shopping Cart
  As a customer
  I want to add items to my shopping cart
  So that I can purchase multiple items

  Scenario: Calculate total with multiple items
    Given an empty shopping cart
    And a product "Book" with price 10.00
    And a product "Pen" with price 1.50
    When I add 2 "Book" items to the cart
    And I add 3 "Pen" items to the cart
    Then the cart total should be 24.50

  Scenario: Apply discount code
    Given a shopping cart with total 100.00
    When I apply discount code "SAVE20"
    Then the cart total should be 80.00
    And the discount amount should be 20.00
```

### Gherkin Keywords

- **Feature**: High-level description of functionality
- **Scenario**: Specific example of behavior
- **Given**: Initial context (preconditions)
- **When**: Action or event
- **Then**: Expected outcome
- **And**: Additional conditions or actions
- **But**: Negative conditions

## BDD with pytest-bdd

### Installation

```bash
uv add --dev pytest-bdd
```

### Feature Files

Create feature files in `features/` directory:

```gherkin
# features/shopping_cart.feature

Feature: Shopping Cart
  As a customer
  I want to add items to my shopping cart
  So that I can purchase multiple items

  Scenario: Calculate total with multiple items
    Given an empty shopping cart
    And a product "Book" with price 10.00
    And a product "Pen" with price 1.50
    When I add 2 "Book" items to the cart
    And I add 3 "Pen" items to the cart
    Then the cart total should be 24.50
```

### Step Definitions

Implement step definitions in test files:

```python
# tests/step_defs/test_shopping_cart.py

from pytest_bdd import scenarios, given, when, then, parsers
import pytest

# Load scenarios from feature file
scenarios('../features/shopping_cart.feature')

# Step definitions
@given('an empty shopping cart')
def empty_cart():
    return ShoppingCart()

@given(parsers.parse('a product "{name}" with price {price:f}'))
def product(name, price):
    return Product(name, price)

@when(parsers.parse('I add {quantity:d} "{name}" items to the cart'))
def add_items(empty_cart, product, quantity, name):
    empty_cart.add_item(product, quantity)

@then(parsers.parse('the cart total should be {expected:f}'))
def verify_total(empty_cart, expected):
    assert empty_cart.total_price() == expected
```

## BDD Best Practices

**Do's**:
- ✅ Write scenarios in business language
- ✅ Focus on behavior, not implementation
- ✅ Use descriptive scenario names
- ✅ Keep scenarios independent
- ✅ Reuse step definitions across scenarios
- ✅ Involve non-technical stakeholders in scenario writing
- ✅ Use scenario outlines for data-driven tests

**Don'ts**:
- ❌ Include technical details in feature files
- ❌ Test implementation details
- ❌ Create overly complex scenarios
- ❌ Duplicate step definitions
- ❌ Use BDD for unit tests (use pytest directly)

## Scenario Outlines (Data-Driven Tests)

Test the same behavior with different data:

```gherkin
Feature: Discount Calculation

  Scenario Outline: Apply various discount codes
    Given a shopping cart with total <original_price>
    When I apply discount code "<code>"
    Then the cart total should be <final_price>
    And the discount amount should be <discount>

    Examples:
      | original_price | code    | final_price | discount |
      | 100.00         | SAVE10  | 90.00       | 10.00    |
      | 100.00         | SAVE20  | 80.00       | 20.00    |
      | 100.00         | SAVE50  | 50.00       | 50.00    |
      | 50.00          | SAVE10  | 45.00       | 5.00     |
```

Implementation:

```python
from pytest_bdd import scenarios, given, when, then, parsers

scenarios('../features/discounts.feature')

@given(parsers.parse('a shopping cart with total {price:f}'))
def cart_with_total(price):
    cart = ShoppingCart()
    # Add items to reach the price
    cart.add_item(Product("Item", price), quantity=1)
    return cart

@when(parsers.parse('I apply discount code "{code}"'))
def apply_discount_code(cart_with_total, code):
    cart_with_total.apply_discount_code(code)

@then(parsers.parse('the cart total should be {expected:f}'))
def check_total(cart_with_total, expected):
    assert cart_with_total.total_price() == expected

@then(parsers.parse('the discount amount should be {expected:f}'))
def check_discount(cart_with_total, expected):
    assert cart_with_total.discount_amount == expected
```

## Complex BDD Scenarios

### Background Steps

Reuse setup across scenarios:

```gherkin
Feature: User Authentication

  Background:
    Given a user exists with email "user@example.com"
    And the user password is "password123"

  Scenario: Successful login
    When I login with email "user@example.com" and password "password123"
    Then I should be logged in
    And I should see my dashboard

  Scenario: Failed login with wrong password
    When I login with email "user@example.com" and password "wrong"
    Then I should see an error "Invalid credentials"
    And I should not be logged in
```

### Tables in Steps

Pass tabular data to steps:

```gherkin
Scenario: Bulk add items to cart
  Given an empty shopping cart
  When I add the following items:
    | product  | price | quantity |
    | Book     | 10.00 | 2        |
    | Pen      | 1.50  | 3        |
    | Notebook | 5.00  | 1        |
  Then the cart should contain 3 item types
  And the cart total should be 29.50
```

Implementation:

```python
@when(parsers.parse('I add the following items:'))
def add_multiple_items(empty_cart, datatable):
    """Add multiple items from table."""
    for row in datatable:
        product = Product(row['product'], float(row['price']))
        quantity = int(row['quantity'])
        empty_cart.add_item(product, quantity)

@then(parsers.parse('the cart should contain {count:d} item types'))
def check_item_count(empty_cart, count):
    assert len(empty_cart.items) == count
```

## pytest-bdd vs behave

| Feature | pytest-bdd | behave |
|---------|-----------|--------|
| **Framework** | pytest plugin | Standalone |
| **Fixtures** | Full pytest fixtures | Limited |
| **Plugins** | All pytest plugins | behave-specific |
| **Markers** | pytest markers | behave tags |
| **Learning Curve** | Easy (if you know pytest) | Moderate |
| **Integration** | Seamless with pytest | Separate ecosystem |

**Recommendation**: Use **pytest-bdd** for Python projects in 2025 - it integrates seamlessly with pytest and allows fixture reuse.

## When to Use BDD

**Ideal for**:
- ✅ User-facing features
- ✅ Acceptance testing
- ✅ Projects with non-technical stakeholders
- ✅ Complex business workflows
- ✅ API contract testing

**Less suitable for**:
- ❌ Unit testing (use pytest directly)
- ❌ Performance testing
- ❌ Internal utility functions
- ❌ Projects without stakeholder involvement

## BDD Workflow Example

### Example: User Registration Feature

**Step 1**: Write feature file with stakeholders

```gherkin
# features/user_registration.feature

Feature: User Registration
  As a new user
  I want to register for an account
  So that I can use the application

  Scenario: Successful registration
    Given I am on the registration page
    When I enter email "alice@example.com"
    And I enter password "SecurePass123"
    And I enter password confirmation "SecurePass123"
    And I click the "Register" button
    Then I should see a success message "Registration successful"
    And I should receive a confirmation email
    And I should be redirected to the dashboard

  Scenario: Registration with existing email
    Given a user exists with email "alice@example.com"
    And I am on the registration page
    When I enter email "alice@example.com"
    And I enter password "SecurePass123"
    And I enter password confirmation "SecurePass123"
    And I click the "Register" button
    Then I should see an error "Email already registered"
    And I should not be registered

  Scenario: Registration with weak password
    Given I am on the registration page
    When I enter email "bob@example.com"
    And I enter password "123"
    And I enter password confirmation "123"
    And I click the "Register" button
    Then I should see an error "Password must be at least 8 characters"
    And I should not be registered
```

**Step 2**: Implement step definitions

```python
# tests/step_defs/test_user_registration.py

from pytest_bdd import scenarios, given, when, then, parsers
import pytest

scenarios('../features/user_registration.feature')

@given('I am on the registration page')
def registration_page(client):
    """Navigate to registration page."""
    response = client.get('/register')
    assert response.status_code == 200
    return response

@given(parsers.parse('a user exists with email "{email}"'))
def existing_user(db_session, email):
    """Create existing user."""
    user = User(email=email, password="password123")
    db_session.add(user)
    db_session.commit()
    return user

@when(parsers.parse('I enter email "{email}"'))
def enter_email(context, email):
    """Store email in context."""
    if not hasattr(context, 'form_data'):
        context.form_data = {}
    context.form_data['email'] = email

@when(parsers.parse('I enter password "{password}"'))
def enter_password(context, password):
    """Store password in context."""
    if not hasattr(context, 'form_data'):
        context.form_data = {}
    context.form_data['password'] = password

@when(parsers.parse('I enter password confirmation "{password}"'))
def enter_password_confirmation(context, password):
    """Store password confirmation in context."""
    if not hasattr(context, 'form_data'):
        context.form_data = {}
    context.form_data['password_confirmation'] = password

@when(parsers.parse('I click the "{button}" button'))
def click_button(client, context, button):
    """Submit registration form."""
    response = client.post('/register', data=context.form_data)
    context.response = response
    return response

@then(parsers.parse('I should see a success message "{message}"'))
def check_success_message(context, message):
    """Verify success message."""
    assert message in context.response.get_data(as_text=True)

@then(parsers.parse('I should see an error "{message}"'))
def check_error_message(context, message):
    """Verify error message."""
    assert message in context.response.get_data(as_text=True)

@then('I should receive a confirmation email')
def check_confirmation_email(mail_outbox):
    """Verify confirmation email sent."""
    assert len(mail_outbox) == 1
    assert "confirmation" in mail_outbox[0].subject.lower()

@then('I should not be registered')
def check_not_registered(db_session, context):
    """Verify user was not created."""
    email = context.form_data.get('email')
    user = db_session.query(User).filter_by(email=email).first()
    assert user is None
```

**Step 3**: Implement the feature

```python
# app/routes/auth.py

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        email = request.form.get('email')
        password = request.form.get('password')
        password_confirmation = request.form.get('password_confirmation')

        # Validation
        if User.query.filter_by(email=email).first():
            return render_template('register.html', error="Email already registered")

        if len(password) < 8:
            return render_template('register.html', error="Password must be at least 8 characters")

        if password != password_confirmation:
            return render_template('register.html', error="Passwords do not match")

        # Create user
        user = User(email=email)
        user.set_password(password)
        db.session.add(user)
        db.session.commit()

        # Send confirmation email
        send_confirmation_email(user)

        flash("Registration successful")
        return redirect(url_for('dashboard'))

    return render_template('register.html')
```

## BDD Tags

Organize scenarios with tags:

```gherkin
@smoke @authentication
Scenario: Successful login
  Given I am on the login page
  When I enter valid credentials
  Then I should be logged in

@slow @integration
Scenario: User data synchronization
  Given I am logged in
  When I update my profile
  Then my data should sync across devices
```

Run scenarios by tag:

```bash
# Run only smoke tests
pytest -m smoke

# Run authentication scenarios
pytest -k authentication
```

## Agent Implementation Checklist

Before completing BDD implementation, verify:

**Feature File Quality**:
- [ ] Feature file uses business language (no technical jargon)
- [ ] Scenarios are independent and can run in any order
- [ ] Each scenario tests ONE specific behavior
- [ ] Given-When-Then steps are clear and unambiguous
- [ ] Background steps used for common preconditions (if applicable)

**Step Definitions**:
- [ ] Step definitions are reusable across scenarios
- [ ] No duplicate step definitions
- [ ] Step definitions use pytest fixtures effectively
- [ ] Parsers correctly extract parameters from steps
- [ ] Step definitions focus on behavior, not implementation

**Test Execution**:
- [ ] All scenarios pass (`uv run pytest`)
- [ ] Scenarios run independently
- [ ] No flaky scenarios
- [ ] Error messages are clear and actionable

**Documentation**:
- [ ] Feature files serve as living documentation
- [ ] Scenario names clearly describe behavior
- [ ] Tags used appropriately (@smoke, @integration, etc.)

## Agent Common Patterns

**Pattern 1: Data Tables in Steps**
```gherkin
When I add the following items:
  | product  | quantity |
  | Book     | 2        |
  | Pen      | 3        |
```

```python
@when(parsers.parse('I add the following items:'))
def add_items(cart, datatable):
    for row in datatable:
        cart.add_item(row['product'], int(row['quantity']))
```

**Pattern 2: Scenario Outlines**
```gherkin
Scenario Outline: Apply discount
  Given cart total is <original>
  When I apply code "<code>"
  Then total should be <final>

  Examples:
    | original | code    | final |
    | 100      | SAVE10  | 90    |
    | 100      | SAVE20  | 80    |
```

**Pattern 3: Background Steps**
```gherkin
Background:
  Given a user exists with email "user@example.com"
  And the database is clean
```

## Resources

For external documentation and references, see [external-sources.md](external-sources.md).
