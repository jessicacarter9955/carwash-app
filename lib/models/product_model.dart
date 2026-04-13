class ProductModel {
  final String id;
  final String name;
  final String? description;
  final String? image;
  final bool active;

  ProductModel({
    required this.id,
    required this.name,
    this.description,
    this.image,
    required this.active,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      image: map['image'],
      active: map['active'] ?? true,
    );
  }
}
