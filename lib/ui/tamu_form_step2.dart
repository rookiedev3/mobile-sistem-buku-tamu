import 'package:flutter/material.dart';
import 'tamu_form_step3.dart';

class TamuFormStep2 extends StatefulWidget {
  const TamuFormStep2({Key? key}) : super(key: key);

  @override
  _TamuFormStep2State createState() => _TamuFormStep2State();
}

class _TamuFormStep2State extends State<TamuFormStep2> {
  // Controller untuk Detail Kunjungan
  final _detailController = TextEditingController();
  final _tanggalController = TextEditingController();

  // State untuk Dropdown Tahap 2
  String? _selectedStaff;
  final List<String> _listStaff = ['Budi (Staff IT)', 'Siti (Customer Service)', 'Andi (Sales Manager)', 'Dewi (Admin Cabang)'];

  String? _selectedCabang;
  final List<String> _listCabang = ['Cabang Sleman', 'Cabang Magelang'];

  String? _selectedJenisKunjungan;
  final List<String> _listJenisKunjungan = ['Konsultasi', 'Meeting', 'Pembayaran', 'Pengambilan Barang', 'Lainnya'];

  String? _selectedProduk;
  final List<String> _listProduk = ['Pembuatan Web', 'POS (Point of Sales)', 'SEO Optimization', 'Aplikasi Mobile', 'Digital Marketing'];

  String? _selectedSumber;
  final List<String> _listSumber = ['Google', 'Instagram', 'Rekomendasi Teman', 'LinkedIn', 'Walk-in (Lewat Saja)'];

  @override
  void dispose() {
    _detailController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

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
                // Tombol Kembali ke Tahap 1
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.arrow_back_ios, size: 14, color: Color(0xFF006B3F)),
                      SizedBox(width: 4),
                      Text(
                        "Kembali ke Tahap 1",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF006B3F)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Indikator Tahap (Step 2 of 4)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Detail Kunjungan Tamu",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                    ),
                    Text(
                      "Tahap 2 dari 4",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF006B3F)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  "Silakan lengkapi informasi tujuan dan keperluan kunjungan Anda.",
                  style: TextStyle(fontSize: 13, color: Color(0xFF778195)),
                ),
                const SizedBox(height: 24),

                // 1. Tujuan Bertemu (Staff / PIC)
                const Text("Tujuan Bertemu (Staff / PIC) *", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedStaff,
                  hint: const Text("Pilih Staff / PIC yang dituju", style: TextStyle(fontSize: 13, color: Color(0xFF778195))),
                  decoration: _inputDecoration(),
                  items: _listStaff.map((String staff) {
                    return DropdownMenuItem<String>(
                      value: staff,
                      child: Text(staff, style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedStaff = val),
                ),
                const SizedBox(height: 16),

                // 2. Cabang Kantor
                const Text("Cabang Kantor *", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedCabang,
                  hint: const Text("Pilih cabang kantor", style: TextStyle(fontSize: 13, color: Color(0xFF778195))),
                  decoration: _inputDecoration(),
                  items: _listCabang.map((String cabang) {
                    return DropdownMenuItem<String>(
                      value: cabang,
                      child: Text(cabang, style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCabang = val),
                ),
                const SizedBox(height: 16),

                // 3. Jenis Kunjungan
                const Text("Jenis Kunjungan *", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedJenisKunjungan,
                  hint: const Text("Pilih jenis kunjungan", style: TextStyle(fontSize: 13, color: Color(0xFF778195))),
                  decoration: _inputDecoration(),
                  items: _listJenisKunjungan.map((String jenis) {
                    return DropdownMenuItem<String>(
                      value: jenis,
                      child: Text(jenis, style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedJenisKunjungan = val),
                ),
                const SizedBox(height: 16),

                // 4. Produk / Layanan yang Diminati
                const Text("Produk / Layanan yang Diminati", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedProduk,
                  hint: const Text("Pilih produk atau layanan", style: TextStyle(fontSize: 13, color: Color(0xFF778195))),
                  decoration: _inputDecoration(),
                  items: _listProduk.map((String produk) {
                    return DropdownMenuItem<String>(
                      value: produk,
                      child: Text(produk, style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedProduk = val),
                ),
                const SizedBox(height: 16),

                // 5. Tanggal Kunjungan
                const Text("Tanggal Kunjungan *", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: _tanggalController,
                  readOnly: true,
                  decoration: _inputDecoration().copyWith(
                    hintText: "Pilih tanggal kunjungan",
                    suffixIcon: const Icon(Icons.calendar_today, size: 18, color: Color(0xFF006B3F)),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2025),
                      lastDate: DateTime(2030),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _tanggalController.text = "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // 6. Sumber Mengetahui IT Solution
                const Text("Sumber Mengetahui IT Solution", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedSumber,
                  hint: const Text("Pilih sumber informasi", style: TextStyle(fontSize: 13, color: Color(0xFF778195))),
                  decoration: _inputDecoration(),
                  items: _listSumber.map((String sumber) {
                    return DropdownMenuItem<String>(
                      value: sumber,
                      child: Text(sumber, style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedSumber = val),
                ),
                const SizedBox(height: 16),

                // 7. Detail Kunjungan
                const Text("Detail Kunjungan", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: _detailController,
                  maxLines: 3,
                  decoration: _inputDecoration().copyWith(
                    hintText: "Tuliskan keterangan detail keperluan Anda...",
                  ),
                ),
                const SizedBox(height: 28),

                // Tombol Lanjut ke Tahap 3
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
                    if (_selectedStaff == null || _selectedCabang == null || _selectedJenisKunjungan == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Harap lengkapi kolom wajib (*)')),
                      );
                      return;
                    }

                    // 👇 GANTI / TAMBAHKAN NAVIGATOR.PUSH INI SUPAYA PINDAH KE TAHAP 3
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TamuFormStep3()),
                    );
                  },
                  child: const Text(
                    "Lanjut ke Tahap 3",
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

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF4F7FC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }
}