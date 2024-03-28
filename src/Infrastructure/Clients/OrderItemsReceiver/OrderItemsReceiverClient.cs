using System;
using System.Net.Http;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.Extensions.Options;

namespace Microsoft.eShopWeb.Infrastructure.Clients.OrderItemsReceiver;

public class OrderItemsReceiverClient : IOrderItemsReceiverClient
{
    private readonly HttpClient _httpClient;

    public OrderItemsReceiverClient(HttpClient httpClient, IOptions<OrderItemsReceiverConfiguration> options)
    {
        _httpClient = httpClient;
        _httpClient.BaseAddress = new Uri(options.Value.BaseUri);
        if (!string.IsNullOrEmpty(options.Value.ApiCode))
        {
            _httpClient.DefaultRequestHeaders.Add("x-functions-key", options.Value.ApiCode);
        }
    }

    public async Task SendRequest(OrderRequest orderRequest)
    {
        // Using StringContent correctly sets the Content-Length header 
        var serializedOrderRequest = JsonSerializer.Serialize(orderRequest);
        var content = new StringContent(serializedOrderRequest, System.Text.Encoding.UTF8, "application/json");
        var response = await _httpClient.PostAsync("api/OrderItemsReceiver", content);

        response.EnsureSuccessStatusCode();
    }
}

