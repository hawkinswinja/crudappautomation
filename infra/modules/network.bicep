param VnetName string = '${resourceGroup().name}-vnet-${resourceGroup().location}'
param VnetAddressPrefix string = '10.224.0.0/12'
param subnets object = {
  aksSubnet: {
    addressprefix: '10.225.1.0/24'
    public: false
    delegation: false
  }
  publicSubnet: {
    addressprefix: '10.225.2.0/24'
    public: true
    delegation: false
  }
  webAppSubnet: {
    addressprefix: '10.225.3.0/24'
    public: false
    delegation: true
    delegationName: 'delegationToWebApp'
    serviceName: 'Microsoft.Web/serverFarms'
  }
}

var location = resourceGroup().location


// resource privateNSG 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
//   name: 'private-${VnetName}-nsg'
//   location: location
//   properties: {
//     securityRules: []
//   }
// }

// resource publicNSG 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
//   name: 'public-${VnetName}-nsg'
//   location: location
//   properties: {
//     securityRules: [
//       {
//         name: 'AllowSSHInbound'
//         properties: {
//           priority: 300
//           protocol: '*'
//           sourcePortRange: '*'
//           destinationPortRange: '22'
//           sourceAddressPrefix: 'Internet'
//           destinationAddressPrefix: 'VirtualNetwork'
//           access: 'Allow'
//           direction: 'Inbound'
//         }
//       }
//     ]
//   }
// }

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: VnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        VnetAddressPrefix
      ]
    }
    subnets: [for subnet in items(subnets): {
        name: subnet.key
        properties: {
          addressPrefix: subnet.value.addressprefix
          delegations: subnet.value.delegation ? [
            {
              name: subnet.value.delegationName
              properties: {
                serviceName: subnet.value.serviceName
              }
            }
          ] : []
        }
      }
    ]
  }
}


output publicsubnetID string = vnet.properties.subnets[1].id
output akssubnetID string = vnet.properties.subnets[0].id
output webAppSubnetID string = vnet.properties.subnets[2].id
// output nsgID string = publicNSG.id
