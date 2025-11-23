# CXG - Go Development Plugin

AI-powered Go development plugin with structured problem-solving workflows.

## Features

- **Problem-Solving Workflow**: Multi-phase issue resolution with validation, review, and testing
- **Modern Go**: Go 1.23+ support with latest language features
- **CI/CD Integration**: GitHub Actions and testing automation

## Commands

- `/cxg:problem [description]` - Research and define a new problem
- `/cxg:refine [issue-name]` - Enhance existing problem definition
- `/cxg:solve [issue-name]` - Execute complete solution workflow

## Skills

- `cxg:go-dev` - Expert Go development assistance
- `cxg:chainsaw-tester` - Go testing framework expertise
- `cxg:github-cicd` - GitHub CI/CD workflow integration

## Workflow

1. **Problem Research** → `issues/[name]/problem.md`
2. **Problem Validation** → `issues/[name]/validation.md`
3. **Solution Proposals** → `issues/[name]/proposals.md`
4. **Solution Review** → `issues/[name]/review.md`
5. **Implementation** → `issues/[name]/implementation.md`
6. **Testing & Review** → `issues/[name]/testing.md`
7. **Documentation** → `archive/[name]/solution.md`

## Requirements

- Go 1.23+
- Claude Code CLI

## Quick Start

```bash
# Define a problem
/cxg:problem "Add gRPC server implementation"

# Solve the problem
/cxg:solve grpc-server
```
