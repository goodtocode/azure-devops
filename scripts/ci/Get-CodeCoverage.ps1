####################################################################################
# To execute
#   1. In powershell, set security policy for this script: 
#      Set-ExecutionPolicy Unrestricted -Scope Process -Force
#   2. Change directory to the script folder:
#      CD src (wherever your script is)
#   3. In powershell, run script: 
#      .\Get-CodeCoverage.ps1 -TestProjectFilter '*Tests*.csproj'
# This script uses native .NET 10 code coverage (Microsoft.Testing.Platform)
# Note: Due to MSTest 4.1.0 incompatibility with 'dotnet test' on .NET 10, this runs tests as executables
####################################################################################

Param(
    [string]$TestProjectFilter = '*Tests*.csproj',    
    [string]$Configuration = 'Release',
    [string]$TestRootPath = ''
)
####################################################################################
if ($IsWindows) {Set-ExecutionPolicy Unrestricted -Scope Process -Force}
$VerbosePreference = 'SilentlyContinue' # 'Continue'
####################################################################################

function Resolve-TestRootPath {
    param(
        [Parameter(Mandatory = $true)]
        [System.IO.DirectoryInfo]$ScriptDir,
        [Parameter(Mandatory = $false)]
        [string]$OverridePath
    )

    if (-not [string]::IsNullOrWhiteSpace($OverridePath)) {
        return Get-Item -Path (Resolve-Path -Path $OverridePath)
    }

    $current = $ScriptDir
    while ($null -ne $current) {
        $srcCandidate = Join-Path $current.FullName 'src'
        if (Test-Path -Path $srcCandidate) {
            return Get-Item -Path $srcCandidate
        }

        $current = $current.Parent
    }

    return $ScriptDir
}

# Install required tools
& dotnet tool install -g dotnet-reportgenerator-globaltool
& dotnet tool install -g dotnet-coverage

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$scriptPath = Get-Item -Path $PSScriptRoot
$testRootPath = Resolve-TestRootPath -ScriptDir $scriptPath -OverridePath $TestRootPath
$reportOutputPath = Join-Path $testRootPath "TestResults\Reports\$timestamp"

New-Item -ItemType Directory -Force -Path $reportOutputPath 

# Find test projects
$testProjects = Get-ChildItem $testRootPath -Filter $TestProjectFilter -Recurse
Write-Host "Found $($testProjects.Count) test projects."

foreach ($project in $testProjects) {
    $testProjectPath = $project.FullName
    Write-Host "Running tests with coverage for project: $($project.BaseName)"

    Write-Host "Building test project: $($project.BaseName)"
    & dotnet build $testProjectPath --configuration $Configuration
    
    # Use 'dotnet run' instead of 'dotnet test' for MSTest runner projects
    # This bypasses the VSTest target that's incompatible with .NET 10 SDK
    Push-Location $project.DirectoryName
    & dotnet run --configuration $Configuration --no-build -- --coverage
    Pop-Location
}

# Collect all coverage files (Microsoft.Testing.Platform outputs .coverage files)
$coverageFiles = Get-ChildItem -Path $testRootPath -Filter "*.coverage" -Recurse | Select-Object -ExpandProperty FullName

if ($coverageFiles.Count -eq 0) {
    Write-Warning "No coverage files found. Make sure your test projects have code coverage enabled."
    exit 0
}

Write-Host "Found $($coverageFiles.Count) coverage file(s)"

# Convert binary .coverage files to XML format
$coverageXmlFiles = @()
foreach ($coverageFile in $coverageFiles) {
    $xmlFile = $coverageFile -replace '\.coverage$', '.cobertura.xml'
    Write-Host "Converting $coverageFile to XML format..."
    & dotnet-coverage merge $coverageFile --output $xmlFile --output-format cobertura
    if (Test-Path $xmlFile) {
        $coverageXmlFiles += $xmlFile
    }
}

if ($coverageXmlFiles.Count -eq 0) {
    Write-Warning "No XML coverage files were generated."
    exit 0
}

Write-Host "Generated $($coverageXmlFiles.Count) XML coverage file(s)"

# Generate HTML report
$coverageFilesArg = ($coverageXmlFiles -join ";")
& reportgenerator -reports:$coverageFilesArg -targetdir:$reportOutputPath -reporttypes:Html

Write-Host "Code coverage report generated at: $reportOutputPath"

$reportIndexHtml = Join-Path $reportOutputPath "index.html"
if (Test-Path $reportIndexHtml) {
    Invoke-Item -Path $reportIndexHtml
}
else {
    Write-Warning "Report index.html not found at: $reportIndexHtml"
}