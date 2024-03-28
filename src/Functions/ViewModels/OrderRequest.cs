using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace Microsoft.eShopWeb.Functions.ViewModels;

public class OrderRequest
{
    [Required]
    public int? OrderId { get; set; }
    [Required]
    public List<OrderItem>? OrderItems { get; set; }
}
