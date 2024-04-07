using System.Collections.Generic;
using Newtonsoft.Json;

namespace Microsoft.eShopWeb.Functions.DeliveryOrderProcessor.Models;

public class DeliveryOrder
{
    [JsonRequired]
    public string? Id { get; set; }
    [JsonRequired]
    public int OrderId { get; set; }
    [JsonRequired]
    public List<OrderItem> OrderItems { get; set; } = new List<OrderItem>();
    [JsonRequired]
    public decimal FinalPrice { get; set; }
    [JsonRequired]
    public Address? ShippingAddress { get; set; }
}
