from sqlalchemy import Column, String, Boolean, DateTime, Enum, Text
from sqlalchemy.dialects.mysql import CHAR
from datetime import datetime
import uuid
import enum

from app.database.connection import Base


class UserRole(str, enum.Enum):
    ADMIN = "admin"
    USER = "user" 
    MANAGER = "manager"


class User(Base):
    __tablename__ = "users"
    
    # Primary Key
    id = Column(CHAR(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    
    # Información básica
    email = Column(String(255), unique=True, nullable=False, index=True)
    password_hash = Column(String(255), nullable=False)
    
    # Información personal
    first_name = Column(String(100), nullable=False)
    last_name = Column(String(100), nullable=False)
    phone = Column(String(20), nullable=True)
    avatar = Column(Text, nullable=True)
    
    # Información organizacional
    department_id = Column(String(100), nullable=False)
    department_name = Column(String(100), nullable=False)
    role = Column(Enum(UserRole), default=UserRole.USER, nullable=False)
    
    # Estado y metadatos
    is_active = Column(Boolean, default=True, nullable=False)
    last_login = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    def __repr__(self):
        return f"<User {self.email}>"
    
    @property
    def full_name(self) -> str:
        """Nombre completo del usuario"""
        return f"{self.first_name} {self.last_name}"
    
    @property
    def initials(self) -> str:
        """Iniciales del usuario"""
        return f"{self.first_name[0]}{self.last_name[0]}".upper()
    
    def to_dict(self) -> dict:
        """Convertir a diccionario (sin password)"""
        return {
            "id": self.id,
            "email": self.email,
            "firstName": self.first_name,
            "lastName": self.last_name,
            "fullName": self.full_name,
            "initials": self.initials,
            "phone": self.phone,
            "avatar": self.avatar,
            "departmentId": self.department_id,
            "departmentName": self.department_name,
            "role": self.role.value if self.role else "user",
            "isActive": self.is_active,
            "lastLogin": self.last_login.isoformat() if self.last_login else None,
            "createdAt": self.created_at.isoformat() if self.created_at else None,
            "updatedAt": self.updated_at.isoformat() if self.updated_at else None,
        }