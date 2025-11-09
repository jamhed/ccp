Perform comprehensive code quality review and create refactoring issues ready for `/cxp:solve` workflow.

**Scope**: $ARGUMENTS (file paths, module names, or "all" for entire codebase)

**What this does**:
1. **Analyzes code** for refactoring opportunities:
   - Code duplication across files
   - God classes/functions (complexity, SRP violations)
   - Architecture issues (tight coupling, missing patterns)
   - Type safety gaps (missing type hints)
   - Performance issues (N+1 queries, with profiling evidence)
   - Modern Python 3.14+ upgrade opportunities

2. **Creates individual issues** in `issues/` folder:
   - Each issue is a focused refactoring opportunity
   - Includes clear problem statement with evidence
   - Prioritized by impact and effort
   - Ready for `/cxp:solve [issue-name]` workflow

3. **Generates summary report**:
   - Lists all issues created with priorities
   - Identifies quick wins (high impact, low effort)
   - Provides recommended execution order
   - Estimates total impact if all issues resolved

**Output**:
- `issues/refactor-[name]/problem.md` - Individual refactoring issues
- `code-review-summary-[timestamp].md` - Summary report with recommendations

**Example Usage**:
- `/cxp:review services/user` - Review the user service module
- `/cxp:review app/api/handlers.py` - Review specific file
- `/cxp:review all` - Review entire codebase

**Example Workflow**:
```bash
# 1. Review code and create issues
/cxp:review services/user

# Output: Created 5 issues (3 high, 2 medium priority)
# - refactor-split-user-service-god-class
# - refactor-extract-validation-logic
# - refactor-add-type-hints-user-module
# - refactor-introduce-repository-pattern
# - refactor-use-dataclasses-user-models

# 2. Solve issues one at a time
/cxp:solve refactor-extract-validation-logic

# 3. Continue with other issues
/cxp:solve refactor-split-user-service-god-class
```

Launch the Code Quality Reviewer agent with the specified scope.
