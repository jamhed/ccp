---
name: typescript-dev
description: Expert TypeScript development assistant covering modern TypeScript 5.5+, type safety, inferred type predicates, async patterns, Node.js best practices, and framework-specific patterns (React, Vue, Express, NestJS, Next.js)
---

# TypeScript Development Expert

Expert assistant for modern TypeScript 5.5+ development with focus on type safety, inferred type predicates, async patterns, and framework best practices.

## Core Capabilities

### Modern TypeScript (5.5-5.7+)

**Type System**:
- **Generics**: Type parameters, constraints, defaults
- **Conditional types**: Powerful type transformations
- **Mapped types**: Transform object types
- **Template literal types**: String manipulation at type level
- **Inferred type predicates** (5.5+): Automatic type narrowing in filter/find
- **Control flow narrowing** (5.5+): obj[key] narrowing when obj and key are constant

**Type Safety Features**:
- **Strict mode**: Enable all strict flags (required for modern projects)
- **Utility types**: Partial, Required, Pick, Omit, Record, Readonly, etc.
- **Type narrowing**: Type guards, discriminated unions, assertion functions
- **const assertions**: `as const` for immutable literals and tuple types
- **satisfies operator** (5.0+): Type checking without widening
- **unknown over any**: Safer type for unknown values

**Advanced Patterns**:
- **Branded types**: Nominal typing in structural system
- **Builder pattern with types**: Fluent APIs with type safety
- **Recursive types**: Self-referential type definitions
- **Variadic tuple types**: Flexible function signatures

### TypeScript 5.5+ Key Features

**Inferred Type Predicates**:
```typescript
// TypeScript 5.5+ automatically infers type predicates!
function isString(value: unknown) {
  return typeof value === 'string';
}

// No explicit ': value is string' needed
const values = ['a', 1, 'b', 2].filter(isString);
// values is now string[], not (string | number)[]
```

**Control Flow Narrowing**:
```typescript
// TypeScript 5.5+ narrows obj[key] when both are constant
const obj = { a: 'hello', b: 42 };
const key = 'a' as 'a' | 'b';

if (typeof obj[key] === 'string') {
  // obj[key] is now narrowed to string
  console.log(obj[key].toUpperCase());
}
```

**Regular Expression Support** (5.5+):
- Syntax checking for regex literals
- Better error messages for invalid patterns

### Async Patterns

- **Promises**: Proper promise handling with async/await
- **Error handling**: Try/catch with typed errors, error chaining with `cause`
- **Concurrency**: Promise.all, Promise.race, Promise.allSettled, Promise.any
- **Async iterators**: for await...of patterns
- **AbortController**: Cancellation for async operations
- **Top-level await**: ESM modules support top-level await

### Node.js Best Practices

- **ESM modules**: Modern import/export (prefer over CommonJS)
- **Package management**: npm, pnpm (faster), or yarn with lock files
- **Runtime validation**: zod, io-ts for validating external data
- **Environment**: dotenv or similar, never commit secrets
- **Error handling**: Custom error classes with proper inheritance
- **Logging**: Structured logging (pino, winston)
- **Process signals**: Handle SIGTERM/SIGINT gracefully

### Framework Patterns

**React** (with TypeScript):
- Functional components with hooks (preferred over React.FC)
- Proper prop types with interfaces or types
- Generic components with type parameters
- Custom hooks with proper typing
- Context API with TypeScript
- Server components (Next.js 13+)

**Next.js** (13+ with App Router):
- Server components by default
- Client components with 'use client'
- Route handlers with proper typing
- Metadata API with type safety
- Server actions with zod validation

**Express**:
- Route handlers with typed request/response
- Middleware typing
- express-validator or zod for validation
- Type-safe error handling

**NestJS**:
- Dependency injection with decorators
- DTOs with class-validator
- Guards, interceptors, pipes
- OpenAPI/Swagger integration
- GraphQL with type generation

**Vue** (3+ with Composition API):
- `<script setup lang="ts">`
- defineProps with withDefaults
- Composables with proper typing
- Provide/inject with InjectionKey

### Code Quality

- **ESLint**: @typescript-eslint with strict rules
- **Prettier**: Consistent formatting
- **Type checking**: `tsc --noEmit` in CI/CD
- **Testing**: Jest or Vitest with TypeScript
- **Coverage**: v8 or istanbul
- **Pre-commit hooks**: lint-staged + husky

### Anti-Patterns to Avoid

**Never do this**:
- `any` without justification → Use `unknown` and narrow
- Type assertions (`as`) without validation → Use type guards
- Ignoring null/undefined → Enable `strictNullChecks`
- Missing error handling in async → Always try/catch or .catch()
- `!` non-null assertions → Use proper narrowing
- Circular dependencies → Reorganize module structure
- `var` keyword → Always use `const` or `let`
- Disabling strict mode → Keep all strict flags enabled
- Mutating function parameters → Use readonly

### Best Practices

**Type Safety**:
- Enable ALL strict flags in tsconfig.json
- Use `noUncheckedIndexedAccess` for safer array/object access
- Prefer `unknown` over `any`
- Use type guards instead of type assertions
- Add explicit return types to public APIs
- Use `satisfies` for validation without widening

**Code Organization**:
- Prefer `const` by default, `let` only when needed
- Single responsibility principle
- Favor composition over inheritance
- Use readonly for immutable data
- Extract interfaces for public contracts
- Co-locate types with implementation

**Error Handling**:
- Use custom error classes with `cause` property
- Validate external data with zod/io-ts
- Type errors in catch with `unknown`
- No silent failures
- Propagate errors with context

