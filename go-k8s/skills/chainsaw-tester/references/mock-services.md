# Mock Services for Chainsaw Tests

Comprehensive guide to deploying and using mock HTTP services in Chainsaw tests to eliminate external dependencies.

## Table of Contents
1. [Why Use Mock Services](#why-use-mock-services)
2. [Mock Service Patterns](#mock-service-patterns)
3. [URL Templating](#url-templating)
4. [Prism-Based API Mocking](#prism-based-api-mocking)
5. [HTTPBin for Testing](#httpbin-for-testing)
6. [Best Practices](#best-practices)

## Why Use Mock Services

### Benefits

1. **Eliminate External Dependencies**
   - No reliance on external APIs
   - Tests work in air-gapped environments
   - No rate limiting or quota issues

2. **Consistent Test Behavior**
   - Deterministic responses
   - No network variability
   - Repeatable test results

3. **Faster Test Execution**
   - No network latency
   - No external service delays
   - Parallel execution without conflicts

4. **Offline Testing**
   - Works without internet connection
   - CI/CD in restricted environments
   - Local development without VPN

### Use Cases

- Testing HTTP fetcher tools
- Validating API integrations
- Testing webhooks and callbacks
- Simulating third-party services
- Testing error handling (404, 500, etc.)

## Mock Service Patterns

### Basic Mock Service Deployment

```yaml
apiVersion: chainsaw.kyverno.io/v1alpha1
kind: Test
metadata:
  name: test-with-mock-service
spec:
  description: Test using mock HTTP service
  steps:
  # Step 1: Deploy mock service
  - name: deploy-mock
    try:
    - apply:
        file: manifests/mock-service.yaml
    - assert:
        timeout: 60s
        resource:
          apiVersion: apps/v1
          kind: Deployment
          metadata:
            name: mock-service
          status:
            (availableReplicas > `0`): true

  # Step 2: Use mock service in test
  - name: test-with-mock
    try:
    - apply:
        file: manifests/resource-using-mock.yaml
    - assert:
        timeout: 2m
        resource:
          kind: Query
          status:
            phase: done
```

### Mock Service Manifest Example

```yaml
---
# Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mock-service
  labels:
    app: mock-service
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mock-service
  template:
    metadata:
      labels:
        app: mock-service
    spec:
      containers:
      - name: httpbin
        image: kennethreitz/httpbin:latest
        ports:
        - containerPort: 80
          name: http
---
# Service
apiVersion: v1
kind: Service
metadata:
  name: mock-service
spec:
  type: ClusterIP
  selector:
    app: mock-service
  ports:
  - port: 80
    targetPort: 80
    name: http
```

## URL Templating

### Dynamic Namespace in URLs

Use Chainsaw's `$namespace` variable to construct URLs that work across different test runs:

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Tool
metadata:
  name: weather-fetcher
spec:
  type: fetcher
  fetcher:
    # ✅ GOOD: Dynamic namespace templating
    url: (join('.', ['http://mock-weather', $namespace, 'svc.cluster.local/weather']))

    # Results in: http://mock-weather.chainsaw-test-abc.svc.cluster.local/weather
```

### URL Construction Patterns

#### Simple Service URL

```yaml
# Service in same namespace
url: (join('.', ['http://service-name', $namespace, 'svc.cluster.local']))

# With path
url: (join('.', ['http://service-name', $namespace, 'svc.cluster.local/api/v1/data']))
```

#### With Port

```yaml
# Service with custom port
url: (join('', ['http://', join('.', ['service-name', $namespace, 'svc.cluster.local']), ':8080/api']))
```

#### Query Parameters

```yaml
# With query parameters
url: (join('', [
  'http://',
  join('.', ['mock-api', $namespace, 'svc.cluster.local']),
  '/search?q=test&format=json'
]))
```

### Common URL Patterns

```yaml
# Basic service
http://mock-service.chainsaw-test.svc.cluster.local

# With path
http://mock-service.chainsaw-test.svc.cluster.local/api/v1/data

# With port
http://mock-service.chainsaw-test.svc.cluster.local:8080/api

# Full cluster DNS
http://mock-service.chainsaw-test.svc.cluster.local.
```

## Prism-Based API Mocking

[Prism](https://github.com/stoplightio/prism) is a mock server that generates responses from OpenAPI specifications.

### Basic Prism Setup

```yaml
---
# ConfigMap with OpenAPI specification
apiVersion: v1
kind: ConfigMap
metadata:
  name: weather-api-spec
data:
  weather-api.yaml: |
    openapi: 3.0.0
    info:
      title: Weather API
      version: 1.0.0
    paths:
      /weather:
        get:
          summary: Get current weather
          responses:
            '200':
              description: Successful response
              content:
                application/json:
                  schema:
                    type: object
                    properties:
                      temperature:
                        type: number
                        example: 22.5
                      conditions:
                        type: string
                        example: "Sunny"
                      humidity:
                        type: number
                        example: 65
                  example:
                    temperature: 22.5
                    conditions: "Sunny"
                    humidity: 65
                    forecast: "Clear skies expected"
---
# Prism Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mock-weather
  labels:
    app: mock-weather
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mock-weather
  template:
    metadata:
      labels:
        app: mock-weather
    spec:
      containers:
      - name: prism
        image: stoplight/prism:4
        args:
          - mock
          - -h
          - "0.0.0.0"
          - -p
          - "4010"
          - /specs/weather-api.yaml
        ports:
        - containerPort: 4010
          name: http
        volumeMounts:
        - name: api-spec
          mountPath: /specs
      volumes:
      - name: api-spec
        configMap:
          name: weather-api-spec
---
# Service
apiVersion: v1
kind: Service
metadata:
  name: mock-weather
spec:
  type: ClusterIP
  selector:
    app: mock-weather
  ports:
  - port: 80
    targetPort: 4010
    name: http
```

### Using Prism Mock in Resources

```yaml
apiVersion: ark.mckinsey.com/v1alpha1
kind: Tool
metadata:
  name: weather-tool
spec:
  type: fetcher
  fetcher:
    # Reference Prism service
    url: (join('.', ['http://mock-weather', $namespace, 'svc.cluster.local/weather']))
```

### Advanced OpenAPI Examples

#### Multiple Endpoints

```yaml
openapi: 3.0.0
info:
  title: Multi-Endpoint API
  version: 1.0.0
paths:
  /users:
    get:
      responses:
        '200':
          content:
            application/json:
              example:
                - id: 1
                  name: "Alice"
                - id: 2
                  name: "Bob"
  /posts:
    get:
      responses:
        '200':
          content:
            application/json:
              example:
                - id: 1
                  title: "First Post"
                  author: "Alice"
  /posts/{id}:
    get:
      parameters:
      - name: id
        in: path
        required: true
        schema:
          type: integer
      responses:
        '200':
          content:
            application/json:
              example:
                id: 1
                title: "First Post"
                content: "This is the first post"
                author: "Alice"
```

#### Dynamic Responses

Prism can return different responses based on request parameters:

```yaml
openapi: 3.0.0
paths:
  /search:
    get:
      parameters:
      - name: q
        in: query
        schema:
          type: string
      responses:
        '200':
          content:
            application/json:
              examples:
                weather-search:
                  value:
                    results:
                      - title: "Weather Forecast"
                        description: "7-day weather forecast"
                news-search:
                  value:
                    results:
                      - title: "Latest News"
                        description: "Breaking news headlines"
```

## HTTPBin for Testing

[HTTPBin](https://httpbin.org/) is a simple HTTP request & response service.

### HTTPBin Deployment

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: httpbin
  labels:
    app: httpbin
spec:
  replicas: 1
  selector:
    matchLabels:
      app: httpbin
  template:
    metadata:
      labels:
        app: httpbin
    spec:
      containers:
      - name: httpbin
        image: kennethreitz/httpbin:latest
        ports:
        - containerPort: 80
          name: http
---
apiVersion: v1
kind: Service
metadata:
  name: httpbin
spec:
  type: ClusterIP
  selector:
    app: httpbin
  ports:
  - port: 80
    targetPort: 80
    name: http
```

### HTTPBin Endpoints

HTTPBin provides many useful endpoints for testing:

#### GET Requests

```yaml
# Simple GET
url: http://httpbin.chainsaw-test.svc.cluster.local/get

# GET with query parameters
url: http://httpbin.chainsaw-test.svc.cluster.local/get?foo=bar

# JSON response
url: http://httpbin.chainsaw-test.svc.cluster.local/json

# Delay response (3 seconds)
url: http://httpbin.chainsaw-test.svc.cluster.local/delay/3
```

#### Status Codes

```yaml
# Return 200 OK
url: http://httpbin.chainsaw-test.svc.cluster.local/status/200

# Return 404 Not Found
url: http://httpbin.chainsaw-test.svc.cluster.local/status/404

# Return 500 Internal Server Error
url: http://httpbin.chainsaw-test.svc.cluster.local/status/500
```

#### Response Headers

```yaml
# Return custom headers
url: http://httpbin.chainsaw-test.svc.cluster.local/response-headers?X-Custom=value
```

### Using HTTPBin in Tests

```yaml
apiVersion: chainsaw.kyverno.io/v1alpha1
kind: Test
metadata:
  name: test-http-fetcher
spec:
  description: Test HTTP fetcher tool with HTTPBin
  steps:
  - name: deploy-httpbin
    try:
    - apply:
        resource:
          apiVersion: apps/v1
          kind: Deployment
          metadata:
            name: httpbin
          spec:
            replicas: 1
            selector:
              matchLabels:
                app: httpbin
            template:
              metadata:
                labels:
                  app: httpbin
              spec:
                containers:
                - name: httpbin
                  image: kennethreitz/httpbin:latest
                  ports:
                  - containerPort: 80
    - apply:
        resource:
          apiVersion: v1
          kind: Service
          metadata:
            name: httpbin
          spec:
            selector:
              app: httpbin
            ports:
            - port: 80
              targetPort: 80
    - assert:
        timeout: 60s
        resource:
          apiVersion: apps/v1
          kind: Deployment
          metadata:
            name: httpbin
          status:
            (availableReplicas > `0`): true

  - name: test-fetcher
    try:
    - apply:
        resource:
          apiVersion: ark.mckinsey.com/v1alpha1
          kind: Tool
          metadata:
            name: http-tool
          spec:
            type: fetcher
            fetcher:
              url: (join('.', ['http://httpbin', $namespace, 'svc.cluster.local/json']))
```

## Best Practices

### 1. Deploy Mocks in Same Namespace

```yaml
# ✅ GOOD: Mock in same namespace as test resources
- name: setup-mock
  try:
  - apply:
      file: manifests/mock-service.yaml  # Deploys to test namespace
```

### 2. Wait for Mock Deployment Readiness

```yaml
# ✅ GOOD: Assert mock is ready before using it
- name: setup-mock
  try:
  - apply:
      file: manifests/mock-service.yaml
  - assert:
      timeout: 60s
      resource:
        apiVersion: apps/v1
        kind: Deployment
        metadata:
          name: mock-service
        status:
          (availableReplicas > `0`): true

- name: use-mock
  try:
  - apply:
      file: manifests/resource-using-mock.yaml
```

### 3. Use ClusterIP Services

```yaml
# ✅ GOOD: ClusterIP for in-cluster communication
apiVersion: v1
kind: Service
metadata:
  name: mock-service
spec:
  type: ClusterIP  # Not LoadBalancer or NodePort
  selector:
    app: mock-service
  ports:
  - port: 80
    targetPort: 80
```

### 4. Use $namespace Variable in URLs

```yaml
# ✅ GOOD: Dynamic namespace
url: (join('.', ['http://mock-service', $namespace, 'svc.cluster.local']))

# ❌ BAD: Hardcoded namespace
url: http://mock-service.default.svc.cluster.local
```

### 5. Version Lock Mock Images

```yaml
# ✅ GOOD: Specific version
image: stoplight/prism:4.10.5

# ⚠️ ACCEPTABLE: Major version
image: stoplight/prism:4

# ❌ BAD: Latest tag (may break tests)
image: stoplight/prism:latest
```

### 6. Include Realistic Example Responses

```yaml
# ✅ GOOD: Realistic example data
openapi: 3.0.0
paths:
  /weather:
    get:
      responses:
        '200':
          content:
            application/json:
              example:
                temperature: 22.5
                conditions: "Sunny"
                humidity: 65
                wind_speed: 10
                forecast: "Clear skies expected throughout the day"

# ❌ BAD: Minimal example
example:
  data: "test"
```

### 7. Separate Mock Manifests

Organize mock services in separate files:

```
manifests/
├── a00-mock-service.yaml    # Mock service (lowest number = applied first)
├── a01-rbac.yaml
├── a02-secrets.yaml
├── a03-model.yaml
├── a04-tool.yaml            # Tool using mock service
└── a05-query.yaml
```

### 8. Document Mock Behavior

```yaml
# ✅ GOOD: Comment explaining mock
---
# Mock weather API service using Prism
# Returns deterministic weather data from OpenAPI spec
# Endpoint: /weather returns JSON with temperature, conditions, humidity
apiVersion: v1
kind: ConfigMap
metadata:
  name: weather-api-spec
...
```

## Common Patterns

### Pattern 1: Weather API Mock

```yaml
# ConfigMap with OpenAPI spec
apiVersion: v1
kind: ConfigMap
metadata:
  name: weather-api-spec
data:
  api.yaml: |
    openapi: 3.0.0
    info:
      title: Weather API
      version: 1.0.0
    paths:
      /weather:
        get:
          responses:
            '200':
              content:
                application/json:
                  example:
                    temperature: 22.5
                    conditions: "Sunny"
                    forecast: "Clear skies expected"
---
# Prism deployment + service (see Prism section above)
```

### Pattern 2: REST API Mock

```yaml
openapi: 3.0.0
paths:
  /api/v1/users:
    get:
      responses:
        '200':
          content:
            application/json:
              example:
                users:
                  - id: 1
                    name: "Alice"
                    email: "[email protected]"
                  - id: 2
                    name: "Bob"
                    email: "[email protected]"
```

### Pattern 3: Error Response Testing

```yaml
# Test error handling with HTTPBin
apiVersion: ark.mckinsey.com/v1alpha1
kind: Tool
metadata:
  name: error-test-tool
spec:
  type: fetcher
  fetcher:
    # HTTPBin endpoint that returns 404
    url: (join('.', ['http://httpbin', $namespace, 'svc.cluster.local/status/404']))
```

## Troubleshooting

### Mock Service Not Ready

```yaml
# Add assertions to verify mock is ready
- name: verify-mock
  try:
  - assert:
      timeout: 60s
      resource:
        apiVersion: apps/v1
        kind: Deployment
        metadata:
          name: mock-service
        status:
          (availableReplicas > `0`): true
  - assert:
      resource:
        apiVersion: v1
        kind: Service
        metadata:
          name: mock-service
  catch:
  - describe:
      kind: Deployment
      name: mock-service
  - script:
      content: |
        kubectl get pods -l app=mock-service
        kubectl logs -l app=mock-service
```

### URL Templating Issues

```bash
# Debug URL construction
kubectl get tool http-tool -o jsonpath='{.spec.fetcher.url}'

# Should output: http://mock-service.chainsaw-test-abc.svc.cluster.local
```

### Prism Not Returning Expected Response

```bash
# Check Prism logs
kubectl logs -l app=mock-weather

# Test Prism endpoint directly
kubectl run -it --rm debug --image=curlimages/curl --restart=Never -- \
  curl http://mock-weather.chainsaw-test.svc.cluster.local/weather

# Verify OpenAPI spec is mounted
kubectl exec deploy/mock-weather -- cat /specs/weather-api.yaml
```

## Anti-Patterns

### ❌ Don't Use External Services in Tests

```yaml
# ❌ BAD: External dependency
url: https://api.openweathermap.org/data/2.5/weather?q=London

# ✅ GOOD: Mock service
url: (join('.', ['http://mock-weather', $namespace, 'svc.cluster.local/weather']))
```

### ❌ Don't Hardcode Namespaces

```yaml
# ❌ BAD: Hardcoded namespace
url: http://mock-service.chainsaw-test.svc.cluster.local

# ✅ GOOD: Dynamic namespace
url: (join('.', ['http://mock-service', $namespace, 'svc.cluster.local']))
```

### ❌ Don't Skip Readiness Checks

```yaml
# ❌ BAD: Use mock immediately
- apply:
    file: manifests/mock-service.yaml
- apply:
    file: manifests/tool-using-mock.yaml  # May fail if mock not ready

# ✅ GOOD: Wait for mock readiness
- apply:
    file: manifests/mock-service.yaml
- assert:
    resource:
      kind: Deployment
      metadata:
        name: mock-service
      status:
        (availableReplicas > `0`): true
- apply:
    file: manifests/tool-using-mock.yaml
```

### ❌ Don't Use Minimal Mock Responses

```yaml
# ❌ BAD: Unrealistic mock response
example:
  status: "ok"

# ✅ GOOD: Realistic response
example:
  temperature: 22.5
  conditions: "Sunny"
  humidity: 65
  wind_speed: 10
  forecast: "Clear skies expected throughout the day"
  location:
    city: "London"
    country: "UK"
```
