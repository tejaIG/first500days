from azure.core.credentials import AzureKeyCredential
from azure.search.documents import SearchClient
from azure.search.documents.indexes import SearchIndexClient
from azure.search.documents.indexes.models import (
    SearchIndex,
    SimpleField,
    SearchableField,
    SearchField,
    SearchFieldDataType,
    VectorSearch,
    HnswAlgorithmConfiguration,
    VectorSearchProfile,
)
from azure.search.documents.models import VectorizedQuery
from app.core.config import settings

def get_index_client() -> SearchIndexClient:
    return SearchIndexClient(
        endpoint=settings.AZURE_SEARCH_ENDPOINT,
        credential=AzureKeyCredential(settings.AZURE_SEARCH_KEY)
    )

def get_search_client() -> SearchClient:
    return SearchClient(
        endpoint=settings.AZURE_SEARCH_ENDPOINT,
        index_name=settings.AZURE_SEARCH_INDEX_NAME,
        credential=AzureKeyCredential(settings.AZURE_SEARCH_KEY)
    )

def ensure_index_exists():
    client = get_index_client()
    index_name = settings.AZURE_SEARCH_INDEX_NAME
    
    if index_name not in [name for name in client.list_index_names()]:
        # Define Vector Search Profile
        vector_search = VectorSearch(
            algorithms=[
                HnswAlgorithmConfiguration(
                    name="my-hnsw-config",
                    kind="hnsw"
                )
            ],
            profiles=[
                VectorSearchProfile(
                    name="my-vector-profile",
                    algorithm_configuration_name="my-hnsw-config"
                )
            ]
        )

        # Define Schema
        fields = [
            SimpleField(name="id", type=SearchFieldDataType.String, key=True),
            SearchableField(name="content", type=SearchFieldDataType.String),
            SimpleField(name="source", type=SearchFieldDataType.String, filterable=True),
            SearchField(
                name="embedding",
                type=SearchFieldDataType.Collection(SearchFieldDataType.Single),
                # Gemini text-embedding-004 is 768 dimensions
                vector_search_dimensions=768, 
                vector_search_profile_name="my-vector-profile"
            )
        ]

        index = SearchIndex(name=index_name, fields=fields, vector_search=vector_search)
        client.create_index(index)
        print(f"Index {index_name} created.")
    else:
        print(f"Index {index_name} already exists.")

def search_documents(query: str, vector: list[float], top_k: int = 3):
    client = get_search_client()
    
    vector_query = VectorizedQuery(vector=vector, k_nearest_neighbors=top_k, fields="embedding")
  
    results = client.search(
        search_text=query,
        vector_queries=[vector_query],
        select=["content", "source"],
        top=top_k
    )
    
    return list(results)