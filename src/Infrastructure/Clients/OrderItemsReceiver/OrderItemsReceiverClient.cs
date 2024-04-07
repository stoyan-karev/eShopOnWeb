using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.Extensions.Options;

namespace Microsoft.eShopWeb.Infrastructure.Clients.OrderItemsReceiver;

public class OrderItemsReceiverClient : IOrderItemsReceiverClient
{
    private readonly HttpClient _httpClient;

    public OrderItemsReceiverClient(HttpClient httpClient, IOptions<OrderItemsReceiverConfiguration> options)
    {
        _httpClient = httpClient;
        _httpClient.AddAzureFunctionConfiguration(options.Value.BaseUri, options.Value.ApiCode);
    }

    public async Task SendAsync(OrderRequest orderRequest)
    {
        await _httpClient.PostJsonAsync("api/OrderItemsReceiver", orderRequest);
    }
}

