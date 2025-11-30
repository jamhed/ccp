---
name: claude-md-writer
description: Expert for writing and optimizing CLAUDE.md files. Use when user asks to "create CLAUDE.md", "improve CLAUDE.md", "optimize my claude config", "review claude.md" or needs help configuring Claude Code for a project. Applies research-backed best practices for concise, effective project context.
---

# Claude MD Writer

Expert assistant for creating and optimizing CLAUDE.md files based on research-backed best practices. Helps configure Claude Code for maximum effectiveness by crafting concise, universally-applicable project context.

## Core Principle

**LLMs are stateless** - Claude starts each session with zero codebase knowledge. CLAUDE.md is the only file automatically included in every conversation, making it critical real estate that must be optimized carefully.

## Critical Constraints

### Instruction Budget
- Frontier LLMs reliably follow ~150-200 instructions
- Claude Code's system prompt uses ~50 instructions
- **You have ~100-150 instructions remaining** for CLAUDE.md
- Smaller models degrade much faster with instruction overload

### Length Targets
| Quality | Lines | Use Case |
|---------|-------|----------|
| Optimal | <60 | Small to medium projects |
| Good | <150 | Large projects, monorepos |
| Maximum | <300 | Complex enterprise codebases |

### The Ignore Problem
Claude Code's system includes guidance to **disregard context unless highly relevant**. Overstuffed CLAUDE.md files cause valuable guidance to be ignored entirely.

## What to Include (WHY, WHAT, HOW)

### 1. WHAT - Project Structure
```markdown
## Project Overview
- Tech stack: [frameworks, languages, key dependencies]
- Architecture: [monorepo structure, app boundaries]
- Key directories: [src/, tests/, docs/ purposes]
```

### 2. WHY - Project Purpose
```markdown
## Context
- What this project does
- Why certain patterns exist
- Non-obvious design decisions
```

### 3. HOW - Working Instructions
```markdown
## Commands
- `npm run build` - Build the project
- `npm run test` - Run test suite
- `npm run typecheck` - Type checking

## Workflow
- Run typecheck after code changes
- Use single test runs over full suite
```

## What to AVOID

### Never Include

| Anti-Pattern | Why It's Bad | Alternative |
|--------------|--------------|-------------|
| Code style guidelines | LLMs are in-context learners | Use linters + hooks |
| Task-specific instructions | Distracts on unrelated tasks | Separate files |
| Code snippets | Become stale | File references |
| Auto-generated content | Suboptimal, untested | Manual curation |
| Sensitive credentials | Security risk | Environment variables |
| Excessive comments | Wastes instruction budget | Be concise |

### Style Guidelines Problem
**"LLMs are in-context learners!"** - They naturally adopt existing patterns from your codebase. Instead:
- Use deterministic tools (Biome, ESLint, Prettier)
- Configure Claude Code hooks for formatting
- Use Slash Commands to separate implementation from formatting

## Progressive Disclosure Pattern

Store task-specific guidance in separate files with brief pointers:

```markdown
## Documentation
For detailed guidance, see:
- `docs/architecture.md` - System design decisions
- `docs/testing.md` - Test patterns and conventions
- `docs/deployment.md` - Release procedures
```

**Prefer file references over code snippets** - they stay current.

## Workflow

### Creating New CLAUDE.md

1. **Analyze the codebase**:
   - Identify tech stack from package files
   - Map directory structure
   - Find existing documentation
   - Note common commands from scripts/Makefile

2. **Draft minimal content** focusing on:
   - Project purpose (1-2 sentences)
   - Tech stack (list format)
   - Key directories (brief descriptions)
   - Essential commands (build, test, lint)

3. **Apply constraints**:
   - Remove anything task-specific
   - Remove style guidelines
   - Convert code snippets to file references
   - Aim for <60 lines

4. **Add emphasis** where critical:
   - Use "IMPORTANT:" for must-follow rules
   - Use "NEVER:" for hard constraints
   - Keep emphasis rare (overuse dilutes impact)

### Improving Existing CLAUDE.md

1. **Audit current file**:
   - Count lines (target <60, max <300)
   - Identify task-specific content (remove)
   - Find style guidelines (remove, use linters)
   - Spot stale code snippets (convert to references)

2. **Extract to separate files**:
   - Move specialized guidance to `docs/`
   - Add brief pointers in CLAUDE.md
   - Create slash commands for repeated workflows

3. **Test effectiveness**:
   - Start fresh conversation
   - Verify Claude follows key instructions
   - Tune wording ("IMPORTANT", "MUST") for better adherence

## Templates

