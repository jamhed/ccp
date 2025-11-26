# Mocking Patterns and Test Doubles (2025)

Comprehensive guide to mocking in TypeScript tests using Vitest's `vi` utilities, type-safe mocking patterns, and test doubles.

## Agent Quick Reference: When to Mock

**Decision Tree**:
```
What are you testing?
├─ HTTP/API call? → MOCK (use vi.fn or msw)
├─ Database operation? → DON'T MOCK (use test database)
├─ File I/O? → MOCK (use vi.mock)
├─ Time/random? → MOCK (use vi.useFakeTimers)
├─ External service? → MOCK (use vi.fn)
├─ Internal business logic? → DON'T MOCK (test directly)
└─ Your own classes? → DON'T MOCK (refactor or use real instances)
```

**Agent Instructions**:
1. **MOCK** external dependencies only (APIs, external services, time)
2. **DON'T MOCK** internal code (business logic, your classes)
3. **USE** type-safe mocks with generic parameters
4. **USE** vi.hoisted() for mock references in vi.mock()
5. **USE** vi.spyOn() sparingly (prefer full mocks or real objects)
6. **RESET** mocks between tests with vi.clearAllMocks()

**Golden Rule for Agents**: If you own the code, don't mock it. Test it directly.

## Agent Quick Reference: vi.fn vs vi.mock vs vi.spyOn

| What You're Mocking | Use This | Example |
|---------------------|----------|---------|
| Function argument | `vi.fn()` | `const callback = vi.fn()` |
| Module export | `vi.mock()` | `vi.mock('./module')` |
| Object method | `vi.spyOn()` | `vi.spyOn(obj, 'method')` |
| HTTP requests | `vi.fn()` or MSW | Mock fetch/axios |
| Timers | `vi.useFakeTimers()` | Control time |

## Test Doubles Overview

### Types of Test Doubles

**Mock**: Records calls and verifies interactions
- Used to verify that methods were called
- Can assert call count, arguments, order

**Stub**: Returns predefined responses
- Used to provide controlled data
- Doesn't verify calls, just returns values

**Fake**: Working implementation (simplified)
- Real implementation with shortcuts (e.g., in-memory DB)
- More complex than mocks/stubs

**Spy**: Records calls while delegating to real object
- Wraps real object
- Records interactions for verification

## vi.fn() - Creating Mock Functions

### Basic Usage

```typescript
import { describe, it, expect, vi } from 'vitest';

describe('vi.fn basics', () => {
  it('creates a mock function', () => {
    const mock = vi.fn();
    mock('arg1', 'arg2');

    expect(mock).toHaveBeenCalled();
    expect(mock).toHaveBeenCalledWith('arg1', 'arg2');
    expect(mock).toHaveBeenCalledTimes(1);
  });
});
```

### Type-Safe Mock Functions (2025 Best Practice)

```typescript
import { vi } from 'vitest';

// Type-safe mock with return type
const mockFn = vi.fn<[string, number], boolean>();
mockFn.mockReturnValue(true);

// Type-safe mock from function type
type UserFetcher = (id: string) => Promise<User>;
const mockFetch = vi.fn<Parameters<UserFetcher>, ReturnType<UserFetcher>>();
mockFetch.mockResolvedValue({ id: '1', name: 'Alice' });

// Using MockedFunction type
import type { MockedFunction } from 'vitest';

const realFn = (x: number) => x * 2;
const mockedFn: MockedFunction<typeof realFn> = vi.fn();
mockedFn.mockReturnValue(42);
```

### Return Values

```typescript
import { vi } from 'vitest';

// Return specific value
const mock = vi.fn().mockReturnValue(42);
expect(mock()).toBe(42);

// Return promise
const asyncMock = vi.fn().mockResolvedValue({ data: 'value' });
expect(await asyncMock()).toEqual({ data: 'value' });

// Return rejected promise
const failingMock = vi.fn().mockRejectedValue(new Error('Failed'));
await expect(failingMock()).rejects.toThrow('Failed');

// Return different values on successive calls
const multiMock = vi.fn()
  .mockReturnValueOnce(1)
  .mockReturnValueOnce(2)
  .mockReturnValue(99);

expect(multiMock()).toBe(1);  // First call
expect(multiMock()).toBe(2);  // Second call
expect(multiMock()).toBe(99); // Subsequent calls
```

### Implementation Mock

```typescript
import { vi } from 'vitest';

// Custom implementation
const mock = vi.fn().mockImplementation((a: number, b: number) => a + b);
expect(mock(2, 3)).toBe(5);

// One-time implementation
const onceMock = vi.fn()
  .mockImplementationOnce(() => 'first')
  .mockImplementationOnce(() => 'second');

expect(onceMock()).toBe('first');
expect(onceMock()).toBe('second');
expect(onceMock()).toBeUndefined();
```

