import 'dart:typed_data';
import 'package:flutter/material.dart';
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
  XFile? _photoFile; // 🟢 UBAH: Menggunakan XFile? agar aman untuk Web & Mobile

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
          _photoFile = pickedFile; // 🟢 UBAH: Simpan langsung sebagai XFile
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengambil gambar: $e')));
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
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF006B3F),
                ),
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
        'photo_file': _photoFile, // 🟢 Meneruskan XFile? ke Step 2 & 3
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
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
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
                                "Kembali ke Beranda",
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

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Expanded(
                              child: Text(
                                "Check-in Tamu Mandiri",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF172033),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Tahap 1 dari 4",
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
                          "Silakan isi data diri dan unggah foto Anda terlebih dahulu.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF778195),
                          ),
                        ),
                        const SizedBox(height: 24),

                        Center(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: _showImagePickerModal,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF4F7FC),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(
                                        0xFF006B3F,
                                      ).withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  // 🟢 UBAH: Menampilkan preview gambar XFile dengan FutureBuilder & MemoryImage
                                  child: ClipOAuth(photoFile: _photoFile),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: _showImagePickerModal,
                                icon: const Icon(
                                  Icons.upload,
                                  size: 16,
                                  color: Color(0xFF006B3F),
                                ),
                                label: Text(
                                  _photoFile == null
                                      ? "Unggah Foto Tamu"
                                      : "Ubah Foto Tamu",
                                  style: const TextStyle(
                                    color: Color(0xFF006B3F),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          "Nama Lengkap *",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _namaController,
                          decoration: _inputDecoration(
                            "Masukkan nama lengkap Anda",
                          ),
                          validator: (val) => val == null || val.isEmpty
                              ? "Nama wajib diisi"
                              : null,
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          "Asal Instansi / Perusahaan *",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _instansiController,
                          decoration: _inputDecoration("Contoh: PT Maju Jaya"),
                          validator: (val) => val == null || val.isEmpty
                              ? "Instansi wajib diisi"
                              : null,
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          "Alamat",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _alamatController,
                          decoration: _inputDecoration(
                            "Alamat instansi atau domisili",
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          "Jabatan *",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _jabatanController,
                          decoration: _inputDecoration(
                            "Contoh: Manager / Staff / Tamu",
                          ),
                          validator: (val) => val == null || val.isEmpty
                              ? "Jabatan wajib diisi"
                              : null,
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          "Nomor WhatsApp *",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _whatsappController,
                          keyboardType: TextInputType.phone,
                          decoration: _inputDecoration("081234567890"),
                          validator: (val) => val == null || val.isEmpty
                              ? "No WhatsApp wajib diisi"
                              : null,
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          "Email *",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration("email@domain.com"),
                          validator: (val) {
                            if (val == null || val.isEmpty)
                              return "Email wajib diisi";
                            if (!val.contains('@'))
                              return "Format email tidak valid";
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          "Kategori Pengunjung *",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedKategoriId,
                          hint: const Text(
                            "Pilih kategori pengunjung",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF778195),
                            ),
                          ),
                          decoration: _inputDecoration(""),
                          items: _listKategori.map((OptionItem item) {
                            return DropdownMenuItem<String>(
                              value: item.id.toString(),
                              child: Text(
                                item.name,
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? val) {
                            setState(() {
                              _selectedKategoriId = val;
                            });
                          },
                        ),
                        const SizedBox(height: 28),

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
                            onPressed: _isSubmitting ? null : _processNextStep,
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
                                    "Lanjut ke Tahap 2",
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

/// 🟢 Widget Helper untuk Preview Foto XFile
class ClipOAuth extends StatelessWidget {
  final XFile? photoFile;

  const ClipOAuth({super.key, this.photoFile});

  @override
  Widget build(BuildContext context) {
    if (photoFile == null) {
      return const Icon(
        Icons.camera_alt_outlined,
        size: 36,
        color: Color(0xFF006B3F),
      );
    }

    return FutureBuilder<Uint8List>(
      future: photoFile!.readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ClipOval(
            child: Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
              width: 100,
              height: 100,
            ),
          );
        }
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF006B3F)),
        );
      },
    );
  }
}