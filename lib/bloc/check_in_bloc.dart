import 'dart:convert';
import 'package:mobile_flutter/helpers/api.dart';
import 'package:mobile_flutter/helpers/api_url.dart';
import 'package:mobile_flutter/model/check_in.dart';
import 'package:image_picker/image_picker.dart';

class CheckInBloc {
  /// 1. GET /api/check-in/form-data
  /// Mengambil data master dropdown (Kategori, PIC, Cabang, Purpose, Product, Source)
  static Future<CheckInMasterData> getFormData() async {
    String apiUrl = ApiUrl.checkInFormData;

    try {
      var response = await Api().get(apiUrl);
      var jsonObj = json.decode(response.body);

      if (jsonObj['success'] == false) {
        throw Exception(jsonObj['message'] ?? "Gagal mengambil data formulir.");
      }

      return CheckInMasterData.fromJson(jsonObj['data']);
    } catch (error) {
      throw Exception(error.toString().replaceAll('Exception: ', ''));
    }
  }

  /// 2. POST /api/check-in/validate-step1
  /// Validasi identitas tamu di Step 1 secara opsional
  static Future<bool> validateStep1({
    required String name,
    required String companyName,
    required String email,
    required String guestCategoryId,
    required String position,
    required String phone,
    String? address,
  }) async {
    String apiUrl = ApiUrl.checkInValidateStep1;

    var body = {
      "name": name,
      "company_name": companyName,
      "address": address ?? "",
      "email": email,
      "guest_category_id": guestCategoryId,
      "position": position,
      "phone": phone,
    };

    try {
      var response = await Api().post(apiUrl, body);
      var jsonObj = json.decode(response.body);

      if (jsonObj['success'] == false) {
        if (jsonObj['data'] is Map) {
          final errors = jsonObj['data'] as Map;
          final firstError = errors.values.first;
          throw Exception(firstError is List ? firstError.first : firstError.toString());
        }
        throw Exception(jsonObj['message'] ?? "Validasi Step 1 gagal.");
      }

      return true;
    } catch (error) {
      throw Exception(error.toString().replaceAll('Exception: ', ''));
    }
  }

  /// 3. POST /api/check-in
  /// Submit akhir gabungan Step 1 & Step 2 (Termasuk Upload Foto)
  static Future<CheckInResult> store({
    required String name,
    required String companyName,
    required String email,
    required String guestCategoryId,
    required String position,
    required String phone,
    required int assignedTo,
    required int branchId,
    required int purposeId,
    required String scheduledAt,
    required String notes,
    String? address,
    XFile? photoFile,
    List<int>? productInterest,
    int? sourceId,
  }) async {
    String apiUrl = ApiUrl.checkInStore;

    // Menyiapkan teks fields
    Map<String, String> fields = {
      "name": name,
      "company_name": companyName,
      "address": address ?? "",
      "email": email,
      "guest_category_id": guestCategoryId,
      "position": position,
      "phone": phone,
      "assigned_to": assignedTo.toString(),
      "branch_id": branchId.toString(),
      "purpose_id": purposeId.toString(),
      "scheduled_at": scheduledAt,
      "notes": notes,
    };

    if (sourceId != null) {
      fields["source_id"] = sourceId.toString();
    }

    // Mengirim array product_interest[]
    if (productInterest != null && productInterest.isNotEmpty) {
      for (int i = 0; i < productInterest.length; i++) {
        fields["product_interest[$i]"] = productInterest[i].toString();
      }
    }

    try {
      // Memanggil method Api().postMultipart
      var response = await Api().postMultipart(
        apiUrl,
        fields,
        file: photoFile,
        fileParamName: 'photo_path',
      );

      var jsonObj = json.decode(response.body);
      var result = CheckInResult.fromJson(jsonObj);

      if (result.success == false) {
        throw Exception(result.message ?? "Gagal memproses check-in.");
      }

      return result;
    } catch (error) {
      throw Exception(error.toString().replaceAll('Exception: ', ''));
    }
  }

  /// 4. GET /api/check-in/{id}
  /// Mengambil detail kunjungan / tiket bukti check-in
  static Future<Map<String, dynamic>> show(int id) async {
    String apiUrl = ApiUrl.checkInDetail(id);

    try {
      var response = await Api().get(apiUrl);
      var jsonObj = json.decode(response.body);

      if (jsonObj['success'] == false) {
        throw Exception(jsonObj['message'] ?? "Data kunjungan tidak ditemukan.");
      }

      return jsonObj['data'];
    } catch (error) {
      throw Exception(error.toString().replaceAll('Exception: ', ''));
    }
  }
} 