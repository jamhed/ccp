---
name: issue-manager
description: Manage project issues in the issues folder. List open issues, archive solved issues, and refine problem definitions. Use when user mentions "list issues", "archive issue", "manage issues", or when working with the issues/ directory.
---

# Issue Manager

Expert assistant for managing project issues stored in the `issues/` folder. Provides utilities to list open issues, archive solved issues to the archive folder, and refine problem definitions.

## Core Capabilities

### 1. List Open Issues

List all open (non-archived) issues that have a `problem.md` file:

```bash
scripts/list-open
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
scripts/list-solved
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
scripts/archive <issue-name>
```

**Example:**
```bash
scripts/archive agent-crd-embedding-in-tool
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

**Prerequisites:**
- Issue must exist in the `issues/` directory
- Issue should be fully solved with a `solution.md` file

### 4. Solve All Unsolved Issues

Automatically solve all unsolved issues (issues with `problem.md` but no `solution.md`):

```bash
scripts/solve-unsolved [command-name]
```

**Examples:**
```bash
# Use default cx:solve command
scripts/solve-unsolved

# Use Python-specific solve workflow
scripts/solve-unsolved cxp:solve

# Use TypeScript-specific solve workflow
scripts/solve-unsolved cxt:solve
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
   scripts/list-open
   ```

2. **Solve all unsolved issues** (batch mode):
   ```bash
   # For general projects
   scripts/solve-unsolved

   # For Python projects
   scripts/solve-unsolved cxp:solve

   # For TypeScript projects
   scripts/solve-unsolved cxt:solve
   ```

3. **List solved issues** ready to archive:
   ```bash
   scripts/list-solved
   ```

4. **Archive when solved**:
   ```bash
   scripts/archive agent-crd-embedding-in-tool
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

