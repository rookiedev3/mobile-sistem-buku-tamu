// laporan_model.dart
// Model untuk response GET /api/v1/owner/laporan
// Mengikuti struktur yang dikembalikan PicApiController@laporan:
// { success, data: [...], meta: {...}, summary: {...}, options: { branches, pic_users }, filters: {...} }
//
// Bagian pagination (data/current_page/last_page/total) sekarang pakai
// PaginatedResponse<T> generik dari paginated_response.dart, biar tidak
// nulis ulang logic yang sama di tiap model paginated lain (riwayat,
// followup, leads, dst).

import 'paginated_response.dart';

class OptionItem {
  final int id;
  final String name;

  OptionItem({required this.id, required this.name});

  factory OptionItem.fromJson(Map<String, dynamic> json) => OptionItem(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
        name: json['name'] ?? '-',
      );
}

class LaporanSummary {
  final int totalKunjungan;
  final int totalDeal;
  final int totalVip;
  final double conversionRate;
  final double avgDuration; // dalam menit

  LaporanSummary({
    required this.totalKunjungan,
    required this.totalDeal,
    required this.totalVip,
    required this.conversionRate,
    required this.avgDuration,
  });

  factory LaporanSummary.fromJson(Map<String, dynamic> json) => LaporanSummary(
        totalKunjungan: json['total_kunjungan'] ?? 0,
        totalDeal: json['total_deal'] ?? 0,
        totalVip: json['total_vip'] ?? 0,
        conversionRate: (json['conversion_rate'] as num?)?.toDouble() ?? 0,
        avgDuration: (json['avg_duration'] as num?)?.toDouble() ?? 0,
      );
}

class LaporanItem {
  final int id;
  final String visitCode;
  final String? checkInAt;
  final String? checkOutAt;
  final int? durasiMenit;
  final String? guestName;
  final String? guestPhone;
  final bool isVip;
  final String? branchName;
  final String? picName;
  final String? purposeName;
  final String? productNames;
  final String? sourceName;
  final String? potentialLevel;
  final String? meetingResult;
  final String? status;
  final String? notes;            // dari visits.notes, dipakai untuk "Catatan Hasil"
  final String? leadStatus;       // dari leads.status (new/contacted/negotiation/deal/lost)
  final bool isCompleted;         // flag kunjungan sudah selesai atau belum
  final String? companyName;

  LaporanItem({
    required this.id,
    required this.visitCode,
    this.checkInAt,
    this.checkOutAt,
    this.durasiMenit,
    this.guestName,
    this.guestPhone,
    this.isVip = false,
    this.branchName,
    this.picName,
    this.purposeName,
    this.productNames,
    this.sourceName,
    this.potentialLevel,
    this.meetingResult,
    this.notes,
    this.status,
    this.leadStatus,
    this.isCompleted = false,
    this.companyName,
  });

  factory LaporanItem.fromJson(Map<String, dynamic> json) => LaporanItem(
        id: json['id'],
        visitCode: json['visit_code'] ?? '-',
        checkInAt: json['check_in_at'],
        checkOutAt: json['check_out_at'],
        durasiMenit: json['durasi_menit'] != null
            ? num.tryParse(json['durasi_menit'].toString())?.round()
            : null,
        guestName: json['guest_name'],
        guestPhone: json['guest_phone'],
        isVip: json['is_vip'] == true || json['is_vip'] == 1,
        branchName: json['branch_name'],
        picName: json['pic_name'],
        purposeName: json['purpose_name'],
        productNames: json['product_names'],
        sourceName: json['source_name'],
        potentialLevel: json['potential_level'],
        meetingResult: json['meeting_result'],
        notes: json['notes'],
        status: json['status'],
        companyName: json['company_name'],
        leadStatus: json['lead_status'],
        isCompleted: json['is_completed'] == true ||
            json['is_completed'] == 1 ||
            json['check_out_at'] != null,
      );

  String get kategoriLabel => isVip ? 'VIP' : 'Reguler';
}

class LaporanResponse {
  final PaginatedResponse<LaporanItem> paginated;
  final LaporanSummary summary;
  final List<OptionItem> branches;
  final List<OptionItem> picUsers;

  LaporanResponse({
    required this.paginated,
    required this.summary,
    required this.branches,
    required this.picUsers,
  });

  // Shortcut biar kode yang sudah manggil _laporanResponse.data /
  // .currentPage / .lastPage / .total (di LaporanManagerScreen) tidak
  // perlu diubah sama sekali.
  List<LaporanItem> get data => paginated.data;
  int get currentPage => paginated.currentPage;
  int get lastPage => paginated.lastPage;
  int get total => paginated.total;
  int get perPage => paginated.perPage;
  bool get hasMore => paginated.hasMore;

  factory LaporanResponse.fromJson(Map<String, dynamic> json) {
    final options = (json['options'] as Map<String, dynamic>?) ?? {};

    return LaporanResponse(
      paginated: PaginatedResponse.fromJson(json, LaporanItem.fromJson),
      summary: LaporanSummary.fromJson((json['summary'] as Map<String, dynamic>?) ?? {}),
      branches: ((options['branches'] as List?) ?? [])
          .map((e) => OptionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      picUsers: ((options['pic_users'] as List?) ?? [])
          .map((e) => OptionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}