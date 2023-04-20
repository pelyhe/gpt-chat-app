# GPT Chat app
## A chat app based on gpt-3.5 turbo, trained by own data from txt files. 
### Client side: Flutter app with basic UI
### Server side: Python (FastAPI) API which handles different user sessions. Uses Llama-index & langchain to query from own txt files. Also has the basic GPT knowledge, not only the knowledge from the files. It is context-aware, so has a Buffer memory which stores the previous messages and metadatas for each user.
