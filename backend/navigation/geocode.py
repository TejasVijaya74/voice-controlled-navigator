import openrouteservice
import os
from dotenv import load_dotenv

load_dotenv()
client = openrouteservice.Client(key=os.getenv("ORS_API_KEY"))

def geocode(query):
    # Returns [longitude, latitude]
    result = client.pelias_search(text=query, size=1)
    if result['features']:
        coords = result['features'][0]['geometry']['coordinates']
        return {"lng": coords[0], "lat": coords[1], "name": result['features'][0]['properties']['label']}
    return None
