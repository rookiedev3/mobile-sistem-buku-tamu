import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/api_url.dart';
import '../model/lead_pipeline_model.dart';

class PipelineBloc {
  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {'Accept': 'application/json', 'Authorization': 'Bearer $token'};
  }

static Future<LeadPipelineResponse> list({
  required String filter,
  String vipStatus = 'all',
  String? keyword,
  int page = 1,
}) async {
  final url = Uri.parse(ApiUrl.managerLeadsPipeline(filter, vipStatus, keyword: keyword, page: page));
  final response = await http.get(url, headers: await _headers());

  print('URL: $url');
  print('STATUS: ${response.statusCode}');
  print('BODY: ${response.body}');

  if (response.statusCode == 200) {
    return LeadPipelineResponse.fromJson(jsonDecode(response.body));
  }
  throw Exception('Gagal memuat pipeline lead (${response.statusCode})');
}}