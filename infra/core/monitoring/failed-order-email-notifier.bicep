param name string
param location string = resourceGroup().location
param mailingList string
param tags object = {}

// A manual step is needed after the connection is created to configure the connection string to the Service Bus Namespace.
resource serviceBusConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: 'servicebus-connection'
  location: location
  tags: tags
  properties: {
    api: {
      id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'servicebus')
    }
    displayName: 'servicebus-connection'
  }
}

// A manual step is needed after the connection is created to authorize the connection with the Outlook account.
resource outlookConnection 'Microsoft.Web/connections@2016-06-01' = {
  name: 'outlook-connection'
  location: location
  tags: tags
  properties: {
    api: {
      id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'outlook')
    }
    displayName: 'outlook-connection'
  }
}

resource failedOrderEmailNotifier 'Microsoft.Logic/workflows@2019-05-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        'mailing-list': {
          defaultValue: ''
          type: 'String'
        }
        '$connections': {
          defaultValue: {}
          type: 'Object'
        }
      }
      triggers: {
        'When_a_message_is_received_in_a_queue_(auto-complete)': {
          recurrence: {
            interval: 1
            frequency: 'Minute'
          }
          evaluatedRecurrence: {
            interval: 1
            frequency: 'Minute'
          }
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'servicebus\'][\'connectionId\']'
              }
            }
            method: 'get'
            path: '/@{encodeURIComponent(encodeURIComponent(\'order-items\'))}/messages/head'
            queries: {
              queueType: 'DeadLetter'
            }
          }
        }
      }
      actions: {
        'Send_an_email_(V2)': {
          runAfter: {}
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'outlook\'][\'connectionId\']'
              }
            }
            method: 'post'
            body: {
              To: '@parameters(\'mailing-list\')'
              Subject: 'eShopOnWeb - An order could not be processed'
              Body: '<p>An order could not be processed.<span>\n</span>Please check the attachment for details.</p>'
              Attachments: [
                {
                  Name: 'order-items.json'
                  ContentBytes: '@{triggerBody()?[\'ContentData\']}'
                }
              ]
              Importance: 'Normal'
            }
            path: '/v2/Mail'
          }
        }
      }
      outputs: {}
    }
    parameters: {
      '$connections': {
        value: {
          servicebus: {
            id: serviceBusConnection.properties.api.id
            connectionId: serviceBusConnection.id
            connectionName: serviceBusConnection.name
          }
          outlook: {
            id: outlookConnection.properties.api.id
            connectionId: outlookConnection.id
            connectionName: outlookConnection.name
          }
        }
      }
      'mailing-list': {
        value: mailingList
      }
    }
  }
}
