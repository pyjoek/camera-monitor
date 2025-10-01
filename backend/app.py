from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_cors import CORS
from apscheduler.schedulers.background import BackgroundScheduler
import subprocess
import atexit


app = Flask(__name__)
CORS(app)

# MySQL configuration
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+mysqlconnector://root:@localhost/nvr_db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Initialize the database
db = SQLAlchemy(app)
migrate = Migrate(app, db)

# ----------------------
# Models
# ----------------------


def ping_all_cameras():
    print("Pinging all cameras...")
    cameras = Camera.query.all()
    for camera in cameras:
        is_online = ping_camera(camera.ip)
        camera.status = "online" if is_online else "offline"
    db.session.commit()
    print("Camera statuses updated.")

# ----------------------
# Scheduler Setup
# ----------------------
scheduler = BackgroundScheduler()
scheduler.add_job(func=ping_all_cameras, trigger="interval", seconds=60)
scheduler.start()

# Shutdown scheduler on app exit
atexit.register(lambda: scheduler.shutdown())

class NVR(db.Model):
    __tablename__ = 'nvrs'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255), nullable=False)
    cameras = db.relationship('Camera', backref='nvr', lazy=True)

    def __init__(self, name):
        self.name = name

    def __repr__(self):
        return f"<NVR {self.name}>"


class Camera(db.Model):
    __tablename__ = 'cameras'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255), nullable=False)
    ip = db.Column(db.String(255), unique=True, nullable=False)
    status = db.Column(db.String(50), default="unknown")

    nvr_id = db.Column(db.Integer, db.ForeignKey('nvrs.id'), nullable=False)

    def __init__(self, name, ip, status, nvr_id):
        self.name = name
        self.ip = ip
        self.status = status
        self.nvr_id = nvr_id

    def __repr__(self):
        return f"<Camera {self.name} ({self.status})>"

# ----------------------
# Helper Functions
# ----------------------

def ping_camera(ip: str) -> bool:
    """ Ping a camera IP to check if it's online """
    try:
        subprocess.check_output(["ping", "-c", "1", "-W", "1", ip])
        return True
    except subprocess.CalledProcessError:
        return False


# ----------------------
# Routes (Endpoints)
# ----------------------

@app.route('/', methods=['GET'])
def get_nvrs():
    ping_all_cameras()

    nvrs = NVR.query.all()
    if not nvrs:
        return jsonify([])

    response = []
    for nvr in nvrs:
        cameras = [
            {
                'id': cam.id,
                'name': cam.name,
                'ip': cam.ip,
                'status': cam.status
            }
            for cam in nvr.cameras
        ]

        response.append({
            'id': nvr.id,
            'name': nvr.name,
            'cameras': cameras
        })

    return jsonify(response)



@app.route('/new/nvr', methods=['POST'])
def create_nvr():
    """ Create a new NVR """
    data = request.get_json()
    nvr_name = data.get('name')

    if not nvr_name:
        return jsonify({"error": "NVR name is required"}), 400

    new_nvr = NVR(name=nvr_name)
    db.session.add(new_nvr)
    db.session.commit()

    return jsonify({"message": "NVR created", "nvr": {"id": new_nvr.id, "name": new_nvr.name}})

@app.route('/nvrs/<nvr_id>/cameras', methods=['POST'])
def add_camera(nvr_id):
    """ Add a new camera to an NVR """
    # Check if IP already exists
    data = request.get_json()
    camera_name = data.get('name')
    camera_ip = data.get('ip')
    existing_camera = Camera.query.filter_by(ip=camera_ip).first()
    if existing_camera:
        return jsonify({"error": "Camera with this IP already exists"}), 400
    
    # nvr_id = data.get('nvr_id')

    if not camera_name or not camera_ip or not nvr_id:
        return jsonify({"error": "Camera name, IP and NVR are required"}), 400

    # Check if NVR exists
    nvr = NVR.query.get(nvr_id)
    if not nvr:
        return jsonify({"error": "NVR not found"}), 404

    new_camera = Camera(name=camera_name, ip=camera_ip, status="unknown", nvr_id=nvr_id)
    db.session.add(new_camera)
    db.session.commit()

    return jsonify({"message": "Camera added", "camera": {"id": new_camera.id, "name": new_camera.name, "ip": new_camera.ip, "status": new_camera.status}})


@app.route('/nvrs/<int:nvr_id>/camera', methods=['GET'])
def get_cameras(nvr_id):
    """ Get all cameras for a specific NVR """
    nvr = NVR.query.get(nvr_id)
    if not nvr:
        return jsonify({"error": "NVR not found"}), 404

    cameras = [{'id': cam.id, 'name': cam.name, 'ip': cam.ip, 'status': cam.status} for cam in nvr.cameras]
    return jsonify(cameras)

# ----------------------
# Run Flask App
# ----------------------

if __name__ == '__main__':
    app.run(debug=True)
