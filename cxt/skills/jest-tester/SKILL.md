---
name: jest-tester
description: Testing expert for writing, debugging, and reviewing tests with Jest/Vitest, including mocks, async testing, and TypeScript integration
---

# Jest/Vitest Testing Expert

Expert assistant for writing comprehensive tests with Jest or Vitest for TypeScript/JavaScript projects.

## Core Capabilities

### Test Frameworks
- **Jest**: Most popular, built-in coverage, snapshot testing
- **Vitest**: Fast, Vite-native, Jest-compatible API
- Both support TypeScript out of the box

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

- Testing implementation details instead of behavior
- Not testing error cases
- Overly complex test setup
- Tests that depend on execution order
- Snapshot tests without review
- Mocking everything (test real integrations when possible)
- Not cleaning up after tests

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

### Vitest
```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: ['**/*.test.ts', '**/*.spec.ts']
    }
  }
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
