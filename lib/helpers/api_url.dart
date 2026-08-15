class ApiUrl {
   static const String baseUrl = "http://192.168.100.85:8000";
  // static const String baseUrl = "http://127.0.0.1:8000";
  //static const String baseUrl = "http://127.0.0.1:8000";

  // ================= AUTH =================
  static const String registrasi = '$baseUrl/api/register';
  static const String login = '$baseUrl/api/login';
  static const String logout = '$baseUrl/api/logout';
  static const String me = '$baseUrl/api/me';

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
static String updateGuestCategory(int id) => '$baseUrl/api/guest-categories/$id';
static String deleteGuestCategory(int id) => '$baseUrl/api/guest-categories/$id';

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
    static String managerLeadsPipeline(String filter, String vipStatus, {String? keyword, int page = 1}) {
      final buffer = StringBuffer('$baseUrl/api/manager/leads?filter=$filter&vip_status=$vipStatus&page=$page');
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
  final buffer = StringBuffer('$baseUrl/api/manager/kunjungan?vip_status=$vipStatus&page=$page');
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
static String ownerLeadsPipeline(String filter, String vipStatus, {String? keyword, int page = 1}) {
    final buffer = StringBuffer('$baseUrl/api/owner/leads?filter=$filter&vip_status=$vipStatus&page=$page');
    if (keyword != null && keyword.isNotEmpty) {
      buffer.write('&keyword=${Uri.encodeQueryComponent(keyword)}');
    }
    return buffer.toString();
  }
  

  // ================= SECURITY =================
static String securityDashboard({String? date}) {
  return '$baseUrl/api/security/dashboard' + (date != null ? '?date=$date' : '');
}
static String securityCheckIn(int id) => '$baseUrl/api/security/check-in/$id';
static String securityCheckOut(int id) => '$baseUrl/api/security/check-out/$id';


// ================= OWNER =================
  static String ownerDashboard() {
    return '$baseUrl/api/owner/dashboard';
  }

  static String ownerActivityLog({String? keyword, int page = 1, int perPage = 10}) {
    final buffer = StringBuffer('$baseUrl/api/owner/activity-log?page=$page&per_page=$perPage');
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


  // ================= CHECK-IN (TAMBAHAN BARU) =================
  static const String checkInFormData = '$baseUrl/api/check-in/form-data';
  static const String checkInValidateStep1 = '$baseUrl/api/check-in/validate-step1';
  static const String checkInStore = '$baseUrl/api/check-in';

  static String checkInDetail(int id) => '$baseUrl/api/check-in/$id';
}

