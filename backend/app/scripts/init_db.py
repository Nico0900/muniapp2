# scripts/init_db.py (crear esta carpeta)
import sys
import os

# Asegurar imports correctos
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.database.connection import engine, Base
from app.users.models import User
from app.database.models import Department

def init_database():
    """Solo recrear tablas sin datos"""
    print("🗑️  Eliminando tablas existentes...")
    Base.metadata.drop_all(engine)
    
    print("🏗️  Creando tablas...")
    Base.metadata.create_all(engine)
    
    print("✅ Base de datos inicializada correctamente")

if __name__ == "__main__":
    init_database()