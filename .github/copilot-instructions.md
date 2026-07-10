# Copilot Instructions

## Repository Purpose
This repository stores Azure DevOps YAML assets:
- end-to-end pipeline definitions under pipelines/
- reusable step templates under steps/
- environment/common variable templates under variables/
- shared pipeline scripts under scripts/

## Preferred Authoring Approach
- Prefer direct CLI-driven or immediate task steps in pipeline files over adding new templated step abstractions.
- Keep templates only when they are already in active use or clearly reduce duplication.
- Favor explicit, readable stage and job logic over deep indirection.

## .NET Versioning Standard
Use scripts in scripts/ci/ for all .NET version stamping in pipeline build jobs.

Required pattern:
1. Run Get-Version.ps1 first and parse JSON output.
2. Set pipeline variables from JSON:
   - semanticVersion
   - fileVersion
   - assemblyVersion
   - informationalVersion
3. Run Set-Version.ps1 with explicit components.
4. Pass resolved versions into dotnet build with MSBuild properties:
   - /p:Version=$(semanticVersion)
   - /p:FileVersion=$(fileVersion)
   - /p:AssemblyVersion=$(assemblyVersion)
   - /p:InformationalVersion=$(informationalVersion)

Default component guidance:
- versionMajor: 1
- versionMinor: 1
- patch: $(Build.BuildId)

Avoid legacy Set-Version usage that depends on Revision, Build, or Build.BuildNumber when patch-level numeric consistency is required.

## Pipeline Change Rules
- Keep changes minimal and scoped to the requested pipeline behavior.
- Do not rename existing pipeline files unless explicitly requested.
- Preserve trigger, branch, and path filters unless a change request includes trigger updates.
- Preserve existing deployment conditions and approvals unless explicitly requested.

## Script Usage Rules
- Call scripts using repo-relative variables (for example $(scriptsPath)).
- Keep script arguments explicit; avoid hidden defaults in pipeline YAML when values are important.
- Prefer PowerShell@2 steps for script orchestration and variable export.

## Validation Expectations
When modifying pipeline YAML:
- verify the edited files still contain expected stages and job dependencies
- confirm variable names match between Get-Version output and dotnet build arguments
- confirm all script paths align with ci-common.yml variables
