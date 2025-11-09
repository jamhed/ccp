Perform comprehensive bug audit to identify logic errors, oversights, refactoring remnants, and potential issues ready for `/cxp:solve` workflow.

**Scope**: $ARGUMENTS (file paths, module names, or "all" for entire codebase)

**What this does**:
1. **Logic error detection**:
   - Off-by-one errors, wrong operators, incorrect algorithms
   - Boolean logic mistakes, incorrect conditionals
   - Copy-paste errors, wrong variable names after adaptation

2. **Oversight detection**:
   - Missing None checks, empty collection handling
   - Boundary conditions, division by zero, index errors
   - Missing input validation

3. **Refactoring remnants**:
   - Dead code, unused variables/functions
   - Commented-out code, TODO/FIXME markers
   - Incomplete migrations, orphaned functions
   - Debug code left in production

4. **Type safety & error handling**:
   - Missing type hints leading to runtime errors
   - Type confusion, incorrect type usage
   - Unhandled exceptions, silent failures
   - Missing cleanup (context managers, finally blocks)

5. **Async/await issues**:
   - Blocking I/O in async functions
   - Missing await statements
   - Race conditions on shared state

6. **Performance issues** (with profiling evidence):
   - N+1 query patterns
   - Blocking calls in async code

7. **Basic security** (obvious cases only):
   - SQL injection, hardcoded secrets
   - Command injection with user input

8. **Creates individual issues** in `issues/` folder:
   - Each issue is a bug, logic error, or oversight
   - Prioritized by severity (Critical/High/Medium/Low)
   - Includes evidence (tool output, reproduction steps)
   - Ready for `/cxp:solve [issue-name]` workflow

9. **Generates audit report**:
   - Lists all issues by severity and category
   - Identifies priorities (fix immediately vs later)
   - Tool findings summary
   - Estimated bug count and types

**Output**:
- `issues/bug-[name]/problem.md` - Individual bug/issue reports
- `audit-report-[timestamp].md` - Comprehensive audit summary

**Example Usage**:
- `/cxp:audit services/user` - Audit user service for bugs and oversights
- `/cxp:audit app/api/handlers.py` - Audit specific file
- `/cxp:audit all` - Audit entire codebase

**Example Workflow**:
```bash
# 1. Audit user service
/cxp:audit services/user

# Output: Created 5 issues
# - bug-off-by-one-pagination (High - logic error)
# - bug-missing-none-check-user-email (High - oversight causing crashes)
# - bug-unused-function-old-validation (Medium - refactoring remnant)
# - bug-blocking-db-call-async (Medium - async issue)
# - bug-sql-injection-user-search (High - obvious security issue)

# 2. Fix high severity bugs first
/cxp:solve bug-off-by-one-pagination

# 3. Fix oversights causing crashes
/cxp:solve bug-missing-none-check-user-email

# 4. Address medium severity issues
/cxp:solve bug-unused-function-old-validation
```

**Difference from /cxp:review**:
- **`/cxp:audit`**: Finds **bugs, logic errors, oversights, refactoring remnants**
- **`/cxp:review`**: Finds **refactoring opportunities, code quality improvements, tech debt**

**Tools used**:
- Ruff (bug detection, dead code)
- Pyright (type safety)
- Vulture (dead code detection)
- cProfile, py-spy (performance profiling when needed)
- Manual code review for logic errors and oversights

Launch the Bug Hunter agent with the specified scope.
