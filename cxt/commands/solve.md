---
confirm: Are you ready to solve issue {{input}} using the complete multi-phase workflow? This will execute all agents sequentially: Problem Validator → Solution Reviewer → Solution Implementer → Code Reviewer & Tester → Documentation Updater. Each agent creates an audit trail file documenting its phase.
---

Execute the complete problem-solving workflow for TypeScript/Node.js projects.

**Phase 1: Problem Validator**
Task(cxt:Problem Validator): Validate the problem definition in issues/{{input}}/problem.md. Confirm the issue exists, propose multiple solution approaches (A, B, C), provide pros/cons for each, and create test cases to prove the issue exists.

**Phase 2: Solution Reviewer**
Task(cxt:Solution Reviewer): Review the proposed solutions from validation.md and select the optimal approach. Analyze complexity, risk, and effort for each solution. Provide a recommendation with clear justification and implementation guidance.

**Phase 3: Solution Implementer**
Task(cxt:Solution Implementer): Implement the selected solution using modern TypeScript best practices. Use type safety, async patterns, proper error handling, and create comprehensive implementation notes.

**Phase 4: Code Reviewer & Tester**
Task(cxt:Code Reviewer & Tester): Review the implementation for correctness and TypeScript best practices. Run linting (ESLint), type checking (tsc), tests (Jest/Vitest), and ensure no regressions.

**Phase 5: Documentation Updater**
Task(cxt:Documentation Updater): Create comprehensive solution.md summarizing the entire workflow. Generate a clean git commit with descriptive message, archive the issue to archive/{{input}}/, and mark it as RESOLVED.
