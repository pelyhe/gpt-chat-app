from bson import ObjectId
from fastapi import APIRouter, Request

from controllers.user_controller import UserController
router = APIRouter()

# get all users
@router.get("/user", tags=["user"])
def get_users():
    return UserController.get_users()

# get user by id
@router.get("/user/id/{id}", tags=["user"])
def get_user_by_id(id: str):
    return UserController.get_user_by_id(id)

# get user by username
@router.get("/user/username/{username}", tags=["user"])
def get_user_by_username(username: str):
    return UserController.get_user_by_username(username)

@router.get("/user/{id}/previous-messages")
def get_previous_messages_by_user_id(id):
    return UserController.get_previous_messages_by_user_id(id)

@router.get("/user/categorize", tags=["user", "categorize"])
def categorize_user_by_id(prompt: str):
    return UserController.categorize_user_by_id(prompt).response

# TODO: should use one object instead of these parameters
@router.post("/user/update")
def update_user(id: str, location: str, favArtwork: str, favGallery: str, favArtist: str, auctions: str, fairs: str, vip: str):
    return UserController.update_user(id=id, location = location, favArtwork=favArtwork, favGallery=favGallery, favArtist=favArtist, auctions=auctions, fairs=fairs, vip=vip)
