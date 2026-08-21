// lib/ui/admin/manajemen_pengguna_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dashboard_admin_screen.dart';
import 'daftar_tamu_screen.dart';
import 'riwayat_screen.dart';
import 'janji_tamu_screen.dart';
import 'master_data/master_data_screen.dart';
import 'package:mobile_flutter/bloc/user_bloc.dart';
import 'package:mobile_flutter/bloc/branch_bloc.dart';
import 'package:mobile_flutter/model/user.dart';
import 'package:mobile_flutter/model/branch.dart';
import 'package:mobile_flutter/model/user_list_response.dart';

const List<String> _roleOptions = ['pic', 'manager', 'owner', 'admin', 'security', 'tamu'];

// ================= VALIDATION HELPERS =================
final RegExp _emailRegex = RegExp(r'^[\w\.\-\+]+@([\w\-]+\.)+[a-zA-Z]{2,}$');

String? _validateNama(String? val) {
  if (val == null || val.trim().isEmpty) return 'Nama wajib diisi';
  if (val.trim().length < 3) return 'Nama minimal 3 karakter';
  return null;
}

String? _validateEmail(String? val) {
  if (val == null || val.trim().isEmpty) return 'Email wajib diisi';
  if (!_emailRegex.hasMatch(val.trim())) return 'Format email tidak valid';
  return null;
}

// DIUBAH: sekarang nomor HP hanya boleh diawali "+62" atau "08", disamakan
// dengan validasi di UserApiController (regex:/^(\+62|08)[0-9]+$/).
// Sebelumnya hanya mengecek boleh diawali satu '+' bebas + digit, sekarang
// diperketat supaya format selalu konsisten dengan yang dinormalisasi
// backend lewat UserApiController::normalizePhone().
final RegExp _phoneRegex = RegExp(r'^(\+62|08)[0-9]+$');

String? _validatePhone(String? val) {
  if (val == null || val.trim().isEmpty) return 'No. WhatsApp/HP wajib diisi';
  final trimmed = val.trim();

  if (!_phoneRegex.hasMatch(trimmed)) {
    return 'No. HP harus diawali +62 atau 08';
  }

  final digitsAfterPrefix = trimmed.startsWith('+62')
      ? trimmed.substring(3)
      : trimmed.substring(2); // buang prefix "08"

  if (digitsAfterPrefix.length < 7 || digitsAfterPrefix.length > 13) {
    return 'No. HP tidak valid';
  }
  return null;
}

// Formatter khusus nomor HP — hanya izinkan digit dan SATU tanda '+' di
// posisi paling depan (kalau user coba ketik '+' di tengah, otomatis
// dibuang). Validasi ketat "harus +62 atau 08" tetap ditangani oleh
// _validatePhone di atas, bukan di sini, supaya user masih bisa mengetik
// bertahap (mis. baru mengetik "0" atau "+") tanpa terasa aneh.
class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text;
    final hasLeadingPlus = raw.startsWith('+');
    final digitsOnly = raw.replaceAll(RegExp(r'[^0-9]'), '');
    final filtered = hasLeadingPlus ? '+$digitsOnly' : digitsOnly;
    return TextEditingValue(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
    );
  }
}

String? _validatePasswordRequired(String? val) {
  if (val == null || val.isEmpty) return 'Password wajib diisi';
  if (val.length < 6) return 'Password minimal 6 karakter';
  return null;
}

String? _validatePasswordOptional(String? val) {
  if (val == null || val.isEmpty) return null; // opsional saat edit
  if (val.length < 6) return 'Password minimal 6 karakter';
  return null;
}

/// Mengambil pesan error yang enak dibaca, meski exception-nya berisi body JSON mentah
/// dengan prefix apa pun (mis. "Exception: ", "Invalid Input: ") dan detail validasi
/// yang bisa ada di key "errors" ATAU "data".
String _friendlyErrorMessage(Object e) {
  String raw = e.toString().replaceAll('Exception: ', '').trim();
  final jsonStart = raw.indexOf('{');
  if (jsonStart != -1) {
    final jsonPart = raw.substring(jsonStart);
    try {
      final decoded = jsonDecode(jsonPart);
      if (decoded is Map) {
        for (final key in ['errors', 'data']) {
          final detail = decoded[key];
          if (detail is Map && detail.isNotEmpty) {
            final firstVal = detail.values.first;
            if (firstVal is List && firstVal.isNotEmpty) return firstVal.first.toString();
            if (firstVal != null) return firstVal.toString();
          }
        }
        if (decoded['message'] != null) return decoded['message'].toString();
      }
    } catch (_) {
      // bukan JSON valid, biarkan fallback ke pesan generik di bawah
    }
    return 'Terjadi kesalahan, silakan coba lagi';
  }
  return raw.isEmpty ? 'Terjadi kesalahan, silakan coba lagi' : raw;
}

