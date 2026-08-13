import 'package:flutter/material.dart';
import 'manajemen_pengguna_screen.dart';
import 'form_tambah_janji_dialog.dart'; // Sesuaikan jika foldernya berbeda (misal: 'ui/admin/form_tambah_janji_dialog.dart')

class DashboardAdminScreen extends StatefulWidget {
  const DashboardAdminScreen({Key? key}) : super(key: key);

  @override
  State<DashboardAdminScreen> createState() => _DashboardAdminScreenState();
}

class _DashboardAdminScreenState extends State<DashboardAdminScreen> {
  // Indeks 0 untuk Beranda Admin
  int _currentIndex = 0;

  // State Filter & Pencarian
  String _filterStatus = 'Semua'; // 'Semua' atau 'Hari Ini'
  String _searchQuery = '';

  // Data Simulasi Daftar Reservasi & Janji Tamu (Dilengkapi Jam)
  final List<Map<String, dynamic>> _daftarReservasi = [
    {
      "id": 1,
      "token": "TRX-001",
      "nama": "Andi Pratama",
      "jabatan": "Direktur PT Maju",
      "jenis": "Meeting Bisnis",
      "tujuan": "Bapak Manager (Sleman)",
      "jam": "09:30 WIB",
      "status": "Terjadwal", // Bisa "Terjadwal", "Menunggu", "Dibatalkan"
      "tanggal": "2026-08-13",
    },
    {
      "id": 2,
      "token": "TRX-002",
      "nama": "Siti Aminah",
      "jabatan": "Consultant",
      "jenis": "Konsultasi",
      "tujuan": "Rian Sales (Magelang)",
      "jam": "10:15 WIB",
      "status": "Terjadwal",
      "tanggal": "2026-08-13",
    },
    {
      "id": 3,
      "token": "TRX-003",
      "nama": "Budi Santoso",
      "jabatan": "Kurir Paket",
      "jenis": "Pengiriman",
      "tujuan": "Resepsionis",
      "jam": "13:00 WIB",
      "status": "Dibatalkan",
      "tanggal": "2026-08-12",
    },
  ];

  

