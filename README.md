# Claude Code Plugin Collection

Custom Claude Code plugins for modern software development workflows with AI-powered problem-solving agents.

## Problem-Solving Approach

All plugins follow a systematic 7-phase workflow:

1. **Problem Research** → `issues/[name]/problem.md`
2. **Problem Validation** → `issues/[name]/validation.md` (failing tests that prove the problem)
3. **Solution Proposals** → `issues/[name]/proposals.md` (3-4 solution approaches)
4. **Solution Review** → `issues/[name]/review.md` (pros/cons analysis, recommendation)
5. **Implementation** → `issues/[name]/implementation.md` (code changes)
6. **Testing & Review** → `issues/[name]/testing.md` (test results, code review)
7. **Documentation** → `archive/[name]/solution.md` (final summary + git commit)

This approach ensures systematic problem-solving with complete audit trails, TDD validation, and autonomous multi-agent coordination from issue identification to resolution.

### Helper Agents (Python)

The Python plugin (cxp) includes additional agents for proactive code quality improvement:

- **Bug Hunter** (`/cxp:audit`) - Comprehensive bug audit that scans code for logic errors, edge cases, overlooked issues, and potential bugs. Creates problem.md files for each issue found.
- **Code Quality Reviewer** (`/cxp:review`) - Proactive code quality review identifying refactoring opportunities, code duplication, complexity issues, and areas for improvement. Creates problem.md files for refactoring tasks.

These agents help maintain code quality by identifying issues before they become problems, generating actionable problem definitions ready for the `/cxp:solve` workflow.

### Skills Architecture

Skills are reusable knowledge modules shared among agents:

**Global Skills** (cx plugin):
- `cx:issue-manager` - Issue lifecycle management (list, archive, solve-unsolved)
- `cx:web-doc` - Web documentation fetching and caching

**Python Skills** (cxp plugin):
- `cxp:python-developer` - Modern Python development patterns and best practices
- `cxp:python-tester` - Testing strategies, frameworks, and async testing patterns
- `cxp:fastapi-dev` - FastAPI development expertise
- `cxp:issue-management` - Python-specific issue workflow patterns

**TypeScript Skills** (cxt plugin):
- `cxt:typescript-dev` - TypeScript development patterns and type system expertise
- `cxt:jest-tester` - Jest testing framework and patterns

**Go Skills** (cxg plugin):
- `cxg:go-dev` - Go development patterns and best practices
- `cxg:chainsaw-tester` - Chainsaw E2E testing for Kubernetes
- `cxg:github-cicd` - GitHub Actions CI/CD workflows

Skills are referenced by agents to access specialized knowledge without duplication, ensuring consistency across the multi-agent workflow.

## Available Plugins

### cx - Core Cross-Language Utilities

Core plugin providing shared utilities used across all CCP plugins.

**Shared Skills**:
- Issue management (list, archive, refine)
- Documentation fetching and caching

[**→ View cx Documentation**](cx/README.md)

### cxg - Go & Kubernetes Development

Multi-phase problem-solving workflow for Go 1.23+ and Kubernetes operator development.

**Key Features**:
- Problem identification and research
- Multi-agent workflow from validation to implementation
- Go best practices enforcement (generics, fail-early, error wrapping)
- Kubernetes operator patterns (controller-runtime, CRDs, webhooks)
- E2E testing with Chainsaw

[**→ View cxg Documentation**](cxg/README.md)

### cxp - Python Development

Multi-phase problem-solving workflow for modern Python 3.11+ development.

**Key Features**:
- Problem identification and research
- Multi-agent workflow from validation to implementation
- Python best practices enforcement (type hints, async/await, pattern matching)
- FastAPI patterns (Pydantic, dependency injection, async routes)
- Code quality review and bug hunting agents

[**→ View cxp Documentation**](cxp/README.md)

### cxt - TypeScript & Node.js Development

Multi-phase problem-solving workflow for modern TypeScript 5.0+ and Node.js development.

