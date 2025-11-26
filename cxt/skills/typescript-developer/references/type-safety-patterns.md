# Type Safety with Fail-Fast Principles

Guide to writing type-safe TypeScript code that fails early and loudly. Static types + runtime validation = bugs caught at development time, not production.

**For TypeScript syntax and features**, see [modern-typescript-2025.md](modern-typescript-2025.md). This document focuses on validation, error handling, and fail-fast patterns.

## Core Principle: Fail Early, Fail Loudly

```typescript
// ❌ WRONG: Silent failures hide bugs
function getUserAge(userId: string): number {
  const user = findUser(userId);  // Returns User | undefined
  if (!user) {
    return 0;  // Silent failure - hides missing user!
  }
  return user.age;
}

// ✅ CORRECT: Fail immediately with clear error
function getUserAge(userId: string): number {
  const user = findUser(userId);
  if (!user) {
    throw new Error(`User ${userId} not found`);  // Fail loudly
  }
  return user.age;
}
```

**Why fail-fast matters**: Silent failures let bugs propagate. By the time you discover `age=0` is wrong, you're far from the root cause. Failing immediately shows exactly where and why.

## Essential Patterns for Safe Code

### 1. Validate Inputs Immediately with zod

```typescript
import { z } from 'zod';

// ❌ WRONG: Accept anything, hope it's valid
function processUserData(data: Record<string, unknown>): void {
  const userId = data.id ?? 0;  // Defaults hide missing data
  const email = data.email ?? '';  // Empty string is not valid!
}

// ✅ CORRECT: Validate structure at boundary with zod
const UserDataSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  name: z.string().min(1),
});

type UserData = z.infer<typeof UserDataSchema>;

function processUserData(data: unknown): void {
  // Validate at boundary - fail fast if invalid
  const validated = UserDataSchema.parse(data);

  // Now safe to use - guaranteed valid structure
  console.log(validated.id);  // Type-safe: string
  console.log(validated.email);  // Type-safe: string
}

// Safe validation (returns result object)
function safeProcessUserData(data: unknown): UserData | null {
  const result = UserDataSchema.safeParse(data);
  if (!result.success) {
    console.error('Validation failed:', result.error.errors);
    return null;
  }
  return result.data;
}
```

### 2. Never Return null/undefined on Errors

```typescript
// ❌ WRONG: Returning null hides errors
function parseConfig(path: string): Record<string, string> | null {
  try {
    const content = fs.readFileSync(path, 'utf-8');
    return JSON.parse(content);
  } catch {
    return null;  // Lost all error information!
  }
}

// Caller doesn't know what went wrong:
const config = parseConfig('config.json');
if (config === null) {
  // Was it missing file? Parse error? Permission denied? Unknown!
  config = {};  // Wrong - hides real problem
}

// ✅ CORRECT: Throw exceptions with context
class ConfigError extends Error {
  constructor(message: string, options?: ErrorOptions) {
    super(message, options);
    this.name = 'ConfigError';
  }
}

function parseConfig(path: string): Record<string, string> {
  let content: string;
  try {
    content = fs.readFileSync(path, 'utf-8');
  } catch (error) {
    throw new ConfigError(`Config file not found: ${path}`, { cause: error });
  }

  try {
    const data = JSON.parse(content);
    if (typeof data !== 'object' || data === null) {
      throw new ConfigError(`Config must be an object, got ${typeof data}`);
    }
    return data as Record<string, string>;
  } catch (error) {
    if (error instanceof ConfigError) throw error;
    throw new ConfigError(`Invalid JSON in ${path}`, { cause: error });
  }
}

// Caller handles specific errors explicitly:
try {
  const config = parseConfig('config.json');
} catch (error) {
  if (error instanceof ConfigError) {
    console.error('Configuration error:', error.message);
    if (error.cause) {
      console.error('Caused by:', error.cause);
    }
  }
  throw error;
}
```

### 3. Validate at System Boundaries

