import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_flutter/bloc/check_in_bloc.dart';
import 'package:mobile_flutter/model/check_in.dart';

class FormTambahJanjiDialog extends StatefulWidget {
  const FormTambahJanjiDialog({super.key});

  @override
  State<FormTambahJanjiDialog> createState() => _FormTambahJanjiDialogState();
}

class _FormTambahJanjiDialogState extends State<FormTambahJanjiDialog> {
  final Color corporateGreen = const Color(0xFF006B3F);
  int _currentStep = 0;

  // STEP 1: Controllers Identitas Tamu & Foto (Opsional)
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _instansiController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _jabatanController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImageFile;
  Uint8List? _imageBytes;

  // STEP 2: Controllers & Dropdown Detail Kunjungan
  int? _selectedCabangId;
  int? _selectedStaffId;
  int? _selectedPurposeId;
  int? _selectedProdukId;
  int? _selectedSumberId;

  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _tanggalController = TextEditingController();
  DateTime? _selectedDateTime;

  // Master Data API via CheckInBloc
  List<OptionItem> _listCabang = [];
  List<OptionItem> _listStaff = [];
  List<OptionItem> _listPurposes = [];
  List<OptionItem> _listProduk = [];
  List<OptionItem> _listSumber = [];
  bool _isLoadingMasterData = true;

  // STEP 3: State Checkbox Konfirmasi
  bool _isChecked = false;

