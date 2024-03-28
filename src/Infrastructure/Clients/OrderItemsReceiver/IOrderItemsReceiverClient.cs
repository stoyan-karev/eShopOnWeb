using System.Threading.Tasks;

namespace Microsoft.eShopWeb.Infrastructure.Clients.OrderItemsReceiver;

public interface IOrderItemsReceiverClient
{
    Task SendRequest(OrderRequest orderRequest);
}
