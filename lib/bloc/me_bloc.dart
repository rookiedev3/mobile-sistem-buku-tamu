import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_flutter/helpers/api_url.dart';

class MeBloc {
  static Future<Map<String, dynamic>> getMe(String token) async {
    final response = await http.get(
      Uri.parse(ApiUrl.me),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final jsonObj = json.decode(response.body);

    if (response.statusCode != 200 || jsonObj['status'] != true) {
      throw Exception('Token tidak valid atau sudah kedaluwarsa');
    }

    // sesuai AuthApiController::me() → responseHasil(200, true, $request->user())
    return jsonObj['data']; // berisi id, name, email, role, dst
  }
}