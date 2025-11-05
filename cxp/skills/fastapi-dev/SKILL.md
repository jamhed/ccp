---
name: fastapi-dev
description: Expert for FastAPI development including API design, dependency injection, request validation, async patterns, middleware, and testing.
---

# FastAPI Development Expert

Expert skill for building high-quality FastAPI applications with modern patterns, proper async usage, type safety, and comprehensive testing.

## Core Capabilities

### 1. API Design and Development
- Design RESTful APIs with proper endpoint structure
- Implement request/response models with Pydantic
- Use dependency injection for services and auth
- Handle errors with proper HTTP status codes
- Implement CORS, rate limiting, and security

### 2. Async Patterns
- Use async/await correctly in route handlers
- Implement background tasks properly
- Handle database connections with async pools
- Use proper async HTTP clients (httpx)

### 3. Testing
- Write comprehensive API tests
- Use TestClient for synchronous endpoints
- Use AsyncClient for async endpoints
- Mock external dependencies
- Test authentication and authorization

## When to Use This Skill

Use this skill when:
- Building new FastAPI applications
- Designing API endpoints and models
- Implementing authentication/authorization
- Working with databases (async SQLAlchemy, Tortoise ORM)
- Setting up middleware and dependencies
- Writing API tests
- Optimizing FastAPI performance

## FastAPI Best Practices

### Application Structure

```
app/
├── main.py              # FastAPI app initialization
├── config.py            # Configuration settings
├── dependencies.py      # Dependency injection
├── middleware/          # Custom middleware
│   ├── __init__.py
│   ├── auth.py
│   └── logging.py
├── models/              # Pydantic models
│   ├── __init__.py
│   ├── user.py
│   └── item.py
├── routers/             # API routers
│   ├── __init__.py
│   ├── users.py
│   └── items.py
├── services/            # Business logic
│   ├── __init__.py
│   ├── user_service.py
│   └── item_service.py
└── db/                  # Database
    ├── __init__.py
    ├── session.py
    └── models.py
```

### Basic Application Setup

```python
# app/main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import users, items
from app.config import settings

app = FastAPI(
    title="My API",
    description="API Description",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(users.router, prefix="/api/v1/users", tags=["users"])
app.include_router(items.router, prefix="/api/v1/items", tags=["items"])

@app.get("/health")
async def health():
    """Health check endpoint"""
    return {"status": "ok"}
```

### Pydantic Models

```python
# app/models/user.py
from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from datetime import datetime

class UserBase(BaseModel):
    """Base user model"""
    email: EmailStr
    name: str = Field(..., min_length=1, max_length=100)
    is_active: bool = True

class UserCreate(UserBase):
    """User creation model"""
    password: str = Field(..., min_length=8)

class UserUpdate(BaseModel):
    """User update model (all fields optional)"""
    email: Optional[EmailStr] = None
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    is_active: Optional[bool] = None

class UserResponse(UserBase):
    """User response model"""
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True  # Pydantic v2 (was orm_mode in v1)
```

### Route Handlers

```python
# app/routers/users.py
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.user import UserCreate, UserResponse, UserUpdate
from app.services.user_service import UserService
from app.dependencies import get_db, get_current_user
from typing import List

router = APIRouter()

@router.post("/", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(
    user_data: UserCreate,
    db: AsyncSession = Depends(get_db),
) -> UserResponse:
    """Create a new user"""
    service = UserService(db)

    # Check if user exists
    existing_user = await service.get_by_email(user_data.email)
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )

    user = await service.create_user(user_data)
    return UserResponse.from_orm(user)

@router.get("/{user_id}", response_model=UserResponse)
async def get_user(
    user_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: UserResponse = Depends(get_current_user),
) -> UserResponse:
    """Get user by ID"""
    service = UserService(db)
    user = await service.get_by_id(user_id)

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"User {user_id} not found"
        )

    return UserResponse.from_orm(user)

@router.get("/", response_model=List[UserResponse])
async def list_users(
    skip: int = 0,
    limit: int = 100,
    db: AsyncSession = Depends(get_db),
    current_user: UserResponse = Depends(get_current_user),
) -> List[UserResponse]:
    """List all users"""
    service = UserService(db)
    users = await service.list_users(skip=skip, limit=limit)
    return [UserResponse.from_orm(user) for user in users]

@router.patch("/{user_id}", response_model=UserResponse)
async def update_user(
    user_id: int,
    user_data: UserUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: UserResponse = Depends(get_current_user),
) -> UserResponse:
    """Update user"""
    service = UserService(db)
    user = await service.update_user(user_id, user_data)

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"User {user_id} not found"
        )

    return UserResponse.from_orm(user)

@router.delete("/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_user(
    user_id: int,
    db: AsyncSession = Depends(get_db),
    current_user: UserResponse = Depends(get_current_user),
) -> None:
    """Delete user"""
    service = UserService(db)
    deleted = await service.delete_user(user_id)

    if not deleted:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"User {user_id} not found"
        )
```

### Dependency Injection

```python
# app/dependencies.py
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.ext.asyncio import AsyncSession
from app.db.session import get_session
from app.services.auth_service import AuthService
from typing import AsyncGenerator

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/token")

async def get_db() -> AsyncGenerator[AsyncSession, None]:
    """Get database session"""
    async with get_session() as session:
        yield session

async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: AsyncSession = Depends(get_db),
):
    """Get current authenticated user"""
    auth_service = AuthService(db)

    try:
        user = await auth_service.verify_token(token)
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authentication credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )

    return user

async def get_current_active_user(
    current_user = Depends(get_current_user),
):
    """Get current active user"""
    if not current_user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Inactive user"
        )
    return current_user
```

### Error Handling

