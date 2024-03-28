using System.Collections.Generic;

namespace Microsoft.eShopWeb.Infrastructure.Clients.OrderItemsReceiver;

public class OrderRequest
{
    public int OrderId { get; set; }
    public List<OrderItem> OrderItems { get; set; } = [];
}