## vi.mock() - Module Mocking

### Basic Module Mock

```typescript
import { vi, describe, it, expect } from 'vitest';

// Mock must be hoisted - use vi.mock at top level
vi.mock('./userService', () => ({
  getUser: vi.fn().mockResolvedValue({ id: '1', name: 'Alice' }),
  createUser: vi.fn().mockResolvedValue({ id: '2', name: 'Bob' }),
}));

import { getUser, createUser } from './userService';

describe('with mocked userService', () => {
  it('uses mocked getUser', async () => {
    const user = await getUser('1');
    expect(user.name).toBe('Alice');
  });
});
```

### Using vi.hoisted() for Mock References

```typescript
import { vi, describe, it, expect, beforeEach } from 'vitest';

// Use vi.hoisted() to create mock references accessible in tests
const mocks = vi.hoisted(() => ({
  getUser: vi.fn(),
  createUser: vi.fn(),
}));

vi.mock('./userService', () => ({
  getUser: mocks.getUser,
  createUser: mocks.createUser,
}));

import { getUser, createUser } from './userService';

describe('with hoisted mocks', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('can configure mock in test', async () => {
    mocks.getUser.mockResolvedValue({ id: '1', name: 'Alice' });

    const user = await getUser('1');
    expect(user.name).toBe('Alice');
    expect(mocks.getUser).toHaveBeenCalledWith('1');
  });

  it('can use different mock values', async () => {
    mocks.getUser.mockResolvedValue({ id: '2', name: 'Bob' });

    const user = await getUser('2');
    expect(user.name).toBe('Bob');
  });
});
```

### Partial Module Mock (importOriginal)

```typescript
import { vi } from 'vitest';

vi.mock('./utils', async (importOriginal) => {
  const actual = await importOriginal<typeof import('./utils')>();
  return {
    ...actual,
    // Only mock specific exports
    formatDate: vi.fn().mockReturnValue('2025-01-01'),
    // Keep others as-is
  };
});
```

### Default Export Mock

```typescript
import { vi } from 'vitest';

// Default export requires special handling
vi.mock('./config', () => ({
  default: {
    apiUrl: 'http://test.api.com',
    timeout: 1000,
  },
}));

import config from './config';
// config.apiUrl === 'http://test.api.com'
```

### Class Mock

```typescript
import { vi } from 'vitest';

vi.mock('./Database', () => ({
  Database: vi.fn().mockImplementation(() => ({
    connect: vi.fn().mockResolvedValue(true),
    query: vi.fn().mockResolvedValue([]),
    close: vi.fn(),
  })),
}));

import { Database } from './Database';

describe('with mocked Database', () => {
  it('creates mock instance', () => {
    const db = new Database();
    expect(db.connect).toBeDefined();
    expect(db.query).toBeDefined();
  });
});
```

## vi.spyOn() - Spy on Methods

### Basic Spy Usage

```typescript
import { vi, describe, it, expect } from 'vitest';

const calculator = {
  add: (a: number, b: number) => a + b,
  multiply: (a: number, b: number) => a * b,
};

describe('vi.spyOn', () => {
  it('spies on method calls', () => {
    const spy = vi.spyOn(calculator, 'add');

    const result = calculator.add(2, 3);

    expect(result).toBe(5);  // Real implementation called
    expect(spy).toHaveBeenCalledWith(2, 3);
    expect(spy).toHaveBeenCalledTimes(1);
  });

  it('can mock implementation', () => {
    const spy = vi.spyOn(calculator, 'add').mockReturnValue(100);

    const result = calculator.add(2, 3);

    expect(result).toBe(100);  // Mocked return value
    expect(spy).toHaveBeenCalledWith(2, 3);
  });
});
```

### When to Use vi.spyOn

**Best Practice for Agents**:
- Prefer `vi.mock()` for module-level mocking
- Use `vi.spyOn()` when you need the real implementation but want to verify calls
- Use `vi.fn()` for callbacks and function arguments

## Mocking External Dependencies

### Mocking HTTP Requests (fetch)

```typescript
import { vi, describe, it, expect, beforeEach } from 'vitest';

describe('API client', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('fetches user data', async () => {
    const mockResponse = {
      ok: true,
      json: vi.fn().mockResolvedValue({ id: '1', name: 'Alice' }),
    };
    global.fetch = vi.fn().mockResolvedValue(mockResponse);

    const response = await fetch('/api/users/1');
    const user = await response.json();

    expect(fetch).toHaveBeenCalledWith('/api/users/1');
    expect(user.name).toBe('Alice');
  });

  it('handles fetch errors', async () => {
    global.fetch = vi.fn().mockRejectedValue(new Error('Network error'));

    await expect(fetch('/api/users/1')).rejects.toThrow('Network error');
  });
});
```

