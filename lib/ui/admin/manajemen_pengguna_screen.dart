// lib/ui/admin/manajemen_pengguna_screen.dart
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchData();
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
        SnackBar(content: Text('Gagal memuat data: ${e.toString().replaceAll('Exception: ', '')}')),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField("Nama Lengkap", namaController),
                    const SizedBox(height: 6),
                    _buildTextField("Email", emailController, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 6),
                    _buildTextField("No. WhatsApp / HP", waController, keyboardType: TextInputType.phone),
                    const SizedBox(height: 6),
                    _buildTextField("Password", passwordController, obscureText: true),
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
                          if (namaController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Nama, email, dan password wajib diisi')),
                            );
                            return;
                          }
                          setStateDialog(() => isSaving = true);
                          try {
                            final res = await UserBloc.create(
                              name: namaController.text,
                              email: emailController.text,
                              phone: waController.text,
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
                              SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
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
    final namaController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final waController = TextEditingController(text: user.phone);
    final passwordBaruController = TextEditingController();
    String selectedRole = _roleOptions.contains(user.role) ? user.role! : _roleOptions.first;
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField("Nama Lengkap", namaController),
                    const SizedBox(height: 6),
                    _buildTextField("Email", emailController, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 6),
                    _buildTextField("No. WhatsApp / HP", waController, keyboardType: TextInputType.phone),
                    const SizedBox(height: 6),
                    _buildTextField("Password Baru (Opsional)", passwordBaruController, obscureText: true),
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
                          setStateDialog(() => isSaving = true);
                          try {
                            final res = await UserBloc.updateUser(
                              id: user.id!,
                              name: namaController.text,
                              email: emailController.text,
                              phone: waController.text,
                              password: passwordBaruController.text,
                              role: selectedRole,
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
                              SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
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
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
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

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text, bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF778195))),
        const SizedBox(height: 3),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: const TextStyle(fontSize: 11),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            filled: true,
            fillColor: const Color(0xFFF4F7FC),
            isDense: true,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    if (_daftarPengguna.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: Text('Belum ada data pengguna', style: TextStyle(color: Color(0xFF778195)))),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _daftarPengguna.length,
                        itemBuilder: (context, index) {
                          final user = _daftarPengguna[index];
                          bool isActive = user.isActive ?? false;

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
                                      child: Text("Role: ${user.role ?? '-'}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF006B3F))),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isActive ? "Aktif" : "Non-Aktif",
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isActive ? Colors.green[700] : Colors.red[700]),
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
                  ],
                ),
              ),
            ),
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: _currentIndex,
      //   selectedItemColor: const Color(0xFF006B3F),
      //   unselectedItemColor: const Color(0xFF778195),
      //   backgroundColor: Colors.white,
      //   type: BottomNavigationBarType.fixed,
      //   selectedFontSize: 10,
      //   unselectedFontSize: 10,
      //   onTap: (index) {
      //     setState(() => _currentIndex = index);
      //     if (index == 0) {
      //       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardAdminScreen()));
      //     } else if (index == 1) {
      //       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DaftarTamuScreen()));
      //     } else if (index == 2) {
      //       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RiwayatScreen()));
      //     } else if (index == 3) {
      //       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const JanjiTamuScreen()));
      //     }
      //   },
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.home_rounded, size: 20), label: 'Beranda'),
      //     BottomNavigationBarItem(icon: Icon(Icons.people_outline_rounded, size: 20), label: 'Daftar Tamu'),
      //     BottomNavigationBarItem(icon: Icon(Icons.history_rounded, size: 20), label: 'Riwayat'),
      //     BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined, size: 20), label: 'Janji Tamu'),
      //     BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings_outlined, size: 20), label: 'Pengguna'),
      //   ],
      // ),
    );
  }
}