# mongodb driver
from pymongo import MongoClient
from decouple import config

def get_db():
    CONNECTION_STRING = config("MONGODB_URL")
    client = MongoClient(CONNECTION_STRING)     
    return client['chat_ai']    

# This is added so that many files can reuse the function get_database()
if __name__ == "__main__":   
  
   # Get the database
   dbname = get_db()