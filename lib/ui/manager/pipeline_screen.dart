import 'package:flutter/material.dart';
import 'dashboard_manager.dart';
import 'daftar_kunjungan_manager_screen.dart';

class PipelineScreen extends StatefulWidget {
  const PipelineScreen({Key? key}) : super(key: key);

  @override
  State<PipelineScreen> createState() => _PipelineScreenState();
}

class _PipelineScreenState extends State<PipelineScreen> {
  int _currentIndex = 1;
  
  // State untuk Filter Navbar di atas (Aktif, Terlambat, Hari Ini, Menunggu, Deal, Lost)
  String _selectedCategory = 'Aktif';
  final List<String> _categories = ['Aktif', 'Terlambat', 'Hari Ini', 'Menunggu', 'Deal', 'Lost'];

  // Data Simulasi Prospek / Lead
  final List<Map<String, dynamic>> _allProspects = [
    {
      "no": "1",
      "token": "#TKN-001",
      "tamu": "Budi Santoso\n(Direktur Utama)",
      "pic": "Rian (Sales)",
      "value": "Rp 45.000.000",
      "tgl": "14 Ags 2026",
      "tahap": "Demo Produk",
      "kategori": "Aktif",
      "catatan": "Klien tertarik dengan fitur integrasi sistem POS, minta dikirimkan penawaran harga resmi besok pagi."
    },
    {
      "no": "2",
      "token": "#TKN-002",
      "tamu": "Siti Aminah\n(Manager Operasional)",
      "pic": "Siska (Sales)",
      "value": "Rp 25.000.000",
      "tgl": "12 Ags 2026",
      "tahap": "Follow Up Lanjutan",
      "kategori": "Terlambat",
      "catatan": "Belum ada respons setelah dikirim proposal minggu lalu. Perlu dihubungi via WhatsApp ulang."
    },
    {
      "no": "3",
      "token": "#TKN-003",
      "tamu": "Joko Widodo\n(Purchasing)",
      "pic": "Ahmad (Sales)",
      "value": "Rp 60.000.000",
      "tgl": "13 Ags 2026",
      "tahap": "Negosiasi",
      "kategori": "Hari Ini",
      "catatan": "Jadwal meeting jam 14.00 WIB untuk membahas diskon pembelian borongan sistem ERP."
    },
    {
      "no": "4",
      "token": "#TKN-004",
      "tamu": "Dewi Lestari\n(Owner)",
      "pic": "Diana (Sales)",
      "value": "Rp 15.000.000",
      "tgl": "10 Ags 2026",
      "tahap": "Deal / Selesai",
      "kategori": "Deal",
      "catatan": "Kontrak sudah ditandatangani dan pembayaran DP 50% telah masuk ke rekening perusahaan."
    },
  ];

  // Fungsi untuk menampilkan Pop-Up Catatan
  void _showCatatanDialog(BuildContext context, String token, String catatan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Row(
            children: [
              const Icon(Icons.note_alt_rounded, color: Color(0xFF006B3F), size: 22),
              const SizedBox(width: 8),
              Text("Catatan Prospek ($token)", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            catatan,
            style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Tutup", style: TextStyle(color: Color(0xFF006B3F), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter data berdasarkan kategori navigasi atas
    final displayedProspects = _selectedCategory == 'Aktif'
        ? _allProspects
        : _allProspects.where((item) => item['kategori'] == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF006B3F),
        elevation: 0,
        title: const Text(
          "Lead & Pipeline Management",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===================================================
            // BAGIAN 1: KARTU STATISTIK (Total Prospek & Total Deal)
            // ===================================================
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: "Total Prospek Aktif",
                    value: "28",
                    icon: Icons.trending_up_rounded,
                    color: const Color(0xFF1B65E3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: "Total Deal",
                    value: "12",
                    icon: Icons.check_circle_outline_rounded,
                    color: const Color(0xFF006B3F),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ===================================================
            // BAGIAN 2: NAVBAR ATAS (Aktif, Terlambat, Hari Ini, Menunggu, Deal, Lost)
            // ===================================================
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      selectedColor: const Color(0xFF006B3F),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : const Color(0xFF778195),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFF006B3F) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Judul Daftar Prospek
            Text(
              "Daftar Prospek - $_selectedCategory",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF172033),
              ),
            ),
            const SizedBox(height: 12),

            // ===================================================
            // BAGIAN 3: DAFTAR KARTU PROSPEK
            // ===================================================
            displayedProspects.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: const Center(
                      child: Text("Tidak ada data prospek untuk kategori ini.", style: TextStyle(fontSize: 12, color: Color(0xFF778195))),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: displayedProspects.length,
                    itemBuilder: (context, index) {
                      final item = displayedProspects[index];
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
                            // Baris No & Token & Tahap Pipeline
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(4)),
                                      child: Text("No. ${item["no"]}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF778195))),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(item["token"]!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF006B3F))),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1B65E3).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(item["tahap"]!, style: const TextStyle(color: Color(0xFF1B65E3), fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Tamu & Jabatan
                            Row(
                              children: [
                                const Icon(Icons.person_outline_rounded, size: 14, color: Color(0xFF778195)),
                                const SizedBox(width: 6),
                                Text("Tamu: ", style: const TextStyle(fontSize: 12, color: Color(0xFF778195))),
                                Text(item["tamu"]!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // PIC / Sales & Value
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.badge_outlined, size: 14, color: Color(0xFF778195)),
                                    const SizedBox(width: 6),
                                    Text("PIC: ${item["pic"]}", style: const TextStyle(fontSize: 12, color: Color(0xFF778195))),
                                  ],
                                ),
                                Text(item["value"]!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF006B3F))),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Tanggal Follow Up
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF778195)),
                                const SizedBox(width: 6),
                                Text("Follow Up: ${item["tgl"]}", style: const TextStyle(fontSize: 12, color: Color(0xFF778195))),
                              ],
                            ),

                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                            ),

                            // Catatan (Bisa dipencet untuk memunculkan Pop-Up)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Catatan: ${item["catatan"]}",
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () => _showCatatanDialog(context, item["token"], item["catatan"]),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF006B3F).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text("Lihat Catatan", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF006B3F))),
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
      // BAGIAN 4: NAVBAR BAWAH
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardManager()),
            );
          } else if (index == 1) {
            // Berada di Pipeline
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DaftarKunjunganManagerScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Navigasi ke menu indeks $index (Segera Hadir)')),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.timeline_rounded), label: 'Pipeline'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'Kunjungan'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_rounded), label: 'Laporan'),
          BottomNavigationBarItem(icon: Icon(Icons.download_rounded), label: 'Eksport'),
        ],
      ),
    );
  }

  // Widget Kartu Statistik Atas
  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
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
              Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF778195), fontWeight: FontWeight.w500)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}