using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.eShopWeb.Functions.OrderItemsReceiver.Models;
using Microsoft.eShopWeb.Functions.Infrastructure;
using System.Text.Json;
using Azure.Storage.Blobs;
using Microsoft.AspNetCore.Http;

namespace Microsoft.eShopWeb.Functions.OrderItemsReceiver;

public static class OrderItemsReceiver
{
    [FunctionName("OrderItemsReceiver")]
    public static async Task<IActionResult> Run(
        [HttpTrigger(AuthorizationLevel.Function, "post", Route = null)] HttpRequest request,
        [Blob("orders", FileAccess.Write, Connection = "AzureWebJobsStorage")] BlobContainerClient ordersContainer)
    {
        var orderRequest = await request.ReadAsJsonAsync<OrderRequest>();
        if (orderRequest == null)
        {
            return new BadRequestObjectResult("Invalid order request");
        }

        ordersContainer.CreateIfNotExists();
        var blob = ordersContainer.GetBlobClient(orderRequest.OrderId.ToString());
        using (var writer = new StreamWriter(await blob.OpenWriteAsync(true)))
        {
            var json = JsonSerializer.Serialize(orderRequest);
            await writer.WriteAsync(json);
        }

        return new NoContentResult();
    }
}
