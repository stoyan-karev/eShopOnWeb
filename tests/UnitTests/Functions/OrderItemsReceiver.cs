using Microsoft.eShopWeb.Functions;
using Microsoft.eShopWeb.Functions.ViewModels;
using Microsoft.AspNetCore.Http;
using Xunit;
using NSubstitute;
using Azure.Storage.Blobs;
using Microsoft.AspNetCore.Mvc;
using System.Text.Json;


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

        var blobContainerClient = Substitute.For<BlobContainerClient>();
        var blobClient = Substitute.For<BlobClient>();
        blobClient.OpenWriteAsync(Arg.Any<bool>()).Returns(new MemoryStream());
        blobContainerClient.GetBlobClient(Arg.Any<string>()).Returns(blobClient);

        var result = await OrderItemsReceiver.Run(orderRequest, blobContainerClient);

        Assert.IsType<NoContentResult>(result);
    }

    [Fact]
    public async Task OrderItemsReceiver_Run_InvalidOrderRequest()
    {
        var orderRequest = new OrderRequest
        {
            OrderId = null,
            OrderItems = null
        };

        var blobContainerClient = Substitute.For<BlobContainerClient>();

        var result = await OrderItemsReceiver.Run(orderRequest, blobContainerClient);

        Assert.IsType<BadRequestObjectResult>(result);
    }
}

