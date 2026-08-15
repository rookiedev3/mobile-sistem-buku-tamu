import 'package:flutter/material.dart';
// import 'dashboard_admin_screen.dart';
// import 'manajemen_pengguna_screen.dart';

class DaftarTamuScreen extends StatefulWidget {
  const DaftarTamuScreen({Key? key}) : super(key: key);

  @override
  State<DaftarTamuScreen> createState() => _DaftarTamuScreenState();
}

class _DaftarTamuScreenState extends State<DaftarTamuScreen> {
  final Color corporateGreen = const Color(0xFF006B3F);
  
  // Indeks 1 untuk menu Daftar Tamu pada Navbar Bawah (5 Menu)
  // int _currentIndex = 1;

  // State Filter Kategori
  String _filterKategori = 'Semua Tamu';

  // Data Simulasi Direktori Tamu
  final List<Map<String, dynamic>> _daftarTamu = [
    {
      "id": 1,
      "nama": "Budi Santoso",
      "tanggal": "13 Agu 2026",
      "instansi": "PT. Maju Mundur",
      "jabatan": "Project Manager",
      "wa": "081234567890",
      "email": "budi@majumundur.com",
      "alamat": "Jl. Malioboro No. 10, Yogyakarta",
      "status": "VIP",
      "totalKunjungan": 5,
    },
    {
      "id": 2,
      "nama": "Siti Aminah",
      "tanggal": "12 Agu 2026",
      "instansi": "Universitas Teknologi",
      "jabatan": "Mahasiswa / Peneliti",
      "wa": "089876543210",
      "email": "siti@student.ac.id",
      "alamat": "Jl. Ringroad Utara, Sleman",
      "status": "Reguler",
      "totalKunjungan": 2,
    },
    {
      "id": 3,
      "nama": "Ahmad Fauzi",
      "tanggal": "10 Agu 2026",
      "instansi": "CV. Solusi Digital",
      "jabatan": "Direktur Utama",
      "wa": "085678123456",
      "email": "fauzi@solusi.com",
      "alamat": "Jl. Magelang KM 5, Magelang",
      "status": "VIP",
      "totalKunjungan": 8,
    },
  ];

