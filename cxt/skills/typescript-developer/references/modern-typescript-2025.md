# Modern TypeScript Development (2025)

Practical guide to developing TypeScript applications using modern features from TypeScript 5.5+ through 5.8+.

## Core Modern Features to Use

### Type Hints - Use Everywhere

```typescript
// Modern union syntax
function process(value: number | string | null): Record<string, string | number> {
  return { value, type: typeof value };
}

// Generic types with constraints
function first<T>(items: T[]): T | undefined {
  return items[0];
}

// Branded types for type safety
type UserId = string & { readonly brand: unique symbol };
type Email = string & { readonly brand: unique symbol };

function createUserId(value: string): UserId {
  if (!value.match(/^user_[a-z0-9]+$/)) {
    throw new Error(`Invalid user ID: ${value}`);
  }
  return value as UserId;
}

// Template literal types
type EventName = `on${Capitalize<string>}`;
type HttpMethod = 'GET' | 'POST' | 'PUT' | 'DELETE';
type Endpoint = `/${string}`;
type Route = `${HttpMethod} ${Endpoint}`;
```

### The `satisfies` Operator - Game Changer (5.0+)

```typescript
// CRITICAL: Use satisfies for type validation without widening

// ❌ WRONG: Type annotation widens the type
const config: Record<string, string> = {
  apiUrl: 'https://api.example.com',
  timeout: '5000',
};
// config.apiUrl is string, not the literal type

// ✅ CORRECT: satisfies validates without widening
const config = {
  apiUrl: 'https://api.example.com',
  timeout: '5000',
} satisfies Record<string, string>;
// config.apiUrl is 'https://api.example.com' (literal type preserved)

// Use with zod for schema validation
import { z } from 'zod';

const UserSchema = z.object({
  id: z.string().uuid(),
  name: z.string().min(1),
  email: z.string().email(),
});

type User = z.infer<typeof UserSchema>;

const defaultUser = {
  id: '123e4567-e89b-12d3-a456-426614174000',
  name: 'Default User',
  email: 'default@example.com',
} satisfies User;

// Type narrowing with satisfies
type ColorMap = Record<string, [number, number, number]>;

const colors = {
  red: [255, 0, 0],
  green: [0, 255, 0],
  blue: [0, 0, 255],
} satisfies ColorMap;

// colors.red is [number, number, number], not number[]
const [r, g, b] = colors.red;  // Works perfectly
```

### Inferred Type Predicates (5.5+)

```typescript
// TypeScript 5.5+ automatically infers type predicates!

// No explicit ': value is string' needed
function isString(value: unknown) {
  return typeof value === 'string';
}

// Automatic narrowing in filter/find
const values = ['a', 1, 'b', 2].filter(isString);
// values is string[], not (string | number)[]

// Works with null checks too
function isNotNull<T>(value: T | null): value is T {
  return value !== null;
}

// Simplified with inference (5.5+):
function isNotNullInferred<T>(value: T | null) {
  return value !== null;  // Inferred: value is T
}

const items = [1, null, 2, null, 3].filter(isNotNullInferred);
// items: number[]

// Complex type guards
function isUser(value: unknown): value is User {
  return (
    typeof value === 'object' &&
    value !== null &&
    'id' in value &&
    'name' in value &&
    'email' in value
  );
}
```

### Control Flow Narrowing (5.5+)

```typescript
// TypeScript 5.5+ narrows obj[key] when both are constant
const obj = { a: 'hello', b: 42 } as const;
const key = 'a' as 'a' | 'b';

if (typeof obj[key] === 'string') {
  // obj[key] is now narrowed to string
  console.log(obj[key].toUpperCase());
}

// Works with discriminated unions
type Response =
  | { status: 'success'; data: string }
  | { status: 'error'; error: Error };

function handleResponse(response: Response) {
  if (response.status === 'success') {
    // response.data is available
    console.log(response.data);
  } else {
    // response.error is available
    console.error(response.error);
  }
}
```

### Discriminated Unions - For Complex Types

```typescript
// Always use discriminated unions for variant types
type ApiResponse<T> =
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: Error };

function handleResponse<T>(response: ApiResponse<T>): string {
  switch (response.status) {
    case 'loading':
      return 'Loading...';
    case 'success':
      return `Data: ${JSON.stringify(response.data)}`;
    case 'error':
      return `Error: ${response.error.message}`;
  }
}

// With exhaustive checking
function assertNever(x: never): never {
  throw new Error(`Unexpected value: ${x}`);
}

type Shape =
  | { kind: 'circle'; radius: number }
  | { kind: 'rectangle'; width: number; height: number }
  | { kind: 'triangle'; base: number; height: number };

function getArea(shape: Shape): number {
  switch (shape.kind) {
    case 'circle':
      return Math.PI * shape.radius ** 2;
    case 'rectangle':
      return shape.width * shape.height;
    case 'triangle':
      return (shape.base * shape.height) / 2;
    default:
      return assertNever(shape);  // Compile error if case missed
  }
}
```

