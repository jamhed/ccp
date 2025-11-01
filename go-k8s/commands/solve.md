When given a problem in issues/$ARGUMENTS/problem.md:

REQUIRED: Execute ALL agents in this exact order:
1. Problem Validator - validate issue and propose solutions (saves validation.md)
  - If "NOT A BUG": creates solution.md and skips to step 5
  - If confirmed: continues to step 2
2. Solution Reviewer - select best approach (saves review.md)
3. Solution Implementer - implement the fix (saves implementation.md)
4. Code Reviewer & Tester - review and test (saves testing.md)
5. Documentation Updater - MANDATORY: commit changes (solution.md already created for rejections)

IMPORTANT: You MUST invoke the Documentation Updater agent.
Do NOT commit changes yourself. Let Documentation Updater handle it.

Each agent creates an audit trail file in the issue directory:
- validation.md - Problem Validator findings
- review.md - Solution Reviewer analysis
- implementation.md - Implementation report
- testing.md - Code review and test results
- solution.md - Final documentation (summary)
