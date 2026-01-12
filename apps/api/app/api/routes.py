from fastapi import APIRouter, UploadFile, File, HTTPException
from pydantic import BaseModel
import uuid
import tempfile
import os
from pypdf import PdfReader
from app.services.agent import process_query, get_doc_embedding
from app.services.vector_store import get_search_client

router = APIRouter()

class ChatRequest(BaseModel):
    message: str

@router.post("/chat")
async def chat(request: ChatRequest):
    try:
        result = process_query(request.message)
        return result
    except Exception as e:
        # Log error in production
        print(f"Error processing query: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/ingest")
async def ingest_document(file: UploadFile = File(...)):
    if not file.filename.endswith(".pdf"):
        raise HTTPException(status_code=400, detail="Only PDF files are supported.")
    
    try:
        # Save temp file
        with tempfile.NamedTemporaryFile(delete=False, suffix=".pdf") as tmp:
            tmp.write(await file.read())
            tmp_path = tmp.name

        # Extract Text
        reader = PdfReader(tmp_path)
        text = ""
        for page in reader.pages:
            extract = page.extract_text()
            if extract:
                text += extract + "\n"
        
        os.remove(tmp_path)

        if not text.strip():
             raise HTTPException(status_code=400, detail="Could not extract text from PDF.")

        # Create Embedding using the Document task type
        embedding = get_doc_embedding(text)

        # Upload to Azure Search
        search_client = get_search_client()
        doc = {
            "id": str(uuid.uuid4()),
            "content": text,
            "source": file.filename,
            "embedding": embedding
        }
        
        search_client.upload_documents(documents=[doc])
        
        return {"status": "success", "filename": file.filename, "chunks": 1}

    except Exception as e:
        print(f"Error ingesting document: {e}")
        raise HTTPException(status_code=500, detail=str(e))