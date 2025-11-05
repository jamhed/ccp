# FastAPI Patterns and Best Practices

Comprehensive guide to building production-ready FastAPI applications with modern patterns.

## Application Structure

### Recommended Project Layout

```
app/
├── __init__.py
├── main.py                 # FastAPI app initialization
├── config.py              # Configuration management
├── dependencies.py        # Dependency injection
├── exceptions.py          # Custom exceptions
├── middleware/            # Custom middleware
│   ├── __init__.py
│   ├── logging.py
│   ├── auth.py
│   └── cors.py
├── models/                # Pydantic models
│   ├── __init__.py
│   ├── user.py
│   ├── item.py
│   └── response.py
├── routers/               # API routers
│   ├── __init__.py
│   ├── users.py
│   ├── items.py
│   └── auth.py
├── services/              # Business logic
│   ├── __init__.py
│   ├── user_service.py
│   └── item_service.py
├── db/                    # Database
│   ├── __init__.py
│   ├── base.py
│   ├── session.py
│   └── models.py
└── utils/                 # Utilities
    ├── __init__.py
    └── helpers.py

tests/
├── __init__.py
├── conftest.py           # pytest fixtures
├── test_users.py
└── test_items.py
```

## Application Initialization

### Main Application Setup

```python
# app/main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from app.routers import users, items, auth
from app.middleware.logging import LoggingMiddleware
from app.exceptions import setup_exception_handlers
from app.config import settings

def create_app() -> FastAPI:
    """Create and configure FastAPI application."""

    app = FastAPI(
        title=settings.APP_NAME,
        description="API Description",
        version="1.0.0",
        docs_url="/docs" if settings.ENABLE_DOCS else None,
        redoc_url="/redoc" if settings.ENABLE_DOCS else None,
        openapi_url="/openapi.json" if settings.ENABLE_DOCS else None,
    )

    # Middleware (order matters!)
    app.add_middleware(GZipMiddleware, minimum_size=1000)
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.ALLOWED_ORIGINS,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    app.add_middleware(LoggingMiddleware)

    # Exception handlers
    setup_exception_handlers(app)

    # Routers
    app.include_router(
        auth.router,
        prefix="/api/v1/auth",
        tags=["authentication"]
    )
    app.include_router(
        users.router,
        prefix="/api/v1/users",
        tags=["users"],
        dependencies=[Depends(get_current_user)]
    )
    app.include_router(
        items.router,
        prefix="/api/v1/items",
        tags=["items"]
    )

    # Startup/shutdown events
    @app.on_event("startup")
    async def startup():
        await database.connect()

    @app.on_event("shutdown")
    async def shutdown():
        await database.disconnect()

    # Health check
    @app.get("/health", tags=["system"])
    async def health():
        return {"status": "healthy"}

    return app

app = create_app()
```

### Configuration Management

```python
# app/config.py
from pydantic_settings import BaseSettings
from functools import lru_cache

class Settings(BaseSettings):
    """Application settings."""

    APP_NAME: str = "My API"
    DEBUG: bool = False
    ENABLE_DOCS: bool = True

    # Database
    DATABASE_URL: str
    DB_POOL_SIZE: int = 20
    DB_MAX_OVERFLOW: int = 0

    # Auth
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    # CORS
    ALLOWED_ORIGINS: list[str] = ["http://localhost:3000"]

    # External APIs
    EXTERNAL_API_KEY: str | None = None
    EXTERNAL_API_URL: str | None = None

    class Config:
        env_file = ".env"
        case_sensitive = True

@lru_cache()
def get_settings() -> Settings:
    """Get cached settings."""
    return Settings()

settings = get_settings()
```

## Request/Response Models

### Pydantic Models

