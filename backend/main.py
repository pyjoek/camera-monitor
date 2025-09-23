# backend/main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import subprocess
import asyncio

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Example NVRs and cameras
nvrs = [
    {
        "id": 1,
        "name": "NVR Front Building",
        "cameras": [
            {"id": 101, "name": "Gate", "ip": "192.168.1.101", "status": "unknown"},
            {"id": 102, "name": "Lobby", "ip": "192.168.1.102", "status": "unknown"},
        ],
    },
    {
        "id": 2,
        "name": "NVR Parking Lot",
        "cameras": [
            {"id": 201, "name": "Parking Entrance", "ip": "192.168.1.103", "status": "unknown"},
            {"id": 202, "name": "Back Gate", "ip": "192.168.1.104", "status": "unknown"},
        ],
    },
]

def ping_camera(ip: str) -> bool:
    try:
        subprocess.check_output(["ping", "-c", "1", "-W", "1", ip])
        return True
    except subprocess.CalledProcessError:
        return False

async def monitor_cameras():
    while True:
        for nvr in nvrs:
            for cam in nvr["cameras"]:
                cam["status"] = "online" if ping_camera(cam["ip"]) else "offline"
        await asyncio.sleep(300)  # 5 minutes

@app.on_event("startup")
async def startup_event():
    asyncio.create_task(monitor_cameras())

@app.get("/nvrs")
def get_nvrs():
    return nvrs

@app.post("/nvrs/{nvr_id}/cameras")
def add_camera(nvr_id: int, cam: dict):
    for nvr in nvrs:
        if nvr["id"] == nvr_id:
            cam["id"] = max([c["id"] for c in nvr["cameras"]], default=0) + 1
            cam["status"] = "unknown"
            nvr["cameras"].append(cam)
            return {"message": "Camera added", "camera": cam}
    return {"error": "NVR not found"}
