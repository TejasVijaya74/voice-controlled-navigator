import openrouteservice
import os
from dotenv import load_dotenv

load_dotenv()
client = openrouteservice.Client(key=os.getenv("ORS_API_KEY"))

def get_route(from_lat, from_lng, to_lat, to_lng):
    # ORS expects [[lng, lat], [lng, lat]]
    coords = [[from_lng, from_lat], [to_lng, to_lat]]
    
    route = client.directions(
        coordinates=coords,
        profile='foot-walking',
        format='geojson',
        instructions=True
    )
    
    # Extract only what the Flutter app needs
    segments = route['features'][0]['properties']['segments'][0]
    geometry = route['features'][0]['geometry']['coordinates']
    
    steps = []
    for step in segments['steps']:
        # Map waypoints to actual coordinates for the Flutter "Live Loop"
        end_pt = geometry[step['way_points'][1]]
        steps.append({
            "instruction": step['instruction'],
            "distance": step['distance'],
            "end_lat": end_pt[1],
            "end_lng": end_pt[0]
        })
        
    return {
        "total_distance": segments['distance'],
        "steps": steps
    }
