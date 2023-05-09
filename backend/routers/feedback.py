# import necessary packages
import os
from fastapi import APIRouter
from pydantic import BaseModel
from controllers.feedback_controller import FeedbackController

router = APIRouter()

class FeedbackRequest(BaseModel):
    ai: str
    feedback: str
    opinion: str
    date: str

@router.post("/uploadFeedback")
def upload(feedback_request: FeedbackRequest):
    return FeedbackController.upload(feedback_request.ai,
                                     feedback_request.feedback, 
                                     feedback_request.opinion, 
                                     feedback_request.date)