### Mocking Axios

```typescript
import { vi } from 'vitest';
import axios from 'axios';

vi.mock('axios');
const mockedAxios = vi.mocked(axios);

describe('with mocked axios', () => {
  it('makes GET request', async () => {
    mockedAxios.get.mockResolvedValue({
      data: { users: [{ id: '1', name: 'Alice' }] },
    });

    const response = await axios.get('/api/users');

    expect(response.data.users).toHaveLength(1);
    expect(mockedAxios.get).toHaveBeenCalledWith('/api/users');
  });
});
```

### Mocking Timers

```typescript
import { vi, describe, it, expect, beforeEach, afterEach } from 'vitest';

describe('timer functions', () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('tests setTimeout', () => {
    const callback = vi.fn();
    setTimeout(callback, 1000);

    expect(callback).not.toHaveBeenCalled();

    vi.advanceTimersByTime(1000);

    expect(callback).toHaveBeenCalledTimes(1);
  });

  it('tests setInterval', () => {
    const callback = vi.fn();
    setInterval(callback, 1000);

    vi.advanceTimersByTime(3000);

    expect(callback).toHaveBeenCalledTimes(3);
  });

  it('runs all pending timers', () => {
    const callback = vi.fn();
    setTimeout(callback, 5000);
    setTimeout(callback, 10000);

    vi.runAllTimers();

    expect(callback).toHaveBeenCalledTimes(2);
  });
});
```

### Mocking Date

```typescript
import { vi, describe, it, expect, beforeEach, afterEach } from 'vitest';

describe('date functions', () => {
  beforeEach(() => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date('2025-01-15T10:00:00Z'));
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('uses mocked date', () => {
    const now = new Date();

    expect(now.getFullYear()).toBe(2025);
    expect(now.getMonth()).toBe(0);  // January
    expect(now.getDate()).toBe(15);
  });

  it('advances time', () => {
    vi.advanceTimersByTime(24 * 60 * 60 * 1000);  // 1 day

    const now = new Date();
    expect(now.getDate()).toBe(16);
  });
});
```

### Mocking Environment Variables

```typescript
import { vi, describe, it, expect, beforeEach, afterEach } from 'vitest';

describe('environment variables', () => {
  const originalEnv = process.env;

  beforeEach(() => {
    vi.resetModules();
    process.env = { ...originalEnv };
  });

  afterEach(() => {
    process.env = originalEnv;
  });

  it('uses mocked env var', () => {
    process.env.API_URL = 'http://test.api.com';

    expect(process.env.API_URL).toBe('http://test.api.com');
  });
});
```

## Type-Safe Mocking Patterns

### Mocking with Correct Types

```typescript
import { vi } from 'vitest';
import type { User, UserService } from './types';

// Type-safe mock service
const mockUserService: UserService = {
  getUser: vi.fn<[string], Promise<User | null>>()
    .mockResolvedValue({ id: '1', name: 'Alice', email: 'alice@example.com' }),

  createUser: vi.fn<[Omit<User, 'id'>], Promise<User>>()
    .mockImplementation(async (data) => ({
      id: 'new-id',
      ...data,
    })),

  deleteUser: vi.fn<[string], Promise<boolean>>()
    .mockResolvedValue(true),
};

// TypeScript will error if mock doesn't match interface
```

### Using vi.mocked() for Type Inference

```typescript
import { vi } from 'vitest';
import { getUser } from './userService';

vi.mock('./userService');

// vi.mocked adds proper mock types
const mockedGetUser = vi.mocked(getUser);

mockedGetUser.mockResolvedValue({
  id: '1',
  name: 'Alice',
  email: 'alice@example.com',
});

// TypeScript knows mockedGetUser is MockedFunction
mockedGetUser.mockClear();
mockedGetUser.mockReset();
```

## Mocking Best Practices

### Do's

1. **Mock external dependencies only**
```typescript
// GOOD - Mock external API
vi.mock('axios');

// BAD - Don't mock internal business logic
vi.mock('./calculateTotal'); // Test the real calculation instead
```

2. **Use type-safe mocks**
```typescript
// GOOD
const mock = vi.fn<[string], number>().mockReturnValue(42);

// BAD - No type safety
const mock = vi.fn().mockReturnValue(42);
```

3. **Clear mocks between tests**
```typescript
beforeEach(() => {
  vi.clearAllMocks();
});
```

4. **Use vi.hoisted() with vi.mock()**
```typescript
const mocks = vi.hoisted(() => ({
  fetchData: vi.fn(),
}));

vi.mock('./api', () => ({
  fetchData: mocks.fetchData,
}));
```

### Don'ts

