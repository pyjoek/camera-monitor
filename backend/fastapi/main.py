from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
import subprocess
import asyncio

from database import SessionLocal, engine
import models, schemas, crud

models.Base.metadata.create_all(bind=engine)

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

def get_db():
    db = SessionLocal()
    try:
        return db
    finally:
        db.close()

def ping_camera(ip: str) -> bool:
    try:
        subprocess.check_output(["ping", "-c", "1", "-W", "1", ip])
        return True
    except subprocess.CalledProcessError:
        return False

async def monitor_cameras():
    while True:
        db = SessionLocal()
        try:
            cameras = db.query(models.Camera).all()
            for cam in cameras:
                status = "online" if ping_camera(cam.ip) else "offline"
                crud.update_camera_status(db, cam.ip, status)
        finally:
            db.close()
        await asyncio.sleep(180)

@app.on_event("startup")
async def startup_event():
    asyncio.create_task(monitor_cameras())

@app.get("/nvrs", response_model=list[schemas.NVR])
def list_nvrs(db: Session = Depends(get_db)):
    return crud.get_nvrs(db)

@app.post("/nvrs", response_model=schemas.NVR)
def create_nvr(nvr: schemas.NVRCreate, db: Session = Depends(get_db)):
    return crud.create_nvr(db, nvr)

@app.post("/nvrs/{nvr_id}/cameras", response_model=schemas.Camera)
def add_camera(nvr_id: int, cam: schemas.CameraCreate, db: Session = Depends(get_db)):
    db_cam = crud.add_camera_to_nvr(db, nvr_id, cam)
    if db_cam is None:
        raise HTTPException(status_code=404, detail="NVR not found")
    return db_cam
