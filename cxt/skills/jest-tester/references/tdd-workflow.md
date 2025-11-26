# Test-Driven Development (TDD) Workflow

Comprehensive guide to Test-Driven Development methodology, the Red-Green-Refactor cycle, and TDD best practices for TypeScript development with Vitest.

## Agent Guidance: When to Apply TDD

**Decision Tree**:
```
User asks to implement feature/fix bug
    ├─ Is this a spike/prototype/POC? → NO TDD (prototype first)
    ├─ Is this simple CRUD? → OPTIONAL TDD
    ├─ Is this complex logic? → YES, use TDD
    ├─ Is this bug fix? → YES, write failing test first
    ├─ Is this new feature? → YES, use TDD
    ├─ Does it involve complex types? → YES, write type tests first
    └─ Is this zod schema? → YES, use TDD
```

**Agent Instructions**:
1. **ALWAYS** use TDD for: complex business logic, bug fixes, new features, API development, type-heavy code
2. **SKIP** TDD for: UI prototypes, proof-of-concepts, one-off scripts
3. **FOLLOW** this sequence: Red (failing test) → Green (minimal code) → Refactor (improve)
4. **INCLUDE** type tests for complex generics
5. **NEVER** skip the refactor step
6. **ENSURE** only ONE failing test at a time

## The Red-Green-Refactor Cycle

TDD follows a simple three-step cycle:

1. **Red**: Write a failing test that defines desired functionality
2. **Green**: Write the minimum code required to make the test pass
3. **Refactor**: Improve code quality without changing behavior

## TDD Process Flow

```typescript
// 1. RED - Write a failing test
import { describe, it, expect } from 'vitest';
import { ShoppingCart, Product } from './cart';

describe('ShoppingCart', () => {
  it('calculates total price correctly', () => {
    const cart = new ShoppingCart();
    cart.addItem(new Product('Book', 10.00), 2);
    cart.addItem(new Product('Pen', 1.50), 3);

    expect(cart.totalPrice()).toBe(24.50);  // Test fails - method doesn't exist
  });
});

// 2. GREEN - Write minimum code to pass
interface ProductData {
  name: string;
  price: number;
}

class Product {
  constructor(
    public name: string,
    public price: number
  ) {}
}

class ShoppingCart {
  private items: Array<{ product: Product; quantity: number }> = [];

  addItem(product: Product, quantity: number): void {
    this.items.push({ product, quantity });
  }

  totalPrice(): number {
    return this.items.reduce(
      (sum, item) => sum + item.product.price * item.quantity,
      0
    );
  }
}

// 3. REFACTOR - Improve code quality
import { z } from 'zod';

const ProductSchema = z.object({
  name: z.string().min(1),
  price: z.number().positive(),
});

type Product = z.infer<typeof ProductSchema>;

interface CartItem {
  product: Product;
  quantity: number;
}

class ShoppingCart {
  private readonly items: CartItem[] = [];

  addItem(product: Product, quantity: number): void {
    if (quantity <= 0) {
      throw new Error('Quantity must be positive');
    }
    this.items.push({ product, quantity });
  }

  totalPrice(): number {
    return this.items.reduce(
      (sum, { product, quantity }) => sum + product.price * quantity,
      0
    );
  }
}
```

## Agent Quick Reference: TDD Workflow

**Step-by-Step Agent Procedure**:
1. **Understand requirement** - Clarify what needs to be implemented
2. **Write failing test** - Test describes expected behavior
3. **Run test** - Verify it fails (Red)
4. **Write minimal code** - Just enough to pass the test
5. **Run test** - Verify it passes (Green)
6. **Write type test** - If complex types are involved
7. **Refactor** - Improve code quality, run tests again
8. **Repeat** - Next requirement/edge case

**Test Naming Convention for Agents**:
```typescript
it('<action> <outcome> when <condition>', () => {});
```

**Example**:
```typescript
it('throws ValidationError when email is invalid', () => {});
it('returns user when found by id', () => {});
it('creates order with correct total', () => {});
```

## TDD Best Practices

**Do's**:
- Write tests first, code second
- Keep tests simple and focused (one assertion per test when possible)
- Write minimum code to pass the test
- Refactor continuously
- Never have more than one failing test at a time
- Use descriptive test names
- Follow Arrange-Act-Assert (AAA) structure
- Include type tests for complex generics
- Test zod schemas and validation

**Don'ts**:
- Write all tests before any implementation
- Skip the refactoring step
- Write complex tests that are hard to understand
- Test implementation details
- Skip edge case testing
- Use `any` in test code

## TDD Benefits (Research-Backed)

Studies show significant benefits:
- **40-90% reduction** in pre-release defect density
- **40% decrease** in defect rates for TDD-adopting organizations
- **15-30% increase** in initial development time
- Better code design through testability requirements
- Living documentation through test suites
- Immediate feedback loop with TypeScript type checking

