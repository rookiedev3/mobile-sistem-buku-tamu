import 'package:flutter/material.dart';
import 'dart:math' as math;
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

  // Controller untuk Detail & Tanggal/Waktu Kunjungan
  final _detailController = TextEditingController();
  final _tanggalController = TextEditingController();
  DateTime? _selectedDateTime;

  // Selected Values (ID)
  int? _selectedCabangId;
  int? _selectedStaffId;
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

  /// Getter penyaringan daftar Staff/PIC berdasarkan cabang yang dipilih
  List<OptionItem> get _filteredStaff {
    if (_selectedCabangId == null) return [];
    return _listStaff.where((item) => item.branchId == _selectedCabangId).toList();
  }

  /// Validasi & Pindah ke Step 3 (Konfirmasi)
  void _processNextStep() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCabangId == null ||
        _selectedStaffId == null ||
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
          content: Text('Silakan pilih tanggal dan jam kunjungan!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Ambil nama terisolasi untuk ditampilkan di Step 3
    String branchName = _listCabang
        .firstWhere(
          (e) => e.id == _selectedCabangId,
          orElse: () => OptionItem(id: 0, name: '-'),
        )
        .name;

    String staffName = _listStaff
        .firstWhere(
          (e) => e.id == _selectedStaffId,
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
      'staff_name': staffName,
      'branch_name': branchName,
      'purpose_name': purposeName,
      'product_name': productName,
      'source_name': sourceName,
      'formatted_date': _tanggalController.text,
    };

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
      body: Stack(
        children: [
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
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundArcsPainter(),
            ),
          ),
          _isLoadingData
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 450),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                    child: Text(
                                      "Detail Kunjungan Tamu",
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
                                      "Tahap 2 / 4",
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
                                "Silakan lengkapi informasi tujuan dan keperluan kunjungan Anda.",
                                style: TextStyle(fontSize: 12, color: Colors.white70),
                              ),

                              const SizedBox(height: 16),

                              // 1. Dropdown Cabang Kantor
                              const Text("Cabang Kantor *", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<int>(
                                value: _selectedCabangId,
                                dropdownColor: Colors.white,
                                style: const TextStyle(color: Color(0xFF172033), fontSize: 13),
                                hint: const Text("Pilih cabang kantor", style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
                                decoration: _inputDecoration(),
                                items: _listCabang.map((OptionItem item) {
                                  return DropdownMenuItem<int>(
                                    value: item.id,
                                    child: Text(item.name, style: const TextStyle(fontSize: 13)),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedCabangId = val;
                                    _selectedStaffId = null;
                                  });
                                },
                                validator: (val) => val == null ? "Cabang kantor wajib dipilih" : null,
                              ),

                              const SizedBox(height: 10),

                              // 2. Dropdown Staff / PIC
                              const Text("Tujuan Bertemu (Staff / PIC) *", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<int>(
                                key: ValueKey(_selectedCabangId),
                                value: _selectedStaffId,
                                dropdownColor: Colors.white,
                                style: const TextStyle(color: Color(0xFF172033), fontSize: 13),
                                hint: Text(
                                  _selectedCabangId == null
                                      ? "Pilih cabang kantor terlebih dahulu"
                                      : (_filteredStaff.isEmpty ? "Tidak ada PIC di cabang ini" : "Pilih Staff / PIC yang dituju"),
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                                ),
                                decoration: _inputDecoration(),
                                items: _filteredStaff.map((OptionItem item) {
                                  return DropdownMenuItem<int>(
                                    value: item.id,
                                    child: Text(item.name, style: const TextStyle(fontSize: 13)),
                                  );
                                }).toList(),
                                onChanged: (_selectedCabangId == null || _filteredStaff.isEmpty)
                                    ? null
                                    : (val) => setState(() => _selectedStaffId = val),
                                validator: (val) => val == null ? "Staff/PIC wajib dipilih" : null,
                              ),

                              const SizedBox(height: 10),

                              // 3. Jenis Kunjungan
                              const Text("Jenis Kunjungan *", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<int>(
                                value: _selectedPurposeId,
                                dropdownColor: Colors.white,
                                style: const TextStyle(color: Color(0xFF172033), fontSize: 13),
                                hint: const Text("Pilih jenis kunjungan", style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
                                decoration: _inputDecoration(),
                                items: _listPurposes.map((OptionItem item) {
                                  return DropdownMenuItem<int>(
                                    value: item.id,
                                    child: Text(item.name, style: const TextStyle(fontSize: 13)),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() => _selectedPurposeId = val),
                                validator: (val) => val == null ? "Jenis kunjungan wajib dipilih" : null,
                              ),

                              const SizedBox(height: 10),

                              // 4. Produk / Layanan yang Diminati
                              const Text("Produk / Layanan yang Diminati", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<int>(
                                value: _selectedProdukId,
                                dropdownColor: Colors.white,
                                style: const TextStyle(color: Color(0xFF172033), fontSize: 13),
                                hint: const Text("Pilih produk atau layanan", style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
                                decoration: _inputDecoration(),
                                items: _listProduk.map((OptionItem item) {
                                  return DropdownMenuItem<int>(
                                    value: item.id,
                                    child: Text(item.name, style: const TextStyle(fontSize: 13)),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() => _selectedProdukId = val),
                              ),

                              const SizedBox(height: 10),

                             // 5. Tanggal & Jam Kunjungan (Pilih Tanggal + Pilih Jam)
const Text("Tanggal & Jam Kunjungan *", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
const SizedBox(height: 4),
TextFormField(
  controller: _tanggalController,
  readOnly: true,
  style: const TextStyle(color: Color(0xFF172033), fontSize: 12),
  decoration: _inputDecoration().copyWith(
    hintText: "Pilih tanggal & jam",
    hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    suffixIcon: const Icon(
      Icons.access_time_rounded,
      size: 16,
      color: Color(0xFF778195),
    ),
  ),
  validator: (val) => val == null || val.isEmpty ? "Tanggal & jam kunjungan wajib diisi" : null,
  onTap: () async {
    // 1. Pilih Tanggal dengan pembatas ukuran agar tidak overflow di HP kecil
  DateTime? pickedDate = await showDatePicker(
  context: context,
  initialDate: DateTime.now(),
  firstDate: DateTime.now().subtract(const Duration(days: 1)),
  lastDate: DateTime(2030),
  builder: (context, child) {
    return Theme(
      data: Theme.of(context).copyWith(
        datePickerTheme: DatePickerThemeData(
          // Menghilangkan border pada hari ini dengan membuat warnanya transparan
          todayBorder: BorderSide.none,
        ),
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 360,
            maxHeight: 520,
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(0.85),
            ),
            child: child!,
          ),
        ),
      ),
    );
  },
);

    if (pickedDate == null || !mounted) return;

    // 2. Pilih Jam setelah tanggal dipilih
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(0.9)),
          child: child!,
        );
      },
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

                              // 6. Sumber Mengetahui
                              const Text("Sumber Mengetahui IT Solution", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<int>(
                                value: _selectedSumberId,
                                dropdownColor: Colors.white,
                                style: const TextStyle(color: Color(0xFF172033), fontSize: 13),
                                hint: const Text("Pilih sumber informasi", style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
                                decoration: _inputDecoration(),
                                items: _listSumber.map((OptionItem item) {
                                  return DropdownMenuItem<int>(
                                    value: item.id,
                                    child: Text(item.name, style: const TextStyle(fontSize: 13)),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() => _selectedSumberId = val),
                              ),

                              const SizedBox(height: 10),

                              // 7. Detail Kunjungan (Notes)
                              const Text("Detail Kunjungan *", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _detailController,
                                maxLines: 3,
                                style: const TextStyle(color: Color(0xFF172033), fontSize: 13),
                                decoration: _inputDecoration().copyWith(
                                  hintText: "Tuliskan keterangan detail keperluan Anda...",
                                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
                                ),
                                validator: (val) => val == null || val.isEmpty ? "Detail kunjungan wajib diisi" : null,
                              ),

                              const SizedBox(height: 20),

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

                              const SizedBox(height: 16),

                              Center(
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.arrow_back_ios, size: 12, color: Colors.white60),
                                      SizedBox(width: 4),
                                      Text(
                                        "Kembali ke Tahap 1",
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
                ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      // Mengubah padding horizontal agar lebih leluasa di layar HP kecil
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      errorStyle: const TextStyle(
        color: Colors.redAccent,
        fontWeight: FontWeight.bold,
        fontSize: 11,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }
}

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