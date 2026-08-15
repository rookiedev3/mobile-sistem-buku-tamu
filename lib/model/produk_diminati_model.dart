class ProdukDiminatiItem {
  final String nama;
  final int jumlah;
  final double persentase;

  ProdukDiminatiItem({required this.nama, required this.jumlah, required this.persentase});

  factory ProdukDiminatiItem.fromJson(Map<String, dynamic> json) {
    return ProdukDiminatiItem(
      nama: json['nama'] ?? '-',
      jumlah: json['jumlah'] is int ? json['jumlah'] : int.tryParse(json['jumlah'].toString()) ?? 0,
      persentase: json['persentase'] is num
          ? (json['persentase'] as num).toDouble()
          : double.tryParse(json['persentase'].toString()) ?? 0.0,
    );
  }
}

class ProdukDiminatiResponse {
  final List<ProdukDiminatiItem> products;
  final int totalPeminatan;

  ProdukDiminatiResponse({required this.products, required this.totalPeminatan});

  factory ProdukDiminatiResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return ProdukDiminatiResponse(
      products: (data['products'] as List? ?? [])
          .map((e) => ProdukDiminatiItem.fromJson(e))
          .toList(),
      totalPeminatan: data['total_peminatan'] ?? 0,
    );
  }
}