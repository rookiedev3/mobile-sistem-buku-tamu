import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_flutter/helpers/api.dart';
import 'package:mobile_flutter/helpers/api_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DashboardAdminBloc {
  /// 1. GET /api/admin/dashboard
  /// Mengambil data statistik & daftar reservasi/kunjungan admin
  static Future<Map<String, dynamic>> getDashboard({
    String dateFilter = 'all',
    String? keyword,
    int page = 1,
  }) async {
    String apiUrl = ApiUrl.adminDashboard(
      dateFilter: dateFilter,
      keyword: keyword,
      page: page,
    );

    try {
      var response = await Api().get(apiUrl);
      var jsonObj = json.decode(response.body);

      if (jsonObj['status'] == false || jsonObj['success'] == false) {
        throw Exception(
          jsonObj['message'] ?? "Gagal mengambil data dashboard admin.",
        );
      }

      return jsonObj['data'];
    } catch (error) {
      throw Exception(error.toString().replaceAll('Exception: ', ''));
    }
  }

  /// 2. GET /api/admin/master-data
  /// Mengambil data dropdown master (PIC, Cabang, Purpose, Kategori, Produk, Lead Source)
  static Future<Map<String, dynamic>> getMasterData() async {
    String apiUrl = ApiUrl.adminMasterData;

    try {
      var response = await Api().get(apiUrl);
      var jsonObj = json.decode(response.body);

      if (jsonObj['status'] == false || jsonObj['success'] == false) {
        throw Exception(jsonObj['message'] ?? "Gagal mengambil data master.");
      }

      return jsonObj['data'];
    } catch (error) {
      throw Exception(error.toString().replaceAll('Exception: ', ''));
    }
  }

  /// 3. POST /api/admin/check-in/{id}
  /// Memproses check-in tamu oleh admin
  static Future<Map<String, dynamic>> checkIn(int id) async {
    String apiUrl = ApiUrl.adminCheckIn(id);

    try {
      var response = await Api().post(apiUrl, {});
      var jsonObj = json.decode(response.body);

      if (jsonObj['status'] == false || jsonObj['success'] == false) {
        throw Exception(jsonObj['message'] ?? "Gagal melakukan check-in.");
      }

      return jsonObj['data'] ?? {};
    } catch (error) {
      throw Exception(error.toString().replaceAll('Exception: ', ''));
    }
  }

  /// 4. POST /api/admin/check-out/{id}
  /// Memproses check-out tamu oleh admin
  static Future<Map<String, dynamic>> checkOut(int id) async {
    String apiUrl = ApiUrl.adminCheckOut(id);

    try {
      var response = await Api().post(apiUrl, {});
      var jsonObj = json.decode(response.body);

      if (jsonObj['status'] == false || jsonObj['success'] == false) {
        throw Exception(jsonObj['message'] ?? "Gagal melakukan check-out.");
      }

      return jsonObj['data'] ?? {};
    } catch (error) {
      throw Exception(error.toString().replaceAll('Exception: ', ''));
    }
  }

  /// 5. POST /api/admin/cancel/{id}
  /// Membatalkan kunjungan/janji temu
  static Future<Map<String, dynamic>> cancel(int id) async {
    String apiUrl = ApiUrl.adminCancel(id);

    try {
      var response = await Api().post(apiUrl, {});
      var jsonObj = json.decode(response.body);

      if (jsonObj['status'] == false || jsonObj['success'] == false) {
        throw Exception(jsonObj['message'] ?? "Gagal membatalkan kunjungan.");
      }

      return jsonObj['data'] ?? {};
    } catch (error) {
      throw Exception(error.toString().replaceAll('Exception: ', ''));
    }
  }

  /// 6. POST /api/admin/store-manual
  /// Input antrian / kunjungan manual oleh admin (termasuk upload foto jika ada)
  static Future<Map<String, dynamic>> storeManual({
    required String name,
    required String companyName,
    required String position,
    required String address,
    required String phone,
    required String email,
    required int guestCategoryId,
    required int assignedTo,
    required int branchId,
    required int purposeId,
    required String scheduledAt,
    required String notes,
    int? productId,
    XFile? photoFile,
  }) async {
    String apiUrl = ApiUrl.adminStoreManual;

    Map<String, String> fields = {
      "name": name,
      "company_name": companyName,
      "position": position,
      "address": address,
      "phone": phone,
      "email": email,
      "guest_category_id": guestCategoryId.toString(),
      "assigned_to": assignedTo.toString(),
      "branch_id": branchId.toString(),
      "purpose_id": purposeId.toString(),
      "scheduled_at": scheduledAt,
      "notes": notes,
    };

    if (productId != null) {
      fields["product_id"] = productId.toString();
    }

    try {
      var response = await Api().postMultipart(
        apiUrl,
        fields,
        file: photoFile,
        fileParamName: 'photo_path',
      );

      var jsonObj = json.decode(response.body);

      if (jsonObj['status'] == false || jsonObj['success'] == false) {
        if (jsonObj['data'] is Map) {
          final errors = jsonObj['data'] as Map;
          final firstError = errors.values.first;
          throw Exception(
            firstError is List ? firstError.first : firstError.toString(),
          );
        }
        throw Exception(
          jsonObj['message'] ?? "Gagal menyimpan data kunjungan manual.",
        );
      }

      return jsonObj['data'];
    } catch (error) {
      throw Exception(error.toString().replaceAll('Exception: ', ''));
    }
  }

  /// 7. GET /api/admin/history
  /// Mengambil data riwayat kunjungan yang telah selesai atau dibatalkan
  static Future<Map<String, dynamic>> getHistory({
    String? date,
    String? keyword,
    int page = 1,
  }) async {
    String apiUrl = ApiUrl.adminHistory(
      date: date,
      keyword: keyword,
      page: page,
    );

    try {
      var response = await Api().get(apiUrl);
      var jsonObj = json.decode(response.body);

      if (jsonObj['status'] == false || jsonObj['success'] == false) {
        throw Exception(
          jsonObj['message'] ?? "Gagal mengambil riwayat kunjungan.",
        );
      }

      return jsonObj['data'];
    } catch (error) {
      throw Exception(error.toString().replaceAll('Exception: ', ''));
    }
  }

  /// 8. GET /api/admin/guest
  /// Mengambil daftar tamu dengan filter VIP & kata kunci pencarian
  static Future<Map<String, dynamic>> getGuests({
    String? vipStatus,
    String? keyword,
    int page = 1,
  }) async {
    String query = 'page=$page';
    if (vipStatus != null && vipStatus.isNotEmpty) {
      query += '&vip=${Uri.encodeComponent(vipStatus)}';
    }
    if (keyword != null && keyword.isNotEmpty) {
      query += '&keyword=${Uri.encodeComponent(keyword)}';
    }

    String apiUrl = '${ApiUrl.baseUrl}/api/admin/guest?$query';

    try {
      var response = await Api().get(apiUrl);
      var jsonObj = json.decode(response.body);

      if (jsonObj['status'] == false || jsonObj['success'] == false) {
        throw Exception(jsonObj['message'] ?? "Gagal mengambil data tamu.");
      }

      return jsonObj['data'];
    } catch (error) {
      throw Exception(error.toString().replaceAll('Exception: ', ''));
    }
  }

  /// 9. POST /api/admin/guest
  /// Menyimpan data tamu baru ke database
  static Future<Map<String, dynamic>> storeGuest({
    required String name,
    required String phone,
    String? email,
    String? companyName,
    String? position,
    String? address,
    required bool isVip,
    XFile? photoFile,
  }) async {
    String apiUrl = '${ApiUrl.baseUrl}/api/admin/guest';

    Map<String, String> fields = {
      "name": name,
      "phone": phone,
      "is_vip": isVip ? "1" : "0",
      "email": email ?? "",
      "company_name": companyName ?? "",
      "position": position ?? "",
      "address": address ?? "",
    };

    try {
      var response = await Api().postMultipart(
        apiUrl,
        fields,
        file: photoFile,
        fileParamName: 'photo',
      );

      var jsonObj = json.decode(response.body);

      if (jsonObj['status'] == false || jsonObj['success'] == false) {
        if (jsonObj['data'] is Map) {
          final errors = jsonObj['data'] as Map;
          final firstError = errors.values.first;
          throw Exception(
            firstError is List ? firstError.first : firstError.toString(),
          );
        }
        throw Exception(jsonObj['message'] ?? "Gagal menambah tamu.");
      }

      return jsonObj['data'];
    } catch (error) {
      throw Exception(error.toString().replaceAll('Exception: ', ''));
    }
  }

  /// PUT /api/admin/guest/{id}/vip
  /// Mengubah status VIP tamu
  static Future<Map<String, dynamic>> updateGuestVip({
    required int guestId,
    required bool isVip,
  }) async {
    String apiUrl = '${ApiUrl.baseUrl}/api/admin/guest/$guestId/vip';

    Map<String, String> body = {
      'is_vip': isVip ? "1" : "0",
    };

    try {
      // Ganti ke Api().put(...) jika di Laravel menggunakan Route::put
      var response = await Api().put(apiUrl, body);
      var jsonObj = json.decode(response.body);

      if (jsonObj['status'] == false || jsonObj['success'] == false) {
        throw Exception(
          jsonObj['message'] ?? "Gagal mengubah status VIP tamu.",
        );
      }

      return jsonObj['data'] ?? {};
    } catch (error) {
      throw Exception(error.toString().replaceAll('Exception: ', ''));
    }
  }
}