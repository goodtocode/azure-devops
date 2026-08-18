####################################################################################
# To execute
#   1. Run Powershell as ADMINistrator
#   2. In powershell, set security polilcy for this script: 
#      Set-ExecutionPolicy Unrestricted -Scope Process -Force
#   3. Change directory to the script folder:
#      CD C:\Scripts (wherever your script is)
#   4. In powershell, run script: 
#      .\Copy-StorageAccountContainer.ps1 
####################################################################################

param (
    [string]$TenantId,
    [string]$SubscriptionId,
    [string]$SrcResourceGroupName,
    [string]$SrcStorageAccountName,
    [string]$SrcContainer,
    [string]$DestResourceGroupName,
    [string]$DestStorageAccountName,
    [string]$DestContainer
)

####################################################################################
Set-ExecutionPolicy Unrestricted -Scope Process -Force
$VerbosePreference = 'SilentlyContinue' # 'SilentlyContinue' # 'Continue'
####################################################################################

# Imports
if (-not (Get-Module -ListAvailable -Name Az.Accounts)) { Install-Module -Name Az.Accounts -AllowClobber -Scope CurrentUser -Force }
if (-not (Get-Module -Name Az.Accounts)) { Import-Module -Name Az.Accounts -Force}
if (-not (Get-Module -ListAvailable -Name Az.Resources)) { Install-Module -Name Az.Resources -AllowClobber -Scope CurrentUser -Force }
if (-not (Get-Module -Name Az.Resources)) { Import-Module -Name Az.Resources -Force}
if (-not (Get-Module -ListAvailable -Name Az.Storage)) { Install-Module -Name Az.Storage -AllowClobber -Scope CurrentUser -Force }
if (-not (Get-Module -Name Az.Storage)) { Import-Module -Name Az.Storage -Force}

# Auth
Connect-AzAccount -Tenant $TenantId -Subscription $SubscriptionId

# Execute
$SrcStorageKey = (Get-AzStorageAccountKey -ResourceGroupName $SrcResourceGroupName -Name $SrcStorageAccountName)[0].Value
$DestStorageKey = (Get-AzStorageAccountKey -ResourceGroupName $DestResourceGroupName -Name $DestStorageAccountName)[0].Value

$SrcContext = New-AzStorageContext -StorageAccountName $SrcStorageAccountName -StorageAccountKey $SrcStorageKey
$DestContext = New-AzStorageContext -StorageAccountName $DestStorageAccountName -StorageAccountKey $DestStorageKey

# Check if destination container exists, if not, create it
$DestContainerExists = Get-AzStorageContainer -Context $DestContext -Name $DestContainer -ErrorAction SilentlyContinue
if (-not $DestContainerExists) {
    New-AzStorageContainer -Name $DestContainer -Context $DestContext
}

Get-AzStorageBlob -Container $SrcContainer -Context $SrcContext | ForEach-Object {
    Start-AzStorageBlobCopy -SrcContainer $SrcContainer -SrcBlob $_.Name -SrcContext $SrcContext -DestContainer $DestContainer -DestContext $DestContext -Force
}