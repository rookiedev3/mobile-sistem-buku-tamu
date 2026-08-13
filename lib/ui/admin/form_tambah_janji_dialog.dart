import 'package:flutter/material.dart';

class FormTambahJanjiDialog extends StatefulWidget {
  const FormTambahJanjiDialog({Key? key}) : super(key: key);

  @override
  State<FormTambahJanjiDialog> createState() => _FormTambahJanjiDialogState();
}

class _FormTambahJanjiDialogState extends State<FormTambahJanjiDialog> {
  int _currentSlide = 0;
  final PageController _pageController = PageController();
  final Color corporateGreen = const Color(0xFF006B3F);

  // Controller Slide 1 (Data Diri)
  final _namaController = TextEditingController();
  final _instansiController = TextEditingController();
  final _alamatController = TextEditingController();
  final _jabatanController = TextEditingController();
  final _waController = TextEditingController();
  final _emailController = TextEditingController();
  String? _selectedKategori;
  bool _adaFoto = false;

  // Controller & State Slide 2 (Detail Kunjungan)
  String? _selectedCabang;
  String? _selectedPic;
  String? _selectedKeperluan;
  String? _selectedProduk;
  DateTime? _selectedTanggal;
  TimeOfDay? _selectedWaktu;
  String? _selectedSumber;
  final _detailController = TextEditingController();

  // State Slide 3 (Konfirmasi & Persetujuan)
  bool _isDisetujui = false;

