# cxt Plugin - TypeScript & Node.js Development

Comprehensive toolkit for modern TypeScript 5.0+ and Node.js development with specialized skills, agents, and commands for building production-ready applications.

## Skills

- **typescript-dev**: Expert TypeScript development assistant covering modern TypeScript 5.0+ (strict mode, utility types, type narrowing), async patterns, and framework-specific patterns (React, Vue, Express, NestJS)
- **jest-tester**: Testing expert for writing, debugging, and reviewing tests with Jest/Vitest, including mocks, async testing, and TypeScript integration
- **issue-manager**: Manage project issues in the issues folder. List open issues, archive solved issues, and refine problem definitions
- **web-doc**: Fetches and caches technical documentation locally in `docs/web/` for offline reference

## Agents

Multi-phase problem-solving workflow agents (see [agents/README.md](agents/README.md) for details):

- **Problem Researcher**: Researches TypeScript/Node.js codebases to identify bugs, performance issues, and feature requirements
- **Problem Validator**: Validates issues, proposes solution approaches, and develops test cases
- **Solution Reviewer**: Critically evaluates solutions and selects optimal approach
- **Solution Implementer**: Implements fixes using modern TypeScript best practices
- **Code Reviewer & Tester**: Reviews code quality, runs linters, type checking, and tests
- **Documentation Updater**: Creates solution documentation and git commits

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

## TypeScript Best Practices Covered

### Modern TypeScript (5.0+)
- **Strict mode**: All strict flags enabled for maximum type safety
- **Type narrowing**: Type guards, discriminated unions, assertion functions
- **Utility types**: Partial, Required, Pick, Omit, Record, etc.
- **const assertions**: `as const` for immutable literals
- **satisfies operator**: Type checking without widening
- **Template literal types**: String validation at type level

### Async Patterns
- **async/await**: Proper promise handling
- **Error handling**: Try/catch with typed errors
- **Concurrency**: Promise.all, Promise.race, Promise.allSettled
- **Cancellation**: AbortController for async operations
- **No unhandled rejections**: Proper error propagation

### Node.js Patterns
- **ESM modules**: Modern import/export syntax
- **Environment**: dotenv for configuration
- **Error handling**: Custom error classes
- **Logging**: Structured logging (pino/winston)
- **No blocking**: Avoid blocking the event loop

### Code Quality
- **ESLint**: TypeScript-specific rules (@typescript-eslint)
- **Prettier**: Consistent formatting
- **Type checking**: tsc --noEmit for CI/CD
- **Testing**: Jest or Vitest with ts-jest
- **Coverage**: Target >80% code coverage

### Anti-Patterns to Avoid
- `any` type without justification (use `unknown`)
- Type assertions without validation
- Unhandled promise rejections
- Blocking operations in async code
- Mutating function parameters
- Circular dependencies
- Silent error swallowing

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

**Result**: Executes full workflow:
- Validates the problem exists
- Proposes multiple solutions (A: try/catch, B: error middleware, C: promise wrapper)
- Selects best approach (A: try/catch for explicit error handling)
- Implements the fix with type-safe error handling
- Runs tests: type check (tsc), lint (ESLint), unit tests (Jest/Vitest)
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

## Skill Usage

### TypeScript Development
```
Use the cxt:typescript-dev skill to help me review this code for type safety.
```

### Testing
```
Use the cxt:jest-tester skill to help me write tests for the user service.
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
