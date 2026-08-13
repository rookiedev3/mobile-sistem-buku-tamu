import 'dart:convert';
import 'package:mobile_flutter/helpers/api.dart';
import 'package:mobile_flutter/helpers/api_url.dart';
import 'package:mobile_flutter/model/visit.dart'; // ← punya temenmu

class SecurityDashboardResponse {
  bool? success;
  String? selectedDate;
  int? totalToday;
  List<Visit>? data;

  SecurityDashboardResponse({this.success, this.selectedDate, this.totalToday, this.data});

  factory SecurityDashboardResponse.fromJson(Map<String, dynamic> obj) {
    var list = obj['data'] as List;
    return SecurityDashboardResponse(
      success: obj['success'],
      selectedDate: obj['selected_date'],
      totalToday: obj['total_today'],
      data: list.map((e) => Visit.fromJson(e)).toList(),
    );
  }
}

class SecurityBloc {
  static Future<SecurityDashboardResponse> dashboard({String? date}) async {
    String apiUrl = ApiUrl.securityDashboard(date: date);
    var response = await Api().get(apiUrl);
    return SecurityDashboardResponse.fromJson(json.decode(response.body));
  }

  static Future<void> checkIn(int id) async {
    await Api().post(ApiUrl.securityCheckIn(id), {});
  }

  static Future<void> checkOut(int id) async {
    await Api().post(ApiUrl.securityCheckOut(id), {});
  }
}