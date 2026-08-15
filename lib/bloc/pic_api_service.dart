// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:mobile_flutter/helpers/api_url.dart';

// /// Dilempar setiap kali request gagal (network, auth, validasi server, dll)
// /// supaya UI bisa nampilin pesan yang manusiawi, bukan crash.
// class ApiException implements Exception {
//   final String message;
//   final int? statusCode;
//   ApiException(this.message, {this.statusCode});

//   @override
//   String toString() => message;
// }

// class PicApiService {
//   // Ganti key ini kalau kamu simpan token dengan nama lain di local storage.
//   static const String _tokenKey = 'token';

//   Future<String?> _getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_tokenKey);
//   }

//   Future<Map<String, String>> _headers() async {
//     final token = await _getToken();
//     return {
//       'Accept': 'application/json',
//       'Content-Type': 'application/json',
//       if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
//     };
//   }

//   /// Semua response lewat sini dulu supaya:
//   /// - kalau server balikin HTML (mis. error 500 / redirect login), tidak
//   ///   langsung jsonDecode dan crash, tapi jadi ApiException yang rapi.
//   /// - status code non-2xx otomatis jadi ApiException dengan pesan dari server.
//   Map<String, dynamic> _decode(http.Response response) {
//     final contentType = response.headers['content-type'] ?? '';

//     if (!contentType.contains('application/json')) {
//       throw ApiException(
//         'Server tidak memberi respon yang valid (bukan JSON). '
//         'Cek apakah URL API benar / kamu sudah login.',
//         statusCode: response.statusCode,
//       );
//     }

//     late final dynamic decoded;
//     try {
//       decoded = jsonDecode(response.body);
//     } catch (_) {
//       throw ApiException('Gagal membaca respon dari server.', statusCode: response.statusCode);
//     }

//     if (decoded is! Map<String, dynamic>) {
//       throw ApiException('Format respon tidak sesuai.', statusCode: response.statusCode);
//     }

//     if (response.statusCode == 401) {
//       throw ApiException(decoded['message']?.toString() ?? 'Sesi berakhir, silakan login lagi.', statusCode: 401);
//     }

//     if (response.statusCode == 422) {
//       // Laravel validation error: { message: "...", errors: {field: [..]} }
//       final errors = decoded['errors'];
//       String msg = decoded['message']?.toString() ?? 'Data tidak valid.';
//       if (errors is Map && errors.isNotEmpty) {
//         final firstField = errors.values.first;
//         if (firstField is List && firstField.isNotEmpty) {
//           msg = firstField.first.toString();
//         }
//       }
//       throw ApiException(msg, statusCode: 422);
//     }

//     if (response.statusCode >= 400) {
//       throw ApiException(decoded['message']?.toString() ?? 'Terjadi kesalahan pada server.', statusCode: response.statusCode);
//     }

//     return decoded;
//   }

//   Future<Map<String, dynamic>> _get(String url) async {
//     try {
//       final response = await http.get(Uri.parse(url), headers: await _headers());
//       return _decode(response);
//     } on ApiException {
//       rethrow;
//     } catch (e) {
//       throw ApiException('Gagal memuat data. Periksa koneksi Anda.');
//     }
//   }

//   Future<Map<String, dynamic>> _post(String url, Map<String, dynamic> body) async {
//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         headers: await _headers(),
//         body: jsonEncode(body),
//       );
//       return _decode(response);
//     } on ApiException {
//       rethrow;
//     } catch (e) {
//       throw ApiException('Gagal mengirim data. Periksa koneksi Anda.');
//     }
//   }

//   // ---------------------------------------------------------------------
//   // Endpoint-endpoint
//   // ---------------------------------------------------------------------

//   Future<Map<String, dynamic>> fetchDashboard({
//     String filter = 'all',
//     String vipStatus = 'all',
//     String keyword = '',
//     int perPage = 10,
//   }) {
//     final uri = Uri.parse(ApiUrl.picDashboard).replace(queryParameters: {
//       'filter': filter,
//       'vip_status': vipStatus,
//       if (keyword.isNotEmpty) 'keyword': keyword,
//       'per_page': perPage.toString(),
//     });
//     return _get(uri.toString());
//   }

//   Future<Map<String, dynamic>> fetchFollowup({String filter = 'all'}) {
//     final uri = Uri.parse(ApiUrl.picFollowup).replace(queryParameters: {'filter': filter});
//     return _get(uri.toString());
//   }

//   Future<Map<String, dynamic>> fetchRiwayat({
//     String vipStatus = 'all',
//     String keyword = '',
//     int perPage = 10,
//   }) {
//     final uri = Uri.parse(ApiUrl.picRiwayat).replace(queryParameters: {
//       'vip_status': vipStatus,
//       if (keyword.isNotEmpty) 'keyword': keyword,
//       'per_page': perPage.toString(),
//     });
//     return _get(uri.toString());
//   }

//   Future<Map<String, dynamic>> fetchLeads({String filter = 'active', String vipStatus = 'all'}) {
//     final uri = Uri.parse(ApiUrl.picLeads).replace(queryParameters: {
//       'filter': filter,
//       'vip_status': vipStatus,
//     });
//     return _get(uri.toString());
//   }

//   Future<Map<String, dynamic>> updateVisitStatus(int visitId, {required bool confirm}) {
//     return _post(ApiUrl.picUpdateStatus(visitId), {
//       'status': confirm ? 'confirmed' : 'cancelled',
//     });
//   }

//   Future<Map<String, dynamic>> startMeeting(int visitId) {
//     return _post(ApiUrl.picStartMeeting(visitId), {});
//   }

//   Future<Map<String, dynamic>> completeMeeting(
//     int visitId, {
//     required String meetingResult,
//     required String potentialLevel,
//     String? followUpAt,
//     num? estimatedValue,
//   }) {
//     return _post(ApiUrl.picCompleteMeeting(visitId), {
//       'meeting_result': meetingResult,
//       'potential_level': potentialLevel,
//       if (followUpAt != null) 'follow_up_at': followUpAt,
//       if (estimatedValue != null) 'estimated_value': estimatedValue,
//     });
//   }

//   Future<Map<String, dynamic>> updateFollowUp(
//     int leadId, {
//     required String status,
//     required String result,
//     String? dueAt,
//     num? estimatedValue,
//   }) {
//     return _post(ApiUrl.picUpdateFollowUp(leadId), {
//       'status': status,
//       'result': result,
//       if (dueAt != null) 'due_at': dueAt,
//       if (estimatedValue != null) 'estimated_value': estimatedValue,
//     });
//   }
// }