### Minimal Template (~30 lines)
```markdown
# Project Name

Brief description of what this project does.

## Tech Stack
- Language: [e.g., TypeScript 5.x]
- Framework: [e.g., Next.js 14]
- Testing: [e.g., Vitest]

## Commands
- `npm run dev` - Start development server
- `npm run build` - Production build
- `npm run test` - Run tests
- `npm run lint` - Lint and format

## Key Directories
- `src/` - Application source code
- `tests/` - Test files
- `docs/` - Documentation

## Important
- Run tests before committing
- Use TypeScript strict mode
```

### Standard Template (~60 lines)
```markdown
# Project Name

[1-2 sentence project description]

## Tech Stack
- Language: [version]
- Framework: [version]
- Database: [type]
- Testing: [framework]

## Architecture
[Brief architecture description - 2-3 sentences max]

## Commands
- `[command]` - [description]
- `[command]` - [description]
- `[command]` - [description]

## Key Directories
- `src/` - [purpose]
- `tests/` - [purpose]
- `docs/` - [purpose]

## Workflow
- [Key workflow step 1]
- [Key workflow step 2]
- [Key workflow step 3]

## Documentation
For detailed guidance:
- `docs/architecture.md` - Design decisions
- `docs/contributing.md` - Development guide

## Important
- [Critical rule 1]
- [Critical rule 2]
```

### Monorepo Template (~100 lines)
```markdown
# Monorepo Name

[Project description]

## Structure
```
apps/
  web/      - Next.js frontend
  api/      - Express backend
packages/
  shared/   - Shared utilities
  ui/       - Component library
```

## Tech Stack
- Frontend: [stack]
- Backend: [stack]
- Shared: [stack]

## Commands (Root)
- `pnpm dev` - Start all apps
- `pnpm build` - Build all packages
- `pnpm test` - Run all tests

## App-Specific
See CLAUDE.md in each app directory for specific guidance.

## Important
- Changes to `packages/` require rebuilding dependents
- Run `pnpm install` after pulling
```

## File Locations

CLAUDE.md can be placed in multiple locations:

| Location | Scope | Use Case |
|----------|-------|----------|
| `~/.claude/CLAUDE.md` | All projects | Personal preferences |
| `./CLAUDE.md` | Repository | Team-shared context |
| `./CLAUDE.local.md` | Repository (gitignored) | Personal overrides |
| `./subdir/CLAUDE.md` | Subdirectory | Component-specific |

**Hierarchy**: More specific (nested) files take priority when relevant.

## The # Key Shortcut

Press `#` during coding to have Claude incorporate instructions into CLAUDE.md automatically. Use for:
- Commands you just discovered
- Style preferences you want remembered
- Important codebase information

## Optimization Loop

For maximum effectiveness:

1. **Baseline**: Run Claude on representative tasks
2. **Evaluate**: Note where instructions aren't followed
3. **Tune**: Add emphasis ("IMPORTANT", "MUST", "NEVER")
4. **Test**: Verify improvements in fresh conversations
5. **Iterate**: Refine based on actual friction points

## Examples

### Good CLAUDE.md Entry
```markdown
## Commands
- `make test` - Run test suite (required before PR)
```

### Bad CLAUDE.md Entry
```markdown
## Testing Guidelines
When writing tests, always use descriptive names that follow
the pattern "should_[expected]_when_[condition]". Mock external
dependencies using the testutil package. Ensure 80% coverage...
[continues for 50 more lines]
```

**Why bad?** Task-specific, could be in `docs/testing.md`, wastes instruction budget.

## When to Use This Skill

**Use when user:**
- Asks to "create CLAUDE.md" or "write CLAUDE.md"
- Wants to "improve" or "optimize" their CLAUDE.md
- Says "configure Claude Code for my project"
- Mentions CLAUDE.md is "not working" or "being ignored"
- Wants to set up a new project for Claude Code

**Do NOT use for:**
- General Claude Code questions (use claude-code-guide agent)
- Creating other documentation files
- Writing code or tests

## References

### Cached Documentation (Read First)

For detailed best practices, read the cached documentation:
- **`docs/web/claude-md-best-practices.md`** - Comprehensive CLAUDE.md optimization guide

### Original Sources

This skill synthesizes best practices from:
- [Anthropic: Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [HumanLayer: Writing a Good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md)
- [Arize: CLAUDE.md Optimization with Prompt Learning](https://arize.com/blog/claude-md-best-practices-learned-from-optimizing-claude-code-with-prompt-learning/)
- [Claude Blog: Using CLAUDE.md Files](https://www.claude.com/blog/using-claude-md-files)
