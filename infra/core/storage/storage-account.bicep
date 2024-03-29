param location string = resourceGroup().location

param name string

param tags object = {}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }
}

// Construct the connection string
var accountKey = storageAccount.listKeys().keys[0].value
var endpointSuffix = environment().suffixes.storage
var blobStorageConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${accountKey};EndpointSuffix=${endpointSuffix}'

output id string = storageAccount.id
output connectionString string = blobStorageConnectionString
