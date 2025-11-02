# Modern Go 1.23+ Patterns & Idioms

Common Go best practices and patterns for Kubernetes operator development.

**For comprehensive guidance**: Use `Skill(go-k8s:go-dev)` for expert Go development assistance.

## Core Patterns

### 1. Fail-Early with Guard Clauses

**Prefer early returns over nested conditions**:

```go
// ❌ Bad: Nested conditions
func ProcessBackup(ctx context.Context, backup *v1alpha1.Backup) error {
    if backup != nil {
        if backup.Spec.Source != "" {
            if backup.Spec.Destination != "" {
                // Main logic here (deeply nested)
                return performBackup(backup)
            }
        }
    }
    return errors.New("invalid backup")
}

// ✅ Good: Fail-early guard clauses
func ProcessBackup(ctx context.Context, backup *v1alpha1.Backup) error {
    if backup == nil {
        return errors.New("backup cannot be nil")
    }
    if backup.Spec.Source == "" {
        return errors.New("backup source is required")
    }
    if backup.Spec.Destination == "" {
        return errors.New("backup destination is required")
    }

    // Main logic at the top level
    return performBackup(backup)
}
```

### 2. Default Values with `cmp.Or`

**Use `cmp.Or` for providing defaults** (Go 1.22+):

```go
import "cmp"

// ❌ Bad: Verbose ternary-like pattern
maxTurns := 10
if config.MaxTurns != 0 {
    maxTurns = config.MaxTurns
}

// ✅ Good: cmp.Or for defaults
maxTurns := cmp.Or(config.MaxTurns, 10)

// Works with strings too
timeout := cmp.Or(config.Timeout, "30s")
```

**Constants for magic numbers**:
```go
const (
    defaultMaxTurns = 10
    defaultTimeout  = "30s"
)

maxTurns := cmp.Or(config.MaxTurns, defaultMaxTurns)
```

### 3. Error Wrapping with `%w`

**Always wrap errors for context**:

```go
// ❌ Bad: Loses error chain
if err := client.Get(ctx, key, obj); err != nil {
    return errors.New("failed to get object")
}

// ✅ Good: Preserves error chain
if err := client.Get(ctx, key, obj); err != nil {
    return fmt.Errorf("failed to get %s: %w", key, err)
}
```

**Check specific errors**:
```go
if err := doSomething(); err != nil {
    if errors.Is(err, ErrNotFound) {
        // Handle not found
    }
    return fmt.Errorf("operation failed: %w", err)
}
```

### 4. Clear Variable Naming

**Use descriptive names over abbreviations**:

```go
// ❌ Bad: Unclear abbreviations
func (r *BR) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    br := &v1alpha1.BR{}
    if err := r.Get(ctx, req.NamespacedName, br); err != nil {
        return ctrl.Result{}, err
    }
}

// ✅ Good: Clear, descriptive names
func (r *BackupReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    backup := &v1alpha1.Backup{}
    if err := r.Get(ctx, req.NamespacedName, backup); err != nil {
        return ctrl.Result{}, err
    }
}
```

### 5. Avoid Defensive Nil Checks

**Don't check for impossible nils**:

```go
// ❌ Bad: Defensive nil check for value types
func calculateAge(created metav1.Time) int {
    if &created == nil {  // Impossible: created is a value type
        return 0
    }
    return int(time.Since(created.Time).Hours() / 24)
}

// ✅ Good: No unnecessary check
func calculateAge(created metav1.Time) int {
    return int(time.Since(created.Time).Hours() / 24)
}

// ✅ Good: Only check pointers if they can actually be nil
func calculateAge(created *metav1.Time) int {
    if created == nil {
        return 0
    }
    return int(time.Since(created.Time).Hours() / 24)
}
```

## Kubernetes Operator Patterns

### 6. Status Updates

**Always update status after reconciliation changes**:

```go
// Update status subresource
backup.Status.Phase = v1alpha1.BackupPhaseCompleted
backup.Status.CompletionTime = &metav1.Time{Time: time.Now()}

if err := r.Status().Update(ctx, backup); err != nil {
    return ctrl.Result{}, fmt.Errorf("failed to update status: %w", err)
}
```

### 7. Finalizers

**Use finalizers for cleanup**:

