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

Script path guidance:
- Prefer `$(System.DefaultWorkingDirectory)/scripts/ci` for pipeline script usage.
- Some older files may still reference `.azure-devops/scripts`; treat that as legacy and update to `scripts/ci` when touching versioning logic.

## PR And Merge Standard
Use this default operating model for Azure DevOps pipelines:
- PR-triggered runs validate only. They should build, test, package, generate artifacts, run `what-if`, or generate migration scripts, but they must not deploy.
- Merge or direct branch runs build again from the merged commit, then deploy from that run's artifact.
- Deploy-capable stages should include a hard guard on `Build.Reason != PullRequest` so force flags do not allow PR deployments.

For application pipelines:
- Keep a dedicated `build` or `ci` stage that produces the deployable artifact.
- Development and production stages should consume that artifact and should not rebuild.

For deploy-only pipelines such as IaC or EF:
- Prefer a PR-only validation stage when there is a safe non-deploy validation path.
- Examples: Bicep `what-if`, EF migration script generation, compile/restore validation.

## Artifact Reuse Standard
When a pipeline has both build and deploy stages:
- Publish artifacts once during the build stage.
- Deploy development and production from the same artifact created by the current run.
- Prefer `PublishBuildArtifacts@1` paired with `DownloadBuildArtifacts@0` using `buildType: 'current'` when the pipeline already uses build artifacts.
- Scope deployment paths to the downloaded artifact folder rather than broad workspace globs when practical.

This means:
- deployment should not rebuild source
- development and production should deploy the same package from the same run
- a different pipeline run must not be implicitly used for deployment unless explicitly configured as a pipeline resource or external artifact source

## Force And Manual Run Standard
Force flags are an operator escape hatch, not the normal path.

Recommended usage:
- Use PRs for validation only.
- Use merge-triggered runs for normal deployments.
- Use manual runs with force flags for edge cases such as initial deploys, deploy testing, or intentional environment exercises without opening extra PRs.

Examples in this repo include:
- `ForceDeployDev`
- `ForceDeployProd`
- `RunCd`

When adding or modifying force behavior:
- keep PR deploy protection in place
- prefer development force before production force
- preserve manual approval gates for production

## Approval And Promotion Standard
- Production stages should keep explicit approval or validation gates before deployment.
- If a pipeline has both development and production deployment stages, production should normally depend on successful development completion unless the pipeline is intentionally designed otherwise.

## Pipeline Authoring Notes
- Prefer in-pipeline tasks or direct CLI over introducing new `steps/*.yml` abstractions.
- If a pipeline is already being modernized, inline step templates when practical rather than extending the old template surface.
- Keep build/test/package logic explicit so PR and merge behavior is easy to reason about.

## Pipeline Change Rules
- Keep changes minimal and scoped to the requested pipeline behavior.
- Do not rename existing pipeline files unless explicitly requested.
- Preserve trigger, branch, and path filters unless a change request includes trigger updates.
- Preserve existing deployment conditions and approvals unless explicitly requested.

When modifying trigger behavior:
- Prefer enabling PR triggers only when the pipeline has a meaningful validation path.
- If a pipeline only deploys, add a validation-only PR stage before enabling PR triggers broadly.

When modifying deployment behavior:
- Favor artifact reuse over rebuilding inside deploy stages.
- Ensure development and production conditions clearly separate PR validation from post-merge deployment.

## Script Usage Rules
- Call scripts using repo-relative variables (for example $(scriptsPath)).
- Keep script arguments explicit; avoid hidden defaults in pipeline YAML when values are important.
- Prefer PowerShell@2 steps for script orchestration and variable export.

## Validation Expectations
When modifying pipeline YAML:
- verify the edited files still contain expected stages and job dependencies
- confirm variable names match between Get-Version output and dotnet build arguments
- confirm all script paths align with ci-common.yml variables
- confirm PR-triggered runs validate but do not deploy
- confirm deploy stages use artifacts from the current run instead of rebuilding
- confirm production approval gates still exist when they existed before
