from bson import ObjectId
from fastapi import HTTPException
from pydantic import BaseModel
from config.db import get_db
db = get_db()
galleryModel = db['galleries']

class GalleryController(BaseModel):
    
    # get all galleries
    def get_galleries():
        galleries = galleryModel.find()
        galleries_list = list(galleries)
        for gallery in galleries_list:
            gallery['_id'] = str(gallery['_id'])
        return galleries_list