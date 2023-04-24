import logging
LOG_FILE_PATH = 'config/categorize.log'
logging.basicConfig(filename=LOG_FILE_PATH, filemode='a', level=logging.CRITICAL,
                    format='%(asctime)s - %(levelname)s: %(message)s', datefmt='%Y/%m/%d %I:%M:%S %p')
import os
import json
from bson import ObjectId
from fastapi import HTTPException
from langchain import OpenAI
from llama_index import GPTSimpleVectorIndex, LLMPredictor, PromptHelper, ServiceContext, SimpleDirectoryReader
from pydantic import BaseModel
from config.db import get_db
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

    @classmethod
    def categorize_user_by_id(cls, id: str):
        objId = ObjectId(id)
        document = userModel.find_one({"_id": objId})        

        artworkTypes = []
        for artworkId in document['favouriteArtworks']:
            artwork = artworkModel.find_one({"_id": artworkId})
            if artwork != None:
                artworkTypes.append(artwork['type'])

        goAuction = bool(document['goAuctions'])
        goArtfairs = bool(document['goArtfairs'])
        hasFavouriteArtists = len(document['favouriteArtists']) != 0

        artworkTypes = list(dict.fromkeys(artworkTypes))
        isInterstedInMultipleArtworkTypes = len(artworkTypes) > 1

        categorize_query = cls.CategorizeQuery(
            goAuctions=goAuction,
            goArtfairs=goArtfairs,
            hasFavouriteArtists=hasFavouriteArtists,
            isInterestedInMultipleArtworkTypes=isInterstedInMultipleArtworkTypes
        )

        response = cls._get_category_by_ai(categorize_query)
        cls._log_category_by_ai(categorize_query, response.response)
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

    def _get_category_by_ai(query: CategorizeQuery):
        llm_predictor = LLMPredictor(llm=OpenAI(
            temperature=0, model_name="gpt-3.5-turbo"))
        service_context = ServiceContext.from_defaults(
            llm_predictor=llm_predictor
        )
        document = SimpleDirectoryReader(
            input_files=["data/categorize_users.txt"]).load_data()   # TODO: constant value here!
        index = GPTSimpleVectorIndex.from_documents(
            document, service_context=service_context)
        
        jsonObject = query.toJSON()
        print(jsonObject)
        return index.query("Please categorize this user according to the document provided in context. You will have a json file parsed to string and you have all the data inside of it from the user. The response should only include one word, the category of the user, according to the document, starting with small letter. The json file is here: " + jsonObject )

    def _log_category_by_ai(query: CategorizeQuery,response: str):
        userCategory = ""
        if query.goAuctions or not query.hasFavouriteArtists:
            userCategory = "investor"
        else:
            if query.isInterestedInMultipleArtworkTypes:
                userCategory = "impulsive"
            else:
                userCategory = "thematic"

        if userCategory == response:
            logging.critical('MATCHING! AI: ' + response + ' | CALCULATED: ' + userCategory)
        else:
            logging.critical('DIFFERENT! AI: ' + response + ' | CALCULATED: ' + userCategory)
