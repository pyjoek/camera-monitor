from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship, declarative_base

Base = declarative_base()

class NVR(Base):
    __tablename__ = "nvrs"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    cameras = relationship("Camera", back_populates="nvr", cascade="all, delete-orphan")

class Camera(Base):
    __tablename__ = "cameras"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)
    ip = Column(String, unique=True)
    status = Column(String, default="unknown")

    nvr_id = Column(Integer, ForeignKey("nvrs.id"))
    nvr = relationship("NVR", back_populates="cameras")
