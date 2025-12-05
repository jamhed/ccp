---
name: issue-manager
description: Manage project issues in the issues folder. List open issues, archive solved issues, and refine problem definitions. Use when user mentions "list issues", "archive issue", "manage issues", or when working with the issues/ directory.
---

# Issue Manager

Expert assistant for managing project issues stored in the `issues/` folder. Provides utilities to list open issues, archive solved issues to the archive folder, and refine problem definitions.

## Project Root Definition

**CRITICAL**: All issue management operations use the **Git repository root** as the base directory.

```bash
# Project root = Git repository root (directory containing .git/)
PROJECT_ROOT=$(git rev-parse --show-toplevel)
```

**ALWAYS use project root for**:
- `$PROJECT_ROOT/issues/` - All issue definitions (open issues)
- `$PROJECT_ROOT/archive/` - Archived/resolved issues

**NEVER create issues or archive folders in**:
- Subfolders of the project
- Current working directory (if different from project root)
- Package directories (e.g., `pkg/`, `internal/`, `src/`)

**Why this matters**:
- Ensures consistent issue location across all agents
- Prevents scattered issue folders in subprojects
- Makes issue discovery reliable (`issues/*/problem.md` always works from root)

## Archive Protection

**CRITICAL**: Never modify, edit, or delete files in `$PROJECT_ROOT/archive/`. Archived issues are read-only historical records.

- ✅ Read archived issues for reference
- ❌ Edit archived issues
- ❌ Delete archived issues
- ❌ Move files within archive

**Why this matters**:
- Archives serve as immutable audit trail of solved problems
- Historical context should be preserved exactly as it was when solved
- Prevents accidental corruption of completed work
- Supports reproducibility and learning from past solutions

## Script Execution

**IMPORTANT:** All scripts in this skill must be executed using the skill's base path. When this skill loads, you receive a "Base Path" (e.g., `Base Path: /path/to/skill/`). Use this path to construct full script paths:

```bash
# Pattern: {base_path}/scripts/<script-name>
# Example: /Users/name/.claude/plugins/ccp/cx/skills/issue-manager/scripts/list-open
```

Always prepend the base path when running any script from this skill.

## Core Capabilities

### 1. List Open Issues

List all open (non-archived) issues that have a `problem.md` file:

```bash
{base_path}/scripts/list-open
```

**When to use:**
- Need to see what issues are currently open
- Planning which issue to work on next
- Getting an overview of pending work

**How it works:**
- Scans the `issues/` directory for issue folders
- Identifies issues with a `problem.md` file
- Displays descriptive issue names (e.g., "agent-crd-embedding-in-tool", "query-message-observer")

### 2. List Solved Issues (Ready to Archive)

List all solved issues that have a `solution.md` file but haven't been archived yet:

```bash
{base_path}/scripts/list-solved
```

**When to use:**
- Need to see which issues are solved and ready to be archived
- Planning which solved issues to move to archive
- Getting an overview of completed work that needs cleanup
- Before running the archive script to see candidates

**How it works:**
- Scans the `issues/` directory for issue folders
- Identifies issues with a `solution.md` file (indicating completion)
- Displays descriptive issue names of solved issues
- These are candidates for archiving via the archive script

### 3. Archive Solved Issue

Archive a solved issue by moving it from `issues/` to `archive/`:

```bash
{base_path}/scripts/archive <issue-name>
```

**Example:**
```bash
{base_path}/scripts/archive agent-crd-embedding-in-tool
```

**When to use:**
- After successfully solving and verifying an issue
- Cleaning up completed work from the active issues list
- Maintaining a clear separation between open and closed issues

**How it works:**
- Validates the issue exists in `issues/`
- Creates the `archive/` directory if it doesn't exist
- Checks if an issue with the same name already exists in archive
- If duplicate exists, appends timestamp (YYYYMMDD-HHMMSS) to avoid conflicts
- Moves the entire issue folder to `archive/`
- Preserves all issue files (problem.md, solution.md, audit trail, etc.)
- **Executes review hooks**: Runs any `scripts/review-*` scripts from the project directory
- **Commits changes**: Creates a git commit with message "archive: <issue-name>"
- **Pushes to remote**: Pushes the commit to the remote repository