1. **Don't over-mock**
```typescript
// BAD - Mocking everything defeats the test
vi.mock('./service1');
vi.mock('./service2');
vi.mock('./service3');
vi.mock('./service4');
// Not testing anything real
```

2. **Don't mock what you own**
```typescript
// BAD - Mocking internal functions
vi.mock('./utils/helpers');

// GOOD - Mock external dependencies only
vi.mock('axios');
```

3. **Don't create brittle mocks**
```typescript
// BAD - Tied to implementation details
expect(mock).toHaveBeenCalledWith(
  expect.objectContaining({
    _internalFlag: true,
    _privateOption: 'value',
  })
);

// GOOD - Test behavior, not implementation
expect(result).toEqual({ status: 'success' });
```

4. **Don't use mocks for value objects**
```typescript
// BAD - Mocking simple objects
const mockUser = { name: 'Alice' } as User;

// GOOD - Use real value objects
const user: User = { id: '1', name: 'Alice', email: 'alice@example.com' };
```

## Common Patterns

### Mock Method Call Chain

```typescript
// Mock chained calls: service.get().process().result()
const mock = {
  get: vi.fn().mockReturnThis(),
  process: vi.fn().mockReturnThis(),
  result: vi.fn().mockReturnValue(42),
};

const result = mock.get().process().result();
expect(result).toBe(42);
```

### Mock with Side Effects

```typescript
import { vi } from 'vitest';

// Retry logic test
const mockApi = vi.fn()
  .mockRejectedValueOnce(new Error('Connection failed'))
  .mockRejectedValueOnce(new Error('Connection failed'))
  .mockResolvedValue({ status: 'success' });

// First two calls fail, third succeeds
await expect(mockApi()).rejects.toThrow('Connection failed');
await expect(mockApi()).rejects.toThrow('Connection failed');
await expect(mockApi()).resolves.toEqual({ status: 'success' });

expect(mockApi).toHaveBeenCalledTimes(3);
```

### Mock Assertions

```typescript
import { vi, expect } from 'vitest';

const mock = vi.fn();
mock('arg1', 'arg2');
mock('arg3');

// Call assertions
expect(mock).toHaveBeenCalled();
expect(mock).toHaveBeenCalledTimes(2);
expect(mock).toHaveBeenCalledWith('arg1', 'arg2');
expect(mock).toHaveBeenLastCalledWith('arg3');
expect(mock).toHaveBeenNthCalledWith(1, 'arg1', 'arg2');

// Access call information
expect(mock.mock.calls).toHaveLength(2);
expect(mock.mock.calls[0]).toEqual(['arg1', 'arg2']);
expect(mock.mock.lastCall).toEqual(['arg3']);
```

## When NOT to Mock

**Don't mock**:
- Pure functions (test them directly)
- Internal business logic
- Simple value objects
- Your own classes (refactor for testability instead)
- Libraries you trust (integration test instead)

**Do mock**:
- External APIs
- Databases (or use test database)
- File systems
- Network calls
- Time/random functions
- Third-party services

## Agent Implementation Checklist

When using mocks in tests, verify:

**Mock Selection**:
- [ ] Using vi.fn() for function mocks
- [ ] Using vi.mock() for module mocks
- [ ] Using vi.spyOn() only when real implementation needed
- [ ] Not mocking internal business logic

**Type Safety**:
- [ ] Mocks have correct type parameters
- [ ] Using vi.mocked() for type inference
- [ ] No `any` types in mock code

**Mock Configuration**:
- [ ] mockReturnValue/mockResolvedValue set correctly
- [ ] mockRejectedValue for error cases
- [ ] vi.hoisted() used with vi.mock()

**Cleanup**:
- [ ] vi.clearAllMocks() in beforeEach
- [ ] vi.useRealTimers() in afterEach (if using fake timers)
- [ ] Mocks reset between tests

**Assertions**:
- [ ] Using appropriate assertions (toHaveBeenCalled, toHaveBeenCalledWith, etc.)
- [ ] Verifying call arguments correctly
- [ ] Not over-asserting implementation details

## Summary

### Key Principles

1. Mock external dependencies, not internal code
2. Use type-safe mocks with generic parameters
3. Clear mocks between tests
4. Use vi.hoisted() with vi.mock()
5. Prefer real objects over mocks when possible
6. Test behavior, not implementation

### Tools Summary

| Tool | Use Case |
|------|----------|
| `vi.fn()` | Create mock function |
| `vi.mock()` | Mock module exports |
| `vi.spyOn()` | Spy on object methods |
| `vi.mocked()` | Add mock types to function |
| `vi.hoisted()` | Create references for vi.mock |
| `vi.useFakeTimers()` | Mock time |
| `vi.clearAllMocks()` | Reset all mocks |

## Resources

For external documentation and references, see [external-sources.md](external-sources.md).
