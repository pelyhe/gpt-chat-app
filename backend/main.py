# import necessary packages
import os
import pickle
from langchain import OpenAI
from langchain.agents import Tool
from langchain.chains.conversation.memory import ConversationBufferMemory
from langchain.chat_models import ChatOpenAI
from langchain.agents import initialize_agent
from llama_index.langchain_helpers.agents import LlamaToolkit, create_llama_chat_agent, IndexToolConfig, GraphToolConfig
from llama_index.indices.query.query_transform.base import DecomposeQueryTransform
from llama_index.indices.composability import ComposableGraph
from llama_index import GPTSimpleVectorIndex, GPTListIndex, SimpleDirectoryReader, ServiceContext, LLMPredictor
from flask import Flask, request, jsonify

# TODO: put api key in env variable
os.environ['OPENAI_API_KEY'] = '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'

def init_data():
    
    doc_set = {}
    all_docs = []
    # loop through files / filenames (file storing api?) in db
    for filename in os.listdir('data'):
        f = "data/"+filename
        document = SimpleDirectoryReader(input_files=[f]).load_data()
        doc_set[filename] = document    # filename is the key, document itself is the value
        all_docs.extend(document)

    # initialize simple vector indices + global vector index
    service_context = ServiceContext.from_defaults(chunk_size_limit=512)    
    index_set = {}
    for filename in os.listdir('data'):
        curr_index = GPTSimpleVectorIndex.from_documents(doc_set[filename], service_context=service_context)
        index_set[filename] = curr_index
        # curr_index.save_to_disk(f'index_{filename}.json')

    llm_predictor = LLMPredictor(llm=OpenAI(temperature=0, max_tokens=512))
    service_context = ServiceContext.from_defaults(llm_predictor=llm_predictor)

    # define a list index over the vector indices
    # allows us to synthesize information across each index
    graph = ComposableGraph.from_indices(
        GPTListIndex,
        [index_set[f] for f in os.listdir('data')],
        index_summaries=["Some information about an artist" for x in index_set],
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
        description="useful for when you want to answer queries that require analyzing multiple SEC 10-K documents for Uber.",
        query_configs=query_configs,
        tool_kwargs={"return_direct": True}
    )

    # define toolkit
    index_configs = []
    for f in os.listdir('data'):
        tool_config = IndexToolConfig(
            index=index_set[f],
            name=f"Vector Index {f}",
            description=f"useful for when you want to answer queries about artists",
            index_query_kwargs={"similarity_top_k": 3},
            tool_kwargs={"return_direct": True}
        )
        index_configs.append(tool_config)

    toolkit = LlamaToolkit(
        index_configs=index_configs,
        graph_configs=[graph_config]
    )

    llm = OpenAI(temperature=0, model_name="gpt-3.5-turbo")
    memory = ConversationBufferMemory(memory_key="chat_history")
    return create_llama_chat_agent(
        toolkit=toolkit,
        llm=llm,
        memory=memory,
        verbose=True
    )

agent_chains = {}
agent_chain = None
app = Flask(__name__)

@app.route("/ask", methods=["GET"])
def ask():
    prompt = request.args.get("query")
    id = request.args.get("id")

    # search in agent_chains collection in mongodb
    # if getAgentChainByUserId != null
    if id in agent_chains:
        agent_chain = agent_chains[id]
    else:
        agent_chain = init_data()       
        agent_chains[id] = agent_chain      # addAgentChainToDb

    try:
        response = agent_chain.run(input=prompt)
    except ValueError as e:
        response = str(e)
        if not response.startswith("Could not parse LLM output: `"):
            raise e
        response = response.removeprefix(
            "Could not parse LLM output: `").removesuffix("`")

    return jsonify({"answer": response})


if __name__ == "__main__":
    app.run()
