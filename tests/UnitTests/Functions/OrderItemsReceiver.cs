using Microsoft.eShopWeb.Functions.OrderItemsReceiver;
using Microsoft.eShopWeb.Functions.OrderItemsReceiver.Models;
using Microsoft.AspNetCore.Http;
using Xunit;
using NSubstitute;
using Azure.Storage.Blobs;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using System.Text;


namespace Microsoft.eShopWeb.UnitTests.Functions;

public class OrderItemsReceiverTests
{
    [Fact]
    public async Task OrderItemsReceiver_Run_Success()
    {
        var orderRequest = new OrderRequest
        {
            OrderId = 1,
            OrderItems =
                [
                    new OrderItem { ItemId = 1, Quantity = 1 }
                ]
        };

        var request = Substitute.For<HttpRequest>();
        request.Body.Returns(new MemoryStream(Encoding.UTF8.GetBytes(JsonConvert.SerializeObject(orderRequest))));
        var blobContainerClient = Substitute.For<BlobContainerClient>();
        var blobClient = Substitute.For<BlobClient>();
        blobClient.OpenWriteAsync(Arg.Any<bool>()).Returns(new MemoryStream());
        blobContainerClient.GetBlobClient(Arg.Any<string>()).Returns(blobClient);

        var result = await OrderItemsReceiver.Run(request, blobContainerClient);

        Assert.IsType<NoContentResult>(result);
    }

    [Fact]
    public async Task OrderItemsReceiver_Run_InvalidOrderRequest()
    {
        var orderRequest = new
        {
            OrderId = null as int?,
            OrderItems = null as List<OrderItem>
        };

        var request = Substitute.For<HttpRequest>();
        request.Body.Returns(new MemoryStream(Encoding.UTF8.GetBytes(JsonConvert.SerializeObject(orderRequest))));
        var blobContainerClient = Substitute.For<BlobContainerClient>();

        var result = await OrderItemsReceiver.Run(request, blobContainerClient);

        Assert.IsType<BadRequestObjectResult>(result);
    }
}

