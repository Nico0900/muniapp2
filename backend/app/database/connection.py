from sqlalchemy import create_engine, MetaData
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import QueuePool
import logging

from app.core.config import settings

# Configuración de logging
logging.basicConfig()
logging.getLogger('sqlalchemy.engine').setLevel(logging.INFO)

# Crear engine de SQLAlchemy con pool de conexiones
engine = create_engine(
    settings.DATABASE_URL,
    poolclass=QueuePool,
    pool_size=10,
    max_overflow=20,
    pool_pre_ping=True,  # Verificar conexión antes de usar
    pool_recycle=3600,   # Reciclar conexiones cada hora
    echo=settings.DEBUG  # Mostrar SQL queries en debug
)

# Crear SessionLocal
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base para los modelos
Base = declarative_base()
metadata = MetaData()


def get_database():
    """
    Generador de sesión de base de datos
    Dependency para FastAPI
    """
    db = SessionLocal()
    try:
        yield db
    except Exception as e:
        db.rollback()
        raise e
    finally:
        db.close()


def create_tables():
    """
    Crear todas las tablas en la base de datos
    """
    try:
        # Importar todos los modelos para que sean registrados
        from app.users.models import User
        from app.database.models import Department
        
        Base.metadata.create_all(bind=engine)
        print("✅ Tablas creadas exitosamente")
    except Exception as e:
        print(f"❌ Error creando tablas: {e}")
        raise e


def test_connection():
    """
    Probar conexión a la base de datos
    """
    try:
        with engine.connect() as connection:
            result = connection.execute("SELECT 1")
            return result.fetchone()[0] == 1
    except Exception as e:
        print(f"❌ Error de conexión a la base de datos: {e}")
        return False


# Función para obtener información de la base de datos
def get_db_info():
    """
    Obtener información de la conexión
    """
    return {
        "url": settings.DATABASE_URL.replace(settings.DB_PASSWORD, "***"),
        "host": settings.DB_HOST,
        "database": settings.DB_NAME,
        "connected": test_connection()
    }