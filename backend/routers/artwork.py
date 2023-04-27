from bson import ObjectId
from fastapi import APIRouter

from controllers.artwork_controller import ArtworkController
router = APIRouter()

# get all artworks
@router.get("/artwork", tags=["artwork"])
def get_artworks():
    return ArtworkController.get_artworks()