  @override
  Widget build(BuildContext context) {
    // Filter data berdasarkan pencarian nama dan tombol filter
    List<Map<String, dynamic>> filteredList = _daftarReservasi.where((item) {
      bool matchesSearch = item['nama'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item['token'].toLowerCase().contains(_searchQuery.toLowerCase());
      
      if (_filterStatus == 'Hari Ini') {
        return matchesSearch && item['tanggal'] == '2026-08-13';
      }
      return matchesSearch;
    }).toList();

    int totalTerjadwal = _daftarReservasi.where((e) => e['status'] == 'Terjadwal').length;
    int totalBelumSelesai = _daftarReservasi.where((e) => e['status'] == 'Menunggu' || e['status'] == 'Terjadwal').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF006B3F),
        elevation: 0,
        title: const Text(
          "Admin - Dashboard",
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
            // Card Ringkasan (Total Terjadwal & Total Belum Selesai)
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Total Terjadwal", style: TextStyle(fontSize: 11, color: Color(0xFF778195), fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text("$totalTerjadwal", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF006B3F))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Belum Selesai (Hari Ini)", style: TextStyle(fontSize: 11, color: Color(0xFF778195), fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text("$totalBelumSelesai", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Header Daftar Reservasi & Tombol Tambah Janji
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Daftar Reservasi & Janji Tamu",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                ),
                ElevatedButton.icon(
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF006B3F),
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  onPressed: () async {
    // Memanggil pop-up multi-slide 3 langkah yang sudah dipisah
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const FormTambahJanjiDialog(),
    );

    // Jika data dari slide 3 berhasil disimpan/disetujui
    if (result != null) {
      setState(() {
        _daftarReservasi.insert(0, {
          "id": _daftarReservasi.length + 1,
          "token": "TRX-00${_daftarReservasi.length + 1}",
          "nama": result["nama"],
          "jabatan": result["jabatan"],
          "jenis": result["jenis"],
          "tujuan": result["tujuan"],
          "jam": result["jam"],
          "status": "Terjadwal",
          "tanggal": "2026-08-13",
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Janji temu baru berhasil ditambahkan!'),
          backgroundColor: Color(0xFF006B3F),
        ),
      );
    }
  },
  icon: const Icon(Icons.add, size: 16),
  label: const Text("Tambah Janji", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
),
              ],
            ),
            const SizedBox(height: 12),

            // Search Bar & Filter Button (Semua Data / Hari Ini Aja)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Cari berdasarkan nama tamu...",
                      hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                      prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF778195)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (val) {
                    setState(() {
                      _filterStatus = val;
                    });
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'Semua', child: Text("Semua Data")),
                    const PopupMenuItem(value: 'Hari Ini', child: Text("Data Hari Ini Aja")),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.filter_list, size: 16, color: Color(0xFF006B3F)),
                        const SizedBox(width: 4),
                        Text(_filterStatus, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF172033))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // List Daftar Reservasi & Janji Tamu
            filteredList.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text("Tidak ada data reservasi yang ditemukan.", style: TextStyle(color: Color(0xFF778195), fontSize: 12)),
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
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nomor, Token & Status Badge
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(4)),
                                  child: Text("No. ${item["id"]} • ${item["token"]}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF778195))),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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

                            // Tamu & Jabatan
                            Text(item["nama"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF172033))),
                            Text(item["jabatan"], style: const TextStyle(fontSize: 11, color: Color(0xFF778195))),
                            const SizedBox(height: 6),

                            // Jam Kunjungan
                            Row(
                              children: [
                                const Icon(Icons.access_time_rounded, size: 13, color: Color(0xFF006B3F)),
                                const SizedBox(width: 4),
                                Text("Jam: ${item["jam"]}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF006B3F))),
                              ],
                            ),
                            const SizedBox(height: 4),

                            // Jenis Kunjungan
                            Row(
                              children: [
                                const Icon(Icons.assignment_outlined, size: 13, color: Color(0xFF778195)),
                                const SizedBox(width: 4),
                                Text("Jenis Kunjungan: ${item["jenis"]}", style: const TextStyle(fontSize: 11, color: Color(0xFF778195))),
                              ],
                            ),
                            const SizedBox(height: 2),

                            // Tujuan PIC
                            Row(
                              children: [
                                const Icon(Icons.person_outline_rounded, size: 13, color: Color(0xFF006B3F)),
                                const SizedBox(width: 4),
                                Text("Tujuan PIC: ${item["tujuan"]}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF006B3F))),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                            ),

                            // Kolom Aksi (Jika status masih Terjadwal, tampilkan 2 tombol. Jika sudah dipencet salah satu, jadi 1 tombol status Menunggu)
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
                                    icon: const Icon(Icons.check_circle_outline, size: 13, color: Colors.green),
                                    label: const Text("Check-In", style: TextStyle(fontSize: 11, color: Colors.green)),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      side: const BorderSide(color: Colors.green),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                      minimumSize: const Size(40, 26),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        item["status"] = "Dibatalkan";
                                      });
                                    },
                                    icon: const Icon(Icons.cancel_outlined, size: 13, color: Colors.red),
                                    label: const Text("Batalkan", style: TextStyle(fontSize: 11, color: Colors.red)),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      side: const BorderSide(color: Colors.red),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                      minimumSize: const Size(40, 26),
                                    ),
                                  ),
                                ] else ...[
                                  // Berubah jadi 1 tampilan aksi tunggal "Menunggu"
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Status: Menunggu',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange),
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
      // NAVBAR BAWAH (Lengkap 5 Menu Sesuai Rincian)
      // ===================================================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF006B3F),
        unselectedItemColor: const Color(0xFF778195),
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 0) {
            // Beranda (Halaman ini)
          } else if (index == 1) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Navigasi ke Daftar Tamu')));
          } else if (index == 2) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Navigasi ke Riwayat Kunjungan')));
          } else if (index == 3) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Navigasi ke Janji Tamu')));
          } else if (index == 4) {
            // Navigasi ke Manajemen Pengguna
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ManajemenPenggunaScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline_rounded), label: 'Daftar Tamu'),
          BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: 'Janji Tamu'),
          BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings_outlined), label: 'Pengguna'),
        ],
      ),
    );
  }
}