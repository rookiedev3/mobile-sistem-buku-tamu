// lib/model/lead_source.dart
class LeadSource {
  final int id;
  final String name;

  LeadSource({required this.id, required this.name});

  factory LeadSource.fromJson(Map<String, dynamic> json) {
    return LeadSource(
      id: json['id'],
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}