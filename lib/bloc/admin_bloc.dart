import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:mobile_flutter/helpers/api.dart';
import 'package:mobile_flutter/helpers/api_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminBloc {
  // Method untuk menyimpan data janji tamu manual ke database
  static Future<Map<String, dynamic>> storeManual({
    required String name,
    required String companyName,
    required String position,
    required String address,
    required String phone,
    required String email,
    required int guestCategoryId, // Default 1 (Reguler) jika dari form dialog
    required int assignedTo,
    required int branchId,
    required int purposeId,
    int? productId,
    int? sourceId,
    required String scheduledAt,
    required String notes,
    Uint8List? photoBytes,
  }) async {
    Uri url = Uri.parse(ApiUrl.adminStoreManual);
    
    // Gunakan MultipartRequest jika ada pengiriman berkas gambar
    var request = http.MultipartRequest('POST', url);
    
    // Dapatkan token autentikasi (sesuaikan dengan mekanisme auth di app Anda)
    final prefs = await SharedPreferences.getInstance();
String? token = prefs.getString('token');
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.headers['Accept'] = 'application/json';

    // Text fields
    request.fields['name'] = name;
    request.fields['company_name'] = companyName;
    request.fields['position'] = position;
    request.fields['address'] = address;
    request.fields['phone'] = phone;
    request.fields['email'] = email;
    request.fields['guest_category_id'] = guestCategoryId.toString();
    request.fields['assigned_to'] = assignedTo.toString();
    request.fields['branch_id'] = branchId.toString();
    request.fields['purpose_id'] = purposeId.toString();
    request.fields['scheduled_at'] = scheduledAt;
    request.fields['notes'] = notes;

    if (productId != null) {
      request.fields['product_id'] = productId.toString();
    }
    if (sourceId != null) {
      request.fields['source_id'] = sourceId.toString();
    }

    // Attach foto jika ada
    if (photoBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'photo_path',
          photoBytes,
          filename: 'guest_photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    final responseData = json.decode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return responseData;
    } else {
      String errorMessage = responseData['message'] ?? 'Gagal menyimpan data janji tamu.';
      throw Exception(errorMessage);
    }
  }
}