**Review Hooks:**
After archiving, the script looks for executable `scripts/review-*` files in the **project directory** (not the skill directory) and runs them with the archived issue name as argument:
```bash
# Example: If project has scripts/review-codex, it will run:
scripts/review-codex <issue-name>
```

Use review hooks for external code review (e.g., Codex, OpenCode) or post-archive automation.

**Prerequisites:**
- Issue must exist in the `issues/` directory
- Issue should be fully solved with a `solution.md` file
- Git repository initialized with remote configured (for push)

### 4. Solve All Unsolved Issues

Automatically solve all unsolved issues (issues with `problem.md` but no `solution.md`):

```bash
{base_path}/scripts/solve-unsolved [command-name]
```

**Examples:**
```bash
# Use default cx:solve command
{base_path}/scripts/solve-unsolved

# Use Python-specific solve workflow
{base_path}/scripts/solve-unsolved cxp:solve

# Use TypeScript-specific solve workflow
{base_path}/scripts/solve-unsolved cxt:solve
```

**Parameters:**
- `command-name` (optional): The solve command to use (default: `cx:solve`)
  - `cx:solve` - General solve workflow
  - `cxp:solve` - Python-specific solve workflow
  - `cxt:solve` - TypeScript-specific solve workflow

**When to use:**
- Batch processing multiple unsolved issues
- Automated issue resolution workflow for specific language projects
- Working through backlog of open issues

**How it works:**
- Scans the `issues/` directory for unsolved issues
- Identifies issues with `problem.md` but no `solution.md`
- Processes each issue using the specified solve command
- Automatically commits changes after each solution
- Reports progress as it processes each issue

**Prerequisites:**
- Issues must exist in the `issues/` directory with `problem.md` files
- The specified solve slash command must be available

**Output:**
- Shows which solve command is being used
- Shows count of unsolved issues found
- Displays progress for each issue being solved
- Confirms when all issues are processed

## When to Use This Skill

**Automatically use when:**
- User mentions "list issues", "show issues", or "what issues are open"
- User asks to "list solved", "show archived", or "what issues are solved"
- User asks to "archive" or "close" an issue
- User wants to "solve all issues" or "batch solve issues"
- Working with files in the `issues/` directory

**Explicitly use for:**
- Getting an overview of open work items
- Viewing completed/solved issues
- Managing issue lifecycle (open → solved → archived)
- Batch processing unsolved issues
- Cleaning up solved issues from the active list

## Workflow

### Typical Issue Management Flow

1. **List open issues** to see what needs work:
   ```bash
   {base_path}/scripts/list-open
   ```

2. **Solve all unsolved issues** (batch mode):
   ```bash
   # For general projects
   {base_path}/scripts/solve-unsolved

   # For Python projects
   {base_path}/scripts/solve-unsolved cxp:solve

   # For TypeScript projects
   {base_path}/scripts/solve-unsolved cxt:solve
   ```

3. **List solved issues** ready to archive:
   ```bash
   {base_path}/scripts/list-solved
   ```

4. **Archive when solved**:
   ```bash
   {base_path}/scripts/archive agent-crd-embedding-in-tool
   ```

## Directory Structure

Issues use descriptive kebab-case names that clearly indicate the problem:

```
issues/
├── agent-crd-embedding-in-tool/
│   ├── problem.md
│   ├── solution.md
│   └── ... (other files)
└── query-message-observer/
    └── problem.md

archive/
└── partial-tool-parameter-substitution/
    ├── problem.md
    └── solution.md
```

**Naming convention:**
- Use kebab-case (lowercase with hyphens)
- Descriptive names that indicate the issue (e.g., `agent-crd-embedding-in-tool`)
- Not IDs or ticket numbers

## Best Practices

1. **Before archiving:** Ensure the issue has a complete `solution.md` file
2. **Batch processing:** Use `solve-unsolved` to efficiently process multiple open issues
3. **Regular cleanup:** Archive solved issues to keep the issues/ directory focused
4. **Preserve history:** Archived issues retain all files for future reference