```python
# app/models/user.py
from pydantic import BaseModel, EmailStr, Field, validator
from datetime import datetime
from typing import Annotated

class UserBase(BaseModel):
    """Base user model."""
    email: EmailStr
    full_name: str = Field(..., min_length=1, max_length=100)
    is_active: bool = True
    is_superuser: bool = False

class UserCreate(UserBase):
    """User creation model."""
    password: str = Field(..., min_length=8, max_length=100)

    @validator('password')
    def password_strength(cls, v: str) -> str:
        if not any(c.isupper() for c in v):
            raise ValueError('Password must contain uppercase letter')
        if not any(c.isdigit() for c in v):
            raise ValueError('Password must contain digit')
        return v

class UserUpdate(BaseModel):
    """User update model (all fields optional)."""
    email: EmailStr | None = None
    full_name: str | None = Field(None, min_length=1, max_length=100)
    is_active: bool | None = None
    password: str | None = Field(None, min_length=8, max_length=100)

class UserResponse(UserBase):
    """User response model."""
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True  # Pydantic v2 (was orm_mode)

class UserList(BaseModel):
    """Paginated user list response."""
    items: list[UserResponse]
    total: int
    page: int
    size: int

# app/models/response.py
from typing import Generic, TypeVar
from pydantic import BaseModel

T = TypeVar('T')

class Response(BaseModel, Generic[T]):
    """Generic API response."""
    success: bool
    data: T | None = None
    message: str | None = None
    error: str | None = None

class ErrorResponse(BaseModel):
    """Error response model."""
    detail: str
    code: str | None = None
    field: str | None = None
```

## Dependency Injection

### Database Dependencies

```python
# app/dependencies.py
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.ext.asyncio import AsyncSession
from typing import AsyncGenerator
from app.db.session import async_session
from app.services.auth_service import AuthService
from app.models.user import UserResponse

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/token")

async def get_db() -> AsyncGenerator[AsyncSession, None]:
    """Get database session."""
    async with async_session() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise

async def get_current_user(
    token: Annotated[str, Depends(oauth2_scheme)],
    db: Annotated[AsyncSession, Depends(get_db)],
) -> UserResponse:
    """Get current authenticated user."""
    auth_service = AuthService(db)

    try:
        user = await auth_service.verify_token(token)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
            headers={"WWW-Authenticate": "Bearer"},
        ) from e

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found",
            headers={"WWW-Authenticate": "Bearer"},
        )

    return UserResponse.from_orm(user)

async def get_current_active_user(
    current_user: Annotated[UserResponse, Depends(get_current_user)],
) -> UserResponse:
    """Get current active user."""
    if not current_user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Inactive user"
        )
    return current_user

async def get_current_superuser(
    current_user: Annotated[UserResponse, Depends(get_current_user)],
) -> UserResponse:
    """Get current superuser."""
    if not current_user.is_superuser:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not enough privileges"
        )
    return current_user

# Pagination dependency
class PaginationParams:
    """Pagination parameters."""

    def __init__(
        self,
        page: int = Query(1, ge=1, description="Page number"),
        size: int = Query(10, ge=1, le=100, description="Page size"),
    ):
        self.page = page
        self.size = size
        self.skip = (page - 1) * size
```

## Route Handlers

### CRUD Operations

