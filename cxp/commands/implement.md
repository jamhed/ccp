When given a problem in issues/$ARGUMENTS/problem.md:

REQUIRED: Execute ALL agents SEQUENTIALLY in this exact order. Wait for each agent to complete before starting the next.

1. Solution Implementer - implement the fix (saves implementation.md)
  - WAIT for completion before proceeding
  - Reads review.md
  - On retry: Also reads testing.md for issues found by tester
  - Continue to step 2

2. Code Reviewer & Tester - review, test, find bugs, identify refactoring opportunities (saves testing.md)
  - WAIT for completion before proceeding
  - Reads implementation.md from step 1
  - Tester MUST fix minor issues (test failures, bugs, type errors)
  - **DECISION POINT**: Check testing.md for blocking issues:
    - ✅ If implementation is complete and functional → Continue to step 3
    - ⚠️ If INCOMPLETE IMPLEMENTATION found → Return to step 1 (max 2 retries)
    - ⚠️ If FUNDAMENTAL DESIGN ISSUES found → Return to step 1 (max 2 retries)
    - ⚠️ If WRONG APPROACH (many test failures indicate design issue) → Return to step 1 (max 2 retries)
  - Continue to step 3 (or retry step 1 if blocking issues found)

3. Documentation Updater - MANDATORY: document solution, create follow-up issues if needed, commit changes
  - Reads testing.md from step 2
  - Creates solution.md, commits, and creates follow-up issues

CRITICAL EXECUTION RULES:
- Execute agents ONE AT A TIME in a single message per agent
- WAIT for each agent to return results before invoking the next agent
- Do NOT invoke multiple agents in parallel
- **RETRY MECHANISM**: After Code Reviewer & Tester (step 2):
  - Read testing.md to check for blocking issues
  - If INCOMPLETE IMPLEMENTATION, FUNDAMENTAL DESIGN ISSUES, or WRONG APPROACH → Retry step 1
  - Maximum 2 retries allowed (3 total attempts)
  - On retry: Implementer reads both review.md AND testing.md
- You MUST invoke the Documentation Updater agent
- Do NOT commit changes yourself. Let Documentation Updater handle it

Each agent creates an audit trail file in the issue directory:
- validation.md - Problem Validator findings (status, test case)
- proposals.md - Solution Proposer research and proposals (3-4 solutions)
- review.md - Solution Reviewer analysis and selection
- implementation.md - Implementation report (code changes)
- testing.md - Code review, test results, refactoring opportunities
- solution.md - Final documentation (summary)

Follow-up issues (if refactoring opportunities found):
- issues/[follow-up-issue-name]/problem.md - New refactoring issue