```go
const backupFinalizer = "backup.example.com/finalizer"

// Adding finalizer
if !controllerutil.ContainsFinalizer(backup, backupFinalizer) {
    controllerutil.AddFinalizer(backup, backupFinalizer)
    if err := r.Update(ctx, backup); err != nil {
        return ctrl.Result{}, fmt.Errorf("failed to add finalizer: %w", err)
    }
}

// Cleanup logic
if !backup.DeletionTimestamp.IsZero() {
    if controllerutil.ContainsFinalizer(backup, backupFinalizer) {
        // Perform cleanup
        if err := r.cleanup(ctx, backup); err != nil {
            return ctrl.Result{}, fmt.Errorf("cleanup failed: %w", err)
        }

        // Remove finalizer
        controllerutil.RemoveFinalizer(backup, backupFinalizer)
        if err := r.Update(ctx, backup); err != nil {
            return ctrl.Result{}, fmt.Errorf("failed to remove finalizer: %w", err)
        }
    }
    return ctrl.Result{}, nil
}
```

### 8. Requeue Logic

**Use appropriate requeue strategies**:

```go
// Requeue immediately on conflict
if apierrors.IsConflict(err) {
    return ctrl.Result{Requeue: true}, nil
}

// Requeue after delay
if backup.Status.Phase == v1alpha1.BackupPhaseInProgress {
    return ctrl.Result{RequeueAfter: 30 * time.Second}, nil
}

// Don't requeue on success
return ctrl.Result{}, nil
```

## Testing Patterns

### 9. Table-Driven Tests

**Use table-driven tests for multiple scenarios**:

```go
func TestValidateBackup(t *testing.T) {
    tests := []struct {
        name    string
        backup  *v1alpha1.Backup
        wantErr bool
    }{
        {
            name: "valid backup",
            backup: &v1alpha1.Backup{
                Spec: v1alpha1.BackupSpec{
                    Source:      "pvc-1",
                    Destination: "s3://bucket",
                },
            },
            wantErr: false,
        },
        {
            name: "missing source",
            backup: &v1alpha1.Backup{
                Spec: v1alpha1.BackupSpec{
                    Destination: "s3://bucket",
                },
            },
            wantErr: true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := validateBackup(tt.backup)
            if (err != nil) != tt.wantErr {
                t.Errorf("validateBackup() error = %v, wantErr %v", err, tt.wantErr)
            }
        })
    }
}
```

### 10. Context Usage

**Always pass context, use context.TODO() sparingly**:

```go
// ❌ Bad: Creating new context
func (r *Reconciler) doWork() error {
    ctx := context.Background()
    return r.Client.Get(ctx, key, obj)
}

// ✅ Good: Accept context parameter
func (r *Reconciler) doWork(ctx context.Context) error {
    return r.Client.Get(ctx, key, obj)
}

// Use context.TODO() only when refactoring
ctx := context.TODO() // TODO: pass context from caller
```

## Anti-Patterns to Avoid

### Don't:
- ❌ Use `panic()` in production code (use errors)
- ❌ Ignore errors: `_ = doSomething()`
- ❌ Create goroutines without proper cleanup
- ❌ Use `time.Sleep()` in controllers (use RequeueAfter)
- ❌ Mutate shared state without synchronization
- ❌ Use string concatenation for errors (use `fmt.Errorf`)
- ❌ Return `nil, nil` (return zero value and error)
- ❌ Check for nil on non-pointer types
- ❌ Use `interface{}` when concrete types work

### Do:
- ✅ Return errors, handle at appropriate level
- ✅ Use defer for cleanup (Close, Unlock, etc.)
- ✅ Use channels for goroutine coordination
- ✅ Use `ctrl.Result{RequeueAfter: duration}` for delays
- ✅ Use mutexes or atomic operations for shared state
- ✅ Wrap errors with context using `%w`
- ✅ Return zero value with error: `return ctrl.Result{}, err`
- ✅ Only check pointers for nil
- ✅ Use concrete types or generics over `interface{}`

## When to Use go-dev Skill

Use `Skill(go-k8s:go-dev)` for:
- Complex refactoring guidance
- Architecture decisions
- Performance optimization
- Advanced Go idioms
- Code review assistance
- Debugging complex issues
- Best practice validation

## References

- [Effective Go](https://go.dev/doc/effective_go)
- [Go Code Review Comments](https://github.com/golang/go/wiki/CodeReviewComments)
- [Kubernetes API Conventions](https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/api-conventions.md)
- [Controller Runtime Patterns](https://github.com/kubernetes-sigs/controller-runtime)
