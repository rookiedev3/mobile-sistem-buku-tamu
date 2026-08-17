import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:image_picker/image_picker.dart';
import 'package:mobile_flutter/bloc/check_in_bloc.dart';
import 'package:mobile_flutter/model/check_in.dart';
import 'tamu_form_step2.dart';

class TamuFormStep1 extends StatefulWidget {
  const TamuFormStep1({super.key});

  @override
  State<TamuFormStep1> createState() => _TamuFormStep1State();
}

class _TamuFormStep1State extends State<TamuFormStep1> {
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _instansiController = TextEditingController();
  final _alamatController = TextEditingController();
  final _jabatanController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _emailController = TextEditingController();

  String? _selectedKategoriId;
  List<OptionItem> _listKategori = [];
  
  // Menggunakan XFile? menggantikan File? (kompatibel Web & Mobile)
  XFile? _photoFile;

  bool _isLoadingData = true;
  bool _isSubmitting = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchMasterData();
  }

  Future<void> _fetchMasterData() async {
    try {
      CheckInMasterData masterData = await CheckInBloc.getFormData();
      if (!mounted) return;
      setState(() {
        _listKategori = masterData.guestCategories;
        _isLoadingData = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingData = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal memuat kategori: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          // Menyimpan objek XFile secara langsung tanpa wrapper File()
          _photoFile = pickedFile;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil gambar: $e')),
      );
    }
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF006B3F)),
                title: const Text('Ambil dari Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF006B3F)),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _processNextStep() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedKategoriId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih kategori pengunjung!')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await CheckInBloc.validateStep1(
        name: _namaController.text,
        companyName: _instansiController.text,
        address: _alamatController.text,
        email: _emailController.text,
        guestCategoryId: _selectedKategoriId!,
        position: _jabatanController.text,
        phone: _whatsappController.text,
      );

      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });

      Map<String, dynamic> step1Data = {
        'name': _namaController.text,
        'company_name': _instansiController.text,
        'address': _alamatController.text,
        'email': _emailController.text,
        'guest_category_id': _selectedKategoriId,
        'position': _jabatanController.text,
        'phone': _whatsappController.text,
        'photo_file': _photoFile, // XFile dikirim ke step 2
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TamuFormStep2(step1Data: step1Data),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
                              // Header Judul & Tahap
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                    child: Text(
                                      "Check-in Tamu",
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
                                      "Tahap 1 / 4",
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
                                "Silakan isi data diri Anda di bawah ini.",
                                style: TextStyle(fontSize: 12, color: Colors.white70),
                              ),

                              const SizedBox(height: 16),

                              // Nama Lengkap
                              const Text("Nama Lengkap *", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _namaController,
                                style: const TextStyle(color: Color(0xFF172033), fontSize: 13),
                                decoration: _inputDecoration("Masukkan nama lengkap Anda"),
                                validator: (val) => val == null || val.isEmpty ? "Nama wajib diisi" : null,
                              ),

                              const SizedBox(height: 10),

                              // Asal Instansi
                              const Text("Asal Instansi / Perusahaan *", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _instansiController,
                                style: const TextStyle(color: Color(0xFF172033), fontSize: 13),
                                decoration: _inputDecoration("Contoh: PT Maju Jaya"),
                                validator: (val) => val == null || val.isEmpty ? "Instansi wajib diisi" : null,
                              ),

                              const SizedBox(height: 10),

                              // Alamat
                              const Text("Alamat", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _alamatController,
                                style: const TextStyle(color: Color(0xFF172033), fontSize: 13),
                                decoration: _inputDecoration("Alamat instansi atau domisili"),
                              ),

                              const SizedBox(height: 10),

                              // Jabatan
                              const Text("Jabatan *", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _jabatanController,
                                style: const TextStyle(color: Color(0xFF172033), fontSize: 13),
                                decoration: _inputDecoration("Contoh: Manager / Staff / Tamu"),
                                validator: (val) => val == null || val.isEmpty ? "Jabatan wajib diisi" : null,
                              ),

                              const SizedBox(height: 10),

                              // WhatsApp
                              const Text("Nomor WhatsApp *", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _whatsappController,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(color: Color(0xFF172033), fontSize: 13),
                                decoration: _inputDecoration("081234567890"),
                                validator: (val) => val == null || val.isEmpty ? "No WhatsApp wajib diisi" : null,
                              ),

                              const SizedBox(height: 10),

                              // Email
                              const Text("Email *", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(color: Color(0xFF172033), fontSize: 13),
                                decoration: _inputDecoration("email@domain.com").copyWith(
                                  errorStyle: const TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) return "Email wajib diisi";
                                  if (!val.contains('@')) return "Format email tidak valid";
                                  return null;
                                },
                              ),

                              const SizedBox(height: 10),

                              // Kategori Pengunjung
                              const Text("Kategori Pengunjung *", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                value: _selectedKategoriId,
                                dropdownColor: Colors.white,
                                style: const TextStyle(color: Color(0xFF172033), fontSize: 13),
                                hint: const Text("Pilih kategori pengunjung", style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
                                decoration: _inputDecoration(""),
                                items: _listKategori.map((OptionItem item) {
                                  return DropdownMenuItem<String>(
                                    value: item.id.toString(),
                                    child: Text(item.name, style: const TextStyle(fontSize: 13)),
                                  );
                                }).toList(),
                                onChanged: (String? val) {
                                  setState(() {
                                    _selectedKategoriId = val;
                                  });
                                },
                              ),

                              const SizedBox(height: 10),

                              // Foto Tamu
                              const Text("Foto Tamu", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap: _showImagePickerModal,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _photoFile != null ? Icons.check_circle : Icons.camera_alt_outlined,
                                        color: _photoFile != null ? const Color(0xFF006B3F) : const Color(0xFF9CA3AF),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _photoFile != null
                                              ? "Foto berhasil dipilih (Ketuk untuk ganti)"
                                              : "Ketuk untuk mengambil atau memilih foto",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: _photoFile != null ? const Color(0xFF172033) : const Color(0xFF9CA3AF),
                                            fontWeight: _photoFile != null ? FontWeight.w500 : FontWeight.normal,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Tombol Lanjut ke Tahap 2
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
                                  onPressed: _isSubmitting ? null : _processNextStep,
                                  child: _isSubmitting
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          "Lanjut ke Tahap 2",
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Tombol Kembali ke Beranda
                              Center(
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.arrow_back_ios, size: 12, color: Colors.white60),
                                      SizedBox(width: 4),
                                      Text(
                                        "Kembali ke Beranda",
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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