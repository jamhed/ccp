# Async/Await Patterns in TypeScript

Comprehensive guide to asynchronous programming in TypeScript using async/await with Promises, including modern patterns and best practices for 2025.

**For TypeScript syntax and features**, see [modern-typescript-2025.md](modern-typescript-2025.md). This document focuses on async/await patterns, best practices, and production-ready code.

## Async Basics

### Async Functions

```typescript
// Async function definition
async function fetchData(url: string): Promise<Record<string, unknown>> {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`HTTP ${response.status}: ${response.statusText}`);
  }
  return response.json();
}

// Arrow function syntax
const fetchUser = async (id: string): Promise<User> => {
  const response = await fetch(`/api/users/${id}`);
  return response.json();
};

// Method syntax
class ApiClient {
  async get<T>(url: string): Promise<T> {
    const response = await fetch(url);
    return response.json();
  }
}
```

### Async vs Sync

```typescript
// DON'T: Blocking patterns in async context
async function badPattern(): Promise<string> {
  // These block and defeat the purpose of async
  const result = someSyncHeavyComputation();  // Blocks event loop
  return result;
}

// DO: Keep async code non-blocking
async function goodPattern(): Promise<string> {
  // I/O operations are naturally async
  const response = await fetch('/api/data');
  const data = await response.json();
  return data.result;
}

// DO: Offload heavy computation
async function computeHeavy(data: number[]): Promise<number> {
  // For heavy computation, consider Web Workers or worker threads
  return new Promise((resolve) => {
    // Simulate async computation
    setTimeout(() => {
      const result = data.reduce((a, b) => a + b, 0);
      resolve(result);
    }, 0);
  });
}
```

## Concurrent Execution

### Promise.all()

```typescript
// Run multiple operations concurrently
async function fetchMultiple(urls: string[]): Promise<Response[]> {
  const promises = urls.map(url => fetch(url));
  const responses = await Promise.all(promises);
  return responses;
}

// With data transformation
async function fetchUsers(ids: string[]): Promise<User[]> {
  const users = await Promise.all(
    ids.map(async (id) => {
      const response = await fetch(`/api/users/${id}`);
      return response.json();
    })
  );
  return users;
}

// Parallel API calls
async function getDashboardData(userId: string): Promise<DashboardData> {
  const [user, posts, notifications] = await Promise.all([
    fetchUser(userId),
    fetchUserPosts(userId),
    fetchNotifications(userId),
  ]);

  return { user, posts, notifications };
}
```

### Promise.allSettled()

```typescript
// Handle partial failures gracefully
async function fetchWithPartialFailures(urls: string[]): Promise<Array<Response | null>> {
  const results = await Promise.allSettled(
    urls.map(url => fetch(url))
  );

  return results.map((result, index) => {
    if (result.status === 'fulfilled') {
      return result.value;
    } else {
      console.error(`Failed to fetch ${urls[index]}:`, result.reason);
      return null;
    }
  });
}

// Collect successes and failures separately
interface FetchResults<T> {
  successes: T[];
  failures: Array<{ url: string; error: Error }>;
}

async function fetchAllWithReport(urls: string[]): Promise<FetchResults<Response>> {
  const results = await Promise.allSettled(
    urls.map(url => fetch(url))
  );

  const successes: Response[] = [];
  const failures: Array<{ url: string; error: Error }> = [];

  results.forEach((result, index) => {
    if (result.status === 'fulfilled') {
      successes.push(result.value);
    } else {
      failures.push({
        url: urls[index],
        error: result.reason instanceof Error ? result.reason : new Error(String(result.reason)),
      });
    }
  });

  return { successes, failures };
}
```

### Promise.race()

```typescript
// First to complete wins
async function fetchWithFallback(primaryUrl: string, fallbackUrl: string): Promise<Response> {
  return Promise.race([
    fetch(primaryUrl),
    fetch(fallbackUrl),
  ]);
}

// Timeout pattern with race
async function fetchWithTimeout(url: string, timeoutMs: number): Promise<Response> {
  const timeoutPromise = new Promise<never>((_, reject) => {
    setTimeout(() => reject(new Error('Request timed out')), timeoutMs);
  });

  return Promise.race([fetch(url), timeoutPromise]);
}

// First successful (ignoring errors)
async function fetchFromFastestServer(urls: string[]): Promise<Response> {
  return Promise.race(urls.map(url => fetch(url)));
}
```

