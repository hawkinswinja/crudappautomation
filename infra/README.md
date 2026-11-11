# Infrastructure setup

This directory contains the Azure Bicep templates for the CRUD application. The
deployment is scoped to an Azure subscription and creates the resource groups,
virtual network, Application Gateway, AKS cluster, Azure Container Registry,
Azure App Service, Azure SQL Server databases, Key Vault, and Azure DevOps
agent-pool infrastructure described by `main.bicep`.

## Architecture diagram

![DevOpsAssessment](https://github.com/user-attachments/assets/75d52fdc-5fcf-4583-8567-e2576992f328)

## Prerequisites

Install and authenticate the Azure CLI:

```bash
az login
az account set --subscription "<subscription-id>"
az bicep install
```

The deploying identity needs permission to create subscription-level
deployments and resources in the target subscription. You also need:

- A globally unique Azure Container Registry name.
- An existing service principal client ID for the AKS cluster.
- An Azure DevOps organization and project if the `mdp` module is enabled
  (it is enabled by `main.bicep`).
- A strong SQL administrator password. Do not commit it to this repository.

## Configure parameters

Review `main.parameters.json` and change environment-specific values before
deploying:

| Parameter | Description |
| --- | --- |
| `Location` | Azure region for the application resource group |
| `ResourceGroupName` | Name of the application resource group |
| `acrName` | Globally unique ACR name |
| `aksClusterName` | AKS cluster name |
| `servicePrincipalClientId` | Existing service principal client ID used by AKS |
| `webAppName` | Globally unique App Service name |
| `webAppContainerImage` | Image path and tag in the ACR |
| `azdoUrl` | Azure DevOps organization URL |
| `azdoProject` | Azure DevOps project name |

`dbUserName`, `dbPassword`, and `dbNames` are declared in `main.bicep`.
`dbPassword` is secure and must be supplied at deployment time.

The default parameter file uses `acrCreate: true`, so the deployment creates
the registry. Set it to `false` only when the template is updated to reference
an existing registry appropriately.

## Validate the templates

Run these commands from the repository root:

```bash
az bicep build --file infra/main.bicep

az deployment sub what-if \
  --name "crudapp-infra" \
  --location "northeurope" \
  --template-file infra/main.bicep \
  --parameters @infra/main.parameters.json \
  --parameters \
    dbPassword="<strong-password>" \
    webAppContainerImage="nginx:v1"
```

Use the target location and image value for your environment. `what-if` shows
the resources Azure will create or change without applying them.

## Deploy

Deploy the complete infrastructure with:

```bash
az deployment sub create \
  --name "crudapp-infra" \
  --location "northeurope" \
  --template-file infra/main.bicep \
  --parameters @infra/main.parameters.json \
  --parameters \
    dbPassword="<strong-password>" \
    webAppContainerImage="<acr-name>.azurecr.io/<image>:<tag>"
```

The `ResourceGroupName`, `acrName`, and other values from the parameter file
can also be overridden on the command line:

```bash
az deployment sub create \
  --name "crudapp-infra" \
  --location "$LOCATION" \
  --template-file infra/main.bicep \
  --parameters @infra/main.parameters.json \
  --parameters \
    ResourceGroupName="$RESOURCE_GROUP_NAME" \
    acrName="$ACR_NAME" \
    webAppContainerImage="$AUTH_IMAGE" \
    dbPassword="$DB_PASSWORD"
```

The deployment creates two resource groups:

- `<ResourceGroupName>` for the application infrastructure.
- `<ResourceGroupName>-azdo` for the Azure DevOps Dev Center and agent pool.

## Verify the deployment

Check the deployment and resources:

```bash
az deployment sub show \
  --name "crudapp-infra" \
  --query properties.provisioningState \
  --output tsv

az group list \
  --query "[?starts_with(name, '<resource-group-name>')].{name:name,location:location}" \
  --output table

az aks get-credentials \
  --resource-group "<resource-group-name>" \
  --name "<aks-cluster-name>"

kubectl get nodes
```

Use the same deployment name when checking a deployment from another
environment.

## Azure DevOps pipeline

`.workflows/deploy-bicep.yml` runs the same subscription deployment from the
`infra` directory. Before running it, create an Azure Resource Manager service
connection and a variable group named `AutomationDemo` containing the values
used by the pipeline, including the secret `dbpassword`.

The pipeline currently overrides `ResourceGroupName`, `acrName`,
`webAppContainerImage`, and `dbPassword`. Keep secrets in Azure DevOps secret
variables or another approved secret store; never add them to
`main.parameters.json` or commit them to source control.

## Related files

- `main.bicep` - subscription-level entry point and module wiring
- `main.parameters.json` - non-secret environment defaults
- `modules/network.bicep` - virtual network and subnets
- `modules/aks.bicep` - AKS, ACR, Key Vault, and cluster add-ons
- `modules/appgw.bicep` - Application Gateway and public IP
- `modules/appservice.bicep` - Linux App Service and container settings
- `modules/sqlserver.bicep` - SQL Server and application databases
- `modules/mdp.bicep` - Azure DevOps Dev Center and agent pool
