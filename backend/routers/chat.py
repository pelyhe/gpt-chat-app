# import necessary packages
import os
from fastapi import APIRouter
from controllers.chat_v2_controller import ChatController

router = APIRouter()

@router.get("/ask",  tags=["user", "chat"])
def ask(prompt: str, id: str):
    return ChatController.askAI(prompt=prompt, id=id)

