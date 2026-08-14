class FollowUp {
  final int id;
  final String? result;
  final String? status;
  final String? dueAt;
  final num? estimatedValue;
  final String? createdAt;

  FollowUp({
    required this.id,
    this.result,
    this.status,
    this.dueAt,
    this.estimatedValue,
    this.createdAt,
  });

  factory FollowUp.fromJson(Map<String, dynamic> json) {
    return FollowUp(
      id: json['id'],
      result: json['result'],
      status: json['status'],
      dueAt: json['due_at'],
      estimatedValue: json['estimated_value'] != null
          ? num.tryParse(json['estimated_value'].toString())
          : null,
      createdAt: json['created_at'],
    );
  }
}

class Kunjungan {
  final int id;
  final String visitCode;
  final String? guestName;
  final String? guestPosition;
  final String? companyName;
  final bool isVip;
  final String? categoryName;
  final String? categoryColor;
  final String? assignedUser;
  final String? purpose;
  final String? branchName;
  final String? scheduledAt;
  final String? checkInAt;
  final String? checkOutAt;
  final String status;
  final String? notes;            // BARU
  final String? meetingResult;    // BARU
  final String? leadStatus;
  final double? estimatedValue;
  final String? followUpAt;       // BARU
  final List<FollowUp> followUps;

  Kunjungan({
    required this.id,
    required this.visitCode,
    this.guestName,
    this.guestPosition,
    this.companyName,
    required this.isVip,
    this.categoryName,
    this.categoryColor,
    this.assignedUser,
    this.purpose,
    this.branchName,
    this.scheduledAt,
    this.checkInAt,
    this.checkOutAt,
    required this.status,
    this.notes,
    this.meetingResult,
    this.leadStatus,
    this.estimatedValue,
    this.followUpAt,
    this.followUps = const [],
  });

  String? get catatanTerakhir =>
      followUps.isNotEmpty ? (followUps.first.result) : null;

  factory Kunjungan.fromJson(Map<String, dynamic> json) {
    return Kunjungan(
      id: json['id'],
      visitCode: json['visit_code'] ?? '-',
      guestName: json['guest_name'],
      guestPosition: json['guest_position'],
      companyName: json['company_name'],
      isVip: json['is_vip'] == true,
      categoryName: json['category_name'],
      categoryColor: json['category_color'],
      assignedUser: json['assigned_user'],
      purpose: json['purpose'],
      branchName: json['branch_name'],
      scheduledAt: json['scheduled_at'],
      checkInAt: json['check_in_at'],
      checkOutAt: json['check_out_at'],
      status: json['status'] ?? '-',
      notes: json['notes'],
      meetingResult: json['meeting_result'],
      leadStatus: json['lead_status'],
      estimatedValue: json['estimated_value'] != null
          ? double.tryParse(json['estimated_value'].toString())
          : null,
      followUpAt: json['follow_up_at'],
      followUps: (json['follow_ups'] as List?)
              ?.map((f) => FollowUp.fromJson(f))
              .toList() ??
          [],
    );
  }
}

class KunjunganResponse {
  final List<Kunjungan> data;
  final int currentPage;
  final int lastPage;
  final int total;

  KunjunganResponse({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory KunjunganResponse.fromJson(Map<String, dynamic> obj) {
    final d = obj['data'] ?? {};
    var list = (d['data'] as List?) ?? [];
    return KunjunganResponse(
      data: list.map((e) => Kunjungan.fromJson(e)).toList(),
      currentPage: d['current_page'] ?? 1,
      lastPage: d['last_page'] ?? 1,
      total: d['total'] ?? 0,
    );
  }
}