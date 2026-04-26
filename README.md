# Voice Controlled Navigator

A voice-enabled smart navigation system built with **FastAPI (Backend)** and **Flutter (Frontend)**, integrated with **OpenRouteService** for routing and **YOLOv8** for real-time obstacle detection.

## Features

- Voice-based destination input
- Geocoding (destination → coordinates)
- Turn-by-turn pedestrian navigation
- Real-time obstacle detection using YOLOv8
- Text-to-Speech navigation guidance
- Flutter mobile frontend
- FastAPI backend APIs

---

## Project Structure

```bash
voice-controlled-navigator/
│
├── backend/
│   ├── navigation/
│   │   ├── __init__.py
│   │   ├── geocode.py
│   │   └── route.py
│   ├── main.py
│   ├── requirements.txt
│   ├── .env
│   └── yolov8m.pt
│
└── frontend/
    ├── lib/
    ├── assets/
    ├── pubspec.yaml
    └── ...

```

### Backend Setup (FastAPI)
1) Navigate to backend
``` bash
cd backend
```
2) Create virtual environment
``` bash
python -m venv .venv
```
3) Activate environment
- Windows (PowerShell)
```bash
.\.venv\Scripts\Activate
```
- Linux / macOS
``` bash
source .venv/bin/activate
```
4) Install dependencies
``` bash
pip install -r requirements.txt
```
5) Create .env

- Create a .env file inside backend/
``` bash
ORS_API_KEY=your_openrouteservice_api_key
```

- Get your API key from:

- https://openrouteservice.org/dev/

6) Run backend server
``` bash
uvicorn main:app --reload
```
- Backend runs at:
``` bash
http://127.0.0.1:8000
```

- Swagger Docs:
``` bash
http://127.0.0.1:8000/docs
```

### Frontend Setup (Flutter)

1) Navigate to frontend
```
cd frontend
```
2) Install packages
```
flutter pub get
```
3) Run app
```
flutter run
```
### API Endpoints

#### Geocode Destination

##### POST
```
/navigation/geocode
```
Request:
```
{
  "destination": "MG Road Bangalore"
}
```
Response:
```
{
  "lat": 12.9756,
  "lng": 77.6050
}
```
#### Route Navigation

##### POST
```
/navigation/route
```
Request:
```
{
  "current_lat": 12.9716,
  "current_lng": 77.5946,
  "voice_destination": "MG Road Bangalore"
}
```
Response:
```
{
  "destination": "MG Road",
  "total_distance": "1200 meters",
  "total_duration": "15 mins",
  "navigation_steps": [...]
}
```
#### Obstacle Detection

##### POST
```
/detect
```
Uploads camera frame and returns detected obstacles.
