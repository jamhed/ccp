---
name: python-tester
description: Expert for Python testing - unit/integration/E2E test design, pytest/unittest/hypothesis/doctest frameworks, mocking patterns, async testing with pytest-asyncio, TDD/BDD workflows, coverage improvement, manual CLI testing. Use when: designing test strategies and choosing test types/frameworks; writing unit/integration/E2E/property-based/regression tests; implementing fixtures, mocks, parametrization, async testing patterns; debugging test failures and analyzing root causes; reviewing test quality (coverage, clarity, maintainability, isolation); setting up test infrastructure (configuration, CI/CD integration, parallel execution); performing manual/smoke/exploratory testing; practicing TDD/BDD workflows.
---

# Python Testing Expert (2025)

Expert assistant for Python testing covering test design, testing frameworks (pytest, unittest, hypothesis, doctest), testing strategies (unit, integration, E2E, property-based), mocking patterns, async testing, TDD/BDD workflows, and quality assurance.

## Core Capabilities

### 1. Test Design and Strategy
When designing tests:
- **Choose test type**: Unit (70%), integration (20%), E2E (10%) - follow the testing pyramid
- **Select framework**: pytest (recommended), unittest (stdlib), hypothesis (property-based), doctest (examples)
- **Design for behavior**: Test what code does, not how it does it
- **Ensure quality**: Fast, isolated, repeatable, self-validating tests
- **Organize clearly**: Logical structure, descriptive names, proper markers

**Reference**: [references/test-organization.md](references/test-organization.md)

### 2. Writing Tests with Pytest (Primary Framework)
When writing pytest tests:
- Use simple assert statements and powerful fixtures
- Parametrize tests with @pytest.mark.parametrize
- Organize with markers (@pytest.mark.unit, @pytest.mark.integration, @pytest.mark.slow)
- Run in parallel with `uv run pytest -n auto`
- **pytest-asyncio 1.3.0+** for async testing (Python 3.10-3.14)

**Reference**: [references/pytest-patterns.md](references/pytest-patterns.md)

### 3. Mocking and Test Isolation
When mocking dependencies:
- **Mock external dependencies**: HTTP, DB, filesystem, time, external APIs
- **Don't mock internal code**: Test real integrations where possible
- **Use appropriate test doubles**: Mock (verify calls), Stub (return values), Fake (working implementation)
- **AsyncMock** for async functions (Python 3.8+)
- Keep mocks simple and focused

**References**:
- [references/mocking-patterns.md](references/mocking-patterns.md)
- [references/async-testing.md](references/async-testing.md)

### 4. Async Testing (2025)
When testing async code:
- Use @pytest.mark.asyncio for async test functions
- **pytest-asyncio 1.3.0+** supports Python 3.10-3.14
- Use async fixtures for async setup/teardown
- Optimize with asyncio.gather for concurrent test setup
- Use AsyncMock for mocking async functions
- Avoid blocking calls in async tests

**References**:
- [references/async-testing.md](references/async-testing.md) - Async testing patterns
- [references/test-organization.md](references/test-organization.md) - pytest-asyncio setup

### 5. Test Organization and Execution
When organizing tests:
- **Testing pyramid**: 70% unit, 20% integration, 10% E2E with context-specific adjustments
- **Structure**: Separate unit/, integration/, e2e/ directories
- **Markers**: Use @pytest.mark to categorize tests (unit, integration, e2e, property, slow, fast, asyncio)
- **Parallel execution**: Run tests with `uv run pytest -n auto`
- **Selective execution**: `pytest -m unit`, `pytest -m "not slow"`
- **CI/CD integration**: `make dev` (fast tests), `make ci` (full suite)

**Reference**: [references/test-organization.md](references/test-organization.md) - Includes testing pyramid strategy, test types, organization, and CI/CD

### 6. Manual Testing and Quality Assurance
**CRITICAL**: Always perform manual testing after implementation.

**Why manual testing matters**:
- Automated tests may mock critical execution paths
- Runtime warnings only appear in actual execution
- UX issues need human verification
- Edge cases may be missed by test scenarios

**Manual testing workflow**:
1. Run automated test suite
2. Manual smoke test with real data/environment
3. Test all output formats and options
4. Test error conditions with invalid inputs
5. Test with verbose logging to catch warnings

**Reference**: [references/manual-testing.md](references/manual-testing.md)

### 7. Coverage and Quality Metrics
When analyzing test quality:
- **Coverage**: Aim for >80% of critical code paths
- **Test both paths**: Success and failure scenarios
- **Edge cases**: Boundary conditions, null values, empty collections
- **Error paths**: Exception handling and error conditions
- **Coverage tools**: `pytest --cov=app --cov-report=term-missing`

**Don't chase 100% coverage** - meaningful tests matter more than metrics.

## Best Practices Summary

