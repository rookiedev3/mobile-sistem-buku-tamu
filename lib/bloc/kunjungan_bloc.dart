import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/api_url.dart';
import '../model/kunjungan.dart';
import '../model/paginated_response.dart';

class KunjunganBloc {
  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {'Accept': 'application/json', 'Authorization': 'Bearer $token'};
  }

  static Future<KunjunganResponse> list({
    String? startDate,
    String? endDate,
    String vipStatus = 'all',
    String? keyword,
    int page = 1,
  }) async {
    final url = Uri.parse(ApiUrl.managerKunjungan(
      startDate: startDate,
      endDate: endDate,
      vipStatus: vipStatus,
      keyword: keyword,
      page: page,
    ));
    final response = await http.get(url, headers: await _headers());

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      // Backend membungkus paginator Laravel mentah di dalam key 'data',
      // bukan format 'data' + 'meta' yang sudah ditransform. Makanya
      // pakai fromLaravelPaginator, bukan fromJson biasa.
      final paginator = (body['data'] as Map<String, dynamic>?) ?? {};
      return PaginatedResponse<Kunjungan>.fromLaravelPaginator(
        paginator,
        Kunjungan.fromJson,
      );
    }
    throw Exception('Gagal memuat arsip kunjungan (${response.statusCode})');
  }
}