**Key Features**:
- Problem identification and research
- Multi-agent workflow from validation to implementation
- TypeScript best practices enforcement (strict mode, type narrowing, async patterns)
- Framework support (React, Vue, Express, NestJS)
- Testing with Jest/Vitest

[**→ View cxt Documentation**](cxt/README.md)

## Problem-Solving Workflow

All plugins share a common multi-phase workflow for systematic problem-solving:

### 1. Define the Problem

Identify and research issues in your codebase:

```bash
# Go projects
/cxg:problem [description]

# Python projects
/cxp:problem [description]

# TypeScript projects
/cxt:problem [description]
```

**Output**: Creates `issues/[issue-name]/problem.md` with evidence, context, and acceptance criteria.

### 2. Refine (Optional)

Enhance problem definitions with additional research:

```bash
# Go projects
/cxg:refine [issue-name]

# Python projects
/cxp:refine [issue-name]

# TypeScript projects
/cxt:refine [issue-name]
```

**Output**: Updates `issues/[issue-name]/problem.md` with deeper analysis.

### 3. Solve

Execute the complete multi-phase workflow:

```bash
# Go projects
/cxg:solve [issue-name]

# Python projects
/cxp:solve [issue-name]

# TypeScript projects
/cxt:solve [issue-name]
```

**Workflow Phases**:
1. **Problem Validator** - Validates issue with tests → `validation.md`
2. **Solution Proposer** - Proposes multiple solution approaches → `proposals.md`
3. **Solution Reviewer** - Evaluates and selects best approach → `review.md`
4. **Solution Implementer** - Implements fix with best practices → `implementation.md`
5. **Code Reviewer & Tester** - Reviews code, runs tests → `testing.md`
6. **Documentation Updater** - Creates summary and git commit → `solution.md`

**Output**: Complete audit trail in `archive/[issue-name]/` with all phase documentation.

### 4. Code Quality (Python only)

Additional Python-specific workflows:

```bash
# Proactive code quality review
/cxp:review [scope]

# Comprehensive bug audit
/cxp:audit [scope]
```

**Output**: Multiple actionable issues ready for `/cxp:solve` workflow.

## Issue Management System

All plugins use a unified issue tracking system:

### Directory Structure

**Active Issues**:
```
issues/[issue-name]/
└── problem.md          # Issue definition (Status: OPEN)
```

**Workflow In Progress**:
```
issues/[issue-name]/
├── problem.md          # Original issue
├── validation.md       # Problem Validator output
├── proposals.md        # Solution Proposer output
├── review.md           # Solution Reviewer output
├── implementation.md   # Solution Implementer output
└── testing.md          # Code Reviewer & Tester output
```

**Archived (Solved)**:
```
archive/[issue-name]/
├── problem.md          # Original issue (Status: RESOLVED)
├── validation.md       # Audit trail
├── proposals.md        # Audit trail
├── review.md           # Audit trail
├── implementation.md   # Audit trail
├── testing.md          # Audit trail
└── solution.md         # Final summary
```

### Workflow Files

Each phase creates comprehensive documentation:

| File | Purpose | Contains |
|------|---------|----------|
| **problem.md** | Issue definition | Context, evidence, acceptance criteria (from research/refine) |
| **validation.md** | Problem validation | Failing tests that prove the problem exists (TDD) |
| **proposals.md** | Solution proposals | 3-4 solution approaches with detailed descriptions |
| **review.md** | Solution selection | Pros/cons analysis, complexity/risk evaluation, recommendation |
| **implementation.md** | Code changes | Files modified, design patterns, edge cases |
| **testing.md** | Quality assurance | Test results, linting, code review findings |
| **solution.md** | Final summary | Problem, solution, changes, commit info |

## Installation

```bash
# Add marketplace
/plugin marketplace add jamhed/ccp

# Install core utilities (optional - automatically available with any plugin)
/plugin install cx@ccp

# Install language-specific plugins
/plugin install cxg@ccp  # Go/Kubernetes
/plugin install cxp@ccp  # Python
/plugin install cxt@ccp  # TypeScript/Node.js
```

