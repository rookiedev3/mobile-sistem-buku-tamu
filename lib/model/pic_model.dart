/// Helper parsing aman untuk field numerik yang bisa datang dari backend
/// sebagai int, double, String (mis. kolom decimal Laravel dikirim sebagai
/// "600000.00"), atau null. Selalu pakai helper ini untuk field num/int,
/// jangan assign langsung dari json[...] karena tipe runtime-nya tidak
/// dijamin sama dengan tipe field di model (itu penyebab error
/// "type 'String' is not a subtype of type 'num?'").
num? _asNum(dynamic v) {
  if (v == null) return null;
  if (v is num) return v;
  if (v is String) return num.tryParse(v);
  return null;
}

int _asInt(dynamic v, [int fallback = 0]) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? num.tryParse(v)?.toInt() ?? fallback;
  return fallback;
}

/// Cek apakah string tanggal dari backend valid (bukan null, kosong, atau
/// placeholder MySQL zero-date "0000-00-00 00:00:00"). Kolom datetime yang
/// belum diisi kadang dikirim MySQL sebagai zero-date, bukan null — kalau
/// tidak difilter, ini yang bikin UI menampilkan "0000" di layar.
bool _isValidDateString(String? v) {
  if (v == null || v.isEmpty) return false;
  if (v.startsWith('0000')) return false;
  return DateTime.tryParse(v) != null;
}

/// Model untuk satu entri follow_ups, dipakai di dalam PicVisitModel &
/// PicLeadModel (field `follow_ups` di mapVisit()/mapLead() backend).
class FollowUpItem {
  final int id;
  final String? result;
  final String? status;
  final String? dueAt;
  final num? estimatedValue;
  final String? createdAt;

  FollowUpItem({
    required this.id,
    this.result,
    this.status,
    this.dueAt,
    this.estimatedValue,
    this.createdAt,
  });

  factory FollowUpItem.fromJson(Map<String, dynamic> json) {
    return FollowUpItem(
      id: _asInt(json['id']),
      result: json['result'],
      status: json['status'],
      dueAt: json['due_at'],
      estimatedValue: _asNum(json['estimated_value']),
      createdAt: json['created_at'],
    );
  }
}

/// Cocok dengan payload PicApiController::mapVisit()
class PicVisitModel {
  final int id;
  final String? visitCode;
  final String? guestName;
  final String? guestPosition;
  final String? companyName;
  final bool isVip;
  final String? categoryName;
  final String? categoryColor;
  final String? purposeName;
  final int? branchId;
  final String? branchName;
  final String? status;
  final String? scheduledAt;
  final String? checkInAt;
  final String? checkOutAt;
  final String? meetingStartAt;
  final String? notes;
  final String? meetingResult;
  final String? potentialLevel;
  final String? leadStatus;
  final num? estimatedValue;
  final String? followUpAt;
  final List<FollowUpItem> followUps;

  PicVisitModel({
    required this.id,
    this.visitCode,
    this.guestName,
    this.guestPosition,
    this.companyName,
    this.isVip = false,
    this.categoryName,
    this.categoryColor,
    this.purposeName,
    this.branchId,
    this.branchName,
    this.status,
    this.scheduledAt,
    this.checkInAt,
    this.checkOutAt,
    this.meetingStartAt,
    this.notes,
    this.meetingResult,
    this.potentialLevel,
    this.leadStatus,
    this.estimatedValue,
    this.followUpAt,
    this.followUps = const [],
  });

  factory PicVisitModel.fromJson(Map<String, dynamic> json) {
    return PicVisitModel(
      id: _asInt(json['id']),
      visitCode: json['visit_code'],
      guestName: json['guest_name'],
      guestPosition: json['guest_position'],
      companyName: json['company_name'],
      isVip: json['is_vip'] == true || json['is_vip'] == 1,
      categoryName: json['category_name'],
      categoryColor: json['category_color'],
      purposeName: json['purpose_name'],
      branchId: json['branch_id'] != null ? _asInt(json['branch_id']) : null,
      branchName: json['branch_name'],
      status: json['status'],
      scheduledAt: json['scheduled_at'],
      checkInAt: json['check_in_at'],
      checkOutAt: json['check_out_at'],
      meetingStartAt: json['meeting_start_at'],
      notes: json['notes'],
      meetingResult: json['meeting_result'],
      potentialLevel: json['potential_level'],
      leadStatus: json['lead_status'],
      estimatedValue: _asNum(json['estimated_value']),
      followUpAt: json['follow_up_at'],
      followUps: (json['follow_ups'] as List? ?? [])
          .map((f) => FollowUpItem.fromJson(f))
          .toList(),
    );
  }