```typescript
import { z } from 'zod';

// ❌ WRONG: Trust external data
interface User {
  email: string;
  age: number;
}

function createUser(requestData: Record<string, unknown>): User {
  // Assume data is valid - DANGEROUS
  return {
    email: requestData.email as string,  // Might not exist or be string
    age: requestData.age as number,  // Might be string "25"
  };
}

// ✅ CORRECT: Validate external data immediately with zod
const CreateUserRequestSchema = z.object({
  email: z.string().email(),
  age: z.number().int().positive().max(150),
  name: z.string().min(1).max(100),
});

type CreateUserRequest = z.infer<typeof CreateUserRequestSchema>;

function createUser(requestData: unknown): User {
  // Validate at boundary - fail fast if invalid
  const validated = CreateUserRequestSchema.parse(requestData);

  // Now safe to use - guaranteed valid structure
  return {
    email: validated.email,
    age: validated.age,
  };
}

// Express middleware example
import { Request, Response, NextFunction } from 'express';

function validateBody<T>(schema: z.ZodType<T>) {
  return (req: Request, res: Response, next: NextFunction) => {
    const result = schema.safeParse(req.body);
    if (!result.success) {
      res.status(400).json({
        error: 'Validation failed',
        details: result.error.errors,
      });
      return;
    }
    req.body = result.data;
    next();
  };
}

// Usage
app.post('/users', validateBody(CreateUserRequestSchema), (req, res) => {
  // req.body is now typed and validated
  const user = createUser(req.body);
  res.json(user);
});
```

### 4. No Defensive Defaults - Fail Instead

```typescript
// ❌ WRONG: Defensive defaults hide missing data
function getUserEmail(userId: string): string {
  const user = db.getUser(userId);
  return user?.email ?? '';  // Empty string hides missing user!
}

function sendNotification(userId: string): void {
  const email = getUserEmail(userId);
  if (email) {  // Silently skips if empty
    sendEmail(email, 'notification');
  }
  // Bug: User exists but has no email? Or user doesn't exist? Unknown!
}

// ✅ CORRECT: Fail if data is missing
class UserNotFoundError extends Error {
  constructor(public readonly userId: string) {
    super(`User ${userId} not found`);
    this.name = 'UserNotFoundError';
  }
}

class MissingEmailError extends Error {
  constructor(public readonly userId: string) {
    super(`User ${userId} has no email`);
    this.name = 'MissingEmailError';
  }
}

function getUserEmail(userId: string): string {
  const user = db.getUser(userId);
  if (!user) {
    throw new UserNotFoundError(userId);
  }
  if (!user.email) {
    throw new MissingEmailError(userId);
  }
  return user.email;
}

function sendNotification(userId: string): void {
  const email = getUserEmail(userId);  // Throws if invalid
  sendEmail(email, 'notification');
}
```

### 5. Use Branded Types for Domain Safety

```typescript
// ❌ WRONG: All strings look the same to TypeScript
function getUser(id: string): User { /* ... */ }
function sendEmail(to: string): void { /* ... */ }

// Can accidentally pass wrong string:
const userId = 'user_123';
const email = 'user@example.com';
sendEmail(userId);  // No error! But wrong value passed

// ✅ CORRECT: Branded types prevent mix-ups
type UserId = string & { readonly brand: unique symbol };
type Email = string & { readonly brand: unique symbol };

function createUserId(value: string): UserId {
  if (!value.startsWith('user_')) {
    throw new Error(`Invalid user ID format: ${value}`);
  }
  return value as UserId;
}

function createEmail(value: string): Email {
  if (!value.includes('@')) {
    throw new Error(`Invalid email format: ${value}`);
  }
  return value as Email;
}

function getUser(id: UserId): User { /* ... */ }
function sendEmail(to: Email): void { /* ... */ }

const userId = createUserId('user_123');
const email = createEmail('user@example.com');

// sendEmail(userId);  // ❌ Type error: UserId not assignable to Email
sendEmail(email);  // ✅ Works

// With zod for validation
import { z } from 'zod';

const UserIdSchema = z.string()
  .regex(/^user_[a-z0-9]+$/)
  .brand<'UserId'>();

const EmailSchema = z.string()
  .email()
  .brand<'Email'>();

type UserId = z.infer<typeof UserIdSchema>;
type Email = z.infer<typeof EmailSchema>;
```

