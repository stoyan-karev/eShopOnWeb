namespace Microsoft.eShopWeb.Infrastructure;

public class OrderItemsReceiverConfiguration
{
    public const string CONFIG_NAME = "orderItemsReceiver";
    public string BaseUri { get; set; }
    public string ApiCode { get; set; }
}