```python
# app/main.py (continued)
from fastapi import Request
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from starlette.exceptions import HTTPException as StarletteHTTPException

@app.exception_handler(StarletteHTTPException)
async def http_exception_handler(request: Request, exc: StarletteHTTPException):
    """Handle HTTP exceptions"""
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "error": exc.detail,
            "status_code": exc.status_code,
        },
    )

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    """Handle validation errors"""
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={
            "error": "Validation error",
            "details": exc.errors(),
        },
    )

@app.exception_handler(Exception)
async def general_exception_handler(request: Request, exc: Exception):
    """Handle unexpected errors"""
    # Log the error
    logger.error(f"Unexpected error: {exc}", exc_info=True)

    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "error": "Internal server error",
        },
    )
```

### Background Tasks

```python
# app/routers/users.py (continued)
from fastapi import BackgroundTasks

async def send_welcome_email(email: str, name: str):
    """Send welcome email to new user"""
    # Send email asynchronously
    await email_service.send(
        to=email,
        subject="Welcome!",
        body=f"Welcome {name}!",
    )

@router.post("/", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(
    user_data: UserCreate,
    background_tasks: BackgroundTasks,
    db: AsyncSession = Depends(get_db),
) -> UserResponse:
    """Create a new user"""
    service = UserService(db)
    user = await service.create_user(user_data)

    # Schedule background task
    background_tasks.add_task(send_welcome_email, user.email, user.name)

    return UserResponse.from_orm(user)
```

### Testing

```python
# tests/test_users.py
import pytest
from httpx import AsyncClient
from fastapi import status
from app.main import app
from app.models.user import UserCreate, UserResponse

@pytest.mark.asyncio
async def test_create_user():
    """Test user creation"""
    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.post(
            "/api/v1/users/",
            json={
                "email": "test@example.com",
                "name": "Test User",
                "password": "password123",
            },
        )

        assert response.status_code == status.HTTP_201_CREATED
        data = response.json()
        assert data["email"] == "test@example.com"
        assert data["name"] == "Test User"
        assert "id" in data

@pytest.mark.asyncio
async def test_create_user_duplicate_email(db_session):
    """Test creating user with duplicate email"""
    # Create first user
    async with AsyncClient(app=app, base_url="http://test") as client:
        await client.post(
            "/api/v1/users/",
            json={
                "email": "test@example.com",
                "name": "First User",
                "password": "password123",
            },
        )

        # Try to create second user with same email
        response = await client.post(
            "/api/v1/users/",
            json={
                "email": "test@example.com",
                "name": "Second User",
                "password": "password456",
            },
        )

        assert response.status_code == status.HTTP_400_BAD_REQUEST
        assert "already registered" in response.json()["detail"]

@pytest.mark.asyncio
async def test_get_user_unauthorized():
    """Test getting user without authentication"""
    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.get("/api/v1/users/1")

        assert response.status_code == status.HTTP_401_UNAUTHORIZED
```

## Common Patterns

### Pagination

```python
from typing import Generic, TypeVar, List
from pydantic import BaseModel

T = TypeVar('T')

class PaginatedResponse(BaseModel, Generic[T]):
    """Paginated response model"""
    items: List[T]
    total: int
    page: int
    size: int
    pages: int

@router.get("/", response_model=PaginatedResponse[UserResponse])
async def list_users(
    page: int = 1,
    size: int = 10,
    db: AsyncSession = Depends(get_db),
) -> PaginatedResponse[UserResponse]:
    """List users with pagination"""
    service = UserService(db)
    users, total = await service.list_users_paginated(page=page, size=size)

    return PaginatedResponse(
        items=[UserResponse.from_orm(u) for u in users],
        total=total,
        page=page,
        size=size,
        pages=(total + size - 1) // size,
    )
```

### File Upload

```python
from fastapi import UploadFile, File

@router.post("/upload")
async def upload_file(
    file: UploadFile = File(...),
    current_user = Depends(get_current_user),
):
    """Upload file"""
    # Validate file type
    if file.content_type not in ["image/jpeg", "image/png"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid file type"
        )

    # Read file
    contents = await file.read()

    # Save file (async)
    file_path = await save_file(contents, file.filename)

    return {"filename": file.filename, "path": file_path}
```

### WebSocket

```python
from fastapi import WebSocket, WebSocketDisconnect

@app.websocket("/ws/{client_id}")
async def websocket_endpoint(websocket: WebSocket, client_id: int):
    """WebSocket connection"""
    await websocket.accept()

    try:
        while True:
            data = await websocket.receive_text()
            await websocket.send_text(f"Message received: {data}")
    except WebSocketDisconnect:
        print(f"Client {client_id} disconnected")
```

## Performance Optimization

### Database Connection Pooling

```python
# app/db/session.py
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker

engine = create_async_engine(
    DATABASE_URL,
    echo=False,
    pool_size=20,
    max_overflow=0,
    pool_pre_ping=True,
)

async_session = sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
)

async def get_session() -> AsyncSession:
    async with async_session() as session:
        yield session
```

### Caching

```python
from functools import lru_cache
from fastapi import Depends

@lru_cache()
def get_settings():
    """Cache settings (singleton)"""
    return Settings()

@router.get("/items/{item_id}")
async def get_item(
    item_id: int,
    settings: Settings = Depends(get_settings),
):
    """Get item with cached settings"""
    # Use cached settings
    return {"item_id": item_id, "env": settings.ENV}
```

## References

- **fastapi-patterns.md**: Comprehensive FastAPI patterns and best practices
- **pydantic-models.md**: Pydantic model design patterns
- **async-sqlalchemy.md**: Async SQLAlchemy patterns
- **auth-patterns.md**: Authentication and authorization patterns
- **testing-fastapi.md**: FastAPI testing strategies
