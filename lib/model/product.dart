// lib/model/product.dart
class Product {
  final int id;
  final String? code;
  final String name;
  final String? category;
  final bool isActive;

  Product({
    required this.id,
    this.code,
    required this.name,
    this.category,
    required this.isActive,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      code: json['code'],
      name: json['name'] ?? '',
      category: json['category'],
      isActive: json['is_active'] == true || json['is_active'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'category': category,
      'is_active': isActive,
    };
  }
}