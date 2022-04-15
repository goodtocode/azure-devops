#-----------------------------------------------------------------------
# Set-Version [-Path [<String>]] [-VersionToReplace [<String>]]
#
# Example: .\Set-Version -Path \\source\path -Major 1
#-----------------------------------------------------------------------

# ***
# *** Parameters
# ***
param
(
	[Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [string] $Path=$(throw '-Path is a required parameter. i.e. $(Build.SourcesDirectory)'),
	[Version] $VersionToReplace='1.0.0',
	[String] $Major='-1',
	[String] $Minor='-1',
	[String] $Revision='-1',
	[String] $Build='-1'
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
If($IsWindows){
	$Path = Set-Unc -Path $Path
}

# ***
# *** Locals
# ***

# ***
# *** Execute
# ***
$Major = $Major.Replace('-1', '1')
$Minor = $Minor.Replace('-1', (Get-Date -UFormat '%Y').ToString().Substring(2,2)) # YY
$Revision = $Revision.Replace('-1', (Get-Date -UFormat '%j').ToString()) # DayOfYear
$Build = $Build.Replace('-1', (Get-Date -UFormat '%H%M').ToString()) # HrMinSec

# .Net Projects
$LongVersion = "$Major.$Minor.$Revision.$Build"
$ShortVersion = "$Major.$Minor.$Revision"
Write-Host "LongVersion: $LongVersion ShortVersion: $ShortVersion"

# Package.json version
Update-LineByContains -Path $Path -Contains 'version' -Line """version"": ""$LongVersion""," -Include package.json
# *.csproj C# Project files
Update-ContentsByTag -Path $Path -Value $LongVersion -Open '<Version>' -Close '</Version>' -Include *.csproj
# *.nuspec NuGet packages
Update-ContentsByTag -Path $Path -Value $LongVersion -Open '<version>' -Close '</version>' -Include *.nuspec
# Assembly.cs C# assembly manifest
Update-LineByContains -Path $Path -Contains "AssemblyVersion(" -Line "[assembly: AssemblyVersion(""$LongVersion"")]" -Include AssemblyInfo.cs
# *.vsixmanifest VSIX Visual Studio Templates
Update-TextByContains -Path $Path -Contains "<Identity Id" -Old $VersionToReplace -New $ShortVersion -Include *.vsixmanifest