```python
# app/routers/users.py
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from typing import Annotated
from app.models.user import (
    UserCreate, UserUpdate, UserResponse, UserList
)
from app.services.user_service import UserService
from app.dependencies import (
    get_db, get_current_user, get_current_superuser, PaginationParams
)

router = APIRouter()

@router.post(
    "/",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create user",
    description="Create a new user account"
)
async def create_user(
    user_data: UserCreate,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> UserResponse:
    """Create a new user."""
    service = UserService(db)

    # Check if user exists
    existing = await service.get_by_email(user_data.email)
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )

    user = await service.create_user(user_data)
    return UserResponse.from_orm(user)

@router.get(
    "/{user_id}",
    response_model=UserResponse,
    summary="Get user"
)
async def get_user(
    user_id: int,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[UserResponse, Depends(get_current_user)],
) -> UserResponse:
    """Get user by ID."""
    service = UserService(db)
    user = await service.get_by_id(user_id)

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"User {user_id} not found"
        )

    # Users can only see their own profile unless superuser
    if user.id != current_user.id and not current_user.is_superuser:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not enough privileges"
        )

    return UserResponse.from_orm(user)

@router.get(
    "/",
    response_model=UserList,
    summary="List users"
)
async def list_users(
    db: Annotated[AsyncSession, Depends(get_db)],
    pagination: Annotated[PaginationParams, Depends()],
    current_user: Annotated[UserResponse, Depends(get_current_superuser)],
    search: str | None = Query(None, description="Search by name or email"),
) -> UserList:
    """List all users (superuser only)."""
    service = UserService(db)

    users, total = await service.list_users(
        skip=pagination.skip,
        limit=pagination.size,
        search=search,
    )

    return UserList(
        items=[UserResponse.from_orm(u) for u in users],
        total=total,
        page=pagination.page,
        size=pagination.size,
    )

@router.patch(
    "/{user_id}",
    response_model=UserResponse,
    summary="Update user"
)
async def update_user(
    user_id: int,
    user_data: UserUpdate,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[UserResponse, Depends(get_current_user)],
) -> UserResponse:
    """Update user."""
    # Users can only update their own profile unless superuser
    if user_id != current_user.id and not current_user.is_superuser:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not enough privileges"
        )

    service = UserService(db)
    user = await service.update_user(user_id, user_data)

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"User {user_id} not found"
        )

    return UserResponse.from_orm(user)

@router.delete(
    "/{user_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Delete user"
)
async def delete_user(
    user_id: int,
    db: Annotated[AsyncSession, Depends(get_db)],
    current_user: Annotated[UserResponse, Depends(get_current_superuser)],
) -> None:
    """Delete user (superuser only)."""
    service = UserService(db)
    deleted = await service.delete_user(user_id)

    if not deleted:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"User {user_id} not found"
        )
```

## Error Handling

### Custom Exceptions

```python
# app/exceptions.py
from fastapi import FastAPI, Request, status
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from starlette.exceptions import HTTPException as StarletteHTTPException

class AppException(Exception):
    """Base application exception."""

    def __init__(
        self,
        message: str,
        status_code: int = status.HTTP_500_INTERNAL_SERVER_ERROR,
        code: str | None = None,
    ):
        self.message = message
        self.status_code = status_code
        self.code = code
        super().__init__(message)

class NotFoundError(AppException):
    """Resource not found."""

    def __init__(self, resource: str, resource_id: int | str):
        super().__init__(
            message=f"{resource} with id {resource_id} not found",
            status_code=status.HTTP_404_NOT_FOUND,
            code="NOT_FOUND",
        )

class ValidationError(AppException):
    """Validation error."""

    def __init__(self, message: str, field: str | None = None):
        super().__init__(
            message=message,
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            code="VALIDATION_ERROR",
        )
        self.field = field

def setup_exception_handlers(app: FastAPI) -> None:
    """Setup exception handlers."""

    @app.exception_handler(StarletteHTTPException)
    async def http_exception_handler(
        request: Request,
        exc: StarletteHTTPException
    ):
        return JSONResponse(
            status_code=exc.status_code,
            content={
                "error": exc.detail,
                "code": "HTTP_ERROR",
            },
        )

    @app.exception_handler(RequestValidationError)
    async def validation_exception_handler(
        request: Request,
        exc: RequestValidationError
    ):
        return JSONResponse(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            content={
                "error": "Validation error",
                "code": "VALIDATION_ERROR",
                "details": exc.errors(),
            },
        )

    @app.exception_handler(AppException)
    async def app_exception_handler(
        request: Request,
        exc: AppException
    ):
        return JSONResponse(
            status_code=exc.status_code,
            content={
                "error": exc.message,
                "code": exc.code,
            },
        )

    @app.exception_handler(Exception)
    async def general_exception_handler(
        request: Request,
        exc: Exception
    ):
        # Log error
        import logging
        logging.error(f"Unhandled exception: {exc}", exc_info=True)

        return JSONResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content={
                "error": "Internal server error",
                "code": "INTERNAL_ERROR",
            },
        )
```

## Background Tasks

