class ApiUrl {
  static const String baseUrl = "http://127.0.0.1:8000";

  // ================= AUTH =================
  static const String registrasi = '$baseUrl/api/register';
  static const String login = '$baseUrl/api/login';
  static const String logout = '$baseUrl/api/logout';
  static const String me = '$baseUrl/api/me';
  static const String forgotPassword = '$baseUrl/api/forgot-password';

  // ================= PRODUK =================
  static const String listProduk = '$baseUrl/api/products';
  static const String createProduk = '$baseUrl/api/products';
  static String updateProduk(int id) => '$baseUrl/api/products/$id';
  static String showProduk(int id) => '$baseUrl/api/products/$id';
  static String deleteProduk(int id) => '$baseUrl/api/products/$id';

  // ================= BRANCH (TAMBAHAN BARU) =================
  static const String listBranch = '$baseUrl/api/branches';
  static const String createBranch = '$baseUrl/api/branches';
  static String updateBranch(int id) => '$baseUrl/api/branches/$id';
  static String showBranch(int id) => '$baseUrl/api/branches/$id';
  static String deleteBranch(int id) => '$baseUrl/api/branches/$id';

  // ================= LEAD SOURCES (TAMBAHAN BARU) =================
  static const String listLeadSource = '$baseUrl/api/lead-sources';
  static const String createLeadSource = '$baseUrl/api/lead-sources';
  static String updateLeadSource(int id) => '$baseUrl/api/lead-sources/$id';
  static String deleteLeadSource(int id) => '$baseUrl/api/lead-sources/$id';

  // ================= VISIT PURPOSES (TAMBAHAN BARU) =================
  static const String listVisitPurpose = '$baseUrl/api/visit-purposes';
  static const String createVisitPurpose = '$baseUrl/api/visit-purposes';
  static String updateVisitPurpose(int id) => '$baseUrl/api/visit-purposes/$id';
  static String deleteVisitPurpose(int id) => '$baseUrl/api/visit-purposes/$id';

  // ================= GUEST CATEGORIES (TAMBAHAN BARU) =================
  static const String listGuestCategory = '$baseUrl/api/guest-categories';
  static const String createGuestCategory = '$baseUrl/api/guest-categories';
  static String updateGuestCategory(int id) =>
      '$baseUrl/api/guest-categories/$id';
  static String deleteGuestCategory(int id) =>
      '$baseUrl/api/guest-categories/$id';

  // ================= USER MANAGEMENT =================
  static String users({String? status}) {
    return '$baseUrl/api/users' + (status != null ? '?status=$status' : '');
  }

  static String approveUser(int id) => '$baseUrl/api/users/$id/approve';
  static String deactivateUser(int id) => '$baseUrl/api/users/$id/deactivate';
  static String deleteUser(int id) => '$baseUrl/api/users/$id';
  static String updateUser(int id) => '$baseUrl/api/users/$id';
  static String createUser() => '$baseUrl/api/users';

  // ================= MANAGER =================
  static String managerDashboard(String date, String vipStatus) =>
      '$baseUrl/api/manager/dashboard?date=$date&vip_status=$vipStatus';
  static String managerLeadsPipeline(
    String filter,
    String vipStatus, {
    String? keyword,
    int page = 1,
  }) {
    final buffer = StringBuffer(
      '$baseUrl/api/manager/leads?filter=$filter&vip_status=$vipStatus&page=$page',
    );
    if (keyword != null && keyword.isNotEmpty) {
      buffer.write('&keyword=${Uri.encodeQueryComponent(keyword)}');
    }
    return buffer.toString();
  }

  static String managerKunjungan({
    String? startDate,
    String? endDate,
    String vipStatus = 'all',
    String? keyword,
    int page = 1,
  }) {
    final buffer = StringBuffer(
      '$baseUrl/api/manager/kunjungan?vip_status=$vipStatus&page=$page',
    );
    if (startDate != null && startDate.isNotEmpty) {
      buffer.write('&start_date=$startDate');
    }
    if (endDate != null && endDate.isNotEmpty) {
      buffer.write('&end_date=$endDate');
    }
    if (keyword != null && keyword.isNotEmpty) {
      buffer.write('&keyword=${Uri.encodeQueryComponent(keyword)}');
    }
    return buffer.toString();
  }

