import 'package:flutter/material.dart';

class ManajemenPenggunaScreen extends StatefulWidget {
  const ManajemenPenggunaScreen({Key? key}) : super(key: key);

  @override
  State<ManajemenPenggunaScreen> createState() => _ManajemenPenggunaScreenState();
}

class _ManajemenPenggunaScreenState extends State<ManajemenPenggunaScreen> {
  // Data Simulasi Daftar Pengguna
  final List<Map<String, dynamic>> _daftarPengguna = [
    {
      "id": "1",
      "nama": "Bapak Manager",
      "kontak": "manager@office.com\n081234567890",
      "role": "Manager",
      "cabang": "Cabang Sleman",
      "status": "Aktif",
    },
    {
      "id": "2",
      "nama": "Rian Sales",
      "kontak": "rian@office.com\n089876543210",
      "role": "PIC / Sales",
      "cabang": "Cabang Magelang",
      "status": "Aktif",
    },
    {
      "id": "3",
      "nama": "Satpam Jaga Pagi",
      "kontak": "satpam1@office.com\n085678123456",
      "role": "Satpam",
      "cabang": "Cabang Sleman",
      "status": "Non-Aktif",
    },
  ];

  // Opsi Dropdown untuk Role & Cabang
  final List<String> _roleOptions = ['Owner', 'Manager', 'PIC / Sales', 'Satpam', 'Admin'];
  final List<String> _cabangOptions = ['Cabang Sleman', 'Cabang Magelang', 'Cabang Yogyakarta', 'Cabang Solo'];

  // Fungsi Pop-Up Dialog untuk Tambah / Edit Pengguna
  void _showFormPenggunaDialog(BuildContext context, {Map<String, dynamic>? userData}) {
    final bool isEdit = userData != null;

    final TextEditingController namaController = TextEditingController(text: isEdit ? userData['nama'] : '');
    final TextEditingController emailController = TextEditingController(text: isEdit ? userData['kontak'].split('\n')[0] : '');
    final TextEditingController waController = TextEditingController(text: isEdit ? userData['kontak'].split('\n')[1] : '');
    final TextEditingController passwordController = TextEditingController();

    String selectedRole = isEdit ? userData['role'] : _roleOptions[0];
    String selectedCabang = isEdit ? userData['cabang'] : _cabangOptions[0];

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
                    TextField(
                      controller: namaController,
                      decoration: _inputDecoration("Masukkan nama lengkap"),
                    ),
                    const SizedBox(height: 10),
                    const Text("Email", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF778195))),
                    const SizedBox(height: 4),
                    TextField(
                      controller: emailController,
                      decoration: _inputDecoration("contoh@office.com"),
                    ),
                    const SizedBox(height: 10),
                    const Text("No. WhatsApp", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF778195))),
                    const SizedBox(height: 4),
                    TextField(
                      controller: waController,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration("08xxxxxxxxxx"),
                    ),
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
                          items: _roleOptions.map((String role) {
                            return DropdownMenuItem<String>(
                              value: role,
                              child: Text(role),
                            );
                          }).toList(),
                          onChanged: (String? val) {
                            if (val != null) {
                              setStateDialog(() {
                                selectedRole = val;
                              });
                            }
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
                          items: _cabangOptions.map((String cabang) {
                            return DropdownMenuItem<String>(
                              value: cabang,
                              child: Text(cabang),
                            );
                          }).toList(),
                          onChanged: (String? val) {
                            if (val != null) {
                              setStateDialog(() {
                                selectedCabang = val;
                              });
                            }
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
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isEdit ? 'Pengguna berhasil diperbarui!' : 'Pengguna baru berhasil ditambahkan!')),
                    );
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
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
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
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _daftarPengguna.length,
              itemBuilder: (context, index) {
                final user = _daftarPengguna[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
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
                                child: Text("No. ${user["id"]}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF778195))),
                              ),
                              const SizedBox(width: 8),
                              Text(user["nama"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF172033))),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: user["status"] == "Aktif" ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              user["status"],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: user["status"] == "Aktif" ? Colors.green[700] : Colors.red[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.email_outlined, size: 14, color: Color(0xFF778195)),
                          const SizedBox(width: 6),
                          Text(user["kontak"], style: const TextStyle(fontSize: 12, color: Color(0xFF778195))),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.admin_panel_settings_outlined, size: 14, color: Color(0xFF778195)),
                          const SizedBox(width: 6),
                          Text("Role: ${user["role"]} • Cabang: ${user["cabang"]}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF006B3F))),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
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
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Pengguna ${user["nama"]} dihapus!')),
                              );
                            },
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
    );
  }
}