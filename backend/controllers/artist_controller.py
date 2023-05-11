from bson import ObjectId
from fastapi import HTTPException
from pydantic import BaseModel
from config.db import get_db
db = get_db()
artistModel = db['artists']

class ArtistController(BaseModel):
    
    # get all artists
    def get_artists():
        artists = artistModel.find()
        artists_list = list(artists)
        for artist in artists_list:
            artist['_id'] = str(artist['_id'])
        return artists_list