using System.Collections.Generic;
using Microsoft.eShopWeb.ApplicationCore.Entities.OrderAggregate;

namespace Microsoft.eShopWeb.Infrastructure.Clients.DeliveryOrderProcessor;

public class DeliveryOrder
{
    public int OrderId { get; set; }
    public List<OrderItem> OrderItems { get; set; } = new List<OrderItem>();
    public decimal FinalPrice { get; set; }
    public Address? ShippingAddress { get; set; }
}
