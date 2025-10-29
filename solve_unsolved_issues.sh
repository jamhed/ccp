#!/bin/bash
set -euo pipefail

ISSUES_DIR="issues"

# Find all unsolved issues (have problem.md but no solution.md)
unsolved_issues=()
for issue_dir in "$ISSUES_DIR"/*/ ; do
    issue_name=$(basename "$issue_dir")

    # Skip if no problem.md
    [[ ! -f "$issue_dir/problem.md" ]] && continue

    # Skip if solution.md exists
    [[ -f "$issue_dir/solution.md" ]] && continue
    echo $issue_dir

    unsolved_issues+=("$issue_dir")
done

echo "Found ${#unsolved_issues[@]} unsolved issues"
echo ""

# Process each unsolved issue
for issue_dir in "${unsolved_issues[@]}"; do
    issue_name=$(basename "$issue_dir")

    echo "=== Processing unsolved issue: $issue_name ==="
    claude --print --dangerously-skip-permissions "/go-k8s:solve $issue_dir" --output-format stream-json --verbose
    echo ""
done

echo "All unsolved issues processed!"
