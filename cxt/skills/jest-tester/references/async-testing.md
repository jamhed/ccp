# Async Testing Patterns (2025)

Comprehensive guide to testing asynchronous TypeScript code with Vitest, including async/await patterns, Promise testing, and concurrent test execution.

## Agent Quick Reference: Async Testing

**Decision Tree for Async Tests**:
```
What are you testing?
├─ Async function (async/await)? → Use async test + await
├─ Promise-returning function? → Use async test or resolves/rejects
├─ Callback-based function? → Convert to Promise or use done callback
├─ Concurrent operations? → Use Promise.all in test
├─ Timeout behavior? → Use vi.useFakeTimers()
├─ AbortController? → Test abort signal handling
└─ Sync function? → Use regular test (no async)
```

**Agent Instructions**:
1. **ALWAYS** use async/await in test functions for async code
2. **USE** .resolves/.rejects for cleaner Promise assertions
3. **AVOID** mixing callbacks and Promises
4. **USE** vi.useFakeTimers() for testing timeouts/delays
5. **HANDLE** cleanup properly in afterEach
6. **TEST** both success and error paths

**Common Agent Mistakes to Avoid**:
- Forgetting `await` keyword
- Not handling rejected Promises
- Using `done` callback incorrectly
- Not cleaning up async resources
- Mixing sync and async assertion styles

## Basic Async Tests

### Using async/await

```typescript
import { describe, it, expect } from 'vitest';

describe('async functions', () => {
  it('awaits async function result', async () => {
    const result = await fetchUser('123');
    expect(result.name).toBe('Alice');
  });

  it('handles multiple awaits', async () => {
    const user = await fetchUser('123');
    const posts = await fetchPosts(user.id);
    expect(posts).toHaveLength(5);
  });
});
```

### Using .resolves/.rejects Matchers

```typescript
import { describe, it, expect } from 'vitest';

describe('Promise matchers', () => {
  it('uses resolves for successful Promise', async () => {
    await expect(fetchUser('123')).resolves.toMatchObject({
      id: '123',
      name: expect.any(String),
    });
  });

  it('uses rejects for rejected Promise', async () => {
    await expect(fetchUser('invalid')).rejects.toThrow('User not found');
  });

  it('chains with other matchers', async () => {
    await expect(fetchUsers()).resolves.toHaveLength(10);
    await expect(fetchUser('123')).resolves.toHaveProperty('email');
  });
});
```

### Testing Rejected Promises

```typescript
import { describe, it, expect } from 'vitest';

describe('error handling', () => {
  it('rejects with specific error', async () => {
    await expect(fetchUser('invalid'))
      .rejects.toThrow('User not found');
  });

  it('rejects with error type', async () => {
    await expect(fetchUser('invalid'))
      .rejects.toBeInstanceOf(NotFoundError);
  });

  it('catches rejection in try-catch', async () => {
    try {
      await fetchUser('invalid');
      expect.fail('Should have thrown');
    } catch (error) {
      expect(error).toBeInstanceOf(NotFoundError);
      expect((error as NotFoundError).message).toBe('User not found');
    }
  });
});
```

## Testing Timeouts and Delays

### Using Fake Timers

```typescript
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';

describe('timeout functions', () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it('tests debounced function', async () => {
    const callback = vi.fn();
    const debounced = debounce(callback, 1000);

    debounced();
    debounced();
    debounced();

    expect(callback).not.toHaveBeenCalled();

    await vi.advanceTimersByTimeAsync(1000);

    expect(callback).toHaveBeenCalledTimes(1);
  });

  it('tests delayed operation', async () => {
    const promise = delayedFetch('/api/data', 5000);

    // Fast-forward time
    await vi.advanceTimersByTimeAsync(5000);

    const result = await promise;
    expect(result).toBeDefined();
  });

  it('runs all pending timers', async () => {
    const callbacks = [vi.fn(), vi.fn(), vi.fn()];

    setTimeout(callbacks[0], 1000);
    setTimeout(callbacks[1], 2000);
    setTimeout(callbacks[2], 3000);

    await vi.runAllTimersAsync();

    callbacks.forEach(cb => expect(cb).toHaveBeenCalledTimes(1));
  });
});
```

### Testing Real Timeouts

```typescript
import { describe, it, expect } from 'vitest';

describe('real timeout tests', () => {
  it('completes within timeout', async () => {
    const start = Date.now();
    await quickOperation();
    const duration = Date.now() - start;

    expect(duration).toBeLessThan(100);
  }, 1000);  // Test timeout

  it('handles slow operation', async () => {
    // Long timeout for slow tests
    const result = await slowOperation();
    expect(result).toBeDefined();
  }, 10000);
});
```

