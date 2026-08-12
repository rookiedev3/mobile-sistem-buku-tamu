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