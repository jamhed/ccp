# Manual Testing Best Practices (2025)

Comprehensive guide to manual testing practices, smoke testing, exploratory testing, and quality assurance for Python applications.

## Agent Critical Instruction: Manual Testing is REQUIRED

**⚠️ CRITICAL FOR AGENTS**: After implementing any feature, you MUST perform manual testing. This is NOT optional.

**Decision Tree**:
```
Finished implementing feature/fix?
├─ Is this a CLI tool? → YES, MANUAL TEST REQUIRED
├─ Is this a user-facing feature? → YES, MANUAL TEST REQUIRED
├─ Did tests pass but mock critical paths? → YES, MANUAL TEST REQUIRED
├─ Is this internal utility only called by tests? → Manual test optional
└─ All tests passed? → STILL perform smoke test
```

**Agent Instructions**:
1. **ALWAYS** run automated tests first
2. **ALWAYS** perform manual smoke test after automated tests pass
3. **TEST** with real data, not mocked dependencies
4. **TEST** all output formats and options
5. **TEST** error conditions with invalid inputs
6. **RUN** with verbose logging to catch warnings
7. **REPORT** manual testing results to user

**Why This Matters**:
- Automated tests often mock critical execution paths
- Runtime warnings only appear in actual execution
- UX issues need human (or agent) verification
- Real-world integration issues may be missed

## Why Manual Testing Matters

**CRITICAL**: Automated tests don't catch everything. Manual testing is essential for:

- **Runtime warnings**: Only appear in actual execution (async/await bugs, deprecations)
- **UX issues**: Formatting, error messages, user experience need human verification
- **Edge cases**: Scenarios automated tests might miss
- **Integration gaps**: Mocked dependencies may hide real integration issues
- **Real-world behavior**: Actual environment conditions and user interactions

### Lesson Learned: The Missing `await` Bug

**Real-world example**:
- Tool execution had missing `await` wrapper
- **Result**: Returned coroutine object instead of executing
- **Symptom**: RuntimeWarning about unawaited coroutine
- **Root cause**: Async code path not manually tested
- **Discovery**: User ran command and encountered error
- **Testing gap**: All integration tests passed because they mocked the async execution

**Takeaway**: Integration tests may mock critical execution paths. Always perform manual smoke testing.

## Manual Testing Workflow

### 1. Run Automated Tests First

```bash
# Run full test suite
uv run pytest -v

# Run specific test category
uv run pytest -m integration -v

# Check specific functionality
uv run pytest tests/integration/cli/test_<command>.py -v
```

**Purpose**: Ensure basic functionality works before manual verification.

### 2. Manual Smoke Test

Test the actual application with real data and environment:

```bash
# Test primary code path with real data
python -m myapp command --args

# Test with actual files
python -m myapp process --input data.csv --output results.csv

# Test with real API calls
python -m myapp fetch --url https://api.example.com

# Test CLI commands
myapp login --username user@example.com
myapp list --filter active
myapp export --format json
```

**Purpose**: Verify real-world behavior, not mocked scenarios.

### 3. Test All Output Formats

```bash
# Test text output (default)
myapp report

# Test JSON output
myapp report --output-format json

# Test CSV output
myapp report --output-format csv

# Test table output
myapp report --output-format table

# Test verbose output
myapp report --verbose
myapp report -v
myapp report -vv  # Very verbose
```

**Purpose**: Ensure all output formats work correctly.

### 4. Test Error Conditions

```bash
# Test with invalid input
myapp process --input nonexistent.csv

# Test with malformed data
myapp parse --file broken.json

# Test missing required arguments
myapp create  # Without required --name

# Test invalid argument values
myapp set --timeout -1
myapp set --count abc

# Test permission errors
myapp delete --file /root/protected.txt

# Test network errors
myapp fetch --url https://nonexistent-domain-12345.com
```

**Purpose**: Verify error handling and error messages are user-friendly.