// TAMBAHAN: helper status akun, disamakan dengan logic di web
// (resources/views/.../index.blade.php):
//   is_null($u->role)      -> "Menunggu Persetujuan"
//   $u->is_active           -> "Aktif"
//   else                    -> "Nonaktif"
bool _isPendingApproval(UserModel u) {
  return u.role == null || u.role!.trim().isEmpty;
}

class ManajemenPenggunaScreen extends StatefulWidget {
  const ManajemenPenggunaScreen({Key? key}) : super(key: key);

  @override
  State<ManajemenPenggunaScreen> createState() => _ManajemenPenggunaScreenState();
}

class _ManajemenPenggunaScreenState extends State<ManajemenPenggunaScreen> {
  final Color corporateGreen = const Color(0xFF006B3F);
  int _currentIndex = 4;

  List<UserModel> _daftarPengguna = [];
  List<Branch> _daftarBranch = [];
  bool _isLoading = true;

  // Client-Side Search, Filter & Pagination
  final TextEditingController _searchController = TextEditingController();
  String _filterRole = 'Semua';
  String _filterStatus = 'Semua';
  int _currentPage = 1;
  final int _perPage = 10;

  // TAMBAHAN: opsi status kini punya 3 state, sama seperti web.
  static const List<String> _statusOptions = ['Semua', 'Menunggu Persetujuan', 'Aktif', 'Non-Aktif'];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        UserBloc.listUsers(),
        BranchBloc.daftarBranch(),
      ]);
      final userRes = results[0] as UserListResponse;
      final branchRes = results[1] as ApiResponse<List<Branch>>;
      setState(() {
        _daftarPengguna = userRes.data ?? [];
        _daftarBranch = branchRes.data ?? [];
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: ${_friendlyErrorMessage(e)}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _branchNameById(int? id) {
    if (id == null) return null;
    final found = _daftarBranch.where((b) => b.id == id);
    return found.isEmpty ? null : found.first.name;
  }

  void _showTambahPenggunaDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController();
    final emailController = TextEditingController();
    final waController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = _roleOptions.first;
    int? selectedBranchId = _daftarBranch.isNotEmpty ? _daftarBranch.first.id : null;
    bool userAktif = true;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(Icons.person_add_rounded, color: corporateGreen, size: 20),
                  const SizedBox(width: 8),
                  const Text("Tambah Pengguna Baru", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        "Nama Lengkap",
                        namaController,
                        validator: _validateNama,
                      ),
                      const SizedBox(height: 6),
                      _buildTextField(
                        "Email",
                        emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 6),
                      _buildTextField(
                        "No. WhatsApp / HP",
                        waController,
                        keyboardType: TextInputType.phone,
                        validator: _validatePhone,
                        inputFormatters: [_PhoneInputFormatter()],
                        hintText: "Contoh: 08123456789",
                      ),
                      const SizedBox(height: 6),
                      _buildTextField(
                        "Password",
                        passwordController,
                        obscureText: true,
                        validator: _validatePasswordRequired,
                      ),
                      const SizedBox(height: 6),
                      const Text("Role / Hak Akses", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF778195))),
                      const SizedBox(height: 3),
                      _dropdownBox<String>(
                        value: selectedRole,
                        items: _roleOptions,
                        labelBuilder: (r) => r[0].toUpperCase() + r.substring(1),
                        onChanged: (val) => setStateDialog(() => selectedRole = val!),
                      ),
                      const SizedBox(height: 6),
                      const Text("Cabang Branch", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF778195))),
                      const SizedBox(height: 3),
                      _daftarBranch.isEmpty
                          ? const Text("Belum ada data branch", style: TextStyle(fontSize: 11, color: Colors.red))
                          : _dropdownBox<int>(
                              value: selectedBranchId,
                              items: _daftarBranch.map((b) => b.id).toList(),
                              labelBuilder: (id) => _daftarBranch.firstWhere((b) => b.id == id).name,
                              onChanged: (val) => setStateDialog(() => selectedBranchId = val),
                            ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Checkbox(
                            value: userAktif,
                            activeColor: corporateGreen,
                            onChanged: (val) => setStateDialog(() => userAktif = val ?? true),
                          ),
                          const Text("User Aktif", style: TextStyle(fontSize: 10, color: Color(0xFF475569))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text("Batal", style: TextStyle(fontSize: 11, color: Color(0xFF778195))),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: corporateGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          if (_daftarBranch.isNotEmpty && selectedBranchId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Cabang wajib dipilih')),
                            );
                            return;
                          }
                          setStateDialog(() => isSaving = true);
                          try {
                            final res = await UserBloc.create(
                              name: namaController.text.trim(),
                              email: emailController.text.trim(),
                              phone: waController.text.trim(),
                              password: passwordController.text,
                              role: selectedRole,
                              branchId: selectedBranchId,
                              isActive: userAktif,
                            );
                            Navigator.pop(context);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(res.message ?? 'Pengguna baru berhasil ditambahkan!'),
                                backgroundColor: res.status == true ? corporateGreen : Colors.red,
                              ),
                            );
                            _fetchData();
                          } catch (e) {
                            setStateDialog(() => isSaving = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(_friendlyErrorMessage(e)), backgroundColor: Colors.red),
                            );
                          }
                        },
                  child: isSaving
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text("Simpan", style: TextStyle(fontSize: 11)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditPenggunaDialog(BuildContext context, UserModel user) {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final waController = TextEditingController(text: user.phone);
    final passwordBaruController = TextEditingController();
    // DIUBAH: kalau user belum punya role (menunggu persetujuan), dropdown
    // dibiarkan null (tampil hint "Pilih") daripada dipaksa ke role pertama,
    // supaya admin tidak tanpa sadar mengubah dari "Menunggu Persetujuan"
    // jadi role tertentu hanya karena membuka dialog edit.
    String? selectedRole = _roleOptions.contains(user.role) ? user.role : null;
    int? selectedBranchId = user.branchId;
    bool userAktif = user.isActive ?? true;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(Icons.edit_rounded, color: corporateGreen, size: 20),
                  const SizedBox(width: 8),
                  const Text("Edit Pengguna", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        "Nama Lengkap",
                        namaController,
                        validator: _validateNama,
                      ),
                      const SizedBox(height: 6),
                      _buildTextField(
                        "Email",
                        emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 6),
                      _buildTextField(
                        "No. WhatsApp / HP",
                        waController,
                        keyboardType: TextInputType.phone,
                        validator: _validatePhone,
                        inputFormatters: [_PhoneInputFormatter()],
                        hintText: "Contoh: 08123456789 atau +628123456789",
                      ),
                      const SizedBox(height: 6),
                      _buildTextField(
                        "Password Baru (Opsional)",
                        passwordBaruController,
                        obscureText: true,
                        validator: _validatePasswordOptional,
                      ),
                      const SizedBox(height: 6),
                      const Text("Role / Hak Akses", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF778195))),
                      const SizedBox(height: 3),
                      if (selectedRole == null)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 3),
                          child: Text(
                            "Pengguna ini belum memiliki role (Menunggu Persetujuan)",
                            style: TextStyle(fontSize: 9.5, color: Colors.orange),
                          ),
                        ),
                      _dropdownBox<String>(
                        value: selectedRole,
                        items: _roleOptions,
                        labelBuilder: (r) => r[0].toUpperCase() + r.substring(1),
                        onChanged: (val) => setStateDialog(() => selectedRole = val),
                      ),
                      const SizedBox(height: 6),
                      const Text("Cabang Branch", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF778195))),
                      const SizedBox(height: 3),
                      _daftarBranch.isEmpty
                          ? const Text("Belum ada data branch", style: TextStyle(fontSize: 11, color: Colors.red))
                          : _dropdownBox<int>(
                              value: _daftarBranch.any((b) => b.id == selectedBranchId) ? selectedBranchId : null,
                              items: _daftarBranch.map((b) => b.id).toList(),
                              labelBuilder: (id) => _daftarBranch.firstWhere((b) => b.id == id).name,
                              onChanged: (val) => setStateDialog(() => selectedBranchId = val),
                            ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Checkbox(
                            value: userAktif,
                            activeColor: corporateGreen,
                            onChanged: (val) => setStateDialog(() => userAktif = val ?? true),
                          ),
                          const Text("User Aktif", style: TextStyle(fontSize: 10, color: Color(0xFF475569))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text("Batal", style: TextStyle(fontSize: 11, color: Color(0xFF778195))),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: corporateGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          if (selectedRole == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Role wajib dipilih untuk menyetujui pengguna ini')),
                            );
                            return;
                          }
                          setStateDialog(() => isSaving = true);
                          try {
                            final res = await UserBloc.updateUser(
                              id: user.id!,
                              name: namaController.text.trim(),
                              email: emailController.text.trim(),
                              phone: waController.text.trim(),
                              password: passwordBaruController.text,
                              role: selectedRole!,
                              branchId: selectedBranchId,
                              isActive: userAktif,
                            );
                            Navigator.pop(context);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(res.message ?? 'Pengguna berhasil diperbarui!'),
                                backgroundColor: res.status == true ? corporateGreen : Colors.red,
                              ),
                            );
                            _fetchData();
                          } catch (e) {
                            setStateDialog(() => isSaving = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(_friendlyErrorMessage(e)), backgroundColor: Colors.red),
                            );
                          }
                        },
                  child: isSaving
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text("Perbarui", style: TextStyle(fontSize: 11)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _hapusPengguna(UserModel user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Pengguna?", style: TextStyle(fontSize: 14)),
        content: Text("Yakin ingin menghapus ${user.name}? Tindakan ini tidak dapat dibatalkan.", style: const TextStyle(fontSize: 12)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Batal")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final res = await UserBloc.destroy(id: user.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message ?? 'Pengguna berhasil dihapus!'), backgroundColor: res.status == true ? corporateGreen : Colors.red),
      );
      _fetchData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_friendlyErrorMessage(e)), backgroundColor: Colors.red),
      );
    }
  }

  Widget _dropdownBox<T>({
    required T? value,
    required List<T> items,
    required String Function(T) labelBuilder,
    required void Function(T?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: const Text("Pilih", style: TextStyle(fontSize: 11)),
          style: const TextStyle(fontSize: 11, color: Color(0xFF172033), fontWeight: FontWeight.w600),
          items: items.map((val) => DropdownMenuItem(value: val, child: Text(labelBuilder(val)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    String? hintText, // TAMBAHAN: placeholder contoh format, mis. untuk field No. HP
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF778195))),
        const SizedBox(height: 3),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          inputFormatters: inputFormatters,
          style: const TextStyle(fontSize: 11),
          decoration: InputDecoration(
            hintText: hintText, // TAMBAHAN
            hintStyle: const TextStyle(fontSize: 10.5, color: Color(0xFF9CA3AF)), // TAMBAHAN
            contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Colors.red)),
            errorStyle: const TextStyle(fontSize: 9.5),
            filled: true,
            fillColor: const Color(0xFFF4F7FC),
            isDense: true,
          ),
        ),
      ],
    );
  }

  List<UserModel> _getFilteredUsers() {
    return _daftarPengguna.where((u) {
      final keyword = _searchController.text.trim().toLowerCase();
      if (keyword.isNotEmpty) {
        final name = (u.name ?? '').toLowerCase();
        final email = (u.email ?? '').toLowerCase();
        final phone = (u.phone ?? '').toLowerCase();
        if (!name.contains(keyword) && !email.contains(keyword) && !phone.contains(keyword)) {
          return false;
        }
      }

      if (_filterRole != 'Semua') {
        if ((u.role ?? '').toLowerCase() != _filterRole.toLowerCase()) {
          return false;
        }
      }

      // DIUBAH: sekarang ada 3 state status, disamakan dengan web —
      // "Menunggu Persetujuan" (role belum di-set), "Aktif", "Non-Aktif".
      if (_filterStatus != 'Semua') {
        final isPending = _isPendingApproval(u);
        if (_filterStatus == 'Menunggu Persetujuan') {
          if (!isPending) return false;
        } else {
          if (isPending) return false; // user pending tidak masuk filter Aktif/Non-Aktif
          final isActive = u.isActive ?? false;
          if (_filterStatus == 'Aktif' && !isActive) return false;
          if (_filterStatus == 'Non-Aktif' && isActive) return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _getFilteredUsers();
    final totalData = filteredUsers.length;
    final lastPage = (totalData / _perPage).ceil() == 0 ? 1 : (totalData / _perPage).ceil();

    if (_currentPage > lastPage) {
      _currentPage = lastPage;
    } else if (_currentPage < 1) {
      _currentPage = 1;
    }

    final startIndex = (_currentPage - 1) * _perPage;
    final endIndex = startIndex + _perPage;
    final paginatedUsers = filteredUsers.sublist(
      startIndex,
      endIndex > totalData ? totalData : endIndex,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: corporateGreen,
        elevation: 0,
        title: const Text("Admin - Manajemen Pengguna", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _fetchData),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const BranchesScreen()));
                          },
                          icon: const Icon(Icons.settings_outlined, size: 14, color: Color(0xFF006B3F)),
                          label: const Text("Master Data", style: TextStyle(fontSize: 11, color: Color(0xFF006B3F), fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: corporateGreen),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: corporateGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _showTambahPenggunaDialog(context),
                          icon: const Icon(Icons.person_add_rounded, size: 14),
                          label: const Text("Tambah Pengguna", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text("Daftar Akun Pengguna", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
                    const SizedBox(height: 2),
                    const Text("Kelola hak akses dan status akun pengguna sistem", style: TextStyle(fontSize: 11, color: Color(0xFF778195))),
                    const SizedBox(height: 14),

                    // ================= FILTERS & SEARCH ROW =================
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _searchController,
                            onChanged: (val) {
                              setState(() {
                                _currentPage = 1;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: "Cari nama, email, atau no. WA...",
                              hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                              prefixIcon: const Icon(Icons.search, size: 16, color: Color(0xFF778195)),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 14),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _currentPage = 1;
                                        });
                                      },
                                    )
                                  : null,
                              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                              filled: true,
                              fillColor: const Color(0xFFF4F7FC),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF4F7FC),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _filterRole,
                                      isExpanded: true,
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF172033), fontWeight: FontWeight.bold),
                                      items: ['Semua', 'pic', 'manager', 'owner', 'admin', 'security', 'tamu'].map((val) {
                                        return DropdownMenuItem<String>(
                                          value: val,
                                          child: Text(val == 'Semua' ? 'Semua Role' : val[0].toUpperCase() + val.substring(1)),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() {
                                            _filterRole = val;
                                            _currentPage = 1;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF4F7FC),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _filterStatus,
                                      isExpanded: true,
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF172033), fontWeight: FontWeight.bold),
                                      // DIUBAH: tambah opsi "Menunggu Persetujuan"
                                      items: _statusOptions.map((val) {
                                        return DropdownMenuItem<String>(
                                          value: val,
                                          child: Text(
                                            val == 'Semua' ? 'Semua Status' : val,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() {
                                            _filterStatus = val;
                                            _currentPage = 1;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    if (paginatedUsers.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: Text('Belum ada data pengguna', style: TextStyle(color: Color(0xFF778195)))),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: paginatedUsers.length,
                        itemBuilder: (context, index) {
                          final user = paginatedUsers[index];

                          // DIUBAH: status badge sekarang 3 state, sama seperti web:
                          // role null -> Menunggu Persetujuan (kuning/oranye)
                          // is_active -> Aktif (hijau)
                          // else      -> Non-Aktif (merah)
                          final isPending = _isPendingApproval(user);
                          final bool isActive = user.isActive ?? false;

                          late final String statusLabel;
                          late final Color statusBg;
                          late final Color statusText;
                          if (isPending) {
                            statusLabel = "Menunggu Persetujuan";
                            statusBg = Colors.orange.withOpacity(0.1);
                            statusText = Colors.orange[800]!;
                          } else if (isActive) {
                            statusLabel = "Aktif";
                            statusBg = Colors.green.withOpacity(0.1);
                            statusText = Colors.green[700]!;
                          } else {
                            statusLabel = "Non-Aktif";
                            statusBg = Colors.red.withOpacity(0.1);
                            statusText = Colors.red[700]!;
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(4)),
                                      child: Text(
                                        // DIUBAH: kalau role belum ada, tampilkan "Belum ditentukan"
                                        // seperti di web, bukan "Role: -"
                                        isPending ? "Role: Belum ditentukan" : "Role: ${user.role}",
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF006B3F)),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: statusBg,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        statusLabel,
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusText),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(user.name ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF172033))),
                                const SizedBox(height: 4),
                                Text("Email: ${user.email ?? '-'}", style: const TextStyle(fontSize: 10, color: Color(0xFF778195))),
                                Text("No. WA: ${user.phone ?? '-'}", style: const TextStyle(fontSize: 10, color: Color(0xFF778195))),
                                Text("Cabang: ${user.branchName ?? _branchNameById(user.branchId) ?? '-'}", style: const TextStyle(fontSize: 10, color: Color(0xFF778195))),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 6.0),
                                  child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () => _showEditPenggunaDialog(context, user),
                                      icon: const Icon(Icons.edit_outlined, size: 12, color: Colors.blue),
                                      label: const Text("Edit", style: TextStyle(fontSize: 10, color: Colors.blue)),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        side: const BorderSide(color: Colors.blue),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                        minimumSize: const Size(40, 24),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    OutlinedButton.icon(
                                      onPressed: () => _hapusPengguna(user),
                                      icon: const Icon(Icons.delete_outline, size: 12, color: Colors.red),
                                      label: const Text("Hapus", style: TextStyle(fontSize: 10, color: Colors.red)),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        side: const BorderSide(color: Colors.red),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                        minimumSize: const Size(40, 24),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    if (!_isLoading && filteredUsers.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _buildPaginationControl(totalData, lastPage),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPaginationControl(int totalData, int lastPage) {
    int startItem = totalData == 0 ? 0 : ((_currentPage - 1) * _perPage) + 1;
    int endItem = (_currentPage * _perPage) > totalData
        ? totalData
        : (_currentPage * _perPage);

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Menampilkan $startItem-$endItem dari $totalData data",
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF778195),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "Hal $_currentPage dari $lastPage",
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF172033),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.first_page, size: 18),
                onPressed: _currentPage > 1 ? () => setState(() => _currentPage = 1) : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                color: corporateGreen,
                disabledColor: Colors.grey.shade300,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 18),
                onPressed: _currentPage > 1
                    ? () => setState(() => _currentPage = _currentPage - 1)
                    : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                color: corporateGreen,
                disabledColor: Colors.grey.shade300,
              ),
              const SizedBox(width: 6),
              ..._buildPageNumbers(lastPage),
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 18),
                onPressed: _currentPage < lastPage
                    ? () => setState(() => _currentPage = _currentPage + 1)
                    : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                color: corporateGreen,
                disabledColor: Colors.grey.shade300,
              ),
              IconButton(
                icon: const Icon(Icons.last_page, size: 18),
                onPressed: _currentPage < lastPage
                    ? () => setState(() => _currentPage = lastPage)
                    : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                color: corporateGreen,
                disabledColor: Colors.grey.shade300,
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers(int lastPage) {
    List<Widget> pageButtons = [];
    int start = _currentPage - 1;
    int end = _currentPage + 1;

    if (start < 1) {
      start = 1;
      end = start + 2;
    }
    if (end > lastPage) {
      end = lastPage;
      start = end - 2;
      if (start < 1) start = 1;
    }

    for (int i = start; i <= end; i++) {
      final bool isCurrent = (i == _currentPage);
      pageButtons.add(
        InkWell(
          onTap: isCurrent ? null : () => setState(() => _currentPage = i),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isCurrent ? corporateGreen : const Color(0xFFF4F7FC),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isCurrent ? corporateGreen : const Color(0xFFE2E8F0),
              ),
            ),
            child: Text(
              "$i",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isCurrent ? Colors.white : const Color(0xFF172033),
              ),
            ),
          ),
        ),
      );
    }
    return pageButtons;
  }
}