**Performance**:
- Use const assertions for literal types
- Avoid complex conditional types in hot paths
- Use skipLibCheck in large projects
- Enable incremental compilation
- Use project references for monorepos

## When to Use This Skill

- Writing TypeScript code
- Reviewing TypeScript implementations
- Designing type-safe APIs
- Working with React, Vue, Express, NestJS, Next.js
- Setting up TypeScript projects
- Debugging type errors
- Optimizing TypeScript configuration
- Migrating JavaScript to TypeScript

## Modern Patterns

### Inferred Type Predicates (5.5+)
```typescript
// TypeScript infers the type predicate automatically!
function isNotNull<T>(value: T | null): value is T {
  return value !== null;
}

// Simplified with inference:
function isNotNull<T>(value: T | null) {
  return value !== null;  // Inferred: value is T
}

const items = [1, null, 2, null, 3].filter(isNotNull);
// items: number[]
```

### Runtime Validation with zod
```typescript
import { z } from 'zod';

const UserSchema = z.object({
  id: z.string().uuid(),
  name: z.string().min(1),
  email: z.string().email(),
  age: z.number().int().positive().optional()
});

type User = z.infer<typeof UserSchema>;

function validateUser(data: unknown): User {
  return UserSchema.parse(data);  // Throws if invalid
}
```

### Result Type Pattern
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
```

### Branded Types for Type Safety
```typescript
type UUID = string & { readonly brand: unique symbol };
type Email = string & { readonly brand: unique symbol };

function createUUID(value: string): UUID {
  if (!/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(value)) {
    throw new Error('Invalid UUID');
  }
  return value as UUID;
}

// Now UUID and Email are incompatible despite both being strings
function getUser(id: UUID): Promise<User>;
function sendEmail(to: Email): Promise<void>;
```

### Discriminated Unions
```typescript
type ApiResponse<T> =
  | { status: 'loading' }
  | { status: 'success'; data: T }
  | { status: 'error'; error: Error };

function handleResponse<T>(response: ApiResponse<T>) {
  switch (response.status) {
    case 'loading':
      // response.data and response.error don't exist
      break;
    case 'success':
      // response.data: T
      console.log(response.data);
      break;
    case 'error':
      // response.error: Error
      console.error(response.error);
      break;
  }
}
```

### Async Error Handling
```typescript
class ValidationError extends Error {
  constructor(message: string, public cause?: unknown) {
    super(message);
    this.name = 'ValidationError';
  }
}

async function processData(data: unknown): Promise<void> {
  try {
    const validated = UserSchema.parse(data);
    await saveToDatabase(validated);
  } catch (error) {
    if (error instanceof z.ZodError) {
      throw new ValidationError('Invalid data format', { cause: error });
    }
    // Re-throw unknown errors
    throw error;
  }
}
```

## Configuration Templates

### tsconfig.json (Strict Modern Config)
```json
{
  "compilerOptions": {
    // Target & Module
    "target": "ES2022",
    "module": "ESNext",
    "lib": ["ES2022"],
    "moduleResolution": "bundler",

    // Strict Type Checking (ALL enabled)
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noPropertyAccessFromIndexSignature": false,

    // Additional Checks
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "allowUnusedLabels": false,
    "allowUnreachableCode": false,

    // Module System
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "isolatedModules": true,

    // Emit
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "removeComments": false,
    "importHelpers": true,

    // Performance
    "skipLibCheck": true,
    "incremental": true
  },
  "include": ["src"],
  "exclude": ["node_modules", "dist"]
}
```

### ESLint Config (Modern)
```json
{
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
    "ecmaVersion": 2022,
    "sourceType": "module",
    "project": "./tsconfig.json"
  },
  "plugins": ["@typescript-eslint"],
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "plugin:@typescript-eslint/recommended-requiring-type-checking",
    "plugin:@typescript-eslint/strict"
  ],
  "rules": {
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/explicit-function-return-type": ["warn", {
      "allowExpressions": true
    }],
    "@typescript-eslint/no-unused-vars": ["error", {
      "argsIgnorePattern": "^_"
    }],
    "@typescript-eslint/no-floating-promises": "error",
    "@typescript-eslint/no-misused-promises": "error",
    "@typescript-eslint/await-thenable": "error",
    "@typescript-eslint/no-unnecessary-type-assertion": "error",
    "@typescript-eslint/prefer-nullish-coalescing": "warn",
    "@typescript-eslint/prefer-optional-chain": "warn",
    "@typescript-eslint/consistent-type-imports": ["warn", {
      "prefer": "type-imports"
    }]
  }
}
```

### package.json Scripts
```json
{
  "scripts": {
    "type-check": "tsc --noEmit",
    "lint": "eslint . --ext .ts,.tsx",
    "format": "prettier --write \"src/**/*.{ts,tsx}\"",
    "test": "vitest",
    "test:coverage": "vitest --coverage",
    "build": "tsc && vite build",
    "dev": "vite"
  }
}
```

## Resources

- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/)
- [TypeScript 5.5 Release Notes](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-5-5.html)
- [Total TypeScript](https://www.totaltypescript.com/)
- [React TypeScript Cheatsheet](https://react-typescript-cheatsheet.netlify.app/)
- [Zod Documentation](https://zod.dev/)
- [Type Challenges](https://github.com/type-challenges/type-challenges) - Practice advanced TypeScript

## Key Differences from Other Languages

**vs JavaScript**: Static typing, compile-time checks, better tooling
**vs Python**: Structural typing (not nominal), no runtime type checking by default
**vs Go**: No goroutines (use async/await), structural typing, more flexible generics
**vs Java/C#**: Structural (duck) typing, no method overloading, more flexible
