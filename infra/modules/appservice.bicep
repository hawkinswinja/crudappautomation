@description('The name of the App Service Plan')
param appServicePlanName string

@description('The name of the Web App')
param webAppName string
@description('The login server of the container registry')
param registry string
@description('The resource id of the container registry')
param registryId string
// @description('The login username for the container registry')
// param registryUserName string
// @description('The login password for the container registry')
// @secure()
// param registryPassword string
@description('The location for the resources')
param location string = resourceGroup().location
@description('The subnet id to provision web app')
param appSubnetID string
@description('The SKU of the App Service Plan. Defaults to Basic B1')
param appServicePlanSku object = {
  name: 'B1'
  tier: 'Basic'
  size: 'B1'
  capacity: 1
}

@description('The container image to deploy')
param containerImage string
param dbUserName string = 'azureuser'
@secure()
param dbPassword string
param sqlServerurl string
param dbName string = 'auth'


var registryUserName = listCredentials(registryId, '2023-07-01').username
var registryPassword = listCredentials(registryId, '2023-07-01').passwords[0].value



resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  kind: 'linux'
  sku: appServicePlanSku
  properties: {
    reserved: true
  }
}

resource webApp 'Microsoft.Web/sites@2022-03-01' = {
  name: webAppName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    publicNetworkAccess: 'Disabled'
    virtualNetworkSubnetId: appSubnetID
    vnetImagePullEnabled: true
    siteConfig: {
      httpLoggingEnabled: true
      cors: {
        allowedOrigins: [
          '*'
        ]
      }
      appSettings: [
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${registry}'
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_USERNAME'
          value: registryUserName
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_PASSWORD'
          value: registryPassword
        }
        {
          name: 'WEBSITES_CONTAINER_START_TIME_LIMIT'
          value: '1800'
        }
        {
          name: 'WEBSITES_CONTAINER_STOP_TIME_LIMIT'
          value: '1800'
        }
        {
          name: 'DOCKER_ENABLE_CI'
          value: 'true'
        }
        {
          name: 'ConnectionStrings__DefaultConnection'
          value: 'Server=tcp:${sqlServerurl},1433;Initial Catalog=${dbName};Persist Security Info=False;User ID=${dbUserName};Password=${dbPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
        }
      ]
      linuxFxVersion: 'DOCKER|${registry}/${containerImage}'
    }
  }
  kind: 'app,linux'
}
