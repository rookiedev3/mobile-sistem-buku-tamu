import 'package:flutter/material.dart';
import 'dashboard_admin_screen.dart';
import 'daftar_tamu_screen.dart';
import 'riwayat_screen.dart';
import 'janji_tamu_screen.dart';
import 'branches_screen.dart'; // File Master Data Branches

class ManajemenPenggunaScreen extends StatefulWidget {
  const ManajemenPenggunaScreen({Key? key}) : super(key: key);

  @override
  State<ManajemenPenggunaScreen> createState() => _ManajemenPenggunaScreenState();
}

class _ManajemenPenggunaScreenState extends State<ManajemenPenggunaScreen> {
  final Color corporateGreen = const Color(0xFF006B3F);
  
  // Indeks 4 untuk menu Pengguna pada Navbar Bawah (5 Menu)
  int _currentIndex = 4;

  // Data Simulasi Akun Pengguna Aktif (Memuat Email dan No. HP secara terpisah)
  final List<Map<String, dynamic>> _daftarPengguna = [
    {
      "id": 1,
      "nama": "Bapak Manager",
      "email": "manager@itsolution.com",
      "wa": "081122334455",
      "role": "Manager",
      "branch": "Cabang Sleman",
      "status": "Aktif",
    },
    {
      "id": 2,
      "nama": "Rian Sales",
      "email": "rian.sales@itsolution.com",
      "wa": "081234567890",
      "role": "PIC",
      "branch": "Cabang Magelang",
      "status": "Aktif",
    },
    {
      "id": 3,
      "nama": "Siska Staff",
      "email": "siska@itsolution.com",
      "wa": "089876543210",
      "role": "Admin",
      "branch": "Cabang Sleman",
      "status": "Aktif",
    },
  ];

  // Pop-up Tambah Pengguna Baru
  void _showTambahPenggunaDialog(BuildContext context) {
    final namaController = TextEditingController();
    final emailController = TextEditingController();
    final waController = TextEditingController();
    final passwordController = TextEditingController();
    String selectedRole = 'PIC';
    String selectedBranch = 'Cabang Sleman';
    bool userAktif = true;

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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F7FC),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedRole,
                          isExpanded: true,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF172033), fontWeight: FontWeight.w600),
                          items: ['PIC', 'Manager', 'Owner', 'Admin', 'Security', 'Tamu'].map((val) {
                            return DropdownMenuItem(value: val, child: Text(val));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setStateDialog(() => selectedRole = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text("Cabang Branch", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF778195))),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F7FC),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedBranch,
                          isExpanded: true,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF172033), fontWeight: FontWeight.w600),
                          items: ['Cabang Sleman', 'Cabang Magelang'].map((val) {
                            return DropdownMenuItem(value: val, child: Text(val));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setStateDialog(() => selectedBranch = val);
                          },
                        ),
                      ),
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
                  onPressed: () => Navigator.pop(context),
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
                  onPressed: () {
                    if (namaController.text.isNotEmpty) {
                      setState(() {
                        _daftarPengguna.add({
                          "id": _daftarPengguna.length + 1,
                          "nama": namaController.text,
                          "email": emailController.text.isEmpty ? "-" : emailController.text,
                          "wa": waController.text.isEmpty ? "-" : waController.text,
                          "role": selectedRole,
                          "branch": selectedBranch,
                          "status": userAktif ? "Aktif" : "Non-Aktif",
                        });
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pengguna baru berhasil ditambahkan!'), backgroundColor: Color(0xFF006B3F)),
                      );
                    }
                  },
                  child: const Text("Simpan", style: TextStyle(fontSize: 11)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Pop-up Edit Pengguna (Memuat Email, No. WA, dan Password Baru)
  void _showEditPenggunaDialog(BuildContext context, Map<String, dynamic> user) {
    final namaController = TextEditingController(text: user["nama"]);
    final emailController = TextEditingController(text: user["email"]);
    final waController = TextEditingController(text: user["wa"]);
    final passwordBaruController = TextEditingController();
    String selectedRole = user["role"];
    String selectedBranch = user["branch"];
    bool userAktif = user["status"] == "Aktif";

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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F7FC),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedRole,
                          isExpanded: true,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF172033), fontWeight: FontWeight.w600),
                          items: ['PIC', 'Manager', 'Owner', 'Admin', 'Security', 'Tamu'].map((val) {
                            return DropdownMenuItem(value: val, child: Text(val));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setStateDialog(() => selectedRole = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text("Cabang Branch", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF778195))),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F7FC),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedBranch,
                          isExpanded: true,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF172033), fontWeight: FontWeight.w600),
                          items: ['Cabang Sleman', 'Cabang Magelang'].map((val) {
                            return DropdownMenuItem(value: val, child: Text(val));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setStateDialog(() => selectedBranch = val);
                          },
                        ),
                      ),
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
                  onPressed: () => Navigator.pop(context),
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
                  onPressed: () {
                    setState(() {
                      user["nama"] = namaController.text;
                      user["email"] = emailController.text;
                      user["wa"] = waController.text;
                      user["role"] = selectedRole;
                      user["branch"] = selectedBranch;
                      user["status"] = userAktif ? "Aktif" : "Non-Aktif";
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pengguna berhasil diperbarui!'), backgroundColor: Color(0xFF006B3F)),
                    );
                  },
                  child: const Text("Perbarui", style: TextStyle(fontSize: 11)),
                ),
              ],
            );
          },
        );
      },
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
        title: const Text(
          "Admin - Manajemen Pengguna",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tombol Master Data & Tambah Pengguna
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BranchesScreen()),
                    );
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
            const Text(
              "Daftar Akun Pengguna Aktif",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
            ),
            const SizedBox(height: 2),
            const Text(
              "Kelola hak akses dan status akun pengguna sistem",
              style: TextStyle(fontSize: 11, color: Color(0xFF778195)),
            ),
            const SizedBox(height: 14),

            // List Daftar Akun Pengguna Aktif
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _daftarPengguna.length,
              itemBuilder: (context, index) {
                final user = _daftarPengguna[index];
                bool isActive = user["status"] == "Aktif";

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
                            child: Text("Role: ${user["role"]}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF006B3F))),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              user["status"],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isActive ? Colors.green[700] : Colors.red[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(user["nama"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF172033))),
                      const SizedBox(height: 4),
                      Text("Email: ${user["email"]}", style: const TextStyle(fontSize: 10, color: Color(0xFF778195))),
                      Text("No. WA: ${user["wa"]}", style: const TextStyle(fontSize: 10, color: Color(0xFF778195))),
                      Text("Cabang: ${user["branch"]}", style: const TextStyle(fontSize: 10, color: Color(0xFF778195))),
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
                            onPressed: () {
                              setState(() {
                                _daftarPengguna.removeAt(index);
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Pengguna berhasil dihapus!')),
                              );
                            },
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

      // ===================================================
      // NAVBAR BAWAH (Konsisten 5 Menu)
      // ===================================================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF006B3F),
        unselectedItemColor: const Color(0xFF778195),
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardAdminScreen()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DaftarTamuScreen()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const RiwayatScreen()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const JanjiTamuScreen()),
            );
          } else if (index == 4) {
            // Halaman ini (Pengguna)
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded, size: 20), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline_rounded, size: 20), label: 'Daftar Tamu'),
          BottomNavigationBarItem(icon: Icon(Icons.history_rounded, size: 20), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined, size: 20), label: 'Janji Tamu'),
          BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings_outlined, size: 20), label: 'Pengguna'),
        ],
      ),
    );
  }
}