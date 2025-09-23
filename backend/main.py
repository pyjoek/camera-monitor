# backend/main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import subprocess
import asyncio

app = FastAPI()

# Allow React frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# List of cameras (IP addresses or hostnames)
cameras = [
    {"id": 1, "name": "Front Gate", "ip": "192.168.1.101", "status": "unknown"},
    {"id": 2, "name": "Lobby", "ip": "192.168.1.102", "status": "unknown"},
    {"id": 3, "name": "Parking Lot", "ip": "192.168.1.103", "status": "unknown"},
]

# Function to ping a camera
def ping_camera(ip: str) -> bool:
    try:
        subprocess.check_output(["ping", "-c", "1", "-W", "1", ip])
        return True
    except subprocess.CalledProcessError:
        return False

# Background task that runs every 5 minutes
async def monitor_cameras():
    while True:
        for cam in cameras:
            cam["status"] = "online" if ping_camera(cam["ip"]) else "offline"
        await asyncio.sleep(300)  # 5 minutes

@app.on_event("startup")
async def startup_event():
    asyncio.create_task(monitor_cameras())

@app.get("/cameras")
def get_cameras():
    return cameras
