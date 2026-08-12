import 'dart:convert';
import 'package:mobile_flutter/helpers/api.dart';
import 'package:mobile_flutter/helpers/api_url.dart';
import 'package:mobile_flutter/model/login.dart';

class LoginBloc {
  static Future<Login> login({String? email, String? password}) async {
    String apiUrl = ApiUrl.login;
    var body = {"email": email, "password": password};

    try {
      // 1. Kirim data login ke backend
      var response = await Api().post(apiUrl, body);
      
      // 2. Decode body response
      var jsonObj = json.decode(response.body);
      
      // 3. Ubah menjadi object model Login
      Login loginResult = Login.fromJson(jsonObj);

      // 4. Validasi respons dari CodeIgniter kamu
      if (loginResult.status == false || loginResult.code != 200) {
        throw Exception(jsonObj['message'] ?? "Email atau password salah.");
      }

      return loginResult;
    } catch (error) {
      // Melempar error asli agar bisa ditangkap oleh onError di login_page.dart
      throw Exception(error.toString());
    }
  }
}