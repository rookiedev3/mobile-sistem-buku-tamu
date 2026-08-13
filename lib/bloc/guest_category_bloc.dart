// lib/bloc/guest_category_bloc.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_flutter/model/guest_category.dart';
import 'package:mobile_flutter/helpers/api_url.dart'; // sesuaikan path
import 'package:shared_preferences/shared_preferences.dart';
import 'branch_bloc.dart' show ApiResponse;

class GuestCategoryBloc {
  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<ApiResponse<List<GuestCategory>>> daftarGuestCategory() async {
    final res = await http.get(Uri.parse(ApiUrl.listGuestCategory), headers: await _headers());
    final body = jsonDecode(res.body);
    if (res.statusCode == 200 && body['status'] == true) {
      final List data = body['data'];
      return ApiResponse(status: true, data: data.map((e) => GuestCategory.fromJson(e)).toList());
    }
    throw Exception(body['data']?.toString() ?? 'Gagal memuat data guest category');
  }

  static Future<ApiResponse<GuestCategory>> tambahGuestCategory(String name, String color) async {
    final res = await http.post(
      Uri.parse(ApiUrl.createGuestCategory),
      headers: await _headers(),
      body: jsonEncode({'name': name, 'color': color}),
    );
    final body = jsonDecode(res.body);
    if (res.statusCode == 200 && body['status'] == true) {
      return ApiResponse(status: true, data: GuestCategory.fromJson(body['data']));
    }
    throw Exception(_parseError(body));
  }

  static Future<ApiResponse<GuestCategory>> updateGuestCategory(int id, String name, String color) async {
    final res = await http.put(
      Uri.parse(ApiUrl.updateGuestCategory(id)),
      headers: await _headers(),
      body: jsonEncode({'name': name, 'color': color}),
    );
    final body = jsonDecode(res.body);
    if (res.statusCode == 200 && body['status'] == true) {
      return ApiResponse(status: true, data: GuestCategory.fromJson(body['data']));
    }
    throw Exception(_parseError(body));
  }

  static Future<void> hapusGuestCategory(int id) async {
    final res = await http.delete(Uri.parse(ApiUrl.deleteGuestCategory(id)), headers: await _headers());
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