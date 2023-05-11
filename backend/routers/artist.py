from bson import ObjectId
from fastapi import APIRouter

from controllers.artist_controller import ArtistController
router = APIRouter()

# get all artist
@router.get("/artist", tags=["artist"])
def get_artist():
    return ArtistController.get_artists()