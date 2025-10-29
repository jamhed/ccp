# Claude Code Plugin Collection

Custom Claude Code plugins for Go and Kubernetes development workflows.

## go-k8s Plugin

Comprehensive toolkit for Go 1.23+ and Kubernetes operator development with specialized skills, agents, and commands.

### Skills

- **go-dev**: Expert Go development assistant covering modern Go 1.23+ idioms, fail-early patterns, error handling, and Kubernetes operator patterns
- **chainsaw-tester**: E2E testing expert for Kubernetes operators using Chainsaw, JP assertions, webhook validation, and mock services
- **github-cicd**: CI/CD pipeline specialist for GitHub Actions workflows, Docker builds, semantic versioning, and Kubernetes deployments
- **web-doc**: Fetches and caches technical documentation locally in `docs/web/` for offline reference

### Agents

Multi-phase problem-solving workflow agents:

- **Problem Validator**: Validates issues, proposes solution approaches, and develops test cases
- **Solution Reviewer**: Critically evaluates solutions and selects optimal approach
- **Solution Implementer**: Implements fixes using modern Go best practices
- **Code Reviewer & Tester**: Reviews code quality, runs linters and tests
- **Documentation Updater**: Creates solution documentation and git commits

### Commands

- **/solve**: Orchestrates the complete problem-solving workflow from validation through implementation to documentation

## Issues Folder Structure

The workflow expects issues to be organized in a structured directory format:

```
issues/[issue-name]/
├── problem.md          # Issue definition (Status: OPEN → RESOLVED)
└── solution.md         # Created by Documentation Updater after resolution
```

### problem.md Format

```markdown
**Status**: OPEN
**Severity**: [High|Medium|Low]
**Location**: [source file path]
**Impact**: [description]

## Problem Description
[Detailed description of the issue]

## Recommended Fix
[Optional: suggested approach]
```

### solution.md (Auto-generated)

Created by the Documentation Updater agent with:
- Problem Summary
- Solution Approach (selected from alternatives)
- Implementation Details
- Code Changes (files modified)
- Testing Results (unit tests, E2E tests, linting)
- Build Status
- Related Issues
- Commit Information

## Install

```sh
# add marketplace
/plugin marketplace add jamhed/ccp

# install go-k8s plugin
/plugin install go-k8s@ccp
```