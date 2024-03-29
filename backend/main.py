from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import routers.users as users
import routers.chat as chat
import routers.feedback as feedback
import routers.artwork as artwork
import routers.gallery as gallery
import routers.artist as artist

import sys
sys.path.append(".") 
app = FastAPI()

app.include_router(users.router)
app.include_router(chat.router)
app.include_router(feedback.router)
app.include_router(artwork.router)
app.include_router(gallery.router)
app.include_router(artist.router)

origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)