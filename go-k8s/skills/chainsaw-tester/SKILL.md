---
name: chainsaw-tester
description: Expert for writing, debugging, and reviewing Chainsaw E2E tests for Kubernetes operators. Use when working with chainsaw-test.yaml files, debugging test failures, reviewing chainsaw test changes, or writing new E2E tests. Covers JP assertions, operator testing, webhook validation, mock services, and flakiness resolution.
---

# Chainsaw Tester

Expert assistant for Chainsaw end-to-end testing of Kubernetes operators. Helps with writing, debugging, reviewing, understanding, and optimizing tests using declarative YAML and built-in JP (JMESPath) assertions.

## Core Capabilities

### 1. Writing Chainsaw Tests
When writing Chainsaw tests:
- Use built-in JP (JMESPath) assertions instead of shell scripts
- Apply proper RBAC configuration for query-based tests
- Structure tests with correct file naming and dependencies
- Leverage Chainsaw's declarative assertion trees
- Follow ARK-specific CR validation patterns
- Use proper timeout and error handling

**References**:
- [references/chainsaw-basics.md](references/chainsaw-basics.md)
- [references/assertion-patterns.md](references/assertion-patterns.md)
- [references/jp-functions.md](references/jp-functions.md)

### 2. Kubernetes Operator Testing
When writing tests for Kubernetes operators:
- Validate CRD schemas before writing manifests
- Test Custom Resources and their controllers
- Use proper resource dependencies (RBAC → Secrets → CRDs → Custom Resources)
- Validate status phases and conditions
- Test admission webhooks and validation
- Validate reconciliation behavior

**References**:
- [references/chainsaw-basics.md](references/chainsaw-basics.md)
- [references/assertion-patterns.md](references/assertion-patterns.md)
- [references/ark-examples.md](references/ark-examples.md) (optional: ARK operator examples)

### 3. Debugging and Understanding Tests
When debugging or understanding Chainsaw tests:
- Interpret test failures and error messages
- Analyze catch block outputs (events, describe)
- Understand JP assertion expressions
- Identify root causes of test failures
- Optimize test performance and reliability
- Refactor shell scripts to JP assertions

**References**:
- [references/assertion-patterns.md](references/assertion-patterns.md)
- [references/jp-functions.md](references/jp-functions.md)
- [references/chainsaw-basics.md](references/chainsaw-basics.md)

### 4. Assertion Best Practices
When writing or reviewing assertions:
- **ALWAYS** prefer built-in JP functions over shell scripts
- Use `length()`, `contains()`, `join()` for response validation
- Use `json_parse()` for structured output validation
- Validate existence with proper null/exists checks
- Combine multiple assertions for comprehensive validation
- Use proper error handling with catch blocks

**References**:
- [references/assertion-patterns.md](references/assertion-patterns.md)
- [references/jp-functions.md](references/jp-functions.md)

## When to Use This Skill

**Automatically use when:**
- Working with files matching `**/chainsaw-test.yaml` or `**/*chainsaw*.yaml`
- User mentions "chainsaw test", "e2e test", or "kubernetes operator test"
- Debugging test failures in `tests/` directories
- Reviewing changes to Chainsaw tests in git diffs or pull requests

**Explicitly use for:**
- Writing new Chainsaw tests for Kubernetes operators or Custom Resources
- Testing Custom Resource Definitions (CRDs) and admission webhooks
- Validating controller/operator reconciliation behavior
- Debugging flaky tests or webhook timeout issues
- Converting shell script assertions to JP functions
- Reviewing test structure and best practices
- Setting up mock services for testing

## Workflow

### For Writing New Tests

1. **Understand requirements** - What functionality needs testing and which resources are involved?

