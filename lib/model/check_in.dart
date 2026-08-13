class OptionItem {
  final dynamic id;
  final String name;

  OptionItem({required this.id, required this.name});

  factory OptionItem.fromJson(Map<String, dynamic> json) {
    return OptionItem(
      id: json['id'],
      name: json['name'] ?? '',
    );
  }
}

class CheckInMasterData {
  final List<OptionItem> guestCategories;
  final List<OptionItem> pics;
final List<OptionItem> branches;
  final List<OptionItem> visitPurposes;
  final List<OptionItem> products;
  final List<OptionItem> leadSources;

  CheckInMasterData({
    required this.guestCategories,
    required this.pics,
    required this.branches,
    required this.visitPurposes,
    required this.products,
    required this.leadSources,
  });

  factory CheckInMasterData.fromJson(Map<String, dynamic> json) {
    return CheckInMasterData(
      guestCategories: (json['guest_categories'] as List? ?? [])
          .map((e) => OptionItem.fromJson(e))
          .toList(),
      pics: (json['pics'] as List? ?? [])
          .map((e) => OptionItem.fromJson(e))
          .toList(),
      branches: (json['branches'] as List? ?? [])
          .map((e) => OptionItem.fromJson(e))
          .toList(),
      visitPurposes: (json['visit_purposes'] as List? ?? [])
          .map((e) => OptionItem.fromJson(e))
          .toList(),
      products: (json['products'] as List? ?? [])
          .map((e) => OptionItem.fromJson(e))
          .toList(),
      leadSources: (json['lead_sources'] as List? ?? [])
          .map((e) => OptionItem.fromJson(e))
          .toList(),
    );
  }
}

class CheckInResult {
  final bool? success;
  final String? message;
  final int? visitId;
  final String? visitCode;
  final String? queueNumber;
  final String? status;

  CheckInResult({
    this.success,
    this.message,
    this.visitId,
    this.visitCode,
    this.queueNumber,
    this.status,
  });

  factory CheckInResult.fromJson(Map<String, dynamic> json) {
    var data = json['data'] ?? {};
    return CheckInResult(
      success: json['success'],
      message: json['message'],
      visitId: data['visit_id'],
      visitCode: data['visit_code'],
      queueNumber: data['queue_number'],
      status: data['status'],
    );
  }
}