using System.Data;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.eShopWeb.ApplicationCore.Entities.OrderAggregate;
using Microsoft.eShopWeb.ApplicationCore.Interfaces;
using Microsoft.eShopWeb.Infrastructure.Clients.OrderItemsReceiver;

namespace Microsoft.eShopWeb.Infrastructure.Services;

public class OrderRequestPublisher : IOrderPublisher
{
    private readonly IOrderItemsReceiverClient _orderItemsReceiverClient;

    public OrderRequestPublisher(IOrderItemsReceiverClient orderItemsReceiverClient)
    {
        _orderItemsReceiverClient = orderItemsReceiverClient;
    }

    public async Task PublishAsync(Order order)
    {
        var orderRequest = MapToOrderRequest(order);

        await _orderItemsReceiverClient.SendAsync(orderRequest);
    }

    private static OrderRequest MapToOrderRequest(Order order)
    {
        var orderRequest = new OrderRequest
        {
            OrderId = order.Id,
            OrderItems = order.OrderItems.Select(oi => new Clients.OrderItemsReceiver.OrderItem
            {
                ItemId = oi.ItemOrdered.CatalogItemId,
                Quantity = oi.Units
            }).ToList()
        };

        return orderRequest;
    }
}
