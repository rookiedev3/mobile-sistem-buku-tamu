class ApiUrl {
  // Ubah URL dasar sesuai server backend teman Anda (misal: port 8080 atau 8000)
  static const String baseUrl = "http://localhost:8080"; 

  // Autentikasi
  static const String registrasi = '$baseUrl/registrasi';
  static const String login = '$baseUrl/login';

  // --- Sistem Buku Tamu (Guest Management) ---
  static const String listTamu = '$baseUrl/tamu';
  static const String createTamu = '$baseUrl/tamu';

  static String showTamu(int id) {
    return '$baseUrl/tamu/$id';
  }

  static String updateTamu(int id) {
    return '$baseUrl/tamu/$id';
  }

  static String deleteTamu(int id) {
    return '$baseUrl/tamu/$id';
  }
}