### Runtime Validation with zod

```typescript
import { z } from 'zod';

// Define schema with runtime validation
const UserSchema = z.object({
  id: z.string().uuid(),
  name: z.string().min(1).max(100),
  email: z.string().email(),
  age: z.number().int().positive().optional(),
  role: z.enum(['admin', 'user', 'guest']),
  tags: z.array(z.string()).default([]),
  createdAt: z.date(),
});

// Infer type from schema
type User = z.infer<typeof UserSchema>;

// Validate external data
function validateUser(data: unknown): User {
  return UserSchema.parse(data);  // Throws ZodError if invalid
}

// Safe validation (returns result object)
function safeValidateUser(data: unknown): { success: true; data: User } | { success: false; error: z.ZodError } {
  const result = UserSchema.safeParse(data);
  return result;
}

// Branded types with zod
const UserIdSchema = z.string().uuid().brand<'UserId'>();
type UserId = z.infer<typeof UserIdSchema>;

const EmailSchema = z.string().email().brand<'Email'>();
type Email = z.infer<typeof EmailSchema>;

// Now UserId and Email are distinct types
function sendEmail(to: Email, subject: string): void {
  // Implementation
}

const userId = UserIdSchema.parse('123e4567-e89b-12d3-a456-426614174000');
const email = EmailSchema.parse('user@example.com');

// sendEmail(userId, 'Hello');  // ❌ Type error: UserId not assignable to Email
sendEmail(email, 'Hello');  // ✅ Works
```

### Async/Await - For I/O Operations

```typescript
// Basic async function
async function fetchData(url: string): Promise<Record<string, string>> {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`HTTP ${response.status}: ${response.statusText}`);
  }
  return response.json();
}

// Concurrent execution with Promise.all
async function fetchAll(urls: string[]): Promise<Record<string, string>[]> {
  return Promise.all(urls.map(url => fetchData(url)));
}

// With error handling for partial failures
async function fetchAllSettled(urls: string[]): Promise<Array<Record<string, string> | null>> {
  const results = await Promise.allSettled(urls.map(url => fetchData(url)));
  return results.map(result =>
    result.status === 'fulfilled' ? result.value : null
  );
}

// AbortController for cancellation
async function fetchWithTimeout(url: string, timeoutMs: number): Promise<Response> {
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeoutMs);

  try {
    const response = await fetch(url, { signal: controller.signal });
    return response;
  } finally {
    clearTimeout(timeoutId);
  }
}
```

**For comprehensive async patterns**, see [async-patterns.md](async-patterns.md):
- Promise.all, Promise.race, Promise.allSettled, Promise.any
- AbortController for cancellation
- Retry patterns with exponential backoff
- Concurrent execution limits
- Error handling and error chaining

### Error Handling - Specific and Explicit

```typescript
// Custom error classes with cause
class AppError extends Error {
  constructor(
    message: string,
    public readonly code: string,
    options?: ErrorOptions
  ) {
    super(message, options);
    this.name = 'AppError';
  }
}

class NotFoundError extends AppError {
  constructor(resource: string, id: string, options?: ErrorOptions) {
    super(`${resource} with id ${id} not found`, 'NOT_FOUND', options);
    this.name = 'NotFoundError';
  }
}

class ValidationError extends AppError {
  constructor(
    message: string,
    public readonly field: string,
    options?: ErrorOptions
  ) {
    super(message, 'VALIDATION_ERROR', options);
    this.name = 'ValidationError';
  }
}

// Error chaining with cause
async function getUser(id: string): Promise<User> {
  try {
    const response = await fetch(`/api/users/${id}`);
    if (!response.ok) {
      if (response.status === 404) {
        throw new NotFoundError('User', id);
      }
      throw new AppError(`HTTP ${response.status}`, 'HTTP_ERROR');
    }
    return response.json();
  } catch (error) {
    if (error instanceof AppError) {
      throw error;
    }
    throw new AppError('Failed to fetch user', 'FETCH_ERROR', { cause: error });
  }
}

// Handle unknown errors safely
function handleError(error: unknown): string {
  if (error instanceof ValidationError) {
    return `Validation error in ${error.field}: ${error.message}`;
  }
  if (error instanceof NotFoundError) {
    return `Not found: ${error.message}`;
  }
  if (error instanceof Error) {
    return `Error: ${error.message}`;
  }
  return `Unknown error: ${String(error)}`;
}
```