### Promise.any()

```typescript
// First successful promise (ignores rejections until all fail)
async function fetchFromAnySource(urls: string[]): Promise<Response> {
  try {
    return await Promise.any(urls.map(url => fetch(url)));
  } catch (error) {
    if (error instanceof AggregateError) {
      console.error('All fetches failed:', error.errors);
    }
    throw error;
  }
}

// Fallback chain
async function fetchWithFallbacks(urls: string[]): Promise<string> {
  const response = await Promise.any(
    urls.map(async (url) => {
      const response = await fetch(url);
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }
      return response.text();
    })
  );
  return response;
}
```

## Timeouts and Cancellation

### AbortController

```typescript
// Basic abort controller usage
async function fetchWithAbort(url: string, timeoutMs: number): Promise<Response> {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeoutMs);

  try {
    const response = await fetch(url, { signal: controller.signal });
    return response;
  } finally {
    clearTimeout(timeoutId);
  }
}

// Reusable timeout wrapper
function withTimeout<T>(
  promise: Promise<T>,
  timeoutMs: number,
  errorMessage = 'Operation timed out'
): Promise<T> {
  return new Promise((resolve, reject) => {
    const timeoutId = setTimeout(() => {
      reject(new Error(errorMessage));
    }, timeoutMs);

    promise
      .then((result) => {
        clearTimeout(timeoutId);
        resolve(result);
      })
      .catch((error) => {
        clearTimeout(timeoutId);
        reject(error);
      });
  });
}

// Usage
const data = await withTimeout(fetchData('/api/data'), 5000, 'Fetch timed out');

// Cancellable operation class
class CancellableOperation<T> {
  private controller = new AbortController();

  constructor(private operation: (signal: AbortSignal) => Promise<T>) {}

  async execute(): Promise<T> {
    return this.operation(this.controller.signal);
  }

  cancel(): void {
    this.controller.abort();
  }

  get signal(): AbortSignal {
    return this.controller.signal;
  }
}

// Usage
const op = new CancellableOperation(async (signal) => {
  const response = await fetch('/api/data', { signal });
  return response.json();
});

// Cancel after 5 seconds
setTimeout(() => op.cancel(), 5000);

try {
  const data = await op.execute();
} catch (error) {
  if (error instanceof Error && error.name === 'AbortError') {
    console.log('Operation was cancelled');
  }
}
```

### Timeout Utilities

```typescript
// Sleep function
function sleep(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}

// Delay with value
function delay<T>(ms: number, value: T): Promise<T> {
  return new Promise(resolve => setTimeout(() => resolve(value), ms));
}

// Debounce async function
function debounceAsync<T extends (...args: unknown[]) => Promise<unknown>>(
  fn: T,
  ms: number
): T {
  let timeoutId: ReturnType<typeof setTimeout> | undefined;

  return ((...args: Parameters<T>) => {
    return new Promise((resolve, reject) => {
      if (timeoutId) {
        clearTimeout(timeoutId);
      }

      timeoutId = setTimeout(async () => {
        try {
          const result = await fn(...args);
          resolve(result);
        } catch (error) {
          reject(error);
        }
      }, ms);
    });
  }) as T;
}
```

## Error Handling

### Try/Catch Patterns

```typescript
// Basic error handling
async function fetchUser(id: string): Promise<User> {
  try {
    const response = await fetch(`/api/users/${id}`);
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }
    return response.json();
  } catch (error) {
    if (error instanceof Error) {
      throw new Error(`Failed to fetch user ${id}: ${error.message}`, { cause: error });
    }
    throw error;
  }
}

// Multiple error types
class NetworkError extends Error {
  constructor(message: string, options?: ErrorOptions) {
    super(message, options);
    this.name = 'NetworkError';
  }
}

class ValidationError extends Error {
  constructor(message: string, public readonly field: string, options?: ErrorOptions) {
    super(message, options);
    this.name = 'ValidationError';
  }
}

async function processData(url: string): Promise<ProcessedData> {
  try {
    const response = await fetch(url);
    const data = await response.json();
    return validateAndProcess(data);
  } catch (error) {
    if (error instanceof TypeError) {
      throw new NetworkError('Network request failed', { cause: error });
    }
    if (error instanceof SyntaxError) {
      throw new ValidationError('Invalid JSON response', 'body', { cause: error });
    }
    throw error;
  }
}
```

