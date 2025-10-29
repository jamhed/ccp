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

3. **Gather information from user**:
   - Ask the user to describe the problem
   - Ask about severity (High/Medium/Low)
   - Ask about the affected file location
   - Ask about the impact
   - Ask if they have a recommended fix (optional)

4. **Create problem.md file** with this structure:

```markdown
**Status**: OPEN
**Severity**: [High|Medium|Low]
**Location**: [source file path]
**Impact**: [description of impact]

## Problem Description

[Detailed description of the issue]

## Recommended Fix

[Optional: suggested approach to fix the problem]
```

5. **Confirm creation**:
   - Read the created file to verify
   - Show the user the path: `issues/$ARGUMENTS/problem.md`
   - Inform them they can now run `/solve $ARGUMENTS` to start the resolution workflow

## Guidelines

- Be interactive and ask clarifying questions
- If the user provides all information upfront, use it directly
- Ensure the problem description is clear and detailed
- Use the AskUserQuestion tool if needed to gather missing information
- Create the file using the Write tool
- Verify the file was created successfully

## Example Interaction

User: `/problem memory-leak-reconciler`

You ask:
- What is the problem?
- What is the severity?
- Where is the issue located?
- What is the impact?
- Do you have a recommended fix?

Then create `issues/memory-leak-reconciler/problem.md` with the gathered information.
