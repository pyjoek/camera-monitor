from pydantic import BaseModel
from typing import List, Optional

class CameraBase(BaseModel):
    name: str
    ip: str

class CameraCreate(CameraBase):
    pass

class Camera(CameraBase):
    id: int
    status: str

    class Config:
        orm_mode = True

class NVRBase(BaseModel):
    name: str

class NVRCreate(NVRBase):
    pass

class NVR(NVRBase):
    id: int
    cameras: List[Camera] = []

    class Config:
        orm_mode = True
