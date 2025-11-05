# Kubernetes Operator Patterns (controller-runtime)

Best practices for controller-runtime based operators.

## Table of Contents
1. [Reconciler Implementation](#reconciler-implementation)
2. [Error Handling in Reconcile](#error-handling-in-reconcile)
3. [Watch and Predicate Patterns](#watch-and-predicate-patterns)
4. [Manager Setup](#manager-setup)
5. [Status Updates](#status-updates)
6. [Finalizers](#finalizers)
7. [Client Usage](#client-usage)

## Reconciler Implementation

### Fail Early Pattern

```go
// GOOD: Fail early, clear control flow
func (r *MyReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    obj := &v1alpha1.MyResource{}
    if err := r.Get(ctx, req.NamespacedName, obj); err != nil {
        return ctrl.Result{}, client.IgnoreNotFound(err)
    }

    if obj.DeletionTimestamp != nil {
        return r.handleDeletion(ctx, obj)
    }

    if err := r.ensureFinalizer(ctx, obj); err != nil {
        return ctrl.Result{}, err
    }

    if err := r.reconcileResource(ctx, obj); err != nil {
        return ctrl.Result{}, err
    }

    return ctrl.Result{}, r.updateStatus(ctx, obj)
}

// BAD: Defensive programming, nested conditions
func (r *MyReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    obj := &v1alpha1.MyResource{}
    err := r.Get(ctx, req.NamespacedName, obj)
    if err != nil {
        if !errors.IsNotFound(err) {
            return ctrl.Result{}, err
        }
        return ctrl.Result{}, nil
    }

    if obj != nil && obj.DeletionTimestamp != nil {
        // nested logic...
        if obj.Finalizers != nil {
            // more nesting...
        }
    }
    // continues with deep nesting
}
```

### Return Early from Helper Functions

```go
// GOOD: Each helper fails early and propagates errors
func (r *MyReconciler) reconcileResource(ctx context.Context, obj *v1alpha1.MyResource) error {
    if err := r.validateSpec(obj); err != nil {
        return fmt.Errorf("invalid spec: %w", err)
    }

    deployment, err := r.getOrCreateDeployment(ctx, obj)
    if err != nil {
        return fmt.Errorf("failed to get deployment: %w", err)
    }

    if err := r.updateDeployment(ctx, deployment, obj); err != nil {
        return fmt.Errorf("failed to update deployment: %w", err)
    }

    return nil
}

// BAD: Trying to handle too many cases defensively
func (r *MyReconciler) reconcileResource(ctx context.Context, obj *v1alpha1.MyResource) error {
    if obj == nil {
        return nil // unnecessary nil check
    }

    if obj.Spec.Replicas != nil {
        if *obj.Spec.Replicas > 0 {
            // nested checks instead of validation
        }
    }
    // continues with defensive checks
}
```

## Error Handling in Reconcile

### Controller-Runtime Error Semantics

```go
// GOOD: Proper error handling semantics
func (r *MyReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    obj := &v1alpha1.MyResource{}

    // Transient errors: return error for exponential backoff
    if err := r.Get(ctx, req.NamespacedName, obj); err != nil {
        return ctrl.Result{}, client.IgnoreNotFound(err)
    }

    // Permanent errors: update status, don't requeue
    if err := r.validateSpec(obj); err != nil {
        obj.Status.Conditions = []v1alpha1.Condition{{
            Type:    "Ready",
            Status:  "False",
            Reason:  "InvalidSpec",
            Message: err.Error(),
        }}
        _ = r.Status().Update(ctx, obj) // best effort
        return ctrl.Result{}, nil // don't requeue
    }

    // Explicit requeue for periodic reconciliation
    if obj.Spec.RefreshInterval != nil {
        return ctrl.Result{RequeueAfter: *obj.Spec.RefreshInterval}, nil
    }

    return ctrl.Result{}, nil
}

// BAD: Returning errors for validation failures
func (r *MyReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    obj := &v1alpha1.MyResource{}
    if err := r.Get(ctx, req.NamespacedName, obj); err != nil {
        return ctrl.Result{}, err
    }

    // BAD: Requeuing on validation error causes infinite retries
    if obj.Spec.Name == "" {
        return ctrl.Result{}, fmt.Errorf("name is required")
    }
}
```

### Modern Error Wrapping (Go 1.20+)

```go
// GOOD: Use errors.Join for multiple errors, %w for wrapping
func (r *MyReconciler) reconcileResources(ctx context.Context, obj *v1alpha1.MyResource) error {
    var errs []error

    if err := r.reconcileDeployment(ctx, obj); err != nil {
        errs = append(errs, fmt.Errorf("deployment: %w", err))
    }

    if err := r.reconcileService(ctx, obj); err != nil {
        errs = append(errs, fmt.Errorf("service: %w", err))
    }

    return errors.Join(errs...)
}

// Use errors.Is for checking
if errors.Is(err, context.DeadlineExceeded) {
    return ctrl.Result{Requeue: true}, nil
}
```

## Watch and Predicate Patterns

### Efficient Predicates

```go
// GOOD: Use predicates to filter events, fail early in predicate
func watchPredicate() predicate.Funcs {
    return predicate.Funcs{
        CreateFunc: func(e event.CreateEvent) bool {
            return hasRequiredLabels(e.Object)
        },
        UpdateFunc: func(e event.UpdateEvent) bool {
            // Fail early: check type first
            oldObj, ok := e.ObjectOld.(*v1alpha1.MyResource)
            if !ok {
                return false
            }
            newObj, ok := e.ObjectNew.(*v1alpha1.MyResource)
            if !ok {
                return false
            }

            // Only reconcile if spec changed
            return !reflect.DeepEqual(oldObj.Spec, newObj.Spec)
        },
        DeleteFunc: func(e event.DeleteEvent) bool {
            return true // always reconcile deletes
        },
    }
}

// BAD: Not using predicates, processing all events
func (r *MyReconciler) SetupWithManager(mgr ctrl.Manager) error {
    return ctrl.NewControllerManagedBy(mgr).
        For(&v1alpha1.MyResource{}).
        Complete(r) // No predicates, reconciles on every event
}
```

### Owner References for Watches

```go
// GOOD: Watch owned resources automatically
func (r *MyReconciler) SetupWithManager(mgr ctrl.Manager) error {
    return ctrl.NewControllerManagedBy(mgr).
        For(&v1alpha1.MyResource{}).
        Owns(&appsv1.Deployment{}).  // Watches owned Deployments
        Owns(&corev1.Service{}).      // Watches owned Services
        WithEventFilter(watchPredicate()).
        Complete(r)
}

// When creating resources, set owner reference
func (r *MyReconciler) createDeployment(ctx context.Context, obj *v1alpha1.MyResource) error {
    deployment := &appsv1.Deployment{
        ObjectMeta: metav1.ObjectMeta{
            Name:      obj.Name,
            Namespace: obj.Namespace,
        },
        Spec: appsv1.DeploymentSpec{/*...*/},
    }

    if err := ctrl.SetControllerReference(obj, deployment, r.Scheme); err != nil {
        return fmt.Errorf("failed to set owner reference: %w", err)
    }

    return r.Create(ctx, deployment)
}
```

## Manager Setup

```go
// GOOD: Clear setup with fail-early pattern
func main() {
    setupLog := ctrl.Log.WithName("setup")

    mgr, err := ctrl.NewManager(ctrl.GetConfigOrDie(), ctrl.Options{
        Scheme:                 scheme,
        MetricsBindAddress:     ":8080",
        HealthProbeBindAddress: ":8081",
        LeaderElection:         true,
        LeaderElectionID:       "my-operator.example.com",
    })
    if err != nil {
        setupLog.Error(err, "unable to create manager")
        os.Exit(1)
    }

    if err = (&MyReconciler{
        Client: mgr.GetClient(),
        Scheme: mgr.GetScheme(),
    }).SetupWithManager(mgr); err != nil {
        setupLog.Error(err, "unable to create controller")
        os.Exit(1)
    }

    if err := mgr.AddHealthzCheck("healthz", healthz.Ping); err != nil {
        setupLog.Error(err, "unable to set up health check")
        os.Exit(1)
    }

    if err := mgr.Start(ctrl.SetupSignalHandler()); err != nil {
        setupLog.Error(err, "problem running manager")
        os.Exit(1)
    }
}
```

## Status Updates

### Use Status Subresource

```go
// GOOD: Update status separately, fail early
func (r *MyReconciler) updateStatus(ctx context.Context, obj *v1alpha1.MyResource) error {
    obj.Status.ObservedGeneration = obj.Generation
    obj.Status.Conditions = []v1alpha1.Condition{
        {
            Type:               "Ready",
            Status:             "True",
            LastTransitionTime: metav1.Now(),
            Reason:             "ReconcileSuccess",
        },
    }

    if err := r.Status().Update(ctx, obj); err != nil {
        return fmt.Errorf("failed to update status: %w", err)
    }

    return nil
}

// BAD: Updating entire object (triggers reconciliation)
func (r *MyReconciler) updateStatus(ctx context.Context, obj *v1alpha1.MyResource) error {
    obj.Status.Ready = true
    return r.Update(ctx, obj) // BAD: triggers watch event
}
```

### Atomic Status Updates

```go
// GOOD: Get latest, update status atomically
func (r *MyReconciler) setCondition(ctx context.Context, obj *v1alpha1.MyResource, condition v1alpha1.Condition) error {
    // Get latest version
    latest := &v1alpha1.MyResource{}
    if err := r.Get(ctx, client.ObjectKeyFromObject(obj), latest); err != nil {
        return err
    }

    // Update conditions
    latest.Status.Conditions = updateCondition(latest.Status.Conditions, condition)

    return r.Status().Update(ctx, latest)
}
```

## Finalizers

```go
// GOOD: Fail-early finalizer pattern
const finalizerName = "myresource.example.com/finalizer"

func (r *MyReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    obj := &v1alpha1.MyResource{}
    if err := r.Get(ctx, req.NamespacedName, obj); err != nil {
        return ctrl.Result{}, client.IgnoreNotFound(err)
    }

    // Handle deletion
    if obj.DeletionTimestamp != nil {
        if controllerutil.ContainsFinalizer(obj, finalizerName) {
            if err := r.cleanup(ctx, obj); err != nil {
                return ctrl.Result{}, fmt.Errorf("cleanup failed: %w", err)
            }

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

    // Normal reconciliation
    return ctrl.Result{}, r.reconcile(ctx, obj)
}

func (r *MyReconciler) cleanup(ctx context.Context, obj *v1alpha1.MyResource) error {
    // Fail early on cleanup errors
    if err := r.deleteExternalResources(ctx, obj); err != nil {
        return fmt.Errorf("failed to delete external resources: %w", err)
    }
    return nil
}
```

## Client Usage

### Efficient List Operations

```go
// GOOD: Use field selectors and label selectors
func (r *MyReconciler) listOwnedPods(ctx context.Context, obj *v1alpha1.MyResource) ([]corev1.Pod, error) {
    podList := &corev1.PodList{}

    if err := r.List(ctx, podList,
        client.InNamespace(obj.Namespace),
        client.MatchingLabels{"app": obj.Name},
    ); err != nil {
        return nil, err
    }

    return podList.Items, nil
}

// BAD: Listing everything and filtering in code
func (r *MyReconciler) listOwnedPods(ctx context.Context, obj *v1alpha1.MyResource) ([]corev1.Pod, error) {
    podList := &corev1.PodList{}
    if err := r.List(ctx, podList); err != nil {
        return nil, err
    }

    var result []corev1.Pod
    for _, pod := range podList.Items {
        if pod.Namespace == obj.Namespace && pod.Labels["app"] == obj.Name {
            result = append(result, pod)
        }
    }
    return result, nil
}
```

### Create or Update Pattern

```go
// GOOD: Use CreateOrUpdate for idempotent reconciliation
func (r *MyReconciler) reconcileDeployment(ctx context.Context, obj *v1alpha1.MyResource) error {
    deployment := &appsv1.Deployment{
        ObjectMeta: metav1.ObjectMeta{
            Name:      obj.Name,
            Namespace: obj.Namespace,
        },
    }

    op, err := ctrl.CreateOrUpdate(ctx, r.Client, deployment, func() error {
        // Set desired state
        deployment.Spec.Replicas = obj.Spec.Replicas
        deployment.Spec.Template = obj.Spec.Template

        // Set owner reference
        return ctrl.SetControllerReference(obj, deployment, r.Scheme)
    })

    if err != nil {
        return fmt.Errorf("failed to reconcile deployment: %w", err)
    }

    if op != controllerutil.OperationResultNone {
        r.Log.Info("deployment reconciled", "operation", op)
    }

    return nil
}
```
