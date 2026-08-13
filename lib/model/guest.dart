// Helper function to safely convert dynamic values (String/int/null) into int
int parseIntSafely(dynamic value, {int defaultValue = 0}) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? defaultValue;
  return defaultValue;
}

class Guest {
  final int id;
  final String name;
  final String? companyName;
  final bool isVip;

  Guest({
    required this.id,
    required this.name,
    this.companyName,
    required this.isVip,
  });

  factory Guest.fromJson(Map<String, dynamic> json) {
    return Guest(
      id: json['id'],
      name: json['name'] ?? '',
      companyName: json['company_name'],
      isVip: json['is_vip'] == true || json['is_vip'] == 1,
    );
  }
}

class AssignedUser {
  final int id;
  final String name;

  AssignedUser({required this.id, required this.name});

  factory AssignedUser.fromJson(Map<String, dynamic> json) {
    return AssignedUser(id: json['id'], name: json['name'] ?? '');
  }
}

class Visit {
  final int id;
  final String visitCode;
  final int guestId;
  final int? assignedTo;
  final DateTime scheduledAt;
  final DateTime? checkInAt;
  final DateTime? checkOutAt;
  final String status;
  final Guest? guest;
  final AssignedUser? assignedUser;

  Visit({
    required this.id,
    required this.visitCode,
    required this.guestId,
    this.assignedTo,
    required this.scheduledAt,
    this.checkInAt,
    this.checkOutAt,
    required this.status,
    this.guest,
    this.assignedUser,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['id'],
      visitCode: json['visit_code'] ?? '',
      guestId: json['guest_id'],
      assignedTo: json['assigned_to'],
      scheduledAt: DateTime.parse(json['scheduled_at']),
      checkInAt: json['check_in_at'] != null ? DateTime.parse(json['check_in_at']) : null,
      checkOutAt: json['check_out_at'] != null ? DateTime.parse(json['check_out_at']) : null,
      status: json['status'] ?? '',
      guest: json['guest'] != null ? Guest.fromJson(json['guest']) : null,
      assignedUser: json['assigned_user'] != null ? AssignedUser.fromJson(json['assigned_user']) : null,
    );
  }
}

class SecurityDashboardResponse {
  int? code;
  bool? status;
  String? selectedDate;
  int? total;
  int? currentPage;
  int? lastPage;
  int? perPage;
  List<Visit> visits;

  SecurityDashboardResponse({
    this.code,
    this.status,
    this.selectedDate,
    this.total,
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.visits = const [],
  });

  factory SecurityDashboardResponse.fromJson(Map<String, dynamic> obj) {
    var data = obj['data'] ?? {};
    var list = (data['visits'] as List?) ?? [];

    return SecurityDashboardResponse(
      code: obj['code'],
      status: obj['status'],
      selectedDate: data['selected_date'],
      total: data['total'],
      currentPage: data['current_page'],
      lastPage: data['last_page'],
      perPage: data['per_page'],
      visits: list.map((e) => Visit.fromJson(e)).toList(),
    );
  }
}