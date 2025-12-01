# Claude Code Plugin Collection - Development Guide

This document provides quick references for working with the Claude Code Plugin Collection (CCP) codebase.

## Project Overview

**Repository**: Claude Code Plugin Collection (CCP)
**Purpose**: Multi-language plugin marketplace for Claude Code with AI-powered problem-solving workflows
**Languages**: Python 3.14+, TypeScript 5.7+, Go 1.23+

## Documentation Structure

### Main Documentation

- **[README.md](./README.md)** - Project overview, installation, quick start guide
- **[docs/web/](docs/web/)** - Cached web documentation for offline reference

### Cached Web Documentation

The [docs/web/](docs/web/) directory contains cached technical documentation:

- [anthropic-skills.md](docs/web/anthropic-skills.md) - Claude Code skills documentation
- [anthropic-agent-sdk-overview.md](docs/web/anthropic-agent-sdk-overview.md) - Agent SDK overview
- [anthropic-agent-skills.md](docs/web/anthropic-agent-skills.md) - Agent skills patterns
- [anthropic-tool-use.md](docs/web/anthropic-tool-use.md) - Tool use best practices
- [anthropic-prompt-engineering.md](docs/web/anthropic-prompt-engineering.md) - Prompt engineering guide
- [issue-management-patterns.md](docs/web/issue-management-patterns.md) - Issue management patterns
- [claude-md-best-practices.md](docs/web/claude-md-best-practices.md) - CLAUDE.md optimization guide
- [prompt-learning-agent-optimization.md](docs/web/prompt-learning-agent-optimization.md) - Prompt learning and agent design

**Note**: Always check cached docs before fetching from web (use `cx:web-doc` skill for new fetches).


## Problem-Solving Workflows

All plugins follow a multi-phase workflow:

1. **Problem Research** → `issues/[issue-name]/problem.md`
2. **Problem Validation** → `issues/[issue-name]/validation.md`
3. **Solution Proposal** → `issues/[issue-name]/proposals.md`
4. **Solution Review** → `issues/[issue-name]/review.md`
5. **Implementation** → `issues/[issue-name]/implementation.md`
6. **Testing & Review** → `issues/[issue-name]/testing.md`
7. **Documentation** → `issues/[issue-name]/solution.md` + git commit

**Follow-up Actions** (manual or automated):
- **Archive Issue** → Move `issues/[issue-name]/` to `archive/[issue-name]/`
- **Process Follow-ups** → Create new issues from refactoring opportunities in `testing.md`
- **External Review** → Use Codex/OpenCode for additional code review

### Language-Specific Workflows

**Python (cxp)**:
```bash
/cxp:problem [description]    # Research and define problem
/cxp:refine [issue-name]      # Enhance problem definition
/cxp:solve [issue-name]       # Execute full workflow
/cxp:review [scope]           # Code quality review
/cxp:audit [scope]            # Bug audit
```

**TypeScript (cxt)**:
```bash
/cxt:problem [description]    # Research and define problem
/cxt:refine [issue-name]      # Enhance problem definition
/cxt:solve [issue-name]       # Execute full workflow
```

**Go (cxg)**:
```bash
/cxg:problem [description]    # Research and define problem
/cxg:refine [issue-name]      # Enhance problem definition
/cxg:solve [issue-name]       # Execute full workflow
```

**Ark YAML Agents (cxa)**:
```bash
/cxa:problem [description]    # Research and define YAML agent problem
/cxa:refine [issue-name]      # Enhance problem definition
/cxa:solve [issue-name]       # Execute full workflow (propose, review, implement)
```

The cxa plugin is specialized for developing YAML-based Ark agents. It includes:
- `cxa:ark-agent-dev` skill with comprehensive patterns (agents, tools, teams, templates)
- Project search to find existing conventions in the current codebase

## File Naming Conventions

**CRITICAL**: All issue-related files use lowercase names:

✅ **Correct**:
- `problem.md`
- `solution.md`
- `validation.md`
- `review.md`
- `implementation.md`
- `testing.md`

❌ **Incorrect**:
- `Problem.md`
- `PROBLEM.md`
- `Solution.MD`

## Best Practices for Development

### Working with Agents

1. **Read existing agents** in `[plugin]/agents/` before modifying
2. **Check for common patterns** - many agents share reference sections
3. **Use skills** for reusable knowledge instead of duplicating in agents
4. **Follow naming conventions** - lowercase filenames, kebab-case directories

### Working with Skills

1. **Read SKILL.md** in each skill directory for detailed documentation
2. **Reference skills from agents** using `Skill([skill-name])` pattern
3. **Check cached web docs** before fetching new documentation
4. **Skills are scoped** - use `cxp:skill-name`, `cxt:skill-name`, etc.

### Working with Commands

1. **Commands are slash commands** - `/cxp:command`, `/cxt:command`, etc.
2. **Command definitions** in `[plugin]/commands/` directory
3. **Commands invoke agents** in sequence for multi-phase workflows

### Fetching Web Documentation

Use the `cx:web-doc` skill:

```bash
# Check cache first (docs/web/)
ls docs/web/

# If not cached or outdated (>30 days), fetch and cache
Use cx:web-doc skill to fetch [URL or topic]
```

