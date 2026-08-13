import 'dart:convert';
import 'package:mobile_flutter/helpers/api.dart';
import 'package:mobile_flutter/helpers/api_url.dart';
import 'package:mobile_flutter/model/user_list_response.dart';
import 'package:mobile_flutter/model/simple_response.dart';

class UserBloc {
  // status: "pending" | "inactive" | null (semua)
  static Future<UserListResponse> listUsers({String? status}) async {
    String apiUrl = ApiUrl.users(status: status);
    var response = await Api().get(apiUrl);
    return UserListResponse.fromJson(json.decode(response.body));
  }

    static Future<SimpleResponse> create({
    required String name,
    required String email,
    String? phone,
    required String password,
    required String role,
    int? branchId,
    bool isActive = true,
  }) async {
    String apiUrl = ApiUrl.createUser();
    var body = {
      "name": name,
      "email": email,
      "phone": phone ?? '',
      "password": password,
      "role": role,
      "branch_id": branchId?.toString() ?? '',
      "is_active": isActive.toString(),
    };
    var response = await Api().post(apiUrl, body);
    return SimpleResponse.fromJson(json.decode(response.body));
  }

    static Future<SimpleResponse> updateUser({
    required int id,
    required String name,
    required String email,
    String? phone,
    String? password, // kosongkan kalau gak mau ganti password
    required String role,
    int? branchId,
    bool isActive = true,
  }) async {
    String apiUrl = ApiUrl.updateUser(id);
    var body = {
      "name": name,
      "email": email,
      "phone": phone ?? '',
      "role": role,
      "branch_id": branchId?.toString() ?? '',
      "is_active": isActive.toString(),
      if (password != null && password.isNotEmpty) "password": password,
    };
    var response = await Api().put(apiUrl, body);
    return SimpleResponse.fromJson(json.decode(response.body));
  }


  static Future<SimpleResponse> approve({required int id, required String role}) async {
    String apiUrl = ApiUrl.approveUser(id);
    var body = {"role": role};
    var response = await Api().post(apiUrl, body);
    return SimpleResponse.fromJson(json.decode(response.body));
  }

  static Future<SimpleResponse> deactivate({required int id}) async {
    String apiUrl = ApiUrl.deactivateUser(id);
    var response = await Api().post(apiUrl, {});
    return SimpleResponse.fromJson(json.decode(response.body));
  }

  static Future<SimpleResponse> destroy({required int id}) async {
    String apiUrl = ApiUrl.deleteUser(id);
    var response = await Api().delete(apiUrl);
    return SimpleResponse.fromJson(json.decode(response.body));
  }
}