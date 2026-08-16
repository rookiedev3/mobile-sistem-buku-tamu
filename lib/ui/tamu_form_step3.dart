import 'dart:typed_data'; 
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:mobile_flutter/bloc/check_in_bloc.dart';
import 'package:mobile_flutter/model/check_in.dart';
import 'tamu_form_step4.dart';

class TamuFormStep3 extends StatefulWidget {
  final Map<String, dynamic>? step1Data;
  final Map<String, dynamic>? step2Data;

  const TamuFormStep3({
    super.key,
    this.step1Data,
    this.step2Data,
  });

  @override
  State<TamuFormStep3> createState() => _TamuFormStep3State();
}

class _TamuFormStep3State extends State<TamuFormStep3> {
  bool _isSubmitting = false;
  bool _isChecked = false;

  /// Proses Submit Akhir Gabungan Step 1 & Step 2 ke API Laravel
  Future<void> _submitFinalCheckIn() async {
    if (!_isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap centang kotak konfirmasi data terlebih dahulu!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final step1 = widget.step1Data ?? {};
      final step2 = widget.step2Data ?? {};

      CheckInResult result = await CheckInBloc.store(
        name: step1['name'] ?? '',
        companyName: step1['company_name'] ?? '',
        email: step1['email'] ?? '',
        guestCategoryId: step1['guest_category_id'] ?? '',
        position: step1['position'] ?? '',
        phone: step1['phone'] ?? '',
        address: step1['address'],
        photoFile: step1['photo_file'] as XFile?,
        assignedTo: step2['assigned_to'] ?? 0,
        branchId: step2['branch_id'] ?? 0,
        purposeId: step2['purpose_id'] ?? 0,
        scheduledAt: step2['scheduled_at'] ?? '',
        notes: step2['notes'] ?? '',
        productInterest: (step2['product_interest'] as List?)?.cast<int>(),
        sourceId: step2['source_id'],
      );

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      // Pindah ke Step 4 (Halaman Sukses / Bukti Tiket)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => TamuFormStep4(
            visitId: result.visitId,
            visitCode: result.visitCode,
            queueNumber: result.queueNumber,
            scheduledAt: step2['scheduled_at'],
          ),
        ),
        (route) => route.isFirst,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal memproses check-in: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final step1 = widget.step1Data ?? {};
    final step2 = widget.step2Data ?? {};
    final photoFile = step1['photo_file'] as XFile?;

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
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Judul & Tahap
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              "Konfirmasi Check-in",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Tahap 3 / 4",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Mohon periksa kembali seluruh data Anda sebelum mengirim formulir.",
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                      const SizedBox(height: 20),

                      // --- CARD SEMI-TRANSPARAN UNTUK ISI DATA ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08), // Latar belakang putih transparan tipis
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15), // Border tipis elegan
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Ringkasan Foto Tamu
                            if (photoFile != null)
                              Center(
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFFC7AB6B),
                                      width: 2,
                                    ),
                                    image: DecorationImage(
                                      image: FileImage(photoFile),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),

                            _buildSectionHeader("Identitas Tamu"),
                            _buildInfoRow("Nama Lengkap", step1['name']),
                            _buildInfoRow("Instansi / Perusahaan", step1['company_name']),
                            _buildInfoRow("Jabatan", step1['position']),
                            _buildInfoRow("Nomor WhatsApp", step1['phone']),
                            _buildInfoRow("Email", step1['email']),
                            _buildInfoRow("Alamat", step1['address']),

                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14.0),
                              child: Divider(color: Colors.white24, height: 1),
                            ),

                            _buildSectionHeader("Detail Kunjungan"),
                            _buildInfoRow("Tujuan Bertemu (PIC)", step2['staff_name']),
                            _buildInfoRow("Cabang Kantor", step2['branch_name']),
                            _buildInfoRow("Jenis Kunjungan", step2['purpose_name']),
                            _buildInfoRow("Tanggal Kunjungan", step2['formatted_date']),
                            _buildInfoRow("Produk Diminati", step2['product_name']),
                            _buildInfoRow("Sumber Informasi", step2['source_name']),
                            _buildInfoRow("Catatan Detail", step2['notes']),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Kolom Checkbox Persetujuan
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: _isChecked,
                              activeColor: const Color(0xFFC7AB6B),
                              checkColor: Colors.white,
                              side: const BorderSide(color: Colors.white, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              onChanged: (bool? value) {
                                setState(() {
                                  _isChecked = value ?? false;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              "Saya menyatakan bahwa data yang saya isi di atas adalah benar dan sesuai.",
                              style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.3),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Tombol Final Submit
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isChecked ? const Color(0xFFC7AB6B) : Colors.grey.shade400,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          onPressed: (_isSubmitting || !_isChecked) ? null : _submitFinalCheckIn,
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.check_circle_outline, size: 20),
                          label: _isSubmitting
                              ? const SizedBox.shrink()
                              : const Text(
                                  "Konfirmasi & Simpan Check-in",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Tombol "Kembali ke Tahap 2" di Paling Bawah Sendiri
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.arrow_back_ios, size: 12, color: Colors.white60),
                              SizedBox(width: 4),
                              Text(
                                "Kembali ke Tahap 2",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white60,
                                ),
                              ),
                            ],
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFFC7AB6B),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ),
          const Text(": ", style: TextStyle(fontSize: 12, color: Colors.white70)),
          Expanded(
            child: Text(
              (value == null || value.trim().isEmpty) ? '-' : value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
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