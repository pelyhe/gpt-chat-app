# import necessary packages
import os
from fastapi import APIRouter
from controllers.chat_controller import ChatController

# TODO: put api key in env variable
os.environ['OPENAI_API_KEY'] = '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'

router = APIRouter()

@router.get("/ask",  tags=["user", "chat"])
def ask(prompt: str, id: str):
    return ChatController.askAI(prompt=prompt, id=id)

