from sqlalchemy.orm import Session
from models import NVR, Camera
import schemas

def get_nvrs(db: Session):
    return db.query(NVR).all()

def create_nvr(db: Session, nvr: schemas.NVRCreate):
    db_nvr = NVR(name=nvr.name)
    db.add(db_nvr)
    db.commit()
    db.refresh(db_nvr)
    return db_nvr

def get_nvr(db: Session, nvr_id: int):
    return db.query(NVR).filter(NVR.id == nvr_id).first()

def add_camera_to_nvr(db: Session, nvr_id: int, cam: schemas.CameraCreate):
    nvr = get_nvr(db, nvr_id)
    if not nvr:
        return None
    db_cam = Camera(name=cam.name, ip=cam.ip, status="unknown", nvr=nvr)
    db.add(db_cam)
    db.commit()
    db.refresh(db_cam)
    return db_cam

def update_camera_status(db: Session, ip: str, status: str):
    cam = db.query(Camera).filter(Camera.ip == ip).first()
    if cam:
        cam.status = status
        db.commit()
