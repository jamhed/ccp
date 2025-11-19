# cxt Plugin - TypeScript & Node.js Development (2025)

Comprehensive toolkit for TypeScript 5.7+ and Node.js development in 2025 with ESM-first approach, advanced type safety, Vitest testing, and modern tooling.

## Skills

- **typescript-dev**: Expert TypeScript 5.7+ development for 2025 - ESM-first, satisfies operator, template literal types, inferred type predicates, zod validation, pnpm, monorepos (Nx/TurboRepo)
- **jest-tester**: Vitest testing expert for 2025 - type testing with expectTypeOf, explicit imports, ESM support, UI mode, blazing fast performance

**Shared Skills** (from cx plugin):
- **issue-manager**: Manage project issues in the issues folder. List open issues, archive solved issues, and refine problem definitions
- **web-doc**: Fetches and caches technical documentation locally in `docs/web/` for offline reference

## Agents (2025)

Multi-phase problem-solving workflow agents using TypeScript 5.7+ and 2025 best practices (see [agents/README.md](agents/README.md) for details):

- **Problem Researcher**: Researches TypeScript 5.7+ codebases - identifies bugs using ESM, type safety, runtime validation standards
- **Problem Validator**: Validates issues and develops Vitest tests with type testing (expectTypeOf)
- **Solution Reviewer**: Evaluates solutions using satisfies operator, template literals, zod validation, monorepo patterns
- **Solution Implementer**: Implements fixes using TypeScript 5.7+, ESM-first, branded types, Result pattern
- **Code Reviewer & Tester**: Runs Vitest with type tests, ESLint, ensures 2025 best practices
- **Documentation Updater**: Documents solution with type test results, ESM compliance, zod usage

## Commands

All commands are scoped to the plugin and should be invoked as `/cxt:command`.

### /cxt:problem [description]

Research and define a new problem using the Problem Researcher agent.

**Usage**: `/cxt:problem [brief description of the issue]`

**What it does**:
- Analyzes the TypeScript/Node.js codebase to identify the root cause
- Gathers evidence with file paths and line numbers
- Creates a structured problem.md file in issues/[issue-name]/
- Documents context, follow-up actions, and acceptance criteria

**Example**: `/cxt:problem unhandled promise rejection in user service`

### /cxt:refine [issue-name]

Refine an existing problem definition using the Problem Researcher agent.

**Usage**: `/cxt:refine [issue-name]`

**What it does**:
- Re-analyzes the issue in issues/[issue-name]/problem.md
- Updates evidence and clarifies requirements
- Improves acceptance criteria
- Ensures problem is well-defined before solving

**Example**: `/cxt:refine bug-unhandled-promise-rejection`

### /cxt:solve [issue-name]

Orchestrates the complete problem-solving workflow from validation through implementation to documentation.

**Usage**: `/cxt:solve [issue-name]`

**What it does**:
Executes all agents in sequence for issues/[issue-name]/problem.md:

1. **Problem Validator** - Validates issue and proposes solutions (creates validation.md)
   - If "NOT A BUG": creates solution.md and skips to step 5
   - If confirmed: continues to step 2
2. **Solution Reviewer** - Evaluates approaches and selects best one (creates review.md)
3. **Solution Implementer** - Implements the fix (creates implementation.md)
4. **Code Reviewer & Tester** - Reviews code, runs type checking, linting, and tests (creates testing.md)
5. **Documentation Updater** - Creates solution.md summary and commits changes

Each agent creates an audit trail file documenting its phase, providing complete traceability from problem to solution.

**Example**: `/cxt:solve bug-unhandled-promise-rejection`

See [cxt/README.md](.) for complete documentation.

## Issue Management System

The plugin uses a comprehensive issue tracking system with active and archived issues. Issues are located in your project's `issues/` directory, with solved issues moved to `archive/`.

### Issue Lifecycle

#### Active Issues
```
issues/[issue-name]/
└── problem.md          # Issue definition (Status: OPEN)
```

#### Archived (Solved) Issues
```
archive/[issue-name]/
├── problem.md          # Original issue (Status: RESOLVED)
├── validation.md       # Problem Validator findings (audit trail)
├── review.md           # Solution Reviewer analysis (audit trail)
├── implementation.md   # Solution Implementer report (audit trail)
├── testing.md          # Code review and test results (audit trail)
└── solution.md         # Final documentation (summary)
```

Each agent in the workflow creates an audit trail file documenting its phase, providing complete traceability from problem to solution.

## TypeScript 5.7+ Best Practices (2025)

### Modern TypeScript (5.7+)
- **Strict mode**: ALL strict flags enabled (mandatory in 2025)
- **ESM-first**: `"type": "module"` with TypeScript 5.7 path rewriting (.ts → .js)
- **satisfies operator**: Game-changer for type validation without widening (use extensively)
- **Template literal types**: Powerful string-based types (2025 emphasis)
- **Inferred type predicates** (5.5+): Automatic type narrowing in filter/find
- **Control flow narrowing** (5.5+): obj[key] narrowing when both constant
- **Type narrowing**: Type guards, discriminated unions, branded types
- **Utility types**: Partial, Required, Pick, Omit, Record, etc.
- **const assertions**: `as const` for immutable literals