### 6. Literal Types for Strict Validation

```typescript
// ❌ WRONG: Runtime validation only
function setLogLevel(level: string): void {
  if (!['DEBUG', 'INFO', 'ERROR'].includes(level)) {
    level = 'INFO';  // Silent default hides typo!
  }
  logger.setLevel(level);
}

// ✅ CORRECT: Type-checked at development time
type LogLevel = 'DEBUG' | 'INFO' | 'ERROR';

function setLogLevel(level: LogLevel): void {
  logger.setLevel(level);  // No runtime check needed
}

// Type checker catches typos:
setLogLevel('DEBUG');  // ✅
// setLogLevel('DEBGU');  // ❌ Type error at development time

// For external input, validate with zod
const LogLevelSchema = z.enum(['DEBUG', 'INFO', 'ERROR']);

function setLogLevelFromInput(levelStr: string): void {
  const level = LogLevelSchema.parse(levelStr);
  setLogLevel(level);
}
```

### 7. Use unknown Instead of any

```typescript
// ❌ WRONG: Using any disables type checking
function logValue(value: any): void {
  console.log(value.name);  // No error, but might crash at runtime
}

function processData(data: any): string {
  return data.toUpperCase();  // No type checking at all
}

// ✅ CORRECT: Use unknown and narrow with type guards
function logValue(value: unknown): void {
  if (typeof value === 'object' && value !== null && 'name' in value) {
    console.log((value as { name: unknown }).name);
  }
}

function processData(data: unknown): string {
  if (typeof data !== 'string') {
    throw new Error(`Expected string, got ${typeof data}`);
  }
  return data.toUpperCase();  // Type-safe: data is string
}

// Better: Use zod for complex validation
const DataSchema = z.object({
  name: z.string(),
  value: z.number(),
});

function processComplexData(data: unknown): void {
  const validated = DataSchema.parse(data);
  console.log(validated.name);  // Type-safe
  console.log(validated.value);  // Type-safe
}
```

### 8. Discriminated Unions for Type Safety

```typescript
// ❌ WRONG: Optional fields hide invalid states
interface ApiResponse {
  success?: boolean;
  data?: unknown;
  error?: string;
}

function handleResponse(response: ApiResponse): void {
  if (response.success) {
    // response.data might still be undefined!
    console.log(response.data);
  }
}

// ✅ CORRECT: Discriminated unions prevent invalid states
type ApiResponse<T> =
  | { status: 'success'; data: T }
  | { status: 'error'; error: string }
  | { status: 'loading' };

function handleResponse<T>(response: ApiResponse<T>): void {
  switch (response.status) {
    case 'success':
      // response.data is guaranteed to exist
      console.log(response.data);
      break;
    case 'error':
      // response.error is guaranteed to exist
      console.error(response.error);
      break;
    case 'loading':
      // No data or error available
      console.log('Loading...');
      break;
  }
}

// Exhaustive checking
function assertNever(x: never): never {
  throw new Error(`Unexpected value: ${JSON.stringify(x)}`);
}

function handleResponseExhaustive<T>(response: ApiResponse<T>): string {
  switch (response.status) {
    case 'success':
      return `Data: ${JSON.stringify(response.data)}`;
    case 'error':
      return `Error: ${response.error}`;
    case 'loading':
      return 'Loading...';
    default:
      return assertNever(response);  // Compile error if case missed
  }
}
```

### 9. Strict Null Checks

