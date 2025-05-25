# Azure AI Search Demo Project

This project demonstrates how to use Azure AI Search and Azure OpenAI to build a Retrieval-Augmented Generation (RAG) application in Python. The solution indexes product documents (PDFs) and enables natural language queries over the indexed content.

## Project Structure

```
Documents/           # Source PDF documents to be indexed
Python/              # Python code for the RAG application
    azure-search-rag.py
    env/             # Python virtual environment (not tracked by git)
Scripts/             # PowerShell scripts for Azure resource management
SearchComponents/    # JSON definitions for Azure Search index, skillset, and indexer
```

## Prerequisites
- Python 3.8+
- Azure Subscription
- Azure AI Search resource
- Azure OpenAI resource
- PowerShell (for running scripts)

## Setup Instructions

1. **Clone the repository**

2. **Set up Python environment**
```sh
cd Python
python3 -m venv env
source env/bin/activate
pip install -r requirements.txt
```

3. **Configure environment variables**
Create a `.env` file in the `Python/` directory with the following:
```
AZURE_OPENAI_ACCOUNT=<your-openai-endpoint>
AZURE_SEARCH_SERVICE=<your-search-service-endpoint>
AZURE_DEPLOYMENT_MODEL=<your-openai-deployment-name>
```

4. **Provision Azure resources**
Use the PowerShell scripts in the `Scripts/` folder to create and configure your Azure AI Search resource and components:
- `Create-AI-Search.ps1` – Creates the Azure AI Search resource
- `Upsert-Search-Components.ps1` – Deploys the index, skillset, and indexer

5. **Run the Python RAG app**
```sh
cd Python
source env/bin/activate
python azure-search-rag.py
```

## Documents
Place your product PDF files in the `Documents/` folder. These will be indexed by the Azure Search indexer. The folder has some documents you could use for your testing as well.

## SearchComponents
- `index.json` – Defines the Azure Search index schema
- `skillset.json` – Defines AI enrichment skills (e.g., key phrase extraction, entity recognition)
- `indexer.json` – Defines the indexer that connects your data source to the index

## Scripts
- `Create-AI-Search.ps1` – Creates the Azure AI Search resource
- `Upsert-Search-Components.ps1` – Deploys/updates the index, skillset, and indexer
- `Delete-AI-Search.ps1` – (Optional) Deletes the Azure AI Search resource

## Python Application
- `azure-search-rag.py` – Main entry point for querying the indexed documents using Azure OpenAI and Azure Search

## .gitignore
- The `Python/env/` folder and other generated files are excluded from version control (see `.gitignore`).

## License
MIT License
