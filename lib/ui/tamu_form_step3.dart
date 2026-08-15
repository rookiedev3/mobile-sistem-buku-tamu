import 'dart:io';
import 'package:flutter/material.dart';
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

  /// Proses Submit Akhir Gabungan Step 1 & Step 2 ke API Laravel
  Future<void> _submitFinalCheckIn() async {
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
        photoFile: step1['photo_file'] as File?,
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
    final photoFile = step1['photo_file'] as File?;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(20.0), // 🟢 Dioptimalkan dari 32 ke 20 agar lebih lega di HP
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tombol Kembali
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back_ios, size: 14, color: Color(0xFF006B3F)),
                      SizedBox(width: 4),
                      Text(
                        "Kembali ke Tahap 2",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006B3F),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 🟢 Header Indikator Tahap 3 (Bebas Overflow)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Text(
                        "Konfirmasi Check-in",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF172033),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Tahap 3 dari 4",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF006B3F),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  "Mohon periksa kembali seluruh data Anda sebelum mengirim formulir.",
                  style: TextStyle(fontSize: 13, color: Color(0xFF778195)),
                ),
                const SizedBox(height: 24),

                // --- RINGKASAN FOTO & IDENTITAS ---
                if (photoFile != null)
                  Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
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

                const Divider(height: 32),

                _buildSectionHeader("Detail Kunjungan"),
                _buildInfoRow("Tujuan Bertemu (PIC)", step2['staff_name']),
                _buildInfoRow("Cabang Kantor", step2['branch_name']),
                _buildInfoRow("Jenis Kunjungan", step2['purpose_name']),
                _buildInfoRow("Tanggal Kunjungan", step2['formatted_date']),
                _buildInfoRow("Produk Diminati", step2['product_name']),
                _buildInfoRow("Sumber Informasi", step2['source_name']),
                _buildInfoRow("Catatan Detail", step2['notes']),

                const SizedBox(height: 32),

                // Tombol Final Submit
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
                    onPressed: _isSubmitting ? null : _submitFinalCheckIn,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Konfirmasi & Simpan Check-in",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Color(0xFF006B3F),
        ),
      ),
    );
  }

  // 🟢 Penyesuaian Lebar Kolom Label agar Isi Data Memiliki Ruang Lebih Luas
  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125, // 👈 Disesuaikan dari 140 ke 125 agar nilai teks di sebelah kanan tidak tertekan
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF778195)),
            ),
          ),
          const Text(": ", style: TextStyle(fontSize: 12, color: Color(0xFF778195))),
          Expanded(
            child: Text(
              (value == null || value.trim().isEmpty) ? '-' : value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF172033),
              ),
            ),
          ),
        ],
      ),
    );
  }
}