### Retry Patterns

```typescript
// Simple retry with exponential backoff
async function retryWithBackoff<T>(
  operation: () => Promise<T>,
  maxRetries: number = 3,
  baseDelayMs: number = 1000
): Promise<T> {
  let lastError: Error | undefined;

  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      return await operation();
    } catch (error) {
      lastError = error instanceof Error ? error : new Error(String(error));

      if (attempt < maxRetries - 1) {
        const delay = baseDelayMs * Math.pow(2, attempt);
        await sleep(delay);
      }
    }
  }

  throw new Error(`Operation failed after ${maxRetries} attempts`, { cause: lastError });
}

// Configurable retry
interface RetryOptions {
  maxRetries: number;
  baseDelayMs: number;
  maxDelayMs: number;
  shouldRetry?: (error: Error) => boolean;
  onRetry?: (attempt: number, error: Error) => void;
}

async function retry<T>(
  operation: () => Promise<T>,
  options: RetryOptions
): Promise<T> {
  const {
    maxRetries,
    baseDelayMs,
    maxDelayMs,
    shouldRetry = () => true,
    onRetry,
  } = options;

  let lastError: Error | undefined;

  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      return await operation();
    } catch (error) {
      lastError = error instanceof Error ? error : new Error(String(error));

      if (!shouldRetry(lastError)) {
        throw lastError;
      }

      if (attempt < maxRetries - 1) {
        onRetry?.(attempt + 1, lastError);
        const delay = Math.min(baseDelayMs * Math.pow(2, attempt), maxDelayMs);
        await sleep(delay);
      }
    }
  }

  throw new Error(`Operation failed after ${maxRetries} attempts`, { cause: lastError });
}

// Usage
const data = await retry(
  () => fetchData('/api/data'),
  {
    maxRetries: 5,
    baseDelayMs: 1000,
    maxDelayMs: 30000,
    shouldRetry: (error) => error.message.includes('timeout'),
    onRetry: (attempt, error) => console.log(`Retry ${attempt}: ${error.message}`),
  }
);
```

## Synchronization Patterns

### Mutex/Lock Pattern

```typescript
// Simple async mutex
class Mutex {
  private locked = false;
  private queue: Array<() => void> = [];

  async acquire(): Promise<void> {
    return new Promise((resolve) => {
      if (!this.locked) {
        this.locked = true;
        resolve();
      } else {
        this.queue.push(resolve);
      }
    });
  }

  release(): void {
    if (this.queue.length > 0) {
      const next = this.queue.shift()!;
      next();
    } else {
      this.locked = false;
    }
  }

  async withLock<T>(fn: () => Promise<T>): Promise<T> {
    await this.acquire();
    try {
      return await fn();
    } finally {
      this.release();
    }
  }
}

// Usage
const mutex = new Mutex();

async function criticalSection(): Promise<void> {
  await mutex.withLock(async () => {
    // Only one execution at a time
    await someSharedResourceOperation();
  });
}
```

### Semaphore Pattern

```typescript
// Limit concurrent operations
class Semaphore {
  private permits: number;
  private queue: Array<() => void> = [];

  constructor(permits: number) {
    this.permits = permits;
  }

  async acquire(): Promise<void> {
    return new Promise((resolve) => {
      if (this.permits > 0) {
        this.permits--;
        resolve();
      } else {
        this.queue.push(resolve);
      }
    });
  }

  release(): void {
    if (this.queue.length > 0) {
      const next = this.queue.shift()!;
      next();
    } else {
      this.permits++;
    }
  }

  async withPermit<T>(fn: () => Promise<T>): Promise<T> {
    await this.acquire();
    try {
      return await fn();
    } finally {
      this.release();
    }
  }
}

// Limit concurrent HTTP requests
async function fetchWithConcurrencyLimit<T>(
  urls: string[],
  maxConcurrent: number,
  fetcher: (url: string) => Promise<T>
): Promise<T[]> {
  const semaphore = new Semaphore(maxConcurrent);

  return Promise.all(
    urls.map(url =>
      semaphore.withPermit(() => fetcher(url))
    )
  );
}

// Usage
const results = await fetchWithConcurrencyLimit(
  urls,
  5,  // Max 5 concurrent requests
  async (url) => {
    const response = await fetch(url);
    return response.json();
  }
);
```

