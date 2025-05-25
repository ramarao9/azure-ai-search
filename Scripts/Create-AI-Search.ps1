#####################################################################
# Create-AI-Search.ps1
# Script to create an Azure AI Search resource
#####################################################################



[CmdletBinding(SupportsShouldProcess=$true)]
param (
    [Parameter(Mandatory=$true, HelpMessage="Enter the name of the Azure Resource Group.")]
    [string]$ResourceGroupName,

    [Parameter(Mandatory=$true, HelpMessage="Enter the desired name for the Azure Search service. It must be globally unique.")]
    [string]$SearchServiceName,

    [Parameter(Mandatory=$true, HelpMessage="Enter the Azure region for the service (e.g., 'East US', 'West Europe').")]
    [string]$Location,

    [Parameter(HelpMessage="Enter the SKU (pricing tier). Valid values: free, basic, standard, standard2, standard3, storage_optimized_l1, storage_optimized_l2. Default is 'basic'.")]
    [ValidateSet("free", "basic", "standard", "standard2", "standard3", "storage_optimized_l1", "storage_optimized_l2")]
    [string]$Sku = "basic"
)

# Begin script execution
try {
    # Check if Az.Search module is installed
    if (-not (Get-Module -ListAvailable -Name Az.Search)) {
        Write-Warning "The Az.Search module is not installed. Attempting to install it now."
        Install-Module Az.Search -Scope CurrentUser -Force -AllowClobber -SkipPublisherCheck
        Import-Module Az.Search -Force
        Write-Host "Az.Search module installed and imported successfully." -ForegroundColor Green
    } else {
        Import-Module Az.Search -Force
        Write-Host "Az.Search module is already installed and imported." -ForegroundColor Green
    }

    # Check if the resource group exists, if not, create it.
    Write-Host "Checking if Resource Group '$ResourceGroupName' exists in location '$Location'..."
    $rg = Get-AzResourceGroup -Name $ResourceGroupName -Location $Location -ErrorAction SilentlyContinue
    if (-not $rg) {
        if ($PSCmdlet.ShouldProcess($ResourceGroupName, "Create Resource Group (because it does not exist)")) {
            Write-Host "Resource Group '$ResourceGroupName' not found. Creating it now in '$Location'..."
            New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Force | Out-Null
            Write-Host "Resource Group '$ResourceGroupName' created successfully in '$Location'." -ForegroundColor Green
        } else {
            Write-Warning "Resource Group '$ResourceGroupName' does not exist and creation was skipped by user."
            exit 1 # Exit if user cancels RG creation
        }
    } else {
        Write-Host "Resource Group '$ResourceGroupName' found in location '$($rg.Location)'." -ForegroundColor Green
        # If RG exists but in a different location, it's usually fine for Search, but good to be aware.
        if ($rg.Location -ne $Location) {
            Write-Warning "The existing Resource Group '$ResourceGroupName' is in location '$($rg.Location)', but the Search Service will be created in '$Location'."
        }
    }

    # Check if the Search Service already exists
    Write-Host "Checking if Search Service '$SearchServiceName' already exists..."
    $searchService = Get-AzSearchService -ResourceGroupName $ResourceGroupName -Name $SearchServiceName -ErrorAction SilentlyContinue

    if ($searchService) {
        Write-Warning "Search Service '$SearchServiceName' already exists in Resource Group '$ResourceGroupName'."
        Write-Host "Service Details:"
        $searchService | Format-List
        Write-Host "No changes made. Exiting script." -ForegroundColor Yellow
        exit 0 # Exit gracefully as service already exists
    }

    # Create the Azure Cognitive Search service
    if ($PSCmdlet.ShouldProcess($SearchServiceName, "Create Azure Cognitive Search Service")) {
        Write-Host "Creating Azure Cognitive Search service '$SearchServiceName' in '$Location' with SKU '$Sku'..."

        $searchServiceParams = @{
            ResourceGroupName = $ResourceGroupName
            Name              = $SearchServiceName
            Sku               = $Sku
            Location          = $Location
            # You can add other optional parameters here, like PartitionCount, ReplicaCount (if Sku is not 'free' or 'basic')
            # Example for standard SKU:
            # ReplicaCount      = 1
            # PartitionCount    = 1
        }

        # For 'free' and 'basic' SKUs, ReplicaCount and PartitionCount cannot be set.
        # For 'standard' and above, they default to 1 if not specified.
        # You might want to add logic to conditionally add ReplicaCount and PartitionCount based on the Sku.
        # For example:
        # if ($Sku -ne "free" -and $Sku -ne "basic") {
        #     $searchServiceParams.ReplicaCount = 1 # Or prompt user
        #     $searchServiceParams.PartitionCount = 1 # Or prompt user
        # }


        $newSearchService = New-AzSearchService @searchServiceParams

        if ($newSearchService) {
            Write-Host "Azure Cognitive Search service '$($newSearchService.Name)' created successfully." -ForegroundColor Green
            Write-Host "Details:"
            Write-Host "  Name: $($newSearchService.Name)"
            Write-Host "  Resource Group: $($newSearchService.ResourceGroupName)"
            Write-Host "  Location: $($newSearchService.Location)"
            Write-Host "  SKU: $($newSearchService.Sku.Name)"
            Write-Host "  Status: $($newSearchService.Status)"
            Write-Host "  Hosting Mode: $($newSearchService.HostingMode)"
            Write-Host "  Public Network Access: $($newSearchService.PublicNetworkAccess)"

        } else {
            Write-Error "Failed to create Azure Cognitive Search service '$SearchServiceName'."
        }
    } else {
        Write-Warning "Creation of Search Service '$SearchServiceName' was skipped by user."
    }

}
catch {
    Write-Error "An error occurred: $($_.Exception.Message)"
    Write-Error "At line: $($_.InvocationInfo.ScriptLineNumber)"
}
finally {
    Write-Host "Script execution finished."
}
