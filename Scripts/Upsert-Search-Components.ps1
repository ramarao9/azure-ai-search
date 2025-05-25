# Create-Search-Components.ps1
# This script creates an Azure Cognitive Search Index, Skillset, and Indexer using JSON definitions from the SearchComponents folder.

param (
    [Parameter(Mandatory = $true)]
    [string]$SearchServiceName,

    [Parameter(Mandatory = $true)]
    [string]$AdminApiKey,

    [Parameter(Mandatory = $false)]
    [string]$ResourceGroup
)

$baseUri = "https://$SearchServiceName.search.windows.net"
Write-Host "Base URI: $baseUri"
$apiVersion = "2024-07-01"
$headers = @{
    'api-key'      = $AdminApiKey
    'Content-Type' = 'application/json' 
    'Accept'       = 'application/json' 
}
$indexName = "product-index"
$skillsetName = "product-skillset"
$indexerName = "product-indexer"


$searchComponentsPath = Join-Path -Path $PSScriptRoot -ChildPath "..\SearchComponents"



# Create Index
$indexFile = Join-Path $searchComponentsPath "index.json"
if (Test-Path $indexFile) {
    $indexJson = Get-Content $indexFile -Raw
    $indexUri = "${baseUri}/indexes/${indexName}?api-version=${apiVersion}"
    Write-Host "Index URI: $indexUri"

    Invoke-RestMethod -Uri $indexUri -Headers $headers -Method Put -Body $indexJson
}
else {
    Write-Warning "Index JSON file not found: $indexFile"
}

# Create Skillset
$skillsetFile = Join-Path $searchComponentsPath "skillset.json"
if (Test-Path $skillsetFile) {
    $skillsetJson = Get-Content $skillsetFile -Raw
    $skillsetUri = "${baseUri}/skillsets('${skillsetName}')?api-version=${apiVersion}"
    Write-Host "Skillset URI: $skillsetUri"
    Invoke-RestMethod -Uri $skillsetUri -Headers $headers -Method Put -Body $skillsetJson
}
else {
    Write-Warning "Skillset JSON file not found: $skillsetFile"
}

# Create Indexer
$indexerFile = Join-Path $searchComponentsPath "indexer.json"
if (Test-Path $indexerFile) {
    $indexerJson = Get-Content $indexerFile -Raw
    $indexerUri = "${baseUri}/indexers('${indexerName}')?api-version=${apiVersion}"

     Invoke-RestMethod -Uri $indexerUri -Headers $headers -Method Put -Body $indexerJson
}
else {
    Write-Warning "Indexer JSON file not found: $indexerFile"
}