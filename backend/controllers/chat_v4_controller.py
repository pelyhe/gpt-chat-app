from langchain.agents import load_tools
from langchain.chains import ConversationalRetrievalChain, RetrievalQA
from langchain.memory import ConversationBufferMemory
from langchain.text_splitter import CharacterTextSplitter
from langchain.document_loaders import DirectoryLoader
from langchain.agents import AgentExecutor, Tool, ZeroShotAgent
from config.db import get_db
from pydantic import BaseModel
from langchain.embeddings.openai import OpenAIEmbeddings
from langchain.vectorstores import FAISS
from langchain.chat_models import ChatOpenAI
from fastapi import HTTPException
from bson import ObjectId
import os
import datetime
import logging
import pickle
from langchain import LLMChain
LOG_FILE_PATH = 'config/log.log'
logging.basicConfig(filename=LOG_FILE_PATH, filemode='a', level=logging.CRITICAL,
                    format='%(asctime)s - %(levelname)s: %(message)s', datefmt='%Y/%m/%d %I:%M:%S %p')

os.environ['OPENAI_API_KEY'] = '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'
DOCUMENTS_DIRECTORY = 'data/gallery/'

db = get_db()
userModel = db['users']

# THE MODEL WITH ONE BIG MEMORY


def _init_chat_agent():
    llm = ChatOpenAI(temperature=0, model_name="gpt-3.5-turbo")

    # Data Ingestion
    word_loader = DirectoryLoader(DOCUMENTS_DIRECTORY, glob="*.docx")
    documents = []
    documents.extend(word_loader.load())
    # Chunk and Embeddings
    text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
    documents = text_splitter.split_documents(documents)
    embeddings = OpenAIEmbeddings()
    vectorstore = FAISS.from_documents(documents, embeddings)

    # Initialise Langchain - Conversation Retrieval Chain
    return ConversationalRetrievalChain.from_llm(llm, vectorstore.as_retriever())


qa = _init_chat_agent()


class ChatController(BaseModel):

    def update_previous_messages(userId: str, prompt: str, response: str):
        new_message = {
            "user": prompt,
            "ai": response,
            "timestamp": datetime.datetime.now()
        }

        userModel.update_one({"_id": ObjectId(userId)}, {
                             "$push": {"previousMessages": new_message}})

    def log_to_file(prompt, responseTime, succeed, errorMessage=None):
        if succeed:
            logging.critical('RESPONSE TIME: ' +
                             responseTime + '. Question: ' + prompt)
        else:
            logging.critical('ERROR: ' + errorMessage)

    @classmethod
    def askAI(cls, prompt: str, id: str):
        try:
            objId = ObjectId(id)
        except:
            cls.log_to_file(prompt=prompt, responseTime=0,
                            succeed=False, errorMessage="Not valid id")
            raise HTTPException(status_code=400, detail="Not valid id.")

        before_time = datetime.datetime.now()

        # for could not parse LLM output

        response = qa({"question": id+ " says: " +prompt, "chat_history": []})
        after_time = datetime.datetime.now()
        print(response)
        response_time = str(after_time - before_time)
        cls.log_to_file(
            prompt=prompt, responseTime=response_time, succeed=True)

        cls.update_previous_messages(
            userId=id, prompt=prompt, response=response)

        return response
