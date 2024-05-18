param name string = 'order-items'
param keyVaultName string
param serviceBusNamespace string

resource namespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' existing = {
  name: serviceBusNamespace
}

resource orderItemsQueue 'Microsoft.ServiceBus/namespaces/queues@2022-10-01-preview' = {
  name: name
  parent: namespace
  properties: {
    lockDuration: 'PT5M'
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: false
    requiresSession: false
    deadLetteringOnMessageExpiration: true
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    maxDeliveryCount: 3
    enableBatchedOperations: false
  }

  resource listenSharedAccessKey 'authorizationRules' = {
    name: 'ListenSharedAccessKey'
    properties: {
      rights: [
        'Listen'
      ]
    }
  }

  resource sendSharedAccessKey 'authorizationRules' = {
    name: 'SendSharedAccessKey'
    properties: {
      rights: [
        'Send'
      ]
    }
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName

  resource listenConnectionStringSecret 'secrets' = {
    name: 'order-items-listen-connection-string'
    properties: {
      value: orderItemsQueue::listenSharedAccessKey.listKeys().primaryConnectionString
    }
  }

  resource sendConnectionStringSecret 'secrets' = {
    name: 'order-items-send-connection-string'
    properties: {
      value: orderItemsQueue::sendSharedAccessKey.listKeys().primaryConnectionString
    }
  }
}

output listenConnectionString string = '@Microsoft.KeyVault(SecretUri=${keyVault::listenConnectionStringSecret.properties.secretUriWithVersion})'
output sendConnectionString string = '@Microsoft.KeyVault(SecretUri=${keyVault::sendConnectionStringSecret.properties.secretUriWithVersion})'
output name string = orderItemsQueue.name
