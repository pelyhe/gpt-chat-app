import csv
import logging
from pathlib import Path
from controllers.user_controller import UserController
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
from llama_index import ComposableGraph, GPTListIndex, GPTSimpleVectorIndex, LLMPredictor, ServiceContext, download_loader
from pydantic import BaseModel
from llama_index.indices.query.query_transform.base import DecomposeQueryTransform
from llama_index.langchain_helpers.agents import LlamaToolkit, create_llama_chat_agent, IndexToolConfig, GraphToolConfig
from config.db import get_db

os.environ['OPENAI_API_KEY'] = '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'
DOCUMENTS_DIRECTORY = 'data'
GRAPH_INDEX_FILENAME = '__graph_index__.json'

db = get_db()
userModel = db['users']

## THE MODEL WHICH USES GENERAL GPT KNOWLEDGE, BUT DONT ALWAYS RESPONSE WITH THE RIGHT ANSWER

class ChatController(BaseModel):

    def _create_chat_agent(memory):

        doc_set = {}
        all_docs = []

        # DocxReader = download_loader("DocxReader")
        # CSVReader = download_loader("SimpleCSVReader")
        # loader = DocxReader()
        # csv_loader = CSVReader()
        # # loop through files / filenames (file storing api?) in db
        # for filename in os.listdir(DOCUMENTS_DIRECTORY):
        #     f = DOCUMENTS_DIRECTORY+'/'+filename
        #     if f.endswith('docx'):
        #         document = loader.load_data(file=Path(f))
        #     else:
        #         document = csv_loader.load_data(file=Path(f))
        #     # filename is the key, document itself is the value
        #     doc_set[filename] = document
        #     all_docs.extend(document)

        # # initialize simple vector indices + global vector index
        # service_context = ServiceContext.from_defaults(chunk_size_limit=1000)
        # index_set = {}
        # for filename in os.listdir(DOCUMENTS_DIRECTORY):
        #     curr_index = GPTSimpleVectorIndex.from_documents(
        #         doc_set[filename], service_context=service_context)
        #     index_set[filename] = curr_index
        #     curr_index.save_to_disk(f'indices/index_{filename}.json') 
        
        # Load indices from disk
        index_set = {}
        for filename in os.listdir(DOCUMENTS_DIRECTORY):
            curr_index = GPTSimpleVectorIndex.load_from_disk(f'indices/index_{filename}.json')
            index_set[filename] = curr_index

        llm_predictor = LLMPredictor(llm=OpenAI(temperature=0, model_name="gpt-3.5-turbo", max_tokens=1000))
        # service_context = ServiceContext.from_defaults(
        #     llm_predictor=llm_predictor)

        # define a list index over the vector indices
        # allows us to synthesize information across each index
        # graph = ComposableGraph.from_indices(
        #     GPTListIndex,
        #     [index_set[f] for f in os.listdir(DOCUMENTS_DIRECTORY)],
        #     index_summaries=[
        #         "useful for when you need to answer questions about the gallery, artworks, Sara Dobai, Rober Bresson, Glassyard Gallery, exhibition or any information about people related to art." for x in index_set],
        #     service_context=service_context
        # )

        # graph.save_to_disk(f'indices/'+ GRAPH_INDEX_FILENAME)


        graph = ComposableGraph.load_from_disk(f'indices/'+ GRAPH_INDEX_FILENAME)

        decompose_transform = DecomposeQueryTransform(
            llm_predictor, verbose=True
        )

        # define query configs for graph
        query_configs = [
            {
                "index_struct_type": "simple_dict",
                "query_mode": "default",
                "query_kwargs": {
                    "similarity_top_k": 1,
                    # "include_summary": True
                },
                "query_transform": decompose_transform
            },
            {
                "index_struct_type": "list",
                "query_mode": "default",
                "query_kwargs": {
                    "response_mode": "tree_summarize",
                    "verbose": True
                }
            }
        ]

        # graph config
        graph_config = GraphToolConfig(
            graph=graph,
            name=f"Graph Index",
            description="useful for when you need to answer questions about the gallery, artworks, Sara Dobai, Rober Bresson, Glassyard Gallery, exhibition, user category/type, user classification, any information about the user or people related to art.",
            query_configs=query_configs,
            tool_kwargs={"return_direct": True}
        )

        # define toolkit
        index_configs = []
        gallery_config = IndexToolConfig(
            index=index_set['gallery_model.docx'],
                name=f"Gallery index",
                description=f"useful for when you need to answer questions about the gallery, artworks, photography, videos, Sara Dobai, Rober Bresson, Glassyard Gallery, exhibition, art.",
                index_query_kwargs={"similarity_top_k": 3},
                tool_kwargs={"return_direct": True}
        )

        artwork_data_config = IndexToolConfig(
            index=index_set['artworks-data.csv'],
                name=f"Artwork data index",
                description=f"useful for when you need to answer basic questions about the details of an artwork, like size, price, date of creation, creation technique. Never tell the id of an artwork.",
                index_query_kwargs={"similarity_top_k": 3},
                tool_kwargs={"return_direct": True}
        )

        policy_config = IndexToolConfig(
            index=index_set['policy.docx'],
                name=f"Vector Index User",
                description=f"contraints for recommending auctions, galleries or other sources of artworks",
                index_query_kwargs={"similarity_top_k": 3},
                tool_kwargs={"return_direct": True}
        )

        index_configs.append(gallery_config)
        index_configs.append(artwork_data_config)
        index_configs.append(policy_config)

        toolkit = LlamaToolkit(
            index_configs=index_configs,
            graph_configs=[graph_config]
        )

        llm = OpenAI(temperature=0, model_name="gpt-3.5-turbo")

        return create_llama_chat_agent(
            toolkit,
            llm,
            memory=memory,
            verbose=True
        )

    def _update_previous_messages(userId: str, prompt: str, response: str):
        new_message = {
            "user": prompt,
            "ai": response,
            "timestamp": datetime.datetime.now()
        }

        userModel.update_one({"_id": ObjectId(userId)}, {
                             "$push": {"previousMessages": new_message}})

    def _log_to_file(prompt, responseTime, succeed, errorMessage=None):
        if succeed:
            logging.critical('RESPONSE TIME: '+ responseTime +'. Question: '+ prompt)
        else:
            logging.critical('ERROR: ' + errorMessage)

    # after every 5 questions, update db with user's category
    def _update_user_category(id: str):
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
            elif "lover" in result.lower():
                update = { "$set": { "category": "art-lover" } }
                userModel.update_one(filter, update)
            elif "impulsive" in result.lower():
                update = { "$set": { "category": "impulsive" } }
                userModel.update_one(filter, update)
            elif "thematic" in result.lower():
                update = { "$set": { "category": "thematic" } }
                userModel.update_one(filter, update)


    @classmethod
    def askAI(cls, prompt: str, id: str):
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

        cls._update_user_category(id=objId)
        agent_executor = cls._create_chat_agent(mem)

        # beforeResponseTimestamp = datetime.datetime.now()
        # for could not parse LLM output
        try:
            response = agent_executor.run(input=prompt)
        except ValueError as e:
            response = str(e)
            if not response.startswith("Could not parse LLM output: `"):
                # cls._log_to_file(prompt, responseTime, succeed=False, errorMessage=str(e))
                raise e
            response = response.removeprefix(
                "Could not parse LLM output: `").removesuffix("`")

        # afterResponseTimestamp = datetime.datetime.now()
        # responseTime = afterResponseTimestamp-beforeResponseTimestamp
        # cls._log_to_file(prompt, str(responseTime), succeed=True)

        # save memory after response
        with open('conv_memory/' + id + '.pickle', 'wb') as handle:
            pickle.dump(mem, handle, protocol=pickle.HIGHEST_PROTOCOL)

        cls._update_previous_messages(id, prompt, response)
        return {"answer": response}
