
namespace Microsoft.eShopWeb.Infrastructure.Clients.DeliveryOrderProcessor;

public class OrderItem
{
    public int ItemId { get; set; }
    public int Quantity { get; set; }

    public string ProductName { get; set; } = string.Empty;
}
