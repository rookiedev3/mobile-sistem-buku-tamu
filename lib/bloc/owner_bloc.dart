import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/api_url.dart';
import '../model/dashboard_owner_model.dart';

class DashboardOwnerBloc {
  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {'Accept': 'application/json', 'Authorization': 'Bearer $token'};
  }

  static Future<DashboardOwnerResponse> fetch({
    String? status,
    String? picId,
    String? keyword,
    bool leadOnly = false,
  }) async {
    final queryParams = <String, String>{};
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (picId != null && picId.isNotEmpty) queryParams['pic_id'] = picId;
    if (keyword != null && keyword.isNotEmpty) queryParams['keyword'] = keyword;
    if (leadOnly) queryParams['lead_only'] = '1';

    final uri = Uri.parse(ApiUrl.ownerDashboard()).replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: await _headers());

    if (response.statusCode == 200) {
      return DashboardOwnerResponse.fromJson(jsonDecode(response.body));
    }
    throw Exception('Gagal memuat dashboard owner (${response.statusCode})');
  }
}