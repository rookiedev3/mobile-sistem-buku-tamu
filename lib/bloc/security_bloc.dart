import 'dart:convert';
import 'package:mobile_flutter/helpers/api.dart';
import 'package:mobile_flutter/helpers/api_url.dart';
import 'package:mobile_flutter/model/guest.dart';

class SecurityBloc {
  static Future<SecurityDashboardResponse> dashboard({String? date, int perPage = 10}) async {
    String apiUrl = ApiUrl.securityDashboard(date: date, perPage: perPage);
    var response = await Api().get(apiUrl);
    return SecurityDashboardResponse.fromJson(json.decode(response.body));
  }
}