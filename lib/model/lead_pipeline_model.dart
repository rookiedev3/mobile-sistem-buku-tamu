
// class LeadPipelineResponse {
//   final List<LeadModel> data;
//   final int currentPage;
//   final int lastPage;
//   final int total;
//   final Map<String, int> counts;

//   LeadPipelineResponse({
//     required this.data,
//     required this.currentPage,
//     required this.lastPage,
//     required this.total,
//     required this.counts,
//   });

//   factory LeadPipelineResponse.fromJson(Map<String, dynamic> json) {
//     // Response asli dibungkus: { code, status, data: { data: [...], current_page, ... } }
//     final body = json['data'] as Map<String, dynamic>? ?? {};

//     return LeadPipelineResponse(
//       data: (body['data'] as List? ?? [])
//           .map((e) => LeadModel.fromJson(e))
//           .toList(),
//       currentPage: body['current_page'] ?? 1,
//       lastPage: body['last_page'] ?? 1,
//       total: body['total'] ?? 0,
//       counts: Map<String, int>.from(body['counts'] ?? {}),
//     );
//   }
// } // tutup class LeadPipelineResponse

// class FollowUpModel {
//   final int id;
//   final String? result;
//   final String? status;
//   final String? dueAt;
//   final String createdAt;
//   final num? estimatedValue; // REVISI: nilai estimasi per update pipeline (menyamakan dengan web)

//   FollowUpModel({required this.id, this.result, this.status, this.dueAt, required this.createdAt, this.estimatedValue});

//   factory FollowUpModel.fromJson(Map<String, dynamic> json) => FollowUpModel(
//         id: json['id'],
//         result: json['result'],
//         status: json['status'],
//         dueAt: json['due_at'],
//         createdAt: json['created_at'] ?? '',
//         estimatedValue: json['estimated_value'] != null
//             ? num.tryParse(json['estimated_value'].toString())
//             : null,
//       );
// } // tutup class FollowUpModel

// class LeadModel {
//   final int id;
//   final String visitCode;
//   final String? guestName;
//   final String? guestPosition;
//   final String? companyName;
//   final bool isVip;
//   final int? ownerId;
//   final String? ownerName;
//   final String status;
//   final String? potentialLevel;
//   final num? estimatedValue;
//   final String? followUpAt;
//   final String? notes; // REVISI: catatan awal kunjungan (dari visits.notes)
//   final String? meetingResult;
//   final List<FollowUpModel> followUps;

//   LeadModel({
//     required this.id,
//     required this.visitCode,
//     this.guestName,
//     this.guestPosition,
//     this.companyName,
//     this.isVip = false,
//     this.ownerId,
//     this.ownerName,
//     required this.status,
//     this.potentialLevel,
//     this.estimatedValue,
//     this.followUpAt,
//     this.notes,
//     this.meetingResult,
//     this.followUps = const [],
//   });

//   factory LeadModel.fromJson(Map<String, dynamic> json) => LeadModel(
//         id: json['id'],
//         visitCode: json['visit_code'] ?? 'VST-${json['id'].toString().padLeft(4, '0')}',
//         guestName: json['guest_name'],
//         guestPosition: json['guest_position'],
//         companyName: json['company_name'],
//         isVip: json['is_vip'] == true || json['is_vip'] == 1,
//         ownerId: json['owner_id'],
//         ownerName: json['owner_name'],
//         status: json['status'] ?? 'new',
//         potentialLevel: json['potential_level'],
//         estimatedValue: json['estimated_value'] != null
//             ? num.tryParse(json['estimated_value'].toString())
//             : null,
//         followUpAt: json['follow_up_at'],
//         notes: json['notes'], // REVISI: ambil dari field 'notes' di response
//         meetingResult: json['meeting_result'],
//         followUps: (json['follow_ups'] as List? ?? [])
//             .map((f) => FollowUpModel.fromJson(f))
//             .toList(),
//       );

//   /// Catatan terakhir yang tampil di preview card
//   String get latestNote {
//     if (followUps.isNotEmpty) return followUps.first.result ?? '-';
//     if (meetingResult != null && meetingResult!.isNotEmpty) return meetingResult!;
//     return 'Belum ada catatan.';
//   }
// } // tutup class LeadModel


// TIDAK PERLU import apapun di sini — file ini justru yang di-import oleh screen lain
// (Baris "import 'lead_pipeline_model.dart';" sebelumnya salah taruh, sudah dihapus)

class LeadPipelineResponse {
  final List<LeadModel> data;
  final int currentPage;
  final int lastPage;
  final int total;
  final Map<String, int> counts;

  LeadPipelineResponse({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.counts,
  });

