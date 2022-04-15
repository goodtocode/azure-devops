#-----------------------------------------------------------------------
# Remove-StorageAccount [-Path [<String>]] [-VersionToReplace [<String>]]
#
# Example: .\Remove-StorageAccount -Path \\source\path -Major 1
#-----------------------------------------------------------------------

# ***
# *** Parameters
# ***
param
(
	[Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [string] $StorageAccount=$(throw '-StorageAccount is a required parameter. i.e. $(Build.SourcesDirectory)')
)

# ***
# *** Initialize
# ***
if ($IsWindows) { Set-ExecutionPolicy Unrestricted -Scope Process -Force }
$VerbosePreference = 'SilentlyContinue' #'Continue'
[String]$ThisScript = $MyInvocation.MyCommand.Path
[String]$ThisDir = Split-Path $ThisScript
[DateTime]$Now = Get-Date
Set-Location $ThisDir # Ensure our location is correct, so we can use relative paths
Write-Host "*****************************"
Write-Host "*** Starting: $ThisScript on $Now"
Write-Host "*****************************"
# Imports
Import-Module "./System.psm1"

# ***
# *** Validate and cleanse
# ***


# ***
# *** Locals
# ***
$connectionString = az storage account show-connection-string -n $StorageAccount -otsv
# ***
# *** Execute
# ***
az storage delete --account-name $StorageAccount --connection-string $connectionString --verbose