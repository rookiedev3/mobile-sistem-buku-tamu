import 'guest.dart';
import 'branch.dart';

class Visit {
  final int id;
  final String visitCode;
  final int guestId;
  final int assignedTo;
  final int branchId;
  final int purposeId;
  final String? scheduledAt;
  final String? checkInAt;
  final String status;
  final String queueNumber;
  final String? notes;

  // Relasi Eloquent dari Laravel
  final Guest? guest;
  final Branch? branch;
  final Map<String, dynamic>? assignedUser;
  final Map<String, dynamic>? purpose;
  final List<dynamic>? products;

  Visit({
    required this.id,
    required this.visitCode,
    required this.guestId,
    required this.assignedTo,
    required this.branchId,
    required this.purposeId,
    this.scheduledAt,
    this.checkInAt,
    required this.status,
    required this.queueNumber,
    this.notes,
    this.guest,
    this.branch,
    this.assignedUser,
    this.purpose,
    this.products,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['id'],
      visitCode: json['visit_code'] ?? '',
      guestId: json['guest_id'] ?? 0,
      assignedTo: json['assigned_to'] ?? 0,
      branchId: json['branch_id'] ?? 0,
      purposeId: json['purpose_id'] ?? 0,
      scheduledAt: json['scheduled_at'],
      checkInAt: json['check_in_at'],
      status: json['status'] ?? 'Terjadwal',
      queueNumber: json['queue_number'] ?? '',
      notes: json['notes'],
      guest: json['guest'] != null ? Guest.fromJson(json['guest']) : null,
      branch: json['branch'] != null ? Branch.fromJson(json['branch']) : null,
      assignedUser: json['assigned_user'],
      purpose: json['purpose'],
      products: json['products'],
    );
  }
}