**Note**: The `cx` plugin provides shared skills (issue-manager, web-doc) used by all language-specific plugins.

After installation, check `~/.claude/plugins/marketplace` folder. To update, pull latest changes and restart Claude.

## Quick Start

### Go Project Example

```bash
# 1. Identify problem
/cxg:problem telemetry spans exceeding attribute limits

# 2. Solve with full workflow
/cxg:solve bug-telemetry-attribute-limit

# Result: Issue validated, solution selected, implemented, tested, committed, and archived
```

### Python Project Example

```bash
# 1. Identify problem
/cxp:problem async exception handling in user endpoint

# 2. Solve with full workflow
/cxp:solve bug-async-unhandled-exception

# Result: Issue validated, solution selected, implemented, tested, committed, and archived
```

### Python Code Quality Example

```bash
# 1. Review code for refactoring opportunities
/cxp:review services/user

# 2. Audit for bugs and oversights
/cxp:audit services/user

# 3. Solve generated issues
/cxp:solve refactor-split-user-service
/cxp:solve bug-missing-none-check
```

### TypeScript Project Example

```bash
# 1. Identify problem
/cxt:problem unhandled promise rejection in user service

# 2. Solve with full workflow
/cxt:solve bug-unhandled-promise-rejection

# Result: Issue validated, solution selected, implemented, tested, committed, and archived
```

## Plugin Comparison

| Feature | cxg (Go/K8s) | cxp (Python) | cxt (TypeScript) |
|---------|-------------|--------------|------------------|
| **Language** | Go 1.23+ | Python 3.11+ | TypeScript 5.0+ |
| **Package Manager** | go mod | UV (10-100x faster than pip) | npm/pnpm/yarn |
| **Type System** | Generics, interfaces | Type hints, Protocol | Strict mode, utility types |
| **Async** | Goroutines, channels | async/await, asyncio | async/await, Promises |
| **Web Frameworks** | Kubernetes operators | FastAPI, Django | Express, NestJS, Next.js |
| **Frontend** | - | - | React, Vue |
| **Testing** | go test, Chainsaw E2E | pytest (parallel), pytest-asyncio | Jest, Vitest, Testing Library |
| **Linting** | golangci-lint | ruff (check + format) | ESLint + Prettier |
| **Type Checking** | go vet | pyright | tsc --noEmit |
| **Error Handling** | Error wrapping with %w | Exception chaining with `from` | Try/catch with typed errors |
| **Data Validation** | Custom validation | Pydantic models | class-validator, zod |
| **Extra Agents** | - | Code Quality Reviewer, Bug Hunter | - |

## Key Benefits

### Systematic Problem-Solving
- Structured workflow from identification to resolution
- Complete audit trail for every phase
- Evidence-based decision making

### Quality Enforcement
- **Go**: Modern idioms, fail-early patterns, Kubernetes best practices
- **Python**: Type safety, async patterns, modern Python 3.11+ features
- **TypeScript**: Strict mode, type narrowing, async/await patterns

### Autonomous Execution
- Multi-agent coordination
- Automatic test execution and validation
- Git commit creation with documentation

### Comprehensive Testing
- **Go**: Unit tests, E2E Chainsaw tests, golangci-lint
- **Python**: pytest (parallel), pyright type checking, ruff linting
- **TypeScript**: Jest/Vitest, tsc type checking, ESLint

## Documentation

- [**cx Plugin**](cx/README.md) - Core shared utilities (issue management, documentation)
- [**cxg Plugin**](cxg/README.md) - Go & Kubernetes development
  - [cxg Agents](cxg/agents/README.md) - Detailed agent documentation
- [**cxp Plugin**](cxp/README.md) - Python development
  - [cxp Agents](cxp/agents/README.md) - Detailed agent documentation
- [**cxt Plugin**](cxt/README.md) - TypeScript & Node.js development
  - [cxt Agents](cxt/agents/README.md) - Detailed agent documentation

## Contributing

This is part of the Claude Code Plugin Collection. Contributions welcome at https://github.com/jamhed/ccp
