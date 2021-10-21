@minLength(3)
@maxLength(10)
@description('project short name')
param projectName string

@description('Location for all resources.')
param location string = resourceGroup().location


var acrName = '${projectName}cr'
var replicaLocation = 'northeurope'

// container registry and replication
resource cr 'Microsoft.ContainerRegistry/registries@2019-12-01-preview' = {
  name: acrName
  location: location
  tags: {
    displayName: 'Container Registry'
    'container.registry': acrName
  }
  sku: {
    name: 'Premium'
  }
  properties: {
    adminUserEnabled: false
  }
}
resource crreplica 'Microsoft.ContainerRegistry/registries/replications@2019-12-01-preview' = {
  name: '${acrName}/${replicaLocation}'
  location: replicaLocation
  properties: {
  }
  dependsOn:[
    cr
  ]
}