## Testing AbortController

```typescript
import { describe, it, expect, vi } from 'vitest';

describe('AbortController', () => {
  it('aborts fetch request', async () => {
    const controller = new AbortController();

    const fetchPromise = fetchWithAbort('/api/data', {
      signal: controller.signal,
    });

    controller.abort();

    await expect(fetchPromise).rejects.toThrow('aborted');
  });

  it('completes before abort', async () => {
    const controller = new AbortController();

    const result = await fetchWithAbort('/api/quick', {
      signal: controller.signal,
    });

    expect(result).toBeDefined();
    // Aborting after completion has no effect
    controller.abort();
  });

  it('handles timeout with AbortController', async () => {
    vi.useFakeTimers();

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 5000);

    const fetchPromise = fetchWithAbort('/api/slow', {
      signal: controller.signal,
    });

    await vi.advanceTimersByTimeAsync(5000);

    await expect(fetchPromise).rejects.toThrow();

    clearTimeout(timeoutId);
    vi.useRealTimers();
  });
});
```

## Concurrent Testing

### Testing Concurrent Operations

```typescript
import { describe, it, expect } from 'vitest';

describe('concurrent operations', () => {
  it('runs operations in parallel', async () => {
    const start = Date.now();

    const [user1, user2, user3] = await Promise.all([
      fetchUser('1'),
      fetchUser('2'),
      fetchUser('3'),
    ]);

    const duration = Date.now() - start;

    expect(user1.id).toBe('1');
    expect(user2.id).toBe('2');
    expect(user3.id).toBe('3');

    // Should complete faster than sequential
    expect(duration).toBeLessThan(1000);
  });

  it('handles partial failures with allSettled', async () => {
    const results = await Promise.allSettled([
      fetchUser('1'),
      fetchUser('invalid'),
      fetchUser('3'),
    ]);

    expect(results[0].status).toBe('fulfilled');
    expect(results[1].status).toBe('rejected');
    expect(results[2].status).toBe('fulfilled');

    if (results[0].status === 'fulfilled') {
      expect(results[0].value.id).toBe('1');
    }
  });

  it('races multiple operations', async () => {
    const result = await Promise.race([
      fetchFromServer1(),
      fetchFromServer2(),
      fetchFromServer3(),
    ]);

    // First to complete wins
    expect(result).toBeDefined();
  });
});
```

### Testing with Promise.any

```typescript
import { describe, it, expect } from 'vitest';

describe('Promise.any', () => {
  it('returns first successful result', async () => {
    const result = await Promise.any([
      Promise.reject(new Error('Server 1 failed')),
      fetchFromServer2(),  // Succeeds
      Promise.reject(new Error('Server 3 failed')),
    ]);

    expect(result).toBeDefined();
  });

  it('throws AggregateError when all fail', async () => {
    await expect(Promise.any([
      Promise.reject(new Error('Failed 1')),
      Promise.reject(new Error('Failed 2')),
      Promise.reject(new Error('Failed 3')),
    ])).rejects.toBeInstanceOf(AggregateError);
  });
});
```

## Testing Async Iterators

```typescript
import { describe, it, expect } from 'vitest';

describe('async iterators', () => {
  it('iterates async generator', async () => {
    const results: number[] = [];

    async function* numberGenerator() {
      yield 1;
      yield 2;
      yield 3;
    }

    for await (const num of numberGenerator()) {
      results.push(num);
    }

    expect(results).toEqual([1, 2, 3]);
  });

  it('collects stream data', async () => {
    const chunks: string[] = [];

    for await (const chunk of createReadableStream()) {
      chunks.push(chunk);
    }

    expect(chunks.join('')).toBe('Hello, World!');
  });

  it('handles async iterator errors', async () => {
    async function* failingGenerator() {
      yield 1;
      throw new Error('Generator failed');
    }

    const results: number[] = [];

    await expect(async () => {
      for await (const num of failingGenerator()) {
        results.push(num);
      }
    }).rejects.toThrow('Generator failed');

    expect(results).toEqual([1]);
  });
});
```

## Testing Event Emitters

