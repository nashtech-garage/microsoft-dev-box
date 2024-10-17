// Variables
param devCenterName string

param region string

// DevCenter Resource
resource devCenter 'Microsoft.DevCenter/devcenters@2023-04-01' = {
  name: devCenterName
  location: region
}

// Output Dev Box Details
output devCenterName string = devCenter.name

