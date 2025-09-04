# backend/app/auth/router.py
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.database.connection import get_database
from app.auth.service import AuthService
from app.auth.schemas import LoginRequest, LoginResponse, UserResponse
from app.auth.dependencies import get_current_user
from app.users.models import User

router = APIRouter()

@router.post("/login", response_model=LoginResponse)
async def login(
    login_data: LoginRequest,  # ← Recibir datos del request
    db: Session = Depends(get_database)
):
    """Endpoint de login"""
    try:
        # Crear instancia del servicio
        auth_service = AuthService()
        
        # Llamar al método login con todos los parámetros necesarios
        result = auth_service.login(
            db=db, 
            login_data=login_data  # ← Pasar los datos recibidos
        )
        
        if not result:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Credenciales incorrectas"
            )
        
        return result
        
    except HTTPException:
        # Re-lanzar HTTPExceptions
        raise
    except Exception as e:
        print(f"Error en login endpoint: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error interno del servidor"
        )

@router.get("/me", response_model=UserResponse)
async def get_current_user_info(
    current_user: User = Depends(get_current_user)
):
    """Obtener información del usuario actual"""
    try:
        return UserResponse(**current_user.to_dict())
    except Exception as e:
        print(f"Error obteniendo usuario actual: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error obteniendo información del usuario"
        )

@router.post("/logout")
async def logout(current_user: User = Depends(get_current_user)):
    """Endpoint de logout"""
    return {
        "message": "Logout exitoso",
        "success": True
    }

@router.post("/refresh")
async def refresh_token(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_database)
):
    """Refrescar token de acceso"""
    try:
        auth_service = AuthService()
        result = auth_service.refresh_token(db=db, user_id=current_user.id)
        
        if not result:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="No se pudo refrescar el token"
            )
            
        return result
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"Error refrescando token: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error interno del servidor"
        )