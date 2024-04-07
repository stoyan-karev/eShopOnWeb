using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.Extensions.Options;

namespace Microsoft.eShopWeb.Infrastructure.Clients.DeliveryOrderProcessor;

public class DeliveryOrderProcessorClient : IDeliveryOrderProcessorClient
{
    private readonly HttpClient _httpClient;

    public DeliveryOrderProcessorClient(HttpClient httpClient, IOptions<DeliveryOrderProcessorConfiguration> options)
    {
        _httpClient = httpClient;
        _httpClient.AddAzureFunctionConfiguration(options.Value.BaseUri, options.Value.ApiCode);
    }

    public async Task SendAsync(DeliveryOrder deliveryOrder)
    {
        var response = await _httpClient.PostJsonAsync("api/DeliveryOrderProcessor", deliveryOrder);
    }
}
