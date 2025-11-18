# cxg Agents - Go & Kubernetes Development

Multi-phase problem-solving workflow agents for Go 1.23+ and Kubernetes operator development. These agents work together to provide a comprehensive problem-solving pipeline from issue identification through implementation to documentation.

## Agent Overview

### Problem-Solving Workflow Agents

These agents execute sequentially as part of the `/cxg:solve` workflow:

#### 1. Problem Researcher
**File**: `problem-researcher.md`
**Purpose**: Researches Go codebases to identify bugs, performance issues, and feature requirements

**Key Capabilities**:
- Analyzes Go source code for bugs, anti-patterns, and vulnerabilities
- Specializes in Kubernetes operator patterns
- Creates comprehensive problem definitions with evidence
- Documents context, root cause, and acceptance criteria
- Uses severity levels (Critical, High, Medium, Low) based on evidence

**Triggered by**: `/cxg:problem [description]` or `/cxg:refine [issue-name]`

**Output**: Creates `issues/[issue-name]/problem.md`

#### 2. Problem Validator
**File**: `problem-validator.md`
**Purpose**: Validates issues, proposes solution approaches, and develops test cases

**Key Capabilities**:
- Confirms whether reported issue is valid or "NOT A BUG"
- Classifies issue type (bug/feature/refactor)
- Assesses feasibility and implementation complexity
- Proposes multiple solution approaches (A, B, C)
- Provides pros/cons and comparison for each approach
- Creates validation test cases to prove the issue exists

**Triggered by**: `/cxg:solve [issue-name]` (Step 1)

**Output**: Creates `issues/[issue-name]/validation.md`

**Special Behavior**: If issue is "NOT A BUG", creates `solution.md` and skips directly to Documentation Updater

#### 3. Solution Reviewer
**File**: `solution-reviewer.md`
**Purpose**: Critically evaluates proposed solutions and selects optimal approach

**Key Capabilities**:
- Analyzes complexity, risk, and effort for each proposed solution
- Provides recommendation with justification
- Documents key decision factors
- Considers Go best practices and Kubernetes operator patterns
- Evaluates maintainability and extensibility

**Triggered by**: `/cxg:solve [issue-name]` (Step 2)

**Output**: Creates `issues/[issue-name]/review.md`

#### 4. Solution Implementer
**File**: `solution-implementer.md`
**Purpose**: Implements fixes using modern Go 1.23+ best practices

**Key Capabilities**:
- Implements the selected solution approach
- Uses modern Go idioms (generics, fail-early patterns, error wrapping)
- Follows Kubernetes operator best practices
- Documents design patterns and rationale
- Handles edge cases
- Creates comprehensive implementation notes

**Triggered by**: `/cxg:solve [issue-name]` (Step 3)

**Output**: Creates `issues/[issue-name]/implementation.md`

#### 5. Code Reviewer & Tester
**File**: `code-reviewer-tester.md`
**Purpose**: Reviews code quality, runs linters and tests

**Key Capabilities**:
- Creates and validates test cases
- Runs unit tests (`go test`)
- Runs E2E tests with Chainsaw (for Kubernetes operators)
- Executes linters (`golangci-lint`)
- Performs code quality review
- Identifies improvements and refactoring opportunities
- Analyzes regression risks

**Triggered by**: `/cxg:solve [issue-name]` (Step 4)

**Output**: Creates `issues/[issue-name]/testing.md`

#### 6. Documentation Updater
**File**: `documentation-updater.md`
**Purpose**: Creates solution documentation and git commits

**Key Capabilities**:
- Summarizes the entire workflow
- Creates comprehensive solution.md
- Generates clean git commits with descriptive messages
- Archives issue to `archive/[issue-name]/`
- Creates follow-up issues if needed
- Marks original issue as RESOLVED

**Triggered by**: `/cxg:solve [issue-name]` (Step 5)

**Output**: Creates `archive/[issue-name]/solution.md` and git commit

## Workflow Execution

### Complete Workflow (`/cxg:solve [issue-name]`)

```
issues/[issue-name]/problem.md
    ↓
[Problem Validator] → validation.md
    ↓
    ├─ NOT A BUG → solution.md → [Documentation Updater] → archive/
    │
    └─ CONFIRMED ↓
[Solution Reviewer] → review.md
    ↓
[Solution Implementer] → implementation.md
    ↓
[Code Reviewer & Tester] → testing.md
    ↓
[Documentation Updater] → solution.md + git commit → archive/
```

