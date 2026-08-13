import 'package:flutter/material.dart';
import 'package:mobile_flutter/bloc/user_bloc.dart';
import 'package:mobile_flutter/model/user.dart';
import 'package:mobile_flutter/helpers/title_case_formatter.dart'; // ← import baru


class ManajemenPenggunaScreen extends StatefulWidget {
  const ManajemenPenggunaScreen({Key? key}) : super(key: key);

  @override
  State<ManajemenPenggunaScreen> createState() => _ManajemenPenggunaScreenState();
}

class _ManajemenPenggunaScreenState extends State<ManajemenPenggunaScreen> {
  List<UserModel> _daftarPengguna = [];
  bool _isLoading = true;

  final Map<String, int> _cabangIdMap = {
  'Cabang Sleman': 1,
  'Cabang Magelang': 2,
  };

  // Pemetaan role backend (Inggris) <-> label yang ditampilkan di UI (Indonesia)
  static const Map<String, String> _roleToDisplay = {
    'owner': 'Owner',
    'manager': 'Manager',
    'pic': 'PIC / Sales',
    'security': 'Satpam',
    'admin': 'Admin',
    'tamu': 'Tamu',
  };

  final List<String> _roleOptions = ['Owner', 'Manager', 'PIC / Sales', 'Satpam', 'Admin'];
  final List<String> _cabangOptions = ['Cabang Sleman', 'Cabang Magelang'];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final result = await UserBloc.listUsers();
      setState(() => _daftarPengguna = result.data ?? []);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: ${e.toString().replaceAll('Exception: ', '')}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleNonaktifkan(UserModel user) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Nonaktifkan Pengguna'),
      content: Text('Yakin ingin menonaktifkan ${user.name}?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Nonaktifkan'),
        ),
      ],
    ),
  );

  if (confirm != true) return;

  try {
    await UserBloc.deactivate(id: user.id!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${user.name} berhasil dinonaktifkan')),
    );
    _fetchUsers();
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
    );
  }
}

  Future<void> _handleAktifkan(UserModel user) async {
  // Kalau role-nya udah pernah ada, aktifkan ulang pakai role yang sama.
  // Kalau baru daftar (role masih null), minta admin pilih dulu.
  String? roleToUse = user.role;

  if (roleToUse == null) {
    roleToUse = await showDialog<String>(
      context: context,
      builder: (ctx) {
        String tempRole = _roleOptions[0];
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Pilih Role'),
              content: DropdownButtonFormField<String>(
                value: tempRole,
                items: _roleOptions
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setStateDialog(() => tempRole = val);
                },
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                ElevatedButton(
                  onPressed: () {
                    final roleValue = _roleToDisplay.entries
                        .firstWhere((e) => e.value == tempRole)
                        .key;
                    Navigator.pop(ctx, roleValue);
                  },
                  child: const Text('Aktifkan'),
                ),
              ],
            );
          },
        );
      },
    );

    if (roleToUse == null) return; // admin batal pilih role
  }

  try {
    await UserBloc.approve(id: user.id!, role: roleToUse);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${user.name} berhasil diaktifkan')),
    );
    _fetchUsers();
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
    );
  }
}

  Future<void> _handleHapus(UserModel user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Pengguna'),
        content: Text('Yakin ingin menghapus ${user.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await UserBloc.destroy(id: user.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pengguna ${user.name} dihapus!')),
      );
      _fetchUsers(); // refresh list
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  // Dialog Tambah/Edit — MASIH SIMULASI, belum tersambung ke backend
  // (butuh endpoint baru khusus admin buat create/update user, dibahas terpisah)
  void _showFormPenggunaDialog(BuildContext context, {UserModel? userData}) {
    final bool isEdit = userData != null;

    final TextEditingController namaController = TextEditingController(text: isEdit ? userData.name : '');
    final TextEditingController emailController = TextEditingController(text: isEdit ? userData.email : '');
    final TextEditingController waController = TextEditingController(text: isEdit ? userData.phone : '');
    final TextEditingController passwordController = TextEditingController();

    String selectedRole = isEdit ? (_roleToDisplay[userData.role] ?? _roleOptions[0]) : _roleOptions[0];
    String selectedCabang = isEdit ? (userData.branchName ?? _cabangOptions[0]) : _cabangOptions[0];

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              title: Row(
                children: [
                  Icon(
                    isEdit ? Icons.edit_rounded : Icons.person_add_rounded,
                    color: const Color(0xFF006B3F),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEdit ? "Edit Pengguna" : "Tambah Pengguna Baru",
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Nama Lengkap", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF778195))),
                    const SizedBox(height: 4),
                    TextField(controller: namaController, 
                    inputFormatters: [TitleCaseTextFormatter()], // ← TAMBAHAN
                    decoration: _inputDecoration("Masukkan nama lengkap")),
                    const SizedBox(height: 10),
                    const Text("Email", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF778195))),
                    const SizedBox(height: 4),
                    TextField(controller: emailController, decoration: _inputDecoration("contoh@office.com")),
                    const SizedBox(height: 10),
                    const Text("No. WhatsApp", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF778195))),
                    const SizedBox(height: 4),
                    TextField(controller: waController, keyboardType: TextInputType.phone, decoration: _inputDecoration("08xxxxxxxxxx")),
                    const SizedBox(height: 10),
                    const Text("Password", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF778195))),
                    const SizedBox(height: 4),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: _inputDecoration(isEdit ? "Kosongkan jika tidak diubah" : "Masukkan password"),
                    ),
                    const SizedBox(height: 10),
                    const Text("Hak Akses (Role)", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF778195))),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F7FC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedRole,
                          isExpanded: true,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF172033), fontWeight: FontWeight.w600),
                          items: _roleOptions.map((String role) => DropdownMenuItem<String>(value: role, child: Text(role))).toList(),
                          onChanged: (String? val) {
                            if (val != null) setStateDialog(() => selectedRole = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text("Cabang Kantor", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF778195))),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F7FC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCabang,
                          isExpanded: true,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF172033), fontWeight: FontWeight.w600),
                          items: _cabangOptions.map((String cabang) => DropdownMenuItem<String>(value: cabang, child: Text(cabang))).toList(),
                          onChanged: (String? val) {
                            if (val != null) setStateDialog(() => selectedCabang = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text("Batal", style: TextStyle(color: Color(0xFF778195))),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006B3F),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
  // Petain balik label UI (Indonesia) -> value backend (Inggris)
  final roleValue = _roleToDisplay.entries
      .firstWhere((e) => e.value == selectedRole, orElse: () => const MapEntry('tamu', 'Tamu'))
      .key;
  final branchIdValue = _cabangIdMap[selectedCabang]; // map yang sama kayak di register_screen.dart

  if (!isEdit && passwordController.text.isEmpty) {
    ScaffoldMessenger.of(dialogContext).showSnackBar(
      const SnackBar(content: Text('Password wajib diisi untuk user baru')),
    );
    return;
  }

  try {
    if (isEdit) {
      await UserBloc.updateUser(
        id: userData.id!,
        name: namaController.text.trim(),
        email: emailController.text.trim(),
        phone: waController.text.trim(),
        password: passwordController.text.isNotEmpty ? passwordController.text : null,
        role: roleValue,
        branchId: branchIdValue,
        isActive: userData.isActive ?? true,
      );
    } else {
      await UserBloc.create(
        name: namaController.text.trim(),
        email: emailController.text.trim(),
        phone: waController.text.trim(),
        password: passwordController.text,
        role: roleValue,
        branchId: branchIdValue,
      );
    }

    Navigator.of(dialogContext).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isEdit ? 'Pengguna berhasil diperbarui!' : 'Pengguna baru berhasil ditambahkan!')),
    );
    _fetchUsers(); // refresh list
  } catch (e) {
    ScaffoldMessenger.of(dialogContext).showSnackBar(
      SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
    );
  }
},
                  child: Text(isEdit ? "Simpan Perubahan" : "Simpan"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      filled: true,
      fillColor: const Color(0xFFF4F7FC),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF006B3F),
        elevation: 0,
        title: const Text(
          "Admin - Manajemen Pengguna",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _fetchUsers),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF006B3F)))
          : RefreshIndicator(
              onRefresh: _fetchUsers,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Daftar Pengguna Sistem",
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Kelola hak akses dan akun staf perusahaan",
                              style: TextStyle(fontSize: 12, color: Color(0xFF778195)),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF006B3F),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => _showFormPenggunaDialog(context),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text("Tambah", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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
                          final isAktif = user.isActive == true;
                          final roleLabel = _roleToDisplay[user.role] ?? (user.role ?? 'Belum ditentukan');

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(4)),
                                          child: Text("No. ${user.id}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF778195))),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(user.name ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF172033))),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isAktif ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isAktif ? "Aktif" : "Non-Aktif",
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isAktif ? Colors.green[700] : Colors.red[700]),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.email_outlined, size: 14, color: Color(0xFF778195)),
                                    const SizedBox(width: 6),
                                    Text('${user.email}\n${user.phone}', style: const TextStyle(fontSize: 12, color: Color(0xFF778195))),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.admin_panel_settings_outlined, size: 14, color: Color(0xFF778195)),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Role: $roleLabel • Cabang: ${user.branchName ?? '-'}",
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF006B3F)),
                                    ),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                                ),
                               Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    // Tombol toggle status — selalu tampil, beda label/aksi tergantung status sekarang
    OutlinedButton.icon(
      onPressed: () => isAktif ? _handleNonaktifkan(user) : _handleAktifkan(user),
      icon: Icon(
        isAktif ? Icons.toggle_off_outlined : Icons.check_circle_outline,
        size: 14,
        color: isAktif ? Colors.orange[700] : Colors.green,
      ),
      label: Text(
        isAktif ? "Nonaktifkan" : "Aktifkan",
        style: TextStyle(fontSize: 11, color: isAktif ? Colors.orange[700] : Colors.green),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        side: BorderSide(color: isAktif ? Colors.orange[700]! : Colors.green),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        minimumSize: const Size(50, 28),
      ),
    ),
    const SizedBox(width: 8),
    OutlinedButton.icon(
      onPressed: () => _showFormPenggunaDialog(context, userData: user),
      icon: const Icon(Icons.edit_outlined, size: 14, color: Color(0xFF1B65E3)),
      label: const Text("Edit", style: TextStyle(fontSize: 11, color: Color(0xFF1B65E3))),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        side: const BorderSide(color: Color(0xFF1B65E3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        minimumSize: const Size(50, 28),
      ),
    ),
    const SizedBox(width: 8),
    OutlinedButton.icon(
      onPressed: () => _handleHapus(user),
      icon: const Icon(Icons.delete_outline_rounded, size: 14, color: Colors.red),
      label: const Text("Hapus", style: TextStyle(fontSize: 11, color: Colors.red)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        side: const BorderSide(color: Colors.red),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        minimumSize: const Size(50, 28),
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
    );
  }
}