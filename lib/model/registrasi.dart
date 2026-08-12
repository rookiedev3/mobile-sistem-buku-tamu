class Registrasi {
  int? code;
  bool? status;
  String? data; // pesan sukses/gagal dari backend

  Registrasi({this.code, this.status, this.data});

  factory Registrasi.fromJson(Map<String, dynamic> obj) {
    return Registrasi(
      code: obj['code'],
      status: obj['status'],
      data: obj['data'],
    );
  }
}