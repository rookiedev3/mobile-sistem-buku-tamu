class ApiUrl {
  static const String baseUrl = "http://127.0.0.1:8000";

  // ================= AUTH =================
  static const String registrasi = '$baseUrl/api/register';
  static const String login = '$baseUrl/api/login';
  static const String logout = '$baseUrl/api/logout';
  static const String me = '$baseUrl/api/me';

  // ================= PRODUK =================
  static const String listProduk = '$baseUrl/api/products';
  static const String createProduk = '$baseUrl/api/products';

  static String updateProduk(int id) => '$baseUrl/api/products/$id';
  static String showProduk(int id) => '$baseUrl/api/products/$id';
  static String deleteProduk(int id) => '$baseUrl/api/products/$id';

  // ================= USER MANAGEMENT =================
  static String users({String? status}) {
    return '$baseUrl/api/users' + (status != null ? '?status=$status' : '');
  }
  static String approveUser(int id) => '$baseUrl/api/users/$id/approve';
  static String deactivateUser(int id) => '$baseUrl/api/users/$id/deactivate';
  static String deleteUser(int id) => '$baseUrl/api/users/$id';
  static String updateUser(int id) => '$baseUrl/api/users/$id';
  static String createUser() => '$baseUrl/api/users';


  // ================= SECURITY =================
  static String securityDashboard({String? date, int perPage = 10}) {
    final query = <String>['per_page=$perPage'];
    if (date != null) query.add('date=$date');
    return '$baseUrl/api/security/dashboard?${query.join('&')}';
  }
  static String securityCheckIn(int id) => '$baseUrl/api/security/check-in/$id';
  static String securityCheckOut(int id) => '$baseUrl/api/security/check-out/$id';
}