```typescript
import { describe, it, expect, vi } from 'vitest';
import { EventEmitter } from 'events';

describe('event emitters', () => {
  it('listens for events', async () => {
    const emitter = new EventEmitter();
    const handler = vi.fn();

    emitter.on('data', handler);
    emitter.emit('data', { value: 42 });

    expect(handler).toHaveBeenCalledWith({ value: 42 });
  });

  it('waits for event with Promise', async () => {
    const emitter = new EventEmitter();

    const eventPromise = new Promise<string>((resolve) => {
      emitter.once('message', resolve);
    });

    setTimeout(() => emitter.emit('message', 'Hello'), 100);

    const message = await eventPromise;
    expect(message).toBe('Hello');
  });

  it('handles multiple events', async () => {
    const emitter = new EventEmitter();
    const events: string[] = [];

    const collectEvents = new Promise<void>((resolve) => {
      emitter.on('item', (item) => {
        events.push(item);
        if (events.length === 3) resolve();
      });
    });

    emitter.emit('item', 'one');
    emitter.emit('item', 'two');
    emitter.emit('item', 'three');

    await collectEvents;
    expect(events).toEqual(['one', 'two', 'three']);
  });
});
```

## Testing Retries

```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest';

describe('retry logic', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('succeeds after retries', async () => {
    const mockFetch = vi.fn()
      .mockRejectedValueOnce(new Error('Attempt 1 failed'))
      .mockRejectedValueOnce(new Error('Attempt 2 failed'))
      .mockResolvedValue({ data: 'success' });

    const result = await retryWithBackoff(mockFetch, 3);

    expect(result.data).toBe('success');
    expect(mockFetch).toHaveBeenCalledTimes(3);
  });

  it('throws after max retries', async () => {
    const mockFetch = vi.fn()
      .mockRejectedValue(new Error('Always fails'));

    await expect(retryWithBackoff(mockFetch, 3))
      .rejects.toThrow('Max retries exceeded');

    expect(mockFetch).toHaveBeenCalledTimes(3);
  });

  it('respects backoff timing', async () => {
    vi.useFakeTimers();

    const mockFetch = vi.fn()
      .mockRejectedValueOnce(new Error('Fail 1'))
      .mockRejectedValueOnce(new Error('Fail 2'))
      .mockResolvedValue({ data: 'success' });

    const promise = retryWithExponentialBackoff(mockFetch, {
      maxRetries: 3,
      initialDelay: 1000,
    });

    // First attempt
    expect(mockFetch).toHaveBeenCalledTimes(1);

    // Wait for first backoff (1000ms)
    await vi.advanceTimersByTimeAsync(1000);
    expect(mockFetch).toHaveBeenCalledTimes(2);

    // Wait for second backoff (2000ms)
    await vi.advanceTimersByTimeAsync(2000);
    expect(mockFetch).toHaveBeenCalledTimes(3);

    const result = await promise;
    expect(result.data).toBe('success');

    vi.useRealTimers();
  });
});
```

## Testing WebSockets

```typescript
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';

describe('WebSocket', () => {
  let mockWebSocket: {
    send: ReturnType<typeof vi.fn>;
    close: ReturnType<typeof vi.fn>;
    onmessage?: (event: { data: string }) => void;
    onopen?: () => void;
    onerror?: (error: Error) => void;
    onclose?: () => void;
  };

  beforeEach(() => {
    mockWebSocket = {
      send: vi.fn(),
      close: vi.fn(),
    };

    vi.stubGlobal('WebSocket', vi.fn(() => mockWebSocket));
  });

  afterEach(() => {
    vi.unstubAllGlobals();
  });

  it('sends message over WebSocket', async () => {
    const client = new WebSocketClient('ws://example.com');

    // Simulate connection open
    mockWebSocket.onopen?.();

    client.send({ type: 'greeting', message: 'Hello' });

    expect(mockWebSocket.send).toHaveBeenCalledWith(
      JSON.stringify({ type: 'greeting', message: 'Hello' })
    );
  });

  it('receives messages', async () => {
    const client = new WebSocketClient('ws://example.com');
    const messageHandler = vi.fn();

    client.onMessage(messageHandler);
    mockWebSocket.onopen?.();

    // Simulate receiving message
    mockWebSocket.onmessage?.({
      data: JSON.stringify({ type: 'response', value: 42 }),
    });

    expect(messageHandler).toHaveBeenCalledWith({
      type: 'response',
      value: 42,
    });
  });
});
```

## Async Setup and Teardown

