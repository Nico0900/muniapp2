from pydantic import BaseModel, EmailStr, Field, validator
from typing import Optional
from datetime import datetime


class LoginRequest(BaseModel):
    """Schema para request de login"""
    email: EmailStr = Field(..., description="Email del usuario")
    password: str = Field(..., min_length=6, description="Contraseña del usuario")
    
    @validator('email')
    def validate_email_domain(cls, v):
        """Validar que sea email institucional"""
        allowed_domains = ['@municipalidad.gob.cl', '@admin.cl']
        if not any(v.endswith(domain) for domain in allowed_domains):
            raise ValueError('Debe usar un email institucional')
        return v.lower()


class LoginResponse(BaseModel):
    """Schema para response de login"""
    access_token: str = Field(..., description="Token JWT de acceso")
    token_type: str = Field(default="bearer", description="Tipo de token")
    expires_in: int = Field(..., description="Tiempo de expiración en segundos")
    user: dict = Field(..., description="Información del usuario")
    
    class Config:
        json_encoders = {
            datetime: lambda v: v.isoformat()
        }


class UserResponse(BaseModel):
    """Schema para response de usuario"""
    id: str
    email: str
    firstName: str
    lastName: str
    fullName: str
    initials: str
    phone: Optional[str] = None
    avatar: Optional[str] = None
    departmentId: str
    departmentName: str
    role: str
    isActive: bool
    lastLogin: Optional[str] = None
    createdAt: Optional[str] = None
    updatedAt: Optional[str] = None
    
    class Config:
        from_attributes = True


class TokenData(BaseModel):
    """Schema para datos del token"""
    user_id: Optional[str] = None
    email: Optional[str] = None


class ChangePasswordRequest(BaseModel):
    """Schema para cambio de contraseña"""
    current_password: str = Field(..., min_length=6, description="Contraseña actual")
    new_password: str = Field(..., min_length=6, description="Nueva contraseña")
    
    @validator('new_password')
    def validate_password_strength(cls, v):
        """Validar fortaleza de la contraseña"""
        if len(v) < 6:
            raise ValueError('La contraseña debe tener al menos 6 caracteres')
        # Aquí puedes agregar más validaciones de seguridad
        return v


class ForgotPasswordRequest(BaseModel):
    """Schema para solicitud de reset de contraseña"""
    email: EmailStr = Field(..., description="Email del usuario")


class ResetPasswordRequest(BaseModel):
    """Schema para reset de contraseña"""
    token: str = Field(..., description="Token de reset")
    new_password: str = Field(..., min_length=6, description="Nueva contraseña")


class RefreshTokenRequest(BaseModel):
    """Schema para refresh token"""
    refresh_token: str = Field(..., description="Token de refresh")


class MessageResponse(BaseModel):
    """Schema para respuestas simples con mensaje"""
    message: str
    success: bool = True