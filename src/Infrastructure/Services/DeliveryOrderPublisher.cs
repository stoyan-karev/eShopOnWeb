using System.Data;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.eShopWeb.ApplicationCore.Entities.OrderAggregate;
using Microsoft.eShopWeb.ApplicationCore.Interfaces;
using Microsoft.eShopWeb.Infrastructure.Clients.DeliveryOrderProcessor;

namespace Microsoft.eShopWeb.Infrastructure.Services;

public class DeliveryOrderPublisher : IOrderPublisher
{
    private readonly IDeliveryOrderProcessorClient _deliveryOrderProcessorClient;

    public DeliveryOrderPublisher(IDeliveryOrderProcessorClient deliveryOrderProcessorClient)
    {
        _deliveryOrderProcessorClient = deliveryOrderProcessorClient;
    }

    public async Task PublishAsync(Order order)
    {
        var orderRequest = MapToDeliveryOrder(order);

        await _deliveryOrderProcessorClient.SendAsync(orderRequest);
    }

    private static DeliveryOrder MapToDeliveryOrder(Order order)
    {
        var deliveryOrder = new DeliveryOrder
        {
            OrderId = order.Id,
            OrderItems = order.OrderItems.Select(oi => new Clients.DeliveryOrderProcessor.OrderItem
            {
                ItemId = oi.ItemOrdered.CatalogItemId,
                Quantity = oi.Units,
                ProductName = oi.ItemOrdered.ProductName
            }).ToList(),
            ShippingAddress = order.ShipToAddress,
            FinalPrice = order.Total()
        };

        return deliveryOrder;
    }
}
