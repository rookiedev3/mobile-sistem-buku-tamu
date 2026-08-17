// Class generik buat semua response API yang bentuknya paginated
// (punya field data, meta.current_page, meta.last_page, meta.total).
// Taruh file ini di lib/model/paginated_response.dart, lalu import
// di model manapun yang butuh (laporan_model.dart, riwayat_model.dart,
// followup_model.dart, kunjungan.dart, dst) — tidak perlu nulis ulang
// logic ini tiap bikin model baru.

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

  /// json: seluruh response body yang SUDAH ditransform backend
  /// (punya 'data' & 'meta' di root level).
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

  /// Buat response yang bentuknya paginator Laravel MENTAH (belum di-transform
  /// jadi 'data' + 'meta'), biasanya dibungkus gini di controller:
  ///   return response()->json(['data' => $paginator]);
  /// -> { "data": { "data": [...], "current_page":1, "last_page":5,
  ///                "total":50, "per_page":10 } }
  ///
  /// paginatorJson: WAJIB objek paginator-nya langsung, yaitu json['data']
  ///                dari response body — BUKAN seluruh response body.
  ///                Contoh pemakaian di bloc:
  ///   final body = jsonDecode(response.body) as Map<String, dynamic>;
  ///   final paginator = (body['data'] as Map<String, dynamic>?) ?? {};
  ///   PaginatedResponse<Kunjungan>.fromLaravelPaginator(paginator, Kunjungan.fromJson);
  factory PaginatedResponse.fromLaravelPaginator(
    Map<String, dynamic> paginatorJson,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final list = ((paginatorJson['data'] as List?) ?? [])
        .map((e) => fromJsonT(e as Map<String, dynamic>))
        .toList();

    return PaginatedResponse(
      data: list,
      currentPage: paginatorJson['current_page'] ?? 1,
      lastPage: paginatorJson['last_page'] ?? 1,
      total: paginatorJson['total'] ?? list.length,
      perPage: paginatorJson['per_page'] ?? list.length,
    );
  }
}