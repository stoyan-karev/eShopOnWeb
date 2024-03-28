using System.ComponentModel.DataAnnotations;

namespace Microsoft.eShopWeb.Functions.ViewModels;

public class OrderItem
{
    [Required]
    public int? ItemId { get; set; }
    [Required]
    public int? Quantity { get; set; }
}
