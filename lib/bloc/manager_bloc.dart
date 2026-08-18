import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/api_url.dart';
import '../model/manager_dashboard_model.dart';

class ManagerBloc {
  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? ''; // sesuaikan key token kamu
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Ambil data dashboard manager: kunjungan pada [date] (yyyy-MM-dd) dan filter [vipStatus] ('all'/'vip'/'reguler')
  static Future<ManagerDashboardResponse> dashboard({
    required String date,
    String vipStatus = 'all',
  }) async {
    final url = Uri.parse(ApiUrl.managerDashboard(date, vipStatus));
    final response = await http.get(url, headers: await _headers());

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return ManagerDashboardResponse.fromJson(body);
    } else {
      throw Exception('Gagal memuat dashboard manager (${response.statusCode})');
    }
  }

  /// Tandai 1 notifikasi sebagai dibaca
  static Future<void> markNotificationAsRead(String notifId) async {
    final String url = ApiUrl.adminMarkNotificationRead(int.parse(notifId));
    final response = await http.post(Uri.parse(url), headers: await _headers());

    if (response.statusCode != 200) {
      throw Exception('Gagal menandai notifikasi dibaca.');
    }
  }

  /// Tandai semua notifikasi sebagai dibaca
  static Future<void> markAllNotificationsAsRead() async {
    final String url = ApiUrl.adminMarkAllNotificationsRead;
    final response = await http.post(Uri.parse(url), headers: await _headers());

    if (response.statusCode != 200) {
      throw Exception('Gagal menandai semua notifikasi dibaca.');
    }
  }
}