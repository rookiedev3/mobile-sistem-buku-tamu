import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_flutter/model/aktivitas_model.dart';
import 'package:mobile_flutter/helpers/api_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AktivitasMeta {
  final int currentPage;
  final int lastPage;
  final int total;

  AktivitasMeta({required this.currentPage, required this.lastPage, required this.total});

  factory AktivitasMeta.fromJson(Map<String, dynamic> json) => AktivitasMeta(
        currentPage: json['current_page'] ?? 1,
        lastPage: json['last_page'] ?? 1,
        total: json['total'] ?? 0,
      );
}

class AktivitasListResult {
  final List<AktivitasModel> data;
  final AktivitasMeta meta;
  AktivitasListResult({required this.data, required this.meta});
}

class AktivitasBloc {
  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<AktivitasListResult> daftarAktivitas({
    String keyword = '',
    int page = 1,
    int perPage = 10,
  }) async {
    final url = ApiUrl.ownerActivityLog(keyword: keyword, page: page, perPage: perPage);
    final res = await http.get(Uri.parse(url), headers: await _headers());
    final body = jsonDecode(res.body);

    // controller ini pakai key 'success', bukan 'status' kayak Product/Branch
    if (res.statusCode == 200 && body['success'] == true) {
      final List data = body['data'] ?? [];
      return AktivitasListResult(
        data: data.map((e) => AktivitasModel.fromJson(e)).toList(),
        meta: AktivitasMeta.fromJson(body['meta'] ?? {}),
      );
    }

    throw Exception(_parseError(body));
  }

  static String _parseError(Map body) {
    final data = body['data'];
    if (data is Map) {
      return data.values.map((v) => (v as List).join(', ')).join('\n');
    }
    return data?.toString() ?? body['message']?.toString() ?? 'Terjadi kesalahan';
  }
}