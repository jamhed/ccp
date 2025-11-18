# Claude Code Plugin Collection

Custom Claude Code plugins for modern software development workflows with AI-powered problem-solving agents.

## Available Plugins

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

## Problem-Solving Workflow

Both plugins share a common multi-phase workflow for systematic problem-solving:

### 1. Define the Problem

Identify and research issues in your codebase:

```bash
# Go projects
/cxg:problem [description]

# Python projects
/cxp:problem [description]
```

**Output**: Creates `issues/[issue-name]/problem.md` with evidence, context, and acceptance criteria.

### 2. Refine (Optional)

Enhance problem definitions with additional research:

```bash
# Go projects
/cxg:refine [issue-name]

# Python projects
/cxp:refine [issue-name]
```

**Output**: Updates `issues/[issue-name]/problem.md` with deeper analysis.

### 3. Solve

Execute the complete multi-phase workflow:

```bash
# Go projects
/cxg:solve [issue-name]

# Python projects
/cxp:solve [issue-name]
```

**Workflow Phases**:
1. **Problem Validator** - Validates issue, proposes multiple solutions → `validation.md`
2. **Solution Reviewer** - Evaluates and selects best approach → `review.md`
3. **Solution Implementer** - Implements fix with best practices → `implementation.md`
4. **Code Reviewer & Tester** - Reviews code, runs tests → `testing.md`
5. **Documentation Updater** - Creates summary and git commit → `solution.md`

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

Both plugins use a unified issue tracking system:

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
├── review.md           # Solution Reviewer output
├── implementation.md   # Solution Implementer output
└── testing.md          # Code Reviewer & Tester output
```

**Archived (Solved)**:
```
archive/[issue-name]/
├── problem.md          # Original issue (Status: RESOLVED)
├── validation.md       # Audit trail
├── review.md           # Audit trail
├── implementation.md   # Audit trail
├── testing.md          # Audit trail
└── solution.md         # Final summary
```

### Workflow Files

Each phase creates comprehensive documentation:

| File | Purpose | Contains |
|------|---------|----------|
| **problem.md** | Issue definition | Context, evidence, acceptance criteria |
| **validation.md** | Problem validation | Issue confirmation, proposed solutions (A/B/C), pros/cons |
| **review.md** | Solution selection | Complexity/risk analysis, recommendation, justification |
| **implementation.md** | Code changes | Files modified, design patterns, edge cases |
| **testing.md** | Quality assurance | Test results, linting, code review findings |
| **solution.md** | Final summary | Problem, solution, changes, commit info |

## Installation

```bash
# Add marketplace
/plugin marketplace add jamhed/ccp

# Install Go/Kubernetes plugin
/plugin install cxg@ccp

# Install Python plugin
/plugin install cxp@ccp
```

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

## Key Benefits

### Systematic Problem-Solving
- Structured workflow from identification to resolution
- Complete audit trail for every phase
- Evidence-based decision making

### Quality Enforcement
- **Go**: Modern idioms, fail-early patterns, Kubernetes best practices
- **Python**: Type safety, async patterns, modern Python 3.11+ features

### Autonomous Execution
- Multi-agent coordination
- Automatic test execution and validation
- Git commit creation with documentation

### Comprehensive Testing
- **Go**: Unit tests, E2E Chainsaw tests, golangci-lint
- **Python**: pytest (parallel), pyright type checking, ruff linting

## Documentation

- [**cxg Plugin**](cxg/README.md) - Go & Kubernetes development
  - [cxg Agents](cxg/agents/README.md) - Detailed agent documentation
- [**cxp Plugin**](cxp/README.md) - Python development
  - [cxp Agents](cxp/agents/README.md) - Detailed agent documentation

## Contributing

This is part of the Claude Code Plugin Collection. Contributions welcome at https://github.com/jamhed/ccp
