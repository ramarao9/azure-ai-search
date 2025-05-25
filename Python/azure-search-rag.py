# Set up the query for generating responses
from azure.identity import DefaultAzureCredential
from azure.identity import get_bearer_token_provider
from azure.search.documents import SearchClient
from openai import AzureOpenAI
from dotenv import load_dotenv
import os
from pprint import pprint


def main():

    load_dotenv()
    # Set up the Azure OpenAI and Azure Search service credentials
    AZURE_OPENAI_ACCOUNT = os.getenv("AZURE_OPENAI_ACCOUNT")
    AZURE_SEARCH_SERVICE = os.getenv("AZURE_SEARCH_SERVICE")
    AZURE_DEPLOYMENT_MODEL = os.getenv("AZURE_DEPLOYMENT_MODEL")

    print(f"AZURE_OPENAI_ACCOUNT: {AZURE_OPENAI_ACCOUNT}")
    print(f"AZURE_SEARCH_SERVICE: {AZURE_SEARCH_SERVICE}")
    print(f"AZURE_DEPLOYMENT_MODEL: {AZURE_DEPLOYMENT_MODEL}")

    credential = DefaultAzureCredential()

    token_provider = get_bearer_token_provider(
        credential, "https://cognitiveservices.azure.com/.default"
    )

    openai_client = AzureOpenAI(
        api_version="2024-06-01",
        azure_endpoint=AZURE_OPENAI_ACCOUNT,
        azure_ad_token_provider=token_provider,
    )

    search_client = SearchClient(
        endpoint=AZURE_SEARCH_SERVICE,
        index_name="product-index",
        credential=credential,
    )

    # This prompt provides instructions to the model
    GROUNDED_PROMPT = """
    You are a friendly assistant that recommends products.
    Answer the query using only the sources provided below in a friendly and concise bulleted manner.
    Answer ONLY with the facts listed in the list of sources below.
    If there isn't enough information below, say you don't know.
    Do not generate answers that don't use the sources below.
    Query: {query}
    Sources:\n{sources}
    """

    # Get the query from the user
    query = input("Enter your product-related question: ")

    # Search results are created by the search client
    # Search results are composed of the top 10 results and the fields selected from the search index
    # Search results include the top 10 matches to your query
    search_results = search_client.search(
        search_text=query,
        top=10,
        select="keyphrases,content,products,url,metadata_storage_name",
    )

    print(f"Search results returned:")

    sources_formatted = "\n".join(
        [
            f'{document["metadata_storage_name"]}:{document["content"]}:{document["keyphrases"]}:{document["url"]}:{document["products"]}'
            for document in search_results
        ]
    )

    # Send the search results and the query to the LLM to generate a response based on the prompt.
    response = openai_client.chat.completions.create(
        messages=[
            {
                "role": "user",
                "content": GROUNDED_PROMPT.format(
                    query=query, sources=sources_formatted
                ),
            }
        ],
        model=AZURE_DEPLOYMENT_MODEL,
    )

    # Here is the response from the chat model.
    print(response.choices[0].message.content)


if __name__ == "__main__":
    main()
