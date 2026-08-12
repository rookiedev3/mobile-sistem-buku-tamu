import 'package:flutter/material.dart';
import 'dashboard_manager.dart';
import 'pipeline_screen.dart';

class DaftarKunjunganManagerScreen extends StatefulWidget {
  const DaftarKunjunganManagerScreen({Key? key}) : super(key: key);

  @override
  State<DaftarKunjunganManagerScreen> createState() => _DaftarKunjunganManagerScreenState();
}

class _DaftarKunjunganManagerScreenState extends State<DaftarKunjunganManagerScreen> {
  // Indeks 2 untuk menu Kunjungan pada Bottom Navigation Bar
  int _currentIndex = 2;

  // State untuk Filter & Pencarian
  String _searchQuery = '';
  String _selectedStatus = 'Semua';
  final List<String> _statusOptions = ['Semua', 'VIP', 'Reguler'];

  // Data Simulasi Arsip Kunjungan Tamu (No, Token, Tamu & Jabatan, Tanggal & Waktu, Jenis Kunjungan, Keperluan, Value, Catatan, Tahap Pipeline)
  final List<Map<String, dynamic>> _daftarArsip = [
    {
      "no": "1",
      "token": "#TKN-101",
      "tamu": "Budi Santoso\n(Direktur PT. Solusi Maju)",
      "waktu": "12 Ags 2026, 10:00 WIB",
      "jenis": "Demo Produk",
      "keperluan": "Presentasi Software POS & Kasir",
      "value": "Rp 45.000.000",
      "status": "VIP",
      "tahap": "Demo Produk",
      "catatan": "Klien sangat antusias dengan fitur laporan multi-cabang. Minta follow-up penawaran resmi."
    },
    {
      "no": "2",
      "token": "#TKN-102",
      "tamu": "Siti Aminah\n(Manager CV. Berkah)",
      "waktu": "12 Ags 2026, 11:30 WIB",
      "jenis": "Konsultasi",
      "keperluan": "Konsultasi Integrasi Sistem Keuangan",
      "value": "Rp 25.000.000",
      "status": "Reguler",
      "tahap": "Follow Up Lanjutan",
      "catatan": "Membutuhkan custom fitur ekspor data ke Excel untuk laporan bulanan internal."
    },
    {
      "no": "3",
      "token": "#TKN-103",
      "tamu": "Joko Widodo\n(Purchasing Mandiri)",
      "waktu": "11 Ags 2026, 14:00 WIB",
      "jenis": "Negosiasi",
      "keperluan": "Negosiasi Harga Paket Enterprise",
      "value": "Rp 60.000.000",
      "status": "VIP",
      "tahap": "Negosiasi",
      "catatan": "Diskusi alot mengenai diskon termin pembayaran 3 tahap. Deal disepakati."
    },
  ];

  // Fungsi Pop-Up Catatan
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
              Text("Catatan Arsip ($token)", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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
    // Filter data berdasarkan pencarian teks dan dropdown status
    final filteredArsip = _daftarArsip.where((item) {
      final matchesSearch = item['tamu'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item['token'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item['keperluan'].toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _selectedStatus == 'Semua' || item['status'] == _selectedStatus;
      return matchesSearch && matchesStatus;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF006B3F),
        elevation: 0,
        title: const Text(
          "Arsip Kunjungan Tamu",
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
            // BAGIAN 1: FILTER PENCARIAN & TANGGAL
            // ===================================================
            Container(
              padding: const EdgeInsets.all(14),
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
                children: [
                  // Input Pencarian Nama / Instansi
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Cari nama tamu atau instansi...",
                      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF778195)),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF006B3F), size: 20),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF4F7FC),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Baris Filter Tanggal & Dropdown Status
                  Row(
                    children: [
                      // Tombol Rentang Tanggal
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Membuka kalender filter tanggal...')),
                            );
                          },
                          icon: const Icon(Icons.date_range, size: 16, color: Color(0xFF006B3F)),
                          label: const Text("10 Ags - 12 Ags", style: TextStyle(fontSize: 11, color: Color(0xFF172033))),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Dropdown Status (VIP / Reguler)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F7FC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedStatus,
                            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF006B3F)),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                            items: _statusOptions.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value == 'Semua' ? 'Status: Semua' : value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedStatus = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Tombol "Catat" Kunjungan Baru (Bersih tanpa error)
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006B3F),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Membuka form pencatatan kunjungan baru...')),
                        );
                      },
                      child: const Text("Catat Kunjungan Baru", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Judul Daftar Arsip
            const Text(
              "Hasil Arsip Kunjungan",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
            ),
            const SizedBox(height: 12),

            // ===================================================
            // BAGIAN 2: CARD DAFTAR KUNJUNGAN
            // ===================================================
            filteredArsip.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: const Center(
                      child: Text("Tidak ada arsip kunjungan yang cocok.", style: TextStyle(fontSize: 12, color: Color(0xFF778195))),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredArsip.length,
                    itemBuilder: (context, index) {
                      final item = filteredArsip[index];
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
                            // Baris No, Token & Status VIP/Reguler
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
                                    color: item["status"] == "VIP" ? Colors.amber.withOpacity(0.15) : Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item["status"]!,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: item["status"] == "VIP" ? Colors.amber[800] : Colors.blue[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Tamu & Jabatan
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.person_outline_rounded, size: 14, color: Color(0xFF778195)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    "Tamu: ${item["tamu"]}",
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Tanggal & Waktu
                            Row(
                              children: [
                                const Icon(Icons.schedule_rounded, size: 14, color: Color(0xFF778195)),
                                const SizedBox(width: 6),
                                Text("Waktu: ${item["waktu"]}", style: const TextStyle(fontSize: 12, color: Color(0xFF778195))),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Jenis Kunjungan & Value
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.category_outlined, size: 14, color: Color(0xFF778195)),
                                    const SizedBox(width: 6),
                                    Text("Jenis: ${item["jenis"]}", style: const TextStyle(fontSize: 12, color: Color(0xFF778195))),
                                  ],
                                ),
                                Text(item["value"]!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF006B3F))),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Keperluan
                            Row(
                              children: [
                                const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF778195)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text("Keperluan: ${item["keperluan"]}", style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                                ),
                              ],
                            ),

                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                            ),

                            // Tahap Pipeline & Catatan (Pop-up)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1B65E3).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text("Tahap: ${item["tahap"]}", style: const TextStyle(color: Color(0xFF1B65E3), fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
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
      // BAGIAN 3: NAVBAR BAWAH
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PipelineScreen()),
            );
          } else if (index == 2) {
            // Sudah di halaman Daftar Kunjungan
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
}