### 5. Test with Verbose Logging

```bash
# Test with debug logging
python -m myapp command -v

# Test with very verbose logging (catches warnings)
python -m myapp command -vv

# Test with logging to file
python -m myapp command --log-file debug.log

# Check for warnings
python -W all -m myapp command
```

**Purpose**: Catch runtime warnings, deprecations, and debugging issues.

## Manual Testing Checklist

### CLI Applications

- [ ] **Basic functionality**
  - [ ] Command runs without errors
  - [ ] Help text displays correctly (`--help`)
  - [ ] Version info displays (`--version`)

- [ ] **Input/Output**
  - [ ] Accepts expected input formats
  - [ ] Produces correct output format
  - [ ] All output formats work (text, JSON, CSV, etc.)
  - [ ] Output is properly formatted and readable

- [ ] **Error Handling**
  - [ ] Invalid input shows clear error message
  - [ ] Missing required arguments show helpful message
  - [ ] Permission errors are handled gracefully
  - [ ] Network errors don't crash the application

- [ ] **Edge Cases**
  - [ ] Empty input files
  - [ ] Large input files
  - [ ] Special characters in input
  - [ ] Unicode/emoji handling
  - [ ] Whitespace-only input

- [ ] **Logging and Debugging**
  - [ ] Verbose mode provides useful information
  - [ ] No unexpected warnings in output
  - [ ] Error messages are actionable
  - [ ] Stack traces are informative (in debug mode)

### Web APIs

- [ ] **Endpoints**
  - [ ] All endpoints respond
  - [ ] Correct status codes (200, 201, 404, 500)
  - [ ] Response format matches documentation

- [ ] **Authentication**
  - [ ] Login works with valid credentials
  - [ ] Login fails with invalid credentials
  - [ ] Token refresh works
  - [ ] Logout works

- [ ] **Data Validation**
  - [ ] Required fields are enforced
  - [ ] Invalid data returns 400 with clear message
  - [ ] Type validation works (strings, numbers, dates)
  - [ ] Length limits are enforced

- [ ] **Error Responses**
  - [ ] 404 for missing resources
  - [ ] 401 for unauthorized access
  - [ ] 403 for forbidden actions
  - [ ] 500 includes useful error info (in dev)

- [ ] **Performance**
  - [ ] Responses are reasonably fast
  - [ ] No timeout errors under normal load
  - [ ] Pagination works for large datasets

### Web Applications

- [ ] **User Interface**
  - [ ] Pages load correctly
  - [ ] Forms submit successfully
  - [ ] Buttons and links work
  - [ ] Navigation is intuitive

- [ ] **User Experience**
  - [ ] Error messages are helpful
  - [ ] Loading states are clear
  - [ ] Success messages appear
  - [ ] Confirmation dialogs work

- [ ] **Browser Compatibility**
  - [ ] Works in Chrome
  - [ ] Works in Firefox
  - [ ] Works in Safari
  - [ ] Mobile responsive

- [ ] **Accessibility**
  - [ ] Keyboard navigation works
  - [ ] Screen reader friendly
  - [ ] Sufficient color contrast
  - [ ] Form labels are clear

## Smoke Testing

### What is Smoke Testing?

Quick sanity checks to verify critical paths work after deployment or major changes.

### Smoke Test Scenarios

**For CLI Applications**:
```bash
# Scenario 1: Basic operation
myapp --version
myapp --help

# Scenario 2: Critical command
myapp process --input sample.csv

# Scenario 3: Authentication
myapp login --username test@example.com
myapp whoami

# Scenario 4: Data operations
myapp create --name "Test Item"
myapp list
myapp delete --id <created-id>
```

