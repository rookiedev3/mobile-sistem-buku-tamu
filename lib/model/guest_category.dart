class GuestCategory {
  final dynamic id;
  final String name;
  final String? color;

  GuestCategory({
    this.id,
    required this.name,
    this.color,
  });

  /// Konversi dari JSON Response Laravel ke Object Dart
  factory GuestCategory.fromJson(Map<String, dynamic> json) {
    return GuestCategory(
      id: json['id'],
      name: json['name'] ?? '',
      color: json['color']?.toString(),
    );
  }

  /// Konversi dari Object Dart ke JSON Payload (untuk Request API)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      if (color != null) 'color': color,
    };
  }
}