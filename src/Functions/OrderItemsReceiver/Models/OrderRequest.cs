using System.Collections.Generic;
using Newtonsoft.Json;

namespace Microsoft.eShopWeb.Functions.OrderItemsReceiver.Models;

public class OrderRequest
{
    [JsonRequired]
    public int? OrderId { get; set; }
    [JsonRequired]
    public List<OrderItem>? OrderItems { get; set; }
}
