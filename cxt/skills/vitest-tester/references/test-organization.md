# Test Organization and CI/CD (2025)

Comprehensive guide to TypeScript test strategy, organization, directory structure, Vitest configuration, parallel execution, and CI/CD integration.

## Agent Guidance: Test Type Selection

**Quick Decision Tree**:
- **Pure function/calculation** → UNIT TEST
- **Database operation** → INTEGRATION TEST
- **API endpoint** → INTEGRATION TEST
- **External service call** → INTEGRATION TEST (mock) or E2E TEST (real)
- **Complete user workflow** → E2E TEST
- **Type behavior/inference** → TYPE TEST (*.test-d.ts)
- **Zod schema validation** → UNIT TEST
- **React/Vue component** → COMPONENT TEST

**Agent Instructions**:
1. **DEFAULT** to unit tests (70% of tests)
2. **ADD** integration tests for component boundaries (20% of tests)
3. **LIMIT** E2E tests to critical workflows only (10% of tests)
4. **ADD** type tests for complex type behaviors
5. **WRITE** tests from bottom up: Unit → Integration → E2E
6. **NEVER** skip unit tests in favor of integration/E2E tests

## Testing Pyramid Strategy

### Test Distribution (70/20/10)

**Unit Tests (70%)**:
- Fast execution (<10ms each)
- Test individual functions/classes in isolation
- Test zod schemas and validation
- Test branded types and type guards
- Cheapest to maintain
- Most reliable and deterministic
- Best for TDD workflow

**Integration Tests (20%)**:
- Medium speed (10ms-1s per test)
- Test component interactions and contracts
- Use real dependencies (DB, services)
- Test API endpoints with supertest
- Moderate maintenance cost

**End-to-End Tests (10%)**:
- Slowest execution (seconds to minutes)
- Test complete user workflows
- Most expensive to maintain
- Most brittle (depend on full system)
- Highest value for critical paths

**Type Tests**:
- Compile-time verification
- Test type inference behavior
- Use `expectTypeOf` assertions
- No runtime cost

**Context-Specific Adjustments**:
- Microservices: May need more integration tests (60/30/10)
- UI-heavy apps: May need more E2E tests (60/25/15)
- Libraries: Can focus more on unit tests (80/15/5)
- Type-heavy libs: Add significant type tests

### Test Type Characteristics

| Test Type | Speed | File Pattern | Scope | When to Use |
|-----------|-------|--------------|-------|-------------|
| **Unit** | <10ms | `*.test.ts` | Single function | Pure logic, calculations |
| **Integration** | <1s | `*.integration.test.ts` | Component interaction | DB, API, services |
| **E2E** | >1s | `*.e2e.test.ts` | Full system | Critical user flows |
| **Type** | Compile | `*.test-d.ts` | Type behavior | Type inference, generics |
| **Component** | <100ms | `*.test.tsx` | UI components | React/Vue components |

### Test Coverage Goals

**By Test Type**:
- Unit tests: >80% code coverage
- Integration tests: All major components
- E2E tests: All critical user paths
- Type tests: Complex generic types

**By Code Area**:
- Business logic: >90% coverage
- API endpoints: 100% coverage
- Utilities: >80% coverage
- UI components: 60-70% coverage

**Don't chase 100%** - Focus on meaningful tests, not metrics.

## Directory Structure

### Recommended Structure (Vitest)

```
project/
├── src/
│   └── myapp/
│       ├── index.ts
│       ├── models.ts
│       ├── services.ts
│       └── utils.ts
├── tests/
│   ├── setup.ts              # Test setup (vitest.setup.ts)
│   ├── helpers/              # Test utilities
│   │   └── factories.ts      # Test data factories
│   ├── unit/
│   │   ├── models.test.ts
│   │   ├── services.test.ts
│   │   └── utils.test.ts
│   ├── integration/
│   │   ├── api.test.ts
│   │   ├── database.test.ts
│   │   └── external.test.ts
│   ├── e2e/
│   │   └── workflows.test.ts
│   └── types/
│       └── inference.test-d.ts
├── vitest.config.ts
├── tsconfig.json
└── package.json
```

### Co-located Tests (Alternative)

```
project/
├── src/
│   └── myapp/
│       ├── models.ts
│       ├── models.test.ts        # Co-located unit tests
│       ├── models.test-d.ts      # Co-located type tests
│       ├── services.ts
│       └── services.test.ts
├── tests/
│   ├── integration/
│   └── e2e/
└── vitest.config.ts
```