```typescript
// tsconfig.json: "strictNullChecks": true (included in "strict": true)

// ❌ WRONG: Ignore null/undefined
function getLength(str: string): number {
  return str.length;  // Crashes if str is null/undefined
}

// ✅ CORRECT: Handle null explicitly
function getLength(str: string | null | undefined): number {
  if (str == null) {  // Checks both null and undefined
    throw new Error('String is required');
  }
  return str.length;
}

// Or with default value (when appropriate)
function getLength(str: string | null | undefined, defaultLength = 0): number {
  return str?.length ?? defaultLength;
}

// Non-null assertion (use sparingly!)
function processElement(element: HTMLElement | null): void {
  // Only use ! when you're 100% certain it's not null
  // Better to throw an error if assumption is wrong
  if (!element) {
    throw new Error('Element not found');
  }
  element.classList.add('processed');
}
```

### 10. Const Assertions for Immutability

```typescript
// ❌ WRONG: Mutable arrays lose type information
const statuses = ['pending', 'active', 'completed'];
type Status = typeof statuses[number];  // string (too wide!)

// ✅ CORRECT: as const preserves literal types
const statuses = ['pending', 'active', 'completed'] as const;
type Status = typeof statuses[number];  // 'pending' | 'active' | 'completed'

// Object immutability
const config = {
  apiUrl: 'https://api.example.com',
  timeout: 5000,
} as const;

// config.apiUrl is 'https://api.example.com', not string
// config.timeout is 5000, not number
// config.apiUrl = 'other';  // Error: Cannot assign to readonly property

// Readonly utility for function parameters
function processConfig(config: Readonly<{ apiUrl: string; timeout: number }>): void {
  // config.timeout = 1000;  // Error: Cannot assign to readonly property
  console.log(config.apiUrl);
}
```

## Catching Bugs with Fail-Fast + Types

### Bug: Silent null Handling

```typescript
// ❌ BUG: Returns 0 when user not found - hides error
function getUserAgeDefensive(userId: string): number {
  const user = db.getUser(userId);
  if (!user) {
    return 0;  // Silent default
  }
  return user.age ?? 0;  // More silent defaults!
}

// Causes bug far from root cause:
const age = getUserAgeDefensive('nonexistent');  // Returns 0
if (age < 18) {
  // Wrong! User doesn't exist, but we treat as age=0
  restrictAccess();
}

// ✅ FIXED: Fail immediately at source
function getUserAge(userId: string): number {
  const user = db.getUser(userId);
  if (!user) {
    throw new UserNotFoundError(userId);
  }
  if (user.age === undefined) {
    throw new Error(`User ${userId} has no age field`);
  }
  return user.age;
}

// Caller handles error explicitly:
try {
  const age = getUserAge('nonexistent');
  if (age < 18) {
    restrictAccess();
  }
} catch (error) {
  if (error instanceof UserNotFoundError) {
    denyAccess();  // Correct behavior
  }
  throw error;
}
```

### Bug: Accepting Invalid Input

```typescript
// ❌ BUG: Accepts negative prices
function calculateDiscount(price: number, percent: number): number {
  return price * (1 - percent);
}

// Caller can pass invalid values:
calculateDiscount(-100, 0.5);  // Negative price!
calculateDiscount(100, 1.5);   // 150% discount!

// ✅ FIXED: Validate inputs with zod
import { z } from 'zod';

const DiscountInputSchema = z.object({
  price: z.number().positive(),
  percent: z.number().min(0).max(1),
});

function calculateDiscount(price: number, percent: number): number {
  const validated = DiscountInputSchema.parse({ price, percent });
  return validated.price * (1 - validated.percent);
}

// Catches bugs immediately:
calculateDiscount(-100, 0.5);  // ✅ Throws ZodError: price must be positive
calculateDiscount(100, 1.5);   // ✅ Throws ZodError: percent must be <= 1
```

## Type Checker Configuration for Fail-Fast