### Do's ✅
- **Test behavior**, not implementation details
- **Use descriptive names** that document intent
- **Follow the pyramid**: Many unit, some integration, few E2E
- **Keep tests simple** and easy to understand
- **Mock external dependencies** (HTTP, DB, filesystem)
- **Run tests in parallel** for speed
- **Manual testing** for CLI tools and user-facing features
- **Test both success and failure** paths
- **Cover edge cases** and boundaries

### Don'ts ❌
- **Don't test implementation** details
- **Don't over-mock** internal code
- **Don't skip manual verification** for CLI tools
- **Don't chase 100% coverage** without meaningful tests
- **Don't have test dependencies** or execution order
- **Don't ignore flaky tests** - fix them
- **Don't use sleep()** - use proper synchronization
- **Don't mix test types** in the same file

## Modern Python Testing (2025)

- **pytest** recommended for new projects (simple, powerful, extensive plugins)
- **pytest-asyncio 1.3.0+** for async testing (Python 3.10-3.14 support)
- **uv** for 10-100x faster test execution (`uv run pytest -n auto`)
- **Parallel execution** with pytest-xdist for CI/CD performance
- **AsyncMock** for async mocking (Python 3.8+)
- **hypothesis** for property-based testing of complex logic
- **Manual testing** remains essential despite automation advances

## Key Testing Principles

1. **Follow the Testing Pyramid**: 70% unit, 20% integration, 10% E2E
2. **Test Behavior, Not Implementation**: Focus on what code does
3. **Keep Tests Simple**: Tests should be easier to understand than code
4. **Maintain Independence**: No dependencies between tests
5. **Automate Everything**: But don't skip manual verification
6. **Fast Feedback**: Unit tests should run in milliseconds
7. **Coverage is a Tool**: Aim for >80%, meaningful tests > 100%
8. **Fail Fast**: Tests should fail quickly and clearly

## Reference Files

- **[test-organization.md](references/test-organization.md)**: Testing pyramid strategy (70/20/10), test types, directory structure, markers, pytest-asyncio setup, parallel execution, CI/CD, agent templates and checklists
- **[pytest-patterns.md](references/pytest-patterns.md)**: Pytest fixtures, parametrization, markers, configuration, examples
- **[async-testing.md](references/async-testing.md)**: Async test patterns, AsyncMock, concurrency, fixtures, real-world examples
- **[mocking-patterns.md](references/mocking-patterns.md)**: Test doubles, mocking strategies, tools, best practices
- **[tdd-workflow.md](references/tdd-workflow.md)**: Test-Driven Development process, Red-Green-Refactor cycle, TDD patterns
- **[bdd-workflow.md](references/bdd-workflow.md)**: Behavior-Driven Development, Given-When-Then syntax, pytest-bdd implementation
- **[manual-testing.md](references/manual-testing.md)**: Manual testing best practices, checklist, examples
- **[external-sources.md](references/external-sources.md)**: Curated external documentation and web references

Load references as needed based on the testing task at hand.

## Common Commands (2025)

**ALWAYS use uv for running tests** (10-100x faster dependency resolution):

```bash
# Run all tests
uv run pytest

# Run in parallel (recommended)
uv run pytest -n auto

# Run specific markers
uv run pytest -m unit           # Unit tests only
uv run pytest -m "not slow"     # Exclude slow tests
uv run pytest -m asyncio        # Async tests only

# Run with coverage
uv run pytest --cov=app --cov-report=term-missing -n auto

# Debug failed tests
uv run pytest --lf -v           # Last failed
uv run pytest --pdb             # Enter debugger
uv run pytest -v -s             # Verbose with output
```

## Example Usage

### Example 1: Writing Unit Tests

**User**: "Help me write unit tests for a user validation function"

**Assistant**:
1. Loads test-organization.md and pytest-patterns.md
2. Identifies test type: Unit tests (fast, isolated, 70% of test suite)
3. Implements tests with:
   - Simple pytest assert statements
   - Parametrization for multiple scenarios
   - Tests for success and failure paths
   - Edge cases (empty strings, null values, boundaries)
   - Clear, descriptive test names
4. Provides example with fixtures and markers

### Example 2: Setting Up Async Testing

**User**: "How do I test async database operations?"

**Assistant**:
1. Loads async-testing.md, test-organization.md (for setup), and pytest-patterns.md
2. Recommends pytest-asyncio 1.3.0+ configuration from test-organization.md
3. Implements async test setup:
   - @pytest.mark.asyncio marker
   - Async fixtures for database setup
   - AsyncMock for external dependencies
   - asyncio.gather for concurrent setup
   - Proper async/await patterns
4. Provides configuration and examples

### Example 3: Improving Test Coverage

**User**: "My test coverage is low, how do I improve it?"

**Assistant**:
1. Loads test-organization.md (includes testing pyramid strategy)
2. Analyzes current coverage gaps against 70/20/10 distribution
3. Recommends:
   - Follow testing pyramid: prioritize unit tests
   - Identify untested code paths
   - Add tests for error handling
   - Cover edge cases and boundaries
   - Test success and failure scenarios
   - Use hypothesis for complex logic
4. Provides strategy for systematic improvement with agent checklist
