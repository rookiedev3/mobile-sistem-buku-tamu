import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:mobile_flutter/bloc/check_in_bloc.dart';
import 'homepage_screen.dart';

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
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Gradasi Hijau Korporat
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF01281b),
                  Color(0xFF013220),
                  Color(0xFF006B3F),
                ],
                stops: [0.0, 0.4, 1.0],
              ),
            ),
          ),

          // 2. Motif Setengah Lingkaran Background
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundArcsPainter(),
            ),
          ),

          // 3. Konten Tampilan Penuh
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Ikon Sukses
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFFC7AB6B),
                                size: 64,
                              ),
                            ),
                            const SizedBox(height: 20),

                            const Text(
                              "Check-in Berhasil!",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Terima kasih telah mengisi buku tamu. Jadwal pertemuan Anda telah dicatat dalam sistem.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
                            ),
                            const SizedBox(height: 24),

                            // Kotak Informasi Jadwal Pertemuan (Nomor Antrean & Kode Visit Dihapus)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Jadwal Pertemuan Terkonfirmasi",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF006B3F),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today, size: 16, color: Color(0xFF778195)),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Tanggal: ${_getFormattedDate()}",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF172033),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 16, color: Color(0xFF778195)),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Jam: ${_getFormattedTime()}",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF172033),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Tombol Selesai (Background #C7AB6B, Teks Putih)
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFC7AB6B),
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
          ),
        ],
      ),
    );
  }
}

// Custom Painter untuk Menggambar Setengah Lingkaran (Arc Tunggal) yang Elegan
class BackgroundArcsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final arcs = [
      {'x': size.width * 0.15, 'y': size.height * 0.2, 'r': 110.0, 'start': 0.0, 'sweep': math.pi, 'opacity': 0.12},
      {'x': size.width * 0.85, 'y': size.height * 0.3, 'r': 150.0, 'start': math.pi / 2, 'sweep': math.pi * 1.2, 'opacity': 0.08},
      {'x': size.width * 0.75, 'y': size.height * 0.8, 'r': 180.0, 'start': math.pi, 'sweep': math.pi, 'opacity': 0.1},
      {'x': size.width * 0.25, 'y': size.height * 0.75, 'r': 130.0, 'start': math.pi * 1.5, 'sweep': math.pi * 1.1, 'opacity': 0.14},
    ];

    for (var a in arcs) {
      paint.color = Colors.white.withOpacity(a['opacity'] as double);
      
      final rect = Rect.fromCircle(
        center: Offset(a['x'] as double, a['y'] as double),
        radius: a['r'] as double,
      );
      
      canvas.drawArc(
        rect,
        a['start'] as double,
        a['sweep'] as double,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}