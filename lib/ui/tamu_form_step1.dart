import 'package:flutter/material.dart';
import 'tamu_form_step2.dart'; // <-- Jangan lupa impor ini di atas


class TamuFormStep1 extends StatefulWidget {
  const TamuFormStep1({Key? key}) : super(key: key);

  @override
  _TamuFormStep1State createState() => _TamuFormStep1State();
}

class _TamuFormStep1State extends State<TamuFormStep1> {
  // Controller untuk Data Diri Tahap 1
  final _namaController = TextEditingController();
  final _instansiController = TextEditingController();
  final _alamatController = TextEditingController();
  final _jabatanController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _emailController = TextEditingController();

  // State untuk Dropdown Kategori Pengunjung
  String? _selectedKategori;
  final List<String> _listKategori = ['Mitra', 'Umum', 'Instansi Pemerintah', 'Media', 'Vendor'];

  @override
  void dispose() {
    _namaController.dispose();
    _instansiController.dispose();
    _alamatController.dispose();
    _jabatanController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
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
                // Tombol Kembali ke Beranda
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.arrow_back_ios, size: 14, color: Color(0xFF006B3F)),
                      SizedBox(width: 4),
                      Text(
                        "Kembali ke Beranda",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF006B3F)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Indikator Tahap (Step 1 of 4)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Check-in Tamu Mandiri",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                    ),
                    Text(
                      "Tahap 1 dari 4",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF006B3F)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  "Silakan isi data diri dan unggah foto Anda terlebih dahulu.",
                  style: TextStyle(fontSize: 13, color: Color(0xFF778195)),
                ),
                const SizedBox(height: 24),

                // --- UPLOAD FOTO TAMU ---
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F7FC),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF006B3F).withOpacity(0.3), width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_outlined, size: 36, color: Color(0xFF006B3F)),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          // Simulasi ambil foto / upload
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Simulasi Ambil/Unggah Foto Tamu')),
                          );
                        },
                        icon: const Icon(Icons.upload, size: 16, color: Color(0xFF006B3F)),
                        label: const Text("Unggah Foto Tamu", style: TextStyle(color: Color(0xFF006B3F), fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 1. Nama Lengkap
                const Text("Nama Lengkap *", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: _namaController,
                  decoration: _inputDecoration("Masukkan nama lengkap Anda"),
                ),
                const SizedBox(height: 16),

                // 2. Asal Instansi
                const Text("Asal Instansi / Perusahaan *", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: _instansiController,
                  decoration: _inputDecoration("Contoh: PT Maju Jaya"),
                ),
                const SizedBox(height: 16),

                // 3. Alamat
                const Text("Alamat", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: _alamatController,
                  decoration: _inputDecoration("Alamat instansi atau domisili"),
                ),
                const SizedBox(height: 16),

                // 4. Jabatan
                const Text("Jabatan", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: _jabatanController,
                  decoration: _inputDecoration("Contoh: Manager / Staff / Tamu"),
                ),
                const SizedBox(height: 16),

                // 5. No WhatsApp
                const Text("Nomor WhatsApp *", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: _whatsappController,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration("081234567890"),
                ),
                const SizedBox(height: 16),

                // 6. Email
                const Text("Email", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration("email@domain.com"),
                ),
                const SizedBox(height: 16),

                // 7. Kategori Pengunjung (Dropdown)
                const Text("Kategori Pengunjung *", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedKategori,
                  hint: const Text("Pilih kategori pengunjung", style: TextStyle(fontSize: 14, color: Color(0xFF778195))),
                  decoration: _inputDecoration(""),
                  items: _listKategori.map((String kat) {
                    return DropdownMenuItem<String>(
                      value: kat,
                      child: Text(kat, style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (String? val) {
                    setState(() {
                      _selectedKategori = val;
                    });
                  },
                ),
                const SizedBox(height: 28),

                // Tombol Lanjut ke Tahap 2
                // Tombol Lanjut ke Tahap 2
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
                      // Validasi sederhana
                      if (_namaController.text.isEmpty || _whatsappController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Nama dan No WhatsApp wajib diisi!')),
                        );
                        return;
                      }

                  // 👇 INI PERINTAH UNTUK REDIRECT KE TAHAP 2
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TamuFormStep2()),
                  );
                },
                child: const Text(
                  "Lanjut ke Tahap 2",
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

  // Helper Dekorasi TextField supaya kodingan rapi
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF778195)),
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