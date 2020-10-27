Start / Stop Azure Classic Virtual Machines (Runbook, Azure Automation)
=======================================================================

            

Intended to be used as a Runbook within Azure automation.


As part of the Automation account used to run the Runbook you'll need to create a variable for AzureSubscriptionId (this is your azure subscription ID), and a credential called AzureCredential (this needs to be an account within your Azure AD).


Start / stops Azure classic virtual machines.  Provided a resouce group is added as a variable, all VMs within that group will be toggled.  If machines are started then machines will be stopped, if machines are stopped they will be started.


Note - Machines only start Monday - Friday.  On Saturday / Sunday machines will not be started - they will only be stopped (if manually started).


 


 

 
 

        
    
TechNet gallery is retiring! This script was migrated from TechNet script center to GitHub by Microsoft Azure Automation product group. All the Script Center fields like Rating, RatingCount and DownloadCount have been carried over to Github as-is for the migrated scripts only. Note : The Script Center fields will not be applicable for the new repositories created in Github & hence those fields will not show up for new Github repositories.
