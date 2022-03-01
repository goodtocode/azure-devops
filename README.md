# azure-devops - Starter Azure DevOps Template
<sup>azure-devops Starter Azure DevOps Template is a starting point for using Azure DevOps pipeline YML files to automate cloud infrastructure, building source, unit-testing source, deploying source and running external integration tests.</sup> <br>

This is a simple Azure DevOps YML template for [Azure DevOps Pipelines](https://docs.microsoft.com/en-us/azure/devops/pipelines/get-started/what-is-azure-pipelines?view=azure-devops)

This template contains the following operations:
* Deploy [Enterprise-scale Architecture Landing Zones](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/#:~:text=Azure%20landing%20zones%20are%20the%20output%20of%20a,as%20a%20service%20or%20platform%20as%20a%20service.)
* Deploy Azure cloud infrastructure
* Building source with dotnet build
* Unit-testing source with dotnet tests
* Deploying source to cloud infrastructure
* And running external integration tests

#### /pipelines Contents
Path | Item | Contents
--- | --- | ---
pipelines | - | Contains all scripts, steps, variables and main-pipeline files
pipelines | COMPANY-rg-PRODUCT-infrastructure.yml | Main-pipeline file to deploy ONLY: cloud landing zone, and infrastructure
pipelines | COMPANY-rg-PRODUCT-src.yml | Main-pipeline file to build/test/deply ALL elements: landing zone, infrastructure, src, unit tests and integration tests
pipelines | COMPANY-rg-PRODUCT-tests.yml | Main-pipeline file to test ONLY: External integration tests

#### /pipeline/scripts YML Files
Path | Item | Contents
--- | --- | ---
pipelines/scripts | - | Contains Azure DevOps YML files, Windows PowerShell scripts, and variables to support Azure DevOps YML Pipelines.
pipelines/scripts | Helpers.Code.psm1 | Powershell helpers for code functions
pipelines/scripts | Helpers.System.psm1 | Powershell helpers for system-level functions
pipelines/scripts | Set-Version.ps1 | Sets version per MAJOR.MINOR.REVISION.BUILD methodology
pipelines/scripts/get-azuread | Get-AzureAd.ps1 | Manual script for getting Azure AD information
pipelines/scripts/new-selfsignedcert | New-SelfSignedCert.ps1 | Manual script for generating a self-signed certificate

#### /pipeline/steps YML Files
Path | Item | Contents
--- | --- | ---
pipelines/steps | - | Azure DevOps Pipeline step templates.
pipelines/steps | func-build-steps.yml | Azure Functions source code build, and package
pipelines/steps | func-deploy-steps.yml |  Azure Functions source code deploy to cloud infrastructure
pipelines/steps | infrastructure-deploy-steps.yml | Azure ESA infrastructure deploy
pipelines/steps | integration-test-steps.yml | Runs external integration tests against src
pipelines/steps | logic-deploy-steps.yml | Azure Logic Apps deploy to cloud infrastructure
pipelines/steps | lz-deploy-steps.yml | Azure ESA Landing Zone deploy
pipelines/steps | nuget-deploy-external-steps.yml | NuGet.org package (.nupkg) deploy
pipelines/steps | nuget-deploy-internal-steps.yml | Azure DevOps Feed (.nupkg) deploy
pipelines/steps | dotnet-build-steps.yml | Source code (/src) build with dotnet build
pipelines/steps | dotnet-test-steps.yml |  Source code (/src) unit-test with dotnet test

#### /pipeline/variables YML Files
Path | Item | Contents
--- | --- | ---
pipelines/variables | - | Variables (non-secret only) for the Azure landing zone, Azure infrastructure and NuGet packages.
pipelines/variables | common.yml | Common variables to all pipelines
pipelines/variables | development.yml | Development environment-specific variables
pipelines/variables | production.yml | Production environment-specific variables

#### Azure Services used in these repositories
Azure Service | Purpose
:---------------------:| --- 
[Azure Cosmos DB](https://azure.microsoft.com/en-us/services/cosmos-db/)| NoSQL database where original content as well as processing results are stored.
[Azure Functions](https://azure.microsoft.com/en-us/try/app-service/)|Code blocks that analyze the documents stored in the Azure Cosmos DB.
[Azure Service Bus](https://azure.microsoft.com/en-us/services/service-bus/)|Service bus queues are used as triggers for durable Azure Functions.
[Azure Storage](https://azure.microsoft.com/en-us/services/storage/)|Holds images from articles and hosts the code for the Azure Functions.

> <b> Note </b> This design uses the service collection extensions, dependency inversion, queue notification, and serverless patterns for simplicity. While these are useful patterns, this is not the only pattern that can be used to accomplish this data flow.
>
> [Azure Service Bus Topics](https://docs.microsoft.com/en-us/azure/service-bus-messaging/service-bus-dotnet-how-to-use-topics-subscriptions) could be used which would allow processing different parts of the article in a parallel as opposed to the serial processing done in this example. Topics would be useful if article inspection processing time is critical.  A comparison between Azure Service Bus Queues and Azure Service Bus Topics can be found [here](https://docs.microsoft.com/en-us/azure/service-bus-messaging/service-bus-dotnet-how-to-use-topics-subscriptions).
>
>Azure functions could also be implemented in an [Azure Logic App](https://azure.microsoft.com/en-us/services/logic-apps/).  However, with parallel processing the user would have to implement record-level locking such as [Redlock](https://redis.io/topics/distlock) until Cosmos DB supports [partial document updates](https://feedback.azure.com/forums/263030-azure-cosmos-db/suggestions/6693091-be-able-to-do-partial-updates-on-document). 
>
>A comparison between durable functions and Logic apps can be found [here](https://docs.microsoft.com/en-us/azure/azure-functions/functions-compare-logic-apps-ms-flow-webjobs).

# Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.microsoft.com.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.