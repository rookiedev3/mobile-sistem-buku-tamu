// import 'package:shared_preferences/shared_preferences.dart';

// class UserInfo{
//   Future setToken (String value) async {
//     final SharedPreferences pref = await SharedPreferences.getInstance();
//     return pref.setString('token', value);
//   }

//   Future<String?> getToken() async {
//     final SharedPreferences pref = await SharedPreferences.getInstance();
//     return pref.getString('token');
//   }
//   Future setUserId(int value) async {
//     final SharedPreferences pref = await SharedPreferences.getInstance();
//     return pref.setInt('userID', value);
//   }
//   Future<int?> getUserId() async {
//     final SharedPreferences pref = await SharedPreferences.getInstance();
//     return pref.getInt('userID');
//   }
//   Future logout() async {
//     final SharedPreferences pref = await SharedPreferences.getInstance();
//     pref.clear();
//   }
// // }
// class UserInfo {
//   static const _kToken = 'token';
//   static const _kUserId = 'user_id';
//   static const _kRememberMe = 'remember_me';
//   static const _kSavedEmail = 'saved_email';

//   Future<void> setToken(String token) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_kToken, token);
//   }

//   Future<String?> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_kToken);
//   }

//   Future<void> setUserId(int id) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setInt(_kUserId, id);
//   }

//   Future<void> setRememberMe(bool value, {String? email}) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_kRememberMe, value);
//     if (value && email != null) {
//       await prefs.setString(_kSavedEmail, email);
//     } else {
//       await prefs.remove(_kSavedEmail);
//     }
//   }

//   Future<bool> getRememberMe() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getBool(_kRememberMe) ?? false;
//   }

//   Future<String?> getSavedEmail() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_kSavedEmail);
//   }

//   // Dipanggil kalau remember_me == false, supaya token dihapus tiap app dibuka ulang
//   Future<void> clearSession() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_kToken);
//     await prefs.remove(_kUserId);
//   }
//   Future<void> logout() async {
//   final prefs = await SharedPreferences.getInstance();
//   await prefs.remove('token');
//   await prefs.remove('user_id');
//   await prefs.remove('remember_me');   // ← opsional: hapus juga preferensi remember
//   await prefs.remove('saved_email');   // ← opsional
// }
// }
import 'package:shared_preferences/shared_preferences.dart';

class UserInfo {
  static const _kToken = 'token';
  static const _kUserId = 'user_id';
  static const _kRememberMe = 'remember_me';
  static const _kSavedEmail = 'saved_email';

  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kToken);
  }

  Future<void> setUserId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kUserId, id);
  }

  Future<void> setRememberMe(bool value, {String? email}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kRememberMe, value);
    if (value && email != null) {
      await prefs.setString(_kSavedEmail, email);
    } else {
      await prefs.remove(_kSavedEmail);
    }
  }

  Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kRememberMe) ?? false;
  }

  Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kSavedEmail);
  }

  // Dipanggil kalau token ternyata expired/invalid saat auto-login dicoba
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
    await prefs.remove(_kUserId);
  }

  // ← PENTING: logout manual harus hapus SEMUANYA, termasuk remember_me,
  // supaya app benar-benar minta login ulang setelah user sengaja keluar
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
    await prefs.remove(_kUserId);
    await prefs.remove(_kRememberMe);
    await prefs.remove(_kSavedEmail);
  }

  
}