### Runtime Validation (2025 Standard)
- **zod schemas**: All external data validation (API responses, user input, env vars)
- **Branded types**: Nominal typing for domain values (UUID, Email, etc.)
- **Result type pattern**: Explicit error handling without exceptions
- **No unvalidated data**: Never trust external sources

### Async Patterns (2025)
- **async/await**: Proper promise handling with error chaining (`cause` property)
- **Error handling**: Custom error classes with `cause` for error chains
- **Concurrency**: Promise.all, Promise.race, Promise.allSettled
- **Cancellation**: AbortController for async operations
- **No unhandled rejections**: Proper error propagation
- **Cleanup**: Always clean up resources in finally blocks

### Node.js Patterns (2025)
- **ESM-first**: Never CommonJS, always import/export
- **pnpm**: Fastest package manager (2025 standard)
- **Monorepos**: Nx or TurboRepo for large-scale projects
- **Node.js compile cache**: 2-3x faster builds (TypeScript 5.7+)
- **Environment**: zod for env validation
- **Logging**: Structured logging (pino/winston)
- **No blocking**: Avoid blocking the event loop

### Testing (2025 with Vitest)
- **Vitest**: Industry standard (blazing fast, ESM-native, type testing)
- **Type testing**: expectTypeOf for testing type behavior
- **Explicit imports**: Never use globals (import describe, it, expect)
- **UI mode**: Visual testing experience (pnpm exec vitest --ui)
- **Type checking**: vitest --typecheck (MUST run)
- **Coverage**: Target >80% (vitest --coverage)
- **Type-safe mocks**: Compiler errors on type mismatches

### Code Quality (2025)
- **ESLint**: @typescript-eslint/strict rules
- **Prettier**: Consistent formatting
- **Type checking**: tsc --noEmit
- **CI/CD**: Run tests + type tests + lint + coverage

### Anti-Patterns to Avoid (2025)
- ❌ `any` type (use `unknown` and narrow)
- ❌ CommonJS (use ESM)
- ❌ Globals in tests (use explicit imports)
- ❌ Type assertions without validation
- ❌ Unvalidated external data (use zod)
- ❌ Unhandled promise rejections
- ❌ Blocking operations in event loop
- ❌ Mutating function parameters
- ❌ Circular dependencies
- ❌ Silent error swallowing

## Installation

```sh
# Add marketplace
/plugin marketplace add jamhed/ccp

# Install cxt plugin
/plugin install cxt@ccp
```

After installation, check your `~/.claude/plugins/marketplace` folder. To update agents, pull latest changes and restart Claude.

## Example Workflow

### 1. Identify a Problem
```
/cxt:problem unhandled promise rejection in user service async methods
```

**Result**: Creates `issues/bug-unhandled-promise-rejection/problem.md` with:
- Root cause analysis
- Evidence (file paths, line numbers, stack traces)
- Impact assessment
- Recommended fix approach

### 2. Solve the Problem
```
/cxt:solve bug-unhandled-promise-rejection
```

**Result**: Executes full 2025 workflow:
- Validates the problem exists with Vitest tests
- Proposes multiple solutions (A: Result type pattern, B: error middleware, C: try/catch with cause)
- Selects best approach (A: Result type pattern for explicit error handling)
- Implements the fix using TypeScript 5.7+ with zod validation
- Runs 2025 tests:
  - Type tests: `vitest --typecheck` ✅
  - Type check: `tsc --noEmit` ✅
  - Lint: `eslint` ✅
  - Unit tests: `vitest` ✅
  - Coverage: `vitest --coverage` ✅
- Verifies ESM-first, zod usage, satisfies operator
- Creates git commit with documentation

**Files created in archive/bug-unhandled-promise-rejection/**:
- `problem.md` - Original issue
- `validation.md` - Validation and proposed solutions
- `review.md` - Solution selection and rationale
- `implementation.md` - Code changes with before/after
- `testing.md` - Test results, type checking, linting
- `solution.md` - Summary documentation

### 3. Archive
Issue automatically moved to `archive/bug-unhandled-promise-rejection/` with all audit trail files.

## Skill Usage (2025)

### TypeScript 5.7+ Development
```
Use the cxt:typescript-dev skill to help me review this code for 2025 best practices (ESM, satisfies operator, zod validation).
```

### Vitest Testing
```
Use the cxt:jest-tester skill to help me write Vitest tests with type testing (expectTypeOf) for the user service.
```

## Framework Support

The plugin supports TypeScript development across multiple frameworks:

| Framework | Focus | Patterns |
|-----------|-------|----------|
| **Node.js** | Backend services | ESM, async patterns, error handling |
| **Express** | REST APIs | Route typing, middleware, error handling |
| **NestJS** | Enterprise backend | DI, decorators, DTOs, modules |
| **React** | Frontend | Hooks, prop types, context API |
| **Vue** | Frontend | Composition API, defineComponent, composables |
| **Next.js** | Full-stack | Server components, API routes, SSR |

## Contributing

This plugin is part of the Claude Code Plugin Collection (ccp). Contributions welcome at https://github.com/jamhed/ccp
