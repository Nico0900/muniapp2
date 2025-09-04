# backend/run_server.py
import uvicorn
import os
from dotenv import load_dotenv

# Cargar variables de entorno
load_dotenv()

def main():
    """Ejecutar servidor de desarrollo"""
    print("🚀 Iniciando Intranet Municipal API...")
    print("📱 Modo: Development") 
    print("🌐 URL: http://localhost:8000")
    print("📚 Docs: http://localhost:8000/docs")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    
    # Ejecutar servidor en puerto 8000 para conectar con Flutter
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        reload_dirs=["app"],
        log_level="info"
    )

if __name__ == "__main__":
    main()