**For Web APIs**:
```bash
# Scenario 1: Health check
curl https://api.example.com/health

# Scenario 2: Authentication
curl -X POST https://api.example.com/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'

# Scenario 3: CRUD operations
# Create
curl -X POST https://api.example.com/users \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"name":"Test User"}'

# Read
curl https://api.example.com/users/1 \
  -H "Authorization: Bearer $TOKEN"

# Update
curl -X PUT https://api.example.com/users/1 \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"name":"Updated Name"}'

# Delete
curl -X DELETE https://api.example.com/users/1 \
  -H "Authorization: Bearer $TOKEN"
```

**For Web Applications**:
1. **Homepage loads**
   - Navigate to home page
   - Verify main content appears

2. **User authentication**
   - Log in with test account
   - Verify dashboard loads

3. **Critical workflow**
   - Create new item
   - Edit item
   - Delete item

4. **Log out**
   - Log out successfully
   - Verify redirect to login page

### Smoke Test Automation

While smoke tests should include manual verification, you can automate the basic checks:

```python
# smoke_tests.py

import pytest
import requests

BASE_URL = "https://api.example.com"

@pytest.mark.smoke
def test_health_endpoint():
    """Smoke: API health check."""
    response = requests.get(f"{BASE_URL}/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"

@pytest.mark.smoke
def test_authentication():
    """Smoke: Authentication works."""
    response = requests.post(
        f"{BASE_URL}/auth/login",
        json={"email": "test@example.com", "password": "password"}
    )
    assert response.status_code == 200
    assert "token" in response.json()

@pytest.mark.smoke
def test_critical_endpoint():
    """Smoke: Critical endpoint works."""
    response = requests.get(f"{BASE_URL}/users")
    assert response.status_code == 200
    assert isinstance(response.json(), list)
```

## Exploratory Testing

### What is Exploratory Testing?

Unscripted testing where testers explore the application to discover unexpected behaviors, edge cases, and usability issues.

### Exploratory Testing Techniques

**1. Boundary Value Testing**
- Test with minimum/maximum values
- Test with values just outside boundaries
- Test with empty, null, zero values

**2. Equivalence Partitioning**
- Test one value from each valid partition
- Test one value from each invalid partition

**3. Error Guessing**
- Try common mistakes users make
- Test obvious error scenarios
- Try unexpected input combinations

**4. User Journey Exploration**
- Follow realistic user workflows
- Try different paths to same goal
- Test back button, cancel actions
- Test switching between features

**5. Negative Testing**
- Try to break the application
- Use invalid inputs
- Test unauthorized access
- Test race conditions (concurrent users)

### Exploratory Testing Session

**Session Structure** (time-boxed, e.g., 30 minutes):

1. **Define Charter** (5 min)
   - What to explore
   - What to look for
   - What risks to cover

2. **Explore** (20 min)
   - Execute tests
   - Take notes
   - Document issues

3. **Debrief** (5 min)
   - Summarize findings
   - Create bug reports
   - Identify follow-up tests

**Example Charter**:
> "Explore user registration and login flow to identify usability issues and edge cases in input validation."

**Notes Template**:
```markdown
## Exploratory Testing Session

**Charter**: Test user registration flow for edge cases
**Duration**: 30 minutes
**Tester**: Alice
**Date**: 2025-11-23

### Test Cases Explored:
1. Registration with valid email
2. Registration with existing email
3. Registration with invalid email formats
4. Registration with weak password
5. Registration with very long username

### Issues Found:
1. **Bug**: Accepts email "user@" (invalid)
   - Severity: Medium
   - Steps: Enter "user@" in email field, submit
   - Expected: Validation error
   - Actual: Account created

2. **UX Issue**: Password strength indicator not visible
   - Severity: Low
   - Suggestion: Show strength indicator in real-time

### Questions/Risks:
- What happens with internationalized domain names?
- Should we limit username length?

### Follow-up:
- Create bug report for email validation
- Write automated test for email edge cases
```

## Quality Assurance Practices

### Code Review Checklist

- [ ] **Test Coverage**
  - [ ] New code has tests
  - [ ] Critical paths covered
  - [ ] Edge cases tested