## TypeScript 5.7 Features (November 2024)

### Path Rewriting for ESM

```typescript
// Compiler option automatically rewrites .ts to .js extensions
// Essential for ESM compatibility in 2025

// tsconfig.json
{
  "compilerOptions": {
    "rewriteRelativeImportExtensions": true
  }
}

// Input: import { foo } from './module.ts';
// Output: import { foo } from './module.js';
```

### Uninitialized Variable Checks

```typescript
// Enhanced checks catch uninitialized variables in nested functions
function outer() {
  let x: string;

  function inner() {
    console.log(x);  // Error: Variable 'x' is used before being assigned
  }

  inner();
  x = 'hello';
}
```

### ES2024 Target Support

```typescript
// New APIs available with --target es2024
const numbers = [1, 2, 3, 4, 5, 6];

// Object.groupBy
const grouped = Object.groupBy(numbers, n => n % 2 === 0 ? 'even' : 'odd');
// { odd: [1, 3, 5], even: [2, 4, 6] }

// Map.groupBy
const groupedMap = Map.groupBy(numbers, n => n % 2 === 0 ? 'even' : 'odd');
```

### Performance Improvements

- ~15% faster compilation compared to 5.6
- 2.5x speedup in running `tsc --version` via caching APIs
- Node.js compile cache support for 2-3x faster builds

## TypeScript 5.8 Features (March 2025)

### Direct Execution Support

```typescript
// Node.js 23.6+ can run TypeScript directly
// with --experimental-strip-types

// Use --erasableSyntaxOnly for compatibility
// tsconfig.json
{
  "compilerOptions": {
    "erasableSyntaxOnly": true
  }
}

// TypeScript-specific syntax that has no runtime semantics works:
// - Type annotations
// - Interfaces
// - Type aliases
// - Generics

// Must avoid:
// - Enums (use const objects instead)
// - Namespaces
// - Parameter properties in constructors
```

### Enhanced Monorepo Support

```typescript
// Better tsconfig.json resolution for monorepos
// Searches parent directories for most suitable config
// Improved file association and IntelliSense accuracy

// Project structure:
// monorepo/
// ├── tsconfig.json (base config)
// ├── packages/
// │   ├── core/
// │   │   └── tsconfig.json (extends base)
// │   └── web/
// │       └── tsconfig.json (extends base)
```

### Performance (40% Improvement)

- Largest single-version performance gain in TypeScript history
- Avoids array allocations during path normalization
- Optimized build times and watch mode

## Development Patterns

### Result Type Pattern

```typescript
// Explicit error handling without exceptions
type Result<T, E = Error> =
  | { ok: true; value: T }
  | { ok: false; error: E };

async function fetchUser(id: string): Promise<Result<User>> {
  try {
    const response = await fetch(`/api/users/${id}`);
    if (!response.ok) {
      return {
        ok: false,
        error: new Error(`HTTP ${response.status}`),
      };
    }
    const data = await response.json();
    return { ok: true, value: data };
  } catch (error) {
    return {
      ok: false,
      error: error instanceof Error ? error : new Error('Unknown error'),
    };
  }
}

// Usage
const result = await fetchUser('123');
if (result.ok) {
  console.log(result.value.name);
} else {
  console.error(result.error.message);
}
```

### Builder Pattern with Types

```typescript
// Fluent API with type safety
class QueryBuilder<T> {
  private conditions: string[] = [];
  private orderByField?: keyof T;
  private limitValue?: number;

  where(condition: string): this {
    this.conditions.push(condition);
    return this;
  }

  orderBy(field: keyof T): this {
    this.orderByField = field;
    return this;
  }

  limit(n: number): this {
    this.limitValue = n;
    return this;
  }

  build(): string {
    let query = `SELECT * FROM table`;
    if (this.conditions.length > 0) {
      query += ` WHERE ${this.conditions.join(' AND ')}`;
    }
    if (this.orderByField) {
      query += ` ORDER BY ${String(this.orderByField)}`;
    }
    if (this.limitValue) {
      query += ` LIMIT ${this.limitValue}`;
    }
    return query;
  }
}

// Usage with type safety
interface User {
  id: string;
  name: string;
  email: string;
}

const query = new QueryBuilder<User>()
  .where('active = true')
  .orderBy('name')  // Type-checked: must be keyof User
  .limit(10)
  .build();
```

### Generic Constraints

