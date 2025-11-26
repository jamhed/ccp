---
name: jest-tester
description: Testing expert for TypeScript with Jest - mature test runner, snapshot testing, extensive ecosystem, mocking with jest.fn/jest.mock, TDD workflows. Use when: working with existing Jest projects; writing or reviewing tests; implementing mocks and fixtures; debugging test failures; practicing TDD/BDD.
---

# Jest Testing Expert (2025)

Expert assistant for writing comprehensive, type-safe tests with Jest for TypeScript projects. Jest remains a solid choice for projects with existing Jest infrastructure or specific ecosystem requirements.

## Core Capabilities

### 1. Test Framework - Jest

**Why Jest**:
- **Mature & Stable**: Battle-tested, extensive documentation
- **Rich Ecosystem**: Large plugin ecosystem, wide community support
- **Snapshot Testing**: First-class snapshot testing support
- **All-in-One**: Built-in assertions, mocking, coverage
- **Widely Adopted**: Many projects use Jest, good for maintenance

**When to Choose Jest over Vitest**:
- Existing Jest codebase (migration cost not worth it)
- Need specific Jest plugins not available in Vitest
- Team familiarity with Jest
- Projects requiring Jest-specific features

**Key Principles**:
- **Explicit imports**: Import `describe`, `it`, `expect` from `@jest/globals`
- **Type-safe mocking**: Use `jest.fn<>()` with type parameters
- **ESM support**: Use `--experimental-vm-modules` for ESM (or stick to CJS)

**Reference**: [references/test-organization.md](references/test-organization.md)

### 2. Test-Driven Development (TDD)

When implementing features or fixing bugs:
- **Red**: Write failing test first (defines expected behavior)
- **Green**: Write minimal code to pass
- **Refactor**: Improve code quality while tests pass

**Use TDD for**: Complex logic, bug fixes, new features, zod schemas

**Reference**: [references/tdd-workflow.md](references/tdd-workflow.md)

### 3. Mocking and Test Isolation

When mocking dependencies:
- **Mock external dependencies**: HTTP, DB, filesystem, time, external APIs
- **Don't mock internal code**: Test real integrations where possible
- **Type-safe mocks**: `jest.fn<ReturnType, Args>()` for type safety
- **Use jest.mock()**: For module-level mocking

**Reference**: [references/mocking-patterns.md](references/mocking-patterns.md)

### 4. Async Testing

When testing async code:
- Use async/await in test functions
- Use `.resolves/.rejects` for Promise assertions
- Use `jest.useFakeTimers()` for delays and timeouts
- Test both success and error paths

**Reference**: [references/async-testing.md](references/async-testing.md)

## Quick Start Example

```typescript
// user.test.ts - Jest test file with explicit imports
import { describe, it, expect, jest, beforeEach } from '@jest/globals';
import { UserService } from './user-service';
import type { User } from './types';

// Mock the module
jest.mock('./api');

import { fetchUser } from './api';
const mockFetchUser = fetchUser as jest.MockedFunction<typeof fetchUser>;

describe('UserService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('getUser', () => {
    it('returns user when found', async () => {
      // Arrange
      mockFetchUser.mockResolvedValue({
        id: '1',
        name: 'Alice',
        email: 'alice@example.com',
      });

      // Act
      const service = new UserService();
      const user = await service.getUser('1');

      // Assert
      expect(user).toMatchObject({ name: 'Alice' });
      expect(mockFetchUser).toHaveBeenCalledWith('1');
    });

    it('returns null when user not found', async () => {
      mockFetchUser.mockResolvedValue(null);

      const service = new UserService();
      const user = await service.getUser('invalid');

      expect(user).toBeNull();
    });

    it('throws on network error', async () => {
      mockFetchUser.mockRejectedValue(new Error('Network failed'));

      const service = new UserService();

      await expect(service.getUser('1')).rejects.toThrow('Network failed');
    });
  });
});
```

## Testing Zod Schemas

```typescript
import { describe, it, expect } from '@jest/globals';
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

## Common Commands

```bash
# Run all tests
npm test