  static String ownerLeadsPipeline(
    String filter,
    String vipStatus, {
    String? keyword,
    int page = 1,
  }) {
    final buffer = StringBuffer(
      '$baseUrl/api/owner/leads?filter=$filter&vip_status=$vipStatus&page=$page',
    );
    if (keyword != null && keyword.isNotEmpty) {
      buffer.write('&keyword=${Uri.encodeQueryComponent(keyword)}');
    }
    return buffer.toString();
  }

  // laporan
  static String managerLaporan() => '$baseUrl/api/manager/laporan';

  static String managerLaporanExportExcel({
    int? month,
    int? year,
    String? category,
    String? branchId,
    String? picId,
  }) {
    final buffer = StringBuffer('$baseUrl/api/manager/laporan/export-excel?');
    final params = <String>[];
    if (month != null) params.add('month=$month');
    if (year != null) params.add('year=$year');
    if (category != null && category.isNotEmpty)
      params.add('category=$category');
    if (branchId != null && branchId.isNotEmpty)
      params.add('branch_id=$branchId');
    if (picId != null && picId.isNotEmpty) params.add('pic_id=$picId');
    buffer.write(params.join('&'));
    return buffer.toString();
  }

  static String managerLaporanExportPdf({
    int? month,
    int? year,
    String? category,
    String? branchId,
    String? picId,
  }) {
    final buffer = StringBuffer('$baseUrl/api/manager/laporan/export-pdf?');
    final params = <String>[];
    if (month != null) params.add('month=$month');
    if (year != null) params.add('year=$year');
    if (category != null && category.isNotEmpty)
      params.add('category=$category');
    if (branchId != null && branchId.isNotEmpty)
      params.add('branch_id=$branchId');
    if (picId != null && picId.isNotEmpty) params.add('pic_id=$picId');
    buffer.write(params.join('&'));
    return buffer.toString();
  }

  // ================= SECURITY =================
  static String securityDashboard({String? date}) {
    return '$baseUrl/api/security/dashboard' +
        (date != null ? '?date=$date' : '');
  }

  static String securityCheckIn(int id) => '$baseUrl/api/security/check-in/$id';
  static String securityCheckOut(int id) =>
      '$baseUrl/api/security/check-out/$id';

  // ================= OWNER =================
  static String ownerDashboard() {
    return '$baseUrl/api/owner/dashboard';
  }

  static String ownerLaporan() => '$baseUrl/api/owner/laporan';

  static String ownerLaporanExportExcel({
    int? month,
    int? year,
    String? category,
    String? branchId,
    String? picId,
  }) {
    final buffer = StringBuffer('$baseUrl/api/owner/laporan/export-excel?');
    final params = <String>[];
    if (month != null) params.add('month=$month');
    if (year != null) params.add('year=$year');
    if (category != null && category.isNotEmpty)
      params.add('category=$category');
    if (branchId != null && branchId.isNotEmpty)
      params.add('branch_id=$branchId');
    if (picId != null && picId.isNotEmpty) params.add('pic_id=$picId');
    buffer.write(params.join('&'));
    return buffer.toString();
  }

  static String ownerLaporanExportPdf({
    int? month,
    int? year,
    String? category,
    String? branchId,
    String? picId,
  }) {
    final buffer = StringBuffer('$baseUrl/api/owner/laporan/export-pdf?');
    final params = <String>[];
    if (month != null) params.add('month=$month');
    if (year != null) params.add('year=$year');
    if (category != null && category.isNotEmpty)
      params.add('category=$category');
    if (branchId != null && branchId.isNotEmpty)
      params.add('branch_id=$branchId');
    if (picId != null && picId.isNotEmpty) params.add('pic_id=$picId');
    buffer.write(params.join('&'));
    return buffer.toString();
  }

  static String ownerActivityLog({
    String? keyword,
    int page = 1,
    int perPage = 10,
  }) {
    final buffer = StringBuffer(
      '$baseUrl/api/owner/activity-log?page=$page&per_page=$perPage',
    );
    if (keyword != null && keyword.isNotEmpty) {
      buffer.write('&keyword=${Uri.encodeQueryComponent(keyword)}');
    }
    return buffer.toString();
  }

