using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.eShopWeb.Functions.ViewModels;
using System.Text.Json;
using System.ComponentModel.DataAnnotations;
using Azure.Storage.Blobs;

namespace Microsoft.eShopWeb.Functions;

public static class OrderItemsReceiver
{
    [FunctionName("OrderItemsReceiver")]
    public static async Task<IActionResult> Run(
        [HttpTrigger(AuthorizationLevel.Function, "post", Route = null)][FromBody] OrderRequest orderRequest,
        [Blob("orders", FileAccess.Write, Connection = "AzureWebJobsStorage")] BlobContainerClient ordersContainer)
    {
        if (!IsValid(orderRequest))
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

    private static bool IsValid(OrderRequest orderRequest)
    {
        return Validator.TryValidateObject(orderRequest, new ValidationContext(orderRequest), null, true);
    }
}
