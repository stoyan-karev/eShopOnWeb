using Newtonsoft.Json;

namespace Microsoft.eShopWeb.Functions.DeliveryOrderProcessor.Models;

public class OrderItem
{
    [JsonRequired]
    public int ItemId { get; set; }
    [JsonRequired]
    public int Quantity { get; set; }

    [JsonRequired]
    public string ProductName { get; set; } = string.Empty;
}
