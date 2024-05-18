using System.Threading.Tasks;
using Azure.Messaging.ServiceBus;
using Microsoft.AspNetCore.Http;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Newtonsoft.Json;

namespace Microsoft.eShopWeb.Functions.Infrastructure;

public static class JsonExtensions
{
    public static async Task<T?> ReadAsJsonAsync<T>(this HttpRequest request)
    {
        T? payload;
        try
        {
            var body = await request.ReadAsStringAsync();
            payload = JsonConvert.DeserializeObject<T>(body);
        }
        catch (JsonException)
        {
            payload = default;
        }

        return payload;
    }

    public static T? ReadAsJson<T>(this ServiceBusReceivedMessage message)
    {
        T? payload;
        try
        {
            var body = message.Body.ToString();
            payload = JsonConvert.DeserializeObject<T>(body);
        }
        catch (JsonException)
        {
            payload = default;
        }

        return payload;
    }
}
