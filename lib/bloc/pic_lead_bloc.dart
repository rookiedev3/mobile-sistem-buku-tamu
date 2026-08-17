import 'dart:convert';
import '../helpers/api.dart';
import '../helpers/api_url.dart';
import '../model/pic_model.dart'; // sesuaikan path sesuai lokasi file model kamu

/// Bloc statis untuk fitur Pipeline Lead (LeadPICScreen).
/// Mengikuti pola Api() + ApiUrl seperti UserBloc.
class PicLeadBloc {
  /// GET /api/pic/leads
  ///
  /// Melempar Exception dengan pesan asli kalau gagal, supaya UI bisa
  /// menampilkan penyebab sebenarnya (bukan pesan generik). Screen yang
  /// memanggil ini WAJIB membungkusnya dengan try-catch dan menampilkan
  /// e.toString() ke user (lihat contoh di bawah file ini).
  static Future<PicLeadsResponse> fetchLeads({
    String filter = 'active',
    String vipStatus = 'all',
    int page = 1,
    int perPage = 10, // <-- ditambahkan: tanpa ini, ApiUrl.picLeads() selalu
                       // jatuh ke default perPage=10-nya sendiri, gak peduli
                       // berapa pun yang mau dipakai screen (sama kasusnya
                       // kayak DashboardPICScreen sebelum di-fix).
  }) async {
    final response = await Api().get(
      ApiUrl.picLeads(
        filter: filter,
        vipStatus: vipStatus,
        page: page,
        perPage: perPage, // <-- diteruskan
      ),
    );

    if (response == null) {
      // Api().get() balikin null biasanya berarti gagal konek sama sekali
      // (SocketException / timeout) — dicek duluan sebelum decode.
      throw Exception('Tidak bisa terhubung ke server. Periksa koneksi/base URL.');
    }

    print('[PicLeadBloc.fetchLeads] status=${response.statusCode} body=${response.body}');

    late final Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      // Body bukan JSON valid — biasanya ini HTML error page dari Laravel
      // (misal error 500 tanpa APP_DEBUG, atau redirect ke halaman login).
      throw Exception(
        'Respons server tidak valid (status ${response.statusCode}). '
        'Body: ${response.body.length > 300 ? response.body.substring(0, 300) + "..." : response.body}',
      );
    }

    // PENTING: backend (responseHasil()) memakai key 'status' sebagai
    // flag sukses (bukan 'success'), dan isi datanya ada di dalam
    // decoded['data'] (bukan langsung di root). Contoh bentuk asli:
    // {"code":200,"status":true,"data":{"data":[...],"counts":{...}}}
    if (decoded['status'] != true) {
      final msg = decoded['message'] ??
          decoded['error_message'] ??
          'Gagal memuat data lead (status ${response.statusCode}).';
      throw Exception(msg);
    }

    // PENTING: jangan unwrap 'data' di sini — PicLeadsResponse.fromJson()
    // sudah melakukan unwrap sendiri (json['data'] ?? json). Kirim
    // `decoded` utuh supaya tidak ke-unwrap dua kali (yang menyebabkan
    // 'counts' diakses di atas List, bukan Map).
    return PicLeadsResponse.fromJson(decoded);
  }

  /// POST /api/pic/leads/{id}/follow-up
  ///
  /// Melempar Exception dengan pesan asli kalau gagal.
  static Future<void> updateFollowUp({
    required int leadId,
    required String status,
    String? result,
    num? estimatedValue,
    String? dueAt,
  }) async {
    final response = await Api().post(ApiUrl.picLeadFollowUp(leadId), {
      'status': status,
      if (result != null) 'result': result,
      if (estimatedValue != null) 'estimated_value': estimatedValue.toString(),
      if (dueAt != null) 'due_at': dueAt,
    });

    if (response == null) {
      throw Exception('Tidak bisa terhubung ke server. Periksa koneksi/base URL.');
    }

    print('[PicLeadBloc.updateFollowUp] status=${response.statusCode} body=${response.body}');

    late final Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception(
        'Respons server tidak valid (status ${response.statusCode}). '
        'Body: ${response.body.length > 300 ? response.body.substring(0, 300) + "..." : response.body}',
      );
    }

    if (decoded['status'] != true) {
      final msg = decoded['message'] ??
          decoded['error_message'] ??
          'Gagal memperbarui follow-up (status ${response.statusCode}).';
      throw Exception(msg);
    }
  }
}