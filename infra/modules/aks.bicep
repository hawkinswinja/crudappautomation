param aksClusterName string =  'Aks-${uniqueString(resourceGroup().id)}'
param nodeCount int = 2
param nodeVmSize string = 'standard_d2s_v3'
@allowed([
   'kubenet'
   'azure'
   'none'])
param aksClusterNetworkPlugin string = 'azure'
param aksClusterKubernetesVersion string = '1.31.2'
param aksSubnetId string
param aksClusterPodCidr string = '10.224.0.0/16'
param aksClusterServiceCidr string = '10.0.0.0/16'
param aksClusterDnsServiceIP string = '10.0.0.10'
param aksClusterLoadBalancerSku string = 'Standard'
param servicePrincipalClientId string
@description('Creates an azure container registry')
param acrCreate bool
@description('The name of the Azure Container Registry.')
param acrName string = 'acr${uniqueString(resourceGroup().id)}'
@description('The ID of the Application Gateway.')
param appGatewayId string


var location = resourceGroup().location


resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = if (acrCreate) {
  name: acrName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: aksClusterName
  location: location
  properties: {
    // nodeResourceGroup: aksNodeResourceGroupName
    enableRBAC: true
    kubernetesVersion: aksClusterKubernetesVersion
    dnsPrefix: aksClusterName
    servicePrincipalProfile: {
      clientId: servicePrincipalClientId
    }
    agentPoolProfiles: [
      {
        name: 'nodepool1'
        count: nodeCount
        vmSize: nodeVmSize
        osType: 'Linux'
        mode: 'System'
        vnetSubnetID: aksSubnetId
      }
    ]

    networkProfile: {
      networkPlugin: aksClusterNetworkPlugin
      podCidr: aksClusterPodCidr
      serviceCidr: aksClusterServiceCidr
      dnsServiceIP: aksClusterDnsServiceIP
      // dockerBridgeCidr: aksClusterDockerBridgeCidr
      // outboundType: aksClusterOutboundType
      loadBalancerSku: aksClusterLoadBalancerSku
      // loadBalancerProfile: json('null')
    }
    addonProfiles: {
      ingressApplicationGateway: (!empty(appGatewayId)) ? {
        enabled: true
        config: {
          applicationGatewayId: appGatewayId
        }
      } : {
        enabled: false
      }
      azureKeyvaultSecretsProvider: {
        enabled: true
      }
      // ingressApplicationGateway: {
      //   enabled: true
      //   config: {
      //     subnetId: appgwSubnetId
      //     gatewayName: 'appGateway'
      //   }
      // }
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource fluxAddon 'Microsoft.KubernetesConfiguration/extensions@2022-04-02-preview' =  {
  name: 'flux'
  scope: aksCluster
  properties: {
    extensionType: 'microsoft.flux'
    autoUpgradeMinorVersion: true
    releaseTrain: 'Stable'
    scope: {
      cluster: {
        releaseNamespace: 'flux-system'
      }
    }
    configurationProtectedSettings: {}
  }
}

output addonKeyvaultClientId string = aksCluster.properties.addonProfiles.azureKeyvaultSecretsProvider.identity.clientId
output acrUrl string = acr.properties.loginServer
output acrId string = acr.id
