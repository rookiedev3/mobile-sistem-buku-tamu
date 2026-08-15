import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/api_url.dart';
import '../model/lead_pipeline_model.dart';
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
  // owner_bloc.dart
static Future<ActivityLogResponse> fetchActivityLog({
  String keyword = '',
  int page = 1,
  int perPage = 25,
}) async {
  final uri = Uri.parse(ApiUrl.ownerActivityLog(keyword: keyword, page: page, perPage: perPage));

  final response = await http.get(uri, headers: await _headers());

  if (response.statusCode != 200) {
    throw Exception('Gagal memuat log aktivitas');
  }

  final body = jsonDecode(response.body);
  final items = (body['data'] as List).map((e) => ActivityLogItem.fromJson(e)).toList();
  final meta = body['meta'];

  return ActivityLogResponse(
    items: items,
    currentPage: meta['current_page'],
    lastPage: meta['last_page'],
  );
}
static Future<LeadPipelineResponse> fetchLeads({
    required String filter,
    required String vipStatus,
    String? keyword,
    int page = 1,
  }) async {
    final uri = Uri.parse(
      ApiUrl.ownerLeadsPipeline(filter, vipStatus, keyword: keyword, page: page),
    );
    final response = await http.get(uri, headers: await _headers());

    if (response.statusCode != 200) {
      throw Exception('Gagal memuat data leads (${response.statusCode})');
    }

    return LeadPipelineResponse.fromJson(jsonDecode(response.body));
  }
}

