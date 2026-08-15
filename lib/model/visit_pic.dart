class GuestPic {
  final int? id;
  final String name;
  final String? position;
  final String? companyName;
  final bool isVip;

  GuestPic({
    this.id,
    required this.name,
    this.position,
    this.companyName,
    this.isVip = false,
  });

  factory GuestPic.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return GuestPic(name: 'Tamu');
    }
    return GuestPic(
      id: json['id'] as int?,
      name: (json['name'] as String?) ?? 'Tamu',
      position: json['position'] as String?,
      companyName: json['company_name'] as String?,
      // is_vip bisa datang sebagai bool, 1/0, atau "1"/"0" tergantung driver DB
      isVip: json['is_vip'] == true || json['is_vip'] == 1 || json['is_vip'] == '1',
    );
  }
}

class VisitPic {
  final int id;
  final String? token;
  final String status;
  final GuestPic guest;
  final String? purposeType;
  final String? purposeDetail;
  final String? notes;
  final DateTime? checkInAt;
  final DateTime? scheduledAt;
  final DateTime? meetingStartAt;
  final String? meetingResult;
  final String? potentialLevel;
  final DateTime? followUpAt;
  final num? estimatedValue;

  VisitPic({
    required this.id,
    this.token,
    required this.status,
    required this.guest,
    this.purposeType,
    this.purposeDetail,
    this.notes,
    this.checkInAt,
    this.scheduledAt,
    this.meetingStartAt,
    this.meetingResult,
    this.potentialLevel,
    this.followUpAt,
    this.estimatedValue,
  });

  factory VisitPic.fromJson(Map<String, dynamic> json) {
    return VisitPic(
      id: (json['id'] as num).toInt(),
      token: json['token']?.toString(),
      status: (json['status'] as String?) ?? '-',
      guest: GuestPic.fromJson(json['guest'] as Map<String, dynamic>?),
      // sesuaikan nama field ini kalau relasi "purpose" kamu strukturnya beda
      purposeType: (json['purpose'] is Map) ? json['purpose']['type']?.toString() : json['purpose_type']?.toString(),
      purposeDetail: (json['purpose'] is Map) ? json['purpose']['detail']?.toString() : json['purpose_detail']?.toString(),
      notes: json['notes']?.toString() ?? json['guest_notes']?.toString(),
      checkInAt: _parseDate(json['check_in_at']),
      scheduledAt: _parseDate(json['scheduled_at']),
      meetingStartAt: _parseDate(json['meeting_start_at']),
      meetingResult: json['meeting_result']?.toString(),
      potentialLevel: json['potential_level']?.toString(),
      followUpAt: _parseDate(json['follow_up_at']),
      estimatedValue: json['estimated_value'] == null ? null : num.tryParse(json['estimated_value'].toString()),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  // ---------------------------------------------------------------------
  // Getter turunan yang dipakai UI
  // ---------------------------------------------------------------------

  String get kategori => guest.isVip ? 'VIP' : 'Reguler';

  bool get isConfirmed => !['-', 'pending', 'Menunggu'].contains(status) &&
      !['dibatalkan', 'ditolak'].contains(status.toLowerCase());

  bool get isMeeting => status.toLowerCase() == 'sedang bertemu';

  bool get isFinished => status.toLowerCase() == 'meeting selesai';

  String get statusKonfirmasi {
    switch (status.toLowerCase()) {
      case 'dikonfirmasi':
        return 'Dikonfirmasi';
      case 'sedang bertemu':
        return 'Sedang Bertemu';
      case 'meeting selesai':
        return 'Selesai';
      case 'dibatalkan':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  String get waktuDisplay {
    final dt = checkInAt ?? scheduledAt;
    if (dt == null) return '-';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}