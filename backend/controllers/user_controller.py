from bson import ObjectId
from fastapi import HTTPException, Request, Body
from pydantic import BaseModel
from config.db import get_db
db = get_db()
userModel = db['users']

class UserController(BaseModel):
    
    # get all users
    def get_users():
        users = userModel.find()
        users_list = list(users)
        for user in users_list:
            user['_id'] = str(user['_id'])
        return users_list
    
    # get user by id
    def get_user_by_id(id: str):
        objId = ObjectId(id)
        document = userModel.find_one({"_id": objId})
        document['_id'] = str(document['_id'])
        return document
    
    # get user by username
    def get_user_by_username(username: str):    
        document = userModel.find_one({"username": username})
        document['_id'] = str(document['_id'])
        return document
    
    def get_previous_messages_by_user_id(id: str):
        document = userModel.find_one({"_id": ObjectId(id)})
        if document and "previousMessages" in document:
            previous_messages = document["previousMessages"]
            return previous_messages
        else:
            raise HTTPException(status_code=400, detail="Not a valid user or previous messages no previous messages array.")
        
    def update_user(id: str, location: str, favArtwork: str, favGallery: str, favArtist: str, auctions: str, fairs: str, vip: str):
        auc = False
        fair = False
        isVip = False
        if(auctions == 'true'):
            auc = True
        if(fairs == 'true'):
            fair = True
        if(vip == 'true'):
            isVip = True
        #Todo update so only not empty strings are uploaded
        userModel.update_one({"_id": ObjectId(id)}, {
                                "$push": {"favouriteArtists": favArtist, "favouriteGalleries": favGallery,"favouriteArtworks": favArtwork}, #---
                                "$set" : {"isVip": isVip,"location": location,"goAuctions": fair,"goArtfairs": auc}, #---
                             }
                            )