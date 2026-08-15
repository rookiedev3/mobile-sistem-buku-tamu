import 'package:flutter/material.dart';
import 'dashboard_admin_screen.dart';
import 'daftar_tamu_screen.dart';
import 'manajemen_pengguna_screen.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({Key? key}) : super(key: key);

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  final Color corporateGreen = const Color(0xFF006B3F);
  
  // Indeks 2 untuk menu Riwayat Kunjungan pada Navbar Bawah (5 Menu)
  int _currentIndex = 2;

  // State Pencarian & Filter Tanggal
  String _searchQuery = '';
  String? _selectedDateFilter; // Format: "YYYY-MM-DD"

  // Data Simulasi Arsip Riwayat Kunjungan
  final List<Map<String, dynamic>> _daftarRiwayat = [
    {
      "id": 1,
      "token": "TRX-8801",
      "waktu": "09:30 - 10:15 WIB",
      "tanggal": "2026-08-13",
      "nama": "Andi Pratama",
      "jabatan": "Direktur PT Maju",
      "jenis": "Meeting Bisnis",
      "tujuan": "Bapak Manager (Sleman)",
      "statusAkhir": "Deal",
      "instansi": "PT Maju Bersama",
      "wa": "081234567890",
      "checkIn": "13 Agu 2026, 09:30 WIB",
      "checkOut": "13 Agu 2026, 10:15 WIB",
      "foto": "https://via.placeholder.com/150",
    },
    {
      "id": 2,
      "token": "TRX-8802",
      "waktu": "11:00 - 11:45 WIB",
      "tanggal": "2026-08-13",
      "nama": "Siti Aminah",
      "jabatan": "Consultant",
      "jenis": "Konsultasi",
      "tujuan": "Rian Sales (Magelang)",
      "statusAkhir": "Dibatalkan",
      "instansi": "Konsultan Mandiri",
      "wa": "089876543210",
      "checkIn": "13 Agu 2026, 11:00 WIB",
      "checkOut": "13 Agu 2026, 11:15 WIB",
      "foto": "https://via.placeholder.com/150",
    },
    {
      "id": 3,
      "token": "TRX-8795",
      "waktu": "14:00 - 15:00 WIB",
      "tanggal": "2026-08-12",
      "nama": "Budi Santoso",
      "jabatan": "Project Manager",
      "jenis": "Maintenance",
      "tujuan": "Ahmad (IT Support)",
      "statusAkhir": "Selesai",
      "instansi": "PT Global Tech",
      "wa": "085678123456",
      "checkIn": "12 Agu 2026, 14:00 WIB",
      "checkOut": "12 Agu 2026, 15:00 WIB",
      "foto": "https://via.placeholder.com/150",
    },
  ];

  // Pop-up Detail Arsip Kunjungan
  void _showDetailRiwayatDialog(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.all(20),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Detail Arsip Kunjungan", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const Divider(height: 12),
                
                // Foto Dokumen Wajah
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 90,
                      height: 90,
                      color: Colors.grey[200],
                      child: const Icon(Icons.person_rounded, size: 50, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Informasi Lengkap
                _buildDetailRow("No. Token", item["token"]),
                _buildDetailRow("Status Kelanjutan", item["statusAkhir"]),
                _buildDetailRow("Nama Lengkap", item["nama"]),
                _buildDetailRow("Asal Instansi", item["instansi"]),
                _buildDetailRow("Jabatan", item["jabatan"]),
                _buildDetailRow("No. WhatsApp", item["wa"]),
                _buildDetailRow("Jenis Kunjungan", item["jenis"]),
                _buildDetailRow("Tujuan PIC", item["tujuan"]),
                _buildDetailRow("Waktu Check-In", item["checkIn"]),
                _buildDetailRow("Waktu Check-Out", item["checkOut"]),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: corporateGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF778195), fontWeight: FontWeight.w600))),
          const Text(": ", style: TextStyle(fontSize: 11)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF172033)))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter data berdasarkan Search Bar (Nama/Instansi/PIC) dan Tanggal
    List<Map<String, dynamic>> filteredList = _daftarRiwayat.where((item) {
      bool matchesSearch = item['nama'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item['instansi'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item['tujuan'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item['token'].toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesDate = _selectedDateFilter == null || item['tanggal'] == _selectedDateFilter;

      return matchesSearch && matchesDate;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: corporateGreen,
        elevation: 0,
        title: const Text(
          "Admin - Riwayat Kunjungan",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Arsip Data Kunjungan",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
            ),
            const SizedBox(height: 2),
            const Text(
              "Cari dan tinjau riwayat seluruh tamu yang telah berkunjung",
              style: TextStyle(fontSize: 11, color: Color(0xFF778195)),
            ),
            const SizedBox(height: 14),

            // Search Bar (Nama Tamu / Instansi / PIC)
            TextField(
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: "Cari nama tamu, instansi, atau PIC...",
                hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF778195)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),

            // Filter Tanggal & Tombol Reset
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2025),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDateFilter = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF006B3F)),
                          const SizedBox(width: 8),
                          Text(
                            _selectedDateFilter == null ? "Filter Tanggal..." : "Tanggal: $_selectedDateFilter",
                            style: TextStyle(fontSize: 11, color: _selectedDateFilter == null ? const Color(0xFF9CA3AF) : const Color(0xFF172033), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_selectedDateFilter != null) ...[
                  const SizedBox(width: 8),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedDateFilter = null;
                      });
                    },
                    child: const Text("Reset", style: TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // List Arsip Riwayat
            filteredList.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text("Tidak ada arsip riwayat kunjungan yang ditemukan.", style: TextStyle(color: Color(0xFF778195), fontSize: 11)),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      bool isDeal = item["statusAkhir"] == "Deal" || item["statusAkhir"] == "Selesai";

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
                                    color: isDeal ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item["statusAkhir"],
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isDeal ? Colors.green[700] : Colors.red[700],
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
                                Text("Waktu: ${item["waktu"]} (${item["tanggal"]})", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF006B3F))),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.assignment_outlined, size: 12, color: Color(0xFF778195)),
                                const SizedBox(width: 4),
                                Text("Jenis: ${item["jenis"]}", style: const TextStyle(fontSize: 10, color: Color(0xFF778195))),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => _showDetailRiwayatDialog(context, item),
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
      //       // Halaman ini (Riwayat)
      //     } else if (index == 3) {
      //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Navigasi ke Janji Tamu')));
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