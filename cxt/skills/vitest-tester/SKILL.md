---
name: vitest-tester
description: Testing expert for modern TypeScript with Vitest - blazing-fast test runner, explicit imports, type testing with expectTypeOf, zod validation, ESM-first, mocking patterns, TDD workflows. Use when: writing or reviewing tests; setting up test infrastructure; implementing mocks and fixtures; debugging test failures; practicing TDD/BDD.
---

# Vitest Testing Expert (2025)

Expert assistant for writing comprehensive, type-safe tests with Vitest for TypeScript 5.7+ projects in 2025.

## Core Capabilities

### 1. Test Framework - Vitest (2025 Standard)

**Why Vitest in 2025**:
- **Blazing Fast**: 10-20x faster than Jest in watch mode
- **Vite-Native**: Zero-config for Vite projects, excellent HMR
- **ESM-First**: Native ES modules support, no CommonJS quirks
- **Type Testing**: Built-in `expectTypeOf` for testing types
- **Modern DX**: Watch mode by default, visual UI, excellent error messages
- **Jest Compatible**: 95% API compatibility for easy migration

**Key Principles**:
- **Explicit imports**: Always import `describe`, `it`, `expect`, `vi` - never use globals
- **Type-safe mocking**: Use `vi.fn<>()` with type parameters
- **ESM-first**: All tests use import/export
- **Type testing**: Use `expectTypeOf` for testing type behavior

**Reference**: [references/test-organization.md](references/test-organization.md)

### 2. Test-Driven Development (TDD)

When implementing features or fixing bugs:
- **Red**: Write failing test first (defines expected behavior)
- **Green**: Write minimal code to pass
- **Refactor**: Improve code quality while tests pass

**Use TDD for**: Complex logic, bug fixes, new features, zod schemas, type-heavy code

**Reference**: [references/tdd-workflow.md](references/tdd-workflow.md)

### 3. Mocking and Test Isolation

When mocking dependencies:
- **Mock external dependencies**: HTTP, DB, filesystem, time, external APIs
- **Don't mock internal code**: Test real integrations where possible
- **Type-safe mocks**: `vi.fn<[args], ReturnType>()` for type safety
- **Use vi.hoisted()**: For mock references in vi.mock()

**Reference**: [references/mocking-patterns.md](references/mocking-patterns.md)

### 4. Async Testing

When testing async code:
- Use async/await in test functions
- Use `.resolves/.rejects` for Promise assertions
- Use `vi.useFakeTimers()` for delays and timeouts
- Test both success and error paths

**Reference**: [references/async-testing.md](references/async-testing.md)

## Quick Start Example

```typescript
// user.test.ts - Modern Vitest test file
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { UserService } from './user-service';
import type { User } from './types';

// Type-safe mock with vi.hoisted
const mocks = vi.hoisted(() => ({
  fetchUser: vi.fn<[string], Promise<User | null>>(),
}));

vi.mock('./api', () => ({
  fetchUser: mocks.fetchUser,
}));

describe('UserService', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('getUser', () => {
    it('returns user when found', async () => {
      // Arrange
      mocks.fetchUser.mockResolvedValue({
        id: '1',
        name: 'Alice',
        email: 'alice@example.com',
      });

      // Act
      const service = new UserService();
      const user = await service.getUser('1');

      // Assert
      expect(user).toMatchObject({ name: 'Alice' });
      expect(mocks.fetchUser).toHaveBeenCalledWith('1');
    });

    it('returns null when user not found', async () => {
      mocks.fetchUser.mockResolvedValue(null);

      const service = new UserService();
      const user = await service.getUser('invalid');

      expect(user).toBeNull();
    });

    it('throws on network error', async () => {
      mocks.fetchUser.mockRejectedValue(new Error('Network failed'));

      const service = new UserService();

      await expect(service.getUser('1')).rejects.toThrow('Network failed');
    });
  });
});
```

## Type Testing (2025 Standard)

```typescript
// user.test-d.ts - Type-only tests
import { expectTypeOf } from 'vitest';
import type { User, CreateUserInput, UserId } from './types';
import { createUser } from './user';

// Test type relationships
expectTypeOf<CreateUserInput>().toMatchTypeOf<Omit<User, 'id'>>();

// Test branded types are distinct
expectTypeOf<UserId>().not.toMatchTypeOf<string>();

// Test function return types
expectTypeOf(createUser).returns.toMatchTypeOf<Promise<User>>();

// Test type inference
const user = { id: '1', name: 'Alice' };
expectTypeOf(user).toEqualTypeOf<{ id: string; name: string }>();
expectTypeOf(user.id).toBeString();
```

## Testing Zod Schemas

