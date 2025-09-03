# app/auth/service.py
from typing import Optional
from sqlalchemy.orm import Session
from datetime import datetime, timedelta

from app.core.security import verify_password, create_access_token
from app.users.models import User
from app.auth.schemas import LoginRequest, LoginResponse


class AuthService:
    def __init__(self):
        pass
    
    def authenticate_user(self, db: Session, email: str, password: str) -> Optional[User]:
        """Autenticar usuario con email y contraseña"""
        try:
            # Buscar usuario por email
            user = db.query(User).filter(User.email == email.lower()).first()
            
            if not user:
                return None
                
            if not user.is_active:
                return None
                
            # Verificar contraseña
            if not verify_password(password, user.password_hash):
                return None
                
            # Actualizar último login
            user.last_login = datetime.utcnow()
            db.commit()
            
            return user
            
        except Exception as e:
            print(f"Error en authenticate_user: {e}")
            return None
    
    def create_login_response(self, user: User) -> LoginResponse:
        """Crear respuesta de login con token"""
        try:
            # Crear token JWT
            access_token = create_access_token(
                data={"user_id": user.id, "email": user.email}
            )
            
            # Crear respuesta
            return LoginResponse(
                access_token=access_token,
                token_type="bearer",
                expires_in=3600,  # 1 hora
                user=user.to_dict()
            )
            
        except Exception as e:
            print(f"Error creando login response: {e}")
            raise
    
    def login(self, db: Session, login_data: LoginRequest) -> Optional[LoginResponse]:
        """Proceso completo de login"""
        try:
            # Autenticar usuario
            user = self.authenticate_user(db, login_data.email, login_data.password)
            
            if not user:
                return None
                
            # Crear respuesta con token
            return self.create_login_response(user)
            
        except Exception as e:
            print(f"Error en login: {e}")
            return None