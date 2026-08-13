import 'package:flutter/material.dart';
import 'package:mobile_flutter/bloc/check_in_bloc.dart';
import 'package:mobile_flutter/model/check_in.dart';
import 'tamu_form_step3.dart';

class TamuFormStep2 extends StatefulWidget {
  final Map<String, dynamic>? step1Data;

  const TamuFormStep2({super.key, this.step1Data});

  @override
  State<TamuFormStep2> createState() => _TamuFormStep2State();
}

class _TamuFormStep2State extends State<TamuFormStep2> {
  final _formKey = GlobalKey<FormState>();

  // Controller untuk Detail & Tanggal Kunjungan
  final _detailController = TextEditingController();
  final _tanggalController = TextEditingController();
  DateTime? _selectedDateTime;

  // Selected Values (ID)
  int? _selectedStaffId;
  int? _selectedCabangId;
  int? _selectedPurposeId;
  int? _selectedProdukId;
  int? _selectedSumberId;

  // List Data Master dari API
  List<OptionItem> _listStaff = [];
  List<OptionItem> _listCabang = [];
  List<OptionItem> _listPurposes = [];
  List<OptionItem> _listProduk = [];
  List<OptionItem> _listSumber = [];

  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _fetchMasterData();
  }

  /// Memuat Master Data Dropdown dari API Laravel via CheckInBloc
  Future<void> _fetchMasterData() async {
    try {
      CheckInMasterData masterData = await CheckInBloc.getFormData();
      if (!mounted) return;
      setState(() {
        _listStaff = masterData.pics;
        _listCabang = masterData.branches;
        _listPurposes = masterData.visitPurposes;
        _listProduk = masterData.products;
        _listSumber = masterData.leadSources;
        _isLoadingData = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingData = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal memuat data formulir: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Validasi & Pindah ke Step 3 (Konfirmasi)
  void _processNextStep() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedStaffId == null ||
        _selectedCabangId == null ||
        _selectedPurposeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi seluruh kolom wajib (*)'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih tanggal kunjungan!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Ambil nama terisolasi untuk ditampilkan di Step 3 (Review/Konfirmasi)
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

    // Gabungkan data Step 2
    Map<String, dynamic> step2Data = {
      'assigned_to': _selectedStaffId,
      'branch_id': _selectedCabangId,
      'purpose_id': _selectedPurposeId,
      'scheduled_at':
          _selectedDateTime!.toIso8601String().split('.').first.replaceAll('T', ' '),
      'notes': _detailController.text,
      'product_interest': _selectedProdukId != null ? [_selectedProdukId!] : <int>[],
      'source_id': _selectedSumberId,
      // Metadata nama untuk tampilan di Step 3
      'staff_name': staffName,
      'branch_name': branchName,
      'purpose_name': purposeName,
      'product_name': productName,
      'source_name': sourceName,
      'formatted_date': _tanggalController.text,
    };

    // Navigasi ke Step 3 (Konfirmasi & Final Submit)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TamuFormStep3(
          step1Data: widget.step1Data,
          step2Data: step2Data,
        ),
      ),
    );
  }

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
      body: _isLoadingData
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF006B3F)),
            )
          : Center(
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tombol Kembali ke Tahap 1
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.arrow_back_ios,
                                size: 14,
                                color: Color(0xFF006B3F),
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Kembali ke Tahap 1",
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

                        // Indikator Tahap (Step 2 dari 4)
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Detail Kunjungan Tamu",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF172033),
                              ),
                            ),
                            Text(
                              "Tahap 2 dari 4",
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
                          "Silakan lengkapi informasi tujuan dan keperluan kunjungan Anda.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF778195),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 1. Tujuan Bertemu (Staff / PIC)
                        const Text(
                          "Tujuan Bertemu (Staff / PIC) *",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<int>(
                          initialValue: _selectedStaffId,
                          hint: const Text(
                            "Pilih Staff / PIC yang dituju",
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF778195),
                            ),
                          ),
                          decoration: _inputDecoration(),
                          items: _listStaff.map((OptionItem item) {
                            return DropdownMenuItem<int>(
                              value: int.tryParse(item.id.toString()) ?? 0,
                              child: Text(
                                item.name,
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => _selectedStaffId = val),
                          validator: (val) =>
                              val == null ? "Staff/PIC wajib dipilih" : null,
                        ),
                        const SizedBox(height: 16),

                        // 2. Cabang Kantor
                        const Text(
                          "Cabang Kantor *",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<int>(
                          initialValue: _selectedCabangId,
                          hint: const Text(
                            "Pilih cabang kantor",
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF778195),
                            ),
                          ),
                          decoration: _inputDecoration(),
                          items: _listCabang.map((OptionItem item) {
                            return DropdownMenuItem<int>(
                              value: int.tryParse(item.id.toString()) ?? 0,
                              child: Text(
                                item.name,
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => _selectedCabangId = val),
                          validator: (val) =>
                              val == null ? "Cabang kantor wajib dipilih" : null,
                        ),
                        const SizedBox(height: 16),

                        // 3. Jenis Kunjungan (Visit Purpose)
                        const Text(
                          "Jenis Kunjungan *",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<int>(
                          initialValue: _selectedPurposeId,
                          hint: const Text(
                            "Pilih jenis kunjungan",
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF778195),
                            ),
                          ),
                          decoration: _inputDecoration(),
                          items: _listPurposes.map((OptionItem item) {
                            return DropdownMenuItem<int>(
                              value: int.tryParse(item.id.toString()) ?? 0,
                              child: Text(
                                item.name,
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => _selectedPurposeId = val),
                          validator: (val) =>
                              val == null ? "Jenis kunjungan wajib dipilih" : null,
                        ),
                        const SizedBox(height: 16),

                        // 4. Produk / Layanan yang Diminati
                        const Text(
                          "Produk / Layanan yang Diminati",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<int>(
                          initialValue: _selectedProdukId,
                          hint: const Text(
                            "Pilih produk atau layanan",
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF778195),
                            ),
                          ),
                          decoration: _inputDecoration(),
                          items: _listProduk.map((OptionItem item) {
                            return DropdownMenuItem<int>(
                              value: int.tryParse(item.id.toString()) ?? 0,
                              child: Text(
                                item.name,
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => _selectedProdukId = val),
                        ),
                        const SizedBox(height: 16),

                        // 5. Tanggal Kunjungan
                        const Text(
                          "Tanggal Kunjungan *",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _tanggalController,
                          readOnly: true,
                          decoration: _inputDecoration().copyWith(
                            hintText: "Pilih tanggal kunjungan",
                            hintStyle: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF778195),
                            ),
                            suffixIcon: const Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: Color(0xFF006B3F),
                            ),
                          ),
                          validator: (val) =>
                              val == null || val.isEmpty ? "Tanggal kunjungan wajib diisi" : null,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now().subtract(const Duration(days: 1)),
                              lastDate: DateTime(2030),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                _selectedDateTime = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  DateTime.now().hour,
                                  DateTime.now().minute,
                                );
                                _tanggalController.text =
                                    "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // 6. Sumber Mengetahui IT Solution
                        const Text(
                          "Sumber Mengetahui IT Solution",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<int>(
                          initialValue: _selectedSumberId,
                          hint: const Text(
                            "Pilih sumber informasi",
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF778195),
                            ),
                          ),
                          decoration: _inputDecoration(),
                          items: _listSumber.map((OptionItem item) {
                            return DropdownMenuItem<int>(
                              value: int.tryParse(item.id.toString()) ?? 0,
                              child: Text(
                                item.name,
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              setState(() => _selectedSumberId = val),
                        ),
                        const SizedBox(height: 16),

                        // 7. Detail Kunjungan (Notes)
                        const Text(
                          "Detail Kunjungan *",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _detailController,
                          maxLines: 3,
                          decoration: _inputDecoration().copyWith(
                            hintText:
                                "Tuliskan keterangan detail keperluan Anda...",
                            hintStyle: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF778195),
                            ),
                          ),
                          validator: (val) =>
                              val == null || val.isEmpty ? "Detail kunjungan wajib diisi" : null,
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _processNextStep,
                            child: const Text(
                              "Lanjut ke Tahap 3",
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
            ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF4F7FC),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }
}