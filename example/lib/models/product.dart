class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final List<String> tags;
  final DateTime createdAt;
  final bool isActive;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.tags,
    required this.createdAt,
    required this.isActive,
    required this.category,
  });

  @override
  String toString() =>
      "Product(name: $name, price: \$${price.toStringAsFixed(2)}, stock: $stock, active: $isActive, tags: $tags, created: ${createdAt.toLocal().toIso8601String().substring(0, 10)})";
}
