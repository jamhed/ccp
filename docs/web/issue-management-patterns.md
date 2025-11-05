# Issue Management Patterns and Best Practices

Research compiled on 2025-10-31 for skill-based issue management systems.

## Table of Contents

1. [GitHub Issue Template Best Practices](#github-issue-template-best-practices)
2. [Problem/Solution Documentation Formats](#problemsolution-documentation-formats)
3. [Git-Based Issue Tracking Patterns](#git-based-issue-tracking-patterns)
4. [Markdown-Based Issue Tracking Systems](#markdown-based-issue-tracking-systems)
5. [Issue Triage Workflow Best Practices](#issue-triage-workflow-best-practices)
6. [Architecture Decision Records (ADR)](#architecture-decision-records-adr)
7. [Recommendations for Skill-Based Systems](#recommendations-for-skill-based-systems)

---

## GitHub Issue Template Best Practices

### Source URLs
- https://everhour.com/blog/github-templates/
- https://rewind.com/blog/best-practices-for-using-github-issues/
- https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/configuring-issue-templates-for-your-repository
- https://github.com/stevemao/github-issue-templates
- https://github.com/devspace/awesome-github-templates

### Key Principles

#### 1. Template Structure and Organization

**Location**: Store templates in `.github/ISSUE_TEMPLATE/` directory with a `config.yml` file.

**Template Chooser**: Use `config.yml` to show users a friendly chooser interface with descriptions for each template type.

**Legacy Note**: The single `ISSUE_TEMPLATE.md` feature was retired on March 30, 2025. GitHub now encourages using the `ISSUE_TEMPLATE/` subdirectory for multiple templates.

#### 2. Design Philosophy

**Keep Templates Minimal**
- Ask for "minimal reproduction, not essays"
- Too much detail discourages contributions
- Include example text in placeholders to show expected tone and depth
- **Rule of thumb**: "If contributors circumvent templates, they're too long or unclear; trim ruthlessly"

**Quarterly Audits**
- Retire stale fields
- Add missing fields based on recurring questions
- Review template effectiveness

#### 3. Recommended Template Types

**Bug Report Template**
```yaml
Fields to include:
- Reproduction steps (numbered list)
- Expected vs. actual behavior
- Screenshots/recordings
- Environment details (version, browser, OS)
- Impact assessment (severity/priority)
```

**Feature Request Template**
```yaml
Fields to include:
- Problem statement (the "why")
- User story format
- Acceptance criteria
- Alternatives considered
- Potential risks/concerns
- Definition of done checklist
```

**Documentation Improvement Template**
```yaml
Fields to include:
- Page/section link
- Current state description
- Proposed change
- Supporting screenshots
```

#### 4. Workflow Integration

**Auto-labeling**: Pre-apply default labels from templates:
- `type:bug`, `type:feature`, `type:docs`
- `needs-triage` for initial review
- `good-first-issue` for newcomer-friendly items

**Assignment Patterns**:
- Private repos: Assign immediately upon creation
- Public repos: Leave unassigned initially, assign during team reviews

**Security Handling**: Use `config.yml` to add contact links for security reports, directing to SECURITY.md instead of public issues.

**Blank Issues**: Optionally disable blank issues via `config.yml` to enforce template usage.

#### 5. Template Configuration Example

```yaml
# .github/ISSUE_TEMPLATE/config.yml
blank_issues_enabled: false
contact_links:
  - name: Security Vulnerability
    url: https://github.com/org/repo/security/policy
    about: Please report security vulnerabilities through our security policy
  - name: Questions & Discussions
    url: https://github.com/org/repo/discussions
    about: Ask questions and discuss ideas here
```

#### 6. Best Practices Summary

1. **Search Before Submission**: Encourage reporters to search existing issues (document in CONTRIBUTING.md)
2. **Strategic Labels**: Use labels to categorize, but avoid over-labeling (reduces clarity)
3. **Sparse Mentions**: Use @mentions sparingly to avoid notification fatigue
4. **Prompt Closure**: Use "Closes #issue_number" in commits/PRs to auto-close resolved issues
5. **Backup Strategy**: Implement automated backups for disaster recovery
6. **Benefits**: Consistency, efficiency, quality, and scalability

---

## Problem/Solution Documentation Formats

### Source URLs
- https://www.altexsoft.com/blog/technical-documentation-in-software-development-types-best-practices-and-tools/
- https://www.atlassian.com/work-management/knowledge-sharing/documentation/software-design-document
- https://softwaredominos.com/home/software-design-development-articles/write-solution-design-document/
- https://paceai.co/software-documentation-best-practices-templates-formats-examples/

### Documentation Types

#### 1. Three Main Categories

**User Documentation**
- User manuals and guides
- FAQs and troubleshooting
- Getting started tutorials
- End-user focused content

**Technical Documentation**
- API documentation
- System architecture diagrams
- Data models and schemas
- Integration points
- Error codes and solutions
- Maintenance guidelines

**Process Documentation**
- Workflows and procedures
- Testing plans
- Release notes
- Development standards

#### 2. Solution Design Documents (SDD)

**Purpose**: Provide detailed solution specifications describing what the software will achieve and the problems it will solve.

**Key Components**:
- Title page (software name, version, release date)
- Table of contents (structured overview)
- Introduction (what it does, who it's for)
- Installation instructions (step-by-step setup)
- Features and functions (detailed instructions)
- FAQs and troubleshooting

**Technical Sections**:
- System overview (high-level architecture)
- Data models (how data is structured)
- Integration points (third-party integrations)
- Diagrams (flowcharts, UML)
- Error codes (possible errors and solutions)
- Maintenance guidelines (troubleshooting, upgrades)

#### 3. Best Practices

**Visual Elements**
- Use diagrams and flowcharts to illustrate complex concepts
- Include screenshots and annotated images
- Create UML or architecture diagrams

**Consistency**
- Use same formatting throughout
- Maintain consistent terminology
- Follow established conventions

**Currency**
- Regular reviews and updates
- Keep documentation in sync with code
- Document changes in release notes

---

## Git-Based Issue Tracking Patterns

### Source URLs
- https://github.com/mgoellnitz/trackdown
- http://mgoellnitz.github.io/trackdown/
- https://sciit.gitlab.io/sciit/
- https://matej.ceplovi.cz/blog/current-state-of-the-distributed-issue-tracking.html

### Key Systems and Patterns

#### 1. TrackDown - Plain Markdown Issue Tracking

**Philosophy**: "Issue Tracking with plain Markdown" for distributed and unconnected small teams.

**Core Structure**:
```markdown
## ID Title (status)

(Commit messages inserted here before the next ticket)

### Description
Full issue description with Markdown support

### Comments
Discussion and updates

### Commits
Auto-generated list of related commits
```

**Issue Field Specifications**:
- **ID**: Any combination of English letters and digits
- **Title**: Any Markdown-compatible text
- **Status**: "new", "in progress", "resolved", "closed"
- **Target Version**: Only digits, letters, and dots (no spaces)
- **Optional Metadata**: severity, priority, affected versions, assignee

**Git Integration Workflow**:
```bash
# Change status to "in progress"
git commit -m "refs #ID - working on this"

# Change status to "resolved"
git commit -m "fixes #ID - completed the work"
git commit -m "resolves #ID,#ID2 - fixed multiple issues"
```

**Deployment Model**:
- Issues reside in a single Markdown file
- Stored locally on developer machines
- Dedicated "trackdown" branch separate from source code
- Accessible via symbolic links at repository root
- Syncs via distributed version control
- Supports offline work and later merging

**Benefits**:
- Works in disconnected situations
- Full Markdown formatting support
- Git-native versioning and merging
- Distributed editing without central server

#### 2. Sciit - Source Control Integrated Issue Tracker

**Philosophy**: Issues stored within source code as block comments in the version repository.

**Key Features**:
- Issues created as block comments anywhere in source code
- Comments become trackable versioned objects in git
- Issues are part of the code they reference
- Full integration with version control workflow

**Benefits**:
- Issues travel with the code
- No external database needed
- Natural branching and merging
- Context co-located with implementation

#### 3. Common Patterns

**Markdown Checklists**:
- Use GitHub-style task lists to split complex issues
- Link to other issues to define relationships
- Track progress within issue bodies

**Distributed Architecture**:
- No central server required
- Each developer has full issue history
- Merge conflicts resolved like code
- Offline-first design

---

## Markdown-Based Issue Tracking Systems

### Source URLs
- https://github.com/mgoellnitz/trackdown
- https://github.com/BaldissaraMatheus/Tasks.md
- https://noted.lol/tasks-md/
- https://pankajpipada.com/posts/2024-08-13-taskmgmt-2/
- https://biggo.com/news/202505160130_Git_Bug_Decentralized_Issue_Tracker

### Systems Overview

#### 1. TrackDown
(See Git-Based Issue Tracking section above for details)

**Key Features**:
- Single Markdown file per project
- Git-based synchronization
- Commit message integration
- Status automation

#### 2. Tasks.md - File-Based Task Board

**Architecture**:
- Self-hosted Markdown file-based system
- Each lane = directory on filesystem
- Each task = individual file
- Can be installed as PWA
- Works offline

**Benefits**:
- Visual board interface
- File system as database
- No external dependencies
- Progressive web app support

#### 3. Git-bug - Decentralized Issue Tracker

**Architecture**:
- Issues stored as git objects (not files)
- Embeds directly within git repositories
- Keeps repository clean (issues not in working tree)
- Leverages git's distributed architecture

**Interfaces**:
- Command-line interface (CLI)
- Text-based user interface (TUI)
- Web interface

**Benefits**:
- True distributed model
- No repository pollution
- Multiple interface options
- Full offline capability

#### 4. Simple Markdown/Git Workflow for Solo Developers

**File Structure**:
```
root/
├── inbox.md              # Capture phase
├── todo.md              # Prioritized actions
├── notes/               # Reference materials
│   ├── meeting-notes.md
│   └── idea-notes.md
└── project-folders/
    └── todo.md          # Project-specific tasks
```

**Priority Levels**:
- **P-0**: Urgent, immediate (kept minimal)
- **P-1**: Important but not immediate
- **P-2**: Obligations with no pressing urgency
- **P-X**: Exciting tasks for motivation

**Project-Specific Structure** (`/todo.md`):
1. **Project Overview**: High-level MVP goals and scope
2. **Running Laundry List**: Dynamic P-0/P-1 tasks
3. **Pushed Out**: P-2 items and backlog

**Workflow Patterns**:
- Inbox → Todo → Ideas flow
- Priorities kept mental rather than documented
- Regular deletion of stale items
- Avoid generic catch-all files
- Mobile capture via external tools (Google Keep)

**Key Lessons**:
- Daily lists often don't work well
- Over-documentation causes clutter
- Simplicity beats complexity
- Integration with coding environment is crucial

---

## Issue Triage Workflow Best Practices

### Source URLs
- https://www.chromium.org/for-testers/bug-reporting-guidelines/triage-best-practices/
- https://smartbear.com/blog/bug-triaging-best-practices/
- https://marker.io/blog/bug-triage
- https://zetcode.com/terms-testing/bug-triage/

### Core Concepts

**Bug Triage Definition**: Sorting errors into three categories:
1. Immediate action needed
2. Future action possible
3. Safe to ignore

### Triage Approaches

#### 1. Reactive Triage
Address urgent issues immediately:
- Critical bugs affecting production
- Anomalous error spikes
- Stability problems
- Security vulnerabilities

#### 2. Periodic Triage
Regular review of all "for review" errors:
- **Target**: Daily triage sessions
- **Goal**: Prevent backlog accumulation
- **Outcome**: Achieve "inbox zero" for errors

### Key Principles

#### 1. Establish Regular Schedules
- Set aside regular time for triage
- Give enough time to handle incoming issues and backlog
- **Initial target**: One team member triaging daily
- Setup rotation to share the load

#### 2. Prioritization Framework

**Impact Assessment**:
- Define domain-specific impact metrics
- Go beyond default measurements (user count, error frequency)
- Consider:
  - A/B test cohorts
  - Feature flags
  - Business value indicators
  - Customer segment affected

**Severity Levels** (common framework):
- **P0/Critical**: System down, major functionality broken
- **P1/High**: Important feature broken, workaround exists
- **P2/Medium**: Minor feature broken, low impact
- **P3/Low**: Cosmetic issues, nice-to-have fixes

#### 3. Snooze Rules Strategy

Instead of creating tickets for low-priority bugs:
- Establish thresholds for re-review
- Set conditions that trigger escalation:
  - Additional occurrence counts
  - Frequency targets
  - Future review dates
- Monitor if conditions change

#### 4. Team Process Recommendations

**Clear Ownership**:
- Assign project owners accountable for stability
- Establish daily/weekly triaging rotations
- Define escalation paths

**Documentation**:
- Add comments explaining triage decisions
- Document investigation findings
- Record snooze thresholds and reasoning
- Maintain team context

**Ticket Strategy**:
- Create tickets only for bugs requiring fixes within next sprint
- Use snoozing for longer-term monitoring
- Avoid creating tickets that will just sit in backlog

**Filtered Views**:
- Use shared bookmarks for common filters
- Focus on high-impact production errors first
- Filter by recent time periods initially
- Gradually expand filters as capacity improves

#### 5. Foster Collaboration

**Triage Meeting Best Practices**:
- Regular meeting agendas
- QA and development teams work together
- Clear decision-making process
- Time-boxed discussions

**Communication**:
- Clear criteria for prioritization
- Everyone understands the process
- Consistent application of rules
- Feedback loops for process improvement

#### 6. Labeling Strategy

**Use "to triage" label**:
- Apply automatically via templates
- Clear visual indicator of untriaged items
- Easy filtering and reporting
- Remove after triage decision made

**Status Labels**:
- `needs-info`: Waiting for reporter
- `ready-for-dev`: Triaged and approved
- `blocked`: Cannot proceed
- `duplicate`: Close with reference

#### 7. Avoid Analysis Paralysis

- Make good-enough decisions to keep workflow moving
- Balance perfection with progress
- Periodically refine triage rules
- Adapt based on product phases

### Triage Workflow Example

```
1. Review new issues (reactive)
   ↓
2. Assess impact and severity
   ↓
3. Decision point:
   ├─ Critical → Immediate action
   ├─ High → Create ticket for next sprint
   ├─ Medium → Snooze with conditions
   └─ Low → Archive or defer
   ↓
4. Document decision rationale
   ↓
5. Apply appropriate labels
   ↓
6. Assign if immediate action needed
```

---

## Architecture Decision Records (ADR)

### Source URLs
- https://github.com/adr/madr
- https://adr.github.io/madr/
- https://github.com/joelparkerhenderson/architecture-decision-record
- https://adr.github.io/adr-templates/
- https://ozimmer.ch/practices/2022/11/22/MADRTemplatePrimer.html

### What are ADRs?

**Definition**: Documents that capture important architectural decisions along with context and consequences.

**Purpose**: Track "decisions that matter" for future reference, onboarding, and historical context.

### MADR - Markdown Any Decision Records

**Overview**: Lightweight format for documenting decisions in Markdown (previously "Markdown Architectural Decision Records").

**Available Templates**:
1. **Full Template** (`adr-template.md`) - All sections with explanations
2. **Minimal Template** (`adr-template-minimal.md`) - Only mandatory sections
3. **Bare Full** (`adr-template-bare.md`) - All sections without explanations
4. **Bare Minimal** (`adr-template-bare-minimal.md`) - Required sections only

### Core ADR Structure

#### Essential Components

**Title**: Numbered decision record
```
0001-database-choice.md
0002-authentication-method.md
```

**Status**: Current state of the decision
- `proposed`: Under consideration
- `accepted`: Approved and implemented
- `deprecated`: No longer recommended
- `superseded`: Replaced by another decision

**Context**: Background and problem statement
- Organizational situation
- Business priorities
- Team skills and considerations
- Relevant constraints

**Decision**: The chosen solution
- Clear statement of what was decided
- Specific and actionable

**Consequences**: Expected outcomes and trade-offs
- What becomes easier
- What becomes more difficult
- Effects on future decisions
- Subsequent ADRs triggered

**Alternatives** (optional but recommended):
- Other options considered
- Pros and cons of each
- Why they were rejected

### Template Examples

#### MADR Minimal Template
```markdown
# [Title]

## Status

[proposed | accepted | deprecated | superseded by [ADR-0005](0005-example.md)]

## Context

[Describe the context and problem statement]

## Decision

[Describe the decision]

## Consequences

[Describe the expected consequences]
```

#### Michael Nygard's Template (Simple and Popular)
```markdown
# Title

## Status

[proposed | accepted | rejected | deprecated | superseded]

## Context

What is the issue that we're seeing that is motivating this decision or change?

## Decision

What is the change that we're proposing and/or doing?

## Consequences

What becomes easier or more difficult to do because of this change?
```

#### MADR Full Template (Emphasizes Options)
```markdown
# [Title]

## Context and Problem Statement

[Describe the context and problem statement]

## Decision Drivers

* [driver 1, e.g., a force, facing concern, ...]
* [driver 2, e.g., a force, facing concern, ...]

## Considered Options

* [option 1]
* [option 2]
* [option 3]

## Decision Outcome

Chosen option: "[option 1]", because [justification].

### Positive Consequences

* [e.g., improvement of quality attribute satisfaction, follow-up decisions required, ...]

### Negative Consequences

* [e.g., compromising quality attribute, follow-up decisions required, ...]

## Pros and Cons of the Options

### [option 1]

* Good, because [argument a]
* Good, because [argument b]
* Bad, because [argument c]

### [option 2]

* Good, because [argument a]
* Good, because [argument b]
* Bad, because [argument c]

### [option 3]

* Good, because [argument a]
* Good, because [argument b]
* Bad, because [argument c]
```

### ADR Best Practices

#### 1. Essential Requirements

**Rationale**: Always explain reasons for the decision

**Specific Focus**: One architectural decision per ADR

**Timestamps**: Track when decisions are made and changed

**Immutability**: Don't alter existing information
- Add amendments as new sections
- Use superseded status to reference new ADRs
- Maintain historical accuracy

#### 2. File Naming Convention

**Format**: Present-tense imperative verbs in lowercase with dashes
```
Good examples:
- choose-database.md
- implement-caching-strategy.md
- adopt-microservices-architecture.md

Bad examples:
- Database.md
- We chose PostgreSQL.md
- CACHE_STRATEGY.md
```

#### 3. Storage Options

**Git repositories** (most common):
```
docs/
  decisions/
    0001-use-markdown-for-decisions.md
    0002-choose-postgresql.md
    0003-implement-jwt-authentication.md
```

**Other options**:
- Google Docs/Sheets
- Atlassian Jira
- Wikis (MediaWiki)
- Confluence

#### 4. Lifecycle Stages

Recommended progression:
1. **Initiating**: Identify need for decision
2. **Researching**: Gather information and options
3. **Evaluating**: Compare alternatives
4. **Implementing**: Execute chosen decision
5. **Maintaining**: Monitor and adjust
6. **Sunsetting**: Deprecate or supersede

#### 5. Popular ADR Template Variations

**Michael Nygard** - Simple and popular (4 sections)

**Jeff Tyree and Art Akerman** - More sophisticated with additional context

**Alexandrian pattern** - Emphasizes context specifics and patterns

**Business case** - MBA-oriented with costs, SWOT, opinions

**MADR** - Emphasizes options and their pros/cons

**Planguage** - Quality assurance oriented

**arc42** - Combines architecture documentation with decisions

### Why Markdown for ADRs?

**Version control-friendly**:
- Plain text format
- Easy diffing
- Collaborative editing
- Branch and merge support

**Collaboration-focused**:
- Everyone can edit
- No special tools required
- Works with existing workflows
- Low barrier to contribution

**Content over presentation**:
- Focus on message and logic
- No formatting distractions
- Portable across systems
- Future-proof format

---

## Recommendations for Skill-Based Systems

Based on the research above, here are specific recommendations for implementing issue management in a skill-based system:

### 1. File Structure

**Recommended organization**:
```
issues/
├── inbox/                    # Unprocessed issues
│   ├── 001-problem.md
│   └── 002-feature.md
├── active/                   # Currently being worked on
│   ├── 003-bug.md
│   └── 004-enhancement.md
├── resolved/                 # Completed issues
│   └── 005-completed.md
└── archived/                 # Historical reference
    └── 006-obsolete.md
```

**Alternative flat structure** (like TrackDown):
```
issues/
├── issues.md                 # Single file with all issues
└── archive/
    └── issues-2025-10.md     # Periodic archives
```

### 2. Issue Template Format

**Recommended structure** (hybrid of MADR and GitHub patterns):

```markdown
## [ID] Title

**Status**: [inbox | active | blocked | resolved | archived]
**Priority**: [P0-critical | P1-high | P2-medium | P3-low]
**Type**: [bug | feature | docs | refactor | investigation]
**Assigned**: [@username or skill-name]
**Created**: YYYY-MM-DD
**Updated**: YYYY-MM-DD

### Problem Statement

[Clear description of the issue or need]

### Context

[Background information, related issues, decision drivers]

### Proposed Solution

[If applicable: the intended approach]

### Acceptance Criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

### Investigation Notes

[Research findings, attempted solutions, blockers]

### Related Issues

- Refs: #123, #456
- Blocks: #789
- Blocked by: #012

### Resolution

[When resolved: what was done, decisions made, outcomes]

### Commits

[Auto-generated or manually linked commits]
- fixes #ID - commit message
```

### 3. Git Integration Patterns

**Commit Message Conventions**:
```bash
# Reference an issue (doesn't close)
git commit -m "refs #123 - investigating database performance"

# Mark as in progress
git commit -m "wip #123 - implementing caching layer"

# Close/resolve an issue
git commit -m "fixes #123 - add connection pooling"
git commit -m "resolves #123,#124 - optimize queries"

# Block an issue
git commit -m "blocks #123 - API changes required"
```

**Branch Naming**:
```bash
issue-123-feature-name
fix-123-bug-description
```

### 4. Skill-Specific Patterns

**Skill Assignment**:
```markdown
**Use Skill**: cx:chainsaw-tester
**Skills Needed**: [testing, kubernetes, debugging]
```

**Skill-Based Labels**:
- `skill:testing` - Requires testing expertise
- `skill:ci-cd` - CI/CD workflow issues
- `skill:go-dev` - Go development work
- `skill:docs` - Documentation tasks

**Cross-Skill Issues**:
```markdown
### Skills Involved

1. Skill(cx:chainsaw-tester) - Create test cases
2. Skill(cx:go-dev) - Implement fix
3. Skill(cx:github-cicd) - Update CI pipeline
```

### 5. Triage Workflow for Skills

**Automated Triage**:
```
New Issue Created
    ↓
1. Skill Detection (based on content/labels)
    ↓
2. Priority Assessment (based on keywords/context)
    ↓
3. Assignment Decision
    ├─ P0 → Immediate skill invocation
    ├─ P1 → Add to skill backlog
    ├─ P2 → Snooze with conditions
    └─ P3 → Archive for later review
    ↓
4. Status Update & Notification
```

**Manual Triage by Skills**:
- Each skill maintains its own backlog
- Skills can delegate to other skills
- Cross-skill coordination tracked in issue

### 6. Status Lifecycle

**Recommended states**:
```
inbox → triaged → active → [blocked] → resolved → archived
              ↓                           ↓
           snoozed                    superseded
```

**State Transitions**:
- `inbox → triaged`: After initial review and assignment
- `triaged → active`: When work begins
- `active → blocked`: External dependency identified
- `blocked → active`: Blocker resolved
- `active → resolved`: Work completed
- `resolved → archived`: After verification period

### 7. Search and Discovery

**Metadata for Searchability**:
```markdown
**Tags**: [performance, database, caching, optimization]
**Components**: [api-server, database-layer, cache-service]
**Versions**: [affected: v1.2.0, fixed: v1.2.1]
```

**Search Patterns**:
```bash
# Find all active issues
grep -r "**Status**: active" issues/

# Find issues by skill
grep -r "**Use Skill**: cx:chainsaw-tester" issues/

# Find high-priority issues
grep -r "**Priority**: P0-critical" issues/
```

### 8. Integration with ADRs

**Link Issues to Decisions**:
```markdown
### Related Decisions

- Implements: [ADR-0023 - Caching Strategy](../decisions/0023-caching-strategy.md)
- Influences: [ADR-0024 - Database Choice](../decisions/0024-database-choice.md)
```

**Create ADRs from Issues**:
- Significant design decisions in issues → formal ADR
- ADR references originating issue for context
- Maintains traceability

### 9. Automation Opportunities

**Status Updates via Commits**:
```bash
# Auto-update status based on commit messages
refs #123    → Status: active
wip #123     → Status: active
blocks #123  → Status: blocked
fixes #123   → Status: resolved
```

**Template Generation**:
```bash
# CLI command to create new issue
./issues new --type bug --priority P1 --skill go-dev --title "Fix memory leak"
```

**Periodic Tasks**:
- Weekly: Review snoozed issues
- Monthly: Archive resolved issues
- Quarterly: Audit labels and templates

### 10. Minimal Viable Implementation

**Phase 1 - Basic Structure**:
1. Create `issues/` directory
2. Define issue template
3. Establish basic labels/status values
4. Document commit message conventions

**Phase 2 - Git Integration**:
1. Implement commit message parsing
2. Auto-update issue status
3. Link commits to issues
4. Create issue branches

**Phase 3 - Skill Integration**:
1. Skill-based assignment
2. Cross-skill coordination
3. Skill-specific backlogs
4. Automated triage

**Phase 4 - Advanced Features**:
1. Search and reporting
2. Metrics and analytics
3. Template customization per skill
4. Integration with external tools

---

## Summary of Most Relevant Patterns

For a **skill-based issue management system**, the most valuable patterns are:

### 1. TrackDown's Markdown + Git Model
- **Why**: Simple, distributed, offline-capable
- **Apply**: Single markdown file per skill or flat structure in issues/
- **Benefit**: Natural integration with git workflow

### 2. GitHub Issue Template Philosophy
- **Why**: Proven patterns for capturing useful information
- **Apply**: Multiple templates for different issue types
- **Benefit**: Consistency and quality of issue reports

### 3. ADR Documentation Pattern
- **Why**: Captures decision context and consequences
- **Apply**: Link issues to decisions, promote important issues to ADRs
- **Benefit**: Maintains architectural knowledge

### 4. Triage Workflow Best Practices
- **Why**: Prevents backlog overwhelming
- **Apply**: Regular triage schedules, clear prioritization
- **Benefit**: Focus on high-impact work

### 5. Markdown Task Lists
- **Why**: Simple progress tracking
- **Apply**: Acceptance criteria as checklists
- **Benefit**: Visual progress indication

### Key Success Factors

1. **Keep It Simple**: Start minimal, add complexity only when needed
2. **Git-Native**: Leverage git for versioning, branching, merging
3. **Offline-First**: Support disconnected work
4. **Skill-Aware**: Issues understand which skills can address them
5. **Context-Rich**: Capture problem, solution, and decision rationale
6. **Searchable**: Good metadata and consistent formatting
7. **Automated**: Use commit messages and scripts to reduce manual work
8. **Auditable**: Clear history of status changes and decisions

### Anti-Patterns to Avoid

1. **Over-Engineering**: Don't build complex systems before you need them
2. **Template Overload**: Too many fields discourages use
3. **Manual Status Updates**: Automate via commit messages
4. **Stale Issues**: Regular cleanup and archival
5. **Generic Labels**: Use specific, actionable labels
6. **No Triage**: Regular review prevents backlog chaos
7. **Missing Context**: Always explain "why" not just "what"
8. **Orphaned Issues**: Clear ownership and assignment

---

## References

### Key Resources

**GitHub Templates**:
- [GitHub Official Docs - Issue Templates](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/configuring-issue-templates-for-your-repository)
- [Awesome GitHub Templates](https://github.com/devspace/awesome-github-templates)
- [GitHub Issue Templates Collection](https://github.com/stevemao/github-issue-templates)

**Git-Based Issue Tracking**:
- [TrackDown](https://github.com/mgoellnitz/trackdown) - Markdown issue tracking
- [Git-bug](https://github.com/MichaelMure/git-bug) - Distributed issue tracker
- [Sciit](https://sciit.gitlab.io/sciit/) - Source control integrated tracker

**Architecture Decision Records**:
- [MADR](https://github.com/adr/madr) - Markdown Any Decision Records
- [ADR Tools](https://github.com/npryce/adr-tools) - Command-line tools
- [ADR Templates Collection](https://github.com/joelparkerhenderson/architecture-decision-record)

**Best Practices**:
- [Rewind - Best Practices for GitHub Issues](https://rewind.com/blog/best-practices-for-using-github-issues/)
- [SmartBear - Bug Triaging Best Practices](https://smartbear.com/blog/bug-triaging-best-practices/)
- [Chromium - Triage Best Practices](https://www.chromium.org/for-testers/bug-reporting-guidelines/triage-best-practices/)

**Markdown Task Management**:
- [Tasks.md](https://github.com/BaldissaraMatheus/Tasks.md) - Self-hosted task board
- [Markdown Task Lists Guide](https://blog.markdowntools.com/posts/markdown-task-lists-and-checkboxes-complete-guide)

---

*Document compiled: 2025-10-31*
*Research focus: Skill-based issue management systems*
*Tools: WebSearch, WebFetch*
