import google.generativeai as genai
from google.generativeai.types import content_types
from collections.abc import Iterable
from app.core.config import settings
from app.services.vector_store import search_documents

# Configure Gemini
genai.configure(api_key=settings.GEMINI_API_KEY)

def get_embedding(text: str) -> list[float]:
    """Generates embedding for Queries"""
    result = genai.embed_content(
        model="models/text-embedding-004",
        content=text,
        task_type="retrieval_query"
    )
    return result['embedding']

def get_doc_embedding(text: str) -> list[float]:
    """Generates embedding for Documents (Ingestion)"""
    result = genai.embed_content(
        model="models/text-embedding-004",
        content=text,
        task_type="retrieval_document"
    )
    return result['embedding']

# --- Tools ---
def search_internal_knowledge(query: str):
    """
    Search the internal knowledge base for relevant documents.
    Use this tool when you need to answer questions based on uploaded files.
    """
    print(f"Tool Call: Searching for '{query}'...")
    # Generate embedding for the query
    vector = get_embedding(query)
    # Search Vector DB
    results = search_documents(query, vector)
    
    formatted_results = []
    for doc in results:
        formatted_results.append(f"Content: {doc['content']}\nSource: {doc['source']}")
    
    if not formatted_results:
        return "No relevant documents found."
        
    return "\n\n".join(formatted_results)

# Initialize Model with Tools
tools_list = [search_internal_knowledge]
model = genai.GenerativeModel(
    model_name=settings.GEMINI_MODEL,
    tools=tools_list
)

# Chat Session
def process_query(user_query: str):
    # Create a chat session 
    chat = model.start_chat(enable_automatic_function_calling=True)
    
    system_instruction = "You are a helpful AI assistant. Always cite your sources in the format [Source: filename]. If you use the search tool, base your answer primarily on the returned context."
    
    # Gemini handles the tool loop automatically
    response = chat.send_message(f"{system_instruction}\n\nUser Query: {user_query}")
    
    sources = [] 
    
    return {"response": response.text, "sources": sources}
