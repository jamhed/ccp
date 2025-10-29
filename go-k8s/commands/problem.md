---
description: Create a new problem definition for the problem-solving workflow
---

You are helping the user create a new problem definition file for the issue resolution workflow.

## Your Task

Create a new problem.md file at `issues/$ARGUMENTS/problem.md` with the proper structure.

## Steps

1. **Check if issue directory exists**:
   ```bash
   ls -la issues/$ARGUMENTS/ 2>/dev/null || echo "Directory does not exist"
   ```

2. **Create issue directory if needed**:
   ```bash
   mkdir -p issues/$ARGUMENTS
   ```

3. **Option A - Use Problem Research Agent** (Recommended):
   - Invoke the Problem Research agent to automatically research the codebase
   - Agent will gather context, analyze code, and generate a comprehensive problem definition
   - Use this when the user provides a general area or issue to investigate

4. **Option B - Gather information from user manually**:
   - Ask the user to describe the problem
   - Ask about severity (CRITICAL/HIGH/MEDIUM/LOW with emoji)
   - Ask about the affected file location
   - Ask about the impact
   - Ask if they have a recommended fix (optional)
   - Use this when the user has specific problem details ready

5. **Create problem.md file** with this structure:

```markdown
# [Title of the Problem]

**Severity**: CRITICAL 🔴 | HIGH 🟠 | MEDIUM 🟡 | LOW 🟢
**Status**: OPEN ⏳
**Source**: [Where this issue was discovered]

## Problem Description

[Detailed description of the issue - be specific about what goes wrong]

## Impact

- [Impact bullet 1]
- [Impact bullet 2]
- [Impact bullet 3]

## Location

**File**: [file path]
**Lines**: [line numbers or function name]

## Code

```go
// Show the problematic code snippet
// Add ❌ comments to highlight issues
```

## Recommended Fix

[Detailed description of recommended approach with code example if applicable]

## Related Files

- [file 1] - [description]
- [file 2] - [description]
```

6. **Confirm creation**:
   - Read the created file to verify
   - Show the user the path: `issues/$ARGUMENTS/problem.md`
   - Inform them they can now run the problem-validator agent to validate and create solutions

## Guidelines

- Be interactive and ask clarifying questions
- If the user provides all information upfront, use it directly
- Ensure the problem description is clear and detailed
- Use the AskUserQuestion tool if needed to gather missing information
- Create the file using the Write tool
- Verify the file was created successfully

## Example Interaction

**Example 1 - Using Problem Research Agent:**

User: `/problem memory-leak-reconciler`
You: "I'll use the Problem Research agent to investigate the memory leak in the reconciler."
*Invokes Problem Research agent which researches code and creates comprehensive problem.md*

**Example 2 - Manual entry:**

User: `/problem config-validation-missing` with all details provided
You: Create `issues/config-validation-missing/problem.md` directly with provided information.