## When to Use TDD

**Ideal for**:
- New feature development
- Bug fixing (write test that reproduces bug first)
- Complex business logic
- API development
- Library/framework development
- Type-heavy code
- Zod schema validation

**Less suitable for**:
- UI/UX prototyping and design exploration
- Spike solutions and proof-of-concepts
- Simple CRUD operations
- Legacy code without tests (refactor first)

## TDD Workflow Example

### Example 1: Adding a New Feature

**Requirement**: Add discount functionality to shopping cart

**Step 1 - Red**: Write failing test
```typescript
import { describe, it, expect } from 'vitest';
import { ShoppingCart, Product } from './cart';

describe('ShoppingCart', () => {
  describe('applyDiscount', () => {
    it('reduces total by percentage', () => {
      const cart = new ShoppingCart();
      cart.addItem(new Product('Book', 100.00), 1);

      cart.applyDiscount(20);  // 20% discount

      expect(cart.totalPrice()).toBe(80.00);
    });
  });
});
```

**Step 2 - Green**: Implement minimum code
```typescript
class ShoppingCart {
  private items: CartItem[] = [];
  private discountPercent = 0;

  addItem(product: Product, quantity: number): void {
    this.items.push({ product, quantity });
  }

  applyDiscount(percent: number): void {
    this.discountPercent = percent;
  }

  totalPrice(): number {
    const subtotal = this.items.reduce(
      (sum, { product, quantity }) => sum + product.price * quantity,
      0
    );
    const discount = subtotal * (this.discountPercent / 100);
    return subtotal - discount;
  }
}
```

**Step 3 - Refactor**: Improve code quality
```typescript
import { z } from 'zod';

const DiscountSchema = z.number().int().min(0).max(100);

class ShoppingCart {
  private readonly items: CartItem[] = [];
  private discountPercent = 0;

  applyDiscount(percent: number): void {
    const validated = DiscountSchema.parse(percent);
    this.discountPercent = validated;
  }

  private calculateSubtotal(): number {
    return this.items.reduce(
      (sum, { product, quantity }) => sum + product.price * quantity,
      0
    );
  }

  private calculateDiscount(subtotal: number): number {
    return subtotal * (this.discountPercent / 100);
  }

  totalPrice(): number {
    const subtotal = this.calculateSubtotal();
    const discount = this.calculateDiscount(subtotal);
    return subtotal - discount;
  }
}
```

### Example 2: Bug Fixing with TDD

**Bug Report**: "Cart allows negative quantities"

**Step 1 - Red**: Write test that reproduces bug
```typescript
import { describe, it, expect } from 'vitest';
import { ShoppingCart, Product, ValidationError } from './cart';

describe('ShoppingCart', () => {
  describe('addItem', () => {
    it('throws ValidationError when quantity is negative', () => {
      const cart = new ShoppingCart();
      const product = new Product('Book', 10.00);

      expect(() => cart.addItem(product, -5))
        .toThrowError(ValidationError);
    });

    it('throws ValidationError when quantity is zero', () => {
      const cart = new ShoppingCart();
      const product = new Product('Book', 10.00);

      expect(() => cart.addItem(product, 0))
        .toThrowError(ValidationError);
    });
  });
});
```

**Step 2 - Green**: Fix the bug
```typescript
class ValidationError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'ValidationError';
  }
}

class ShoppingCart {
  addItem(product: Product, quantity: number): void {
    if (quantity <= 0) {
      throw new ValidationError('Quantity must be positive');
    }
    this.items.push({ product, quantity });
  }
}
```

**Step 3 - Refactor**: Use zod for validation
```typescript
import { z } from 'zod';

const QuantitySchema = z.number().int().positive();

class ShoppingCart {
  addItem(product: Product, quantity: number): void {
    const result = QuantitySchema.safeParse(quantity);
    if (!result.success) {
      throw new ValidationError('Quantity must be a positive integer');
    }
    this.items.push({ product, quantity: result.data });
  }
}
```

## Common TDD Patterns

### Arrange-Act-Assert (AAA)

```typescript
import { describe, it, expect } from 'vitest';

describe('UserService', () => {
  it('creates user with valid data', () => {
    // Arrange - Setup test data
    const userData = {
      name: 'Alice',
      email: 'alice@example.com',
      age: 30,
    };

    // Act - Perform action
    const user = createUser(userData);

    // Assert - Verify results
    expect(user.id).toBeDefined();
    expect(user.name).toBe('Alice');
    expect(user.email).toBe('alice@example.com');
    expect(user.age).toBe(30);
  });
});
```

### Test One Thing