### Feature-Based Structure

```
project/
├── src/
│   ├── users/
│   │   ├── models.ts
│   │   ├── services.ts
│   │   ├── api.ts
│   │   └── __tests__/
│   │       ├── models.test.ts
│   │       ├── services.test.ts
│   │       └── api.integration.test.ts
│   └── orders/
│       ├── models.ts
│       └── __tests__/
│           └── models.test.ts
└── tests/
    └── e2e/
        └── checkout.e2e.test.ts
```

## Vitest Configuration (2025)

### Basic Configuration

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    // Explicit imports (2025 best practice - avoid globals)
    globals: false,

    // Environment
    environment: 'node',

    // Setup files
    setupFiles: ['./tests/setup.ts'],

    // Include patterns
    include: [
      'src/**/*.test.ts',
      'tests/**/*.test.ts',
    ],

    // Type testing
    typecheck: {
      enabled: true,
      tsconfig: './tsconfig.json',
      include: ['**/*.test-d.ts'],
    },

    // Coverage
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html', 'lcov'],
      exclude: [
        '**/*.test.ts',
        '**/*.test-d.ts',
        '**/*.spec.ts',
        '**/node_modules/**',
        '**/dist/**',
        '**/*.d.ts',
        '**/tests/**',
      ],
      thresholds: {
        branches: 80,
        functions: 80,
        lines: 80,
        statements: 80,
      },
    },
  },
});
```

### React/Vue Configuration

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  test: {
    globals: false,
    environment: 'jsdom',
    setupFiles: ['./tests/setup.ts'],
    css: true,
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html'],
    },
  },
});
```

### Setup File

```typescript
// tests/setup.ts
import { expect, vi } from 'vitest';
import '@testing-library/jest-dom/vitest';

// Custom matchers
expect.extend({
  toBeValidUUID(received: string) {
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
    const pass = uuidRegex.test(received);
    return {
      pass,
      message: () => `expected ${received} to be a valid UUID`,
    };
  },
});

// Global setup
beforeEach(() => {
  vi.clearAllMocks();
});
```

## Test Naming Conventions

### File Names

```
✅ Good:
- user.test.ts           # Unit tests
- user.test-d.ts         # Type tests
- user.integration.test.ts  # Integration tests
- user.e2e.test.ts       # E2E tests
- Button.test.tsx        # Component tests

❌ Bad:
- tests.ts (too generic)
- userTests.ts (no .test suffix)
- TEST_USER.ts (wrong case)
```

### Test Function Names

```typescript
// ✅ Good - Descriptive and clear
describe('UserService', () => {
  it('creates user with valid email', () => {});
  it('throws ValidationError when email is invalid', () => {});
  it('returns null when user not found', () => {});
});

// ❌ Bad - Too vague
describe('UserService', () => {
  it('works', () => {});
  it('test1', () => {});
  it('user', () => {});
});
```

### Test Organization

```typescript
import { describe, it, expect, beforeEach } from 'vitest';

describe('UserService', () => {
  // Group by method
  describe('createUser', () => {
    it('creates user with valid data', () => {});
    it('throws when email exists', () => {});
  });

  describe('findUser', () => {
    it('returns user when exists', () => {});
    it('returns null when not found', () => {});
  });
});
```

## Parallel Execution

### Running Tests in Parallel

```bash
# Default parallel execution
pnpm exec vitest

# Specify workers
pnpm exec vitest --pool=threads --poolOptions.threads.maxThreads=4

# Sequential (for tests that can't run in parallel)
pnpm exec vitest --pool=forks --poolOptions.forks.singleFork
```

### Marking Sequential Tests

```typescript
// Use describe.sequential for tests that must run in order
describe.sequential('Database migrations', () => {
  it('runs migration 1', () => {});
  it('runs migration 2', () => {});
  it('runs migration 3', () => {});
});
```

### Test Isolation

```typescript
import { describe, it, beforeEach, afterEach } from 'vitest';

describe('Database tests', () => {
  let connection: Connection;

  beforeEach(async () => {
    connection = await createTestConnection();
    await connection.runMigrations();
  });

  afterEach(async () => {
    await connection.dropDatabase();
    await connection.close();
  });

  it('inserts data correctly', async () => {
    // Test uses isolated database
  });
});
```

## CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: ['20.x', '22.x']

    steps:
    - uses: actions/checkout@v4

    - name: Setup pnpm
      uses: pnpm/action-setup@v2
      with:
        version: 9

    - name: Use Node.js ${{ matrix.node-version }}
      uses: actions/setup-node@v4
      with:
        node-version: ${{ matrix.node-version }}
        cache: 'pnpm'

    - name: Install dependencies
      run: pnpm install

    - name: Run type checking
      run: pnpm exec tsc --noEmit

    - name: Run linters
      run: pnpm exec eslint .

    - name: Run tests
      run: pnpm exec vitest run --coverage --reporter=verbose

    - name: Run type tests
      run: pnpm exec vitest --typecheck

    - name: Upload coverage
      uses: codecov/codecov-action@v4
      with:
        file: ./coverage/lcov.info
```

### Package.json Scripts

```json
{
  "scripts": {
    "test": "vitest",
    "test:run": "vitest run",
    "test:ui": "vitest --ui",
    "test:coverage": "vitest run --coverage",
    "test:types": "vitest --typecheck",
    "test:watch": "vitest --watch",
    "test:ci": "vitest run --coverage --reporter=verbose"
  }
}
```

## Common Commands (2025)

```bash
# Run all tests (watch mode by default)
pnpm exec vitest

# Run tests once
pnpm exec vitest run

# UI mode (visual testing)
pnpm exec vitest --ui

# Type checking
pnpm exec vitest --typecheck

# Run specific test file
pnpm exec vitest user.test.ts

# Run with coverage
pnpm exec vitest run --coverage

# All in one: tests + types + coverage
pnpm exec vitest run --typecheck --coverage

# Run only changed files
pnpm exec vitest --changed

# Filter by test name
pnpm exec vitest -t "creates user"
```

## Agent Implementation Checklist

When implementing tests for a TypeScript feature, follow this checklist:

**Step 1: Identify What to Test**
- [ ] List all functions/methods in the feature
- [ ] Identify public API / external interfaces
- [ ] Note all error conditions
- [ ] List edge cases (empty, null, undefined, boundary values)
- [ ] Identify type behaviors to test

**Step 2: Write Unit Tests First (70%)**
- [ ] Test each function/method independently
- [ ] Test happy path
- [ ] Test error conditions with proper error types
- [ ] Test edge cases
- [ ] Test zod schema validation (if applicable)
- [ ] Ensure all tests pass

**Step 3: Write Type Tests**
- [ ] Test type inference behavior
- [ ] Test generic constraints
- [ ] Test branded types (if applicable)
- [ ] Test discriminated unions

**Step 4: Add Integration Tests (20%)**
- [ ] Test database interactions
- [ ] Test API endpoints
- [ ] Test service integrations
- [ ] Ensure all tests pass

**Step 5: Add E2E Tests (10%)**
- [ ] Identify 2-3 critical user workflows
- [ ] Write E2E tests for critical paths only
- [ ] Ensure all tests pass

**Step 6: Validate Coverage**
- [ ] Run coverage report: `pnpm exec vitest run --coverage`
- [ ] Verify >80% coverage for critical code
- [ ] Identify and test uncovered critical paths
- [ ] Don't chase 100% - focus on meaningful coverage

## Best Practices

### Do's

1. **Follow the testing pyramid**
   - 70% unit tests, 20% integration, 10% E2E
   - Add type tests for complex types

2. **Use explicit imports (2025 standard)**
   ```typescript
   import { describe, it, expect, vi } from 'vitest';
   ```

3. **Run tests in parallel**
   - Vitest runs tests in parallel by default
   - Mark sequential tests appropriately

4. **Use type-safe mocks**
   - Leverage TypeScript for mock type safety
   - Use `vi.fn<[], ReturnType>()` for typed mocks

5. **Integrate with CI/CD**
   - Run tests on every commit
   - Fast feedback (<5 min for unit tests)

### Don'ts

1. **Don't use globals**
   - Always import test functions explicitly
   - Avoid `globals: true` in config

2. **Don't mix test types**
   - Separate unit, integration, e2e directories
   - Use clear file naming patterns

3. **Don't skip type tests**
   - Test type inference for complex generics
   - Use `.test-d.ts` files

4. **Don't ignore TypeScript errors in tests**
   - Tests should be as type-safe as production code

## Resources

For external documentation and references, see [external-sources.md](external-sources.md).
