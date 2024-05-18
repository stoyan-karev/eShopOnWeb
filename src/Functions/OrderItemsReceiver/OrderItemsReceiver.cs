using System.IO;
using System.Threading.Tasks;
using Microsoft.Azure.WebJobs;
using Microsoft.eShopWeb.Functions.OrderItemsReceiver.Models;
using Microsoft.eShopWeb.Functions.Infrastructure;
using System.Text.Json;
using Azure.Storage.Blobs;
using Azure.Messaging.ServiceBus;
using Microsoft.Azure.WebJobs.ServiceBus;

namespace Microsoft.eShopWeb.Functions.OrderItemsReceiver;

public static class OrderItemsReceiver
{
    [FunctionName("OrderItemsReceiver")]
    public static async Task Run(
        [ServiceBusTrigger("order-items", Connection = "OrderItemsQueueConnection", AutoCompleteMessages = false)] ServiceBusReceivedMessage message,
        ServiceBusMessageActions messageActions,
        [Blob("orders", FileAccess.Write, Connection = "OrderItemsStorage")] BlobContainerClient ordersContainer)
    {
        var orderRequest = message.ReadAsJson<OrderRequest>();
        if (orderRequest == null)
        {
            await messageActions.DeadLetterMessageAsync(message);
            return;
        }

        ordersContainer.CreateIfNotExists();
        var blob = ordersContainer.GetBlobClient(orderRequest!.OrderId.ToString());
        using (var writer = new StreamWriter(await blob.OpenWriteAsync(true)))
        {
            var json = JsonSerializer.Serialize(orderRequest);
            await writer.WriteAsync(json);
        }

        await messageActions.CompleteMessageAsync(message);
    }
}
