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
cxp/skills/issue-manager/scripts/list-open
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
cxp/skills/issue-manager/scripts/list-solved
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
cxp/skills/issue-manager/scripts/archive <issue-name>
```

**Example:**
```bash
cxp/skills/issue-manager/scripts/archive agent-crd-embedding-in-tool
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

### 4. Refine Problem Definition

Use the `/cxp:refine` command to launch the problem researcher agent and refine an issue's problem definition:

```bash
/cxp:refine <issue-name>
```

**Example:**
```bash
/cxp:refine bug-async-validation-error
```

**When to use:**
- Problem definition is incomplete or unclear
- Need to investigate root cause more thoroughly
- Adding additional context or reproduction steps
- Improving problem clarity before implementing solution

**How it works:**
- Launches the `cxp:Problem Researcher` agent
- Agent analyzes the current problem definition
- Updates `problem.md` with enhanced details
- Maintains problem structure and formatting

**Prerequisites:**
- Issue must exist with a `problem.md` file

## When to Use This Skill

**Automatically use when:**
- User mentions "list issues", "show issues", or "what issues are open"
- User asks to "list solved", "show archived", or "what issues are solved"
- User asks to "archive" or "close" an issue
- User wants to "refine" or "improve" a problem definition
- Working with files in the `issues/` directory

**Explicitly use for:**
- Getting an overview of open work items
- Viewing completed/solved issues
- Managing issue lifecycle (open → solved → archived)
- Improving problem definitions before implementing solutions
- Cleaning up solved issues from the active list

## Workflow

### Typical Issue Management Flow

1. **List open issues** to see what needs work:
   ```bash
   cxp/skills/issue-manager/scripts/list-open
   ```

2. **Refine problem** if definition is unclear:
   ```bash
   /cxp:refine bug-async-validation-error
   ```

3. **Work on solution** using the `/cxp:solve` workflow

4. **List solved issues** to see what's ready to archive:
   ```bash
   cxp/skills/issue-manager/scripts/list-solved
   ```

5. **Archive when solved**:
   ```bash
   cxp/skills/issue-manager/scripts/archive bug-async-validation-error
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

## Environment Variables

The scripts support these environment variables:

- `ISSUES_DIR`: Directory containing open issues (default: `issues`)
- `ARCHIVE_DIR`: Directory for archived issues (default: `archive`)

**Example with custom directories:**
```bash
ISSUES_DIR=bugs ARCHIVE_DIR=resolved cxp/skills/issue-manager/scripts/list-open
```

## Best Practices

1. **Before archiving:** Ensure the issue has a complete `solution.md` file
2. **Refine early:** Use refine to clarify problem definitions before implementation
3. **Regular cleanup:** Archive solved issues to keep the issues/ directory focused
4. **Preserve history:** Archived issues retain all files for future reference

## Common Patterns

**Check what's open before starting work:**
```bash
cxp/skills/issue-manager/scripts/list-open
```

**View solved issues ready to archive:**
```bash
cxp/skills/issue-manager/scripts/list-solved
```

**Archive after solving:**
```bash
# After solution is complete and tested
cxp/skills/issue-manager/scripts/archive bug-async-validation-error
```

