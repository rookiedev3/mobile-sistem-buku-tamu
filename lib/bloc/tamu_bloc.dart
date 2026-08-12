import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/api_url.dart';
import '../model/tamu.dart';

class TamuBloc {
  
  // Helper untuk mengambil token yang tersimpan saat login
  static Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // READ: Mengambil daftar tamu
  static Future<List<Tamu>> getTamu() async {
    String apiUrl = ApiUrl.listTamu;
    String? token = await _getToken();

    var response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    var jsonObj = json.decode(response.body);

    if (response.statusCode == 200 && jsonObj['data'] != null) {
      List<dynamic> listData = jsonObj['data'];
      return listData.map((e) => Tamu.fromJson(e)).toList();
    }
    return [];
  }

  // CREATE: Menambah tamu baru (Check-in)
  static Future<bool> addTamu(Tamu tamu) async {
    String apiUrl = ApiUrl.createTamu;
    String? token = await _getToken();

    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(tamu.toJson()),
    );

    var jsonObj = json.decode(response.body);
    return response.statusCode == 200 || response.statusCode == 201;
  }

  // UPDATE: Mengubah data tamu
  static Future<bool> updateTamu(Tamu tamu) async {
    String apiUrl = ApiUrl.updateTamu(tamu.id!);
    String? token = await _getToken();

    var response = await http.put(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(tamu.toJson()),
    );

    var jsonObj = json.decode(response.body);
    return response.statusCode == 200;
  }

  // DELETE: Menghapus data tamu
  static Future<bool> deleteTamu(int id) async {
    String apiUrl = ApiUrl.deleteTamu(id);
    String? token = await _getToken();

    var response = await http.delete(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  }
}