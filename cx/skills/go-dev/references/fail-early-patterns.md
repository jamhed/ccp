# Fail-Early Patterns vs Defensive Programming

Avoid defensive programming. Validate inputs, fail early, and trust the type system.

## Table of Contents
1. [Input Validation](#input-validation)
2. [Nil Checks](#nil-checks)
3. [Guard Clauses](#guard-clauses)
4. [Error Propagation](#error-propagation)
5. [Type Assertions](#type-assertions)

## Input Validation

### Validate at Boundaries

```go
// GOOD: Validate once at entry point, fail early
func (r *Reconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    obj := &v1alpha1.MyResource{}
    if err := r.Get(ctx, req.NamespacedName, obj); err != nil {
        return ctrl.Result{}, client.IgnoreNotFound(err)
    }

    // Fail early on validation
    if err := r.validate(obj); err != nil {
        r.updateStatusError(ctx, obj, err)
        return ctrl.Result{}, nil // Don't requeue invalid spec
    }

    // Trust validation - no defensive checks needed
    return r.reconcile(ctx, obj)
}

func (r *Reconciler) validate(obj *v1alpha1.MyResource) error {
    if obj.Spec.Name == "" {
        return fmt.Errorf("spec.name is required")
    }
    if obj.Spec.Replicas != nil && *obj.Spec.Replicas < 0 {
        return fmt.Errorf("spec.replicas must be non-negative, got %d", *obj.Spec.Replicas)
    }
    return nil
}

// After validation, trust the data
func (r *Reconciler) reconcile(ctx context.Context, obj *v1alpha1.MyResource) error {
    // No need to check obj.Spec.Name again - we validated it
    deployment := r.buildDeployment(obj)
    return r.Client.Create(ctx, deployment)
}

// BAD: Defensive checks everywhere
func (r *Reconciler) reconcile(ctx context.Context, obj *v1alpha1.MyResource) error {
    if obj == nil {
        return fmt.Errorf("obj is nil") // Impossible, type system guarantees this
    }
    if obj.Spec.Name == "" {
        return fmt.Errorf("name is empty") // Already validated
    }
    // ... more redundant checks
}
```

### Webhook Validation (Single Point of Truth)

```go
// GOOD: Validate in webhook, trust in reconciler
func (v *MyResourceValidator) ValidateCreate(ctx context.Context, obj runtime.Object) (warnings admission.Warnings, err error) {
    res := obj.(*v1alpha1.MyResource)

    var errs []error

    if res.Spec.Name == "" {
        errs = append(errs, fmt.Errorf("spec.name is required"))
    }

    if res.Spec.Replicas != nil && *res.Spec.Replicas < 0 {
        errs = append(errs, fmt.Errorf("spec.replicas must be non-negative"))
    }

    // Return all validation errors at once
    return nil, errors.Join(errs...)
}

// Reconciler trusts webhook validation
func (r *Reconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    obj := &v1alpha1.MyResource{}
    if err := r.Get(ctx, req.NamespacedName, obj); err != nil {
        return ctrl.Result{}, client.IgnoreNotFound(err)
    }

    // No validation needed - webhook guarantees validity
    return r.reconcile(ctx, obj)
}

// BAD: Duplicate validation in reconciler
func (r *Reconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    // ... get object ...

    // BAD: Re-validating what webhook already checked
    if obj.Spec.Name == "" {
        return ctrl.Result{}, fmt.Errorf("name required")
    }
}
```

## Nil Checks

### Trust the Type System

```go
// GOOD: Only check nil for optional fields
func (r *Reconciler) applyDefaults(obj *v1alpha1.MyResource) {
    // Check optional pointer fields
    if obj.Spec.Replicas == nil {
        obj.Spec.Replicas = Ptr(int32(1))
    }

    if obj.Spec.Strategy == nil {
        obj.Spec.Strategy = &v1alpha1.Strategy{
            Type: "RollingUpdate",
        }
    }
}

func (r *Reconciler) processResource(obj *v1alpha1.MyResource) error {
    // No need to check obj == nil - type system guarantees non-nil
    // No need to check obj.Spec - embedded struct is never nil
    return r.deploy(obj)
}

// BAD: Unnecessary nil checks
func (r *Reconciler) processResource(obj *v1alpha1.MyResource) error {
    if obj == nil {
        return fmt.Errorf("obj is nil") // Impossible with proper types
    }

    if obj.Spec.Name == "" {
        return fmt.Errorf("name is empty") // Just check the value directly
    }

    // More paranoid checks...
}
```

### Pointer Field Handling

```go
// GOOD: Use helper to get value with default
func Deref[T any](ptr *T, defaultValue T) T {
    if ptr == nil {
        return defaultValue
    }
    return *ptr
}

func (r *Reconciler) getReplicas(obj *v1alpha1.MyResource) int32 {
    return Deref(obj.Spec.Replicas, int32(1))
}

// Or use cmp.Or (Go 1.22+)
import "cmp"

replicas := cmp.Or(obj.Spec.Replicas, Ptr(int32(1)))

// BAD: Defensive nil check before every use
func (r *Reconciler) getReplicas(obj *v1alpha1.MyResource) int32 {
    if obj == nil {
        return 1
    }
    if obj.Spec.Replicas == nil {
        return 1
    }
    return *obj.Spec.Replicas
}
```

## Guard Clauses

### Early Returns for Error Cases

```go
// GOOD: Guard clauses at the top, happy path at the bottom
func (r *Reconciler) reconcileDeployment(ctx context.Context, obj *v1alpha1.MyResource) error {
    // Guard: resource being deleted
    if obj.DeletionTimestamp != nil {
        return nil
    }

    // Guard: deployment disabled
    if !obj.Spec.Enabled {
        return r.deleteDeployment(ctx, obj)
    }

    // Guard: not ready for deployment
    if !r.isReady(obj) {
        return fmt.Errorf("resource not ready")
    }

    // Happy path: create or update deployment
    deployment := r.buildDeployment(obj)
    return r.applyDeployment(ctx, deployment)
}

// BAD: Nested conditions
func (r *Reconciler) reconcileDeployment(ctx context.Context, obj *v1alpha1.MyResource) error {
    if obj.DeletionTimestamp == nil {
        if obj.Spec.Enabled {
            if r.isReady(obj) {
                deployment := r.buildDeployment(obj)
                return r.applyDeployment(ctx, deployment)
            } else {
                return fmt.Errorf("resource not ready")
            }
        } else {
            return r.deleteDeployment(ctx, obj)
        }
    }
    return nil
}
```

### Multiple Error Conditions

```go
// GOOD: Chain of guards, fail early
func (r *Reconciler) validateAndProcess(ctx context.Context, obj *v1alpha1.MyResource) error {
    if obj.Spec.Name == "" {
        return fmt.Errorf("name is required")
    }

    if obj.Spec.Image == "" {
        return fmt.Errorf("image is required")
    }

    if obj.Spec.Replicas != nil && *obj.Spec.Replicas < 0 {
        return fmt.Errorf("replicas must be non-negative")
    }

    // All validations passed, proceed
    return r.process(ctx, obj)
}

// BAD: Accumulating errors when we should fail immediately
func (r *Reconciler) validateAndProcess(ctx context.Context, obj *v1alpha1.MyResource) error {
    valid := true
    errMsg := ""

    if obj.Spec.Name == "" {
        valid = false
        errMsg += "name is required; "
    }

    if obj.Spec.Image == "" {
        valid = false
        errMsg += "image is required; "
    }

    if !valid {
        return fmt.Errorf(errMsg)
    }

    return r.process(ctx, obj)
}

// Note: Use errors.Join when you want to collect ALL errors for user feedback
// But fail early when errors prevent further processing
```

## Error Propagation

### Don't Swallow Errors

```go
// GOOD: Propagate errors with context
func (r *Reconciler) reconcile(ctx context.Context, obj *v1alpha1.MyResource) error {
    if err := r.reconcileDeployment(ctx, obj); err != nil {
        return fmt.Errorf("failed to reconcile deployment: %w", err)
    }

    if err := r.reconcileService(ctx, obj); err != nil {
        return fmt.Errorf("failed to reconcile service: %w", err)
    }

    return nil
}

// BAD: Defensive error handling that hides problems
func (r *Reconciler) reconcile(ctx context.Context, obj *v1alpha1.MyResource) error {
    if err := r.reconcileDeployment(ctx, obj); err != nil {
        // BAD: Logging but continuing
        log.Printf("deployment error: %v", err)
    }

    if err := r.reconcileService(ctx, obj); err != nil {
        // BAD: Returning generic error without wrapping
        return fmt.Errorf("service failed")
    }

    return nil
}
```

### Distinguish Permanent vs Transient Errors

```go
// GOOD: Handle permanent vs transient errors differently
func (r *Reconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    obj := &v1alpha1.MyResource{}
    if err := r.Get(ctx, req.NamespacedName, obj); err != nil {
        // Transient error or not found - let controller-runtime handle it
        return ctrl.Result{}, client.IgnoreNotFound(err)
    }

    // Permanent error (invalid spec) - update status, don't requeue
    if err := r.validateSpec(obj); err != nil {
        r.setErrorStatus(ctx, obj, "InvalidSpec", err.Error())
        return ctrl.Result{}, nil
    }

    // Transient error (API call failed) - return error to requeue
    if err := r.reconcileResources(ctx, obj); err != nil {
        return ctrl.Result{}, err
    }

    return ctrl.Result{}, nil
}

// BAD: Treating all errors the same
func (r *Reconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    obj := &v1alpha1.MyResource{}
    if err := r.Get(ctx, req.NamespacedName, obj); err != nil {
        return ctrl.Result{}, err
    }

    if err := r.validateSpec(obj); err != nil {
        // BAD: Requeuing on validation error causes infinite retries
        return ctrl.Result{}, err
    }

    return ctrl.Result{}, nil
}
```

## Type Assertions

### Fail Fast on Type Assertions

```go
// GOOD: Assert type at boundary, then trust it
func (v *Validator) ValidateCreate(ctx context.Context, obj runtime.Object) (admission.Warnings, error) {
    res, ok := obj.(*v1alpha1.MyResource)
    if !ok {
        return nil, fmt.Errorf("expected MyResource, got %T", obj)
    }

    // Type is guaranteed, no more checks needed
    return nil, v.validate(res)
}

func (v *Validator) validate(res *v1alpha1.MyResource) error {
    // No type checking needed - guaranteed by ValidateCreate
    if res.Spec.Name == "" {
        return fmt.Errorf("name required")
    }
    return nil
}

// BAD: Checking types multiple times
func (v *Validator) ValidateCreate(ctx context.Context, obj runtime.Object) (admission.Warnings, error) {
    res, ok := obj.(*v1alpha1.MyResource)
    if !ok {
        return nil, fmt.Errorf("wrong type")
    }
    return nil, v.validate(obj) // Passing runtime.Object instead of concrete type
}

func (v *Validator) validate(obj runtime.Object) error {
    // BAD: Re-checking type
    res, ok := obj.(*v1alpha1.MyResource)
    if !ok {
        return fmt.Errorf("wrong type")
    }
    if res.Spec.Name == "" {
        return fmt.Errorf("name required")
    }
    return nil
}
```

### Use Type Parameters Instead of Assertions

```go
// GOOD: Type-safe generic function
func GetOrCreate[T client.Object](
    ctx context.Context,
    c client.Client,
    key client.ObjectKey,
    obj T,
) (T, error) {
    err := c.Get(ctx, key, obj)
    if err == nil {
        return obj, nil
    }

    if !apierrors.IsNotFound(err) {
        var zero T
        return zero, err
    }

    if err := c.Create(ctx, obj); err != nil {
        var zero T
        return zero, err
    }

    return obj, nil
}

// Usage - type safe, no assertions needed
deployment, err := GetOrCreate(ctx, r.Client, key, &appsv1.Deployment{})

// BAD: Using interface{} and type assertions
func GetOrCreate(ctx context.Context, c client.Client, key client.ObjectKey, obj interface{}) (interface{}, error) {
    clientObj, ok := obj.(client.Object)
    if !ok {
        return nil, fmt.Errorf("not a client.Object")
    }
    // ... implementation with more type assertions
}
```

## Summary

### Fail-Early Checklist

✅ **DO:**
- Validate inputs at boundaries (reconcile entry, webhook)
- Return errors immediately when they occur
- Use guard clauses for error conditions
- Trust the type system - avoid redundant nil checks
- Propagate errors with wrapping (`%w`)
- Use generics instead of type assertions
- Fail fast on invalid state

❌ **DON'T:**
- Check for impossible nil conditions
- Re-validate data that's already validated
- Nest error conditions deeply
- Swallow errors with logging
- Use defensive programming patterns
- Accumulate errors when failing fast is better
- Mix validation and business logic

### Example: Complete Fail-Early Reconcile

```go
func (r *Reconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    // Get resource
    obj := &v1alpha1.MyResource{}
    if err := r.Get(ctx, req.NamespacedName, obj); err != nil {
        return ctrl.Result{}, client.IgnoreNotFound(err)
    }

    // Guard: deletion
    if obj.DeletionTimestamp != nil {
        return r.handleDeletion(ctx, obj)
    }

    // Guard: validation (permanent error)
    if err := r.validate(obj); err != nil {
        r.setErrorStatus(ctx, obj, err)
        return ctrl.Result{}, nil // Don't requeue
    }

    // Reconcile (transient errors)
    if err := r.reconcileResources(ctx, obj); err != nil {
        return ctrl.Result{}, err // Requeue
    }

    // Update status
    if err := r.updateStatus(ctx, obj); err != nil {
        return ctrl.Result{}, err
    }

    return ctrl.Result{}, nil
}
```