  /// [DEPRECATED] Waktu mentah tanpa format & tanpa filter zero-date.
  /// Dipertahankan supaya tidak merusak kode lama yang mungkin masih
  /// memanggilnya, tapi UI seharusnya pakai [formattedTime].
  String get displayTime => scheduledAt ?? checkInAt ?? '-';

  // ------------------------- getter turunan (UI) -------------------------

  String get kategori => isVip ? 'VIP' : 'Reguler';

  /// Token antrian yang ditampilkan. Backend belum punya kolom `token`
  /// terpisah, jadi sementara pakai visit_code. Kalau ada kolom token
  /// khusus, tambahkan 'token' => $v->token di PicApiController::mapVisit().
  String? get token => visitCode;

  String get statusLower => (status ?? '').toLowerCase();

  bool get isConfirmed =>
      ['dikonfirmasi', 'sedang bertemu', 'meeting selesai'].contains(statusLower);

  bool get isMeeting => statusLower == 'sedang bertemu';

  bool get isFinished => statusLower == 'meeting selesai';

  /// Dipakai untuk teks status & penentu aksi tombol.
  String get statusKonfirmasi => status ?? '';

  /// Alias field agar cocok dengan istilah di UI ("Jenis kunjungan").
  String? get purposeType => purposeName;

  /// Backend belum punya kolom "keperluan" terpisah dari notes — sementara
  /// pakai notes yang sama dengan yang dipakai di dialog "Catatan Tamu".
  String? get purposeDetail => notes;

  /// follow_up_at diparse jadi DateTime untuk keperluan date picker di UI.
  DateTime? get followUpDate =>
      followUpAt != null ? DateTime.tryParse(followUpAt!) : null;

  /// True kalau visit masih berstatus "Terjadwal" — artinya tamu belum
  /// check-in sama sekali. Sama persis dengan kondisi
  /// `$statusLower === 'terjadwal'` di pic/partials/_dashboard_panel.blade.php.
  bool get isScheduled => statusLower == 'terjadwal';

  /// True kalau tombol konfirmasi (✓/✕) boleh tampil — yaitu saat visit
  /// sudah check-in tapi PIC belum konfirmasi kehadiran. Sama persis dengan
  /// kondisi `in_array($statusLower, ['pending', 'waiting', 'menunggu'])`
  /// di Blade. SENGAJA tidak pakai check_in_at karena kolom itu ternyata
  /// tidak dipakai sebagai penanda "sudah check-in" di backend — status-lah
  /// satu-satunya sumber kebenaran di sini.
  bool get canConfirm => ['pending', 'waiting', 'menunggu'].contains(statusLower);

  /// Waktu kunjungan yang sudah diformat rapi untuk UI, dan aman dari
  /// zero-date MySQL ("0000-00-00 00:00:00") yang sebelumnya bikin
  /// tampilan waktu jadi "0000". Prioritas: check_in_at, lalu scheduled_at.
  String get formattedTime {
    final raw = _isValidDateString(checkInAt)
        ? checkInAt
        : (_isValidDateString(scheduledAt) ? scheduledAt : null);
    if (raw == null) return '-';

    final dt = DateTime.tryParse(raw);
    if (dt == null) return '-';

    const bulan = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final jam = dt.hour.toString().padLeft(2, '0');
    final menit = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${bulan[dt.month]} ${dt.year}, $jam:$menit WIB';
  }
}

/// Cocok dengan payload PicApiController::mapLead()
class PicLeadModel {
  final int id;
  final String? visitCode;
  final String? guestName;
  final String? guestPosition;
  final String? companyName;
  final bool isVip;
  final String? status;
  final String? potentialLevel;
  final num? estimatedValue;
  final String? followUpAt;
  final String? notes;
  final String? meetingResult;
  final List<FollowUpItem> followUps;
    final String? guestPhone; // ← tambahan

  PicLeadModel({
    required this.id,
    this.visitCode,
    this.guestName,
    this.guestPosition,
    this.companyName,
    this.isVip = false,
    this.status,
    this.potentialLevel,
    this.estimatedValue,
    this.followUpAt,
    this.notes,
    this.meetingResult,
    this.followUps = const [],
        this.guestPhone,

  });

