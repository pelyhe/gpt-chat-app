from bson import ObjectId
from fastapi import HTTPException
from pydantic import BaseModel
from config.db import get_db
db = get_db()
artworkModel = db['artworks']

class ArtworkController(BaseModel):
    
    # get all artworks
    def get_artworks():
        artworks = artworkModel.find()
        artworks_list = list(artworks)
        for artwork in artworks_list:
            artwork['_id'] = str(artwork['_id'])
        return artworks_list