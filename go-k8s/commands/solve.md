When given a problem in issues/$ARGUMENTS/problem.md:

REQUIRED: Execute ALL agents in this exact order:
1. Problem Validator - validate issue and propose solutions
  - If "NOT A BUG": creates solution.md and STOPS
  - If confirmed: continues to step 2
2. Solution Reviewer - select best approach
3. Solution Implementer - implement the fix
4. Code Reviewer & Tester - review and test
5. Documentation Updater - MANDATORY: create solution.md and commit

IMPORTANT: You MUST invoke the Documentation Updater agent.
Do NOT commit changes yourself. Let Documentation Updater handle it.
