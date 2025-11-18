# cxt Agents - TypeScript & Node.js Development

Multi-phase problem-solving workflow agents for TypeScript 5.0+ and Node.js development. These agents work together to provide a comprehensive problem-solving pipeline from issue identification through implementation to documentation.

## Agent Overview

### Problem-Solving Workflow Agents

These agents execute sequentially as part of the `/cxt:solve` workflow:

#### 1. Problem Researcher
**File**: `problem-researcher.md`
**Purpose**: Researches TypeScript/Node.js codebases to identify bugs, performance issues, and feature requirements

**Key Capabilities**:
- Analyzes TypeScript source code for bugs, anti-patterns, and performance issues
- Specializes in async/await patterns, type safety, and framework best practices
- Creates comprehensive problem definitions with evidence
- Uses severity levels (Critical, High, Medium, Low) based on evidence

**Triggered by**: `/cxt:problem [description]` or `/cxt:refine [issue-name]`

**Output**: Creates `issues/[issue-name]/problem.md`

#### 2. Problem Validator
**File**: `problem-validator.md`
**Purpose**: Validates issues, proposes solution approaches, and develops test cases

**Key Capabilities**:
- Confirms whether reported issue is valid or "NOT A BUG"
- Proposes multiple solution approaches with TypeScript-specific considerations
- Creates Jest/Vitest test cases to prove the issue exists
- Evaluates type safety and async compatibility

**Triggered by**: `/cxt:solve [issue-name]` (Step 1)

**Output**: Creates `issues/[issue-name]/validation.md`

#### 3. Solution Reviewer
**File**: `solution-reviewer.md`
**Purpose**: Critically evaluates proposed solutions and selects optimal approach

**Key Capabilities**:
- Analyzes complexity, risk, and effort for each proposed solution
- Evaluates type safety and async compatibility
- Provides recommendation with justification
- Considers TypeScript and Node.js best practices

**Triggered by**: `/cxt:solve [issue-name]` (Step 2)

**Output**: Creates `issues/[issue-name]/review.md`

#### 4. Solution Implementer
**File**: `solution-implementer.md`
**Purpose**: Implements fixes using modern TypeScript 5.0+ best practices

**Key Capabilities**:
- Implements the selected solution approach
- Uses strict type safety and proper type narrowing
- Implements proper async/await with error handling
- Creates comprehensive implementation notes

**Triggered by**: `/cxt:solve [issue-name]` (Step 3)

**Output**: Creates `issues/[issue-name]/implementation.md`

#### 5. Code Reviewer & Tester
**File**: `code-reviewer-tester.md`
**Purpose**: Reviews code quality, runs linters, type checking, and tests

**Key Capabilities**:
- Creates and validates Jest/Vitest test cases
- Runs type checking with tsc --noEmit
- Executes linting with ESLint
- Validates test coverage (target >80%)
- Identifies improvements and refactoring opportunities

**Triggered by**: `/cxt:solve [issue-name]` (Step 4)

**Output**: Creates `issues/[issue-name]/testing.md`

#### 6. Documentation Updater
**File**: `documentation-updater.md`
**Purpose**: Creates solution documentation and git commits

**Key Capabilities**:
- Summarizes the entire workflow
- Creates comprehensive solution.md
- Generates clean git commits
- Archives issue to `archive/[issue-name]/`
- Marks original issue as RESOLVED

**Triggered by**: `/cxt:solve [issue-name]` (Step 5)

**Output**: Creates `archive/[issue-name]/solution.md` and git commit

## Workflow Execution

### Complete Workflow (`/cxt:solve [issue-name]`)

```
issues/[issue-name]/problem.md
    ↓
[Problem Validator] → validation.md
    ↓
    ├─ NOT A BUG → solution.md → [Documentation Updater] → archive/
    │
    └─ CONFIRMED ↓
[Solution Reviewer] → review.md
    ↓
[Solution Implementer] → implementation.md
    ↓
[Code Reviewer & Tester] → testing.md
    ↓
[Documentation Updater] → solution.md + git commit → archive/
```

## TypeScript-Specific Best Practices

All agents enforce modern TypeScript 5.0+ development patterns:

### Language Features
- **Strict mode**: All strict flags enabled
- **Type narrowing**: Type guards, discriminated unions
- **Utility types**: Partial, Required, Pick, Omit, Record
- **const assertions**: Immutable literals with `as const`
- **satisfies operator**: Type checking without widening
- **Template literals**: String validation at type level

### Async Patterns
- **async/await**: Proper promise handling
- **Error handling**: Try/catch with typed errors
- **Concurrency**: Promise.all, allSettled, race
- **Cancellation**: AbortController patterns
- **No unhandled rejections**: Explicit error propagation

### Node.js Patterns
- **ESM modules**: Modern import/export
- **Event loop**: No blocking operations
- **Error classes**: Custom error hierarchies
- **Environment**: Validated configuration
- **Logging**: Structured logging

### Code Quality
- **ESLint**: @typescript-eslint rules
- **Type checking**: tsc --noEmit
- **Testing**: Jest or Vitest with ts-jest
- **Coverage**: >80% target
- **Prettier**: Consistent formatting

## Tools Used

### Code Quality
- **tsc**: TypeScript compiler for type checking
- **ESLint**: Linting with @typescript-eslint
- **Prettier**: Code formatting
- **Jest/Vitest**: Testing framework
- **ts-jest**: TypeScript integration for Jest

### Testing
- **Jest**: Full-featured testing framework
- **Vitest**: Fast Vite-native testing
- **Testing Library**: React/Vue component testing
- **supertest**: HTTP API testing

### Documentation
- Markdown formatting
- File path references with line numbers
- Evidence-based severity assessment
- Git commit message conventions

## See Also

- [cxt Plugin Documentation](../README.md) - Overview of cxt plugin
- [Main CCP Documentation](../../README.md) - Complete collection documentation
