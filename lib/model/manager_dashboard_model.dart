class ManagerDashboardResponse {
  final List<VisitModel> visits;
  final int totalToday;
  final int leadDealsCount;
  final String selectedDate;
  final String vipStatus;
  final List<dynamic> notifications;
  final int unreadNotifications;

  ManagerDashboardResponse({
    required this.visits,
    required this.totalToday,
    required this.leadDealsCount,
    required this.selectedDate,
    required this.vipStatus,
    required this.notifications,
    required this.unreadNotifications,
  });

  factory ManagerDashboardResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json; // jaga-jaga kalau responseHasil dibungkus 'data'
    return ManagerDashboardResponse(
      visits: (data['visits'] as List? ?? [])
          .map((v) => VisitModel.fromJson(v))
          .toList(),
      totalToday: data['total_today'] ?? 0,
      leadDealsCount: data['lead_deals_count'] ?? 0,
      selectedDate: data['selected_date'] ?? '',
      vipStatus: data['vip_status'] ?? 'all',
      notifications: data['notifications'] as List? ?? [],
      unreadNotifications: data['unread_notifications'] ?? 0,
    );
  }
}

class VisitModel {
  final int id;
  final String? visitCode;
  final String? guestName;
  final String? guestPosition;
  final String? companyName;
  final bool isVip;
  final String? categoryName;
  final String? categoryColor;
  final int? assignedUserId;
  final String? assignedUserName;
  final String? purposeName;
  final String? keperluan;
  final String? scheduledAt;
  final String? checkInAt;
  final String? checkOutAt;
  final String? status;

  VisitModel({
    required this.id,
    this.visitCode,
    this.guestName,
    this.guestPosition,
    this.companyName,
    this.isVip = false,
    this.categoryName,
    this.categoryColor,
    this.assignedUserId,
    this.assignedUserName,
    this.purposeName,
    this.keperluan,
    this.scheduledAt,
    this.checkInAt,
    this.checkOutAt,
    this.status,
  });


 factory VisitModel.fromJson(Map<String, dynamic> json) {
    final guest = json['guest'] as Map<String, dynamic>?;
    final category = guest != null ? guest['category'] as Map<String, dynamic>? : null;
    final assignedUser = json['assigned_user'] as Map<String, dynamic>?;
    final purpose = json['purpose'] as Map<String, dynamic>?;


    return VisitModel(
      id: json['id'],
      visitCode: json['visit_code'],
      guestName: guest?['name'],
      guestPosition: guest?['position'],
      companyName: guest?['company_name'],
      isVip: guest?['is_vip'] == true || guest?['is_vip'] == 1,
      categoryName: category?['name'],
      categoryColor: category?['color'],
      assignedUserId: assignedUser?['id'],
      assignedUserName: assignedUser?['name'],
      purposeName: purpose?['name'],
      // sesuaikan key ini kalau nama kolom keperluan di tabel `visits` beda (mis. 'purpose_detail')
      keperluan: json['notes'] ?? json['keperluan'] ?? json['description'],
      scheduledAt: json['scheduled_at'],
      checkInAt: json['check_in_at'],
      checkOutAt: json['check_out_at'],
      status: json['status'],
    );
  }
  /// Waktu yang dipakai untuk ditampilkan: scheduled_at kalau ada, kalau tidak check_in_at
  String get displayTime => scheduledAt ?? checkInAt ?? '-';
}