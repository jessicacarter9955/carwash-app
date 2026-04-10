class ServicePricingModel {
  final String itemKey;
  final String itemName;
  final double price;
  final String category;

  ServicePricingModel({
    required this.itemKey,
    required this.itemName,
    required this.price,
    required this.category,
  });

  factory ServicePricingModel.fromMap(Map<String, dynamic> m) =>
      ServicePricingModel(
        itemKey: m['item_key'] ?? '',
        itemName: m['item_name'] ?? '',
        price: (m['price'] ?? 0).toDouble(),
        category: m['category'] ?? 'clothing',
      );
}
