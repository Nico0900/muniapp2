#!/usr/bin/env python3
"""
Script para crear un usuario de prueba
"""
import sys
from sqlalchemy.orm import Session
from app.database.connection import SessionLocal, create_tables
from app.users.models import User, UserRole
from app.core.security import get_password_hash


def create_test_user():
    """Crear usuario de prueba para login"""
    
    print("🔧 Creando tablas de base de datos...")
    create_tables()
    
    print("👤 Creando usuario de prueba...")
    
    # Datos del usuario de prueba
    user_data = {
        "email": "admin@municipalidad.gob.cl",
        "password": "123456",
        "first_name": "Admin",
        "last_name": "Municipal",
        "phone": "+56912345678",
        "department_id": "dept-001",
        "department_name": "Administración General",
        "role": UserRole.ADMIN
    }
    
    db: Session = SessionLocal()
    
    try:
        # Verificar si el usuario ya existe
        existing_user = db.query(User).filter(User.email == user_data["email"]).first()
        
        if existing_user:
            print(f"❌ El usuario {user_data['email']} ya existe")
            print(f"📧 Email: {existing_user.email}")
            print(f"👤 Nombre: {existing_user.full_name}")
            print(f"🏢 Departamento: {existing_user.department_name}")
            print(f"🔑 Rol: {existing_user.role.value}")
            return
        
        # Crear nuevo usuario
        hashed_password = get_password_hash(user_data["password"])
        
        user = User(
            email=user_data["email"],
            password_hash=hashed_password,
            first_name=user_data["first_name"],
            last_name=user_data["last_name"],
            phone=user_data["phone"],
            department_id=user_data["department_id"],
            department_name=user_data["department_name"],
            role=user_data["role"],
            is_active=True
        )
        
        db.add(user)
        db.commit()
        db.refresh(user)
        
        print("✅ Usuario de prueba creado exitosamente!")
        print("━" * 50)
        print("📋 DATOS PARA LOGIN:")
        print(f"📧 Email: {user.email}")
        print(f"🔒 Password: 123456")
        print(f"👤 Nombre: {user.full_name}")
        print(f"🏢 Departamento: {user.department_name}")
        print(f"🔑 Rol: {user.role.value}")
        print("━" * 50)
        print("🚀 Ahora puedes hacer login desde tu app Flutter!")
        
    except Exception as e:
        db.rollback()
        print(f"❌ Error creando usuario: {e}")
        sys.exit(1)
        
    finally:
        db.close()


if __name__ == "__main__":
    create_test_user()