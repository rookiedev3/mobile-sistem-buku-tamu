class Tamu {
  int? id;
  String? namaTamu;
  String? instansi;
  String? keperluan;
  String? tanggal;

  Tamu({this.id, this.namaTamu, this.instansi, this.keperluan, this.tanggal});

  factory Tamu.fromJson(Map<String, dynamic> obj) {
    return Tamu(
      id: obj['id'] != null ? int.tryParse(obj['id'].toString()) : null,
      namaTamu: obj['nama_tamu'] ?? obj['name'],
      instansi: obj['instansi'] ?? obj['company'],
      keperluan: obj['keperluan'] ?? obj['purpose'],
      tanggal: obj['tanggal'] ?? obj['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_tamu': namaTamu,
      'instansi': instansi,
      'keperluan': keperluan,
    };
  }
}