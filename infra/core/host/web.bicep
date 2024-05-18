param location string
param appName string
param planName string
param serviceName string
param tags object
param useStagingSlot bool = false
param orderItemsQueueName string
param orderItemsQueueConnection string

@secure()
param identityDbConnectionString string
@secure()
param catalogDbConnectionString string

param deliveryOrderProcessorUrl string
param deliveryOrderProcessorApiCode string

@secure()
param applicationInsightsConnection string

param keyVaultName string

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: planName
  location: location
  kind: 'linux'
  tags: tags
  sku: {
    name: 'S1'
    tier: 'Standard'
  }
  properties: {
    reserved: true
  }
}

resource appService 'Microsoft.Web/sites@2023-01-01' = {
  name: appName
  location: location
  kind: 'app,linux'
  tags: union(tags, { 'azd-service-name': serviceName })
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|8.0'
    }
    httpsOnly: true
  }

  resource appSettings 'config' = {
    name: 'appsettings'
    properties: {
      UseOnlyInMemoryDatabase: 'false'
      OrderItemsPublisher__QueueConnection: orderItemsQueueConnection
      OrderItemsPublisher__QueueName: orderItemsQueueName
      DeliveryOrderProcessor__BaseUri: deliveryOrderProcessorUrl
      DeliveryOrderProcessor__ApiCode: deliveryOrderProcessorApiCode
      APPLICATIONINSIGHTS_CONNECTION_STRING: applicationInsightsConnection
      ApplicationInsightsAgent_EXTENSION_VERSION: '~3'
    }
  }

  resource connectionStrings 'config' = {
    name: 'connectionstrings'
    dependsOn: [keyVault::accessPolicy]
    properties: {
      IdentityConnection: {
        value: identityDbConnectionString
        type: 'SQLAzure'
      }
      CatalogConnection: {
        value: catalogDbConnectionString
        type: 'SQLAzure'
      }
    }
  }

  resource stagingSlot 'slots' = if (useStagingSlot) {
    name: 'staging'
    location: location
    tags: tags
    properties: {
      serverFarmId: appServicePlan.id
      siteConfig: {
        linuxFxVersion: 'DOTNETCORE|8.0'
      }
      httpsOnly: true
    }
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName

  resource accessPolicy 'accessPolicies' = {
    name: 'add'
    properties: {
      accessPolicies: [
        {
          tenantId: subscription().tenantId
          objectId: appService.identity.principalId
          permissions: {
            secrets: ['get']
          }
        }
      ]
    }
  }
}

output url string = 'https://${appService.properties.defaultHostName}'
output appServiceId string = appService.id
output appServiceName string = appService.name
