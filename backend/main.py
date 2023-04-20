from fastapi import FastAPI
import routers.users as users
import routers.chat as chat
import sys
sys.path.append(".") 
app = FastAPI()

app.include_router(users.router)
app.include_router(chat.router)

@app.get("/")
def root():
    return {"message": "Hello API!"}
