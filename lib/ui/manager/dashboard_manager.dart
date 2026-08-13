import 'package:flutter/material.dart';
import 'pipeline_screen.dart';

class DashboardManager extends StatefulWidget {
  const DashboardManager({Key? key}) : super(key: key);

  @override
  State<DashboardManager> createState() => _DashboardManagerState();
}

class _DashboardManagerState extends State<DashboardManager> {
  // Indeks untuk Bottom Navigation Bar (Beranda, Pipeline, Guest, Reports)
  int _currentIndex = 0;

  // State untuk Dropdown Filter Tipe Tamu
  String _selectedFilter = 'Semua';
  final List<String> _filterOptions = ['Semua', 'VIP', 'Reguler'];

  @override
  Widget build(BuildContext context) {
    // Simulasi data kunjungan lengkap dengan Jenis Kunjungan
    final List<Map<String, String>> daftarKunjunganManager = [
      {
        "token": "#TKN-001",
        "nama": "PT. Solusi Teknologi", 
        "tamu": "Budi Santoso",
        "waktu": "10:00 WIB", 
        "tipe": "VIP",
        "jenisKunjungan": "Meeting",
        "keperluan": "Konsultasi Sistem Enterprise",
        "pic": "Rian (Sales)",
        "status": "Sedang Meeting", 
        "warna": "hijau"
      },
      {
        "token": "#TKN-002",
        "nama": "CV. Maju Bersama", 
        "tamu": "Siti Aminah",
        "waktu": "11:30 WIB", 
        "tipe": "Reguler",
        "jenisKunjungan": "Konsultasi",
        "keperluan": "Demo Produk Kasir",
        "pic": "Siska (Sales)",
        "status": "Dikonfirmasi", 
        "warna": "biru"
      },
      {
        "token": "#TKN-003",
        "nama": "Mandiri Sejahtera", 
        "tamu": "Joko Widodo",
        "waktu": "13:30 WIB", 
        "tipe": "VIP",
        "jenisKunjungan": "Negosiasi",
        "keperluan": "Negosiasi Kontrak",
        "pic": "Ahmad (Sales)",
        "status": "Menunggu", 
        "warna": "kuning"
      },
      {
        "token": "#TKN-004",
        "nama": "UD. Berkah Jaya", 
        "tamu": "Dewi Lestari",
        "waktu": "14:00 WIB", 
        "tipe": "Reguler",
        "jenisKunjungan": "Pembayaran",
        "keperluan": "Pengambilan Dokumen",
        "pic": "Diana (Sales)",
        "status": "Selesai", 
        "warna": "abu"
      },
    ];

    // Filter data berdasarkan dropdown yang dipilih
    final filteredKunjungan = _selectedFilter == 'Semua'
        ? daftarKunjunganManager
        : daftarKunjunganManager.where((item) => item['tipe'] == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF006B3F), // Hijau Korporat Sesuai Tema
        elevation: 0,
        title: const Text(
          "Dashboard Manager - Executive View",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sapaan / Header Banner Manager
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF006B3F).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.admin_panel_settings, color: Color(0xFF006B3F), size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Selamat Pagi, Bapak Manager",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Pantau performa kunjungan dan lead bisnis hari ini.",
                          style: TextStyle(fontSize: 12, color: Color(0xFF778195)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // KARTU STATISTIK SEJAJAR 2 CARD
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: "Total Tamu Hari Ini",
                    value: "24",
                    subtext: "+12% dari kemarin",
                    icon: Icons.people_alt,
                    iconColor: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: "Potensi Lead Baru",
                    value: "+4",
                    subtext: "Dikonversi hari ini",
                    icon: Icons.trending_up,
                    iconColor: const Color(0xFF006B3F),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Judul Aktivitas Kunjungan
            const Text(
              "Aktivitas Kunjungan & Lead",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
            ),
            const SizedBox(height: 10),

            // CARD FILTER DROPDOWN
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.filter_alt_outlined, size: 18, color: Color(0xFF006B3F)),
                      SizedBox(width: 10),
                      Text(
                        "Filter Tipe Tamu:",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF778195)),
                      ),
                    ],
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedFilter,
                      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF006B3F)),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                      items: _filterOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value == 'Semua' ? 'Semua Tipe Tamu' : value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedFilter = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // List Kunjungan Manager
            filteredKunjungan.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        "Tidak ada data kunjungan untuk kategori ini.",
                        style: TextStyle(fontSize: 12, color: Color(0xFF778195)),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredKunjungan.length,
                    itemBuilder: (context, index) {
                      final item = filteredKunjungan[index];
                      
                      Color badgeColor;
                      Color textColor;
                      if (item["warna"] == "hijau") {
                        badgeColor = Colors.green.withOpacity(0.1);
                        textColor = Colors.green[700]!;
                      } else if (item["warna"] == "biru") {
                        badgeColor = Colors.blue.withOpacity(0.1);
                        textColor = Colors.blue[700]!;
                      } else if (item["warna"] == "kuning") {
                        badgeColor = Colors.orange.withOpacity(0.1);
                        textColor = Colors.orange[800]!;
                      } else {
                        badgeColor = Colors.grey.withOpacity(0.1);
                        textColor = Colors.grey[700]!;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Baris Atas: Token & Status
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item["token"]!,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF006B3F)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: badgeColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item["status"]!,
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            
                            // Perusahaan & Tipe Tamu (VIP / Reguler)
                            Row(
                              children: [
                                Text(
                                  item["nama"]!,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: item["tipe"] == "VIP" ? Colors.amber.withOpacity(0.15) : Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item["tipe"]!,
                                    style: TextStyle(
                                      fontSize: 9, 
                                      fontWeight: FontWeight.bold, 
                                      color: item["tipe"] == "VIP" ? Colors.amber[800] : Colors.blue[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            // Nama Tamu & Waktu
                            Text(
                              "Tamu: ${item["tamu"]} • ${item["waktu"]}",
                              style: const TextStyle(fontSize: 12, color: Color(0xFF778195)),
                            ),
                            const SizedBox(height: 4),

                            // Jenis Kunjungan
                            Row(
                              children: [
                                const Text(
                                  "Jenis Kunjungan: ",
                                  style: TextStyle(fontSize: 11, color: Color(0xFF778195)),
                                ),
                                Text(
                                  item["jenisKunjungan"]!,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF006B3F)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Garis Pemisah Tipis
                            const Divider(color: Color(0xFFE2E8F0), height: 12),

                            // Keperluan & PIC / Sales
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Keperluan: ${item["keperluan"]}",
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "PIC: ${item["pic"]}",
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF172033)),
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
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF006B3F),
        unselectedItemColor: const Color(0xFF778195),
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          // Logika pindah halaman Flutter saat navbar diklik
    if (index == 1) {
      // Jika tab 'Pipeline' diklik, buka PipelineScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PipelineScreen()),
      );
    }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline_rounded),
            label: 'Pipeline',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_rounded),
            label: 'Guest',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_rounded),
            label: 'Reports',
          ),
        ],
      ),
    );
  }

  // Widget pendukung untuk Card Statistik Sejajar
  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
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
              Text(
                title,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF778195)),
              ),
              Icon(icon, color: iconColor, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
          ),
          const SizedBox(height: 4),
          Text(
            subtext,
            style: TextStyle(fontSize: 10, color: iconColor, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}