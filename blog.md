# Building a Retrieval-Augmented Generation (RAG) App with Azure AI Search and Azure OpenAI

This blog post explains how to build a Python application that combines Azure AI Search and Azure OpenAI to enable natural language queries over a set of product documents (PDFs). The solution indexes product documents, enriches them with AI skills, and allows users to ask questions and get answers grounded in the indexed content.

---

## Prerequisites
To follow along, you will need:
- **An Azure Subscription** (with permissions to create resources)
- **Azure AI Search resource** (Standard tier recommended)
- **Azure OpenAI resource** (with a deployed chat/completions model)
- **Python 3.8+**
- **PowerShell** (for running setup scripts)
- **Git** (to clone the repository)
- **Basic familiarity with the command line**

---

## Solution Architecture

Below is a high-level architecture diagram for this RAG approach:

```
+-------------------+         +---------------------+         +-------------------+
|                   |         |                     |         |                   |
|  Product PDFs     +-------->+  Azure AI Search    +<------>+  Azure OpenAI      |
|  (Documents/)     | Indexer |  (Index, Skillset,  |  Query  |  (Chat Completion |
|                   |         |   Indexer)          |         |   API)            |
+-------------------+         +---------------------+         +-------------------+
        |                                                           ^
        |                                                           |
        v                                                           |
+-------------------+                                        +-----+-----+
|                   |<----------------------------------------+           |
|  Python RAG App   |   User Query & Results                  |   User    |
|                   |                                        |           |
+-------------------+                                        +-----------+
```

## Solution Architecture (Mermaid Diagram)

```mermaid
graph TD
    A[Product PDFs (Documents/)] -- Indexer --> B[Azure AI Search\n(Index, Skillset, Indexer)]
    B -- Query --> C[Azure OpenAI\n(Chat Completion API)]
    C -- Answer --> D[Python RAG App]
    D -- User Query & Results --> E[User]
    E -- Ask Question --> D
    D -- Query --> B
```

**Flow:**
1. Product PDFs are placed in the `Documents/` folder.
2. Azure Search indexer and skillset extract and enrich content from PDFs.
3. The Python app takes a user question, queries Azure Search, and sends the results to Azure OpenAI for answer generation.
4. The user receives a grounded, concise answer based on indexed documents.

---

## How the Code Works

1. **Environment Setup:**
   - The user sets up a Python virtual environment and installs dependencies.
   - Environment variables for Azure endpoints and deployment names are configured in a `.env` file.

2. **Indexing Documents:**
   - PowerShell scripts provision the Azure AI Search resource and upload index/skillset/indexer definitions.
   - The indexer processes PDFs in the `Documents/` folder, extracting text and metadata.

3. **Querying and RAG Flow:**
   - The Python script prompts the user for a question.
   - It queries Azure AI Search for relevant content.
   - The top results are formatted and sent to Azure OpenAI's chat completion API with a grounding prompt.
   - The model responds with an answer based only on the provided sources.

4. **User Experience:**
   - The user sees the answer and can ask follow-up questions, all grounded in the indexed product documents.

---

## Key Files and Folders
- `Python/azure-search-rag.py`: Main Python application for RAG workflow
- `Documents/`: Folder for product PDFs to be indexed
- `SearchComponents/`: JSON files for index, skillset, and indexer definitions
- `Scripts/`: PowerShell scripts for provisioning and managing Azure resources

---

## Summary
This approach enables you to build a powerful, enterprise-ready RAG solution using Azure AI Search and Azure OpenAI, allowing users to ask natural language questions and get answers grounded in your own documents.

*Happy building!*
