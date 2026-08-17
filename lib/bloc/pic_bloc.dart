import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/api_url.dart';
import '../model/pic_model.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class PicBloc {
  static Future<Map<String, String>> _headers({bool json = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? ''; // sesuaikan key token kamu
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
    if (json) headers['Content-Type'] = 'application/json';
    return headers;
  }

  /// Melempar ApiException dengan pesan dari body JSON kalau ada (field
  /// 'message' atau 'errors' hasil validasi Laravel), supaya UI bisa
  /// langsung tampilkan pesan error backend (mis. "Status sudah akhir dan
  /// tidak dapat diubah lagi.").
  static Never _throwFromResponse(http.Response response) {
    String message = 'Terjadi kesalahan (${response.statusCode})';
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['message'] != null && (body['message'] as String).isNotEmpty) {
        message = body['message'];
      } else if (body is Map && body['errors'] != null) {
        final errors = body['errors'] as Map;
        final firstList = errors.values.first;
        if (firstList is List && firstList.isNotEmpty) {
          message = firstList.first.toString();
        }
      }
    } catch (_) {
      // biarkan pesan default di atas
    }
    throw ApiException(message, statusCode: response.statusCode);
  }

  /// GET /api/pic/dashboard
  static Future<PicDashboardResponse> dashboard({
    String filter = 'all',
    String vipStatus = 'all',
    String? keyword,
    int page = 1,
    int perPage = 10,
  }) async {
    final url = Uri.parse(ApiUrl.picDashboard(
      filter: filter,
      vipStatus: vipStatus,
      keyword: keyword,
      page: page,
      perPage: perPage,
    ));
    final response = await http.get(url, headers: await _headers());

    // ===== DEBUG: cek URL & response mentah dari endpoint dashboard =====
    // Hapus 3 baris print ini kalau sudah selesai debugging.
    print('DASHBOARD URL: $url');
    print('DASHBOARD STATUS: ${response.statusCode}');
    print('DASHBOARD BODY: ${response.body}');
    // ===== END DEBUG =====

    if (response.statusCode == 200) {
      return PicDashboardResponse.fromJson(jsonDecode(response.body));
    }
    _throwFromResponse(response);
  }

  /// GET /api/pic/followup
  static Future<PicFollowupResponse> followup({
    String filter = 'all',
    String? startDate,
    String? endDate,
    int page = 1,
    int perPage = 10,
  }) async {
    final url = Uri.parse(ApiUrl.picFollowup(
      filter: filter,
      startDate: startDate,
      endDate: endDate,
      page: page,
      perPage: perPage,
    ));
    final response = await http.get(url, headers: await _headers());

    if (response.statusCode == 200) {
      return PicFollowupResponse.fromJson(jsonDecode(response.body));
    }
    _throwFromResponse(response);
  }

  /// GET /api/pic/riwayat
  static Future<PicRiwayatResponse> riwayat({
    String? keyword,
    String? startDate,
    String? endDate,
    String vipStatus = 'all',
    int page = 1,
    int perPage = 10,
  }) async {
    final url = Uri.parse(ApiUrl.picRiwayat(
      keyword: keyword,
      startDate: startDate,
      endDate: endDate,
      vipStatus: vipStatus,
      page: page,
      perPage: perPage,
    ));
    final response = await http.get(url, headers: await _headers());

    if (response.statusCode == 200) {
      return PicRiwayatResponse.fromJson(jsonDecode(response.body));
    }
    _throwFromResponse(response);
  }

  /// GET /api/pic/leads
  static Future<PicLeadsResponse> leadsIndex({
    String filter = 'active',
    String vipStatus = 'all',
    String? startDate,
    String? endDate,
    int page = 1,
    int perPage = 10,
  }) async {
    final url = Uri.parse(ApiUrl.picLeads(
      filter: filter,
      vipStatus: vipStatus,
      startDate: startDate,
      endDate: endDate,
      page: page,
      perPage: perPage,
    ));
    final response = await http.get(url, headers: await _headers());

    if (response.statusCode == 200) {
      return PicLeadsResponse.fromJson(jsonDecode(response.body));
    }
    _throwFromResponse(response);
  }

  /// POST /api/pic/visits/{id}/status
  /// [status] diisi 'confirmed' (atau 'Dikonfirmasi') untuk konfirmasi,
  /// selain itu dianggap pembatalan.
  static Future<PicVisitModel> updateStatus({
    required int id,
    required String status,
  }) async {
    final url = Uri.parse(ApiUrl.picUpdateStatus(id));
    final response = await http.post(
      url,
      headers: await _headers(json: true),
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = body['data'] ?? body;
      return PicVisitModel.fromJson(data['visit']);
    }
    _throwFromResponse(response);
  }

  /// POST /api/pic/visits/{id}/start-meeting
  static Future<PicVisitModel> startMeeting(int id) async {
    final url = Uri.parse(ApiUrl.picStartMeeting(id));
    final response = await http.post(url, headers: await _headers());

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = body['data'] ?? body;
      return PicVisitModel.fromJson(data['visit']);
    }
    _throwFromResponse(response);
  }

  /// POST /api/pic/visits/{id}/complete-meeting
  /// [potentialLevel] salah satu dari: hot, warm, cold, non_lead, deal.
  static Future<PicVisitModel> completeMeeting({
    required int id,
    required String meetingResult,
    required String potentialLevel,
    String? followUpAt, // format 'yyyy-MM-dd', wajib kecuali warm/cold/non_lead/deal
    num? estimatedValue, // wajib > 0 kalau potentialLevel == 'deal'
  }) async {
    final url = Uri.parse(ApiUrl.picCompleteMeeting(id));
    final response = await http.post(
      url,
      headers: await _headers(json: true),
      body: jsonEncode({
        'meeting_result': meetingResult,
        'potential_level': potentialLevel,
        if (followUpAt != null) 'follow_up_at': followUpAt,
        if (estimatedValue != null) 'estimated_value': estimatedValue,
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = body['data'] ?? body;
      return PicVisitModel.fromJson(data['visit']);
    }
    _throwFromResponse(response);
  }

  /// POST /api/pic/leads/{leadId}/follow-up
  /// [status] salah satu dari: new, contacted, negotiation, deal, lost.
  static Future<PicLeadModel> updateFollowUp({
    required int leadId,
    required String status,
    required String result,
    String? dueAt, // format 'yyyy-MM-dd'
    num? estimatedValue, // wajib > 0 kalau status == 'deal'
  }) async {
    final url = Uri.parse(ApiUrl.picUpdateFollowUp(leadId));
    final response = await http.post(
      url,
      headers: await _headers(json: true),
      body: jsonEncode({
        'status': status,
        'result': result,
        if (dueAt != null) 'due_at': dueAt,
        if (estimatedValue != null) 'estimated_value': estimatedValue,
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final data = body['data'] ?? body;
      return PicLeadModel.fromJson(data['lead']);
    }
    _throwFromResponse(response);
  }
}