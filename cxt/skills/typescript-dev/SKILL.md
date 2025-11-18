---
name: typescript-dev
description: Expert TypeScript development assistant covering modern TypeScript 5.0+, type safety, async patterns, Node.js best practices, and framework-specific patterns (React, Vue, Express, NestJS)
---

# TypeScript Development Expert

Expert assistant for modern TypeScript 5.0+ development with focus on type safety, async patterns, and framework best practices.

## Core Capabilities

### Modern TypeScript (5.0+)
- **Type system**: Generics, conditional types, mapped types, template literals
- **Strict mode**: Enable all strict flags for maximum type safety
- **Utility types**: Partial, Required, Pick, Omit, Record, etc.
- **Type narrowing**: Type guards, discriminated unions, assertion functions
- **const assertions**: `as const` for immutable literals
- **satisfies operator**: Type checking without widening (5.0+)

### Async Patterns
- **Promises**: Proper promise handling with async/await
- **Error handling**: Try/catch with typed errors
- **Concurrency**: Promise.all, Promise.race, Promise.allSettled
- **Async iterators**: for await...of patterns
- **AbortController**: Cancellation for async operations

### Node.js Best Practices
- **ESM modules**: Modern import/export syntax
- **Package management**: npm, pnpm, or yarn with proper lock files
- **Environment**: dotenv for configuration, never commit secrets
- **Error handling**: Custom error classes with proper inheritance
- **Logging**: Structured logging with pino or winston

### Framework Patterns

**React**:
- Functional components with hooks
- TypeScript with React.FC vs function declarations
- Proper prop types with interfaces
- Custom hooks with proper typing
- Context API with TypeScript

**Express/NestJS**:
- Route typing with express-validator or class-validator
- Middleware typing
- Dependency injection (NestJS)
- DTOs with class-validator
- OpenAPI/Swagger integration

**Vue**:
- Composition API with TypeScript
- Proper component prop typing
- defineComponent and setup()
- Composables with proper typing

### Code Quality
- **ESLint**: TypeScript-specific rules (@typescript-eslint)
- **Prettier**: Consistent formatting
- **Type checking**: tsc --noEmit for CI/CD
- **Testing**: Jest or Vitest with ts-jest
- **Coverage**: Istanbul/c8 for coverage reporting

### Anti-Patterns to Avoid
- `any` type without justification (use `unknown` instead)
- Type assertions (`as`) without validation
- Ignoring null/undefined (enable strictNullChecks)
- Missing error handling in async code
- Circular dependencies
- Mutating parameters
- Using `var` (always use `const` or `let`)

### Best Practices
- **Prefer `const`**: Use `const` by default, `let` when reassignment needed
- **Explicit return types**: Always type function returns
- **Avoid `!` assertions**: Use proper type narrowing instead
- **Use strict mode**: Enable all strict flags in tsconfig.json
- **Immutability**: Prefer readonly and const assertions
- **Error first**: Handle errors explicitly, no silent failures
- **Single responsibility**: Functions and classes should do one thing
- **DRY**: Don't repeat yourself, extract common patterns

## When to Use This Skill

Use this skill when:
- Writing TypeScript code
- Reviewing TypeScript implementations
- Designing type-safe APIs
- Working with React, Vue, Express, or NestJS
- Setting up TypeScript projects
- Debugging type errors
- Optimizing TypeScript build configuration

## Common Patterns

### Type-safe API responses
```typescript
interface ApiResponse<T> {
  data: T;
  error?: string;
  status: number;
}

async function fetchUser(id: string): Promise<ApiResponse<User>> {
  try {
    const response = await fetch(`/api/users/${id}`);
    const data = await response.json();
    return { data, status: response.status };
  } catch (error) {
    return {
      data: null as unknown as User,
      error: error instanceof Error ? error.message : 'Unknown error',
      status: 500
    };
  }
}
```

### Type guards
```typescript
function isUser(value: unknown): value is User {
  return (
    typeof value === 'object' &&
    value !== null &&
    'id' in value &&
    'name' in value
  );
}
```

### Discriminated unions
```typescript
type Result<T, E> =
  | { success: true; value: T }
  | { success: false; error: E };

function handleResult<T, E>(result: Result<T, E>): void {
  if (result.success) {
    console.log(result.value); // T
  } else {
    console.error(result.error); // E
  }
}
```

### Proper async error handling
```typescript
async function processData(data: string): Promise<void> {
  try {
    const parsed = JSON.parse(data);
    await saveToDatabase(parsed);
  } catch (error) {
    if (error instanceof SyntaxError) {
      throw new ValidationError('Invalid JSON format');
    }
    if (error instanceof DatabaseError) {
      throw new StorageError('Failed to save data', { cause: error });
    }
    throw error;
  }
}
```

## Configuration Templates

### tsconfig.json (strict)
```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "lib": ["ES2022"],
    "moduleResolution": "bundler",
    "strict": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "strictBindCallApply": true,
    "strictPropertyInitialization": true,
    "noImplicitThis": true,
    "noImplicitAny": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  }
}
```

### ESLint config
```json
{
  "parser": "@typescript-eslint/parser",
  "plugins": ["@typescript-eslint"],
  "extends": [
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
    "plugin:@typescript-eslint/recommended-requiring-type-checking"
  ],
  "rules": {
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/explicit-function-return-type": "warn",
    "@typescript-eslint/no-unused-vars": "error"
  }
}
```

## Resources

- TypeScript Handbook: https://www.typescriptlang.org/docs/handbook/
- TypeScript Deep Dive: https://basarat.gitbook.io/typescript/
- React TypeScript Cheatsheet: https://react-typescript-cheatsheet.netlify.app/
