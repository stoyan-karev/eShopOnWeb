using System.Configuration;
using Microsoft.Azure.Cosmos;
using Microsoft.Azure.Cosmos.Fluent;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

[assembly: FunctionsStartup(typeof(Microsoft.eShopWeb.Functions.Startup))]

namespace Microsoft.eShopWeb.Functions;

public class Startup : FunctionsStartup
{
    public override void ConfigureAppConfiguration(IFunctionsConfigurationBuilder builder)
    {
        builder.ConfigurationBuilder
            .AddJsonFile("local.settings.json", optional: true, reloadOnChange: true)
            .AddEnvironmentVariables();
    }

    public override void Configure(IFunctionsHostBuilder builder)
    {
        var context = builder.GetContext();

        // Register the CosmosClient as a Singleton
        builder.Services.AddSingleton((s) =>
        {
            string connectionString = context.Configuration.GetValue<string>("DeliveryOrdersConnection");
            if (string.IsNullOrEmpty(connectionString))
            {
                throw new ConfigurationErrorsException("Please specify a valid Cosmos DB connection string in the appsettings.json file or your Azure Functions Settings.");
            }

            CosmosClientBuilder configurationBuilder = new CosmosClientBuilder(connectionString);
            return configurationBuilder
                .WithSerializerOptions(new CosmosSerializationOptions()
                {
                    PropertyNamingPolicy = CosmosPropertyNamingPolicy.CamelCase
                })
                .Build();
        });
    }
}
