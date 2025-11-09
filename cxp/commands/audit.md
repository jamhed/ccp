Perform critical security and bug audit to identify potential bugs, vulnerabilities, and issues ready for `/cxp:solve` workflow.

**Scope**: $ARGUMENTS (file paths, module names, "critical" for auth/payments only, or "all" for entire codebase)

**What this does**:
1. **Security scanning**:
   - SQL injection, command injection, path traversal
   - XSS, insecure deserialization
   - Hardcoded secrets, weak crypto
   - Authentication/authorization bypasses

2. **Bug detection**:
   - Logic errors (off-by-one, wrong operators)
   - Edge cases (None checks, division by zero, index errors)
   - Type safety issues (runtime type errors)
   - Error handling gaps (unhandled exceptions, silent failures)

3. **Performance analysis** (with profiling):
   - N+1 query patterns
   - Memory leaks (with evidence)
   - Blocking calls in async code
   - CPU bottlenecks

4. **Async/concurrency issues**:
   - Blocking I/O in async functions
   - Missing await statements
   - Race conditions, deadlocks
   - Task management issues

5. **Creates individual issues** in `issues/` folder:
   - Each issue is a bug or vulnerability
   - Prioritized by severity (Critical/High/Medium)
   - Includes evidence (tool output, profiling, reproduction steps)
   - Ready for `/cxp:solve [issue-name]` workflow

6. **Generates audit report**:
   - Lists all issues by severity and category
   - Identifies critical priorities (fix immediately)
   - Provides security recommendations
   - Estimates overall security posture

**Output**:
- `issues/bug-[name]/problem.md` - Individual bug/security issues
- `audit-report-[timestamp].md` - Comprehensive audit summary

**Example Usage**:
- `/cxp:audit auth` - Audit authentication module for security issues
- `/cxp:audit app/api/handlers.py` - Audit specific file
- `/cxp:audit critical` - Audit only critical paths (auth, payments)
- `/cxp:audit all` - Audit entire codebase

**Example Workflow**:
```bash
# 1. Audit authentication module
/cxp:audit auth

# Output: Created 4 issues
# - bug-sql-injection-login (Critical - FIX IMMEDIATELY!)
# - bug-weak-password-hash (Critical)
# - bug-missing-rate-limit (High)
# - bug-session-timeout-missing (Medium)

# 2. Fix critical security issues immediately
/cxp:solve bug-sql-injection-login

# 3. Fix remaining high severity bugs
/cxp:solve bug-missing-rate-limit

# 4. Address medium severity issues
/cxp:solve bug-session-timeout-missing
```

**Difference from /cxp:review**:
- **`/cxp:audit`**: Finds bugs, security vulnerabilities, crashes, performance issues
- **`/cxp:review`**: Finds refactoring opportunities, code quality improvements, tech debt

**Tools used**:
- Bandit (security scanner)
- Ruff (security + bug checks)
- Pyright (type safety)
- cProfile, py-spy (performance profiling)
- Manual code review by security expert

Launch the Bug Hunter agent with the specified scope.
