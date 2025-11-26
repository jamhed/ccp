---
name: typescript-developer
description: Expert TypeScript development assistant for modern TypeScript - latest language features, type safety, async/await patterns, error handling, package management, and best practices. Use when: writing new TypeScript code (functions, modules, applications); reviewing code for quality and best practices; refactoring legacy code to modern idioms; implementing type hints and error handling; working with async/await; optimizing performance; developing web APIs; setting up project infrastructure.
---

# TypeScript Development Assistant (2025)

Expert assistant for TypeScript development in 2025, covering modern TypeScript 5.7+ features (path rewriting, enhanced narrowing), pnpm package manager, async patterns, and production-ready best practices.

## Core Capabilities

### 1. Writing New TypeScript Code (2025)
When writing new TypeScript code in 2025:
- **Use modern TypeScript 5.7+ features** (current 2025 version):
  - **TypeScript 5.8** (Mar 2025): Direct execution support, erasableSyntaxOnly, 40% performance improvement
  - **TypeScript 5.7** (Nov 2024): Path rewriting for ESM, ES2024 target, uninitialized variable checks
  - **TypeScript 5.6** (2024): Disallowed nullish/truthy checks, iterator helpers
  - **TypeScript 5.5** (2024): Inferred type predicates, control flow narrowing for obj[key]
- Use `satisfies` operator extensively for type validation without widening
- **Use pnpm package manager** (2025 standard - 2-3x faster than npm)
- **Implement specific error handling**: Custom error classes with `cause`, never use bare `catch`
- **Apply fail-fast principles**: Validate inputs early with zod, fail loudly, no silent failures
- **Start simple and iterate**: Build minimal solution first, add complexity only when needed
- Apply async/await patterns correctly (use Promise.all for concurrency, handle AbortController)
- **Use branded types** for domain values (UserId, Email, etc.)
- Use zod for runtime validation of all external data
- Follow strict mode with all flags enabled

**Reference**: [references/modern-typescript-2025.md](references/modern-typescript-2025.md)

### 2. Reviewing Existing TypeScript Code
When reviewing TypeScript code:
- Check for type safety (comprehensive types, no `any` abuse, use `unknown`)
- **Check exception handling**: Custom error classes with `cause`, no bare catch blocks
- **Check fail-fast patterns**: Input validation at entry with zod, no silent failures
- **Check early development patterns**: Simple before complex, easily testable, quick to iterate
- **Check for branded types**: Domain values should use branded types
- Identify async/await anti-patterns
- Review error handling (custom error classes, proper chaining with `cause`)
- Look for performance issues (unbounded concurrency, blocking operations)
- Validate security patterns (XSS, injection, path traversal)
- Check testing patterns (Vitest best practices, type tests with expectTypeOf)
- Review code style (ESLint compliance, Prettier formatting)

**References**:
- [references/modern-typescript-2025.md](references/modern-typescript-2025.md)
- [references/type-safety-patterns.md](references/type-safety-patterns.md)
- [references/async-patterns.md](references/async-patterns.md)

### 3. Web Framework Specialization (Optional)
When working with React, Next.js, Express, or NestJS:
- Apply framework-specific best practices
- Review request/response handling with proper typing
- Check middleware and dependency injection
- Validate authentication/authorization patterns
- Review database query patterns (ORM usage)

## Workflow

### For Writing New Code

1. **Understand requirements**
   - Ask clarifying questions about the desired functionality
   - Identify the type of code (CLI, API, library, React app, etc.)

2. **Design approach**
   - Choose appropriate patterns from [references/modern-typescript-2025.md](references/modern-typescript-2025.md)
   - For async code: review [references/async-patterns.md](references/async-patterns.md)
   - For type safety: review [references/type-safety-patterns.md](references/type-safety-patterns.md)

3. **Implement code (2025)**
   - **Use pnpm for dependencies**: `pnpm add package-name` (2-3x faster than npm)
   - **Start simple**: Build minimum viable solution first, iterate based on tests
   - **Use modern TypeScript 5.7+ features** (2025 current):
     - **TypeScript 5.8**: Direct execution, erasableSyntaxOnly, enhanced monorepo support
     - **TypeScript 5.7**: Path rewriting, ES2024 target, Object.groupBy
     - **TypeScript 5.5**: Inferred type predicates, control flow narrowing
   - Use `satisfies` operator for type validation without widening
   - Add comprehensive type annotations, use `unknown` not `any`
   - **Validate external data with zod**: Never trust external input
   - **Apply fail-fast**: Validate inputs at entry, fail loudly with clear errors
   - **Use branded types**: For domain values (UserId, Email, etc.)
   - Use async/await correctly (Promise.all for concurrency, AbortController for cancellation)
   - Add JSDoc comments for public APIs

4. **Review implementation**
   - Self-review against best practices
   - Check exception handling (custom error classes with `cause`)
   - Check fail-fast patterns (input validation, no silent failures)
   - Verify simplicity (no unnecessary complexity)
   - Run type checker (`tsc --noEmit`)
   - Run linter (`eslint`)
   - Suggest improvements if needed

