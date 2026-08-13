class LeadSource {
  final int? id;
  final String name;

  LeadSource({
    this.id,
    required this.name,
  });

  /// Konversi dari JSON Response Laravel ke Object Dart
  factory LeadSource.fromJson(Map<String, dynamic> json) {
    return LeadSource(
      id: json['id'] is String ? int.tryParse(json['id']) : json['id'],
      name: json['name'] ?? '',
    );
  }

  /// Konversi dari Object Dart ke JSON Payload (untuk Request API)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
    };
  }
}