using System;
using System.Net.Http;
using System.Text.Json;
using System.Threading.Tasks;

namespace Microsoft.eShopWeb.Infrastructure.Clients;

public static class HttpClientExtensions
{
    public static async Task<HttpResponseMessage> PostJsonAsync<T>(this HttpClient client, string requestUri, T value)
    {
        // Using StringContent, correctly sets the Content-Length header 
        var content = new StringContent(JsonSerializer.Serialize(value), System.Text.Encoding.UTF8, "application/json");
        var response = await client.PostAsync(requestUri, content);

        response.EnsureSuccessStatusCode();

        return response;
    }

    public static void AddAzureFunctionConfiguration(this HttpClient client, string baseUri, string apiCode)
    {
        client.BaseAddress = new Uri(baseUri);
        if (!string.IsNullOrEmpty(apiCode))
        {
            client.DefaultRequestHeaders.Add("x-functions-key", apiCode);
        }
    }
}
