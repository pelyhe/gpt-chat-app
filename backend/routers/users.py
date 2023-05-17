from bson import ObjectId
from fastapi import APIRouter, Request
from pydantic import BaseModel
from typing import List
from models.user import User
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

@router.post("/user/update")
async def update_user(user: User):
    return UserController.update_user(user)