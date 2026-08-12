class SimpleResponse {
  int? code;
  bool? status;
  dynamic data; // bisa string pesan, atau object user hasil update

  SimpleResponse({this.code, this.status, this.data});

  factory SimpleResponse.fromJson(Map<String, dynamic> obj) {
    return SimpleResponse(code: obj['code'], status: obj['status'], data: obj['data']);
  }
}