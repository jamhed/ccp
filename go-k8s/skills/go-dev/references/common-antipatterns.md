# Common Anti-Patterns in Kubernetes Operators

Operator-specific mistakes and how to avoid them.

## Table of Contents
1. [Reconciliation Anti-Patterns](#reconciliation-anti-patterns)
2. [Resource Management](#resource-management)
3. [Status Updates](#status-updates)
4. [Concurrency Issues](#concurrency-issues)
5. [Performance Problems](#performance-problems)
6. [Error Handling Mistakes](#error-handling-mistakes)

## Reconciliation Anti-Patterns

### Infinite Reconciliation Loop

```go
// BAD: Updating object triggers new reconciliation
func (r *Reconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    obj := &v1alpha1.MyResource{}
    if err := r.Get(ctx, req.NamespacedName, obj); err != nil {
        return ctrl.Result{}, client.IgnoreNotFound(err)
    }

    // BAD: Updating labels triggers another reconciliation
    obj.Labels["last-reconciled"] = time.Now().String()
    if err := r.Update(ctx, obj); err != nil {
        return ctrl.Result{}, err
    }

    return ctrl.Result{}, nil
}

// GOOD: Only update when necessary, use status subresource
func (r *Reconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    obj := &v1alpha1.MyResource{}
    if err := r.Get(ctx, req.NamespacedName, obj); err != nil {
        return ctrl.Result{}, client.IgnoreNotFound(err)
    }

    // Update status (doesn't trigger reconciliation)
    obj.Status.LastReconciled = metav1.Now()
    obj.Status.ObservedGeneration = obj.Generation
    if err := r.Status().Update(ctx, obj); err != nil {
        return ctrl.Result{}, err
    }

    return ctrl.Result{}, nil
}

// GOOD: Use predicates to filter unnecessary reconciliations
func watchPredicate() predicate.Funcs {
    return predicate.Funcs{
        UpdateFunc: func(e event.UpdateEvent) bool {
            oldObj := e.ObjectOld.(*v1alpha1.MyResource)
            newObj := e.ObjectNew.(*v1alpha1.MyResource)

            // Only reconcile if spec changed
            return !reflect.DeepEqual(oldObj.Spec, newObj.Spec)
        },
    }
}
```

### Not Checking ObservedGeneration

```go
// BAD: Not tracking which generation was reconciled
func (r *Reconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    obj := &v1alpha1.MyResource{}
    if err := r.Get(ctx, req.NamespacedName, obj); err != nil {
        return ctrl.Result{}, client.IgnoreNotFound(err)
    }

    // BAD: Status might be from old generation
    if obj.Status.Ready {
        return ctrl.Result{}, nil // Might skip reconciling new spec
    }

    return r.reconcile(ctx, obj)
}

// GOOD: Check ObservedGeneration
func (r *Reconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    obj := &v1alpha1.MyResource{}
    if err := r.Get(ctx, req.NamespacedName, obj); err != nil {
        return ctrl.Result{}, client.IgnoreNotFound(err)
    }

    // Check if status is current
    if obj.Status.ObservedGeneration == obj.Generation && obj.Status.Ready {
        return ctrl.Result{}, nil
    }

    if err := r.reconcile(ctx, obj); err != nil {
        return ctrl.Result{}, err
    }

    // Update ObservedGeneration
    obj.Status.ObservedGeneration = obj.Generation
    return ctrl.Result{}, r.Status().Update(ctx, obj)
}
```

### Requeuing on Validation Errors

```go
// BAD: Returning error for validation failure causes infinite retries
func (r *Reconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    obj := &v1alpha1.MyResource{}
    if err := r.Get(ctx, req.NamespacedName, obj); err != nil {
        return ctrl.Result{}, client.IgnoreNotFound(err)
    }

    if obj.Spec.Name == "" {
        // BAD: Will retry forever since spec won't change
        return ctrl.Result{}, fmt.Errorf("name is required")
    }

    return r.reconcile(ctx, obj)
}

// GOOD: Set error status, don't requeue
func (r *Reconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    obj := &v1alpha1.MyResource{}
    if err := r.Get(ctx, req.NamespacedName, obj); err != nil {
        return ctrl.Result{}, client.IgnoreNotFound(err)
    }

    if obj.Spec.Name == "" {
        obj.Status.Conditions = []v1alpha1.Condition{{
            Type:    "Ready",
            Status:  "False",
            Reason:  "InvalidSpec",
            Message: "name is required",
        }}
        _ = r.Status().Update(ctx, obj)
        return ctrl.Result{}, nil // Don't requeue
    }

    return r.reconcile(ctx, obj)
}
```

## Resource Management

### Not Using Owner References

```go
// BAD: Creating resources without owner references
func (r *Reconciler) createDeployment(ctx context.Context, obj *v1alpha1.MyResource) error {
    deployment := &appsv1.Deployment{
        ObjectMeta: metav1.ObjectMeta{
            Name:      obj.Name,
            Namespace: obj.Namespace,
            // BAD: No owner reference
        },
        Spec: appsv1.DeploymentSpec{/*...*/},
    }

    return r.Create(ctx, deployment)
}

// GOOD: Set owner reference for garbage collection
func (r *Reconciler) createDeployment(ctx context.Context, obj *v1alpha1.MyResource) error {
    deployment := &appsv1.Deployment{
        ObjectMeta: metav1.ObjectMeta{
            Name:      obj.Name,
            Namespace: obj.Namespace,
        },
        Spec: appsv1.DeploymentSpec{/*...*/},
    }

    // Set owner reference
    if err := ctrl.SetControllerReference(obj, deployment, r.Scheme); err != nil {
        return fmt.Errorf("failed to set owner reference: %w", err)
    }

    return r.Create(ctx, deployment)
}
```

### Race Conditions in Resource Creation

```go
// BAD: Not handling AlreadyExists errors
func (r *Reconciler) ensureDeployment(ctx context.Context, obj *v1alpha1.MyResource) error {
    deployment := r.buildDeployment(obj)

    // BAD: Concurrent reconciliations might both try to create
    if err := r.Create(ctx, deployment); err != nil {
        return err // Fails if already exists
    }

    return nil
}

// GOOD: Use CreateOrUpdate for idempotent reconciliation
func (r *Reconciler) ensureDeployment(ctx context.Context, obj *v1alpha1.MyResource) error {
    deployment := &appsv1.Deployment{
        ObjectMeta: metav1.ObjectMeta{
            Name:      obj.Name,
            Namespace: obj.Namespace,
        },
    }

    _, err := ctrl.CreateOrUpdate(ctx, r.Client, deployment, func() error {
        deployment.Spec = r.buildDeploymentSpec(obj)
        return ctrl.SetControllerReference(obj, deployment, r.Scheme)
    })

    return err
}

// GOOD: Or handle AlreadyExists explicitly
func (r *Reconciler) ensureDeployment(ctx context.Context, obj *v1alpha1.MyResource) error {
    deployment := r.buildDeployment(obj)

    if err := r.Create(ctx, deployment); err != nil {
        if apierrors.IsAlreadyExists(err) {
            return r.Update(ctx, deployment)
        }
        return err
    }

    return nil
}
```

### Incorrect Finalizer Handling

```go
// BAD: Not removing finalizer
func (r *Reconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    obj := &v1alpha1.MyResource{}
    if err := r.Get(ctx, req.NamespacedName, obj); err != nil {
        return ctrl.Result{}, client.IgnoreNotFound(err)
    }

    if obj.DeletionTimestamp != nil {
        // BAD: Cleanup but never remove finalizer
        _ = r.cleanup(ctx, obj)
        return ctrl.Result{}, nil // Resource stuck in terminating
    }

    return r.reconcile(ctx, obj)
}

// GOOD: Remove finalizer after cleanup
const finalizerName = "myresource.example.com/finalizer"

func (r *Reconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    obj := &v1alpha1.MyResource{}
    if err := r.Get(ctx, req.NamespacedName, obj); err != nil {
        return ctrl.Result{}, client.IgnoreNotFound(err)
    }

    if obj.DeletionTimestamp != nil {
        if controllerutil.ContainsFinalizer(obj, finalizerName) {
            if err := r.cleanup(ctx, obj); err != nil {
                return ctrl.Result{}, fmt.Errorf("cleanup failed: %w", err)
            }

            // Remove finalizer
            controllerutil.RemoveFinalizer(obj, finalizerName)
            if err := r.Update(ctx, obj); err != nil {
                return ctrl.Result{}, err
            }
        }
        return ctrl.Result{}, nil
    }

    // Add finalizer if missing
    if !controllerutil.ContainsFinalizer(obj, finalizerName) {
        controllerutil.AddFinalizer(obj, finalizerName)
        if err := r.Update(ctx, obj); err != nil {
            return ctrl.Result{}, err
        }
    }

    return r.reconcile(ctx, obj)
}
```

## Status Updates

### Updating Status via Update()

```go
// BAD: Using Update() for status changes
func (r *Reconciler) setReady(ctx context.Context, obj *v1alpha1.MyResource) error {
    obj.Status.Ready = true
    // BAD: Triggers reconciliation, can conflict with spec changes
    return r.Update(ctx, obj)
}

// GOOD: Use Status().Update()
func (r *Reconciler) setReady(ctx context.Context, obj *v1alpha1.MyResource) error {
    obj.Status.Ready = true
    obj.Status.ObservedGeneration = obj.Generation
    // Doesn't trigger reconciliation
    return r.Status().Update(ctx, obj)
}
```

### Not Handling Status Update Conflicts

```go
// BAD: Ignoring status update errors
func (r *Reconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    obj := &v1alpha1.MyResource{}
    if err := r.Get(ctx, req.NamespacedName, obj); err != nil {
        return ctrl.Result{}, client.IgnoreNotFound(err)
    }

    if err := r.reconcile(ctx, obj); err != nil {
        return ctrl.Result{}, err
    }

    obj.Status.Ready = true
    _ = r.Status().Update(ctx, obj) // BAD: Ignoring conflict errors

    return ctrl.Result{}, nil
}

// GOOD: Get latest before updating status
func (r *Reconciler) setStatus(ctx context.Context, obj *v1alpha1.MyResource, ready bool) error {
    // Get latest version
    latest := &v1alpha1.MyResource{}
    if err := r.Get(ctx, client.ObjectKeyFromObject(obj), latest); err != nil {
        return err
    }

    latest.Status.Ready = ready
    latest.Status.ObservedGeneration = latest.Generation

    return r.Status().Update(ctx, latest)
}
```

## Concurrency Issues

### Copying Mutexes

```go
// BAD: Copying structs with mutexes
type Reconciler struct {
    client.Client
    mu sync.Mutex
    cache map[string]string
}

func (r Reconciler) Reconcile(...) {  // BAD: Receiver copies the mutex
    r.mu.Lock()
    defer r.mu.Unlock()
    // ...
}

// GOOD: Pointer receiver
func (r *Reconciler) Reconcile(...) {
    r.mu.Lock()
    defer r.mu.Unlock()
    // ...
}
```

### Shared State Without Synchronization

```go
// BAD: Unprotected shared state
type Reconciler struct {
    client.Client
    cache map[string]string // BAD: Concurrent reconciliations race
}

func (r *Reconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    // BAD: Concurrent map writes
    r.cache[req.Name] = "processing"
    // ...
}

// GOOD: Use sync.Map or protect with mutex
type Reconciler struct {
    client.Client
    mu    sync.RWMutex
    cache map[string]string
}

func (r *Reconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    r.mu.Lock()
    r.cache[req.Name] = "processing"
    r.mu.Unlock()
    // ...
}

// BETTER: Use sync.Map for concurrent access
type Reconciler struct {
    client.Client
    cache sync.Map
}

func (r *Reconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    r.cache.Store(req.Name, "processing")
    // ...
}
```

### Goroutines Without Context

```go
// BAD: Starting goroutines without cleanup
func (r *Reconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    obj := &v1alpha1.MyResource{}
    if err := r.Get(ctx, req.NamespacedName, obj); err != nil {
        return ctrl.Result{}, client.IgnoreNotFound(err)
    }

    // BAD: Goroutine leaks if reconciliation is cancelled
    go func() {
        time.Sleep(5 * time.Minute)
        r.periodicCheck(obj)
    }()

    return ctrl.Result{}, nil
}

// GOOD: Respect context cancellation
func (r *Reconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    obj := &v1alpha1.MyResource{}
    if err := r.Get(ctx, req.NamespacedName, obj); err != nil {
        return ctrl.Result{}, client.IgnoreNotFound(err)
    }

    go func() {
        timer := time.NewTimer(5 * time.Minute)
        defer timer.Stop()

        select {
        case <-timer.C:
            r.periodicCheck(obj)
        case <-ctx.Done():
            return // Clean exit on cancellation
        }
    }()

    return ctrl.Result{}, nil
}

// BETTER: Use RequeueAfter instead of goroutines
func (r *Reconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    obj := &v1alpha1.MyResource{}
    if err := r.Get(ctx, req.NamespacedName, obj); err != nil {
        return ctrl.Result{}, client.IgnoreNotFound(err)
    }

    r.periodicCheck(obj)

    // Requeue after 5 minutes
    return ctrl.Result{RequeueAfter: 5 * time.Minute}, nil
}
```

## Performance Problems

### Listing Without Selectors

```go
// BAD: Fetching all pods, filtering in code
func (r *Reconciler) getOwnedPods(ctx context.Context, obj *v1alpha1.MyResource) ([]corev1.Pod, error) {
    podList := &corev1.PodList{}
    if err := r.List(ctx, podList); err != nil {
        return nil, err
    }

    var result []corev1.Pod
    for _, pod := range podList.Items {
        if pod.Namespace == obj.Namespace &&
           pod.Labels["app"] == obj.Name {
            result = append(result, pod)
        }
    }
    return result, nil
}

// GOOD: Use label selectors
func (r *Reconciler) getOwnedPods(ctx context.Context, obj *v1alpha1.MyResource) ([]corev1.Pod, error) {
    podList := &corev1.PodList{}

    if err := r.List(ctx, podList,
        client.InNamespace(obj.Namespace),
        client.MatchingLabels{"app": obj.Name},
    ); err != nil {
        return nil, err
    }

    return podList.Items, nil
}
```

### Excessive API Calls

```go
// BAD: Fetching each resource individually
func (r *Reconciler) checkPods(ctx context.Context, names []string, namespace string) error {
    for _, name := range names {
        pod := &corev1.Pod{}
        // BAD: N API calls
        if err := r.Get(ctx, client.ObjectKey{Name: name, Namespace: namespace}, pod); err != nil {
            return err
        }
        // check pod...
    }
    return nil
}

// GOOD: List once, filter in memory
func (r *Reconciler) checkPods(ctx context.Context, names []string, namespace string) error {
    podList := &corev1.PodList{}
    if err := r.List(ctx, podList, client.InNamespace(namespace)); err != nil {
        return err
    }

    podMap := make(map[string]*corev1.Pod)
    for i := range podList.Items {
        podMap[podList.Items[i].Name] = &podList.Items[i]
    }

    for _, name := range names {
        pod, exists := podMap[name]
        if !exists {
            return fmt.Errorf("pod %s not found", name)
        }
        // check pod...
    }
    return nil
}
```

### Deep Copying Large Objects

```go
// BAD: Deep copying entire objects unnecessarily
func (r *Reconciler) processObject(obj *v1alpha1.MyResource) error {
    // BAD: Expensive deep copy
    objCopy := obj.DeepCopy()
    // Only using one field...
    name := objCopy.Spec.Name
    // ...
}

// GOOD: Only copy what you need
func (r *Reconciler) processObject(obj *v1alpha1.MyResource) error {
    name := obj.Spec.Name
    // ...
}

// GOOD: Deep copy only when modifying
func (r *Reconciler) updateObject(ctx context.Context, obj *v1alpha1.MyResource) error {
    // Deep copy before modifying
    objCopy := obj.DeepCopy()
    objCopy.Spec.Name = "new-name"

    return r.Update(ctx, objCopy)
}
```

## Error Handling Mistakes

### Ignoring Error Types

```go
// BAD: Not checking error types
func (r *Reconciler) getResource(ctx context.Context, key client.ObjectKey) (*v1alpha1.MyResource, error) {
    obj := &v1alpha1.MyResource{}
    if err := r.Get(ctx, key, obj); err != nil {
        // BAD: Returning NotFound as error
        return nil, err
    }
    return obj, nil
}

// GOOD: Handle NotFound differently
func (r *Reconciler) getResource(ctx context.Context, key client.ObjectKey) (*v1alpha1.MyResource, error) {
    obj := &v1alpha1.MyResource{}
    err := r.Get(ctx, key, obj)
    if apierrors.IsNotFound(err) {
        return nil, nil // Not found is not an error
    }
    if err != nil {
        return nil, err
    }
    return obj, nil
}

// Or use client.IgnoreNotFound
func (r *Reconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    obj := &v1alpha1.MyResource{}
    if err := r.Get(ctx, req.NamespacedName, obj); err != nil {
        return ctrl.Result{}, client.IgnoreNotFound(err)
    }
    // ...
}
```

### Not Wrapping Errors

```go
// BAD: Losing error context
func (r *Reconciler) reconcile(ctx context.Context, obj *v1alpha1.MyResource) error {
    if err := r.createDeployment(ctx, obj); err != nil {
        return err // Lost context about what failed
    }
    return nil
}

// GOOD: Wrap errors with context
func (r *Reconciler) reconcile(ctx context.Context, obj *v1alpha1.MyResource) error {
    if err := r.createDeployment(ctx, obj); err != nil {
        return fmt.Errorf("failed to create deployment for %s/%s: %w",
            obj.Namespace, obj.Name, err)
    }
    return nil
}
```
