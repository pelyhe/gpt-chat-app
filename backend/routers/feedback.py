# import necessary packages
import os
from fastapi import APIRouter
from controllers.feedback_controller import FeedbackController

router = APIRouter()

@router.post("/valami")
def upload(type: str, feedbacl: str):
    return FeedbackController.upload()