  factory PicLeadModel.fromJson(Map<String, dynamic> json) {
    return PicLeadModel(
      id: _asInt(json['id']),
      visitCode: json['visit_code'],
      guestName: json['guest_name'],
      guestPosition: json['guest_position'],
      companyName: json['company_name'],
      isVip: json['is_vip'] == true || json['is_vip'] == 1,
      status: json['status'],
      potentialLevel: json['potential_level'],
      estimatedValue: _asNum(json['estimated_value']),
      followUpAt: json['follow_up_at'],
      notes: json['notes'],
      guestPhone: json['guest_phone'] ?? json['phone'], // sesuaikan key aslinya
      meetingResult: json['meeting_result'],
      followUps: (json['follow_ups'] as List? ?? [])
          .map((f) => FollowUpItem.fromJson(f))
          .toList(),
    );
  }
}

/// GET /api/pic/dashboard
class PicDashboardResponse {
  final List<PicVisitModel> visits;
  final int currentPage;
  final int lastPage;
  final int total;
  final int vipCount;
  final int regularCount;
  final int countToday;
  final int countUpcoming;
  final String filter;
  final String vipStatus;
  final List<dynamic> notifications;
  final int unreadNotifications;

  PicDashboardResponse({
    required this.visits,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.vipCount,
    required this.regularCount,
    required this.countToday,
    required this.countUpcoming,
    required this.filter,
    required this.vipStatus,
    required this.notifications,
    required this.unreadNotifications,
  });

  factory PicDashboardResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return PicDashboardResponse(
      visits: (data['data'] as List? ?? [])
          .map((v) => PicVisitModel.fromJson(v))
          .toList(),
      currentPage: _asInt(data['current_page'], 1),
      lastPage: _asInt(data['last_page'], 1),
      total: _asInt(data['total']),
      vipCount: _asInt(data['vip_count']),
      regularCount: _asInt(data['regular_count']),
      countToday: _asInt(data['count_today']),
      countUpcoming: _asInt(data['count_upcoming']),
      filter: data['filter'] ?? 'all',
      vipStatus: data['vip_status'] ?? 'all',
      notifications: data['notifications'] as List? ?? [],
      unreadNotifications: _asInt(data['unread_notifications'], 0),
    );
  }
}

/// GET /api/pic/followup
class PicFollowupResponse {
  final List<PicLeadModel> leads;
  final int currentPage;
  final int lastPage;
  final int total;
  final String filter;
  final Map<String, int> counts;

  PicFollowupResponse({
    required this.leads,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.filter,
    required this.counts,
  });

  factory PicFollowupResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final rawCounts = data['counts'] as Map<String, dynamic>? ?? {};
    return PicFollowupResponse(
      leads: (data['data'] as List? ?? [])
          .map((l) => PicLeadModel.fromJson(l))
          .toList(),
      currentPage: _asInt(data['current_page'], 1),
      lastPage: _asInt(data['last_page'], 1),
      total: _asInt(data['total']),
      filter: data['filter'] ?? 'all',
      counts: rawCounts.map((k, v) => MapEntry(k, _asInt(v))),
    );
  }
}

/// GET /api/pic/riwayat
class PicRiwayatResponse {
  final List<PicVisitModel> visits;
  final int currentPage;
  final int lastPage;
  final int total;
  final String vipStatus;

  PicRiwayatResponse({
    required this.visits,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.vipStatus,
  });

  factory PicRiwayatResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return PicRiwayatResponse(
      visits: (data['data'] as List? ?? [])
          .map((v) => PicVisitModel.fromJson(v))
          .toList(),
      currentPage: _asInt(data['current_page'], 1),
      lastPage: _asInt(data['last_page'], 1),
      total: _asInt(data['total']),
      vipStatus: data['vip_status'] ?? 'all',
    );
  }
}

/// GET /api/pic/leads
class PicLeadsResponse {
  final List<PicLeadModel> leads;
  final int currentPage;
  final int lastPage;
  final int total;
  final String filter;
  final String vipStatus;
  final Map<String, int> counts;

  PicLeadsResponse({
    required this.leads,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.filter,
    required this.vipStatus,
    required this.counts,
  });

  factory PicLeadsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final rawCounts = data['counts'] as Map<String, dynamic>? ?? {};
    return PicLeadsResponse(
      leads: (data['data'] as List? ?? [])
          .map((l) => PicLeadModel.fromJson(l))
          .toList(),
      currentPage: _asInt(data['current_page'], 1),
      lastPage: _asInt(data['last_page'], 1),
      total: _asInt(data['total']),
      filter: data['filter'] ?? 'active',
      vipStatus: data['vip_status'] ?? 'all',
      counts: rawCounts.map((k, v) => MapEntry(k, _asInt(v))),
    );
  }
}