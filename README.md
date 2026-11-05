# CRUD App Automation

This repository contains a containerized CRUD application and the infrastructure and Azure DevOps pipeline definitions used to build and deploy it on Azure.

## What is included

| Component | Technology | Purpose |
| --- | --- | --- |
| `application/view` | React 18, Vite, NGINX | Browser UI for authentication and product CRUD operations |
| `application/api` | Laravel 11, PHP 8.3 | Product API |
| `application/Authentication` | ASP.NET Core 8, ASP.NET Identity, Entity Framework Core | Registration, login, and token-based authentication |
| `application/docker-compose.yaml` | Docker Compose | Local multi-container development |
| `infra` | Azure Bicep | Resource group, network, ACR, AKS, App Gateway, App Service, SQL Server, and Azure DevOps infrastructure |
| `kustomize` | Kubernetes manifests | Optional deployment of the API and UI to AKS |
| `.workflows` | Azure Pipelines YAML | Image builds and Bicep deployment |

The Laravel API uses a SQL Server-compatible Docker image for the Azure-oriented build (`Dockerfile-sql-srv`). The local Compose file also includes MySQL for development. The authentication service is configured to use SQL Server by default.

## Repository layout

```text
.
├── .workflows/                 # Azure DevOps pipeline definitions
├── application/
│   ├── api/                    # Laravel product API
│   ├── Authentication/         # ASP.NET Core authentication service
│   ├── view/                   # React frontend
│   └── docker-compose.yaml     # Local containers
├── infra/                      # Azure Bicep templates and parameters
└── kustomize/                  # AKS manifests
```

## Prerequisites

For local development, install:

- Git
- Docker Desktop with Docker Compose
- Node.js 20+ and npm (for running the frontend outside Docker)
- PHP 8.2+ and Composer (for running the Laravel API outside Docker)
- .NET 8 SDK (for running authentication outside Docker)
- SQL Server and/or MySQL, depending on the service being run

For Azure DevOps, you also need:

- An Azure subscription and permission to create subscription- and resource-group-scoped resources
- An Azure DevOps organization and project
- An Azure Resource Manager service connection
- An Azure DevOps variable group named `AutomationDemo`
- Either the generated self-hosted pool or a Microsoft-hosted `ubuntu-latest` agent
- An Azure Container Registry for the image build pipelines

## Run locally with Docker Compose

From the repository root:

```bash
cd application
cp api/example.env api/.env
docker compose up --build
```

The Compose file starts:

- React/NGINX frontend at <http://localhost:8080>
- Laravel API container
- ASP.NET Core authentication container
- MySQL container

Set the Compose variables before starting the stack. For example:

```bash
export DB_DATABASE=crud
export DB_USERNAME=cruduser
export DB_PASSWORD=change-me
export DB_CONNECTION_STRING='Server=host.docker.internal;Database=auth;User Id=sa;Password=change-me;TrustServerCertificate=True'
docker compose up --build
```

Use a strong local password and do not commit a `.env` file or credentials.

## Run services without Docker

### React frontend

```bash
cd application/view
npm ci
npm run dev
```

### Laravel API

```bash
cd application/api
composer install
cp example.env .env
php artisan key:generate
# Update the DB_* values in .env
php artisan serve
```

### Authentication service

```bash
cd application/Authentication
dotnet restore
# Update ConnectionStrings:DefaultConnection in appsettings.json
dotnet ef database update
dotnet run
```

The authentication service exposes Swagger in development. The frontend and API connection URLs may need to be updated in `application/view/src/http.js` and `application/view/src/components/product/Service.js` when services are not running behind the same reverse proxy.

## Azure DevOps setup

### 1. Import the repository

1. Push or mirror this repository into Azure Repos, or connect the Azure DevOps project to the GitHub repository.
2. In **Pipelines**, choose **New pipeline**.
3. Select the repository and choose **Existing Azure Pipelines YAML file**.
4. Import these files one at a time:
   - `.workflows/deploy-bicep.yml`
   - `.workflows/api-build-pipeline.yml`
   - `.workflows/auth-build-pipeline.yml`
   - `.workflows/view-build-pipeline.yml`
5. Save each pipeline with a descriptive name.

The build pipelines run when files under their respective application directory change. The Bicep pipeline runs when files under `infra` change on the `master` branch.

### 2. Create the Azure service connection

