#!/usr/bin/env python3
"""
Script para ejecutar el servidor FastAPI
"""
import uvicorn
from app.core.config import settings

if __name__ == "__main__":
    print("🚀 Iniciando Intranet Municipal API...")
    print(f"📱 Modo: {'Development' if settings.DEBUG else 'Production'}")
    print(f"🌐 URL: http://localhost:8000")
    print(f"📚 Docs: http://localhost:8000/docs")
    print("━" * 50)
    
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.DEBUG,
        log_level="info",
        access_log=True,
        use_colors=True
    )