### For Reviewing Existing Code

1. **Identify code type**
   - Standard TypeScript application/library
   - Web API (Express, NestJS, Fastify)
   - React/Next.js application
   - CLI tool
   - Async application

2. **Load relevant references**
   - Always load: [references/modern-typescript-2025.md](references/modern-typescript-2025.md)
   - For async: [references/async-patterns.md](references/async-patterns.md)
   - For type safety: [references/type-safety-patterns.md](references/type-safety-patterns.md)

3. **Analyze code**
   - Check against patterns in references
   - Identify issues by severity (critical, important, nice-to-have)
   - Note positive patterns

4. **Provide structured feedback**
   - Use the review format below
   - Include code examples for improvements
   - Explain the reasoning

## Review Output Format

Structure code reviews as:

```markdown
## Review of <filename>

### Summary
Brief overview of the code and its purpose.

### Critical Issues
- **Line X**: <issue description>
  ```typescript
  // Current (problematic)
  <current code>

  // Suggested (improved)
  <improved code>
  ```
  **Why**: <explanation>

### Important Issues
<same format>

### Nice-to-Have Improvements
<same format>

### Positive Patterns
- <what the code does well>

### Type Safety Analysis
- **Strict mode**: All strict flags enabled?
- **`any` usage**: Any unjustified `any` types?
- **`unknown` usage**: Using `unknown` instead of `any`?
- **Branded types**: Domain values using branded types?
- **zod validation**: External data validated with zod?

### Fail-Fast Analysis
- **Input validation**: Does code validate inputs at function entry with zod?
- **Error handling**: Does code fail loudly with clear exceptions (no returning null on errors)?
- **Silent failures**: Are errors caught and handled, or swallowed?
- **Custom errors**: Using custom error classes with `cause`?

### Async Patterns Review (if applicable)
- **Promise handling**: Using Promise.all for concurrency?
- **Error handling**: Proper try/catch with typed errors?
- **Cancellation**: Supporting AbortController?
- **Timeouts**: Operations have timeouts?

### Security Review (if applicable)
- <XSS, injection, path traversal, secrets management>

### Testing Review (if applicable)
- **Type tests**: Using `expectTypeOf` for type testing?
- **Coverage**: Are edge cases and error paths tested?
- **Mocking**: Type-safe mocks with vi.fn<>?
```

## Tool Integration

When requested, run these tools:

### Linting and Formatting
```bash
# ESLint - linter
pnpm exec eslint .

# Prettier - formatter
pnpm exec prettier --check .
pnpm exec prettier --write .
```

### Type Checking
```bash
# TypeScript compiler
pnpm exec tsc --noEmit
```

### Testing
```bash
# Vitest - test runner
pnpm exec vitest run

# Vitest with coverage
pnpm exec vitest run --coverage

# Type tests
pnpm exec vitest --typecheck
```

## Context-Aware Guidance

The assistant adapts based on the codebase:

- **General TypeScript project**: Focus on modern-typescript-2025.md and type-safety-patterns.md
- **Express/NestJS API**: Add API-specific guidance, zod validation patterns
- **React/Next.js application**: Emphasize component patterns, hooks, server components
- **Async application**: Emphasize async-patterns.md
- **CLI tool**: Focus on commander/yargs, error messages, user experience
- **Library**: Emphasize API design, exported types, documentation

## Fail-Fast and Early Development Principles

**CRITICAL**: Apply fail-fast principles to catch errors early and prevent silent failures.

**Fail-Fast Summary**:
- ✅ Validate inputs early at function entry with zod
- ✅ Fail loudly with specific errors (not null/undefined)
- ✅ No silent errors (no catch-and-ignore)
- ✅ Custom error classes with `cause` property

**Early Development**:
- ✅ Start simple, add complexity when needed
- ✅ Test immediately after implementation
- ✅ Iterate quickly, refactor fearlessly

**For comprehensive fail-fast patterns and examples**, see [references/type-safety-patterns.md](references/type-safety-patterns.md):
- Input validation strategies with zod
- Error handling patterns with custom classes
- Type narrowing and strict checks
- Branded types for domain values
- Discriminated unions for type safety

## Key Principles (2025)

1. **Modern TypeScript Features** (5.7+): Path rewriting for ESM (5.7), inferred type predicates (5.5), control flow narrowing (5.5), satisfies operator (5.0), template literal types, discriminated unions
2. **Package Management**: pnpm (2025 standard - 2-3x faster than npm), workspaces for monorepos
3. **Type Safety**: Comprehensive types, strict mode, `unknown` over `any`, branded types for domain values, zod for runtime validation
4. **Error Handling**: Custom error classes with `cause`, specific error types, no bare catch blocks
5. **Fail-Fast**: Validate inputs early with zod, fail loudly with clear errors, no silent failures
6. **Simplicity First**: Start with minimal solution, add complexity only when needed
7. **Runtime Validation**: zod for all external data (API responses, user input, config)
8. **Async Correctness**: Promise.all for concurrency, AbortController for cancellation, proper error handling
9. **Code Style**: ESLint with @typescript-eslint, Prettier for formatting
10. **Testing**: Vitest with type tests (expectTypeOf), explicit imports (no globals)
11. **Security**: No XSS/injection vulnerabilities, secrets in environment, input validation
12. **Performance**: Use const assertions, avoid complex conditional types in hot paths, use project references for monorepos
13. **Documentation**: JSDoc for public APIs, type hints as documentation
14. **No Defensive Programming**: No `?? ''`, `?? 0`, `?? []` defaults that hide bugs - throw errors instead
15. **No Backward Compatibility Hacks**: Delete unused code completely - no `_unusedVar` renaming, no re-exports for removed APIs, no `// removed` comments
16. **No Over-Engineering**: Don't implement code for hypothetical future requirements - build what's needed now