  @override
  void initState() {
    super.initState();
    _fetchMasterData();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _instansiController.dispose();
    _alamatController.dispose();
    _jabatanController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _detailController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

  /// Memuat Data Master Dropdown dari Backend via CheckInBloc
  Future<void> _fetchMasterData() async {
    try {
      CheckInMasterData masterData = await CheckInBloc.getFormData();
      if (!mounted) return;
      setState(() {
        _listCabang = masterData.branches;
        _listStaff = masterData.pics;
        _listPurposes = masterData.visitPurposes;
        _listProduk = masterData.products;
        _listSumber = masterData.leadSources;
        _isLoadingMasterData = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingMasterData = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal memuat data formulir: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Filter Staff / PIC Berdasarkan Cabang
  List<OptionItem> get _filteredStaff {
    if (_selectedCabangId == null) return [];
    return _listStaff.where((item) => item.branchId == _selectedCabangId).toList();
  }

  /// Picker Foto dari Kamera atau Galeri
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _pickedImageFile = image;
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Pengiriman Akhir Form Janji Tamu (Step 3 Submit)
  void _submitForm() {
    if (!_isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap centang kotak konfirmasi data terlebih dahulu!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String staffName = _listStaff
        .firstWhere(
          (e) => e.id == _selectedStaffId,
          orElse: () => OptionItem(id: 0, name: '-'),
        )
        .name;

    String branchName = _listCabang
        .firstWhere(
          (e) => e.id == _selectedCabangId,
          orElse: () => OptionItem(id: 0, name: '-'),
        )
        .name;

    String purposeName = _listPurposes
        .firstWhere(
          (e) => e.id == _selectedPurposeId,
          orElse: () => OptionItem(id: 0, name: '-'),
        )
        .name;

    final resultData = {
      'nama': _namaController.text.trim(),
      'instansi': _instansiController.text.trim(),
      'alamat': _alamatController.text.trim(),
      'jabatan': _jabatanController.text.trim(),
      'phone': _phoneController.text.trim(),
      'email': _emailController.text.trim(),
      'branch_id': _selectedCabangId,
      'branch_name': branchName,
      'staff_id': _selectedStaffId,
      'tujuan': staffName,
      'purpose_id': _selectedPurposeId,
      'jenis': purposeName,
      'product_id': _selectedProdukId,
      'source_id': _selectedSumberId,
      'scheduled_at': _selectedDateTime?.toIso8601String(),
      'jam': _tanggalController.text,
      'notes': _detailController.text.trim(),
      'foto_file': _pickedImageFile,
      'foto_bytes': _imageBytes,
    };

    Navigator.pop(context, resultData);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(20),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Dialog
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Buat Janji Tamu (${_currentStep + 1}/3)",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF172033),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const Divider(height: 16),

              // Render Halaman Berdasarkan Step
              if (_currentStep == 0) _buildStep1DataTamu(),
              if (_currentStep == 1) _buildStep2DetailKunjungan(),
              if (_currentStep == 2) _buildStep3Konfirmasi(),

              const SizedBox(height: 20),

              // Navigasi Tombol
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: corporateGreen),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => setState(() => _currentStep--),
                      child: Text(
                        "Kembali",
                        style: TextStyle(fontSize: 11, color: corporateGreen),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: corporateGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      if (_currentStep == 0) {
                        if (_namaController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Nama lengkap tamu wajib diisi!')),
                          );
                          return;
                        }
                        setState(() => _currentStep = 1);
                      } else if (_currentStep == 1) {
                        if (_selectedCabangId == null ||
                            _selectedStaffId == null ||
                            _selectedPurposeId == null ||
                            _tanggalController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Harap lengkapi kolom wajib (*)')),
                          );
                          return;
                        }
                        setState(() => _currentStep = 2);
                      } else {
                        _submitForm();
                      }
                    },
                    child: Text(
                      _currentStep == 2 ? "Simpan Janji" : "Lanjut",
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// =============== STEP 1: IDENTITAS TAMU & FOTO (OPSIONAL) ===============
  Widget _buildStep1DataTamu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Langkah 1: Identitas Tamu",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF006B3F),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _namaController,
          style: const TextStyle(fontSize: 12),
          decoration: const InputDecoration(
            labelText: "Nama Lengkap Tamu *",
            labelStyle: TextStyle(fontSize: 11),
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _instansiController,
          style: const TextStyle(fontSize: 12),
          decoration: const InputDecoration(
            labelText: "Asal Instansi / Perusahaan",
            labelStyle: TextStyle(fontSize: 11),
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _alamatController,
          style: const TextStyle(fontSize: 12),
          decoration: const InputDecoration(
            labelText: "Alamat",
            labelStyle: TextStyle(fontSize: 11),
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _jabatanController,
          style: const TextStyle(fontSize: 12),
          decoration: const InputDecoration(
            labelText: "Jabatan",
            labelStyle: TextStyle(fontSize: 11),
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: const TextStyle(fontSize: 12),
          decoration: const InputDecoration(
            labelText: "No. WhatsApp / Telepon",
            labelStyle: TextStyle(fontSize: 11),
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontSize: 12),
          decoration: const InputDecoration(
            labelText: "Email",
            labelStyle: TextStyle(fontSize: 11),
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        const SizedBox(height: 14),

        // Section Foto Tamu (Opsional)
        const Text(
          "Foto Tamu (Opsional)",
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
        ),
        const SizedBox(height: 8),

        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: _imageBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined, size: 30, color: Colors.grey),
                      SizedBox(height: 4),
                      Text("Foto Opsional", style: TextStyle(fontSize: 9, color: Colors.grey)),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt, size: 14),
                label: const Text("Kamera", style: TextStyle(fontSize: 10)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: corporateGreen),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library, size: 14),
                label: const Text("Galeri", style: TextStyle(fontSize: 10)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: corporateGreen),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// =============== STEP 2: DETAIL KUNJUNGAN ===============
  Widget _buildStep2DetailKunjungan() {
    if (_isLoadingMasterData) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(child: CircularProgressIndicator(color: Color(0xFF006B3F))),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Langkah 2: Detail Kunjungan Tamu",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF006B3F),
          ),
        ),
        const SizedBox(height: 12),

        // Cabang
        DropdownButtonFormField<int>(
          value: _selectedCabangId,
          isExpanded: true,
          style: const TextStyle(fontSize: 12, color: Color(0xFF172033)),
          decoration: const InputDecoration(
            labelText: "Cabang Kantor *",
            labelStyle: TextStyle(fontSize: 11),
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: _listCabang.map((OptionItem item) {
            return DropdownMenuItem<int>(
              value: item.id,
              child: Text(item.name, style: const TextStyle(fontSize: 12)),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              _selectedCabangId = val;
              _selectedStaffId = null;
            });
          },
        ),
        const SizedBox(height: 10),

        // Staff/PIC
        DropdownButtonFormField<int>(
          key: ValueKey(_selectedCabangId),
          value: _selectedStaffId,
          isExpanded: true,
          style: const TextStyle(fontSize: 12, color: Color(0xFF172033)),
          decoration: InputDecoration(
            labelText: "Tujuan Bertemu (Staff / PIC) *",
            labelStyle: const TextStyle(fontSize: 11),
            hintText: _selectedCabangId == null
                ? "Pilih cabang terlebih dahulu"
                : (_filteredStaff.isEmpty ? "Tidak ada PIC di cabang ini" : "Pilih Staff / PIC"),
            hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          items: _filteredStaff.map((OptionItem item) {
            return DropdownMenuItem<int>(
              value: item.id,
              child: Text(item.name, style: const TextStyle(fontSize: 12)),
            );
          }).toList(),
          onChanged: (_selectedCabangId == null || _filteredStaff.isEmpty)
              ? null
              : (val) => setState(() => _selectedStaffId = val),
        ),
        const SizedBox(height: 10),

        // Jenis Kunjungan
        DropdownButtonFormField<int>(
          value: _selectedPurposeId,
          isExpanded: true,
          style: const TextStyle(fontSize: 12, color: Color(0xFF172033)),
          decoration: const InputDecoration(
            labelText: "Jenis Kunjungan *",
            labelStyle: TextStyle(fontSize: 11),
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: _listPurposes.map((OptionItem item) {
            return DropdownMenuItem<int>(
              value: item.id,
              child: Text(item.name, style: const TextStyle(fontSize: 12)),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedPurposeId = val),
        ),
        const SizedBox(height: 10),

        // Produk
        DropdownButtonFormField<int>(
          value: _selectedProdukId,
          isExpanded: true,
          style: const TextStyle(fontSize: 12, color: Color(0xFF172033)),
          decoration: const InputDecoration(
            labelText: "Produk / Layanan yang Diminati",
            labelStyle: TextStyle(fontSize: 11),
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: _listProduk.map((OptionItem item) {
            return DropdownMenuItem<int>(
              value: item.id,
              child: Text(item.name, style: const TextStyle(fontSize: 12)),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedProdukId = val),
        ),
        const SizedBox(height: 10),

        // Tanggal & Jam Picker
        TextField(
          controller: _tanggalController,
          readOnly: true,
          style: const TextStyle(fontSize: 12),
          decoration: const InputDecoration(
            labelText: "Tanggal & Jam Kunjungan *",
            labelStyle: TextStyle(fontSize: 11),
            hintText: "Pilih tanggal & jam",
            hintStyle: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
            border: OutlineInputBorder(),
            isDense: true,
            suffixIcon: Icon(Icons.access_time_rounded, size: 18),
          ),
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 1)),
              lastDate: DateTime(2030),
            );

            if (pickedDate == null || !mounted) return;

            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );

            if (pickedTime != null && mounted) {
              setState(() {
                _selectedDateTime = DateTime(
                  pickedDate.year,
                  pickedDate.month,
                  pickedDate.day,
                  pickedTime.hour,
                  pickedTime.minute,
                );

                final String formattedDate =
                    "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
                final String formattedTime =
                    "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";

                _tanggalController.text = "$formattedDate $formattedTime";
              });
            }
          },
        ),
        const SizedBox(height: 10),

        // Sumber
        DropdownButtonFormField<int>(
          value: _selectedSumberId,
          isExpanded: true,
          style: const TextStyle(fontSize: 12, color: Color(0xFF172033)),
          decoration: const InputDecoration(
            labelText: "Sumber Mengetahui IT Solution",
            labelStyle: TextStyle(fontSize: 11),
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: _listSumber.map((OptionItem item) {
            return DropdownMenuItem<int>(
              value: item.id,
              child: Text(item.name, style: const TextStyle(fontSize: 12)),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedSumberId = val),
        ),
        const SizedBox(height: 10),

        // Detail Kunjungan Notes
        TextField(
          controller: _detailController,
          maxLines: 2,
          style: const TextStyle(fontSize: 12),
          decoration: const InputDecoration(
            labelText: "Detail Kunjungan",
            labelStyle: TextStyle(fontSize: 11),
            hintText: "Tuliskan keterangan detail keperluan Anda...",
            hintStyle: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
      ],
    );
  }

  /// =============== STEP 3: KONFIRMASI CHECK-IN ===============
  Widget _buildStep3Konfirmasi() {
    String staffName = _listStaff
        .firstWhere(
          (e) => e.id == _selectedStaffId,
          orElse: () => OptionItem(id: 0, name: '-'),
        )
        .name;

    String branchName = _listCabang
        .firstWhere(
          (e) => e.id == _selectedCabangId,
          orElse: () => OptionItem(id: 0, name: '-'),
        )
        .name;

    String purposeName = _listPurposes
        .firstWhere(
          (e) => e.id == _selectedPurposeId,
          orElse: () => OptionItem(id: 0, name: '-'),
        )
        .name;

    String productName = _selectedProdukId != null
        ? _listProduk
            .firstWhere(
              (e) => e.id == _selectedProdukId,
              orElse: () => OptionItem(id: 0, name: '-'),
            )
            .name
        : '-';

    String sourceName = _selectedSumberId != null
        ? _listSumber
            .firstWhere(
              (e) => e.id == _selectedSumberId,
              orElse: () => OptionItem(id: 0, name: '-'),
            )
            .name
        : '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Langkah 3: Konfirmasi Janji Tamu",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF006B3F),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Mohon periksa kembali seluruh data sebelum menyimpan.",
          style: TextStyle(fontSize: 11, color: Color(0xFF778195)),
        ),
        const SizedBox(height: 12),

        // Box Preview Ringkasan Data
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_imageBytes != null)
                Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: corporateGreen, width: 1.5),
                      image: DecorationImage(
                        image: MemoryImage(_imageBytes!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

              _buildSectionHeader("Identitas Tamu"),
              _buildInfoRow("Nama Lengkap", _namaController.text),
              _buildInfoRow("Instansi", _instansiController.text),
              _buildInfoRow("Jabatan", _jabatanController.text),
              _buildInfoRow("No. WhatsApp", _phoneController.text),
              _buildInfoRow("Email", _emailController.text),
              _buildInfoRow("Alamat", _alamatController.text),

              const Divider(height: 16),

              _buildSectionHeader("Detail Kunjungan"),
              _buildInfoRow("Tujuan PIC", staffName),
              _buildInfoRow("Cabang", branchName),
              _buildInfoRow("Jenis", purposeName),
              _buildInfoRow("Waktu Kunjungan", _tanggalController.text),
              _buildInfoRow("Produk Diminati", productName),
              _buildInfoRow("Sumber Info", sourceName),
              _buildInfoRow("Catatan", _detailController.text),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Checkbox Persetujuan
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: Checkbox(
                value: _isChecked,
                activeColor: corporateGreen,
                onChanged: (bool? value) {
                  setState(() {
                    _isChecked = value ?? false;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                "Saya menyatakan bahwa data janji tamu yang diisi di atas adalah benar.",
                style: TextStyle(fontSize: 10, color: Color(0xFF475569), height: 1.3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: corporateGreen,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
            ),
          ),
          const Text(": ", style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
          Expanded(
            child: Text(
              (value == null || value.trim().isEmpty) ? '-' : value,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}