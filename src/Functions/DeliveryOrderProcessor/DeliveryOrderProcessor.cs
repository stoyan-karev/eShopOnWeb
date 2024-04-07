using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.eShopWeb.Functions.DeliveryOrderProcessor.Models;
using Microsoft.Azure.Cosmos;
using Microsoft.AspNetCore.Http;
using Microsoft.eShopWeb.Functions.Infrastructure;

namespace Microsoft.eShopWeb.Functions.DeliveryOrderProcessor;

public class DeliveryOrderProcessor
{
    private readonly CosmosClient _cosmosClient;

    public DeliveryOrderProcessor(CosmosClient cosmosClient)
    {
        _cosmosClient = cosmosClient;
    }

    [FunctionName("DeliveryOrderProcessor")]
    public async Task<IActionResult> Run(
        [HttpTrigger(AuthorizationLevel.Function, "post", Route = null)] HttpRequest request)
    {
        var deliveryOrderRequest = await request.ReadAsJsonAsync<DeliveryOrderRequest>();
        if (deliveryOrderRequest == null)
        {
            return new BadRequestObjectResult("Invalid delivery order");
        }

        var deliveryOrderToSave = new DeliveryOrder
        {
            Id = deliveryOrderRequest.OrderId.ToString(),
            OrderId = deliveryOrderRequest.OrderId,
            OrderItems = deliveryOrderRequest.OrderItems,
            FinalPrice = deliveryOrderRequest.FinalPrice,
            ShippingAddress = deliveryOrderRequest.ShippingAddress
        };

        var ordersContainer = await GetOrdersContainerAsync();
        await ordersContainer.CreateItemAsync(deliveryOrderToSave);

        return new OkObjectResult(deliveryOrderToSave);
    }

    private async Task<Container> GetOrdersContainerAsync()
    {
        var database = _cosmosClient.GetDatabase("DeliveryOrders");
        var containerResponse = await database.CreateContainerIfNotExistsAsync("Orders", "/id");

        return containerResponse.Container;
    }
}
