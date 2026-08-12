class Login {
  int? code; 
  bool? status; 
  String? token; 
  int? userID; // Tetap biarkan int?
  String? userEmail; 

  Login({this.code, this.status, this.token, this.userID, this.userEmail});

  factory Login.fromJson(Map<String, dynamic> obj) {
    return Login(
      code: obj['code'],
      status: obj['status'],
      token: obj['data']['token'],
      
      // PERBAIKAN DI SINI: Cek apakah data dari server string atau int, lalu convert dengan aman
      userID: obj['data']['user']['id'] is String 
          ? int.parse(obj['data']['user']['id']) 
          : obj['data']['user']['id'],
          
      userEmail: obj['data']['user']['email']
    );
  }
}