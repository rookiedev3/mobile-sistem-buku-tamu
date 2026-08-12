import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_sistem_buku_tamu/models/user_models.dart';

class ApiService {
  // Ganti dengan URL backend Laravel teman Anda (Gunakan IP lokal / 10.0.2.2 untuk emulator Android)
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // Fungsi Login
  static Future<UserModel?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Sesuaikan dengan format JSON dari Laravel teman Anda
        return UserModel.fromJson(data['user'], tokenFromApi: data['token']);
      }
      return null;
    } catch (e) {
      print('Error Login: $e');
      return null;
    }
  }

  // Fungsi Register
  static Future<bool> register(String name, String email, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Error Register: $e');
      return false;
    }
  }
}