class UserModel {
  int? id;
  int? branchId;
  String? name;
  String? email;
  String? phone;
  String? role;
  bool? isActive;
  String? branchName;

  UserModel({
    this.id, this.branchId, this.name, this.email,
    this.phone, this.role, this.isActive, this.branchName,
  });

  factory UserModel.fromJson(Map<String, dynamic> obj) {
    return UserModel(
      id: obj['id'],
      branchId: obj['branch_id'],
      name: obj['name'],
      email: obj['email'],
      phone: obj['phone'],
      role: obj['role'],
      isActive: obj['is_active'],
      branchName: obj['branch'] != null ? obj['branch']['name'] : null,
    );
  }
}