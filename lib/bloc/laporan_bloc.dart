import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/api_url.dart';
import '../model/laporan_model.dart';

class LaporanBloc {
  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {'Accept': 'application/json', 'Authorization': 'Bearer $token'};
  }

  /// GET /api/v1/owner/laporan
  /// category: '', 'vip', atau 'reguler'
  /// branchId / picId: kosongkan string untuk "Semua"
  static Future<LaporanResponse> fetch({
    required int month,
    required int year,
    String category = '',
    String branchId = '',
    String picId = '',
    int perPage = 15,
  }) async {
    // SESUAIKAN: ganti ApiUrl.ownerLaporan() sesuai nama method yang kamu
    // tambahkan di api_url.dart (ikuti pola ownerLeadsPipeline/ownerDashboard).
    final queryParams = <String, String>{
      'month': month.toString(),
      'year': year.toString(),
      'per_page': perPage.toString(),
    };
    if (category.isNotEmpty) queryParams['category'] = category;
    if (branchId.isNotEmpty) queryParams['branch_id'] = branchId;
    if (picId.isNotEmpty) queryParams['pic_id'] = picId;

    final uri = Uri.parse(ApiUrl.ownerLaporan()).replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: await _headers());

    if (response.statusCode != 200) {
      throw Exception('Gagal memuat laporan (${response.statusCode})');
    }

    return LaporanResponse.fromJson(jsonDecode(response.body));
  }

  /// GET /api/v1/owner/laporan/export-excel
  /// Balikin URL file (bukan file binary), sesuai desain backend-nya.
  static Future<String> exportExcel({
    required int month,
    required int year,
    String category = '',
    String branchId = '',
    String picId = '',
  }) async {
    final queryParams = <String, String>{
      'month': month.toString(),
      'year': year.toString(),
    };
    if (category.isNotEmpty) queryParams['category'] = category;
    if (branchId.isNotEmpty) queryParams['branch_id'] = branchId;
    if (picId.isNotEmpty) queryParams['pic_id'] = picId;

    final uri = Uri.parse(ApiUrl.ownerLaporanExportExcel()).replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: await _headers());

    if (response.statusCode != 200) {
      throw Exception('Gagal export Excel (${response.statusCode})');
    }
    final body = jsonDecode(response.body);
    return body['file_url'];
  }

  /// GET /api/v1/owner/laporan/export-pdf
  static Future<String> exportPdf({
    required int month,
    required int year,
    String category = '',
    String branchId = '',
    String picId = '',
  }) async {
    final queryParams = <String, String>{
      'month': month.toString(),
      'year': year.toString(),
    };
    if (category.isNotEmpty) queryParams['category'] = category;
    if (branchId.isNotEmpty) queryParams['branch_id'] = branchId;
    if (picId.isNotEmpty) queryParams['pic_id'] = picId;

    final uri = Uri.parse(ApiUrl.ownerLaporanExportPdf()).replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: await _headers());

    if (response.statusCode != 200) {
      throw Exception('Gagal export PDF (${response.statusCode})');
    }
    final body = jsonDecode(response.body);
    return body['file_url'];
  }
}
