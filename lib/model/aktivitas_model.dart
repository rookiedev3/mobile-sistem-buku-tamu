import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AktivitasModel {
  final String namaTamu;
  final String instansi;
  final String statusBaru;
  final DateTime waktuPerubahan;

  AktivitasModel({
    required this.namaTamu,
    required this.instansi,
    required this.statusBaru,
    required this.waktuPerubahan,
  });

  factory AktivitasModel.fromJson(Map<String, dynamic> json) {
    return AktivitasModel(
      namaTamu: json['guest_name']?.toString() ?? '-',
      instansi: json['company_name']?.toString() ?? '-',
      statusBaru: json['new_status']?.toString() ?? '-',
      waktuPerubahan: DateTime.tryParse(json['changed_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  String get waktuFormatted =>
      "${DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(waktuPerubahan)} WIB";

  // Mapping warna & icon otomatis berdasarkan isi status,
  // meniru style hardcoded di screen aslinya
  Color get statusColor {
    final s = statusBaru.toLowerCase();
    if (s.contains('meeting') || s.contains('selesai')) return const Color(0xFF006B3F);
    if (s.contains('menunggu') || s.contains('waiting')) return Colors.orange;
    if (s.contains('check-in') || s.contains('checkin')) return const Color(0xFF006B3F);
    if (s.contains('jadwal')) return Colors.blue;
    if (s.contains('batal') || s.contains('ditolak')) return Colors.red;
    return Colors.grey;
  }

  IconData get statusIcon {
    final s = statusBaru.toLowerCase();
    if (s.contains('meeting')) return Icons.check_circle_rounded;
    if (s.contains('menunggu') || s.contains('waiting')) return Icons.hourglass_top_rounded;
    if (s.contains('check-in') || s.contains('checkin')) return Icons.login_rounded;
    if (s.contains('jadwal')) return Icons.calendar_today_rounded;
    if (s.contains('batal') || s.contains('ditolak')) return Icons.cancel_rounded;
    return Icons.info_rounded;
  }
}

class AktivitasResponse {
  final List<AktivitasModel> data;
  final int currentPage;
  final int lastPage;
  final int total;

  AktivitasResponse({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory AktivitasResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>? ?? [])
        .map((e) => AktivitasModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final meta = json['meta'] as Map<String, dynamic>? ?? {};

    return AktivitasResponse(
      data: list,
      currentPage: meta['current_page'] ?? 1,
      lastPage: meta['last_page'] ?? 1,
      total: meta['total'] ?? list.length,
    );
  }
}