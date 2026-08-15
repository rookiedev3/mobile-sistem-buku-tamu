import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/api_url.dart';
import '../model/produk_diminati_model.dart';

class ProdukDiminatiBloc {
  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {'Accept': 'application/json', 'Authorization': 'Bearer $token'};
  }

  static Future<ProdukDiminatiResponse> fetch({int? month, int? year}) async {
    final uri = Uri.parse(ApiUrl.ownerProdukDiminati(month: month, year: year));
    final response = await http.get(uri, headers: await _headers());

    if (response.statusCode == 200) {
      return ProdukDiminatiResponse.fromJson(jsonDecode(response.body));
    }
    throw Exception('Gagal memuat data produk diminati (${response.statusCode})');
  }
}