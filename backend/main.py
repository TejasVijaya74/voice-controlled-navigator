import os
import openrouteservice
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from dotenv import load_dotenv  # Import this

# Load variables from .env file
load_dotenv()

app = FastAPI()

# Get the key from the environment
ORS_API_KEY = os.getenv("ORS_API_KEY")

# Initialize Client
if not ORS_API_KEY:
    raise ValueError("ORS_API_KEY not found in .env file")

client = openrouteservice.Client(key=ORS_API_KEY)

class VoiceCommand(BaseModel):
    current_lat: float
    current_lng: float
    voice_destination: str 

@app.post("/navigate")
async def get_navigation_directions(command: VoiceCommand):
    try:
        # --- STEP 1: GEOCODING (Voice -> Coordinates) ---
        # Uses ORS 'Pelias' search to find the place
        geocode_result = client.pelias_search(
            text=command.voice_destination,
            focus_point=[command.current_lng, command.current_lat], # Bias results to user location
            size=1
        )

        if not geocode_result['features']:
            raise HTTPException(status_code=404, detail="Destination not found")

        # ORS returns [Longitude, Latitude]
        dest_coords = geocode_result['features'][0]['geometry']['coordinates']
        dest_name = geocode_result['features'][0]['properties']['label']
        dest_lng, dest_lat = dest_coords[0], dest_coords[1]

        # --- STEP 2: ROUTING (Turn-by-Turn) ---
        # 'foot-walking' profile is optimized for pedestrians (sidewalks, paths)
        route = client.directions(
            coordinates=[[command.current_lng, command.current_lat], [dest_lng, dest_lat]],
            profile='foot-walking',
            format='geojson',
            instructions=True
        )

        if not route['features']:
            raise HTTPException(status_code=404, detail="No route found")

        # --- STEP 3: PARSING (Format for Flutter) ---
        # ORS separates geometry (path) from steps (instructions)
        feature = route['features'][0]
        properties = feature['properties']
        geometry_points = feature['geometry']['coordinates'] # List of all [lng, lat] points on path
        
        steps = []
        segment = properties['segments'][0]
        
        for step in segment['steps']:
            # 'way_points' are indices in the geometry_points list
            start_idx = step['way_points'][0]
            end_idx = step['way_points'][1]
            
            # Convert [Lng, Lat] -> [Lat, Lng] for Flutter
            start_loc = {"lat": geometry_points[start_idx][1], "lng": geometry_points[start_idx][0]}
            end_loc = {"lat": geometry_points[end_idx][1], "lng": geometry_points[end_idx][0]}

            steps.append({
                "instruction": step['instruction'], # Already plain text (no HTML)
                "distance_meters": step['distance'],
                "maneuver": step.get('type', 0), # integer code for turn type (1=right, 0=straight, etc)
                "start_location": start_loc,
                "end_location": end_loc
            })

        return {
            "destination": dest_name,
            "total_distance": f"{properties['summary']['distance']} meters",
            "total_duration": f"{properties['summary']['duration'] / 60:.1f} mins",
            "navigation_steps": steps
        }

    except Exception as e:
        print(f"Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))
