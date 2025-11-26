# CXT - TypeScript Development Plugin

AI-powered TypeScript/Node.js development plugin with structured problem-solving workflows.

## Features

- **Problem-Solving Workflow**: Multi-phase issue resolution with validation, proposals, review, implementation, and testing
- **Modern TypeScript**: TypeScript 5.7+ support with latest language features (satisfies, branded types, zod)
- **Node.js Integration**: Full Node.js ecosystem support with ESM-first patterns
- **Vitest Testing**: Type tests with expectTypeOf, explicit imports, coverage

## Commands

- `/cxt:problem [description]` - Research and define a new problem
- `/cxt:refine [issue-name]` - Enhance existing problem definition
- `/cxt:solve [issue-name]` - Execute complete solution workflow

## Workflow Agents

The `/cxt:solve` command executes these agents sequentially:

1. **Problem Validator** → `validation.md` - Confirms issue, creates failing test
2. **Solution Proposer** → `proposals.md` - Researches and proposes 3-4 solutions
3. **Solution Reviewer** → `review.md` - Selects best approach with guidance
4. **Solution Implementer** → `implementation.md` - Implements the fix
5. **Code Reviewer & Tester** → `testing.md` - Reviews, tests, finds bugs
6. **Documentation Updater** → `solution.md` - Documents and commits

## Skills

- `cxt:typescript-developer` - Expert TypeScript 5.7+ development assistance
- `cxt:jest-tester` - Vitest testing framework expertise with type tests

See [main documentation](../README.md#problem-solving-approach) for complete workflow details.

## Requirements

- TypeScript 5.7+
- Node.js 20+
- pnpm (recommended)
- Claude Code CLI

## Quick Start

```bash
# Define a problem
/cxt:problem "Implement real-time notifications"

# Solve the problem
/cxt:solve real-time-notifications
```

## Audit Trail

Each solve creates documentation in `issues/[issue-name]/`:

```
issues/[issue-name]/
├── problem.md        # Initial problem definition
├── validation.md     # Problem validation and test case
├── proposals.md      # 3-4 solution proposals with research
├── review.md         # Solution selection and guidance
├── implementation.md # Implementation report
├── testing.md        # Test results and review findings
└── solution.md       # Final documentation
```
