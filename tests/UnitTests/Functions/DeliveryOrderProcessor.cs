using Microsoft.AspNetCore.Http;
using Xunit;
using NSubstitute;
using Microsoft.AspNetCore.Mvc;
using Microsoft.eShopWeb.Functions.DeliveryOrderProcessor.Models;
using System.Text;
using Microsoft.Azure.Cosmos;
using Microsoft.eShopWeb.Functions.DeliveryOrderProcessor;
using Newtonsoft.Json;


namespace Microsoft.eShopWeb.UnitTests.Functions;

public class DeliveryOrderProcessorTests
{
    [Fact]
    public async Task DeliveryOrderProcessor_Run_Success()
    {
        var deliveryOrderRequest = new DeliveryOrderRequest
        {
            OrderId = 1,
            OrderItems = [
                new() { ItemId = 1, Quantity = 1 }
            ],
            FinalPrice = 1,
            ShippingAddress = new Address
            {
                City = "Seattle",
                State = "WA",
                ZipCode = "98101",
                Street = "123 Main St",
                Country = "USA"
            }
        };

        var request = Substitute.For<HttpRequest>();
        request.Body.Returns(new MemoryStream(Encoding.UTF8.GetBytes(JsonConvert.SerializeObject(deliveryOrderRequest))));
        var cosmosClient = Substitute.For<CosmosClient>();
        var deliveryOrderProcessor = new DeliveryOrderProcessor(cosmosClient);

        var result = await deliveryOrderProcessor.Run(request);

        Assert.IsType<OkObjectResult>(result);
    }

    [Fact]
    public async Task DeliveryOrderProcessor_Run_InvalidRequest()
    {
        var badDeliveryOrderRequest = new
        {
            OrderId = null as int?,
            OrderItems = null as List<OrderItem>,
            FinalPrice = null as decimal?,
            ShippingAddress = new
            {
                City = "Seattle",
                ZipCode = "98101",
                Street = "123 Main St",
                Country = "USA"
            }
        };

        var request = Substitute.For<HttpRequest>();
        request.Body.Returns(new MemoryStream(Encoding.UTF8.GetBytes(JsonConvert.SerializeObject(badDeliveryOrderRequest))));
        var cosmosClient = Substitute.For<CosmosClient>();
        var deliveryOrderProcessor = new DeliveryOrderProcessor(cosmosClient);

        var result = await deliveryOrderProcessor.Run(request);

        Assert.IsType<BadRequestObjectResult>(result);
    }
}
