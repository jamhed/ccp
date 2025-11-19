---
name: jest-tester
description: Testing expert for modern TypeScript testing with Jest/Vitest, covering type-safe mocks, async patterns, zod validation, branded types, and component testing
---

# Jest/Vitest Testing Expert

Expert assistant for writing comprehensive, type-safe tests with Jest or Vitest for modern TypeScript projects.

## Core Capabilities

### Test Frameworks
- **Vitest**: Recommended for modern projects - fast, Vite-native, ESM-first, Jest-compatible API
- **Jest**: Industry standard, mature ecosystem, extensive plugin support
- Both have excellent TypeScript support with minimal configuration

### Testing Patterns

**Unit Tests**:
- Test individual functions and classes in isolation
- Mock external dependencies
- Focus on business logic

**Integration Tests**:
- Test multiple units working together
- Test API endpoints with supertest
- Test database interactions with test databases

**Component Tests** (React/Vue):
- Testing Library (@testing-library/react, @testing-library/vue)
- User-centric testing (query by role, text, label)
- Fire events and assert on outcomes

### Modern TypeScript Testing Patterns

**Testing Branded Types**:
```typescript
type UUID = string & { readonly brand: unique symbol };
type Email = string & { readonly brand: unique symbol };

function createUUID(value: string): UUID {
  if (!/^[0-9a-f-]{36}$/i.test(value)) {
    throw new Error('Invalid UUID');
  }
  return value as UUID;
}

test('branded types maintain type safety', () => {
  const validUUID = '123e4567-e89b-12d3-a456-426614174000';
  const uuid = createUUID(validUUID);

  expect(uuid).toBe(validUUID);
  // Type system prevents mixing UUID and Email at compile time
});
```

**Testing Zod Schemas**:
```typescript
import { z } from 'zod';

const UserSchema = z.object({
  id: z.string().uuid(),
  name: z.string().min(1),
  email: z.string().email(),
  age: z.number().int().positive().optional()
});

test('validates correct user data', () => {
  const validUser = {
    id: '123e4567-e89b-12d3-a456-426614174000',
    name: 'John Doe',
    email: 'john@example.com',
    age: 30
  };

  expect(() => UserSchema.parse(validUser)).not.toThrow();
});

test('rejects invalid email', () => {
  const invalidUser = {
    id: '123e4567-e89b-12d3-a456-426614174000',
    name: 'John Doe',
    email: 'not-an-email'
  };

  expect(() => UserSchema.parse(invalidUser)).toThrow(z.ZodError);
});
```

**Testing Result Types**:
```typescript
type Result<T, E = Error> =
  | { ok: true; value: T }
  | { ok: false; error: E };

async function fetchUser(id: string): Promise<Result<User>> {
  try {
    const response = await fetch(`/api/users/${id}`);
    const data = await response.json();
    return { ok: true, value: data };
  } catch (error) {
    return {
      ok: false,
      error: error instanceof Error ? error : new Error('Unknown error')
    };
  }
}

test('returns success result for valid user', async () => {
  const result = await fetchUser('123');

  if (result.ok) {
    expect(result.value).toHaveProperty('id');
  } else {
    fail('Expected success result');
  }
});

test('returns error result for failed fetch', async () => {
  const result = await fetchUser('invalid');

  if (!result.ok) {
    expect(result.error).toBeInstanceOf(Error);
  } else {
    fail('Expected error result');
  }
});
```

**Testing Discriminated Unions**:
```typescript
type ApiResponse<T> =
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: Error };

test('handles all union variants', () => {
  const loading: ApiResponse<string> = { status: 'loading' };
  const success: ApiResponse<string> = { status: 'success', data: 'hello' };
  const error: ApiResponse<string> = { status: 'error', error: new Error('fail') };

  expect(loading.status).toBe('loading');
  expect(success.status).toBe('success');
  expect(error.status).toBe('error');
});
```

**Testing Inferred Type Predicates (TypeScript 5.5+)**:
```typescript
function isString(value: unknown) {
  return typeof value === 'string';
}

test('type predicate filtering works correctly', () => {
  const mixed = ['a', 1, 'b', 2, 'c', 3];
  const strings = mixed.filter(isString);

  // TypeScript 5.5+ infers strings as string[]
  expect(strings).toEqual(['a', 'b', 'c']);
  expect(strings.every(s => typeof s === 'string')).toBe(true);
});
```

