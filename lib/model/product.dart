class Product {
  final int? id;
  final String? code;
  final String name;
  final String? category;
  final bool isActive;

  Product({
    this.id,
    this.code,
    required this.name,
    this.category,
    this.isActive = true,
  });

  /// Konversi dari JSON Response Laravel ke Object Dart
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] is String ? int.tryParse(json['id']) : json['id'],
      code: json['code']?.toString(),
      name: json['name'] ?? '',
      category: json['category']?.toString(),
      isActive: json['is_active'] == true || json['is_active'] == 1 || json['is_active'] == '1',
    );
  }

  /// Konversi dari Object Dart ke JSON Payload (untuk Create/Update API)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'code': code,
      'name': name,
      'category': category,
      'is_active': isActive ? 1 : 0,
    };
  }
}