import 'package:flutter/material.dart';

class Product {
  final String name;
  final double price;
  final String imageUrl;

  const Product(
      {required this.name, required this.price, required this.imageUrl});
}

class ProductsList extends StatelessWidget {
  ProductsList({super.key});
  final List<Product> products = [
    Product(
      name: "Nike Shoes",
      price: 99.99,
      imageUrl: "https://images.pexels.com/photos/7904726/pexels-photo-7904726.jpeg?auto=compress&cs=tinysrgb&w=600&lazy=load",
    ),
    Product(
      name: "Adidas Sneakers",
      price: 79.99,
      imageUrl: "https://images.pexels.com/photos/7904726/pexels-photo-7904726.jpeg?auto=compress&cs=tinysrgb&w=600&lazy=load",
    ),
    Product(
      name: "Puma Running",
      price: 59.99,
      imageUrl: "https://images.pexels.com/photos/7904726/pexels-photo-7904726.jpeg?auto=compress&cs=tinysrgb&w=600&lazy=load",
    ),
    Product(
      name: "Reebok Classic",
      price: 89.99,
      imageUrl: "https://images.pexels.com/photos/7904726/pexels-photo-7904726.jpeg?auto=compress&cs=tinysrgb&w=600&lazy=load",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product List"),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ProductCard(product: products[index]);
            }),
      ),
    );
  }
}

// class ProductListScreen extends StatelessWidget {
//   final List<Product> products = [
//     Product(
//       name: "Nike Shoes",
//       price: 99.99,
//       imageUrl: "https://via.placeholder.com/150",
//     ),
//     Product(
//       name: "Adidas Sneakers",
//       price: 79.99,
//       imageUrl: "https://via.placeholder.com/150",
//     ),
//     Product(
//       name: "Puma Running",
//       price: 59.99,
//       imageUrl: "https://via.placeholder.com/150",
//     ),
//     Product(
//       name: "Reebok Classic",
//       price: 89.99,
//       imageUrl: "https://via.placeholder.com/150",
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Product List")),
//       body: Padding(
//         padding: const EdgeInsets.all(10),
//         child: ListView.builder(
//           itemCount: products.length,
//           itemBuilder: (context, index) {
//             return ProductCard(product: products[index]);
//           },
//         ),
//       ),
//     );
//   }
// }

// Product Model

// Product Card Widget
class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10), // Space between image & text

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "\$${product.price.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 16, color: Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