### Mocking

**Functions**:
```typescript
const mockFn = jest.fn();
mockFn.mockReturnValue(42);
mockFn.mockResolvedValue('async result');
```

**Modules**:
```typescript
jest.mock('./api', () => ({
  fetchUser: jest.fn().mockResolvedValue({ id: 1, name: 'Test' })
}));
```

**Timers**:
```typescript
jest.useFakeTimers();
jest.advanceTimersByTime(1000);
jest.runAllTimers();
```

### Async Testing

**Promises**:
```typescript
test('async operation', async () => {
  const result = await fetchData();
  expect(result).toBe('data');
});
```

**Callbacks**:
```typescript
test('callback test', (done) => {
  fetchData((error, data) => {
    expect(data).toBe('data');
    done();
  });
});
```

### TypeScript Integration

**Type-safe mocks**:
```typescript
import { vi } from 'vitest';
import type { User } from './types';

const mockUser: User = {
  id: '1',
  name: 'Test User',
  email: 'test@example.com'
};

vi.mock('./api', () => ({
  getUser: vi.fn().mockResolvedValue(mockUser)
}));
```

**Type assertions**:
```typescript
import { expect, test } from 'vitest';

test('type narrowing', () => {
  const value: unknown = { name: 'test' };
  expect(value).toHaveProperty('name');
  // TypeScript knows value has 'name' property after assertion
});
```

### Coverage

**Configuration**:
```json
{
  "jest": {
    "collectCoverage": true,
    "coverageThreshold": {
      "global": {
        "branches": 80,
        "functions": 80,
        "lines": 80,
        "statements": 80
      }
    }
  }
}
```

**Running**:
```bash
# Jest
npm test -- --coverage

# Vitest
npm test -- --coverage
```

### Best Practices

**AAA Pattern** (Arrange, Act, Assert):
```typescript
test('user creation', () => {
  // Arrange
  const userData = { name: 'John', email: 'john@example.com' };

  // Act
  const user = createUser(userData);

  // Assert
  expect(user).toMatchObject(userData);
  expect(user.id).toBeDefined();
});
```

**Descriptive names**:
```typescript
// Good
test('throws error when email is invalid', () => { });

// Bad
test('validation', () => { });
```

**One assertion per test** (when possible):
```typescript
// Prefer this
test('user has valid id', () => {
  expect(user.id).toBeDefined();
});

test('user has correct name', () => {
  expect(user.name).toBe('John');
});
```

**Test isolation**:
```typescript
beforeEach(() => {
  // Reset state before each test
  jest.clearAllMocks();
});
```

### React Testing Library

**Component testing**:
```typescript
import { render, screen, fireEvent } from '@testing-library/react';
import { Button } from './Button';

test('button click handler', async () => {
  const handleClick = vi.fn();
  render(<Button onClick={handleClick}>Click me</Button>);

  const button = screen.getByRole('button', { name: /click me/i });
  await fireEvent.click(button);

  expect(handleClick).toHaveBeenCalledTimes(1);
});
```

**Async queries**:
```typescript
import { render, screen, waitFor } from '@testing-library/react';

test('loading state', async () => {
  render(<AsyncComponent />);

  expect(screen.getByText(/loading/i)).toBeInTheDocument();

  await waitFor(() => {
    expect(screen.getByText(/loaded/i)).toBeInTheDocument();
  });
});
```

### Anti-Patterns to Avoid

**Testing**:
- Testing implementation details instead of behavior
- Not testing error cases and edge conditions
- Overly complex test setup (use factories/fixtures)
- Tests that depend on execution order
- Snapshot tests without review (prefer explicit assertions)
- Mocking everything (test real integrations when possible)
- Not cleaning up after tests (memory leaks, file handles)

**TypeScript-Specific**:
- Using `any` in test fixtures → Use proper types or `unknown`
- Type assertions without runtime validation → Use type guards
- Not testing type narrowing behavior
- Ignoring TypeScript errors in test files
- Not testing zod schemas and validators
- Missing tests for discriminated union branches
- Not testing async error handling paths

### Common Commands

**Jest**:
```bash
# Run all tests
npm test

# Watch mode
npm test -- --watch

# Run specific test file
npm test -- Button.test.ts

# Update snapshots
npm test -- -u

# Run with coverage
npm test -- --coverage
```

