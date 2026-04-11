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
    key: 'basic',
    name: 'Basic Wash',
    emoji: '�',
    price: 15.00,
  ),
  CartItemDefinition(
    key: 'premium',
    name: 'Premium Wash',
    emoji: '✨',
    price: 25.00,
  ),
  CartItemDefinition(
    key: 'interior',
    name: 'Interior Detailing',
    emoji: '🧹',
    price: 35.00,
  ),
  CartItemDefinition(
    key: 'exterior',
    name: 'Exterior Detailing',
    emoji: '�',
    price: 30.00,
  ),
  CartItemDefinition(
    key: 'full',
    name: 'Full Service Package',
    emoji: '⭐',
    price: 60.00,
  ),
  CartItemDefinition(
    key: 'express',
    name: 'Express Wash (1hr)',
    emoji: '⚡',
    price: 20.00,
  ),
];
