import 'package:flutter/material.dart';
import 'package:mobile_flutter/bloc/check_in_bloc.dart';
import 'homepage_screen.dart'; // Sesuaikan path jika lokasi file berbeda

class TamuFormStep4 extends StatefulWidget {
  final int? visitId;
  final String? visitCode;
  final String? queueNumber;
  final String? scheduledAt;

  const TamuFormStep4({
    super.key,
    this.visitId,
    this.visitCode,
    this.queueNumber,
    this.scheduledAt,
  });

  @override
  State<TamuFormStep4> createState() => _TamuFormStep4State();
}

class _TamuFormStep4State extends State<TamuFormStep4> {
  Map<String, dynamic>? _visitDetail;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.visitId != null && widget.scheduledAt == null) {
      _fetchVisitDetail();
    }
  }

  Future<void> _fetchVisitDetail() async {
    setState(() => _isLoading = true);
    try {
      final detail = await CheckInBloc.show(widget.visitId!);
      if (!mounted) return;
      setState(() {
        _visitDetail = detail;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  String _getFormattedDate() {
    String? rawDate = widget.scheduledAt ?? _visitDetail?['scheduled_at'];
    if (rawDate == null || rawDate.isEmpty) return "-";
    try {
      DateTime dt = DateTime.parse(rawDate);
      return "${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}";
    } catch (_) {
      return rawDate.split(' ').first;
    }
  }

  String _getFormattedTime() {
    String? rawDate = widget.scheduledAt ?? _visitDetail?['scheduled_at'];
    if (rawDate == null || rawDate.isEmpty) return "-";
    try {
      DateTime dt = DateTime.parse(rawDate);
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} WIB";
    } catch (_) {
      if (rawDate.contains(' ')) return "${rawDate.split(' ').last} WIB";
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String displayCode = widget.visitCode ?? _visitDetail?['visit_code'] ?? "-";

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: _isLoading
                ? const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF006B3F)),
                      SizedBox(height: 16),
                      Text(
                        "Memuat tiket kunjungan...",
                        style: TextStyle(fontSize: 13, color: Color(0xFF778195)),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon Check-in Berhasil
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF006B3F).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF006B3F),
                          size: 64,
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        "Check-in Berhasil!",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF172033),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Terima kasih telah mengisi buku tamu. Jadwal pertemuan Anda telah dicatat dalam sistem.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Color(0xFF778195), height: 1.4),
                      ),
                      const SizedBox(height: 24),

                      // 🟢 Kartu Kode Visit (Tanpa Nomor Antrean)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF006B3F).withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF006B3F).withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "KODE VISIT",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF778195),
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              displayCode,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF006B3F),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Kartu Detail Jadwal Pertemuan
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F7FC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF006B3F).withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Jadwal Pertemuan Terkonfirmasi:",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF006B3F),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: Color(0xFF778195)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Tanggal: ${_getFormattedDate()}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF172033),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 16, color: Color(0xFF778195)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Jam: ${_getFormattedTime()}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF172033),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Tombol Selesai
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF006B3F),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomepageScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          child: const Text(
                            "Selesai",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}