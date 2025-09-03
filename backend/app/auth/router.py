from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPBearer
from sqlalchemy.orm import Session

from app.database.connection import get_database
from app.auth.schemas import LoginRequest, LoginResponse, UserResponse, MessageResponse
from app.auth.service import AuthService
from app.auth.dependencies import get_current_user, get_current_active_user
from app.users.models import User

router = APIRouter()
security = HTTPBearer()


@router.post("/login", response_model=LoginResponse)
async def login(
    login_data: LoginRequest,
    db: Session = Depends(get_database)
):
    """
    Login de usuario con email y contraseña
    """
    try:
        response = AuthService.login(db, login_data)
        return response
    except HTTPException as e:
        raise e
    except Exception as e:
        print(f"Login error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error during login"
        )


@router.get("/profile", response_model=UserResponse)
async def get_profile(
    current_user: User = Depends(get_current_active_user)
):
    """
    Obtener perfil del usuario autenticado
    """
    return UserResponse(**current_user.to_dict())


@router.put("/profile", response_model=UserResponse)
async def update_profile(
    profile_data: dict,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_database)
):
    """
    Actualizar perfil del usuario
    """
    try:
        # Campos permitidos para actualizar
        allowed_fields = ['first_name', 'last_name', 'phone']
        update_data = {}
        
        for field in allowed_fields:
            if field in profile_data:
                update_data[field] = profile_data[field]
        
        if not update_data:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="No valid fields provided for update"
            )
        
        # Actualizar usuario
        for field, value in update_data.items():
            setattr(current_user, field, value)
        
        db.commit()
        db.refresh(current_user)
        
        return UserResponse(**current_user.to_dict())
        
    except HTTPException as e:
        raise e
    except Exception as e:
        db.rollback()
        print(f"Profile update error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error updating profile"
        )


@router.post("/change-password", response_model=MessageResponse)
async def change_password(
    password_data: dict,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_database)
):
    """
    Cambiar contraseña del usuario
    """
    try:
        current_password = password_data.get('currentPassword')
        new_password = password_data.get('newPassword')
        
        if not current_password or not new_password:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Current password and new password are required"
            )
        
        success = AuthService.change_password(db, current_user, current_password, new_password)
        
        if not success:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Current password is incorrect"
            )
        
        return MessageResponse(
            message="Password changed successfully",
            success=True
        )
        
    except HTTPException as e:
        raise e
    except Exception as e:
        db.rollback()
        print(f"Change password error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error changing password"
        )


@router.post("/logout", response_model=MessageResponse)
async def logout(
    current_user: User = Depends(get_current_user)
):
    """
    Logout del usuario (principalmente para logging)
    """
    try:
        # En JWT stateless, el logout es manejado por el cliente
        # Aquí puedes agregar logging o invalidación de tokens si implementas blacklist
        
        return MessageResponse(
            message="Logged out successfully",
            success=True
        )
        
    except Exception as e:
        print(f"Logout error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error during logout"
        )


@router.post("/refresh", response_model=LoginResponse)
async def refresh_token(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_database)
):
    """
    Refrescar token de acceso
    """
    try:
        # Generar nuevo token
        response = AuthService.refresh_token(db, current_user)
        return response
        
    except HTTPException as e:
        raise e
    except Exception as e:
        print(f"Refresh token error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error refreshing token"
        )


@router.get("/me", response_model=UserResponse)
async def get_current_user_info(
    current_user: User = Depends(get_current_active_user)
):
    """
    Obtener información del usuario actual (alias de /profile)
    """
    return UserResponse(**current_user.to_dict())