class KategoriTamuItem {
  final String kategori;
  final int jumlah;
  final double persentase;

  KategoriTamuItem({required this.kategori, required this.jumlah, required this.persentase});

  factory KategoriTamuItem.fromJson(Map<String, dynamic> json) {
    return KategoriTamuItem(
      kategori: json['kategori'] ?? '-',
      jumlah: json['jumlah'] is int ? json['jumlah'] : int.tryParse(json['jumlah'].toString()) ?? 0,
      persentase: json['persentase'] is num
          ? (json['persentase'] as num).toDouble()
          : double.tryParse(json['persentase'].toString()) ?? 0.0,
    );
  }
}

class KategoriTamuResponse {
  final List<KategoriTamuItem> categories;
  final int totalTamu;

  KategoriTamuResponse({required this.categories, required this.totalTamu});

  factory KategoriTamuResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return KategoriTamuResponse(
      categories: (data['categories'] as List? ?? [])
          .map((e) => KategoriTamuItem.fromJson(e))
          .toList(),
      totalTamu: data['total_tamu'] ?? 0,
    );
  }
}