from config.db import get_db
from pydantic import BaseModel
from llama_index import GPTVectorStoreIndex, LLMPredictor, download_loader, ServiceContext
from langchain import OpenAI
from fastapi import HTTPException
from bson import ObjectId
import json
import os
import logging

from pathlib import Path
LOG_FILE_PATH = 'config/log.log'
logging.basicConfig(filename=LOG_FILE_PATH, filemode='a', level=logging.CRITICAL,
                    format='%(asctime)s - %(levelname)s: %(message)s', datefmt='%Y/%m/%d %I:%M:%S %p')
USER_CATEGORY_DIRECTORY = 'data/user_categorize.docx'
db = get_db()
userModel = db['users']
artworkModel = db['artworks']
artistModel = db['artists']
galleryModel = db['gallery']
os.environ['OPENAI_API_KEY'] = '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'


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
            raise HTTPException(
                status_code=400, detail="Not a valid user or previous messages no previous messages array.")

    # TODO: update str to lists of objectIds
    # TODO: use this: auc = auctions == 'true'
    def update_user(id: str, location: str, favArtwork: str, favGallery: str, favArtist: str, auctions: str, fairs: str, vip: str):
        auc = False
        fair = False
        isVip = False
        if (auctions == 'true'):
            auc = True
        if (fairs == 'true'):
            fair = True
        if (vip == 'true'):
            isVip = True
        userModel.update_one({"_id": ObjectId(id)}, {
            "$push": {"favouriteArtists": favArtist, "favouriteGalleries": favGallery, "favouriteArtworks": favArtwork},
            "$set": {"isVip": isVip, "location": location, "goAuctions": fair, "goArtfairs": auc},
        })

    @classmethod
    def categorize_user_by_id(cls, previousPrompts: str):

        response = cls._get_category_by_ai(previousPrompts)
        return response

    ### helper functions start here ###

    class CategorizeQuery:

        def __init__(
                self, goAuctions: bool, goArtfairs: bool, hasFavouriteArtists: bool, isInterestedInMultipleArtworkTypes: bool):
            self.goAuctions = goAuctions
            self.goArtfairs = goArtfairs
            self.hasFavouriteArtists = hasFavouriteArtists
            self.isInterestedInMultipleArtworkTypes = isInterestedInMultipleArtworkTypes

        def toJSON(self):
            return json.dumps(self, default=lambda o: o.__dict__, sort_keys=True, indent=4)

    def _get_category_by_ai(prompt: str):
        llm_predictor = LLMPredictor(llm=OpenAI(
            temperature=0, model_name="gpt-3.5-turbo"))
        service_context = ServiceContext.from_defaults(
            llm_predictor=llm_predictor
        )
        DocxReader = download_loader("DocxReader")
        loader = DocxReader()
        f = USER_CATEGORY_DIRECTORY
        document = loader.load_data(file=Path(f))
        index = GPTVectorStoreIndex.from_documents(
            document, service_context=service_context)

        # jsonObject = query.toJSON()
        # print(jsonObject)
        query_engine = index.as_query_engine()
        return query_engine.query("Please categorize this user by its previous questions. The response should only include one or two word, the category of the user, according to the context, starting with small letter. Each question is seperated with a '|'. The user's previous questions starts here: " + prompt)

    def _log_category_by_ai(query: CategorizeQuery, response: str):
        userCategory = ""
        if query.goAuctions or not query.hasFavouriteArtists:
            userCategory = "investor"
        else:
            if query.isInterestedInMultipleArtworkTypes:
                userCategory = "impulsive"
            else:
                userCategory = "thematic"

        if userCategory == response:
            logging.critical('MATCHING! AI: ' + response +
                             ' | CALCULATED: ' + userCategory)
        else:
            logging.critical('DIFFERENT! AI: ' + response +
                             ' | CALCULATED: ' + userCategory)