```typescript
import { describe, it, expect } from 'vitest';
import { z } from 'zod';

const UserSchema = z.object({
  id: z.string().uuid(),
  name: z.string().min(1),
  email: z.string().email(),
  age: z.number().int().positive().optional(),
});

describe('UserSchema', () => {
  it('validates correct user data', () => {
    const validUser = {
      id: '123e4567-e89b-12d3-a456-426614174000',
      name: 'John Doe',
      email: 'john@example.com',
      age: 30,
    };

    expect(() => UserSchema.parse(validUser)).not.toThrow();
  });

  it('rejects invalid email', () => {
    const invalidUser = {
      id: '123e4567-e89b-12d3-a456-426614174000',
      name: 'John Doe',
      email: 'not-an-email',
    };

    expect(() => UserSchema.parse(invalidUser)).toThrow(z.ZodError);
  });

  it('rejects invalid UUID', () => {
    const invalidUser = {
      id: 'not-a-uuid',
      name: 'John Doe',
      email: 'john@example.com',
    };

    expect(() => UserSchema.parse(invalidUser)).toThrow(z.ZodError);
  });
});
```

## Common Commands (2025)

```bash
# Run all tests (watch mode by default)
pnpm exec vitest

# Run tests once
pnpm exec vitest run

# UI mode (visual testing interface)
pnpm exec vitest --ui

# Type checking
pnpm exec vitest --typecheck

# Run specific test file
pnpm exec vitest user.test.ts

# Run with coverage
pnpm exec vitest run --coverage

# All in one: tests + types + coverage
pnpm exec vitest run --typecheck --coverage

# Run only changed files
pnpm exec vitest --changed

# Filter by test name
pnpm exec vitest -t "creates user"

# Debug mode
pnpm exec vitest --reporter=verbose
```

## Vitest Configuration (2025)

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    // Explicit imports - 2025 best practice (no globals)
    globals: false,

    // Environment
    environment: 'node',

    // Setup files
    setupFiles: ['./tests/setup.ts'],

    // Include patterns
    include: [
      'src/**/*.test.ts',
      'tests/**/*.test.ts',
    ],

    // Type testing
    typecheck: {
      enabled: true,
      tsconfig: './tsconfig.json',
      include: ['**/*.test-d.ts'],
    },

    // Coverage
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html', 'lcov'],
      exclude: [
        '**/*.test.ts',
        '**/*.test-d.ts',
        '**/node_modules/**',
        '**/dist/**',
      ],
      thresholds: {
        branches: 80,
        functions: 80,
        lines: 80,
        statements: 80,
      },
    },
  },
});
```

## Testing Patterns

### Unit Tests (70% of test suite)
- Test individual functions/classes in isolation
- Mock external dependencies
- Focus on business logic
- Fast execution (<10ms each)

### Integration Tests (20% of test suite)
- Test component interactions
- Use real dependencies (test DB, services)
- Test API endpoints with supertest
- Moderate speed (10ms-1s per test)

### E2E Tests (10% of test suite)
- Test complete user workflows
- Most expensive to maintain
- Critical paths only

### Type Tests (Additional layer)
- Test type inference behavior
- Use `*.test-d.ts` files
- No runtime cost

## Best Practices Summary

### Do's
- **Explicit imports**: `import { describe, it, expect, vi } from 'vitest'`
- **AAA pattern**: Arrange, Act, Assert
- **Descriptive names**: `it('throws ValidationError when email is invalid')`
- **Type-safe mocks**: Use generic parameters
- **Clear mocks**: `vi.clearAllMocks()` in beforeEach
- **Test both paths**: Success and failure scenarios

### Don'ts
- **Don't use globals**: Always import test functions
- **Don't over-mock**: Mock external deps only
- **Don't skip type tests**: Test type behavior
- **Don't use `any`**: Keep tests type-safe
- **Don't test implementation**: Test behavior

## Reference Files

- **[test-organization.md](references/test-organization.md)**: Testing pyramid (70/20/10), directory structure, Vitest config, CI/CD
- **[tdd-workflow.md](references/tdd-workflow.md)**: Red-Green-Refactor cycle, TDD patterns, agent checklists
- **[mocking-patterns.md](references/mocking-patterns.md)**: vi.fn, vi.mock, vi.spyOn, type-safe mocking
- **[async-testing.md](references/async-testing.md)**: Async/await, Promise assertions, fake timers
- **[external-sources.md](references/external-sources.md)**: Curated external documentation links

Load references as needed based on the testing task at hand.

## When to Use This Skill

- Writing new tests with Vitest and TypeScript 5.7+
- Type testing with `expectTypeOf`
- Debugging failing tests in watch or UI mode
- Setting up modern test infrastructure (ESM, explicit imports)
- Implementing type-safe mocks and stubs
- Testing async code with proper error handling
- Testing React/Vue components with Testing Library
- Testing zod schemas and runtime validation
- Testing branded types and discriminated unions
- Setting up CI/CD with type checking + tests + coverage
- Practicing TDD workflow for new features and bug fixes