```typescript
// Constrained generics for type safety
function getProperty<T, K extends keyof T>(obj: T, key: K): T[K] {
  return obj[key];
}

// With default type parameter
function createArray<T = string>(length: number, value: T): T[] {
  return Array(length).fill(value);
}

// Multiple constraints
interface Identifiable {
  id: string;
}

interface Timestamped {
  createdAt: Date;
  updatedAt: Date;
}

function updateEntity<T extends Identifiable & Timestamped>(
  entity: T,
  updates: Partial<Omit<T, 'id' | 'createdAt'>>
): T {
  return {
    ...entity,
    ...updates,
    updatedAt: new Date(),
  };
}
```

## Best Practices

### Use Pathlib-like Path Handling

```typescript
import { join, dirname, basename, extname } from 'path';

// Modern path handling
const filePath = join('data', 'users', 'file.txt');
const dir = dirname(filePath);      // 'data/users'
const name = basename(filePath);    // 'file.txt'
const ext = extname(filePath);      // '.txt'

// With Node.js URL for file:// URLs
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
```

### Const Assertions for Literals

```typescript
// Preserve literal types with as const
const config = {
  apiUrl: 'https://api.example.com',
  timeout: 5000,
  retries: 3,
} as const;

// config.apiUrl is 'https://api.example.com', not string
// config.timeout is 5000, not number

// Array as const
const methods = ['GET', 'POST', 'PUT', 'DELETE'] as const;
type HttpMethod = typeof methods[number];  // 'GET' | 'POST' | 'PUT' | 'DELETE'

// Object.freeze alternative
const frozen = Object.freeze({
  name: 'app',
  version: '1.0.0',
});
```

### Readonly for Immutability

```typescript
// Readonly arrays and objects
function processItems(items: readonly string[]): string {
  // items.push('new');  // Error: Property 'push' does not exist
  return items.join(', ');
}

// Readonly utility type
interface User {
  id: string;
  name: string;
  email: string;
}

function displayUser(user: Readonly<User>): void {
  // user.name = 'New Name';  // Error: Cannot assign to 'name'
  console.log(user.name);
}

// Deep readonly
type DeepReadonly<T> = {
  readonly [P in keyof T]: T[P] extends object ? DeepReadonly<T[P]> : T[P];
};
```

### Nullish Coalescing and Optional Chaining

```typescript
// Nullish coalescing (??)
const value = null ?? 'default';  // 'default'
const zero = 0 ?? 'default';      // 0 (not 'default')

// Optional chaining (?.)
interface Config {
  server?: {
    port?: number;
    host?: string;
  };
}

function getPort(config: Config): number {
  return config.server?.port ?? 3000;
}

// With function calls
const result = obj.method?.();

// With array access
const first = arr?.[0];
```

## Configuration Templates

### tsconfig.json (2025 Strict Config)

```json
{
  "compilerOptions": {
    "target": "ES2024",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "lib": ["ES2024"],

    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,

    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "allowUnusedLabels": false,
    "allowUnreachableCode": false,

    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "isolatedModules": true,

    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,

    "skipLibCheck": true,
    "incremental": true
  },
  "include": ["src"],
  "exclude": ["node_modules", "dist"]
}
```

## Summary of Essential Modern Features

**Always Use** (TypeScript 5.0+ compatible):
- Strict mode with all flags enabled
- `satisfies` operator for type validation
- zod for runtime validation of external data
- Discriminated unions for variant types
- Branded types for domain values
- Error chaining with `cause` property
- `unknown` instead of `any`
- `as const` for literal types
- Readonly for immutability

**TypeScript 5.5+**:
- Inferred type predicates (automatic narrowing)
- Control flow narrowing for `obj[key]`

**TypeScript 5.7+**:
- Path rewriting for ESM compatibility
- ES2024 target with Object.groupBy
- Enhanced performance (~15% faster)

**TypeScript 5.8+**:
- Direct execution support (Node.js 23.6+)
- 40% performance improvement
- Enhanced monorepo support

**Agent Guidelines**:
- Default to TypeScript 5.5+ compatibility
- Use `satisfies` extensively for type validation
- Always validate external data with zod
- Prefer `unknown` over `any`
- Use branded types for domain values
- Enable all strict flags

## Related References

- **[async-patterns.md](async-patterns.md)** - Comprehensive async/await patterns, Promise methods, error handling
- **[type-safety-patterns.md](type-safety-patterns.md)** - Type safety, fail-fast principles, input validation
- **[pnpm-guide.md](pnpm-guide.md)** - Package management with pnpm, monorepo workspaces
