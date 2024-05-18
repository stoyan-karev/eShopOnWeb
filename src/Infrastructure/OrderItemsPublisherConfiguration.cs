namespace Microsoft.eShopWeb.Infrastructure;

public class OrderItemsPublisherConfiguration
{
    public const string CONFIG_NAME = "orderItemsPublisher";
    public string QueueConnection { get; set; }
    public string QueueName { get; set; }
    public bool Enabled { get; set; }
}
