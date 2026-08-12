import 'package:shared_preferences/shared_preferences.dart';

class UserInfo{
  Future setToken (String value) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString('token', value);
  }

  Future<String?> getToken() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString('token');
  }
  Future setUserId(int value) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setInt('userID', value);
  }
  Future<int?> getUserId() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getInt('userID');
  }
  Future logout() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.clear();
  }
  
}