- [ ] **Error Handling**
  - [ ] Errors are caught appropriately
  - [ ] Error messages are user-friendly
  - [ ] Logging is adequate

- [ ] **Documentation**
  - [ ] README updated
  - [ ] API docs updated
  - [ ] Breaking changes noted

### Pre-Release Checklist

- [ ] **Testing**
  - [ ] All automated tests pass
  - [ ] Manual smoke tests pass
  - [ ] Performance is acceptable
  - [ ] No critical bugs

- [ ] **Documentation**
  - [ ] CHANGELOG updated
  - [ ] Version bumped
  - [ ] Migration guide (if needed)

- [ ] **Deployment**
  - [ ] Staging environment tested
  - [ ] Rollback plan ready
  - [ ] Monitoring configured

### Post-Release Monitoring

```bash
# Monitor logs for errors
tail -f /var/log/app.log | grep ERROR

# Check error rates
curl https://api.example.com/metrics | grep error_rate

# Monitor performance
curl https://api.example.com/metrics | grep response_time

# Check health endpoint
watch -n 30 'curl -s https://api.example.com/health | jq'
```

## Documentation for Manual Testing

### Test Plan Template

```markdown
# Manual Test Plan: Feature Name

## Objective
What are we testing and why?

## Scope
What's included and excluded?

## Test Environment
- OS: Ubuntu 22.04
- Python: 3.14
- Dependencies: Listed in requirements.txt

## Test Scenarios

### Scenario 1: Happy Path
**Steps**:
1. Launch application
2. Click "New Item"
3. Fill form with valid data
4. Submit

**Expected**: Item created successfully

### Scenario 2: Invalid Input
**Steps**:
1. Click "New Item"
2. Submit without required fields

**Expected**: Validation errors displayed

## Pass/Fail Criteria
- All scenarios pass
- No critical bugs
- Performance acceptable (<2s response)

## Test Results
- [ ] Scenario 1: PASS
- [ ] Scenario 2: PASS

## Issues Found
1. Bug #123: Validation message unclear
2. UX Issue: Button alignment off

## Conclusion
Ready for release after fixing Bug #123
```

## Best Practices

### Do's ✅

1. **Always perform manual testing**
   - Don't rely solely on automated tests
   - Test with real data and environments
   - Verify user-facing behavior

2. **Test all output formats**
   - Command-line output
   - JSON, CSV, XML formats
   - Verbose/debug modes

3. **Test error conditions**
   - Invalid inputs
   - Missing files/resources
   - Network failures

4. **Use verbose logging**
   - Catch runtime warnings
   - Identify performance issues
   - Debug unexpected behavior

5. **Document findings**
   - Create bug reports
   - Note edge cases
   - Track manual test results

### Don'ts ❌

1. **Don't skip manual testing**
   - Even with 100% code coverage
   - Especially for user-facing features
   - Never for CLI applications

2. **Don't test only happy paths**
   - Test edge cases
   - Test error conditions
   - Test unusual inputs

3. **Don't ignore warnings**
   - Runtime warnings indicate problems
   - Deprecation warnings need attention
   - Performance warnings matter

4. **Don't test in isolation**
   - Test with real dependencies
   - Test in production-like environment
   - Test with actual user data (sanitized)

## Summary

### Key Principles

1. **Manual testing is essential**: Automated tests don't catch everything
2. **Test real scenarios**: Use actual data and environments
3. **Test all paths**: Happy path, errors, edge cases
4. **Use verbose logging**: Catch warnings and debug issues
5. **Document findings**: Create actionable bug reports
6. **Smoke test after changes**: Quick sanity checks
7. **Explore regularly**: Find issues automated tests miss

### Manual Testing Workflow

1. Run automated tests first
2. Manual smoke test with real data
3. Test all output formats
4. Test error conditions
5. Test with verbose logging
6. Document findings
7. Create bug reports for issues

### When to Manual Test

