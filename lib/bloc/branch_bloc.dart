// lib/bloc/branch_bloc.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_flutter/model/branch.dart';
import 'package:mobile_flutter/helpers/api_url.dart'; // sesuaikan path ApiUrl kamu
import 'package:shared_preferences/shared_preferences.dart';

class ApiResponse<T> {
  final bool status;
  final T? data;
  final String? message;
  ApiResponse({required this.status, this.data, this.message});
}

class BranchBloc {
  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<ApiResponse<List<Branch>>> daftarBranch() async {
    final res = await http.get(Uri.parse(ApiUrl.listBranch), headers: await _headers());
    final body = jsonDecode(res.body);
    if (res.statusCode == 200 && body['status'] == true) {
      final List data = body['data'];
      return ApiResponse(status: true, data: data.map((e) => Branch.fromJson(e)).toList());
    }
    throw Exception(body['data']?.toString() ?? 'Gagal memuat data branch');
  }

  static Future<ApiResponse<Branch>> tambahBranch({
    required String code,
    required String name,
    required String address,
    required String phone,
    required bool isActive,
  }) async {
    final res = await http.post(
      Uri.parse(ApiUrl.createBranch),
      headers: await _headers(),
      body: jsonEncode({
        'code': code, 'name': name, 'address': address, 'phone': phone, 'is_active': isActive,
      }),
    );
    final body = jsonDecode(res.body);
    if (res.statusCode == 200 && body['status'] == true) {
      return ApiResponse(status: true, data: Branch.fromJson(body['data']));
    }
    throw Exception(_parseError(body));
  }

  static Future<ApiResponse<Branch>> updateBranch({
    required int id,
    required String code,
    required String name,
    required String address,
    required String phone,
    required bool isActive,
  }) async {
    final res = await http.put(
      Uri.parse(ApiUrl.updateBranch(id)),
      headers: await _headers(),
      body: jsonEncode({
        'code': code, 'name': name, 'address': address, 'phone': phone, 'is_active': isActive,
      }),
    );
    final body = jsonDecode(res.body);
    if (res.statusCode == 200 && body['status'] == true) {
      return ApiResponse(status: true, data: Branch.fromJson(body['data']));
    }
    throw Exception(_parseError(body));
  }

  static Future<void> hapusBranch(int id) async {
    final res = await http.delete(Uri.parse(ApiUrl.deleteBranch(id)), headers: await _headers());
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