param name string
param endpointResourceIds array

resource trafficManager 'Microsoft.Network/trafficmanagerprofiles@2022-04-01' = {
  name: name
  location: 'global'
  properties: {
    profileStatus: 'Enabled'
    trafficRoutingMethod: 'Priority'
    dnsConfig: {
      relativeName: name
      ttl: 30
    }
    monitorConfig: {
      protocol: 'HTTPS'
      port: 443
      path: '/'
      expectedStatusCodeRanges: [
        {
          min: 200
          max: 202
        }
        {
          min: 301
          max: 302
        }
      ]
    }
  }

  resource endpoints 'AzureEndpoints' = [for endpointResourceId in endpointResourceIds: {
    name: 'endpoint-${uniqueString(endpointResourceId)}'
    properties: {
      targetResourceId: endpointResourceId
      endpointStatus: 'Enabled'
    }
  }]
}

output trafficManagerUrl string = 'https://${trafficManager.properties.dnsConfig.fqdn}'
