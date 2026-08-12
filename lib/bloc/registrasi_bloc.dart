import 'dart:convert';
import 'package:mobile_flutter/helpers/api.dart';
import 'package:mobile_flutter/helpers/api_url.dart';
import 'package:mobile_flutter/model/registrasi.dart';

class RegistrasiBloc {
  static Future<Registrasi> registrasi({
    String? name,
    String? email,
    String? phone,
    int? branchId,
    String? password,
    String? passwordConfirmation,
  }) async {
    String apiUrl = ApiUrl.registrasi;

    var body = {
      "name": name,
      "email": email,
      "phone": phone,
      "branch_id": branchId.toString(),
      "password": password,
      "password_confirmation": passwordConfirmation,
    };

    try {
      var response = await Api().post(apiUrl, body);
      var jsonObj = json.decode(response.body);
      var result = Registrasi.fromJson(jsonObj);

      if (result.status == false) {
        // Backend Laravel balikin error validasi sebagai Map (field: [pesan]),
        // bukan String biasa kayak pesan sukses — jadi perlu ditangani terpisah.
        if (jsonObj['data'] is Map) {
          final errors = jsonObj['data'] as Map;
          final firstError = errors.values.first;
          throw Exception(firstError is List ? firstError.first : firstError.toString());
        }
        throw Exception(result.data ?? "Registrasi gagal");
      }

      return result;
    } catch (error) {
      throw Exception(error.toString().replaceAll('Exception: ', ''));
    }
  }
}