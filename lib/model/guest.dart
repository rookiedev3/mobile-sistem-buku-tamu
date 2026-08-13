class Guest {
  final int id;
  final String? guestCode;
  final String name;
  final String companyName;
  final String? address;
  final String email;
  final String guestCategoryId;
  final String position;
  final String phone;
  final String? photoPath;
  final bool isVip;

  Guest({
    required this.id,
    this.guestCode,
    required this.name,
    required this.companyName,
    this.address,
    required this.email,
    required this.guestCategoryId,
    required this.position,
    required this.phone,
    this.photoPath,
    required this.isVip,
  });

  factory Guest.fromJson(Map<String, dynamic> json) {
    return Guest(
      id: json['id'],
      guestCode: json['guest_code'],
      name: json['name'] ?? '',
      companyName: json['company_name'] ?? '',
      address: json['address'],
      email: json['email'] ?? '',
      guestCategoryId: json['guest_category_id']?.toString() ?? '',
      position: json['position'] ?? '',
      phone: json['phone'] ?? '',
      photoPath: json['photo_path'],
      isVip: json['is_vip'] == true || json['is_vip'] == 1,
    );
  }
}