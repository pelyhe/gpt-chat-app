import logging
from pathlib import Path
from controllers.user_controller import UserController
from langchain.prompts import ChatPromptTemplate, SystemMessagePromptTemplate, HumanMessagePromptTemplate
LOG_FILE_PATH = 'config/requests.log'
logging.basicConfig(filename=LOG_FILE_PATH, filemode='a', level=logging.CRITICAL,
                    format='%(asctime)s - %(levelname)s: %(message)s', datefmt='%Y/%m/%d %I:%M:%S %p')
import datetime
import os
import pickle
from bson import ObjectId
from fastapi import HTTPException
from langchain import OpenAI
from langchain.memory import ConversationBufferMemory
from llama_index import LLMPredictor, ServiceContext, download_loader, GPTVectorStoreIndex
from llama_index.langchain_helpers.agents import LlamaToolkit, create_llama_chat_agent, IndexToolConfig
from config.db import get_db

os.environ['OPENAI_API_KEY'] = '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'
DOCUMENTS_DIRECTORY = 'data'

db = get_db()
userModel = db['users']

## THE MODEL WHICH USES GENERAL GPT KNOWLEDGE, BUT DONT ALWAYS RESPONSE WITH THE RIGHT ANSWER

class ChatController(object):
    def __init__(self):
        self._create_chat_agent()
        # self.callback_handler = AsyncIteratorCallbackHandler()

    def _create_chat_agent(self):

        doc_set = {}
        all_docs = []

        DocxReader = download_loader("DocxReader")
        loader = DocxReader()
        # loop through files / filenames (file storing api?) in db
        for filename in os.listdir(DOCUMENTS_DIRECTORY):
            f = DOCUMENTS_DIRECTORY+'/'+filename
            document = loader.load_data(file=Path(f))
            # filename is the key, document itself is the value
            doc_set[filename] = document
            all_docs.extend(document)

        # # initialize simple vector indices + global vector index
        service_context = ServiceContext.from_defaults(chunk_size_limit=768)
        index_set = {}
        for filename in os.listdir(DOCUMENTS_DIRECTORY):
            curr_index = GPTVectorStoreIndex.from_documents(
                doc_set[filename], service_context=service_context)
            index_set[filename] = curr_index

        llm_predictor = LLMPredictor(llm=OpenAI(temperature=0, model_name="gpt-4", max_tokens=1024))
        service_context = ServiceContext.from_defaults(
            llm_predictor=llm_predictor)

        # define toolkit
        index_configs = []
        gallery_config = IndexToolConfig(
            query_engine=index_set["gallery_model.docx"].as_query_engine(),
            index=index_set['gallery_model.docx'],
            name=f"Gallery index",
            description=f"useful for when you need to answer questions about the gallery, artworks, photography, videos, Sara Dobai, Rober Bresson, Glassyard Gallery, exhibition, art.",
            index_query_kwargs={"similarity_top_k": 3},
            tool_kwargs={"return_direct": True}
        )

        policy_config = IndexToolConfig(
            query_engine=index_set["policy.docx"].as_query_engine(),
            index=index_set['policy.docx'],
            name=f"Vector Index Policy",
            description=f"contraints for recommending auctions, galleries or other sources of artworks",
            index_query_kwargs={"similarity_top_k": 3},
            tool_kwargs={"return_direct": True}
        )

        conversation_control_config = IndexToolConfig(
            query_engine=index_set["conversation-control.docx"].as_query_engine(),
            index=index_set['conversation-control.docx'],
            name=f"Vector Index Conversation Control",
            description=f"useful for when you want to control the conversation based on the user is a thematic, impulsive, investor or art lover user",
            index_query_kwargs={"similarity_top_k": 3},
            tool_kwargs={"return_direct": True}
        )

        index_configs.append(gallery_config)
        index_configs.append(policy_config)
        index_configs.append(conversation_control_config)

        toolkit = LlamaToolkit(index_configs=index_configs)

        llm = OpenAI(temperature=0, model_name="gpt-4", top_p=0.2, presence_penalty=0.4, frequency_penalty=0.2)

        self.agent = create_llama_chat_agent(
            toolkit,
            llm,
            memory=ConversationBufferMemory(),
            verbose=False
        )

    def _update_previous_messages(self, userId: str, prompt: str, response: str):
        new_message = {
            "user": prompt,
            "ai": response,
            "timestamp": datetime.datetime.now()
        }

        userModel.update_one({"_id": ObjectId(userId)}, {
                             "$push": {"previousMessages": new_message}})

    def _log_to_file(self, prompt, response, responseTime, succeed, errorMessage=None):
        if succeed:
            logging.critical('RESPONSE TIME: '+ responseTime +'. Question: '+ prompt + ' Answer: ' + response)
        else:
            logging.critical('ERROR: ' + errorMessage)

    # after every 5 questions, update db with user's category
    def _update_user_category(self, id: str):
        document = userModel.find_one({"_id": id})
        previousMessages = document['previousMessages']
        if len(previousMessages) % 5 == 0 and len(previousMessages) != 0:
            lastMessages = previousMessages[-5:]
            lastQuestions = lastMessages[0]['user']
            lastMessages.pop(0)
            for conv in lastMessages:
                lastQuestions = lastQuestions + " | " + conv['user']
            result = UserController.categorize_user_by_id(lastQuestions)
            result = str(result)
            
            filter = { "_id": id }
            
            if "investor" in result.lower():
                update = { "$set": { "category": "investor" } }
                userModel.update_one(filter, update)
                return 'investor'
            elif "lover" in result.lower():
                update = { "$set": { "category": "art-lover" } }
                userModel.update_one(filter, update)
                return 'art lover'
            elif "impulsive" in result.lower():
                update = { "$set": { "category": "impulsive" } }
                userModel.update_one(filter, update)
                return 'impulsive'
            elif "thematic" in result.lower():
                update = { "$set": { "category": "thematic" } }
                userModel.update_one(filter, update)
                return 'thematic'
            
        elif document['category'] is not None:
            return document['category']
        else:
            return None

    async def askAI(self, prompt: str, id: str):
        try:
            objId = ObjectId(id)
        except:
            raise HTTPException(status_code=400, detail="Not valid id.")

        if not os.path.isfile('conv_memory/'+id+'.pickle'):
            mem = ConversationBufferMemory(memory_key="chat_history")
            with open('conv_memory/' + id + '.pickle', 'wb') as handle:
                pickle.dump(mem, handle, protocol=pickle.HIGHEST_PROTOCOL)
        else:
            # load the memory according to the user id
            with open('conv_memory/'+id+'.pickle', 'rb') as handle:
                mem = pickle.load(handle)

        self.agent.memory = mem
        
        category = self._update_user_category(id=objId)
        
        sys_msg_text = "You are a gallerist in the Glassyard Gallery's exhibition. Feel free to ask from the me."

        if category:
            sys_msg_text += " Respond me like I am a(n) " + category + " user!"
        
        system_message = SystemMessagePromptTemplate.from_template(sys_msg_text)
        user_message = HumanMessagePromptTemplate.from_template("{input}")

        chat_prompt = ChatPromptTemplate.from_messages([system_message, user_message])
        formatted_msg = chat_prompt.format_messages(input=prompt, intermediate_steps=[])
        prompt_str = "".join([message.content for message in formatted_msg])

        beforeResponseTimestamp = datetime.datetime.now()
        # for could not parse LLM output
        try:
            response = await self.agent.arun(input=prompt_str)
        except Exception as e:
            response = str(e)
            if not response.startswith("Could not parse LLM output: `"):
                self._log_to_file(prompt, responseTime, succeed=False, errorMessage=str(e))
                raise e
            response = response.removeprefix(
                "Could not parse LLM output: `").removesuffix("`")

        afterResponseTimestamp = datetime.datetime.now()
        responseTime = afterResponseTimestamp-beforeResponseTimestamp
        self._log_to_file(prompt, response, str(responseTime), succeed=True)

        # save memory after response
        with open('conv_memory/' + id + '.pickle', 'wb') as handle:
            pickle.dump(mem, handle, protocol=pickle.HIGHEST_PROTOCOL)

        self._update_previous_messages(id, prompt, response)
        return {"answer": response}