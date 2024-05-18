param location string = resourceGroup().location
param tags object = {}
param name string
param serviceName string
param keyVaultName string

@secure()
param applicationInsightsConnection string

@secure()
param storageAccountConnection string

@secure()
param deliveryOrdersDbConnectionString string

@secure()
param orderItemsQueueConnection string

resource hostingPlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: 'plan-${name}'
  location: location
  tags: tags
  kind: 'linux'
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {
    reserved: true
  }
}

resource functionApp 'Microsoft.Web/sites@2021-03-01' = {
  name: name
  location: location
  tags: union(tags, { 'azd-service-name': serviceName })
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: storageAccountConnection
        }
        {
          name: 'OrderItemsStorage'
          value: storageAccountConnection
        }
        {
          name: 'OrderItemsQueueConnection'
          value: orderItemsQueueConnection
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: storageAccountConnection
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: '${toLower(name)}-${uniqueString(name)}'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsightsConnection
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'DeliveryOrdersConnection'
          value: deliveryOrdersDbConnectionString
        }
        // Workaround for https://github.com/Azure/azure-dev/issues/3162#issuecomment-1937806202
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'False'
        }
      ]
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
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
          objectId: functionApp.identity.principalId
          permissions: {
            secrets: ['get']
          }
        }
      ]
    }
  }
}

output url string = 'https://${functionApp.properties.defaultHostName}'
#disable-next-line outputs-should-not-contain-secrets
output accessKey string = listKeys('${functionApp.id}/host/default', '2021-03-01').functionKeys.default
