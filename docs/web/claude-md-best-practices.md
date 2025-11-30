# CLAUDE.md Best Practices

**Sources:**
- https://www.anthropic.com/engineering/claude-code-best-practices
- https://www.humanlayer.dev/blog/writing-a-good-claude-md
- https://arize.com/blog/claude-md-best-practices-learned-from-optimizing-claude-code-with-prompt-learning/
- https://www.claude.com/blog/using-claude-md-files

**Fetched:** 2025-11-30

---

## Core Principle

LLMs are stateless functions with frozen weights that learn nothing over time. The only way Claude knows about your codebase is through tokens you provide. CLAUDE.md is the only file that by default goes into every single conversation you have with the agent.

### Three Critical Implications
1. Agents start each session with zero codebase knowledge
2. Important context must be communicated every session
3. CLAUDE.md serves as the primary onboarding mechanism

## What CLAUDE.md Should Cover

### WHAT
Describe your tech stack, project structure, and codebase map. This is especially crucial for monorepos—clarify which apps, shared packages, and components exist and their purposes.

### WHY
Explain the project's purpose and the function of different components.

### HOW
Provide instructions for working effectively, such as build tools, test procedures, verification methods, and compilation steps.

## File Locations

CLAUDE.md can be placed in multiple locations:

| Location | Scope | Use Case |
|----------|-------|----------|
| `~/.claude/CLAUDE.md` | All projects | Personal preferences |
| `./CLAUDE.md` | Repository root | Team-shared context (commit to git) |
| `./CLAUDE.local.md` | Repository (gitignored) | Personal overrides |
| Parent directories | Monorepo | Cascade into context |
| Child directories | Subdirectory | Component-specific (on-demand) |

**Hierarchy**: More specific (nested) files take priority when relevant.

## Critical Finding: Claude Often Ignores CLAUDE.md

The Claude Code system includes a reminder telling Claude to disregard context unless highly relevant to the current task. This means **overstuffing the file with non-universal instructions causes Claude to ignore valuable guidance.**

## Best Practices

### Keep Instructions Minimal

Research indicates frontier thinking LLMs follow approximately 150-200 instructions reliably. Smaller models get MUCH worse, MUCH more quickly. Since Claude Code's system prompt contains roughly 50 instructions, you have limited capacity remaining. Include only universally applicable directives.

### Optimize File Length

| Quality | Lines | Notes |
|---------|-------|-------|
| Optimal | <60 | HumanLayer's root file stays under 60 lines |
| Good | <150 | Larger projects |
| Maximum | <300 | Complex enterprise codebases |

Avoid task-specific instructions like database schema guidance that distract when working on unrelated features.

### Use Progressive Disclosure

Store task-specific guidance in separate markdown files:
- `building_the_project.md`
- `running_tests.md`
- `code_conventions.md`

Include pointers with brief descriptions and let Claude determine relevance.

**Prefer file references over code snippets.** They stay current rather than becoming outdated.

### Don't Make Claude Your Linter

Never include code style guidelines. LLMs are in-context learners! They naturally adopt existing patterns. Instead:
- Use deterministic tools like Biome, ESLint, Prettier
- Configure Claude Code hooks for formatting
- Use Slash Commands to separate implementation from formatting concerns

### Avoid Auto-Generation

Since CLAUDE.md affects every workflow phase, manually craft each line with care. Auto-generation produces suboptimal results.

## What to Include

According to Anthropic, CLAUDE.md should document:
- Common bash commands with descriptions
- Core files and utility functions
- Code style guidelines (but prefer linters)
- Testing instructions
- Repository etiquette (branch naming, merge vs. rebase preferences)
- Developer environment setup (e.g., pyenv use, compiler requirements)
- Project-specific behaviors or warnings
- Other information you want Claude to remember consistently

## Example Structure

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

## Key Directories
- `src/` - Application source code
- `tests/` - Test files
- `docs/` - Documentation

## Important
- Run tests before committing
- Use TypeScript strict mode
```

## The # Key Shortcut

Press `#` during coding to have Claude automatically incorporate instructions into CLAUDE.md. Use for:
- Commands you just discovered
- Style preferences you want remembered
- Important codebase information

Include CLAUDE.md changes in commits so team members benefit.

## Optimization Loop (Prompt Learning)

For maximum effectiveness:

1. **Baseline**: Run Claude on representative tasks
2. **Evaluate**: Note where instructions aren't followed
3. **Tune**: Add emphasis ("IMPORTANT", "MUST", "NEVER")
4. **Test**: Verify improvements in fresh conversations
5. **Iterate**: Refine based on actual friction points

### Research Results

From Arize's Prompt Learning research:
- General coding ability: +5.19% accuracy improvement across different repositories
- Repository-specific optimization: +10.87% improvement within same codebase

"No fine-tuning, no retraining, no custom infrastructure"—improvements came purely from refined instructions grounded in performance data.

## What NOT to Include

- Sensitive credentials or database connection strings
- Detailed security vulnerability information
- Task-specific instructions (move to separate files)
- Extensive code snippets (become stale)
- Auto-generated content (untested)
- Style guidelines (use linters instead)

## Advanced Configuration

### Custom Slash Commands
Store reusable prompts in `.claude/commands/` as markdown files with support for arguments (`$ARGUMENTS`, `$1`, `$2`).

### Subagents
Use isolated contexts for distinct project phases to prevent information interference between tasks.

### Context Management
Use `/clear` between distinct tasks to reset accumulated history while preserving CLAUDE.md.

## Common Mistakes

1. Adding extensive content without iterating on effectiveness
2. Not refining instructions over time
3. Including task-specific guidance that distracts on other tasks
4. Including code snippets that become stale
5. Failing to test whether documentation improves Claude's behavior