  @override
  void dispose() {
    _pageController.dispose();
    _namaController.dispose();
    _instansiController.dispose();
    _alamatController.dispose();
    _jabatanController.dispose();
    _waController.dispose();
    _emailController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  void _nextSlide() {
    if (_currentSlide < 2) {
      if (_currentSlide == 0) {
        if (_namaController.text.isEmpty || _waController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nama Lengkap dan No. WhatsApp wajib diisi!')),
          );
          return;
        }
      } else if (_currentSlide == 1) {
        if (_selectedCabang == null || _selectedPic == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pilih Cabang dan PIC Tujuan terlebih dahulu!')),
          );
          return;
        }
      }

      setState(() {
        _currentSlide++;
        _pageController.animateToPage(
          _currentSlide,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void _prevSlide() {
    if (_currentSlide > 0) {
      setState(() {
        _currentSlide--;
        _pageController.animateToPage(
          _currentSlide,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Pop-up
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_month_rounded, color: corporateGreen, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      "Tambah Janji Temu (${_currentSlide + 1}/3)",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: corporateGreen),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (_currentSlide + 1) / 3,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(corporateGreen),
            ),
            const SizedBox(height: 16),

            // KONTEN FORM SLIDE
            SizedBox(
              height: 360,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildSlide1(),
                  _buildSlide2(),
                  _buildSlide3(),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tombol Navigasi Bawah
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _currentSlide > 0
                    ? Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: OutlinedButton(
                            onPressed: _prevSlide,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: corporateGreen),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: const Text("Sebelumnya", style: TextStyle(color: Color(0xFF006B3F), fontSize: 12)),
                          ),
                        ),
                      )
                    : const Spacer(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: corporateGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: _currentSlide == 2
                          ? (_isDisetujui
                              ? () {
                                  Navigator.pop(context, {
                                    "nama": _namaController.text,
                                    "jabatan": _jabatanController.text.isEmpty ? "Tamu" : _jabatanController.text,
                                    "jenis": _selectedKeperluan ?? "Umum",
                                    "tujuan": "${_selectedPic ?? 'PIC'} (${_selectedCabang ?? 'Cabang'})",
                                    "jam": _selectedWaktu != null ? _selectedWaktu!.format(context) : "10:00 WIB",
                                  });
                                }
                              : null)
                          : _nextSlide,
                      child: Text(
                        _currentSlide == 2 ? "Simpan" : "Selanjutnya",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- SLIDE 1 ---
  Widget _buildSlide1() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("1. Informasi Pengunjung", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF172033))),
          const SizedBox(height: 12),
          _buildTextField("Nama Lengkap *", _namaController),
          const SizedBox(height: 10),
          _buildTextField("Asal Instansi / Perusahaan", _instansiController),
          const SizedBox(height: 10),
          _buildTextField("Alamat", _alamatController),
          const SizedBox(height: 10),
          _buildTextField("Jabatan", _jabatanController),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildTextField("No. WhatsApp *", _waController, keyboardType: TextInputType.phone)),
              const SizedBox(width: 10),
              Expanded(child: _buildTextField("Email", _emailController, keyboardType: TextInputType.emailAddress)),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedKategori,
            decoration: _inputDecoration("Pilih Kategori Pengunjung"),
            items: ['Mitra', 'Umum', 'Vendor', 'Media', 'VIP'].map((val) => DropdownMenuItem(value: val, child: Text(val, style: const TextStyle(fontSize: 12)))).toList(),
            onChanged: (val) => setState(() => _selectedKategori = val),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => setState(() => _adaFoto = true),
                icon: const Icon(Icons.upload_file, size: 14, color: Color(0xFF006B3F)),
                label: const Text("Upload Foto (Opsional)", style: TextStyle(fontSize: 11, color: Color(0xFF006B3F))),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF006B3F)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
              ),
              const SizedBox(width: 10),
              if (_adaFoto) const Text("Terlampir ✓", style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // --- SLIDE 2 ---
  Widget _buildSlide2() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("2. Detail & Tujuan Kunjungan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF172033))),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedCabang,
            decoration: _inputDecoration("Pilih Cabang *"),
            items: ['Cabang Sleman', 'Cabang Magelang'].map((val) => DropdownMenuItem(value: val, child: Text(val, style: const TextStyle(fontSize: 12)))).toList(),
            onChanged: (val) => setState(() => _selectedCabang = val),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedPic,
            decoration: _inputDecoration("Pilih PIC Tujuan *"),
            items: ['Bapak Manager', 'Rian Sales', 'Siska Staff'].map((val) => DropdownMenuItem(value: val, child: Text(val, style: const TextStyle(fontSize: 12)))).toList(),
            onChanged: (val) => setState(() => _selectedPic = val),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedKeperluan,
            decoration: _inputDecoration("Keperluan Kunjungan"),
            items: ['Meeting Bisnis', 'Konsultasi', 'Pengiriman Paket', 'Interview'].map((val) => DropdownMenuItem(value: val, child: Text(val, style: const TextStyle(fontSize: 12)))).toList(),
            onChanged: (val) => setState(() => _selectedKeperluan = val),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedProduk,
            decoration: _inputDecoration("Produk / Layanan yang Diminati"),
            items: ['Software POS', 'Sistem Buku Tamu', 'ERP Sistem', 'Custom Development'].map((val) => DropdownMenuItem(value: val, child: Text(val, style: const TextStyle(fontSize: 12)))).toList(),
            onChanged: (val) => setState(() => _selectedProduk = val),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
                    if (picked != null) setState(() => _selectedTanggal = picked);
                  },
                  child: InputDecorator(
                    decoration: _inputDecoration("Tanggal"),
                    child: Text(_selectedTanggal == null ? 'Pilih Tanggal' : '${_selectedTanggal!.day}/${_selectedTanggal!.month}/${_selectedTanggal!.year}', style: const TextStyle(fontSize: 12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                    if (picked != null) setState(() => _selectedWaktu = picked);
                  },
                  child: InputDecorator(
                    decoration: _inputDecoration("Jam"),
                    child: Text(_selectedWaktu == null ? 'Pilih Jam' : _selectedWaktu!.format(context), style: const TextStyle(fontSize: 12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedSumber,
            decoration: _inputDecoration("Sumber Informasi"),
            items: ['Google Search', 'Media Sosial', 'Rekomendasi', 'Pameran'].map((val) => DropdownMenuItem(value: val, child: Text(val, style: const TextStyle(fontSize: 12)))).toList(),
            onChanged: (val) => setState(() => _selectedSumber = val),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _detailController,
            maxLines: 2,
            style: const TextStyle(fontSize: 12),
            decoration: _inputDecoration("Detail Kunjungan (Opsional)"),
          ),
        ],
      ),
    );
  }

  // --- SLIDE 3 (SEMUA DATA DARI SLIDE 1 & 2 DITAMPILKAN LENGKAP) ---
  Widget _buildSlide3() {
    String tanggalStr = _selectedTanggal == null ? '-' : '${_selectedTanggal!.day}/${_selectedTanggal!.month}/${_selectedTanggal!.year}';
    String waktuStr = _selectedWaktu == null ? '-' : _selectedWaktu!.format(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("3. Konfirmasi Data Janji Temu", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF172033))),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F7FC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Informasi Pengunjung", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF006B3F))),
                const Divider(height: 10),
                _buildInfoRow("Nama Lengkap", _namaController.text),
                _buildInfoRow("Instansi", _instansiController.text),
                _buildInfoRow("Alamat", _alamatController.text),
                _buildInfoRow("Jabatan", _jabatanController.text),
                _buildInfoRow("No. WA", _waController.text),
                _buildInfoRow("Email", _emailController.text),
                _buildInfoRow("Kategori", _selectedKategori ?? '-'),
                _buildInfoRow("Foto", _adaFoto ? 'Terlampir' : '-'),
                const SizedBox(height: 8),
                const Text("Detail & Tujuan Kunjungan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF006B3F))),
                const Divider(height: 10),
                _buildInfoRow("Cabang", _selectedCabang ?? '-'),
                _buildInfoRow("PIC Tujuan", _selectedPic ?? '-'),
                _buildInfoRow("Keperluan", _selectedKeperluan ?? '-'),
                _buildInfoRow("Produk", _selectedProduk ?? '-'),
                _buildInfoRow("Tanggal", tanggalStr),
                _buildInfoRow("Jam", waktuStr),
                _buildInfoRow("Sumber Info", _selectedSumber ?? '-'),
                _buildInfoRow("Detail", _detailController.text),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: _isDisetujui,
                  activeColor: corporateGreen,
                  onChanged: (val) => setState(() => _isDisetujui = val ?? false),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text("Saya menyatakan data yang diisi sudah benar dan sesuai.", style: TextStyle(fontSize: 11, color: Color(0xFF475569))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 12),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 11, color: Color(0xFF778195)),
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        filled: true,
        fillColor: const Color(0xFFF4F7FC),
        isDense: true,
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 11, color: Color(0xFF778195)),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      filled: true,
      fillColor: const Color(0xFFF4F7FC),
      isDense: true,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF778195), fontWeight: FontWeight.w600))),
          const Text(": ", style: TextStyle(fontSize: 11)),
          Expanded(child: Text(value.isEmpty ? '-' : value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF172033)))),
        ],
      ),
    );
  }
}