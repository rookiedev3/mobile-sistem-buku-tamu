// lib/bloc/product_bloc.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_flutter/model/product.dart';
import 'package:mobile_flutter/helpers/api_url.dart'; // sesuaikan path
import 'package:shared_preferences/shared_preferences.dart';
import 'branch_bloc.dart' show ApiResponse; // pakai ApiResponse yang sama, jangan didefinisikan ulang

class ProductBloc {
  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<ApiResponse<List<Product>>> daftarProduk() async {
    final res = await http.get(Uri.parse(ApiUrl.listProduk), headers: await _headers());
    final body = jsonDecode(res.body);
    if (res.statusCode == 200 && body['status'] == true) {
      final List data = body['data'];
      return ApiResponse(status: true, data: data.map((e) => Product.fromJson(e)).toList());
    }
    throw Exception(body['data']?.toString() ?? 'Gagal memuat data produk');
  }

  static Future<ApiResponse<Product>> tambahProduk({
    required String code,
    required String name,
    required String category,
    required bool isActive,
  }) async {
    final res = await http.post(
      Uri.parse(ApiUrl.createProduk),
      headers: await _headers(),
      body: jsonEncode({'code': code, 'name': name, 'category': category, 'is_active': isActive}),
    );
    final body = jsonDecode(res.body);
    if (res.statusCode == 200 && body['status'] == true) {
      return ApiResponse(status: true, data: Product.fromJson(body['data']));
    }
    throw Exception(_parseError(body));
  }

  static Future<ApiResponse<Product>> updateProduk({
    required int id,
    required String code,
    required String name,
    required String category,
    required bool isActive,
  }) async {
    final res = await http.put(
      Uri.parse(ApiUrl.updateProduk(id)),
      headers: await _headers(),
      body: jsonEncode({'code': code, 'name': name, 'category': category, 'is_active': isActive}),
    );
    final body = jsonDecode(res.body);
    if (res.statusCode == 200 && body['status'] == true) {
      return ApiResponse(status: true, data: Product.fromJson(body['data']));
    }
    throw Exception(_parseError(body));
  }

  static Future<void> hapusProduk(int id) async {
    final res = await http.delete(Uri.parse(ApiUrl.deleteProduk(id)), headers: await _headers());
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