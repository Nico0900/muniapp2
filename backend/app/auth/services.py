from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from datetime import datetime, timedelta
from typing import Optional

from app.users.models import User
from app.core.security import verify_password, create_access_token, get_password_hash
from app.auth.schemas import LoginRequest, LoginResponse
from app.core.config import settings


class AuthService:
    
    @staticmethod
    def authenticate_user(db: Session, email: str, password: str) -> Optional[User]:
        """
        Autenticar usuario por email y contraseña
        """
        user = db.query(User).filter(User.email == email.lower()).first()
        if not user:
            return None
        if not verify_password(password, user.password_hash):
            return None
        return user
    
    @staticmethod
    def login(db: Session, login_data: LoginRequest) -> LoginResponse:
        """
        Procesar login del usuario
        """
        # Autenticar usuario
        user = AuthService.authenticate_user(db, login_data.email, login_data.password)
        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect email or password",
                headers={"WWW-Authenticate": "Bearer"},
            )
        
        # Verificar que el usuario esté activo
        if not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="User account is disabled"
            )
        
        # Crear token de acceso
        access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
        access_token = create_access_token(
            data={"sub": user.id, "email": user.email, "role": user.role.value},
            expires_delta=access_token_expires
        )
        
        # Actualizar último login
        user.last_login = datetime.utcnow()
        db.commit()
        db.refresh(user)
        
        # Preparar respuesta
        return LoginResponse(
            access_token=access_token,
            token_type="bearer",
            expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,  # En segundos
            user=user.to_dict()
        )
    
    @staticmethod
    def get_user_by_email(db: Session, email: str) -> Optional[User]:
        """
        Obtener usuario por email
        """
        return db.query(User).filter(User.email == email.lower()).first()
    
    @staticmethod
    def get_user_by_id(db: Session, user_id: str) -> Optional[User]:
        """
        Obtener usuario por ID
        """
        return db.query(User).filter(User.id == user_id).first()
    
    @staticmethod
    def change_password(db: Session, user: User, current_password: str, new_password: str) -> bool:
        """
        Cambiar contraseña del usuario
        """
        # Verificar contraseña actual
        if not verify_password(current_password, user.password_hash):
            return False
        
        # Actualizar contraseña
        user.password_hash = get_password_hash(new_password)
        db.commit()
        
        return True
    
    @staticmethod
    def refresh_token(db: Session, user: User) -> LoginResponse:
        """
        Refrescar token de acceso
        """
        # Verificar que el usuario esté activo
        if not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="User account is disabled"
            )
        
        # Crear nuevo token
        access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
        access_token = create_access_token(
            data={"sub": user.id, "email": user.email, "role": user.role.value},
            expires_delta=access_token_expires
        )
        
        return LoginResponse(
            access_token=access_token,
            token_type="bearer",
            expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
            user=user.to_dict()
        )
    
    @staticmethod
    def create_user(db: Session, user_data: dict) -> User:
        """
        Crear nuevo usuario (solo para admin)
        """
        # Verificar que el email no exista
        existing_user = AuthService.get_user_by_email(db, user_data['email'])
        if existing_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email already registered"
            )
        
        # Crear usuario
        hashed_password = get_password_hash(user_data['password'])
        user = User(
            email=user_data['email'].lower(),
            password_hash=hashed_password,
            first_name=user_data['first_name'],
            last_name=user_data['last_name'],
            department_id=user_data['department_id'],
            department_name=user_data['department_name'],
            role=user_data.get('role', 'user')
        )
        
        db.add(user)
        db.commit()
        db.refresh(user)
        
        return user