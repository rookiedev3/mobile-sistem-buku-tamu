// import 'dart:convert';
// import 'package:mobile_flutter/helpers/api.dart';
// import 'package:mobile_flutter/helpers/api_url.dart';
// import 'package:mobile_flutter/model/login.dart';
// class LoginBloc {
//   static Future<Login> login({String? email, String? password}) async {
//     String apiUrl = ApiUrl.login;
//     var body = {"email": email, "password": password};

//     try {
//       var response = await Api().post(apiUrl, body);
//       var jsonObj = json.decode(response.body);
//       Login loginResult = Login.fromJson(jsonObj);

//       if (loginResult.status == false || loginResult.code != 200) {
//         throw Exception(jsonObj['data'] ?? "Email atau password salah.");
//       }
//       return loginResult;
//     } catch (error) {
//       // ← TAMBAHAN: coba ekstrak pesan bersih dari body JSON mentah yang
//       // dibungkus di dalam exception (mis. "Unauthorised: {...json...}")
//       String rawMessage = error.toString();
//       String cleanMessage = rawMessage;

//       try {
//         // Cari bagian JSON di dalam pesan error (dimulai dari karakter '{')
//         int jsonStart = rawMessage.indexOf('{');
//         if (jsonStart != -1) {
//           var parsed = json.decode(rawMessage.substring(jsonStart));
//           cleanMessage = parsed['data']?.toString() ?? cleanMessage;
//         }
//       } catch (_) {
//         // Kalau gagal parse, ya sudah, pakai rawMessage apa adanya
//       }

//       throw Exception(cleanMessage.replaceAll('Exception: ', ''));
//     }
//   }
// }

import 'dart:convert';
import 'package:mobile_flutter/helpers/api.dart';
import 'package:mobile_flutter/helpers/api_url.dart';
import 'package:mobile_flutter/model/login.dart';

class LoginBloc {
  static Future<Login> login({
    String? email,
    String? password,
    bool remember = false, // ← ditambahkan sebagai parameter
  }) async {
    String apiUrl = ApiUrl.login;
    var body = {
      "email": email,
      "password": password,
      "remember": remember ? "1" : "0", // ← diganti dari remember.toString()
    };

    try {
      var response = await Api().post(apiUrl, body);
      var jsonObj = json.decode(response.body);
      Login loginResult = Login.fromJson(jsonObj);

      if (loginResult.status == false || loginResult.code != 200) {
        throw Exception(jsonObj['data'] ?? "Email atau password salah.");
      }
      return loginResult;
    } catch (error) {
      // Coba ekstrak pesan bersih dari body JSON mentah yang
      // dibungkus di dalam exception (mis. "Unauthorised: {...json...}")
      String rawMessage = error.toString();
      String cleanMessage = rawMessage;

      try {
        int jsonStart = rawMessage.indexOf('{');
        if (jsonStart != -1) {
          var parsed = json.decode(rawMessage.substring(jsonStart));
          cleanMessage = parsed['data']?.toString() ?? cleanMessage;
        }
      } catch (_) {
        // Kalau gagal parse, ya sudah, pakai rawMessage apa adanya
      }

      throw Exception(cleanMessage.replaceAll('Exception: ', ''));
    }
  }
}