### Queue Pattern

```typescript
// Async queue with concurrency control
class AsyncQueue<T, R> {
  private queue: T[] = [];
  private processing = 0;
  private readonly maxConcurrent: number;
  private readonly processor: (item: T) => Promise<R>;
  private results: Map<T, R> = new Map();
  private resolvers: Map<T, (result: R) => void> = new Map();

  constructor(processor: (item: T) => Promise<R>, maxConcurrent = 1) {
    this.processor = processor;
    this.maxConcurrent = maxConcurrent;
  }

  async push(item: T): Promise<R> {
    return new Promise((resolve) => {
      this.resolvers.set(item, resolve);
      this.queue.push(item);
      this.process();
    });
  }

  private async process(): Promise<void> {
    while (this.queue.length > 0 && this.processing < this.maxConcurrent) {
      const item = this.queue.shift()!;
      this.processing++;

      try {
        const result = await this.processor(item);
        this.results.set(item, result);
        this.resolvers.get(item)?.(result);
      } finally {
        this.processing--;
        this.process();
      }
    }
  }
}

// Usage
const queue = new AsyncQueue(
  async (url: string) => {
    const response = await fetch(url);
    return response.json();
  },
  3  // Process 3 at a time
);

const results = await Promise.all(
  urls.map(url => queue.push(url))
);
```

## Common Patterns

### Rate Limiting

```typescript
// Token bucket rate limiter
class RateLimiter {
  private tokens: number;
  private lastRefill: number;
  private readonly maxTokens: number;
  private readonly refillRateMs: number;

  constructor(maxTokens: number, refillRateMs: number) {
    this.maxTokens = maxTokens;
    this.tokens = maxTokens;
    this.refillRateMs = refillRateMs;
    this.lastRefill = Date.now();
  }

  private refill(): void {
    const now = Date.now();
    const elapsed = now - this.lastRefill;
    const tokensToAdd = Math.floor(elapsed / this.refillRateMs);

    if (tokensToAdd > 0) {
      this.tokens = Math.min(this.maxTokens, this.tokens + tokensToAdd);
      this.lastRefill = now;
    }
  }

  async acquire(): Promise<void> {
    this.refill();

    if (this.tokens > 0) {
      this.tokens--;
      return;
    }

    // Wait for next token
    const waitTime = this.refillRateMs - (Date.now() - this.lastRefill);
    await sleep(waitTime);
    return this.acquire();
  }

  async withLimit<T>(fn: () => Promise<T>): Promise<T> {
    await this.acquire();
    return fn();
  }
}

// Usage: 10 requests per second
const limiter = new RateLimiter(10, 100);

async function rateLimitedFetch(url: string): Promise<Response> {
  return limiter.withLimit(() => fetch(url));
}
```

### Batch Processing

```typescript
// Process items in batches
async function processBatch<T, R>(
  items: T[],
  batchSize: number,
  processor: (batch: T[]) => Promise<R[]>
): Promise<R[]> {
  const results: R[] = [];

  for (let i = 0; i < items.length; i += batchSize) {
    const batch = items.slice(i, i + batchSize);
    const batchResults = await processor(batch);
    results.push(...batchResults);
  }

  return results;
}

// With concurrency
async function processBatchConcurrent<T, R>(
  items: T[],
  batchSize: number,
  maxConcurrent: number,
  processor: (batch: T[]) => Promise<R[]>
): Promise<R[]> {
  const batches: T[][] = [];
  for (let i = 0; i < items.length; i += batchSize) {
    batches.push(items.slice(i, i + batchSize));
  }

  const semaphore = new Semaphore(maxConcurrent);
  const batchResults = await Promise.all(
    batches.map(batch =>
      semaphore.withPermit(() => processor(batch))
    )
  );

  return batchResults.flat();
}
```

### Polling Pattern

