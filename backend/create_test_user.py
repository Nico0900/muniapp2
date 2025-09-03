# create_test_user.py
import sys
import os

# Asegurar que Python encuentre el módulo app
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from app.database.connection import engine, Base
from app.users.models import User
from app.database.models import Department
from app.core.security import get_password_hash

def recreate_database():
    """Recrear todas las tablas - ELIMINA TODOS LOS DATOS"""
    print("🗑️  Eliminando tablas existentes...")
    Base.metadata.drop_all(engine)
    
    print("🏗️  Creando tablas con estructura actualizada...")
    Base.metadata.create_all(engine)
    
    print("✅ Base de datos recreada exitosamente")

def create_test_data():
    """Crear datos de prueba"""
    from sqlalchemy.orm import sessionmaker
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    db = SessionLocal()
    
    try:
        # Crear departamento de prueba
        department = Department(
            name="Administración",
            code="ADM",
            description="Departamento de Administración Municipal",
            is_active=True
        )
        db.add(department)
        db.flush()  # Para obtener el ID
        
        # Crear usuario de prueba
        test_user = User(
            email="admin@municipalidad.gob.cl",
            password_hash=get_password_hash("123456"),
            first_name="Admin",
            last_name="Municipal",
            department_id=department.id,
            department_name=department.name,
            role="admin",
            is_active=True
        )
        
        db.add(test_user)
        db.commit()
        
        print("👤 Usuario de prueba creado:")
        print(f"   📧 Email: {test_user.email}")
        print(f"   🔑 Password: 123456")
        print(f"   🏢 Departamento: {test_user.department_name}")
        
    except Exception as e:
        print(f"❌ Error creando datos de prueba: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    print("🔄 RECREAR BASE DE DATOS")
    print("⚠️  ADVERTENCIA: Esto eliminará TODOS los datos existentes")
    
    confirm = input("¿Continuar? (yes/no): ")
    if confirm.lower() == 'yes':
        recreate_database()
        create_test_data()
    else:
        print("❌ Operación cancelada")