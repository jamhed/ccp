# CXP - Python Development Plugin

AI-powered Python development plugin with structured problem-solving workflows.

## Features

- **Problem-Solving Workflow**: Multi-phase issue resolution with validation, review, and testing
- **Code Quality Tools**: Review and audit capabilities for Python codebases
- **Modern Python**: Python 3.14+ support with latest language features

## Commands

- `/cxp:problem [description]` - Research and define a new problem
- `/cxp:refine [issue-name]` - Enhance existing problem definition
- `/cxp:solve [issue-name]` - Execute complete solution workflow
- `/cxp:implement [issue-name]` - Implement approved solution
- `/cxp:review [scope]` - Perform code quality review
- `/cxp:audit [scope]` - Conduct bug hunting audit

## Skills

- `cxp:python-developer` - Expert Python development assistance
- `cxp:python-tester` - Testing strategy and implementation
- `cxp:fastapi-dev` - FastAPI development expertise

See [main documentation](../README.md#problem-solving-approach) for complete workflow details.

## Requirements

- Python 3.14+
- Claude Code CLI

## Quick Start

```bash
# Define a problem
/cxp:problem "Add user authentication to API"

# Solve the problem
/cxp:solve user-authentication

# Review code quality
/cxp:review src/
```
