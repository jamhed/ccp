When given a problem in issues/$ARGUMENTS/problem.md:

REQUIRED: Execute ALL agents SEQUENTIALLY in this exact order. Wait for each agent to complete before starting the next.

1. Problem Validator - validate issue and create test case (saves validation.md)
  - WAIT for completion before proceeding
  - If "NOT A BUG": creates solution.md and SKIP to step 6
  - If confirmed: continue to step 2

2. Solution Proposer - research and propose 3-4 solutions (saves proposals.md)
  - WAIT for completion before proceeding
  - Reads validation.md from step 1
  - Continue to step 3

3. Solution Reviewer - select best approach (saves review.md)
  - WAIT for completion before proceeding
  - Reads proposals.md from step 2
  - Continue to step 4

4. Solution Implementer - implement the fix (saves implementation.md)
  - WAIT for completion before proceeding
  - Reads review.md from step 3
  - Continue to step 5

5. Code Reviewer & Tester - review, test, find bugs, identify refactoring opportunities (saves testing.md)
  - WAIT for completion before proceeding
  - Reads implementation.md from step 4
  - Continue to step 6

6. Documentation Updater - MANDATORY: document solution, create follow-up issues if needed, commit changes
  - Reads testing.md from step 5
  - Creates solution.md, commits, and creates follow-up issues

CRITICAL EXECUTION RULES:
- Execute agents ONE AT A TIME in a single message per agent
- WAIT for each agent to return results before invoking the next agent
- Do NOT invoke multiple agents in parallel
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
