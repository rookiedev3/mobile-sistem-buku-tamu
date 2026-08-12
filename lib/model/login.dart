class Login {
  int? code;
  bool? status;
  String? token;
  int? userID;
  String? userEmail;
  String? userName;   // ← TAMBAHAN
  String? userRole;   // ← TAMBAHAN

  Login({this.code, this.status, this.token, this.userID, this.userEmail, this.userName, this.userRole});

  factory Login.fromJson(Map<String, dynamic> obj) {
    return Login(
      code: obj['code'],
      status: obj['status'],
      token: obj['data']['token'],
      userID: obj['data']['user']['id'] is String
          ? int.parse(obj['data']['user']['id'])
          : obj['data']['user']['id'],
      userEmail: obj['data']['user']['email'],
      userName: obj['data']['user']['name'],   // ← TAMBAHAN
      userRole: obj['data']['user']['role'],   // ← TAMBAHAN
    );
  }
}