class ApiUrl {
  // Sesuaikan sama target run-mu:
  // - Android Emulator     : http://10.0.2.2:8000
  // - HP fisik (WiFi sama) : http://192.168.x.x:8000  (IP lokal laptop)
  // - Windows Desktop      : http://127.0.0.1:8000
  static const String baseUrl = "http://localhost:8000";
  // ================= AUTH =================
  static const String registrasi = baseUrl + '/api/register';
  static const String login = baseUrl + '/api/login';
  static const String logout = baseUrl + '/api/logout';
  static const String me = baseUrl + '/api/me';

  // ================= PRODUK =================
  static const String listProduk = baseUrl + '/api/products';
  static const String createProduk = baseUrl + '/api/products';

  static String updateProduk(int id) => baseUrl + '/api/products/' + id.toString();
  static String showProduk(int id) => baseUrl + '/api/products/' + id.toString();
  static String deleteProduk(int id) => baseUrl + '/api/products/' + id.toString();

  // ================= USER MANAGEMENT =================
  static String users({String? status}) {
    return baseUrl + '/api/users' + (status != null ? '?status=$status' : '');
  }
  static String approveUser(int id) => baseUrl + '/api/users/$id/approve';
  static String deactivateUser(int id) => baseUrl + '/api/users/$id/deactivate';
  static String deleteUser(int id) => baseUrl + '/api/users/$id';
}