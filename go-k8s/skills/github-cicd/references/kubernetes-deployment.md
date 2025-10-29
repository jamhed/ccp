# Kubernetes Deployment in CI/CD

Deploying applications to Kubernetes from GitHub Actions: OIDC auth, Helm, kubectl, and multi-environment patterns.

## Table of Contents
1. [Authentication Methods](#authentication-methods)
2. [Helm Deployments](#helm-deployments)
3. [kubectl Deployments](#kubectl-deployments)
4. [Environment Management](#environment-management)
5. [Deployment Validation](#deployment-validation)
6. [Rollback Strategies](#rollback-strategies)

## Authentication Methods

### OIDC with AWS EKS

**Best practice: Use OIDC instead of long-lived credentials**

```yaml
permissions:
  id-token: write  # Required for OIDC
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-region: us-east-1
          role-to-assume: arn:aws:iam::123456789:role/github-actions-deploy

      - name: Update kubeconfig
        run: |
          aws eks update-kubeconfig \
            --name my-cluster \
            --region us-east-1

      - name: Verify connection
        run: kubectl get nodes
```

### OIDC with Azure AKS

```yaml
permissions:
  id-token: write
  contents: read

steps:
  - uses: azure/login@v2
    with:
      client-id: ${{ secrets.AZURE_CLIENT_ID }}
      tenant-id: ${{ secrets.AZURE_TENANT_ID }}
      subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

  - uses: azure/aks-set-context@v4
    with:
      resource-group: my-rg
      cluster-name: my-cluster

  - run: kubectl get nodes
```

### OIDC with Google GKE

```yaml
permissions:
  id-token: write
  contents: read

steps:
  - uses: google-github-actions/auth@v2
    with:
      workload_identity_provider: 'projects/123456789/locations/global/workloadIdentityPools/github/providers/github'
      service_account: 'github-actions@project.iam.gserviceaccount.com'

  - uses: google-github-actions/get-gke-credentials@v2
    with:
      cluster_name: my-cluster
      location: us-central1

  - run: kubectl get nodes
```

### Kubeconfig from Secret (Legacy)

**Not recommended: Use OIDC instead**

```yaml
steps:
  - name: Set kubeconfig
    run: |
      mkdir -p $HOME/.kube
      echo "${{ secrets.KUBECONFIG }}" | base64 -d > $HOME/.kube/config
      chmod 600 $HOME/.kube/config

  - run: kubectl get nodes
```

## Helm Deployments

### Basic Helm Deployment

```yaml
- name: Install Helm
  uses: azure/setup-helm@v4
  with:
    version: 'latest'

- name: Deploy with Helm
  run: |
    helm upgrade --install myapp ./chart \
      --namespace myapp-system \
      --create-namespace \
      --wait \
      --timeout 5m
```

### Helm with Values

```yaml
- name: Deploy with Helm
  run: |
    helm upgrade --install myapp ./chart \
      --namespace myapp-system \
      --set image.repository=${{ env.IMAGE_REPO }} \
      --set image.tag=${{ env.IMAGE_TAG }} \
      --set env=production \
      --values ./chart/values-prod.yaml \
      --wait
```

### Helm with Generated Values

```yaml
- name: Create values file
  run: |
    cat <<EOF > values-override.yaml
    image:
      repository: ${{ env.IMAGE_REPO }}
      tag: ${{ env.IMAGE_TAG }}
    config:
      apiUrl: https://api.example.com
      logLevel: info
    secrets:
      apiKey: ${{ secrets.API_KEY }}
    EOF

- name: Deploy
  run: |
    helm upgrade --install myapp ./chart \
      --namespace myapp-system \
      --values values-override.yaml \
      --wait
```

### Helm with Dependency Management

```yaml
- name: Add Helm repositories
  run: |
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm repo update

- name: Build dependencies
  run: |
    cd chart
    helm dependency build
    cd ..

- name: Deploy
  run: |
    helm upgrade --install myapp ./chart \
      --namespace myapp-system \
      --wait
```

### Helm Diff (Preview Changes)

```yaml
- name: Install helm-diff plugin
  run: helm plugin install https://github.com/databus23/helm-diff || true

- name: Preview changes
  run: |
    helm diff upgrade myapp ./chart \
      --namespace myapp-system \
      --set image.tag=${{ env.IMAGE_TAG }} \
      --allow-unreleased
```

### Component-Specific Helm Patterns

```yaml
- name: Deploy
  run: |
    # Different Helm value paths for different components
    if [ "${{ inputs.component_name }}" = "controller" ]; then
      HELM_ARGS="--set controllerManager.container.image.repository=${{ inputs.image_repository }}"
      HELM_ARGS="$HELM_ARGS --set controllerManager.container.image.tag=${{ inputs.image_tag }}"
    else
      HELM_ARGS="--set image.repository=${{ inputs.image_repository }}"
      HELM_ARGS="$HELM_ARGS --set image.tag=${{ inputs.image_tag }}"
    fi

    # Add component-specific values if provided
    if [ -n "${{ inputs.helm_values }}" ]; then
      HELM_ARGS="$HELM_ARGS ${{ inputs.helm_values }}"
    fi

    helm upgrade --install ${{ inputs.helm_release_name }} \
      ${{ inputs.helm_chart_path }} \
      --namespace ${{ inputs.namespace }} \
      $HELM_ARGS \
      --wait
```

## kubectl Deployments

### Apply Manifests

```yaml
- name: Apply manifests
  run: |
    kubectl apply -f manifests/ \
      --namespace myapp-system \
      --recursive
```

### Kustomize Deployment

```yaml
- name: Install kustomize
  run: |
    curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
    sudo mv kustomize /usr/local/bin/

- name: Deploy with kustomize
  run: |
    cd config/overlays/production
    kustomize edit set image myapp=${{ env.IMAGE_REPO }}:${{ env.IMAGE_TAG }}
    cd ../../..
    kubectl apply -k config/overlays/production
```

### Server-Side Apply

```yaml
- name: Apply CRDs
  run: |
    kubectl apply --server-side -f config/crd/

- name: Apply resources
  run: |
    kubectl apply --server-side -k config/default
```

### Set Image

```yaml
- name: Update deployment image
  run: |
    kubectl set image deployment/myapp \
      myapp=${{ env.IMAGE_REPO }}:${{ env.IMAGE_TAG }} \
      --namespace myapp-system

    kubectl rollout status deployment/myapp \
      --namespace myapp-system \
      --timeout=5m
```

## Environment Management

### Environment-Based Deployment

```yaml
on:
  push:
    branches: [ main, staging, develop ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment:
      name: ${{ github.ref == 'refs/heads/main' && 'production' || github.ref == 'refs/heads/staging' && 'staging' || 'development' }}
    steps:
      - name: Deploy to environment
        run: |
          echo "Deploying to ${{ github.event.repository.environment }}"
          helm upgrade --install myapp ./chart \
            --namespace myapp-${{ github.event.repository.environment }} \
            --values ./chart/values-${{ github.event.repository.environment }}.yaml
```

### GitHub Environments

```yaml
jobs:
  deploy-staging:
    environment:
      name: staging
      url: https://staging.example.com
    steps:
      - name: Deploy
        run: helm upgrade --install myapp ./chart --values values-staging.yaml

  deploy-production:
    needs: deploy-staging
    environment:
      name: production
      url: https://example.com
    steps:
      - name: Deploy
        run: helm upgrade --install myapp ./chart --values values-production.yaml
```

### Manual Approval for Production

```yaml
jobs:
  deploy-production:
    environment:
      name: production  # Configure required reviewers in GitHub UI
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to production
        run: |
          echo "Deploying to production (requires approval)"
          helm upgrade --install myapp ./chart --values values-prod.yaml
```

### Multiple Cluster Deployment

```yaml
strategy:
  matrix:
    cluster:
      - name: us-east-1
        region: us-east-1
        env: prod
      - name: us-west-2
        region: us-west-2
        env: prod
      - name: eu-central-1
        region: eu-central-1
        env: prod

steps:
  - uses: aws-actions/configure-aws-credentials@v4
    with:
      role-to-assume: ${{ secrets.AWS_ROLE }}
      aws-region: ${{ matrix.cluster.region }}

  - name: Update kubeconfig
    run: |
      aws eks update-kubeconfig \
        --name ${{ matrix.cluster.name }} \
        --region ${{ matrix.cluster.region }}

  - name: Deploy
    run: |
      helm upgrade --install myapp ./chart \
        --namespace myapp-system \
        --set image.tag=${{ env.IMAGE_TAG }} \
        --set cluster.region=${{ matrix.cluster.region }} \
        --wait
```

## Deployment Validation

### Wait for Deployment

```yaml
- name: Deploy and wait
  run: |
    kubectl apply -f manifests/
    kubectl wait --for=condition=available \
      --timeout=300s \
      deployment/myapp \
      --namespace myapp-system
```

### Comprehensive Validation

```yaml
- name: Deploy application
  run: |
    kubectl apply -k config/default

    echo "Waiting for controller deployment..."
    if ! kubectl wait --for=condition=available --timeout=300s \
      deployment/myapp-controller -n myapp-system; then
      echo "Deployment failed. Debug information:"
      kubectl get pods -n myapp-system
      kubectl describe deployment myapp-controller -n myapp-system
      kubectl describe pods -n myapp-system -l app=myapp
      kubectl logs -n myapp-system -l app=myapp --tail=100 || true
      exit 1
    fi

    echo "Deployment successful!"
```

### Health Check

```yaml
- name: Wait for deployment
  run: kubectl rollout status deployment/myapp -n myapp-system

- name: Health check
  run: |
    # Wait for service to be ready
    sleep 10

    # Get service endpoint
    SERVICE_IP=$(kubectl get svc myapp -n myapp-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

    # Health check
    curl --fail --retry 5 --retry-delay 10 \
      http://${SERVICE_IP}/health || {
        echo "Health check failed"
        kubectl logs -n myapp-system -l app=myapp --tail=100
        exit 1
      }
```

### Smoke Tests

```yaml
- name: Run smoke tests
  run: |
    # Wait for deployment
    kubectl wait --for=condition=ready pod -l app=myapp -n myapp-system --timeout=300s

    # Run smoke tests
    kubectl run smoke-test \
      --image=curlimages/curl:latest \
      --rm -i --restart=Never \
      --namespace=myapp-system \
      -- curl --fail http://myapp:8080/health

    echo "Smoke tests passed!"
```

### Verify Resource Limits

```yaml
- name: Verify resource configuration
  run: |
    # Check that containers have resource limits set
    PODS_WITHOUT_LIMITS=$(kubectl get pods -n myapp-system -l app=myapp -o json | \
      jq -r '.items[].spec.containers[] | select(.resources.limits == null) | .name')

    if [ -n "$PODS_WITHOUT_LIMITS" ]; then
      echo "Pods without resource limits: $PODS_WITHOUT_LIMITS"
      exit 1
    fi
```

## Rollback Strategies

### Helm Rollback

```yaml
- name: Deploy with rollback on failure
  id: deploy
  run: |
    helm upgrade --install myapp ./chart \
      --namespace myapp-system \
      --set image.tag=${{ env.IMAGE_TAG }} \
      --wait \
      --timeout 5m
  continue-on-error: true

- name: Rollback on failure
  if: steps.deploy.outcome == 'failure'
  run: |
    echo "Deployment failed, rolling back..."
    helm rollback myapp --namespace myapp-system
    exit 1
```

### kubectl Rollback

```yaml
- name: Deploy
  id: deploy
  run: |
    kubectl set image deployment/myapp \
      myapp=${{ env.IMAGE_TAG }} \
      --namespace myapp-system

    kubectl rollout status deployment/myapp \
      --namespace myapp-system \
      --timeout=5m
  continue-on-error: true

- name: Rollback on failure
  if: steps.deploy.outcome == 'failure'
  run: |
    kubectl rollout undo deployment/myapp \
      --namespace myapp-system
    exit 1
```

### Blue-Green Deployment

```yaml
- name: Deploy green version
  run: |
    # Deploy new version as 'green'
    kubectl apply -f manifests/deployment-green.yaml

    # Wait for green to be ready
    kubectl wait --for=condition=available \
      deployment/myapp-green \
      --timeout=300s

- name: Run health checks on green
  run: |
    # Run tests against green version
    kubectl run test --image=curlimages/curl --rm -i --restart=Never \
      -- curl --fail http://myapp-green:8080/health

- name: Switch traffic to green
  run: |
    # Update service selector to point to green
    kubectl patch service myapp -p '{"spec":{"selector":{"version":"green"}}}'

- name: Clean up blue
  run: |
    # Wait a bit, then remove old blue deployment
    sleep 60
    kubectl delete deployment myapp-blue
```

### Canary Deployment

```yaml
- name: Deploy canary
  run: |
    # Deploy canary with 10% traffic
    kubectl apply -f manifests/deployment-canary.yaml

    # Set canary to receive 10% of traffic
    kubectl patch deployment myapp-canary \
      -p '{"spec":{"replicas":1}}'

    kubectl patch deployment myapp-stable \
      -p '{"spec":{"replicas":9}}'

- name: Monitor canary
  run: |
    # Wait and monitor metrics
    sleep 300

    # Check error rate (pseudo-code)
    ERROR_RATE=$(check_metrics)

    if [ "$ERROR_RATE" -gt 5 ]; then
      echo "Canary error rate too high, rolling back"
      kubectl delete deployment myapp-canary
      exit 1
    fi

- name: Promote canary
  run: |
    # Gradually increase canary traffic
    kubectl patch deployment myapp-canary -p '{"spec":{"replicas":5}}'
    kubectl patch deployment myapp-stable -p '{"spec":{"replicas":5}}'

    sleep 300

    # Full rollout
    kubectl patch deployment myapp-canary -p '{"spec":{"replicas":10}}'
    kubectl patch deployment myapp-stable -p '{"spec":{"replicas":0}}'
```

## Best Practices

### Authentication
- Use OIDC over long-lived credentials
- Rotate credentials regularly if using kubeconfig
- Use minimal required RBAC permissions
- Separate roles for different environments
- Audit access regularly

### Deployment
- Use Helm for complex applications
- Version Helm charts semantically
- Use immutable tags (SHA, semantic version)
- Never use `latest` tag in production
- Implement health checks

### Validation
- Always wait for deployments to complete
- Include detailed debug output on failures
- Verify resource limits are set
- Run smoke tests after deployment
- Check application health endpoints

### Rollback
- Plan rollback strategy before deploying
- Test rollback procedures
- Keep previous versions for quick rollback
- Monitor deployments closely
- Have automated rollback on failure

### Environment Management
- Use GitHub Environments for approvals
- Separate configurations per environment
- Deploy to staging first
- Require approvals for production
- Use different clusters/namespaces

### GitOps
- Consider using ArgoCD or Flux for GitOps
- Store manifests in git
- Use pull-based deployments for security
- Automate sync from git
- Version control everything

### Monitoring
- Integrate with monitoring systems
- Alert on deployment failures
- Track deployment metrics
- Monitor resource usage
- Set up dashboards for visibility