```typescript
// Poll until condition is met
async function pollUntil<T>(
  fn: () => Promise<T>,
  condition: (result: T) => boolean,
  options: {
    intervalMs: number;
    timeoutMs: number;
  }
): Promise<T> {
  const { intervalMs, timeoutMs } = options;
  const startTime = Date.now();

  while (Date.now() - startTime < timeoutMs) {
    const result = await fn();
    if (condition(result)) {
      return result;
    }
    await sleep(intervalMs);
  }

  throw new Error('Polling timed out');
}

// Usage
const status = await pollUntil(
  () => checkJobStatus(jobId),
  (status) => status === 'completed' || status === 'failed',
  { intervalMs: 1000, timeoutMs: 60000 }
);

// With exponential backoff
async function pollWithBackoff<T>(
  fn: () => Promise<T>,
  condition: (result: T) => boolean,
  options: {
    initialIntervalMs: number;
    maxIntervalMs: number;
    timeoutMs: number;
  }
): Promise<T> {
  const { initialIntervalMs, maxIntervalMs, timeoutMs } = options;
  const startTime = Date.now();
  let interval = initialIntervalMs;

  while (Date.now() - startTime < timeoutMs) {
    const result = await fn();
    if (condition(result)) {
      return result;
    }
    await sleep(interval);
    interval = Math.min(interval * 2, maxIntervalMs);
  }

  throw new Error('Polling timed out');
}
```

## Best Practices

### 1. Always Handle Errors

```typescript
// DON'T: Unhandled promise rejection
async function bad(): Promise<void> {
  fetchData('/api');  // Missing await, error silently lost
}

// DO: Handle all async errors
async function good(): Promise<void> {
  try {
    await fetchData('/api');
  } catch (error) {
    console.error('Fetch failed:', error);
    throw error;  // Re-throw or handle appropriately
  }
}
```

### 2. Use Promise.all for Parallel Operations

```typescript
// DON'T: Sequential when parallel is possible
async function sequential(): Promise<[User, Posts, Settings]> {
  const user = await fetchUser();
  const posts = await fetchPosts();  // Waits for user unnecessarily
  const settings = await fetchSettings();  // Waits for posts unnecessarily
  return [user, posts, settings];
}

// DO: Parallel when operations are independent
async function parallel(): Promise<[User, Posts, Settings]> {
  const [user, posts, settings] = await Promise.all([
    fetchUser(),
    fetchPosts(),
    fetchSettings(),
  ]);
  return [user, posts, settings];
}
```

### 3. Handle Cancellation

```typescript
// DO: Support cancellation for long operations
async function fetchWithCancellation(
  url: string,
  signal?: AbortSignal
): Promise<Response> {
  const response = await fetch(url, { signal });
  return response;
}

// Check signal in loops
async function processItems(
  items: string[],
  signal?: AbortSignal
): Promise<void> {
  for (const item of items) {
    if (signal?.aborted) {
      throw new Error('Operation cancelled');
    }
    await processItem(item);
  }
}
```

### 4. Type Async Functions Properly

```typescript
// DO: Explicit return types for async functions
async function fetchUser(id: string): Promise<User> {
  const response = await fetch(`/api/users/${id}`);
  return response.json();
}

// DO: Use unknown for catch blocks
async function safeFetch(url: string): Promise<string | null> {
  try {
    const response = await fetch(url);
    return response.text();
  } catch (error: unknown) {
    if (error instanceof Error) {
      console.error(error.message);
    }
    return null;
  }
}
```

### 5. Limit Concurrency

```typescript
// DON'T: Unbounded concurrency
async function fetchAll(urls: string[]): Promise<Response[]> {
  return Promise.all(urls.map(url => fetch(url)));  // Could be 1000s of requests!
}

// DO: Limit concurrent operations
async function fetchAllLimited(urls: string[], maxConcurrent = 10): Promise<Response[]> {
  const semaphore = new Semaphore(maxConcurrent);
  return Promise.all(
    urls.map(url => semaphore.withPermit(() => fetch(url)))
  );
}
```

## Summary

**Essential Async Patterns**:
1. `Promise.all` for parallel independent operations
2. `Promise.allSettled` for partial failure handling
3. `AbortController` for cancellation
4. Retry with exponential backoff
5. Semaphore for concurrency limits
6. Rate limiting for API calls

**Best Practices**:
- Always await or handle promises
- Use proper error handling with typed errors
- Support cancellation with AbortController
- Limit concurrency to avoid resource exhaustion
- Type async functions explicitly
- Use `unknown` in catch blocks
