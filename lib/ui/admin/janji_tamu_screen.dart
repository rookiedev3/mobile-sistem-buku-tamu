import 'package:flutter/material.dart';
// import 'dashboard_admin_screen.dart';
// import 'daftar_tamu_screen.dart';
// import 'riwayat_screen.dart';
// import 'manajemen_pengguna_screen.dart';
import 'form_tambah_janji_dialog.dart'; // Memanggil pop-up 3 slide yang sudah dibuat sebelumnya

class JanjiTamuScreen extends StatefulWidget {
  const JanjiTamuScreen({Key? key}) : super(key: key);

  @override
  State<JanjiTamuScreen> createState() => _JanjiTamuScreenState();
}

class _JanjiTamuScreenState extends State<JanjiTamuScreen> {
  final Color corporateGreen = const Color(0xFF006B3F);
  
  // Indeks 3 untuk menu Janji Tamu pada Navbar Bawah (5 Menu)
  // int _currentIndex = 3;

  // State Pencarian
  String _searchQuery = '';

  // Data Simulasi Daftar Tamu Terjadwal
  final List<Map<String, dynamic>> _daftarJanji = [
    {
      "id": 1,
      "token": "TRX-901",
      "waktu": "10:00 WIB",
      "nama": "Andi Pratama",
      "jabatan": "Direktur PT Maju",
      "jenis": "Meeting Bisnis",
      "tujuan": "Bapak Manager (Sleman)",
      "status": "Terjadwal",
    },
    {
      "id": 2,
      "token": "TRX-902",
      "waktu": "13:30 WIB",
      "nama": "Siti Aminah",
      "jabatan": "Consultant",
      "jenis": "Konsultasi",
      "tujuan": "Rian Sales (Magelang)",
      "status": "Terjadwal",
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter data berdasarkan pencarian nama tamu atau PIC
    List<Map<String, dynamic>> filteredList = _daftarJanji.where((item) {
      return item['nama'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item['tujuan'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item['token'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: corporateGreen,
        elevation: 0,
        title: const Text(
          "Admin - Janji Tamu & Reservasi",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header & Tombol Buat Janji Tamu (Memanggil Pop-up 3 Slide)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Daftar Janji Tamu Terjadwal",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Kelola jadwal kedatangan dan reservasi tamu",
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
                  onPressed: () async {
                    // Memanggil pop-up 3 slide yang sudah ada
                    final result = await showDialog<Map<String, dynamic>>(
                      context: context,
                      builder: (context) => const FormTambahJanjiDialog(),
                    );

                    if (result != null) {
                      setState(() {
                        _daftarJanji.insert(0, {
                          "id": _daftarJanji.length + 1,
                          "token": "TRX-00${_daftarJanji.length + 1}",
                          "waktu": result["jam"],
                          "nama": result["nama"],
                          "jabatan": result["jabatan"],
                          "jenis": result["jenis"],
                          "tujuan": result["tujuan"],
                          "status": "Terjadwal",
                        });
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Janji tamu baru berhasil dibuat!'),
                          backgroundColor: Color(0xFF006B3F),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text("Buat Janji", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Search Bar Berdasarkan Nama Tamu atau PIC
            TextField(
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: "Cari nama tamu atau tujuan PIC...",
                hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF778195)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // List Daftar Tamu Terjadwal
            filteredList.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text("Tidak ada data janji temu ditemukan.", style: TextStyle(color: Color(0xFF778195), fontSize: 11)),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      String currentStatus = item["status"];

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
                                  child: Text("No. ${item["id"]} • ${item["token"]}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF778195))),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: currentStatus == "Terjadwal"
                                        ? Colors.blue.withOpacity(0.1)
                                        : currentStatus == "Menunggu"
                                            ? Colors.orange.withOpacity(0.1)
                                            : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    currentStatus,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: currentStatus == "Terjadwal"
                                          ? Colors.blue[700]
                                          : currentStatus == "Menunggu"
                                              ? Colors.orange[700]
                                              : Colors.red[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(item["nama"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF172033))),
                            Text(item["jabatan"], style: const TextStyle(fontSize: 10, color: Color(0xFF778195))),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.access_time_rounded, size: 12, color: Color(0xFF006B3F)),
                                const SizedBox(width: 4),
                                Text("Waktu: ${item["waktu"]}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF006B3F))),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.assignment_outlined, size: 12, color: Color(0xFF778195)),
                                const SizedBox(width: 4),
                                Text("Jenis Kunjungan: ${item["jenis"]}", style: const TextStyle(fontSize: 10, color: Color(0xFF778195))),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.person_outline_rounded, size: 12, color: Color(0xFF006B3F)),
                                const SizedBox(width: 4),
                                Text("Tujuan PIC: ${item["tujuan"]}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF006B3F))),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 6.0),
                              child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                            ),
                            // Kolom Aksi (Tombol Check-In / Batalkan atau Status Menunggu)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (currentStatus == 'Terjadwal') ...[
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        item["status"] = "Menunggu";
                                      });
                                    },
                                    icon: const Icon(Icons.check_circle_outline, size: 12, color: Colors.green),
                                    label: const Text("Check-In", style: TextStyle(fontSize: 10, color: Colors.green)),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      side: const BorderSide(color: Colors.green),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                      minimumSize: const Size(40, 24),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        item["status"] = "Dibatalkan";
                                      });
                                    },
                                    icon: const Icon(Icons.cancel_outlined, size: 12, color: Colors.red),
                                    label: const Text("Batalkan", style: TextStyle(fontSize: 10, color: Colors.red)),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      side: const BorderSide(color: Colors.red),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                      minimumSize: const Size(40, 24),
                                    ),
                                  ),
                                ] else ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: currentStatus == "Menunggu" ? Colors.orange.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Status: $currentStatus',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: currentStatus == "Menunggu" ? Colors.orange[700] : Colors.red[700],
                                      ),
                                    ),
                                  ),
                                ],
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
      //       Navigator.pushReplacement(
      //         context,
      //         MaterialPageRoute(builder: (context) => const DashboardAdminScreen()),
      //       );
      //     } else if (index == 1) {
      //       Navigator.pushReplacement(
      //         context,
      //         MaterialPageRoute(builder: (context) => const DaftarTamuScreen()),
      //       );
      //     } else if (index == 2) {
      //       Navigator.pushReplacement(
      //         context,
      //         MaterialPageRoute(builder: (context) => const RiwayatScreen()),
      //       );
      //     } else if (index == 3) {
      //       // Halaman ini (Janji Tamu)
      //     } else if (index == 4) {
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