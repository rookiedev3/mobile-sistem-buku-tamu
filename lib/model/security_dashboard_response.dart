import 'package:mobile_flutter/model/visit.dart';

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