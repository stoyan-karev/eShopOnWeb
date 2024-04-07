using Newtonsoft.Json;

namespace Microsoft.eShopWeb.Functions.OrderItemsReceiver.Models;

public class OrderItem
{
    [JsonRequired]
    public int? ItemId { get; set; }
    [JsonRequired]
    public int? Quantity { get; set; }
}
