using System.Threading.Tasks;
using Microsoft.Extensions.Options;
using Microsoft.Extensions.Azure;
using Azure.Messaging.ServiceBus;

namespace Microsoft.eShopWeb.Infrastructure.Clients.OrderItemsReceiver;

public class OrderItemsReceiverClient : IOrderItemsReceiverClient
{
    private readonly ServiceBusSender _sender;

    public OrderItemsReceiverClient(IAzureClientFactory<ServiceBusSender> factory, IOptions<OrderItemsPublisherConfiguration> options)
    {
        _sender = factory.CreateClient(options.Value.QueueName);
    }

    public async Task SendAsync(OrderRequest orderRequest)
    {
        var message = new ServiceBusMessage(orderRequest.ToJson());
        await _sender.SendMessageAsync(message);
    }
}

