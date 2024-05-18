using Azure.Messaging.ServiceBus;
using Microsoft.eShopWeb.ApplicationCore.Interfaces;
using Microsoft.eShopWeb.ApplicationCore.Services;
using Microsoft.eShopWeb.Infrastructure;
using Microsoft.eShopWeb.Infrastructure.Clients.DeliveryOrderProcessor;
using Microsoft.eShopWeb.Infrastructure.Clients.OrderItemsReceiver;
using Microsoft.eShopWeb.Infrastructure.Data;
using Microsoft.eShopWeb.Infrastructure.Data.Queries;
using Microsoft.eShopWeb.Infrastructure.Logging;
using Microsoft.eShopWeb.Infrastructure.Services;
using Microsoft.Extensions.Azure;

namespace Microsoft.eShopWeb.Web.Configuration;

public static class ConfigureCoreServices
{
    public static IServiceCollection AddCoreServices(this IServiceCollection services,
        IConfiguration configuration)
    {
        var orderRequestPublisherConfigSection = configuration.GetRequiredSection(OrderItemsPublisherConfiguration.CONFIG_NAME);
        services.Configure<OrderItemsPublisherConfiguration>(orderRequestPublisherConfigSection);

        var deliveryOrderProcessorConfigSection = configuration.GetRequiredSection(DeliveryOrderProcessorConfiguration.CONFIG_NAME);
        services.Configure<DeliveryOrderProcessorConfiguration>(deliveryOrderProcessorConfigSection);

        var orderRequestPublisherConfig = orderRequestPublisherConfigSection.Get<OrderItemsPublisherConfiguration>()!;
        if (orderRequestPublisherConfig.Enabled)
        {
            services.AddAzureClients(builder =>
            {
                builder.AddServiceBusClient(orderRequestPublisherConfig.QueueConnection);

                builder.AddClient<ServiceBusSender, ServiceBusClientOptions>((_, _, provider) =>
                provider
                    .GetService<ServiceBusClient>()!
                    .CreateSender(orderRequestPublisherConfig.QueueName)
                )
                .WithName(orderRequestPublisherConfig.QueueName);
            });

            services.AddTransient<IOrderItemsReceiverClient, OrderItemsReceiverClient>();
            services.AddTransient<IOrderPublisher, OrderRequestPublisher>();
        }

        var deliveryOrderProcessorConfig = deliveryOrderProcessorConfigSection.Get<DeliveryOrderProcessorConfiguration>()!;
        if (deliveryOrderProcessorConfig.Enabled)
        {
            services.AddHttpClient<IDeliveryOrderProcessorClient, DeliveryOrderProcessorClient>();
            services.AddTransient<IOrderPublisher, DeliveryOrderPublisher>();
        }

        services.AddScoped(typeof(IReadRepository<>), typeof(EfRepository<>));
        services.AddScoped(typeof(IRepository<>), typeof(EfRepository<>));

        services.AddScoped<IBasketService, BasketService>();
        services.AddScoped<IOrderService, OrderService>();
        services.AddScoped<IBasketQueryService, BasketQueryService>();

        var catalogSettings = configuration.Get<CatalogSettings>() ?? new CatalogSettings();
        services.AddSingleton<IUriComposer>(new UriComposer(catalogSettings));

        services.AddScoped(typeof(IAppLogger<>), typeof(LoggerAdapter<>));
        services.AddTransient<IEmailSender, EmailSender>();

        return services;
    }
}