  static String ownerProdukDiminati({int? month, int? year}) {
    final m = month ?? DateTime.now().month;
    final y = year ?? DateTime.now().year;
    return '$baseUrl/api/owner/produk-diminati?month=$m&year=$y';
  }

  static String ownerKategoriTamu({int? month, int? year}) {
    final m = month ?? DateTime.now().month;
    final y = year ?? DateTime.now().year;
    return '$baseUrl/api/owner/kategori-tamu?month=$m&year=$y';
  }

  static String ownerDatabaseTamu({
    String? search,
    int page = 1,
    int perPage = 10,
  }) {
    final buffer = StringBuffer(
      '$baseUrl/api/owner/database-tamu?page=$page&per_page=$perPage',
    );
    if (search != null && search.isNotEmpty) {
      buffer.write('&search=${Uri.encodeQueryComponent(search)}');
    }
    return buffer.toString();
  }

  // ================= CHECK-IN (TAMBAHAN BARU) =================
  static const String checkInFormData = '$baseUrl/api/check-in/form-data';
  static const String checkInValidateStep1 =
      '$baseUrl/api/check-in/validate-step1';
  static const String checkInStore = '$baseUrl/api/check-in';

  static String checkInDetail(int id) => '$baseUrl/api/check-in/$id';

  // ================= PIC (TAMBAHAN BARU) =================

  // static const String picDashboard = '$baseUrl/api/pic/dashboard';
  // static const String picFollowup = '$baseUrl/api/pic/followup';
  // static const String picRiwayat = '$baseUrl/api/pic/riwayat';
  // static const String picLeads = '$baseUrl/api/pic/leads';
  // static String picUpdateStatus(int visitId) => '$baseUrl/api/pic/visits/$visitId/status';
  // static String picStartMeeting(int visitId) => '$baseUrl/api/pic/visits/$visitId/start-meeting';
  // static String picCompleteMeeting(int visitId) => '$baseUrl/api/pic/visits/$visitId/complete-meeting';
  // static String picUpdateFollowUp(int leadId) => '$baseUrl/api/pic/leads/$leadId/follow-up';

  // ================= PIC =================
  static String picDashboard({
    String filter = 'all',
    String vipStatus = 'all',
    String? keyword,
    int page = 1,
    int perPage = 10,
  }) {
    final buffer = StringBuffer(
      '$baseUrl/api/pic/dashboard?filter=$filter&vip_status=$vipStatus&page=$page&per_page=$perPage',
    );
    if (keyword != null && keyword.isNotEmpty) {
      buffer.write('&keyword=${Uri.encodeQueryComponent(keyword)}');
    }
    return buffer.toString();
  }

  static String picFollowup({
    String filter = 'all',
    String? startDate,
    String? endDate,
    int page = 1,
    int perPage = 10,
  }) {
    final buffer = StringBuffer(
      '$baseUrl/api/pic/followup?filter=$filter&page=$page&per_page=$perPage',
    );
    if (startDate != null && startDate.isNotEmpty) {
      buffer.write('&start_date=$startDate');
    }
    if (endDate != null && endDate.isNotEmpty) {
      buffer.write('&end_date=$endDate');
    }
    return buffer.toString();
  }

  static String picRiwayat({
    String? keyword,
    String? startDate,
    String? endDate,
    String vipStatus = 'all',
    int page = 1,
    int perPage = 10,
  }) {
    final buffer = StringBuffer(
      '$baseUrl/api/pic/riwayat?vip_status=$vipStatus&page=$page&per_page=$perPage',
    );
    if (keyword != null && keyword.isNotEmpty) {
      buffer.write('&keyword=${Uri.encodeQueryComponent(keyword)}');
    }
    if (startDate != null && startDate.isNotEmpty) {
      buffer.write('&start_date=$startDate');
    }
    if (endDate != null && endDate.isNotEmpty) {
      buffer.write('&end_date=$endDate');
    }
    return buffer.toString();
  }
  //   static String picLeads({String filter = 'active', String vipStatus = 'all', int page = 1, int perPage = 10}) {
  //   return '$baseUrl/api/pic/leads?filter=$filter&vip_status=$vipStatus&page=$page&per_page=$perPage';
  // }

