# Azure DevOps Pipelines YAML for Azure Deployments
<sup>This repo is a starting point for using Azure DevOps Pipelines YAML files to automate cloud infrastructure, building source, unit-testing source, deploying source and running external integration tests.</sup> <br>

This is a simple Azure DevOps YAML template for [Azure DevOps Pipelines](https://docs.microsoft.com/en-us/azure/devops//get-started/what-is-azure-pipelines?view=azure-devops)

This repository relates to the following activities:
* Deploy [Enterprise-scale Architecture Landing Zones](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/#:~:text=Azure%20landing%20zones%20are%20the%20output%20of%20a,as%20a%20service%20or%20platform%20as%20a%20service.)
* Deploy Azure cloud infrastructure
* Building source with dotnet build
* Unit-testing source with dotnet tests
* Deploying source to cloud infrastructure
* And running external integration tests

#### /pipelines folder (YAML)
Path | Item | Contents
--- | --- | ---
/pipelines | - | Contains all scripts, steps, variables and main-pipeline files
/pipelines | rg-PRODUCT-infrastructure.yml | Main-pipeline file to deploy cloud landing zone, and infrastructure
/pipelines | rg-PRODUCT-src.yml | Main-pipeline file to build/test/deply src, unit tests and integration tests

#### /steps folder (YAML)
Path | Item | Contents
--- | --- | ---
/steps | - | Azure DevOps Pipelines step templates.
/steps | func-build-steps.yml | Azure Functions source code build, and package
/steps | func-deploy-steps.yml |  Azure Functions source code deploy to cloud infrastructure
/steps | xxx-infrastructure-steps.yml | Azure ESA infrastructure deploy
/steps | integration-test-steps.yml | Runs external integration tests against src
/steps | logic-infrastructure-steps.yml | Azure Logic Apps deploy to cloud infrastructure
/steps | landingzone-infrastructure-steps.yml | Azure ESA Landing Zone deploy
/steps | nuget-deploy-external-steps.yml | NuGet.org package (.nupkg) deploy
/steps | nuget-deploy-internal-steps.yml | Private NuGet Feed (.nupkg) deploy
/steps | dotnet-build-steps.yml | Source code (/src) build with dotnet build
/steps | dotnet-test-steps.yml |  Source code (/src) unit-test with dotnet test

#### /pipeline/variables (YAML)
Path | Item | Contents
--- | --- | ---
/variables | - | Variables (non-secret only) for the Azure landing zone, Azure infrastructure and NuGet packages.
/variables | common.yml | Common variables to all pipelines
/variables | development.yml | Development environment-specific variables
/variables | production.yml | Production environment-specific variables

#### /scripts folder (PowerShell)
Path | Item | Contents
--- | --- | ---
/scripts | - | Contains Azure DevOps Pipelines YAML files, Windows PowerShell scripts, and variables to support Azure DevOps Pipelines YAML Pipelines.
/scripts | System.psm1 | Powershell helpers for system-level functions
/scripts | Set-Version.ps1 | Sets version per MAJOR.MINOR.REVISION.BUILD methodology
/scripts | Get-AzureAd.ps1 | Manual script for getting Azure AD information
/scripts | New-SelfSignedCert.ps1 | Manual script for generating a self-signed certificate

#### Azure Services used in these repositories
Azure Service | Purpose
:---------------------:| --- 
[Azure Cosmos DB](https://azure.microsoft.com/en-us/services/cosmos-db/)| NoSQL database where original content as well as processing results are stored.
[Azure Functions](https://azure.microsoft.com/en-us/try/app-service/)|Code blocks that analyze the documents stored in the Azure Cosmos DB.
[Azure Service Bus](https://azure.microsoft.com/en-us/services/service-bus/)|Service bus queues are used as triggers for durable Azure Functions.
[Azure Storage](https://azure.microsoft.com/en-us/services/storage/)|Holds images from articles and hosts the code for the Azure Functions.
[Azure Logic App](https://azure.microsoft.com/en-us/services/logic-apps/)|Cloud workflow orchestrator, includes activities in the form of Connectors
