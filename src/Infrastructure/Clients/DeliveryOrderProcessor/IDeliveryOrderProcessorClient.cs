using System.Threading.Tasks;

namespace Microsoft.eShopWeb.Infrastructure.Clients.DeliveryOrderProcessor;

public interface IDeliveryOrderProcessorClient
{
    Task SendAsync(DeliveryOrder order);
}
