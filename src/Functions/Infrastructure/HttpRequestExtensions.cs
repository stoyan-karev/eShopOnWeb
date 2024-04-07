using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Newtonsoft.Json;

namespace Microsoft.eShopWeb.Functions.Infrastructure;

public static class HttpRequestExtensions
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
}
