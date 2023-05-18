# import necessary packages
from fastapi import APIRouter
from fastapi.responses import StreamingResponse
from controllers.chat_controller import ChatController

router = APIRouter()
chat_controller = ChatController()

@router.get("/ask",  tags=["user", "chat"])
async def ask(prompt: str, id: str):
    return await chat_controller.askAI(prompt=prompt, id=id)