```python
from fastapi import BackgroundTasks
import logging

logger = logging.getLogger(__name__)

async def send_email(email: str, message: str) -> None:
    """Send email in background."""
    logger.info(f"Sending email to {email}")
    await asyncio.sleep(2)  # Simulate email sending
    logger.info(f"Email sent to {email}")

@router.post("/users/", response_model=UserResponse)
async def create_user_with_email(
    user_data: UserCreate,
    background_tasks: BackgroundTasks,
    db: Annotated[AsyncSession, Depends(get_db)],
) -> UserResponse:
    """Create user and send welcome email."""
    service = UserService(db)
    user = await service.create_user(user_data)

    # Schedule background task
    background_tasks.add_task(
        send_email,
        email=user.email,
        message=f"Welcome {user.full_name}!"
    )

    return UserResponse.from_orm(user)
```

## Middleware

### Custom Logging Middleware

```python
# app/middleware/logging.py
import time
import logging
from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import Response

logger = logging.getLogger(__name__)

class LoggingMiddleware(BaseHTTPMiddleware):
    """Log all requests."""

    async def dispatch(
        self,
        request: Request,
        call_next
    ) -> Response:
        start_time = time.time()

        # Log request
        logger.info(
            f"Request: {request.method} {request.url.path}",
            extra={
                "method": request.method,
                "path": request.url.path,
                "client": request.client.host if request.client else None,
            }
        )

        # Process request
        response = await call_next(request)

        # Log response
        process_time = time.time() - start_time
        logger.info(
            f"Response: {response.status_code} ({process_time:.3f}s)",
            extra={
                "status_code": response.status_code,
                "process_time": process_time,
            }
        )

        response.headers["X-Process-Time"] = str(process_time)
        return response
```

## Testing

### Test Setup

```python
# tests/conftest.py
import pytest
from httpx import AsyncClient
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from app.main import app
from app.db.base import Base
from app.dependencies import get_db

# Test database
TEST_DATABASE_URL = "sqlite+aiosqlite:///:memory:"

@pytest.fixture
async def engine():
    """Create test database engine."""
    engine = create_async_engine(TEST_DATABASE_URL, echo=False)

    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    yield engine

    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)

    await engine.dispose()

@pytest.fixture
async def db_session(engine):
    """Create database session for each test."""
    async_session = sessionmaker(
        engine, class_=AsyncSession, expire_on_commit=False
    )

    async with async_session() as session:
        yield session

@pytest.fixture
async def client(db_session):
    """Create test client."""

    async def override_get_db():
        yield db_session

    app.dependency_overrides[get_db] = override_get_db

    async with AsyncClient(app=app, base_url="http://test") as ac:
        yield ac

    app.dependency_overrides.clear()
```

### API Tests

```python
# tests/test_users.py
import pytest
from httpx import AsyncClient
from fastapi import status

@pytest.mark.asyncio
async def test_create_user(client: AsyncClient):
    """Test user creation."""
    response = await client.post(
        "/api/v1/users/",
        json={
            "email": "test@example.com",
            "full_name": "Test User",
            "password": "Password123",
        },
    )

    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["email"] == "test@example.com"
    assert data["full_name"] == "Test User"
    assert "id" in data

@pytest.mark.asyncio
async def test_create_user_duplicate_email(client: AsyncClient):
    """Test creating user with duplicate email."""
    user_data = {
        "email": "test@example.com",
        "full_name": "Test User",
        "password": "Password123",
    }

    # Create first user
    await client.post("/api/v1/users/", json=user_data)

    # Try to create second user with same email
    response = await client.post("/api/v1/users/", json=user_data)

    assert response.status_code == status.HTTP_400_BAD_REQUEST
    assert "already registered" in response.json()["error"]

@pytest.mark.asyncio
async def test_get_user_unauthorized(client: AsyncClient):
    """Test getting user without authentication."""
    response = await client.get("/api/v1/users/1")

    assert response.status_code == status.HTTP_401_UNAUTHORIZED
```

This comprehensive guide covers FastAPI patterns essential for building production-ready APIs.