### tsconfig.json (Strict Settings)

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,

    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "allowUnusedLabels": false,
    "allowUnreachableCode": false,

    "noImplicitAny": true,
    "noImplicitThis": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "strictBindCallApply": true,
    "strictPropertyInitialization": true,
    "useUnknownInCatchVariables": true
  }
}
```

### ESLint Rules for Type Safety

```json
{
  "rules": {
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/no-unsafe-assignment": "error",
    "@typescript-eslint/no-unsafe-call": "error",
    "@typescript-eslint/no-unsafe-member-access": "error",
    "@typescript-eslint/no-unsafe-return": "error",
    "@typescript-eslint/no-non-null-assertion": "warn",
    "@typescript-eslint/strict-boolean-expressions": "error",
    "@typescript-eslint/no-unnecessary-condition": "error",
    "@typescript-eslint/prefer-nullish-coalescing": "warn",
    "@typescript-eslint/prefer-optional-chain": "warn"
  }
}
```

## Fail-Fast Checklist for Code Review

✅ **Input Validation**:
- [ ] All external inputs validated with zod at boundary
- [ ] Invalid inputs throw exceptions (never return null/undefined/defaults)
- [ ] Validation errors have clear messages with context

✅ **Error Handling**:
- [ ] Never return null on errors - throw exceptions
- [ ] Custom error classes for domain errors
- [ ] Error chaining with `cause` property
- [ ] No silent `try/catch` blocks

✅ **Type Safety**:
- [ ] All strict flags enabled in tsconfig.json
- [ ] No `any` without explicit justification
- [ ] Branded types for domain values (UserId, Email, etc.)
- [ ] Discriminated unions for variant types
- [ ] zod schemas for external data

✅ **No Defensive Programming**:
- [ ] No defensive defaults (empty strings, 0, empty arrays)
- [ ] No `?? ''` or `?? 0` to hide missing data
- [ ] No lenient validation ("accept anything")
- [ ] No silent error swallowing

✅ **Fail-Fast Principles**:
- [ ] Validate early (at function entry, at construction)
- [ ] Fail loudly (throw, don't return error codes)
- [ ] Fail immediately (don't propagate invalid state)
- [ ] Fail with context (helpful error messages)

## Summary: Type Safety + Fail-Fast

**Static types catch bugs at compile time. Fail-fast catches bugs at runtime - as early as possible.**

1. **Validate at boundaries** with zod - Check external input immediately
2. **Throw, don't return null** - Errors are exceptional, treat them that way
3. **No defensive defaults** - Hiding errors with defaults makes debugging hard
4. **Strict TypeScript config** - Enable all strict flags
5. **Branded types** - Prevent mix-ups between domain values
6. **Discriminated unions** - Make invalid states unrepresentable
7. **Custom error classes** - Domain-specific errors with context

**Remember**: A crash during development is better than silent corruption in production. Fail early, fail loudly, fail with context.

## No Defensive Programming

**CRITICAL**: Defensive programming hides bugs. Fail-fast exposes them.

```typescript
// ❌ WRONG: Defensive defaults hide missing data
const name = user?.name ?? '';           // Empty string hides missing user
const items = response?.items ?? [];     // Empty array hides failed request
const count = data?.count ?? 0;          // Zero hides missing count

// ✅ CORRECT: Fail fast - expose the problem
if (!user) throw new UserNotFoundError(userId);
if (!response?.items) throw new ApiError('Items missing from response');
if (data?.count === undefined) throw new ValidationError('Count is required');
```

**Why no defensive programming**:
- Defaults propagate invalid state silently
- Bugs surface far from root cause
- Debugging becomes archaeology
- Tests pass with wrong behavior

## No Backward Compatibility (Unless Requested)

**CRITICAL**: Don't implement backward compatibility unless explicitly asked.

```typescript
// ❌ WRONG: Backward compatibility hacks
const _oldFunction = oldFunction;  // Renamed unused
export { newFunction as oldFunction };  // Re-export for old consumers
// removed: oldMethod() - keeping for reference

// ✅ CORRECT: Delete unused code completely
// Just delete oldFunction - no traces, no comments, no re-exports
```

**When removing code**:
- Delete it completely - no `_unusedVar` prefix
- Don't re-export old names pointing to new implementations
- Don't leave `// removed` or `// deprecated` comments
- Don't keep dead code "for reference" - that's what git history is for

**Exception**: Only add backward compatibility when user explicitly requests it (e.g., "maintain API compatibility for v1 consumers").
