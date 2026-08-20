class VisitOwnerItem {
  final int id;
  final String token;
  final String? nama;
  final String? jabatan;
  final String? instansi;
  final String? waktu;
  final String? jenis;
  final String? keperluan;
  final String? pic;
  final String? catatan;
  final String statusKunjungan;
  final String? statusLead;
    final bool isVip;

  VisitOwnerItem({
    required this.id,
    required this.token,
    this.nama,
    this.jabatan,
    this.instansi,
    this.waktu,
    this.jenis,
    this.keperluan,
    this.pic,
    this.catatan,
    required this.statusKunjungan,
    this.statusLead,
        this.isVip = false,
  });

  factory VisitOwnerItem.fromJson(Map<String, dynamic> json) {
    return VisitOwnerItem(
      id: json['id'],
      token: json['token'] ?? '-',
      nama: json['nama'],
      jabatan: json['jabatan'],
      instansi: json['instansi'],
      waktu: json['waktu'],
      jenis: json['jenis'],
      keperluan: json['keperluan'],
      pic: json['pic'],
      catatan: json['catatan'],
      statusKunjungan: json['status_kunjungan'] ?? '-',
      statusLead: json['status_lead'],
          isVip: json['is_vip'] == true, // ← TAMBAHAN: baca boolean is_vip dari backend
    );
  }
}

class TopProduct {
  final String? name;
  final int total;

  TopProduct({this.name, required this.total});

  factory TopProduct.fromJson(Map<String, dynamic>? json) {
    if (json == null) return TopProduct(name: null, total: 0);
    return TopProduct(
      name: json['name'],
      total: json['total'] is int ? json['total'] : int.tryParse(json['total'].toString()) ?? 0,
    );
  }
}

class TopCategory {
  final String? name;
  final int total;
  final int percentage;

  TopCategory({this.name, required this.total, required this.percentage});

  factory TopCategory.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return TopCategory(
      name: data?['name'],
      total: data != null
          ? (data['total'] is int ? data['total'] : int.tryParse(data['total'].toString()) ?? 0)
          : 0,
      percentage: json['percentage'] ?? 0,
    );
  }
}

class RecentActivity {
  final String? guestName;
  final String? companyName;
  final String? newStatus;
  final String? changedAt;
  final String? jabatan;        // ← TAMBAHAN
  final String? waktu;

  RecentActivity({this.guestName, this.companyName, this.newStatus, this.changedAt, this.jabatan, this.waktu});

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      guestName: json['guest_name'],
      companyName: json['company_name'],
      newStatus: json['new_status'],
      changedAt: json['changed_at'],
      jabatan: json['jabatan'],
      waktu: json['waktu'],
    );
  }
}

class DashboardOwnerSummary {
  final int totalTamuHariIni;
  final int sedangMenunggu;
  final int sedangBertemu;
  final int pertemuanSelesai;
  final int terjadwalHariIni;
  final int menjadiLeadHariIni;
  final int avgWaitMinutes;
  final int serviceRate;
  final int conversionRate;

  DashboardOwnerSummary({
    required this.totalTamuHariIni,
    required this.sedangMenunggu,
    required this.sedangBertemu,
    required this.pertemuanSelesai,
    required this.terjadwalHariIni,
    required this.menjadiLeadHariIni,
    required this.avgWaitMinutes,
    required this.serviceRate,
    required this.conversionRate,
  });

  factory DashboardOwnerSummary.fromJson(Map<String, dynamic> json) {
    return DashboardOwnerSummary(
      totalTamuHariIni: json['total_tamu_hari_ini'] ?? 0,
      sedangMenunggu: json['sedang_menunggu'] ?? 0,
      sedangBertemu: json['sedang_bertemu'] ?? 0,
      pertemuanSelesai: json['pertemuan_selesai'] ?? 0,
      terjadwalHariIni: json['terjadwal_hari_ini'] ?? 0,
      menjadiLeadHariIni: json['menjadi_lead_hari_ini'] ?? 0,
      avgWaitMinutes: json['avg_wait_minutes'] ?? 0,
      serviceRate: json['service_rate'] ?? 0,
      conversionRate: json['conversion_rate'] ?? 0,
    );
  }
}

class DashboardOwnerResponse {
  final DashboardOwnerSummary summary;
  final TopProduct topProduct;
  final TopCategory topCategory;
  final List<RecentActivity> recentActivities;
  final List<VisitOwnerItem> visits;
  final List<String> statusOptions;
  final List<Map<String, dynamic>> picOptions;

  DashboardOwnerResponse({
    required this.summary,
    required this.topProduct,
    required this.topCategory,
    required this.recentActivities,
    required this.visits,
    required this.statusOptions,
    required this.picOptions,
  });

  factory DashboardOwnerResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final filters = data['filters'] as Map<String, dynamic>? ?? {};

    return DashboardOwnerResponse(
      summary: DashboardOwnerSummary.fromJson(data['summary'] ?? {}),
      topProduct: TopProduct.fromJson(data['top_product']),
      topCategory: TopCategory.fromJson(data['top_category'] ?? {}),
      recentActivities: (data['recent_activities'] as List? ?? [])
          .map((e) => RecentActivity.fromJson(e))
          .toList(),
      visits: (data['visits'] as List? ?? [])
          .map((e) => VisitOwnerItem.fromJson(e))
          .toList(),
      statusOptions: (filters['status_options'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      picOptions: (filters['pic_options'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
    );
  }
}

class ActivityLogItem {
  final String? guestName;
  final String? companyName;
  final String? newStatus;
  final String? changedAt;
  final String? jabatan;

  ActivityLogItem({this.guestName, this.companyName, this.newStatus, this.changedAt, this.jabatan});

  factory ActivityLogItem.fromJson(Map<String, dynamic> json) {
    return ActivityLogItem(
      guestName: json['guest_name'],
      jabatan: json['jabatan'],
      companyName: json['company_name'],
      newStatus: json['new_status'],
      changedAt: json['changed_at'],
    );
  }
}

class ActivityLogResponse {
  final List<ActivityLogItem> items;
  final int currentPage;
  final int lastPage;

  ActivityLogResponse({required this.items, required this.currentPage, required this.lastPage});

  bool get hasMore => currentPage < lastPage;
}