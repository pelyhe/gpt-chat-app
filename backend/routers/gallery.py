from bson import ObjectId
from fastapi import APIRouter

from controllers.gallery_controller import GalleryController
router = APIRouter()

# get all galleries
@router.get("/gallery", tags=["gallery"])
def get_galleries():
    return GalleryController.get_galleries()