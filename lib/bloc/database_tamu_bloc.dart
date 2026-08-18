import 'dart:convert';
import 'package:mobile_flutter/helpers/api.dart';
import 'package:mobile_flutter/helpers/api_url.dart';

class DatabaseTamuBloc {
  static Future<Map<String, dynamic>> getDatabaseTamu({
    String? search,
    int page = 1,
    int perPage = 10,
  }) async {
    String apiUrl = ApiUrl.ownerDatabaseTamu(
      search: search,
      page: page,
      perPage: perPage,
    );

    try {
      var response = await Api().get(apiUrl);
      var jsonObj = json.decode(response.body);

      if (jsonObj['status'] == true) {
        return jsonObj;
      } else {
        throw Exception(
          jsonObj['message'] ?? "Gagal memuat data database tamu.",
        );
      }
    } catch (error) {
      throw Exception(error.toString().replaceAll('Exception: ', ''));
    }
  }
}