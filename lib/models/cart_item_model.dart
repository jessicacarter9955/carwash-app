import 'package:flutter/material.dart';

class CartItemDefinition {
  final String key;
  final String name;
  final IconData icon;
  double price;

  CartItemDefinition({
    required this.key,
    required this.name,
    required this.icon,
    required this.price,
  });
}

final defaultItems = [
  CartItemDefinition(
    key: 'basic',
    name: 'Basic Wash',
    icon: Icons.local_car_wash,
    price: 15.00,
  ),
  CartItemDefinition(
    key: 'premium',
    name: 'Premium Wash',
    icon: Icons.auto_awesome,
    price: 25.00,
  ),
  CartItemDefinition(
    key: 'interior',
    name: 'Interior Detailing',
    icon: Icons.cleaning_services,
    price: 35.00,
  ),
  CartItemDefinition(
    key: 'exterior',
    name: 'Exterior Detailing',
    icon: Icons.clean_hands,
    price: 30.00,
  ),
  CartItemDefinition(
    key: 'full',
    name: 'Full Service Package',
    icon: Icons.star,
    price: 60.00,
  ),
  CartItemDefinition(
    key: 'express',
    name: 'Express Wash (1hr)',
    icon: Icons.flash_on,
    price: 20.00,
  ),
];