# Run tests in watch mode
npm test -- --watch

# Run specific test file
npm test -- user.test.ts

# Run with coverage
npm test -- --coverage

# Run tests matching pattern
npm test -- -t "creates user"

# Update snapshots
npm test -- -u

# Run in CI mode (no watch)
npm test -- --ci

# Verbose output
npm test -- --verbose
```

## Jest Configuration (TypeScript)

```javascript
// jest.config.js
/** @type {import('jest').Config} */
module.exports = {
  // TypeScript support
  preset: 'ts-jest',

  // Or use SWC for faster transforms
  // transform: {
  //   '^.+\\.(t|j)sx?$': '@swc/jest',
  // },

  // Test environment
  testEnvironment: 'node',

  // Setup files
  setupFilesAfterEnv: ['<rootDir>/tests/setup.ts'],

  // Test patterns
  testMatch: [
    '**/__tests__/**/*.test.ts',
    '**/*.test.ts',
  ],

  // Module resolution
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
  },

  // Coverage
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/**/*.d.ts',
    '!src/**/*.test.ts',
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },

  // Clear mocks between tests
  clearMocks: true,
};
```

### ESM Configuration (Experimental)

```javascript
// jest.config.js for ESM
/** @type {import('jest').Config} */
module.exports = {
  preset: 'ts-jest/presets/default-esm',
  testEnvironment: 'node',
  extensionsToTreatAsEsm: ['.ts'],
  moduleNameMapper: {
    '^(\\.{1,2}/.*)\\.js$': '$1',
  },
  transform: {
    '^.+\\.tsx?$': [
      'ts-jest',
      {
        useESM: true,
      },
    ],
  },
};
```

Run with: `NODE_OPTIONS='--experimental-vm-modules' npx jest`

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

## Snapshot Testing

```typescript
import { describe, it, expect } from '@jest/globals';

describe('Component', () => {
  it('matches snapshot', () => {
    const output = renderComponent({ name: 'Alice' });
    expect(output).toMatchSnapshot();
  });

  it('matches inline snapshot', () => {
    const user = { id: '1', name: 'Alice' };
    expect(user).toMatchInlineSnapshot(`
      {
        "id": "1",
        "name": "Alice",
      }
    `);
  });
});
```

## Best Practices Summary

### Do's
- **Explicit imports**: `import { describe, it, expect } from '@jest/globals'`
- **AAA pattern**: Arrange, Act, Assert
- **Descriptive names**: `it('throws ValidationError when email is invalid')`
- **Type-safe mocks**: Use generic parameters
- **Clear mocks**: `jest.clearAllMocks()` in beforeEach
- **Test both paths**: Success and failure scenarios

### Don'ts
- **Don't rely on globals**: Always import test functions
- **Don't over-mock**: Mock external deps only
- **Don't use `any`**: Keep tests type-safe
- **Don't test implementation**: Test behavior
- **Don't skip error cases**: Test failure paths

## Reference Files

- **[test-organization.md](references/test-organization.md)**: Testing pyramid (70/20/10), directory structure, Jest config, CI/CD
- **[tdd-workflow.md](references/tdd-workflow.md)**: Red-Green-Refactor cycle, TDD patterns, agent checklists
- **[mocking-patterns.md](references/mocking-patterns.md)**: jest.fn, jest.mock, jest.spyOn, type-safe mocking
- **[async-testing.md](references/async-testing.md)**: Async/await, Promise assertions, fake timers
- **[external-sources.md](references/external-sources.md)**: Curated external documentation links

Load references as needed based on the testing task at hand.

## When to Use This Skill

- Working with existing Jest codebases
- Writing tests for projects using Jest
- Snapshot testing requirements
- Debugging failing Jest tests
- Setting up Jest test infrastructure
- Implementing mocks with jest.fn/jest.mock
- Testing async code with Jest
- Testing zod schemas and runtime validation
- Setting up CI/CD with Jest coverage
- Practicing TDD workflow with Jest