- **Always**: After implementing CLI commands
- **Always**: Before releases
- **Always**: After major refactoring
- **Regularly**: During development
- **Continuously**: As part of development workflow

## Agent Manual Testing Checklist

**⚠️ MANDATORY**: Complete this checklist before marking implementation complete.

### Step 1: Automated Tests (Required)
- [ ] All automated tests pass: `uv run pytest -v`
- [ ] No warnings in test output
- [ ] Coverage is adequate (>80% for critical code)

### Step 2: Manual Smoke Test (Required)
- [ ] Run command/feature with real data
- [ ] Verify expected output is produced
- [ ] No runtime warnings or errors
- [ ] No deprecation warnings

### Step 3: Output Formats (If Applicable)
- [ ] Test default output format
- [ ] Test JSON output (if applicable): `--output-format json`
- [ ] Test verbose output: `-v` or `--verbose`
- [ ] All formats produce valid output

### Step 4: Error Handling (Required)
- [ ] Test with invalid input
- [ ] Test with missing required arguments
- [ ] Error messages are clear and actionable
- [ ] No stack traces for expected errors

### Step 5: Edge Cases (Required)
- [ ] Test with empty input
- [ ] Test with large input
- [ ] Test with special characters
- [ ] Test boundary conditions

### Step 6: Logging and Debugging (Required)
- [ ] Run with verbose logging: `-vv` or `--debug`
- [ ] No unexpected warnings in logs
- [ ] Debug output is helpful
- [ ] No sensitive data in logs

### Step 7: Report Results (Required)
- [ ] Document what was tested
- [ ] Report any issues found
- [ ] Confirm manual testing complete
- [ ] Provide example usage to user

## Agent Manual Testing Templates

**Template 1: CLI Tool Manual Test**
```bash
# 1. Run automated tests
uv run pytest -v

# 2. Manual smoke test
python -m myapp command --args

# 3. Test output formats
python -m myapp command --output-format json
python -m myapp command --verbose

# 4. Test error conditions
python -m myapp command --invalid-arg
python -m myapp command  # Missing required args

# 5. Test with verbose logging
python -m myapp command -vv

# 6. Report to user
echo "✅ Manual testing complete. All tests passed."
```

**Template 2: API Manual Test**
```bash
# 1. Run automated tests
uv run pytest -m integration -v

# 2. Start server
python -m myapp run

# 3. Test endpoints manually
curl http://localhost:8000/health
curl -X POST http://localhost:8000/api/endpoint -d '{"key":"value"}'

# 4. Test error conditions
curl -X POST http://localhost:8000/api/endpoint -d '{"invalid":"data"}'

# 5. Check logs
tail -f logs/app.log

# 6. Report to user
echo "✅ API manual testing complete. All endpoints working."
```

**Template 3: Library Manual Test**
```bash
# 1. Run automated tests
uv run pytest -v

# 2. Test in Python REPL
python -c "from mylib import function; print(function(test_input))"

# 3. Test imports
python -c "import mylib; print(dir(mylib))"

# 4. Test documentation
python -c "from mylib import function; help(function)"

# 5. Report to user
echo "✅ Library manual testing complete. All functions working."
```

## Agent Reporting Template

After manual testing, report results to user:

```
✅ Manual Testing Complete

**Automated Tests**: All tests passed (N tests, M.Ms)
**Manual Smoke Test**: ✅ Command executed successfully
**Output Formats**: ✅ All formats working (text, JSON, verbose)
**Error Handling**: ✅ Error messages clear and actionable
**Edge Cases**: ✅ Handles empty input, large input, special characters
**Logging**: ✅ No unexpected warnings

**Example Usage**:
```bash
# Basic usage
python -m myapp command --arg value

# With verbose output
python -m myapp command --arg value -v

# JSON output
python -m myapp command --arg value --output-format json
```

**Ready for use.**
```

## Resources

For external documentation and references, see [external-sources.md](external-sources.md).
