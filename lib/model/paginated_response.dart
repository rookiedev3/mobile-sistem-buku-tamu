// Class generik buat semua response API yang bentuknya paginated
// (punya field data, meta.current_page, meta.last_page, meta.total).
// Taruh file ini di lib/model/paginated_response.dart, lalu import
// di model manapun yang butuh (laporan_model.dart, riwayat_model.dart,
// followup_model.dart, dst) — tidak perlu nulis ulang logic ini tiap
// bikin model baru.

class PaginatedResponse<T> {
  final List<T> data;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage; // nilai ASLI dari backend, jangan ditebak/hardcode di Flutter

  bool get hasMore => currentPage < lastPage;

  PaginatedResponse({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.perPage,
  });

  /// json: seluruh response body (yang punya 'data' & 'meta' di root)
  /// fromJsonT: cara ubah 1 item mentah (Map) jadi objek T,
  ///            contoh: LaporanItem.fromJson
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final meta = (json['meta'] as Map<String, dynamic>?) ?? {};
    final list = ((json['data'] as List?) ?? [])
        .map((e) => fromJsonT(e as Map<String, dynamic>))
        .toList();

    return PaginatedResponse(
      data: list,
      currentPage: meta['current_page'] ?? 1,
      lastPage: meta['last_page'] ?? 1,
      total: meta['total'] ?? list.length,
      // fallback ke jumlah item di halaman ini kalau backend belum kirim
      // per_page — tapi idealnya backend SELALU kirim field ini.
      perPage: meta['per_page'] ?? list.length,
    );
  }
}