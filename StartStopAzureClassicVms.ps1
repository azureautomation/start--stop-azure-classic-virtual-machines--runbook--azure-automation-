<#
.SYNOPSIS
  Connects to Azure and starts of all VMs in the specified Azure subscription or cloud service

.DESCRIPTION
  This runbook connects to Azure and starts all classic VMs in an Azure subscription or cloud service.  
  You can attach a schedule to this runbook to run it at a specific time.  

  REQUIRED AUTOMATION ASSETS
  1. An Automation variable asset called "AzureSubscriptionId" that contains the GUID for this Azure subscription.  
     To use an asset with a different name you can pass the asset name as a runbook input parameter or change the default value for the input parameter.
  2. An Automation credential asset called "AzureCredential" that contains the Azure AD user credential with authorization for this subscription. 
     To use an asset with a different name you can pass the asset name as a runbook input parameter or change the default value for the input parameter.

.PARAMETER AzureCredentialAssetName
   Optional with default of "AzureCredential".
   The name of an Automation credential asset that contains the Azure AD user credential with authorization for this subscription. 
   To use an asset with a different name you can pass the asset name as a runbook input parameter or change the default value for the input parameter.

.PARAMETER AzureSubscriptionIdAssetName
   Optional with default of "AzureSubscriptionId".
   The name of An Automation variable asset that contains the GUID for this Azure subscription.
   To use an asset with a different name you can pass the asset name as a runbook input parameter or change the default value for the input parameter.

.PARAMETER ServiceName
   Optional
   Allows you to specify the cloud service containing the VMs to start.  
   If this parameter is included, only VMs in the specified cloud service will be started, otherwise all VMs in the subscription will be started.  

.NOTES
   ORIGINAL AUTHOR: System Center Automation Team 
   EDITOR: David Hendry - davidhendry.co.uk
   EDITOR COMMENTS: Added toggle, if machines are started then machines will be stopped, if machines are stopped they will be started.
   machines are only started Monday - Friday.
   LASTEDIT: September 21, 2016
#>

workflow StartStopAzureClassicVms
{   
    param (
        [Parameter(Mandatory=$false)] 
        [String]  $AzureCredentialAssetName = 'AzureCredential',
        
        [Parameter(Mandatory=$false)]
        [String] $AzureSubscriptionIdAssetName = 'AzureSubscriptionId',

        [Parameter(Mandatory=$false)] 
        [String] $ServiceName
    )

    # Returns strings with status messages
    [OutputType([String])]

	# Connect to Azure and select the subscription to work against
	$Cred = Get-AutomationPSCredential -Name $AzureCredentialAssetName
	$null = Add-AzureAccount -Credential $Cred -ErrorAction Stop
	$SubId = Get-AutomationVariable -Name $AzureSubscriptionIdAssetName
    $null = Select-AzureSubscription -SubscriptionId $SubId -ErrorAction Stop

	# If there is a specific cloud service, then get all VMs in the service,
    # otherwise get all VMs in the subscription.
    if ($ServiceName) 
	{ 
		$VMs = Get-AzureVM -ServiceName $ServiceName
	}
    else 
	{ 
		$VMs = Get-AzureVM
	}

    # Iterate through each VM
    foreach ($VM in $VMs)
    {
		if ($VM.PowerState -eq "Started")
		{
			# The VM is already started, so lets turn it off
			Write-Output ($VM.InstanceName + " is going to be stopped")
			Stop-AzureVM -Name $VM.Name -ServiceName $VM.ServiceName -Force -ErrorAction Continue
		}
		else
		{
			$day = [int] (get-date).DayOfWeek
            # We only want to start machines Monday - Friday
			if($day -ne 0 -Or $day -ne 6)
            {
                # The VM needs to be started
                $StartRtn = Start-AzureVM -Name $VM.Name -ServiceName $VM.ServiceName -ErrorAction Continue

                if ($StartRtn.OperationStatus -ne 'Succeeded')
                {
                    # The VM failed to start, so send notice
                    Write-Output ($VM.InstanceName + " failed to start")
                }
                else
                {
                    # The VM started, so send notice
                    Write-Output ($VM.InstanceName + " has been started")
                }
            }
		}
    }
}