Create an **Azure Resource Manager** service connection in **Project settings > Service connections**. Grant it permission to be used by the imported pipelines and use its name as the `azureServiceConnection` pipeline parameter. The checked-in default is `plscont`; change that default or override it when manually running a pipeline.

The service principal used by the Bicep deployment must have enough access to create subscription-level deployments and the resources in the target subscription.

### 3. Create the variable group

Create **Pipelines > Library > Variable groups > AutomationDemo** and add the variables referenced by the YAML files:

| Variable | Used by | Notes |
| --- | --- | --- |
| `location` | Bicep deployment | Azure region, for example `northeurope` |
| `rgname` | Bicep deployment | Target resource group name |
| `acrName` | All image pipelines and Bicep | Globally unique ACR name |
| `crud-api-service` | API image pipeline | API image repository name |
| `crud-auth-service` | Auth image pipeline and Bicep | Authentication image repository/name |
| `crud-ui-service` | UI image pipeline | Frontend image repository name |
| `dbpassword` | Bicep deployment | Mark this variable secret |

The Bicep parameter file also contains project-specific values such as `aksClusterName`, `webAppName`, `azdoUrl`, and `azdoProject`. Review and update `infra/main.parameters.json` before deploying. Do not commit passwords, tokens, or other secrets.

### 4. Configure the agent

The image pipelines default to the self-hosted pool `DevOpsAssessment-agentpool` and require Docker. Choose one of these approaches:

- Deploy the infrastructure pipeline first and use the generated pool, then keep `useSelfHostedAgent: true`.
- Run the image pipelines with `useSelfHostedAgent: false` to use Microsoft-hosted `ubuntu-latest`.
- Change `agentPoolName` to an existing compatible self-hosted pool.

The Bicep module `infra/modules/mdp.bicep` can provision an Azure DevOps-connected agent pool, but the organization URL and project name must match the target Azure DevOps project.

### 5. Deploy infrastructure

Run **Deploy Bicep files** after validating the parameters and variable group. It executes a subscription-scoped deployment:

```bash
az login
az account set --subscription "<subscription-id>"
az deployment sub create \
  --location "$LOCATION" \
  --template-file infra/main.bicep \
  --parameters @infra/main.parameters.json \
  --parameters ResourceGroupName="$RG_NAME" \
               acrName="$ACR_NAME" \
               webAppContainerImage="$AUTH_IMAGE" \
               dbPassword="$DB_PASSWORD"
```

The pipeline supplies these values through the `AutomationDemo` variable group. Review `infra/main.bicep` for the complete required parameter set and adjust `main.parameters.json` or the pipeline before the first run.

### 6. Build and push images

After the ACR exists and the agent can run Docker, run the three image pipelines:

1. **Build and Push api Image**
2. **Build and Push Auth Image**
3. **BuildAndPushViewImage**

Each pipeline logs in with `az acr login`, builds from its service directory, and pushes a timestamped tag to:

```text
<acrName>.azurecr.io/<service-name>:<yyyyMMddHHmm>
```

Record the resulting image tags for the deployment stage. The current YAML files build and push images; they do not automatically update the Kustomize image tags.

## Deploy to AKS with Kustomize

The `kustomize` directory contains the namespace, API, UI, ingress, autoscaling, and Key Vault CSI resources. Before applying it:

1. Replace example image names and tags in the deployment manifests or add an `images` section to `kustomize/kustomization.yaml`.
2. Configure the Key Vault name, tenant ID, managed identity, and secret names in `crudapi-secrets.yaml` for the target subscription.
3. Confirm the AKS cluster context.

Example:

```bash
az aks get-credentials \
  --resource-group "<resource-group>" \
  --name "<aks-cluster-name>"

kubectl apply -k kustomize/
kubectl -n crudapp get pods,services,ingress
```

The checked-in secret provider manifest contains environment-specific identifiers and must be reviewed before use in another subscription or environment.

## Useful commands

```bash
# Validate Bicep
az bicep build --file infra/main.bicep

# Validate the frontend
cd application/view
npm ci
npm run lint
npm run build

# Build local images
cd application
docker compose build
```

## Security notes

- Store database passwords and service connection credentials in Azure DevOps secret variables, Key Vault, or another approved secret store.
- Do not commit `.env` files, production connection strings, kubeconfig files, or access tokens.
- Review the permissive development CORS policy and the sample Kubernetes identity and Key Vault values before exposing the application publicly.