  // Pop-up Detail Tamu
  void _showDetailTamuDialog(BuildContext context, Map<String, dynamic> tamu) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.all(20),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFFF4F7FC),
                  child: Icon(Icons.person, size: 35, color: Color(0xFF006B3F)),
                ),
                const SizedBox(height: 10),
                Text(
                  tamu["nama"],
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: tamu["status"] == "VIP" ? Colors.amber.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tamu["status"],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: tamu["status"] == "VIP" ? Colors.amber[800] : Colors.grey[700],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 10),
                _buildDetailRow("Instansi", tamu["instansi"]),
                _buildDetailRow("Jabatan", tamu["jabatan"]),
                _buildDetailRow("No. WA", tamu["wa"]),
                _buildDetailRow("Email", tamu["email"]),
                _buildDetailRow("Alamat", tamu["alamat"]),
                _buildDetailRow("Frekuensi", "${tamu["totalKunjungan"]} Kali"),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: corporateGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Tutup", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Pop-up Tambah Tamu Baru
  void _showTambahTamuDialog(BuildContext context) {
    final namaController = TextEditingController();
    final waController = TextEditingController();
    final emailController = TextEditingController();
    final instansiController = TextEditingController();
    final jabatanController = TextEditingController();
    final alamatController = TextEditingController();
    String statusTamu = 'Reguler';
    bool adaFoto = false;

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
                  const Text("Tambah Tamu Baru", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField("Nama Lengkap *", namaController),
                    const SizedBox(height: 6),
                    _buildTextField("No. WhatsApp *", waController, keyboardType: TextInputType.phone),
                    const SizedBox(height: 6),
                    _buildTextField("Email", emailController, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 6),
                    _buildTextField("Instansi / Perusahaan", instansiController),
                    const SizedBox(height: 6),
                    _buildTextField("Jabatan", jabatanController),
                    const SizedBox(height: 6),
                    const Text("Status Tamu", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF778195))),
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
                          value: statusTamu,
                          isExpanded: true,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF172033), fontWeight: FontWeight.w600),
                          items: ['Reguler', 'VIP'].map((val) {
                            return DropdownMenuItem(value: val, child: Text(val));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setStateDialog(() => statusTamu = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildTextField("Alamat", alamatController),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => setStateDialog(() => adaFoto = true),
                          icon: const Icon(Icons.upload_file, size: 12, color: Color(0xFF006B3F)),
                          label: const Text("Upload Foto", style: TextStyle(fontSize: 10, color: Color(0xFF006B3F))),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: corporateGreen),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (adaFoto) const Text("Terlampir ✓", style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
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
                    if (namaController.text.isNotEmpty && waController.text.isNotEmpty) {
                      setState(() {
                        _daftarTamu.insert(0, {
                          "id": _daftarTamu.length + 1,
                          "nama": namaController.text,
                          "tanggal": "13 Agu 2026",
                          "instansi": instansiController.text.isEmpty ? "-" : instansiController.text,
                          "jabatan": jabatanController.text.isEmpty ? "-" : jabatanController.text,
                          "wa": waController.text,
                          "email": emailController.text.isEmpty ? "-" : emailController.text,
                          "alamat": alamatController.text.isEmpty ? "-" : alamatController.text,
                          "status": statusTamu,
                          "totalKunjungan": 1,
                        });
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tamu baru berhasil ditambahkan!'), backgroundColor: Color(0xFF006B3F)),
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

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF778195))),
        const SizedBox(height: 3),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF778195), fontWeight: FontWeight.w600))),
          const Text(": ", style: TextStyle(fontSize: 11)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF172033)))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter data berdasarkan kategori
    List<Map<String, dynamic>> filteredList = _daftarTamu.where((tamu) {
      if (_filterKategori == 'VIP') return tamu['status'] == 'VIP';
      if (_filterKategori == 'Reguler') return tamu['status'] == 'Reguler';
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: corporateGreen,
        elevation: 0,
        title: const Text(
          "Admin - Daftar Direktori Tamu",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header & Tombol Tambah Tamu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Direktori Buku Tamu",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Kelola seluruh data kunjungan",
                        style: TextStyle(fontSize: 11, color: Color(0xFF778195)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: corporateGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _showTambahTamuDialog(context),
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text("Tambah", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Filter Kategori Dropdown
            Row(
              children: [
                const Text("Filter: ", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF778195))),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _filterKategori,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF172033), fontWeight: FontWeight.bold),
                      items: ['Semua Tamu', 'VIP', 'Reguler'].map((String val) {
                        return DropdownMenuItem<String>(
                          value: val,
                          child: Text(val),
                        );
                      }).toList(),
                      onChanged: (String? val) {
                        if (val != null) setState(() => _filterKategori = val);
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Daftar Tamu dalam Bentuk Card Responsif
            filteredList.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text("Tidak ada data tamu ditemukan.", style: TextStyle(color: Color(0xFF778195), fontSize: 11)),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final tamu = filteredList[index];
                      bool isVip = tamu["status"] == "VIP";

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
                                  child: Text("No. ${tamu["id"]}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF778195))),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isVip ? Colors.amber.withOpacity(0.2) : Colors.grey.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    tamu["status"],
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isVip ? Colors.amber[800] : Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Color(0xFFF4F7FC),
                                  child: Icon(Icons.person, size: 18, color: Color(0xFF006B3F)),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(tamu["nama"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF172033)), overflow: TextOverflow.ellipsis),
                                      Text("Terdaftar: ${tamu["tanggal"]}", style: const TextStyle(fontSize: 9, color: Color(0xFF778195))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text("Instansi: ${tamu["instansi"]} • ${tamu["jabatan"]}", style: const TextStyle(fontSize: 10, color: Color(0xFF778195)), overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text("No. WA: ${tamu["wa"]}", style: const TextStyle(fontSize: 10, color: Color(0xFF778195))),
                            const SizedBox(height: 2),
                            Text("Total Kunjungan: ${tamu["totalKunjungan"]} Kali", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF006B3F))),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 6.0),
                              child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => _showDetailTamuDialog(context, tamu),
                                  icon: const Icon(Icons.visibility_outlined, size: 12, color: Color(0xFF006B3F)),
                                  label: const Text("Detail", style: TextStyle(fontSize: 10, color: Color(0xFF006B3F))),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    side: BorderSide(color: corporateGreen),
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
      // NAVBAR BAWAH (Konsisten 5 Menu Sesuai Dashboard Admin)
      // ===================================================
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: _currentIndex,
      //   selectedItemColor: const Color(0xFF006B3F),
      //   unselectedItemColor: const Color(0xFF778195),
      //   backgroundColor: Colors.white,
      //   type: BottomNavigationBarType.fixed,
      //   selectedFontSize: 10,
      //   unselectedFontSize: 10,
      //   onTap: (index) {
      //     setState(() {
      //       _currentIndex = index;
      //     });

      //     if (index == 0) {
      //       // Kembali ke Beranda Admin
      //       Navigator.pushReplacement(
      //         context,
      //         MaterialPageRoute(builder: (context) => const DashboardAdminScreen()),
      //       );
      //     } else if (index == 1) {
      //       // Halaman ini (Daftar Tamu)
      //     } else if (index == 2) {
      //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Navigasi ke Riwayat Kunjungan')));
      //     } else if (index == 3) {
      //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Navigasi ke Janji Tamu')));
      //     } else if (index == 4) {
      //       // Pindah ke Manajemen Pengguna
      //       Navigator.push(
      //         context,
      //         MaterialPageRoute(builder: (context) => const ManajemenPenggunaScreen()),
      //       );
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