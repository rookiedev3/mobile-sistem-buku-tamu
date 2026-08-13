class Branch {
  final int id;
  final String? code;
  final String name;
  final String? address;
  final String? phone;
  final bool isActive;

  Branch({
    required this.id,
    this.code,
    required this.name,
    this.address,
    this.phone,
    required this.isActive,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'],
      code: json['code'],
      name: json['name'] ?? '',
      address: json['address'],
      phone: json['phone'],
      isActive: json['is_active'] == true || json['is_active'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'address': address,
      'phone': phone,
      'is_active': isActive,
    };
  }
}