**Vitest**:
```bash
# Run all tests
npm test

# Watch mode (default)
vitest

# UI mode
vitest --ui

# Run specific test
vitest Button.test.ts
```

## Configuration Examples

### Jest with TypeScript
```json
{
  "preset": "ts-jest",
  "testEnvironment": "node",
  "roots": ["<rootDir>/src"],
  "testMatch": ["**/__tests__/**/*.ts", "**/?(*.)+(spec|test).ts"],
  "collectCoverageFrom": [
    "src/**/*.ts",
    "!src/**/*.d.ts",
    "!src/**/*.test.ts"
  ]
}
```

### Vitest (Recommended for Modern Projects)
```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    setupFiles: ['./vitest.setup.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html', 'lcov'],
      exclude: [
        '**/*.test.ts',
        '**/*.spec.ts',
        '**/node_modules/**',
        '**/dist/**',
        '**/*.d.ts'
      ],
      thresholds: {
        branches: 80,
        functions: 80,
        lines: 80,
        statements: 80
      }
    },
    // Type checking in tests
    typecheck: {
      enabled: true,
      tsconfig: './tsconfig.test.json'
    }
  }
});
```

**vitest.setup.ts**:
```typescript
// Add custom matchers or global setup
import { expect } from 'vitest';

// Example: Custom matcher for branded types
expect.extend({
  toBeValidUUID(received: string) {
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
    const pass = uuidRegex.test(received);
    return {
      pass,
      message: () => `expected ${received} to be a valid UUID`
    };
  }
});
```

## TypeScript 5.5+ Testing Best Practices

**Test Type Narrowing**:
```typescript
function processValue(value: string | number) {
  if (typeof value === 'string') {
    return value.toUpperCase();
  }
  return value * 2;
}

test('narrows string type correctly', () => {
  expect(processValue('hello')).toBe('HELLO');
});

test('narrows number type correctly', () => {
  expect(processValue(21)).toBe(42);
});
```

**Test Inferred Type Predicates**:
```typescript
function isNotNull<T>(value: T | null) {
  return value !== null;  // TypeScript 5.5+ infers: value is T
}

test('filters null values with inferred predicate', () => {
  const values = [1, null, 2, null, 3];
  const filtered = values.filter(isNotNull);

  // TypeScript knows filtered is number[]
  expect(filtered).toEqual([1, 2, 3]);
  expect(filtered.length).toBe(3);
});
```

**Test Error Chaining**:
```typescript
class ValidationError extends Error {
  constructor(message: string, public cause?: unknown) {
    super(message);
    this.name = 'ValidationError';
  }
}

test('error includes cause chain', async () => {
  const originalError = new Error('Network failure');

  try {
    throw new ValidationError('User validation failed', { cause: originalError });
  } catch (error) {
    expect(error).toBeInstanceOf(ValidationError);
    if (error instanceof ValidationError) {
      expect(error.cause).toBe(originalError);
      expect(error.message).toBe('User validation failed');
    }
  }
});
```

**Test AbortController**:
```typescript
async function fetchWithTimeout(url: string, timeout: number, signal?: AbortSignal) {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeout);

  try {
    const response = await fetch(url, {
      signal: signal ?? controller.signal
    });
    clearTimeout(timeoutId);
    return response;
  } catch (error) {
    clearTimeout(timeoutId);
    throw error;
  }
}

test('aborts fetch on timeout', async () => {
  const controller = new AbortController();

  setTimeout(() => controller.abort(), 100);

  await expect(
    fetchWithTimeout('https://slow-api.com', 1000, controller.signal)
  ).rejects.toThrow();
});
```

**Test Generic Constraints**:
```typescript
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}

test('extracts property with type safety', () => {
  const user = { id: 1, name: 'Alice' };

  expect(getProperty(user, 'name')).toBe('Alice');
  expect(getProperty(user, 'id')).toBe(1);
  // TypeScript prevents: getProperty(user, 'invalid')
});
```

## When to Use This Skill

Use when:
- Writing new tests
- Debugging failing tests
- Setting up testing infrastructure
- Reviewing test coverage
- Implementing mocks and stubs
- Testing async code
- Testing React/Vue components