  factory LeadPipelineResponse.fromJson(Map<String, dynamic> json) {
    // Mendukung 2 bentuk struktur response:
    // A) FLAT (endpoint leads() terbaru):
    //    { success, data: [...], meta: {...}, counts: {...} }
    // B) NESTED (struktur lama, dipakai role/endpoint lain):
    //    { code, status, data: { data: [...], current_page, ..., counts: {...} } }

    Map<String, dynamic> body;
    List rawList;
    Map<String, dynamic> rawCounts;

    if (json['data'] is List) {
      // --- Struktur FLAT ---
      body = json;
      rawList = json['data'] as List;
      rawCounts = (json['counts'] as Map<String, dynamic>?) ?? {};
    } else {
      // --- Struktur NESTED (lama) ---
      body = (json['data'] as Map<String, dynamic>?) ?? {};
      rawList = (body['data'] as List?) ?? [];
      rawCounts = (body['counts'] as Map<String, dynamic>?) ?? {};
    }

    final meta = (body['meta'] as Map<String, dynamic>?) ?? {};
    final pageSource = meta.isNotEmpty ? meta : body;

    int _readInt(Map<String, dynamic> m, String key, [int fallback = 1]) {
      final v = m[key];
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? fallback;
      return fallback;
    }

    return LeadPipelineResponse(
      data: rawList.map((e) => LeadModel.fromJson(e)).toList(),
      currentPage: _readInt(pageSource, 'current_page', 1),
      lastPage: _readInt(pageSource, 'last_page', 1),
      total: _readInt(pageSource, 'total', 0),
      counts: rawCounts.map(
        (k, v) => MapEntry(k, (v is int) ? v : int.tryParse(v.toString()) ?? 0),
      ),
    );
  }
} // tutup class LeadPipelineResponse

class FollowUpModel {
  final int id;
  final String? result;
  final String? status;
  final String? dueAt;
  final String createdAt;
  final num? estimatedValue; // REVISI: nilai estimasi per update pipeline (menyamakan dengan web)

  FollowUpModel({required this.id, this.result, this.status, this.dueAt, required this.createdAt, this.estimatedValue});

  factory FollowUpModel.fromJson(Map<String, dynamic> json) => FollowUpModel(
        id: json['id'],
        result: json['result'],
        status: json['status'],
        dueAt: json['due_at'],
        createdAt: json['created_at'] ?? '',
        estimatedValue: json['estimated_value'] != null
            ? num.tryParse(json['estimated_value'].toString())
            : null,
      );
} // tutup class FollowUpModel

class LeadModel {
  final int id;
  final String visitCode;
  final String? guestName;
  final String? guestPosition;
  final String? companyName;
  final bool isVip;
  final int? ownerId;
  final String? ownerName;
  final String status;
  final String? potentialLevel;
  final num? estimatedValue;
  final String? followUpAt;
  final String? notes; // REVISI: catatan awal kunjungan (dari visits.notes)
  final String? meetingResult;
  final List<FollowUpModel> followUps;

  LeadModel({
    required this.id,
    required this.visitCode,
    this.guestName,
    this.guestPosition,
    this.companyName,
    this.isVip = false,
    this.ownerId,
    this.ownerName,
    required this.status,
    this.potentialLevel,
    this.estimatedValue,
    this.followUpAt,
    this.notes,
    this.meetingResult,
    this.followUps = const [],
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) => LeadModel(
        id: json['id'],
        visitCode: json['visit_code'] ?? 'VST-${json['id'].toString().padLeft(4, '0')}',
        guestName: json['guest_name'],
        guestPosition: json['guest_position'],
        companyName: json['company_name'],
        isVip: json['is_vip'] == true || json['is_vip'] == 1,
        ownerId: json['owner_id'],
        ownerName: json['owner_name'],
        status: json['status'] ?? 'new',
        potentialLevel: json['potential_level'],
        estimatedValue: json['estimated_value'] != null
            ? num.tryParse(json['estimated_value'].toString())
            : null,
        followUpAt: json['follow_up_at'],
        notes: json['notes'], // REVISI: ambil dari field 'notes' di response
        meetingResult: json['meeting_result'],
        followUps: (json['follow_ups'] as List? ?? [])
            .map((f) => FollowUpModel.fromJson(f))
            .toList(),
      );

  /// Catatan terakhir yang tampil di preview card
  String get latestNote {
    if (followUps.isNotEmpty) return followUps.first.result ?? '-';
    if (meetingResult != null && meetingResult!.isNotEmpty) return meetingResult!;
    return 'Belum ada catatan.';
  }
} // tutup class LeadModel