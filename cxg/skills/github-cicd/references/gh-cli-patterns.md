# GitHub CLI (gh) Patterns for CI/CD

Using GitHub CLI in workflows and scripts for PR management, releases, and API interactions.

## Table of Contents
1. [Authentication](#authentication)
2. [Pull Request Operations](#pull-request-operations)
3. [Release Management](#release-management)
4. [Issue Operations](#issue-operations)
5. [Workflow Operations](#workflow-operations)
6. [API Access](#api-access)

## Authentication

### In GitHub Actions

**Use GITHUB_TOKEN (automatically available):**

```yaml
- name: Create PR
  env:
    GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  run: gh pr create --title "Update" --body "Description"
```

**Alternative: Using gh auth:**

```yaml
- name: Setup gh
  run: gh auth login --with-token <<< "${{ secrets.GITHUB_TOKEN }}"

- name: Create PR
  run: gh pr create --title "Update" --body "Description"
```

### Check Authentication Status

```yaml
- name: Verify gh authentication
  run: |
    gh auth status
    gh api user --jq '.login'
```

## Pull Request Operations

### Create Pull Request

```yaml
- name: Create pull request
  run: |
    gh pr create \
      --title "feat: add new feature" \
      --body "$(cat <<'EOF'
    ## Summary
    - Added new feature
    - Updated documentation

    ## Test Plan
    - [ ] Unit tests pass
    - [ ] Integration tests pass
    EOF
    )" \
      --base main \
      --head feature-branch
```

**With labels and reviewers:**

```yaml
- name: Create PR with metadata
  run: |
    gh pr create \
      --title "feat: new feature" \
      --body "Description" \
      --label "enhancement,needs-review" \
      --reviewer user1,user2 \
      --assignee @me
```

### List Pull Requests

```yaml
- name: List open PRs
  run: gh pr list --state open

- name: List PRs for specific author
  run: gh pr list --author @me --state all

- name: List PRs as JSON
  run: gh pr list --json number,title,state,author
```

### View Pull Request

```yaml
- name: View PR details
  run: gh pr view 123

- name: View PR diff
  run: gh pr diff 123

- name: Get PR as JSON
  run: gh pr view 123 --json number,title,state,mergeable,statusCheckRollup
```

### Check PR Status

```yaml
- name: Check PR checks
  run: |
    PR_NUMBER=$(gh pr view --json number --jq '.number')
    gh pr checks $PR_NUMBER

- name: Wait for checks to pass
  run: |
    PR_NUMBER=$(gh pr view --json number --jq '.number')
    gh pr checks $PR_NUMBER --watch
```

### Merge Pull Request

```yaml
- name: Merge PR
  run: gh pr merge 123 --squash --delete-branch

- name: Merge with auto
  run: gh pr merge 123 --auto --squash
```

### Comment on Pull Request

```yaml
- name: Add PR comment
  run: |
    gh pr comment 123 --body "CI/CD build completed successfully!"

- name: Add comment from file
  run: |
    echo "Build artifacts available at: $URL" > comment.txt
    gh pr comment 123 --body-file comment.txt
```

## Release Management

### Create Release

```yaml
- name: Create GitHub release
  env:
    GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  run: |
    gh release create "v${{ steps.version.outputs.version }}" \
      --title "Release v${{ steps.version.outputs.version }}" \
      --notes "$(cat <<'EOF'
    ## What's Changed
    - Feature A
    - Bug fix B

    ## Installation
    Download the appropriate binary for your platform.
    EOF
    )"
```

**With assets:**

```yaml
- name: Create release with binaries
  run: |
    gh release create "v1.2.3" \
      --title "Release v1.2.3" \
      --notes "Release notes" \
      dist/myapp-linux-amd64 \
      dist/myapp-darwin-amd64 \
      dist/myapp-windows-amd64.exe
```

**Generate notes automatically:**

```yaml
- name: Create release with auto-generated notes
  run: |
    gh release create "v1.2.3" \
      --generate-notes \
      --latest
```

### List Releases

```yaml
- name: List releases
  run: gh release list --limit 10

- name: Get latest release
  run: |
    LATEST=$(gh release view --json tagName --jq '.tagName')
    echo "Latest release: $LATEST"
```

### Upload Release Assets

```yaml
- name: Upload artifacts to release
  run: |
    gh release upload v1.2.3 \
      dist/*.tar.gz \
      dist/*.zip \
      --clobber
```

## Issue Operations

### Create Issue

```yaml
- name: Create issue on failure
  if: failure()
  run: |
    gh issue create \
      --title "CI/CD pipeline failed for ${{ github.sha }}" \
      --body "Workflow run: ${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}" \
      --label "ci/cd,bug"
```

### List Issues

```yaml
- name: List open bugs
  run: gh issue list --label bug --state open

- name: List issues assigned to me
  run: gh issue list --assignee @me
```

### Close Issue

```yaml
- name: Close fixed issue
  run: gh issue close 456 --comment "Fixed in #123"
```

## Workflow Operations

### List Workflow Runs

```yaml
- name: List recent workflow runs
  run: |
    gh run list --limit 10

- name: List runs for specific workflow
  run: |
    gh run list --workflow ci.yaml --limit 5
```

### View Workflow Run

```yaml
- name: View workflow run details
  run: |
    gh run view ${{ github.run_id }}

- name: View run logs
  run: |
    gh run view ${{ github.run_id }} --log
```

### Trigger Workflow

```yaml
- name: Trigger deployment workflow
  run: |
    gh workflow run deploy.yaml \
      --ref main \
      --field environment=production \
      --field version=1.2.3
```

### Watch Workflow Run

```yaml
- name: Trigger and watch workflow
  run: |
    RUN_ID=$(gh workflow run deploy.yaml --ref main --json databaseId --jq '.databaseId')
    gh run watch $RUN_ID
```

## API Access

### Branch Protection

**Configure branch protection rules:**

```bash
gh api \
  --method PUT \
  "/repos/owner/repo/branches/main/protection" \
  --input - <<EOF
{
  "required_status_checks": {
    "strict": true,
    "checks": [
      {"context": "test / test"},
      {"context": "build / build-and-test"}
    ]
  },
  "enforce_admins": false,
  "required_pull_request_reviews": null,
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
EOF
```

### Repository Settings

**Get repository information:**

```yaml
- name: Get repo info
  run: |
    gh api repos/${{ github.repository }} --jq '.default_branch,.visibility'
```

**Update repository settings:**

```yaml
- name: Enable auto-merge
  run: |
    gh api \
      --method PATCH \
      "/repos/${{ github.repository }}" \
      --field allow_auto_merge=true
```

### Secrets Management

**List repository secrets:**

```yaml
- name: List secrets
  run: gh api repos/${{ github.repository }}/actions/secrets --jq '.secrets[].name'
```

### Get Workflow Job Information

```yaml
- name: Get failed job logs
  run: |
    FAILED_JOB=$(gh api \
      "/repos/${{ github.repository }}/actions/runs/${{ github.run_id }}/jobs" \
      --jq '.jobs[] | select(.conclusion == "failure") | .id' | head -1)

    gh api \
      "/repos/${{ github.repository }}/actions/jobs/${FAILED_JOB}/logs" \
      > failed-job.log
```

## Common Patterns

### Automated PR Creation

```yaml
name: Auto Update Dependencies

on:
  schedule:
    - cron: '0 0 * * 1'
  workflow_dispatch:

jobs:
  update:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Update dependencies
        run: |
          go get -u ./...
          go mod tidy

      - name: Create PR if changes
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          if [[ -n $(git status --porcelain) ]]; then
            git config user.name "github-actions[bot]"
            git config user.email "github-actions[bot]@users.noreply.github.com"

            BRANCH="deps-$(date +%Y%m%d)"
            git checkout -b $BRANCH
            git add .
            git commit -m "chore: update dependencies"
            git push origin $BRANCH

            gh pr create \
              --title "chore: update dependencies" \
              --body "Automated dependency updates" \
              --label "dependencies"
          fi
```

### Release Automation

```yaml
- name: Create release from tag
  if: startsWith(github.ref, 'refs/tags/v')
  env:
    GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  run: |
    TAG=${GITHUB_REF#refs/tags/}

    gh release create "$TAG" \
      --title "Release $TAG" \
      --generate-notes \
      dist/*
```

### Check Run Status

```yaml
- name: Wait for other workflows
  run: |
    gh run list \
      --workflow build.yaml \
      --branch ${{ github.ref_name }} \
      --limit 1 \
      --json status,conclusion \
      --jq '.[0].conclusion'

    while [ "$(gh run list --workflow build.yaml --branch ${{ github.ref_name }} --limit 1 --json conclusion --jq '.[0].conclusion')" != "success" ]; do
      echo "Waiting for build to complete..."
      sleep 30
    done
```

### Comment Build Status

```yaml
- name: Comment on PR with build status
  if: always()
  env:
    GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  run: |
    PR_NUMBER=$(gh pr view --json number --jq '.number' 2>/dev/null || echo "")

    if [ -n "$PR_NUMBER" ]; then
      STATUS="${{ job.status }}"
      RUN_URL="${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}"

      if [ "$STATUS" = "success" ]; then
        EMOJI="✅"
        MESSAGE="Build completed successfully!"
      else
        EMOJI="❌"
        MESSAGE="Build failed!"
      fi

      gh pr comment $PR_NUMBER --body "$EMOJI $MESSAGE

      View details: $RUN_URL"
    fi
```

### Query Multiple PRs

```yaml
- name: Find stale PRs
  run: |
    gh pr list \
      --state open \
      --json number,title,updatedAt \
      --jq '.[] | select(.updatedAt < (now - 86400*30 | strftime("%Y-%m-%dT%H:%M:%SZ"))) | .number' \
      | while read PR; do
          echo "Stale PR: #$PR"
          gh pr comment $PR --body "This PR has been inactive for 30 days. Please update or close."
        done
```

## Best Practices

### Error Handling
- Check exit codes when using gh in scripts
- Use `--jq` for JSON parsing instead of external tools
- Validate gh CLI is available before use

### Authentication
- Prefer `GH_TOKEN` environment variable
- Use `GITHUB_TOKEN` in workflows (auto-provided)
- Don't log tokens or sensitive data

### Performance
- Use `--json` and `--jq` for efficient data extraction
- Cache gh CLI binary if installing in workflows
- Batch operations when possible

### Maintainability
- Use heredocs for multi-line content
- Store templates in files when complex
- Document custom API endpoints used
- Use descriptive variable names

### Security
- Use minimal token permissions
- Validate input when creating issues/PRs
- Don't expose secrets in logs
- Review API permissions before granting access
