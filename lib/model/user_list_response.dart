import 'package:mobile_flutter/model/user.dart';

class UserListResponse {
  int? code;
  bool? status;
  List<UserModel>? data;

  UserListResponse({this.code, this.status, this.data});

  factory UserListResponse.fromJson(Map<String, dynamic> obj) {
    var list = obj['data'] as List;
    return UserListResponse(
      code: obj['code'],
      status: obj['status'],
      data: list.map((e) => UserModel.fromJson(e)).toList(),
    );
  }
}