2. **Check CRD schemas** - Verify current field names and types ([operator-testing.md#crd-schema-validation](references/operator-testing.md#crd-schema-validation))

3. **Structure test directory** (see [chainsaw-basics.md#file-organization](references/chainsaw-basics.md#file-organization))

4. **Write manifests in dependency order** - RBAC → Secrets → Dependencies → Primary resources ([operator-testing.md#resource-dependencies](references/operator-testing.md#resource-dependencies))
   - **ALWAYS use 'a' prefix for numbered manifest files**: `a00-`, `a01-`, `a02-`, etc. (never `00-`, `01-`, `02-`)

5. **Write assertions using JP functions** - Use built-in functions, avoid shell scripts ([assertion-patterns.md](references/assertion-patterns.md))

6. **Add error handling** - Use catch blocks with events and describe ([debugging.md](references/debugging.md))

### For Custom Resource Testing

1. **Identify resource type and schema** - Check CRD schema and status fields ([operator-testing.md](references/operator-testing.md))

2. **Load relevant references** - See [assertion-patterns.md](references/assertion-patterns.md) and [jp-functions.md](references/jp-functions.md)

3. **Write test steps** - Setup → Apply dependencies → Assert states → Catch for debugging ([operator-testing.md#testing-custom-resources](references/operator-testing.md#testing-custom-resources))

4. **Validate with JP assertions** - Use `length()`, `contains()`, `json_parse()`, comparison operators ([jp-functions.md](references/jp-functions.md))

### For Debugging Test Failures

1. **Analyze the failure** - Read test output, identify failed step/assertion, check catch blocks ([debugging.md#debugging-test-failures](references/debugging.md#debugging-test-failures))

2. **Investigate root cause** - Verify CRD schema, RBAC permissions, resource dependencies ([debugging.md#investigate-root-cause](references/debugging.md#investigate-root-cause))

3. **Fix and optimize** - Adjust assertions, update timeouts, fix dependency order ([debugging.md#fix-and-optimize](references/debugging.md#fix-and-optimize))

4. **Test improvements** - Run with `--skip-delete` and `--repeat-count` to verify ([debugging.md#test-improvements](references/debugging.md#test-improvements))

### For Debugging Flaky Tests

See detailed guidance in [debugging.md#flaky-test-patterns](references/debugging.md#flaky-test-patterns).

**Quick reference:**
- **Webhook timeouts** → Split resource application into steps ([debugging.md#webhook-timeout-race-conditions](references/debugging.md#webhook-timeout-race-conditions))
- **LLM assertions** → Validate structure, not exact content ([debugging.md#llm-dependent-assertions](references/debugging.md#llm-dependent-assertions))
- **Detecting flakiness** → Run with `--repeat-count 10` ([debugging.md#detecting-flakiness](references/debugging.md#detecting-flakiness))

### For Reviewing Changes to Chainsaw Tests

1. **Understand the changes** - Review git diff, identify what was added/modified/removed

2. **Evaluate test structure** - Check file naming, dependency order, step naming, README ([chainsaw-basics.md#file-organization](references/chainsaw-basics.md#file-organization))

3. **Review assertions and patterns** - Verify JP assertions, timeouts, catch blocks, mock services ([assertion-patterns.md](references/assertion-patterns.md))

4. **Assess correctness** - Verify CRD schemas, RBAC, URL templating, check for race conditions ([operator-testing.md](references/operator-testing.md), [debugging.md](references/debugging.md))

5. **Provide feedback** - Highlight best practices, identify anti-patterns, suggest improvements

## Test Output Format

Structure Chainsaw tests as:

```yaml
apiVersion: chainsaw.kyverno.io/v1alpha1
kind: Test
metadata:
  name: test-name
spec:
  description: Brief description of what this test validates
  steps:
  - name: setup
    try:
    # Setup steps (scripts, apply resources)

  - name: validate
    try:
    # Assertions
    catch:
    # Error handling
```

## Key Principles

1. **Declarative Assertions**: Use JP functions, not shell scripts
2. **RBAC Required**: Query tests need proper RBAC configuration
3. **Dependency Order**: Apply resources in correct dependency sequence
4. **File Naming**: ALWAYS use 'a' prefix for numbered manifest files (a00-, a01-, a02-, etc.)
5. **Schema Validation**: Always verify CRD schema before writing manifests
6. **Comprehensive Validation**: Assert both existence and content
7. **Error Handling**: Include catch blocks with events and describe
8. **Timeouts**: Set appropriate timeout values for different operations
9. **Documentation**: Include README.md for each test directory

## Common Patterns

### Mock Service Deployment

See [mock-services.md](references/mock-services.md) for complete guidance on:
- Deploying mock HTTP services (httpbin, Prism)
- URL templating with `$namespace`
- Prism-based API mocking with OpenAPI
- Best practices and troubleshooting

### JP Assertion Patterns

See [assertion-patterns.md](references/assertion-patterns.md) and [jp-functions.md](references/jp-functions.md) for:
- JP expression syntax
- Array and collection assertions
- JSON content validation
- Common validation patterns

**Quick examples:**
```yaml
# Validate response count
(length(responses)): 1

# Validate presence
(contains(responses[*].target.name, 'agent-name')): true

# Validate content length
(length(join('', responses[*].content)) > `10`): true

# Validate JSON
(json_parse(responses[0].content).field != null): true
```

**Always prefer JP assertions over shell scripts** - see [assertion-patterns.md#anti-patterns](references/assertion-patterns.md#anti-patterns)

## Reference Files

- **[chainsaw-basics.md](references/chainsaw-basics.md)**: Chainsaw fundamentals, test structure, file organization, operations
- **[assertion-patterns.md](references/assertion-patterns.md)**: Assertion syntax, JP expressions, validation patterns
- **[jp-functions.md](references/jp-functions.md)**: Complete JP function reference with examples
- **[debugging.md](references/debugging.md)**: Debugging test failures, flaky tests, webhook timeouts, LLM assertions
- **[mock-services.md](references/mock-services.md)**: Mock service deployment, URL templating, Prism, httpbin
- **[operator-testing.md](references/operator-testing.md)**: CRD testing, controller reconciliation, RBAC, admission webhooks
- **[ark-examples.md](references/ark-examples.md)**: ARK operator examples (optional, project-specific)

Load references as needed based on the testing task at hand.

## Anti-Patterns to Avoid

See detailed anti-patterns in each reference file:
- [assertion-patterns.md#anti-patterns](references/assertion-patterns.md#anti-patterns)
- [debugging.md#anti-patterns](references/debugging.md#anti-patterns)
- [mock-services.md#anti-patterns](references/mock-services.md#anti-patterns)
- [operator-testing.md#anti-patterns](references/operator-testing.md#anti-patterns)

**Critical anti-patterns:**
- ❌ Use shell scripts for assertions → ✅ Use JP functions
- ❌ Apply all resources with `manifests/*.yaml` when webhooks exist → ✅ Split into steps
- ❌ Assert exact LLM output strings → ✅ Validate structure and length
- ❌ Skip CRD schema validation → ✅ Check schema first (`kubectl explain`)
- ❌ Hardcode namespaces in URLs → ✅ Use `$namespace` variable
- ❌ Skip RBAC configuration → ✅ Include RBAC manifests

## Usage and Best Practices

### Getting Help

```bash
# Always check the CLI help for your version
chainsaw test --help
```

### Common Usage Patterns

```bash
# Run all tests
chainsaw test tests/

# Run specific test
chainsaw test tests/test-name/

# Run tests in parallel
chainsaw test tests/ --parallel 4

# Debug: pause on failure and keep resources
chainsaw test tests/ --pause-on-failure --skip-delete

# CI/CD: parallel with JUnit reports
chainsaw test tests/ \
  --parallel 8 \
  --fail-fast \
  --report-format JUNIT-TEST \
  --report-path ./junit-results \
  --no-color

# Detect flaky tests
chainsaw test tests/flaky-test/ --repeat-count 10
```

**Most Common Flags:**
- `--parallel N` - Run N tests concurrently
- `--skip-delete` - Keep resources after test
- `--pause-on-failure` - Pause for inspection
- `--fail-fast` - Stop on first failure
- `--include-test-regex` - Filter tests
- `--report-format` - Generate reports

For complete options and detailed examples, see [references/chainsaw-basics.md](references/chainsaw-basics.md#test-execution).

### Project Integration

When working with a specific operator project:
- Check for existing test documentation (README, TESTING.md, etc.)
- Review existing test patterns for consistency
- Verify CRD schemas in the project's API definitions
- Follow the project's test directory structure
- Reference the project's RBAC requirements

### Example Projects

This skill includes reference examples from real-world operator testing:
- **ARK Operator**: AI agent orchestration patterns (see [references/ark-examples.md](references/ark-examples.md))
- Adapt these patterns to your specific operator's needs

## Version History

### v2.0 - 2025-01-26

**Major refactoring for better organization and usability:**

**New Reference Files:**
- Added `debugging.md` - Comprehensive debugging guide including flaky test patterns, webhook timeouts, and LLM assertion issues
- Added `mock-services.md` - Complete guide to mock service deployment with Prism and httpbin
- Added `operator-testing.md` - CRD testing, controller reconciliation, RBAC, and admission webhooks

**Improvements:**
- Improved skill description for better auto-triggering
- Streamlined SKILL.md from 575 to ~300 lines (48% reduction)
- Removed duplication between SKILL.md and reference files
- Enhanced cross-referencing with anchor links
- Better separation of general vs. project-specific content
- More concise workflows with references to detailed documentation

**Content Reorganization:**
- Moved flakiness patterns to `debugging.md`
- Moved mock service patterns to `mock-services.md`
- Moved operator-specific patterns to `operator-testing.md`
- Consolidated anti-patterns with references to detailed docs
- Improved "When to Use" section with automatic triggers

### v1.0 - 2024-12-01

**Initial skill creation:**
- Core Chainsaw testing patterns
- JP assertion guidance
- ARK operator examples
- Webhook validation patterns
- Basic debugging guidance
