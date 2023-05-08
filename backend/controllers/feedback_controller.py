from bson import ObjectId
from fastapi import HTTPException, Request, Body
from pydantic import BaseModel
from config.db import get_db
db = get_db()
feedbackModel = db['feedbacks']

class FeedbackController(BaseModel):
        
    def upload(type: str, feedback: str):
        feedback_data = {
            '_id': ObjectId(id),
            'type': type,
            'feedback': feedback
        }
        feedbackModel.insert_one(feedback_data)