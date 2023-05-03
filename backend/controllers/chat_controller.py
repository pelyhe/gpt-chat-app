import logging
import pickle
from langchain import LLMChain
LOG_FILE_PATH = 'config/log.log'
logging.basicConfig(filename=LOG_FILE_PATH, filemode='a', level=logging.CRITICAL,
                    format='%(asctime)s - %(levelname)s: %(message)s', datefmt='%Y/%m/%d %I:%M:%S %p')
import datetime
import os
from bson import ObjectId
from fastapi import HTTPException
from langchain.llms import OpenAI
from langchain.vectorstores import FAISS
from langchain.embeddings.openai import OpenAIEmbeddings
from pydantic import BaseModel
from config.db import get_db
from langchain.agents import AgentExecutor, Tool, ZeroShotAgent
from langchain.document_loaders import DirectoryLoader
from langchain.text_splitter import CharacterTextSplitter
from langchain.memory import ConversationBufferMemory
from langchain.chains import ConversationalRetrievalChain, RetrievalQA
from langchain.agents import load_tools

os.environ['OPENAI_API_KEY'] = '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'
# os.environ['GOOGLE_API_KEY'] = 'AIzaSyDIJRQfV4SGsCfiqZqcyIRoEo2PZcL22vs'
# os.environ['GOOGLE_CSE_ID'] = '81890bc0c20ea4b7f'
DOCUMENTS_DIRECTORY = 'data/gallery/'

db = get_db()
userModel = db['users']

## THE MODEL, WHICH CAN USE GOOGLE TOOL

class ChatController(BaseModel):

    def create_chat_agent(memory):
        llm = OpenAI(temperature=0, model_name="gpt-3.5-turbo")
        
        # Data Ingestion
        word_loader = DirectoryLoader(DOCUMENTS_DIRECTORY, glob="*.docx")
        documents = []
        documents.extend(word_loader.load())
        # Chunk and Embeddings
        text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
        documents = text_splitter.split_documents(documents)
        embeddings = OpenAIEmbeddings()
        vectorstore = FAISS.from_documents(documents, embeddings)

        # Initialise Langchain - QA chain
        qa = RetrievalQA.from_chain_type(llm=llm, chain_type="stuff", retriever=vectorstore.as_retriever())
        
        #google_search_tool = load_tools(["google-search"])[0]

        tools = [
            Tool(
                name="Glassyard gallery exhibition",
                func=qa.run,
                description="useful for when you need to answer questions about the gallery, the exhibition, art world, or people related to art."
            ),
            #google_search_tool
        ]

        prefix = """Have a conversation with a human, answering the following questions as best you can based on your language model and the context and memory available.
                    You have access to a single tool."""


        suffix = """Begin!
        
        {chat_history}
        Question: {input}
        {agent_scratchpad}"""

        prompt = ZeroShotAgent.create_prompt(
            tools=tools,
            prefix=prefix,
            suffix=suffix,
            input_variables=["input", "chat_history", "agent_scratchpad"]
        )

        llm_chain = LLMChain(llm=llm, prompt=prompt)

        agent = ZeroShotAgent(llm_chain=llm_chain, tools=tools, verbose=True)
        return AgentExecutor.from_agent_and_tools(
            agent=agent, tools=tools, verbose=True, memory=memory
        )

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
            logging.critical('RESPONSE TIME: '+ responseTime +'. Question: '+ prompt)
        else:
            logging.critical('ERROR: ' + errorMessage)


    @classmethod
    def askAI(cls, prompt: str, id: str):
        try:
            objId = ObjectId(id)
        except:
            cls.log_to_file(prompt=prompt, responseTime=0, succeed=False, errorMessage="Not valid id")
            raise HTTPException(status_code=400, detail="Not valid id.")

        if not os.path.isfile('conv_memory/'+id+'.pickle'):
            mem = ConversationBufferMemory(memory_key="chat_history")
            with open('conv_memory/' + id + '.pickle', 'wb') as handle:
                pickle.dump(mem, handle, protocol=pickle.HIGHEST_PROTOCOL)
        else:
            # load the memory according to the user id
            with open('conv_memory/'+id+'.pickle', 'rb') as handle:
                mem = pickle.load(handle)

        qa = cls.create_chat_agent(memory=mem)
        print(qa)
        before_time = datetime.datetime.now()
        # for could not parse LLM output
        try:
            response = qa.run(input=prompt)
        except ValueError as e:
            response = str(e)
            if not response.startswith("Could not parse LLM output: `"):
                cls.log_to_file(prompt, "", succeed=False, errorMessage=str(e))
                raise e
            response = response.removeprefix(
                "Could not parse LLM output: `").removesuffix("`")
        after_time = datetime.datetime.now()
        
        response_time = str(after_time - before_time)

        cls.log_to_file(prompt=prompt, responseTime=response_time, succeed=True)
        # save memory after response
        with open('conv_memory/' + id + '.pickle', 'wb') as handle:
            pickle.dump(mem, handle, protocol=pickle.HIGHEST_PROTOCOL)
        cls.update_previous_messages(userId=id, prompt=prompt, response=response)

        return response

