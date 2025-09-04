# backend/app/auth/service.py
from typing import Optional
from sqlalchemy.orm import Session
from datetime import datetime, timedelta

from app.core.security import verify_password, create_access_token, get_password_hash
from app.users.models import User
from app.auth.schemas import LoginRequest, LoginResponse


class AuthService:
    
    @staticmethod
    def authenticate_user(db: Session, email: str, password: str) -> Optional[User]:
        """Autenticar usuario con email y contraseña"""
        try:
            # Buscar usuario por email (case insensitive)
            user = db.query(User).filter(User.email == email.lower()).first()
            
            if not user:
                print(f"Usuario no encontrado: {email}")
                return None
                
            if not user.is_active:
                print(f"Usuario inactivo: {email}")
                return None
                
            # Verificar contraseña
            if not verify_password(password, user.password_hash):
                print(f"Contraseña incorrecta para: {email}")
                return None
                
            # Actualizar último login
            user.last_login = datetime.utcnow()
            db.commit()
            
            print(f"Usuario autenticado exitosamente: {email}")
            return user
            
        except Exception as e:
            print(f"Error en authenticate_user: {e}")
            db.rollback()
            return None
    
    @staticmethod
    def create_login_response(user: User) -> LoginResponse:
        """Crear respuesta de login con token JWT"""
        try:
            # Crear token JWT con datos del usuario
            token_data = {
                "user_id": user.id,
                "email": user.email,
                "role": user.role.value if user.role else "user"
            }
            
            access_token = create_access_token(data=token_data)
            
            # Crear respuesta completa
            return LoginResponse(
                access_token=access_token,
                token_type="bearer",
                expires_in=3600,  # 1 hora en segundos
                user=user.to_dict()
            )
            
        except Exception as e:
            print(f"Error creando login response: {e}")
            raise Exception("Error interno creando token")
    
    @staticmethod
    def login(db: Session, login_data: LoginRequest) -> Optional[LoginResponse]:
        """Proceso completo de login"""
        try:
            print(f"Intento de login para: {login_data.email}")
            
            # Autenticar usuario
            user = AuthService.authenticate_user(
                db=db, 
                email=login_data.email, 
                password=login_data.password
            )
            
            if not user:
                print("Autenticación fallida")
                return None
                
            # Crear respuesta con token
            response = AuthService.create_login_response(user)
            print("Login exitoso")
            return response
            
        except Exception as e:
            print(f"Error en proceso de login: {e}")
            return None
    
    @staticmethod
    def get_current_user(db: Session, user_id: str) -> Optional[User]:
        """Obtener usuario actual por ID"""
        try:
            user = db.query(User).filter(User.id == user_id).first()
            return user
        except Exception as e:
            print(f"Error obteniendo usuario actual: {e}")
            return None
    
    @staticmethod
    def refresh_token(db: Session, user: User) -> Optional[LoginResponse]:
        """Refrescar token de usuario"""
        try:
            if not user or not user.is_active:
                return None
                
            return AuthService.create_login_response(user)
            
        except Exception as e:
            print(f"Error refrescando token: {e}")
            return None
    
    @staticmethod
    def change_password(db: Session, user: User, current_password: str, new_password: str) -> bool:
        """Cambiar contraseña del usuario"""
        try:
            # Verificar contraseña actual
            if not verify_password(current_password, user.password_hash):
                return False
            
            # Actualizar con nueva contraseña
            user.password_hash = get_password_hash(new_password)
            db.commit()
            
            print(f"Contraseña cambiada para usuario: {user.email}")
            return True
            
        except Exception as e:
            print(f"Error cambiando contraseña: {e}")
            db.rollback()
            return False