### File Structure

**Active Issue**:
```
issues/[issue-name]/
└── problem.md          # Created by Problem Researcher
```

**During Workflow** (`/cxg:solve` execution):
```
issues/[issue-name]/
├── problem.md          # Initial definition
├── validation.md       # Problem Validator
├── review.md           # Solution Reviewer
├── implementation.md   # Solution Implementer
└── testing.md          # Code Reviewer & Tester
```

**Archived (Solved)**:
```
archive/[issue-name]/
├── problem.md          # Original issue (Status: RESOLVED)
├── validation.md       # Audit trail
├── review.md           # Audit trail
├── implementation.md   # Audit trail
├── testing.md          # Audit trail
├── solution.md         # Final summary
├── .opencode           # Marker file
└── .codex              # Review marker
```

## Go-Specific Best Practices

All agents enforce modern Go 1.23+ development patterns:

### Language Features
- **Generics**: Type-safe collections and algorithms
- **Fail-early patterns**: Guard clauses, early returns
- **Error wrapping**: `fmt.Errorf("context: %w", err)`
- **Zero values**: Leverage Go's zero value initialization
- **Context propagation**: Pass context.Context for cancellation

### Kubernetes Operator Patterns
- **Controller-runtime**: Reconciliation loops, predicates, watches
- **Custom Resources**: CRD definitions, validation, defaulting
- **Webhooks**: Admission control, mutation, validation
- **Error handling**: Requeue strategies, transient vs permanent errors
- **Testing**: Envtest for integration tests, Chainsaw for E2E

### Code Quality
- **Linting**: `golangci-lint` with comprehensive rules
- **Testing**: Table-driven tests, test fixtures
- **Error messages**: Clear, actionable, with context
- **Naming**: Idiomatic Go conventions
- **Documentation**: Package-level docs, exported symbols

## Usage Examples

### Define a New Problem
```bash
/cxg:problem telemetry spans exceeding attribute limits
```
Creates `issues/bug-telemetry-nested-attribute-limit/problem.md`

### Refine Existing Problem
```bash
/cxg:refine bug-telemetry-nested-attribute-limit
```
Updates `issues/bug-telemetry-nested-attribute-limit/problem.md`

### Execute Complete Workflow
```bash
/cxg:solve bug-telemetry-nested-attribute-limit
```
Executes all 6 agents sequentially, creates audit trail, archives issue

## Agent Coordination

### Data Flow
Each agent reads the outputs of previous agents to inform its decisions:

1. **Problem Validator** reads `problem.md`
2. **Solution Reviewer** reads `problem.md` + `validation.md`
3. **Solution Implementer** reads `problem.md` + `validation.md` + `review.md`
4. **Code Reviewer & Tester** reads all previous outputs
5. **Documentation Updater** synthesizes all outputs into `solution.md`

### Audit Trail
Every agent creates a permanent record of its analysis and decisions, providing complete traceability from problem identification to final solution.

### Quality Gates
Each agent enforces quality standards:
- **Problem Validator**: Issue must be valid and well-defined
- **Solution Reviewer**: Solution must be optimal and justified
- **Solution Implementer**: Code must follow Go best practices
- **Code Reviewer & Tester**: Tests must pass, linting must be clean
- **Documentation Updater**: Documentation must be comprehensive

## Integration with Commands

### `/cxg:problem`
Invokes **Problem Researcher** to create new issue

### `/cxg:refine`
Invokes **Problem Researcher** to refine existing issue

### `/cxg:solve`
Orchestrates all 6 agents in sequence for complete workflow

## Tools Used

### Code Analysis
- `go vet` - Static analysis for common errors
- `golangci-lint` - Comprehensive linting
- `go test` - Unit and integration testing
- Chainsaw - E2E testing for Kubernetes operators

### Kubernetes Development
- `controller-runtime` - Operator framework
- `envtest` - Integration testing with control plane
- `kubectl` - Kubernetes CLI
- Custom Resource Definitions (CRDs)

### Documentation
- Markdown formatting
- File path references with line numbers
- Evidence-based severity assessment
- Git commit message conventions

## See Also

- [cxg Plugin Documentation](../README.md) - Overview of cx plugin
- [Main CCP Documentation](../../README.md) - Complete collection documentation
- [Issue Management System](../../README.md#issue-management-system) - Issue lifecycle details
