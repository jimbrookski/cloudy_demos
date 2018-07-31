## Get the connection "AzureRunAsConnection "
$connectionName = "AzureRunAsConnection"
$servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

"Logging in to Azure..."
Add-AzureRmAccount `
            -ServicePrincipal `
            -TenantId $servicePrincipalConnection.TenantId `
            -ApplicationId $servicePrincipalConnection.ApplicationId `
            -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint
"Login complete."

#Get all subscriptions
$Subscriptions = Get-AzureRmSubscription
foreach ($Sub in $Subscriptions) {
    $SelectedSub = Select-AzureRmSubscription -SubscriptionId $Sub.Id -WarningAction Ignore
    if ($SelectedSub.Subscription.State -ne "Disabled") {
        $ResourceGroups = Get-AzureRmResourceGroup
        foreach ($rg in $ResourceGroups) {
            $Tags = $rg.Tags
            if ($Tags -ne $null) {
                foreach ($tag in $Tags) {
                    if (($tag.ContainsKey("DevOps")) -and ($resourceTags["DevOps"] -eq "Test")) {
                        Write-Output "Removing $($rg.ResourceGroupName)"
                        Remove-AzureRmResourceGroup -Name $rg.ResourceGroupName -Force
                        break
                    }
                }
            }
        }
    }
}