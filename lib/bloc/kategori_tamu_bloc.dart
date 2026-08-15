import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/api_url.dart';
import '../model/kategori_tamu_model.dart';

class KategoriTamuBloc {
  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {'Accept': 'application/json', 'Authorization': 'Bearer $token'};
  }

  static Future<KategoriTamuResponse> fetch({int? month, int? year}) async {
    final uri = Uri.parse(ApiUrl.ownerKategoriTamu(month: month, year: year));
    final response = await http.get(uri, headers: await _headers());

    if (response.statusCode == 200) {
      return KategoriTamuResponse.fromJson(jsonDecode(response.body));
    }
    throw Exception('Gagal memuat data kategori tamu (${response.statusCode})');
  }
}