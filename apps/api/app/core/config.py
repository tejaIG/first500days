from pydantic_settings import BaseSettings
from pydantic import Field

class Settings(BaseSettings):
    GEMINI_API_KEY: str = Field(..., description="Google Gemini API Key")
    GEMINI_MODEL: str = "gemini-1.5-flash"
    
    AZURE_SEARCH_ENDPOINT: str = Field(..., description="Azure AI Search Endpoint")
    AZURE_SEARCH_KEY: str = Field(..., description="Azure AI Search Admin Key")
    AZURE_SEARCH_INDEX_NAME: str = "rag-index"

    class Config:
        env_file = ".env"

settings = Settings()