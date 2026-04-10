class CartItemDefinition {
  final String key;
  final String name;
  final String emoji;
  double price;

  CartItemDefinition({
    required this.key,
    required this.name,
    required this.emoji,
    required this.price,
  });
}

final defaultItems = [
  CartItemDefinition(
      key: 'shirts', name: 'Shirts / T-shirts', emoji: '👕', price: 2.50),
  CartItemDefinition(
      key: 'pants', name: 'Pants / Jeans', emoji: '👖', price: 3.50),
  CartItemDefinition(key: 'dress', name: 'Dresses', emoji: '👗', price: 5.00),
  CartItemDefinition(
      key: 'jacket', name: 'Jackets / Coats', emoji: '🧥', price: 8.00),
  CartItemDefinition(
      key: 'sheets', name: 'Bed Sheets', emoji: '🛏', price: 6.00),
  CartItemDefinition(key: 'towels', name: 'Towels', emoji: '🏊', price: 2.00),
];
