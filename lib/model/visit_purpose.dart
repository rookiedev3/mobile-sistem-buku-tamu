class VisitPurpose {
  final int? id;
  final String name;
  final bool isActive;

  VisitPurpose({
    this.id,
    required this.name,
    this.isActive = true,
  });

  /// Konversi dari JSON Response Laravel ke Object Dart
  factory VisitPurpose.fromJson(Map<String, dynamic> json) {
    return VisitPurpose(
      id: json['id'] is String ? int.tryParse(json['id']) : json['id'],
      name: json['name'] ?? '',
      isActive: json['is_active'] == true || json['is_active'] == 1 || json['is_active'] == '1',
    );
  }

  /// Konversi dari Object Dart ke JSON Payload (untuk Request API)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'is_active': isActive ? 1 : 0,
    };
  }
}