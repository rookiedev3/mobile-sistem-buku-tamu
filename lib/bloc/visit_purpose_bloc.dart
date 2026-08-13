// lib/bloc/visit_purpose_bloc.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_flutter/model/visit_purpose.dart';
import 'package:mobile_flutter/helpers/api_url.dart'; // sesuaikan path
import 'package:shared_preferences/shared_preferences.dart';
import 'branch_bloc.dart' show ApiResponse;

class VisitPurposeBloc {
  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<ApiResponse<List<VisitPurpose>>> daftarVisitPurpose() async {
    final res = await http.get(Uri.parse(ApiUrl.listVisitPurpose), headers: await _headers());
    final body = jsonDecode(res.body);
    if (res.statusCode == 200 && body['status'] == true) {
      final List data = body['data'];
      return ApiResponse(status: true, data: data.map((e) => VisitPurpose.fromJson(e)).toList());
    }
    throw Exception(body['data']?.toString() ?? 'Gagal memuat data visit purpose');
  }

  static Future<ApiResponse<VisitPurpose>> tambahVisitPurpose(String name, bool isActive) async {
    final res = await http.post(
      Uri.parse(ApiUrl.createVisitPurpose),
      headers: await _headers(),
      body: jsonEncode({'name': name, 'is_active': isActive}),
    );
    final body = jsonDecode(res.body);
    if (res.statusCode == 200 && body['status'] == true) {
      return ApiResponse(status: true, data: VisitPurpose.fromJson(body['data']));
    }
    throw Exception(_parseError(body));
  }

  static Future<ApiResponse<VisitPurpose>> updateVisitPurpose(int id, String name, bool isActive) async {
    final res = await http.put(
      Uri.parse(ApiUrl.updateVisitPurpose(id)),
      headers: await _headers(),
      body: jsonEncode({'name': name, 'is_active': isActive}),
    );
    final body = jsonDecode(res.body);
    if (res.statusCode == 200 && body['status'] == true) {
      return ApiResponse(status: true, data: VisitPurpose.fromJson(body['data']));
    }
    throw Exception(_parseError(body));
  }

  static Future<void> hapusVisitPurpose(int id) async {
    final res = await http.delete(Uri.parse(ApiUrl.deleteVisitPurpose(id)), headers: await _headers());
    final body = jsonDecode(res.body);
    if (!(res.statusCode == 200 && body['status'] == true)) {
      throw Exception(_parseError(body));
    }
  }

  static String _parseError(Map body) {
    final data = body['data'];
    if (data is Map) {
      return data.values.map((v) => (v as List).join(', ')).join('\n');
    }
    return data?.toString() ?? 'Terjadi kesalahan';
  }
}