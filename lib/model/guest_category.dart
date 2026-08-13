// lib/model/guest_category.dart
class GuestCategory {
  final int id;
  final String name;
  final String color;

  GuestCategory({required this.id, required this.name, required this.color});

  factory GuestCategory.fromJson(Map<String, dynamic> json) {
    return GuestCategory(
      id: json['id'],
      name: json['name'] ?? '',
      color: json['color'] ?? '#013220',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'color': color};
}