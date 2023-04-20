import datetime
import os
import pickle
from bson import ObjectId
from fastapi import HTTPException
from gpt_index import SimpleDirectoryReader
from langchain import OpenAI
from llama_index import ComposableGraph, GPTListIndex, GPTSimpleVectorIndex, LLMPredictor, ServiceContext
from pydantic import BaseModel
from llama_index.indices.query.query_transform.base import DecomposeQueryTransform
from llama_index.langchain_helpers.agents import LlamaToolkit, create_llama_chat_agent, IndexToolConfig, GraphToolConfig
from config.db import get_db

os.environ['OPENAI_API_KEY'] = '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'
DOCUMENTS_DIRECTORY = 'data'
db = get_db()
userModel = db['users']

class ChatController(BaseModel):

    def create_chat_agent(memory):

        doc_set = {}
        all_docs = []
        # loop through files / filenames (file storing api?) in db
        for filename in os.listdir(DOCUMENTS_DIRECTORY):
            f = DOCUMENTS_DIRECTORY+'/'+filename
            document = SimpleDirectoryReader(input_files=[f]).load_data()
            # filename is the key, document itself is the value
            doc_set[filename] = document
            all_docs.extend(document)

        # initialize simple vector indices + global vector index
        service_context = ServiceContext.from_defaults(chunk_size_limit=512)
        index_set = {}
        for filename in os.listdir(DOCUMENTS_DIRECTORY):
            curr_index = GPTSimpleVectorIndex.from_documents(
                doc_set[filename], service_context=service_context)
            index_set[filename] = curr_index
            # curr_index.save_to_disk(f'index_{filename}.json')

        llm_predictor = LLMPredictor(llm=OpenAI(temperature=0, max_tokens=512))
        service_context = ServiceContext.from_defaults(llm_predictor=llm_predictor)

        # define a list index over the vector indices
        # allows us to synthesize information across each index
        graph = ComposableGraph.from_indices(
            GPTListIndex,
            [index_set[f] for f in os.listdir(DOCUMENTS_DIRECTORY)],
            index_summaries=[
                "Some information about an artist" for x in index_set],
            service_context=service_context
        )

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
            description="useful for when user asks about art",
            query_configs=query_configs,
            tool_kwargs={"return_direct": True}
        )

        # define toolkit
        index_configs = []
        for filename in os.listdir(DOCUMENTS_DIRECTORY):
            tool_config = IndexToolConfig(
                index=index_set[filename],
                name=f"Vector Index {filename}",
                description=f"useful for when the user ask about art or artists",
                index_query_kwargs={"similarity_top_k": 3},
                tool_kwargs={"return_direct": True}
            )
            index_configs.append(tool_config)

        toolkit = LlamaToolkit(
            index_configs=index_configs,
            graph_configs=[graph_config]
        )

        llm = OpenAI(temperature=0)

        return create_llama_chat_agent(
            toolkit,
            llm,
            memory=memory,
            verbose=True
        )
    
    def update_previous_messages(userId: str, prompt: str, response: str):
        new_message = {
            "user": prompt,
            "ai": response,
            "timestamp": datetime.datetime.now()
        }

        userModel.update_one({"_id": ObjectId(userId)}, {"$push": {"previousMessages": new_message}})

    @classmethod
    def askAI(cls, prompt: str, id: str):
        try:
            objId = ObjectId(id)
        except:
            raise HTTPException(status_code=400, detail="Not valid id.")

        # load the memory according to the user id
        with open('conv_memory/'+id+'.pickle', 'rb') as handle:
            mem = pickle.load(handle)
        agent_executor = cls.create_chat_agent(mem)

        # for could not parse LLM output
        try:
            response = agent_executor.run(input=prompt)
        except ValueError as e:
            response = str(e)
            if not response.startswith("Could not parse LLM output: `"):
                raise e
            response = response.removeprefix(
                "Could not parse LLM output: `").removesuffix("`")

        # save memory after response
        with open('conv_memory/' + id + '.pickle', 'wb') as handle:
            pickle.dump(mem, handle, protocol=pickle.HIGHEST_PROTOCOL)

        cls.update_previous_messages(id, prompt, response)
        return {"answer": response}
