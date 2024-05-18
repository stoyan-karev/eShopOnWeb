using Microsoft.eShopWeb.Functions.OrderItemsReceiver;
using Microsoft.eShopWeb.Functions.OrderItemsReceiver.Models;
using Microsoft.AspNetCore.Http;
using Xunit;
using NSubstitute;
using Azure.Storage.Blobs;
using Microsoft.AspNetCore.Mvc;
using Newtonsoft.Json;
using System.Text;
using Azure.Messaging.ServiceBus;
using Microsoft.Azure.WebJobs.ServiceBus;


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

        var message = ServiceBusModelFactory.ServiceBusReceivedMessage(BinaryData.FromObjectAsJson(orderRequest));
        var messageActions = Substitute.For<ServiceBusMessageActions>();
        var blobContainerClient = Substitute.For<BlobContainerClient>();
        var blobClient = Substitute.For<BlobClient>();
        blobClient.OpenWriteAsync(Arg.Any<bool>()).Returns(new MemoryStream());
        blobContainerClient.GetBlobClient(Arg.Any<string>()).Returns(blobClient);

        await OrderItemsReceiver.Run(message, messageActions, blobContainerClient);

        await messageActions.Received().CompleteMessageAsync(message);
    }

    [Fact]
    public async Task OrderItemsReceiver_Run_InvalidOrderRequest()
    {
        var orderRequest = new
        {
            OrderId = null as int?,
            OrderItems = null as List<OrderItem>
        };

        var message = ServiceBusModelFactory.ServiceBusReceivedMessage(BinaryData.FromObjectAsJson(orderRequest));
        var messageActions = Substitute.For<ServiceBusMessageActions>();
        var blobContainerClient = Substitute.For<BlobContainerClient>();

        await OrderItemsReceiver.Run(message, messageActions, blobContainerClient);

        await messageActions.Received().DeadLetterMessageAsync(message);
    }
}

