import 'package:flutter/material.dart';
import 'tamu_form_step4.dart';

class TamuFormStep3 extends StatefulWidget {
  // Anda bisa menerima data dari Step 1 & 2 di sini nanti jika dibutuhkan
  const TamuFormStep3({Key? key}) : super(key: key);

  @override
  _TamuFormStep3State createState() => _TamuFormStep3State();
}

class _TamuFormStep3State extends State<TamuFormStep3> {
  // State untuk Checkbox Persetujuan Konfirmasi
  bool _isAgreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tombol Kembali ke Tahap 2
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.arrow_back_ios, size: 14, color: Color(0xFF006B3F)),
                      SizedBox(width: 4),
                      Text(
                        "Kembali ke Tahap 2",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF006B3F)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Indikator Tahap (Step 3 of 3 atau 3 of 4)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Konfirmasi Check-in",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                    ),
                    Text(
                      "Tahap 3 dari 3",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF006B3F)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  "Periksa kembali ringkasan data kunjungan Anda sebelum melakukan konfirmasi akhir.",
                  style: TextStyle(fontSize: 13, color: Color(0xFF778195)),
                ),
                const SizedBox(height: 24),

                // --- KARTU RINGKASAN DATA DIRI (TAHAP 1) ---
                const Text(
                  "Ringkasan Data Diri",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF006B3F)),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F7FC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _RowInfo(label: "Nama Lengkap", value: "Ahmad Fauzi"),
                      _RowInfo(label: "Email", value: "ahmad.fauzi@example.com"),
                      _RowInfo(label: "Kategori", value: "Mitra"),
                      _RowInfo(label: "Asal instansi", value: "pnc"),
                       _RowInfo(label: "Jabatan", value: "Direktur Pemasaran"),
                      _RowInfo(label: "No. WhatsApp", value: "081234567890"),
                      _RowInfo(label: "Alamat", value: "jl . Raya No. 123, Sleman, Yogyakarta"),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // --- KARTU RINGKASAN KUNJUNGAN (TAHAP 2) ---
                const Text(
                  "Ringkasan Kunjungan",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF006B3F)),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F7FC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _RowInfo(label: "Tujuan PIC", value: "Budi (Staff IT)"),
                      _RowInfo(label: "Cabang Kantor", value: "Cabang Sleman"),
                      _RowInfo(label: "Jenis Kunjungan", value: "Konsultasi"),
                      _RowInfo(label: "Layanan", value: "Pembuatan Web"),
                      _RowInfo(label: "Tanggal", value: "12-06-2026"),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // --- CEKLIS PERSETUJUAN (CHECKBOX) ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _isAgreed,
                        activeColor: const Color(0xFF006B3F),
                        onChanged: (bool? value) {
                          setState(() {
                            _isAgreed = value ?? false;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Saya menyatakan bahwa data yang saya isi di atas adalah benar dan sesuai dengan keperluan kunjungan saya ke perusahaan.",
                        style: TextStyle(fontSize: 12.5, color: Color(0xFF172033), height: 1.4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Tombol Final: Selesaikan Check-in
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006B3F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      if (!_isAgreed) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Anda harus mencentang kotak persetujuan terlebih dahulu!')),
                        );
                        return;
                      }

                     Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TamuFormStep4()),
                    );
                    },
                    child: const Text(
                      "Konfirmasi & Selesaikan Check-in",
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

// Widget Kecil Pendukung untuk Baris Teks Ringkasan
class _RowInfo extends StatelessWidget {
  final String label;
  final String value;

  const _RowInfo({Key? key, required this.label, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF778195))),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
        ],
      ),
    );
  }
}