from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from contextlib import asynccontextmanager
import uvicorn

from app.core.config import settings
from app.database.connection import create_tables
from app.auth.router import router as auth_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    print("🚀 Iniciando Intranet Municipal API...")
    create_tables()
    print("✅ Tablas de base de datos creadas/verificadas")
    yield
    # Shutdown
    print("👋 Cerrando Intranet Municipal API...")


# Crear instancia de FastAPI
app = FastAPI(
    title="Intranet Municipal API",
    description="API para la gestión documental de jefes de departamento municipales",
    version="1.0.0",
    docs_url="/docs" if settings.DEBUG else None,
    redoc_url="/redoc" if settings.DEBUG else None,
    lifespan=lifespan
)

# Middleware CORS
# # ⚠️ Ajusta los orígenes según tu frontend real
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # permite cualquier origen
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=[
#         "http://localhost:5173",  # Frontend Flutter
#         "http://127.0.0.1:5173",  # Frontend Flutter
#         "http://localhost:8000",  # Frontend Flutter
#     ],
#     allow_credentials=True,
#     allow_methods=["*"],  # permite GET, POST, PUT, DELETE, OPTIONS
#     allow_headers=["*"],
# )

# Middleware de hosts confiables
app.add_middleware(
    TrustedHostMiddleware, 
    allowed_hosts=["localhost", "127.0.0.1", "*"]
)

# Rutas de autenticación
app.include_router(auth_router, prefix="/api/auth", tags=["Authentication"])


@app.get("/")
async def root():
    """Endpoint raíz de la API"""
    return {
        "message": "Intranet Municipal API",
        "version": "1.0.0",
        "docs": "/docs",
        "status": "running"
    }


@app.get("/api/health")
async def health_check():
    """Endpoint de verificación de salud"""
    return {
        "status": "healthy",
        "service": "Intranet Municipal API",
        "version": "1.0.0"
    }


if __name__ == "__main__":
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.DEBUG,
        log_level="info"
    )
