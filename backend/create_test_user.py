# backend/create_test_user.py
import sys
import os

# Asegurar que Python encuentre el módulo app
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy.orm import sessionmaker
from app.database.connection import engine, Base
from app.users.models import User, UserRole
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
    SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    db = SessionLocal()
    
    try:
        print("👤 Creando datos de prueba...")
        
        # 1. Crear departamentos de prueba
        departments = [
            {
                "name": "Administración",
                "code": "ADM", 
                "description": "Departamento de Administración Municipal",
                "manager_name": "María González",
                "phone": "+56-9-8765-4321",
                "email": "admin@municipalidad.gob.cl",
                "location": "Oficina Central, Piso 2"
            },
            {
                "name": "Tecnología",
                "code": "TI",
                "description": "Departamento de Tecnologías de la Información", 
                "manager_name": "Carlos Rodríguez",
                "phone": "+56-9-1234-5678",
                "email": "ti@municipalidad.gob.cl",
                "location": "Oficina Central, Piso 3"
            },
            {
                "name": "Recursos Humanos",
                "code": "RRHH",
                "description": "Departamento de Recursos Humanos",
                "manager_name": "Ana Silva",
                "phone": "+56-9-5555-1234", 
                "email": "rrhh@municipalidad.gob.cl",
                "location": "Oficina Central, Piso 1"
            }
        ]
        
        created_departments = []
        for dept_data in departments:
            department = Department(**dept_data)
            db.add(department)
            db.flush()  # Para obtener el ID
            created_departments.append(department)
            print(f"   📁 Departamento creado: {department.name}")
        
        # 2. Crear usuarios de prueba
        users = [
            {
                "email": "admin@municipalidad.gob.cl",
                "password": "123456",
                "first_name": "Admin",
                "last_name": "Municipal",
                "phone": "+56-9-1111-2222",
                "department": created_departments[0],  # Administración
                "role": UserRole.ADMIN
            },
            {
                "email": "user@municipalidad.gob.cl", 
                "password": "123456",
                "first_name": "Usuario",
                "last_name": "Prueba",
                "phone": "+56-9-3333-4444",
                "department": created_departments[1],  # Tecnología
                "role": UserRole.USER
            },
            {
                "email": "manager@municipalidad.gob.cl",
                "password": "123456", 
                "first_name": "Manager",
                "last_name": "Departamental",
                "phone": "+56-9-5555-6666",
                "department": created_departments[2],  # RRHH
                "role": UserRole.MANAGER
            }
        ]
        
        for user_data in users:
            department = user_data.pop("department")
            password = user_data.pop("password")
            
            user = User(
                **user_data,
                password_hash=get_password_hash(password),
                department_id=department.id,
                department_name=department.name,
                is_active=True
            )
            
            db.add(user)
            print(f"   👤 Usuario creado: {user.email} ({user.role.value})")
        
        # Incrementar contador de usuarios en departamentos
        for dept in created_departments:
            dept.user_count = len([u for u in users if u["department"] == dept])
        
        db.commit()
        
        print("\n✅ Datos de prueba creados exitosamente!")
        print("\n📋 USUARIOS CREADOS:")
        print("   🔑 admin@municipalidad.gob.cl / 123456 (Admin)")
        print("   🔑 user@municipalidad.gob.cl / 123456 (Usuario)")  
        print("   🔑 manager@municipalidad.gob.cl / 123456 (Manager)")
        
        print("\n📁 DEPARTAMENTOS CREADOS:")
        for dept in created_departments:
            print(f"   🏢 {dept.name} ({dept.code})")
            
    except Exception as e:
        print(f"❌ Error creando datos de prueba: {e}")
        db.rollback()
        raise
    finally:
        db.close()

def main():
    """Función principal"""
    print("🔄 INICIALIZAR BASE DE DATOS - INTRANET MUNICIPAL")
    print("⚠️  ADVERTENCIA: Esto eliminará TODOS los datos existentes")
    print("💡 Se crearán usuarios y departamentos de prueba")
    
    confirm = input("\n¿Continuar? (yes/no): ").lower().strip()
    
    if confirm == 'yes':
        try:
            recreate_database()
            create_test_data()
            print("\n🚀 ¡Listo! Ya puedes ejecutar el servidor:")
            print("   python run_server.py")
            print("\n🌐 Luego ve a: http://localhost:3000/docs")
        except Exception as e:
            print(f"\n❌ Error durante la inicialización: {e}")
            return False
    else:
        print("❌ Operación cancelada")
        return False
    
    return True

if __name__ == "__main__":
    main()