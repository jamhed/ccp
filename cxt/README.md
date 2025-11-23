# CXT - TypeScript Development Plugin

AI-powered TypeScript/Node.js development plugin with structured problem-solving workflows.

## Features

- **Problem-Solving Workflow**: Multi-phase issue resolution with validation, review, and testing
- **Modern TypeScript**: TypeScript 5.7+ support with latest language features
- **Node.js Integration**: Full Node.js ecosystem support

## Commands

- `/cxt:problem [description]` - Research and define a new problem
- `/cxt:refine [issue-name]` - Enhance existing problem definition
- `/cxt:solve [issue-name]` - Execute complete solution workflow

## Skills

- `cxt:typescript-dev` - Expert TypeScript development assistance
- `cxt:jest-tester` - Jest testing framework expertise

## Workflow

1. **Problem Research** → `issues/[name]/problem.md`
2. **Problem Validation** → `issues/[name]/validation.md`
3. **Solution Proposals** → `issues/[name]/proposals.md`
4. **Solution Review** → `issues/[name]/review.md`
5. **Implementation** → `issues/[name]/implementation.md`
6. **Testing & Review** → `issues/[name]/testing.md`
7. **Documentation** → `archive/[name]/solution.md`

## Requirements

- TypeScript 5.7+
- Node.js
- Claude Code CLI

## Quick Start

```bash
# Define a problem
/cxt:problem "Implement real-time notifications"

# Solve the problem
/cxt:solve real-time-notifications
```