```typescript
// GOOD - Tests one thing
it('validates email format', () => {
  expect(() => createUser({ email: 'invalid' }))
    .toThrow('Invalid email');
});

it('validates name is required', () => {
  expect(() => createUser({ email: 'test@example.com' }))
    .toThrow('Name is required');
});

// BAD - Tests multiple things
it('validates user', () => {
  // Testing email validation
  expect(() => createUser({ email: 'invalid' })).toThrow();

  // Testing name validation
  expect(() => createUser({ email: 'test@example.com' })).toThrow();

  // Hard to know which validation failed if test breaks
});
```

### Descriptive Test Names

```typescript
// GOOD - Descriptive names
it('returns empty array when no users match filter', () => {});
it('throws NotFoundError when user does not exist', () => {});
it('updates user email when valid format provided', () => {});

// BAD - Vague names
it('works', () => {});
it('test', () => {});
it('user', () => {});
```

## Type-Driven Development with TDD

TypeScript adds a powerful dimension to TDD - write type tests alongside unit tests.

### Type Test Example

```typescript
// user.test-d.ts
import { expectTypeOf } from 'vitest';
import type { User, CreateUserInput, UserId } from './user';

// Test type relationships
expectTypeOf<CreateUserInput>().toMatchTypeOf<Omit<User, 'id'>>();

// Test branded types are distinct
expectTypeOf<UserId>().not.toMatchTypeOf<string>();

// Test function return types
import { createUser } from './user';
expectTypeOf(createUser).returns.toMatchTypeOf<User>();
```

### TDD with Zod Schemas

```typescript
// 1. RED - Write failing test for schema
import { describe, it, expect } from 'vitest';
import { UserSchema } from './schemas';

describe('UserSchema', () => {
  it('validates correct user data', () => {
    const validUser = {
      id: '123e4567-e89b-12d3-a456-426614174000',
      name: 'Alice',
      email: 'alice@example.com',
    };

    expect(() => UserSchema.parse(validUser)).not.toThrow();
  });

  it('rejects invalid email', () => {
    const invalidUser = {
      id: '123e4567-e89b-12d3-a456-426614174000',
      name: 'Alice',
      email: 'not-an-email',
    };

    expect(() => UserSchema.parse(invalidUser)).toThrow();
  });
});

// 2. GREEN - Implement schema
import { z } from 'zod';

export const UserSchema = z.object({
  id: z.string().uuid(),
  name: z.string().min(1),
  email: z.string().email(),
});

export type User = z.infer<typeof UserSchema>;
```

## TDD Anti-Patterns to Avoid

### The Liar
Test that passes but doesn't actually test anything:
```typescript
// BAD - The Liar
it('calculates total', () => {
  const result = calculateTotal([1, 2, 3]);
  expect(true).toBe(true);  // Always passes!
});
```

### The Giant
Test that's too large and tests too many things:
```typescript
// BAD - The Giant
it('tests entire checkout flow', () => {
  // 100 lines of test code testing everything
});
```

### The Mockery
Test with too many mocks that doesn't test real behavior:
```typescript
// BAD - The Mockery
it('processes order', () => {
  const mockDb = vi.fn();
  const mockEmail = vi.fn();
  const mockPayment = vi.fn();
  const mockInventory = vi.fn();
  const mockShipping = vi.fn();
  // Not testing any real code
});
```

### The Any Escape
Using `any` to avoid type errors in tests:
```typescript
// BAD - The Any Escape
it('creates user', () => {
  const user: any = createUser({ name: 'test' });
  expect(user.name).toBe('test');
});

// GOOD - Use proper types
it('creates user', () => {
  const user = createUser({ name: 'test', email: 'test@example.com' });
  expect(user.name).toBe('test');
});
```

## Agent Implementation Checklist

Before completing TDD implementation, verify:

**Test Quality**:
- [ ] All tests have descriptive names following convention
- [ ] Each test tests ONE thing only
- [ ] Tests follow Arrange-Act-Assert pattern
- [ ] Edge cases are covered (empty, null, undefined, boundary values)
- [ ] Error cases are tested with proper error types
- [ ] Type tests written for complex generics

**Code Quality**:
- [ ] Minimal code written to pass tests (no over-engineering)
- [ ] Code has been refactored for clarity
- [ ] Type hints are correct and specific (no `any`)
- [ ] No code duplication
- [ ] Functions are small and focused
- [ ] Zod schemas used for runtime validation

**Test Execution**:
- [ ] All tests pass (`pnpm exec vitest run`)
- [ ] Type tests pass (`pnpm exec vitest --typecheck`)
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
| Complex types | **Type test first** | Define type behavior |
| Zod schemas | **Test-first** | Define validation rules |
| Prototype/POC | **Code-first** | Explore solution space |
| UI mockup | **Code-first** | Visual feedback needed |
| Simple CRUD | **Either** | Low complexity |

## Resources

For external documentation and references, see [external-sources.md](external-sources.md).
