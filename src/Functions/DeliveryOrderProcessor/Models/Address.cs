using Newtonsoft.Json;

namespace Microsoft.eShopWeb.Functions.DeliveryOrderProcessor.Models;

public class Address
{
    [JsonRequired]
    public string? Street { get; set; }
    [JsonRequired]
    public string? City { get; set; }
    [JsonRequired]
    public string? State { get; set; }
    [JsonRequired]
    public string? Country { get; set; }
    [JsonRequired]
    public string? ZipCode { get; set; }
}