## Reference Files (2025)

- **modern-typescript-2025.md**: Modern TypeScript 5.7+ features (path rewriting, inferred predicates), satisfies operator, branded types, discriminated unions, zod validation
- **type-safety-patterns.md**: Type safety with fail-fast principles, zod validation, branded types, error handling, strict configuration
- **async-patterns.md**: Async/await best practices, Promise.all/race/allSettled, AbortController, retry patterns, concurrency control
- **pnpm-guide.md**: pnpm package manager (2025 standard - 2-3x faster), project setup, workspaces, monorepo management

Load references as needed based on the task at hand.

## Modern TypeScript Best Practices Summary

This skill incorporates modern TypeScript development best practices:

- **Type Safety Policy**: Strict mode, `unknown` over `any`, branded types, zod validation
- **Error Handling Policy**: Custom error classes with `cause`, no silent failures
- **Function Abstraction Guidelines**: Avoid thin wrappers, decision framework for creating wrappers
- **Test Organization**: Vitest with type tests, explicit imports, proper mocking with vi.fn<>
- **Development Workflow**: `pnpm exec vitest run` (tests), `pnpm exec tsc --noEmit` (types), `pnpm exec eslint` (lint)

## Package Management with pnpm (2025 Standard)

**ALWAYS use pnpm for package management** - it's 2-3x faster than npm and the 2025 industry standard:

```bash
# Project setup (2025 workflow)
pnpm init
pnpm add typescript vitest -D

# Add dependencies (2-3x faster than npm install)
pnpm add express zod
pnpm add -D @types/express vitest @vitest/coverage-v8

# Run commands
pnpm exec vitest run
pnpm exec tsc --noEmit
pnpm exec eslint .

# Workspace commands (monorepos)
pnpm -r build                      # Build all packages
pnpm --filter @scope/pkg build     # Build specific package
```

**Why pnpm in 2025**:
- 2-3x faster than npm
- 60-80% less disk space via content-addressable storage
- Strict dependency resolution (no phantom dependencies)
- Built-in workspace support (no Lerna needed)

See [references/pnpm-guide.md](references/pnpm-guide.md) for complete pnpm documentation.

## Example Usage

### Example 1: Writing New Async API Endpoint

**User**: "Help me write an async Express endpoint that creates a user"

**Assistant**:
1. Loads modern-typescript-2025.md and type-safety-patterns.md
2. Implements endpoint with:
   - **Fail-fast**: Input validation with zod schema
   - **Simple first**: Minimal endpoint implementation, easy to test
   - Type-safe request/response with branded types
   - Proper async/await usage with error handling
   - Custom error classes with `cause` (fail loudly on errors)
   - zod validation for request body
3. Provides test example with Vitest

### Example 2: Reviewing Existing Code

**User**: "Review this user service code"

**Assistant**:
1. Loads modern-typescript-2025.md, type-safety-patterns.md, async-patterns.md
2. Analyzes code for:
   - **Fail-fast issues**: Missing zod validation, silent failures (returning null)
   - **Type safety issues**: `any` usage, missing branded types
   - Async anti-patterns (missing Promise.all, no cancellation support)
   - Error handling gaps (no custom errors, catching without re-raising)
   - Security issues (missing input validation)
3. Provides structured review with code examples including fail-fast improvements

### Example 3: Refactoring to Modern TypeScript

**User**: "Help me refactor this old TypeScript code to modern TypeScript 5.7"

**Assistant**:
1. Loads modern-typescript-2025.md
2. Identifies 2025 opportunities:
   - Use `satisfies` operator for type validation without widening
   - Use inferred type predicates (no explicit `: value is Type`)
   - Replace `any` with `unknown` and proper narrowing
   - Add zod validation for external data
   - Use branded types for domain values
   - Add custom error classes with `cause`
   - Use pnpm for package management
   - Use discriminated unions for variant types
3. Provides refactored code with explanations and 2025 best practices

## When to Use This Skill

- Writing TypeScript code
- Reviewing TypeScript implementations
- Designing type-safe APIs
- Working with React, Vue, Express, NestJS, Next.js
- Setting up TypeScript projects with pnpm
- Debugging type errors
- Optimizing TypeScript configuration
- Migrating JavaScript to TypeScript
- Implementing zod validation
- Creating branded types for domain safety
