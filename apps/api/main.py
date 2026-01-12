from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from app.api.routes import router
from app.services.vector_store import ensure_index_exists

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: Ensure Index Exists
    try:
        ensure_index_exists()
    except Exception as e:
        print(f"Warning: Could not check/create index on startup. Check credentials. Error: {e}")
    yield
    # Shutdown

app = FastAPI(lifespan=lifespan)

# CORS
origins = [
    "http://localhost:3000",
    "*" # Allow all for now to ease dev
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(router)

@app.get("/")
def read_root():
    return {"message": "RAG Agent API is Running"}

@app.get("/health")
def health_check():
    return {"status": "healthy"}