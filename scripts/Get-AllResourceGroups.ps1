#Retrieve all resource groups via API call for the current subscription
function Get-Token() {
    $ErrorActionPreference = 'Stop'
  
    if (-not (Get-Module AzureRm.Profile)) {
        Import-Module AzureRm.Profile
    }
    $azureRmProfileModuleVersion = (Get-Module AzureRm.Profile).Version
    # refactoring performed in AzureRm.Profile v3.0 or later
    if ($azureRmProfileModuleVersion.Major -ge 3) {
        $azureRmProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
        if (-not $azureRmProfile.Accounts.Count) {
            Write-Error "Ensure you have logged in before calling this function."    
        }
    }
    else {
        # AzureRm.Profile < v3.0
        $azureRmProfile = [Microsoft.WindowsAzure.Commands.Common.AzureRmProfileProvider]::Instance.Profile
        if (-not $azureRmProfile.Context.Account.Count) {
            Write-Error "Ensure you have logged in before calling this function."    
        }
    }

    $currentAzureContext = Get-AzureRmContext
    $profileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azureRmProfile)
    Write-Debug ("Getting access token for tenant" + $currentAzureContext.Subscription.TenantId)
    $token = $profileClient.AcquireAccessToken($currentAzureContext.Subscription.TenantId)
    return $token.AccessToken
}

#Check if logged in
$Context = Get-AzureRmContext -ErrorAction SilentlyContinue
if ($Context.Name = "Default") {
    $Context = (Login-AzureRmAccount).Context
}

$SubscriptionId = $Context.Subscription.Id

$AccessToken = Get-Token

#Build API call
$Uri = "https://management.azure.com/subscriptions/$SubscriptionId/resourcegroups?api-version=2018-02-01"
$Verb = "GET"
$Headers = @{
    "Authorization" = "Bearer $AccessToken";
    "Content-Type" = "application/json"
}

$Response = Invoke-WebRequest -Uri $Uri -Headers $Headers -Method $Verb

return ($Response | ConvertFrom-Json).Value