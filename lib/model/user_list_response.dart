import 'package:mobile_flutter/model/user.dart';

class UserListResponse {
  final bool? status;
  final String? message;
  final List<UserModel>? data;

  UserListResponse({this.status, this.message, this.data});

  factory UserListResponse.fromJson(Map<String, dynamic> json) {
    return UserListResponse(
      status: json['status'] as bool?,
      message: json['message'] as String? ?? json['pesan'] as String?,
      data: json['data'] != null
          ? (json['data'] as List).map((i) => UserModel.fromJson(i)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data,
    };
  }
}