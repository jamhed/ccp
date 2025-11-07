When given a problem in issues/$ARGUMENTS/problem.md:

REQUIRED: Execute ALL agents in this exact order:
1. Problem Validator - validate issue and create test case (saves validation.md)
  - If "NOT A BUG": creates solution.md and skips to step 6
  - If confirmed: continues to step 2
2. Solution Proposer - research and propose 3-4 solutions (saves proposals.md)
3. Solution Reviewer - select best approach (saves review.md)
4. Solution Implementer - implement the fix (saves implementation.md)
5. Code Reviewer & Tester - review, test, find bugs, identify refactoring opportunities (saves testing.md)
6. Documentation Updater - MANDATORY: document solution, create follow-up issues if needed, commit changes

IMPORTANT:
- You MUST invoke the Documentation Updater agent
- Do NOT commit changes yourself. Let Documentation Updater handle it
- Documentation Updater will create follow-up issues for refactoring opportunities found in testing.md

Each agent creates an audit trail file in the issue directory:
- validation.md - Problem Validator findings (status, test case)
- proposals.md - Solution Proposer research and proposals (3-4 solutions)
- review.md - Solution Reviewer analysis and selection
- implementation.md - Implementation report (code changes)
- testing.md - Code review, test results, refactoring opportunities
- solution.md - Final documentation (summary)

Follow-up issues (if refactoring opportunities found):
- issues/[follow-up-issue-name]/problem.md - New refactoring issue
