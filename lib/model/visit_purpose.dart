// lib/model/visit_purpose.dart
class VisitPurpose {
  final int id;
  final String name;
  final bool isActive;

  VisitPurpose({required this.id, required this.name, required this.isActive});

  factory VisitPurpose.fromJson(Map<String, dynamic> json) {
    return VisitPurpose(
      id: json['id'],
      name: json['name'] ?? '',
      isActive: json['is_active'] == true || json['is_active'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'is_active': isActive};
}