```typescript
import { describe, it, expect, beforeAll, afterAll, beforeEach, afterEach } from 'vitest';

describe('async setup/teardown', () => {
  let database: Database;
  let testUser: User;

  beforeAll(async () => {
    // One-time async setup
    database = await Database.connect(TEST_DB_URL);
    await database.migrate();
  });

  afterAll(async () => {
    // One-time async cleanup
    await database.close();
  });

  beforeEach(async () => {
    // Per-test setup
    testUser = await database.users.create({
      name: 'Test User',
      email: 'test@example.com',
    });
  });

  afterEach(async () => {
    // Per-test cleanup
    await database.users.deleteMany({});
  });

  it('reads user from database', async () => {
    const user = await database.users.findById(testUser.id);
    expect(user?.name).toBe('Test User');
  });
});
```

## Common Async Patterns

### Pattern 1: Testing Async Error Boundaries

```typescript
import { describe, it, expect } from 'vitest';

describe('async error boundaries', () => {
  it('handles async errors gracefully', async () => {
    const result = await safeAsyncOperation(async () => {
      throw new Error('Something went wrong');
    });

    expect(result.success).toBe(false);
    expect(result.error?.message).toBe('Something went wrong');
  });

  it('returns success for valid operations', async () => {
    const result = await safeAsyncOperation(async () => {
      return { data: 'value' };
    });

    expect(result.success).toBe(true);
    expect(result.data).toEqual({ data: 'value' });
  });
});
```

### Pattern 2: Testing Async Queues

```typescript
import { describe, it, expect, vi } from 'vitest';

describe('async queue', () => {
  it('processes items in order', async () => {
    const queue = new AsyncQueue<number>();
    const results: number[] = [];

    queue.onProcess(async (item) => {
      await delay(10);
      results.push(item);
    });

    queue.push(1);
    queue.push(2);
    queue.push(3);

    await queue.drain();

    expect(results).toEqual([1, 2, 3]);
  });

  it('handles concurrent processing', async () => {
    const queue = new AsyncQueue<number>({ concurrency: 2 });
    const processing: number[] = [];

    queue.onProcess(async (item) => {
      processing.push(item);
      await delay(100);
      processing.splice(processing.indexOf(item), 1);
    });

    queue.push(1);
    queue.push(2);
    queue.push(3);

    await delay(50);

    // Two items processing concurrently
    expect(processing).toHaveLength(2);
  });
});
```

### Pattern 3: Testing Race Conditions

```typescript
import { describe, it, expect, vi } from 'vitest';

describe('race conditions', () => {
  it('handles concurrent updates correctly', async () => {
    const counter = new AtomicCounter();

    // Simulate concurrent increments
    await Promise.all([
      counter.increment(),
      counter.increment(),
      counter.increment(),
    ]);

    expect(counter.value).toBe(3);
  });

  it('prevents stale data updates', async () => {
    const resource = new VersionedResource();

    // Fetch resource
    const v1 = await resource.get();

    // Another process updates it
    await resource.update({ value: 'updated' });

    // Our stale update should fail
    await expect(resource.update(v1, { value: 'stale' }))
      .rejects.toThrow('Version conflict');
  });
});
```

## Best Practices

### Do's

- Use async/await consistently
- Always await Promise assertions
- Use fake timers for testing delays
- Test both success and error paths
- Clean up resources in afterEach
- Use .resolves/.rejects for cleaner assertions

### Don'ts

- Don't forget await in async tests
- Don't mix done callback with async/await
- Don't leave pending Promises
- Don't use real timers for delay tests
- Don't ignore Promise rejections
- Don't have unbounded async loops in tests

## Agent Implementation Checklist

When implementing async tests, verify:

**Async/Await Usage**:
- [ ] All async tests use async function
- [ ] All Promise results are awaited
- [ ] Using .resolves/.rejects for Promise assertions
- [ ] No forgotten await keywords

**Error Handling**:
- [ ] Rejected Promises are tested
- [ ] Error types are verified
- [ ] Error messages are checked
- [ ] Using try-catch appropriately

**Timers**:
- [ ] vi.useFakeTimers() for delay tests
- [ ] vi.useRealTimers() in afterEach
- [ ] Using advanceTimersByTimeAsync for async timers

**Cleanup**:
- [ ] Resources cleaned in afterEach
- [ ] Pending timers cleared
- [ ] Event listeners removed
- [ ] Connections closed

**Concurrency**:
- [ ] Promise.all for parallel operations
- [ ] Promise.allSettled for partial failures
- [ ] Race conditions considered
- [ ] Proper test isolation

## Resources

For external documentation and references, see [external-sources.md](external-sources.md).
