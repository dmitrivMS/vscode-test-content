using System;
using System.Collections.Generic;
using System.Linq;

namespace Inventory
{
    public record Product(string Name, decimal Price, int Quantity);

    public class InventoryService
    {
        private readonly List<Product> _products = new();

        public void AddProduct(Product product)
        {
            _products.Add(product);
        }

        public decimal GetTotalValue() =>
            _products.Sum(p => p.Price * p.Quantity);

        public IEnumerable<Product> GetLowStock(int threshold = 5) =>
            _products.Where(p => p.Quantity <= threshold)
                     .OrderBy(p => p.Quantity);
    }

    public static class Program
    {
        public static void Main()
        {
            var service = new InventoryService();
            service.AddProduct(new Product("Widget", 9.99m, 150));
            service.AddProduct(new Product("Gadget", 24.50m, 3));
            service.AddProduct(new Product("Sprocket", 4.75m, 2));

            Console.WriteLine($"Total inventory value: {service.GetTotalValue():C}");
            foreach (var item in service.GetLowStock())
            {
                Console.WriteLine($"Low stock: {item.Name} ({item.Quantity} remaining)");
            }
        }
    }
}
