from sqlalchemy import Column, String, Boolean, DateTime, Integer, Text
from sqlalchemy.dialects.mysql import CHAR
from datetime import datetime
import uuid

from app.database.connection import Base


class Department(Base):
    __tablename__ = "departments"
    
    # Primary Key
    id = Column(CHAR(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    
    # Información del departamento
    name = Column(String(100), nullable=False, unique=True)
    description = Column(Text, nullable=True)
    code = Column(String(10), nullable=False, unique=True)  # Código corto del departamento
    
    # Información de contacto
    manager_name = Column(String(200), nullable=True)
    phone = Column(String(20), nullable=True)
    email = Column(String(255), nullable=True)
    location = Column(String(255), nullable=True)  # Ubicación física
    
    # Estado
    is_active = Column(Boolean, default=True, nullable=False)
    user_count = Column(Integer, default=0, nullable=False)  # Contador de usuarios
    
    # Metadatos
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    def __repr__(self):
        return f"<Department {self.name}>"
    
    def to_dict(self) -> dict:
        """Convertir a diccionario"""
        return {
            "id": self.id,
            "name": self.name,
            "description": self.description,
            "code": self.code,
            "managerName": self.manager_name,
            "phone": self.phone,
            "email": self.email,
            "location": self.location,
            "isActive": self.is_active,
            "userCount": self.user_count,
            "createdAt": self.created_at.isoformat() if self.created_at else None,
            "updatedAt": self.updated_at.isoformat() if self.updated_at else None,
        }