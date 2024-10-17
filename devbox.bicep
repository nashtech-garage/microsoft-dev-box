// Variables
param devCenterName string
param projectName string
param devBoxName string
param region string
param imageId string


// DevCenter Resource
resource devCenter 'Microsoft.DevCenter/devcenters@2023-04-01' = {
  name: devCenterName
  location: region
}


// Project Resource
resource project 'Microsoft.DevCenter/projects@2023-04-01' = {
  name: projectName
  location: region
  properties: {
    devCenterId: devCenter.id
  }
}

// DevboxDefinition Resource
resource devboxDefinition 'Microsoft.DevCenter/devcenters/devboxdefinitions@2023-04-01' = {
  name: '${devCenterName}-devboxdef'
  location: region
  parent: devCenter
  properties: {
    hibernateSupport: 'Disabled'
    imageReference: {
      id: imageId
    }
    osStorageType: 'string'
    sku: {
      capacity: 1
      family: 'D'
      name: 'Standard_DS2_v2'
      size: 'Standard_DS2_v2'
      tier: 'Standard'
    }
  }
}


// Network Resource (Virtual Network)
resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: '${projectName}-vnet'
  location: region
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: '${projectName}-vnet-sub'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

resource networkConnection 'Microsoft.DevCenter/networkConnections@2023-04-01' = {
  name: '${devBoxName}-network-connection'
  location: region
 
  properties: {
    domainJoinType: 'AzureADJoin'   
    subnetId: vnet.properties.subnets[0].id
  }
}

// Dev Box Pool Resource
resource devBoxPool 'Microsoft.DevCenter/projects/pools@2023-04-01' = {
  name: '${devBoxName}-pool'
  location: region
  parent: project
  properties: {
    devBoxDefinitionName: '${devCenterName}-devboxdef'
    licenseType: 'Windows_Client'
    localAdministrator: 'Enabled'
    networkConnectionName: '${devBoxName}-network-connection'
    stopOnDisconnect: {
      gracePeriodMinutes: 1
      status: 'Disabled'
    }
  }
}

// Output Dev Box Details
output devCenterName string = devCenter.name
output devBoxPoolName string = devBoxPool.name
