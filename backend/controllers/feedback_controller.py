from bson import ObjectId
from fastapi import HTTPException, Request, Body
from pydantic import BaseModel
from config.db import get_db
db = get_db()
feedbackModel = db['feedbacks']

class FeedbackController(BaseModel):
        
    def upload(ai: str, feedback: str, opinion: str, date: str):
        feedback_data = {
            'ai': ai,
            'feedback': feedback,
            'opinion': opinion,
            'date': date
        }
        feedbackModel.insert_one(feedback_data)