class ApiUrl {
  static const String baseUrl = "http://localhost:8080"; 

  static const String registrasi = baseUrl + '/registrasi';
  static const String login = baseUrl + '/login';
  static const String listProduk = baseUrl + '/produk';
  static const String createProduk = baseUrl + '/produk';    // Pastikan ini ada

  static String updateProduk(int id) {
    return baseUrl + '/produk/' + id.toString();
  }
  static String showProduk (int id){
    return baseUrl + '/produk/' + id.toString();             // Ditambah / sebelum ID
  }
  static String deleteProduk (int id){
    return baseUrl + '/produk/' + id.toString();             // Ditambah / sebelum ID
  }
}