  static String picLeadFollowUp(int leadId) =>
      '$baseUrl/api/pic/leads/$leadId/follow-up';

  static String picLeads({
    String filter = 'active',
    String vipStatus = 'all',
    String? startDate,
    String? endDate,
    int page = 1,
    int perPage = 10,
  }) {
    final buffer = StringBuffer(
      '$baseUrl/api/pic/leads?filter=$filter&vip_status=$vipStatus&page=$page&per_page=$perPage',
    );
    if (startDate != null && startDate.isNotEmpty) {
      buffer.write('&start_date=$startDate');
    }
    if (endDate != null && endDate.isNotEmpty) {
      buffer.write('&end_date=$endDate');
    }
    return buffer.toString();
  }

  static String picUpdateStatus(int id) => '$baseUrl/api/pic/visits/$id/status';
  static String picCompleteMeeting(int id) =>
      '$baseUrl/api/pic/visits/$id/complete-meeting';
  static String picStartMeeting(int id) =>
      '$baseUrl/api/pic/visits/$id/start-meeting';
  static String picUpdateFollowUp(int leadId) =>
      '$baseUrl/api/pic/leads/$leadId/follow-up';

  // Tambahkan di dalam class ApiUrl:
  static String readNotification(String id) {
    return '$baseUrl/notifications/$id/read'; // Sesuaikan dengan path endpoint backend Anda
  }

  static String get readAllNotifications => '$baseUrl/notifications/read-all';

  // ================= ADMIN (FRONT OFFICE) =================
  static const String adminMasterData = '$baseUrl/api/admin/master-data';

  static String adminDashboard({
    String dateFilter = 'all',
    String? keyword,
    int page = 1,
  }) {
    final buffer = StringBuffer(
      '$baseUrl/api/admin/dashboard?date_filter=$dateFilter&page=$page',
    );
    if (keyword != null && keyword.isNotEmpty) {
      buffer.write('&keyword=${Uri.encodeQueryComponent(keyword)}');
    }
    return buffer.toString();
  }

  static String adminCheckIn(int id) => '$baseUrl/api/admin/check-in/$id';
  static String adminCheckOut(int id) => '$baseUrl/api/admin/check-out/$id';
  static String adminCancel(int id) => '$baseUrl/api/admin/cancel/$id';
  static const String adminStoreManual = '$baseUrl/api/admin/store-manual';

  static String adminHistory({String? date, String? keyword, int page = 1}) {
    final buffer = StringBuffer('$baseUrl/api/admin/history?page=$page');
    if (date != null && date.isNotEmpty) buffer.write('&date=$date');
    if (keyword != null && keyword.isNotEmpty)
      buffer.write('&keyword=${Uri.encodeQueryComponent(keyword)}');
    return buffer.toString();
  }

  static String adminAppointments({String? keyword, int page = 1}) {
    final buffer = StringBuffer('$baseUrl/api/admin/appointments?page=$page');
    if (keyword != null && keyword.isNotEmpty)
      buffer.write('&keyword=${Uri.encodeQueryComponent(keyword)}');
    return buffer.toString();
  }

  static const String adminStoreAppointment = '$baseUrl/api/admin/appointments';
  static String adminUpdateAppointmentStatus(int id) =>
      '$baseUrl/api/admin/appointments/$id/status';

  static String adminGuest({String? vipStatus, String? keyword, int page = 1}) {
    String query = 'page=$page';
    if (vipStatus != null && vipStatus.isNotEmpty) query += '&vip=$vipStatus';
    if (keyword != null && keyword.isNotEmpty) query += '&keyword=$keyword';

    return '$baseUrl/api/admin/guest?$query';
  }

  static String get adminStoreGuest => '$baseUrl/api/admin/guest';
  static String adminUpdateGuest(int id) => '$baseUrl/api/admin/guest/$id';
  static String adminToggleVip(int id) => '$baseUrl/api/admin/guest/$id/vip';

  static const String adminNotifications = '$baseUrl/api/admin/notifications';
  static const String adminMarkAllNotificationsRead =
      '$baseUrl/api/admin/notifications/read-all';
  static String adminMarkNotificationRead(int id) =>
      '$baseUrl/api/admin/notifications/$id/read';

  
}
