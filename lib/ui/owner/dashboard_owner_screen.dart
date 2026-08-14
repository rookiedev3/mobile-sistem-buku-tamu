import 'package:flutter/material.dart';
import 'produk_diminati_screen.dart';
import 'kategori_tamu_screen.dart';
import 'aktivitas_terbaru_screen.dart';

class DashboardOwnerScreen extends StatefulWidget {
  const DashboardOwnerScreen({Key? key}) : super(key: key);

  @override
  State<DashboardOwnerScreen> createState() => _DashboardOwnerScreenState();
}

class _DashboardOwnerScreenState extends State<DashboardOwnerScreen> {
  final Color corporateGreen = const Color(0xFF006B3F);
  int _currentIndex = 0; // 0: Dashboard Owner

  // Controller & Variabel Filter Tabel Kunjungan Hari Ini
  final TextEditingController _searchController = TextEditingController();
  String _filterStatus = 'Semua Status'; 
  String _filterPic = 'Semua PIC'; 

  // Data Simulasi Kunjungan Hari Ini
  final List<Map<String, dynamic>> _daftarKunjunganHariIni = [
    {
      "id": 1,
      "token": "TRX-001",
      "nama": "Budi Santoso",
      "jabatan": "Direktur PT Maju",
      "instansi": "PT Maju Sejahtera",
      "waktu": "10:00 WIB",
      "jenis": "Mitra",
      "keperluan": "Meeting Bisnis",
      "pic": "Chyntia",
      "catatan": "Meminta penawaran harga khusus paket software POS.",
      "statusKunjungan": "Meeting Selesai",
      "statusLead": "Deal",
    },
    {
      "id": 2,
      "token": "TRX-002",
      "nama": "Siti Aminah",
      "jabatan": "Consultant",
      "instansi": "CV Konsultan Mandiri",
      "waktu": "10:30 WIB",
      "jenis": "Prospek",
      "keperluan": "Konsultasi Sistem",
      "pic": "Budi",
      "catatan": "Diskusi implementasi modul inventaris gudang.",
      "statusKunjungan": "Menunggu",
      "statusLead": "Prospek",
    },
    {
      "id": 3,
      "token": "TRX-003",
      "nama": "Joko Widodo",
      "jabatan": "Manager Operasional",
      "instansi": "PT Inovasi Teknologi",
      "waktu": "11:15 WIB",
      "jenis": "Mitra",
      "keperluan": "Demo Produk ERP",
      "pic": "Chyntia",
      "catatan": "Tertarik dengan integrasi keuangan otomatis.",
      "statusKunjungan": "Terjadwal",
      "statusLead": "Warm",
    },
    {
      "id": 4,
      "token": "TRX-004",
      "nama": "Dewi Lestari",
      "jabatan": "HRD Lead",
      "instansi": "PT Sumber Talenta",
      "waktu": "13:00 WIB",
      "jenis": "Pelamar",
      "keperluan": "Wawancara Kerjasama",
      "pic": "Rian",
      "catatan": "Membahas pelatihan karyawan baru.",
      "statusKunjungan": "Dibatalkan",
      "statusLead": "Lost",
    },
  ];

  // Data Aktivitas Terbaru yang Diperkaya (Lengkap dengan Waktu, Warna Indikator, dan Status)
  final List<Map<String, dynamic>> _aktivitasList = [
    {
      "nama": "Hendri Setiawan", 
      "instansi": "PT Mitra Teknologi", 
      "status": "Status diubah: Meeting Selesai",
      "waktu": "10 min lalu",
      "color": Colors.green,
      "icon": Icons.check_circle_rounded
    },
    {
      "nama": "Rian Utama", 
      "instansi": "CV Berkah Jaya", 
      "status": "Status diubah: Menunggu Konfirmasi",
      "waktu": "25 min lalu",
      "color": Colors.orange,
      "icon": Icons.hourglass_top_rounded
    },
  ];

  // Fungsi Filter Card
  void _filterByCard(String jenisFilter, String nilai) {
    setState(() {
      if (jenisFilter == 'statusKunjungan') {
        _filterStatus = nilai;
      }
      _searchController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Menampilkan filter: $nilai", style: const TextStyle(fontSize: 10)),
        duration: const Duration(milliseconds: 700),
        backgroundColor: corporateGreen,
      ),
    );
  }

  // Reset Filter
  void _resetFilter() {
    setState(() {
      _searchController.clear();
      _filterStatus = 'Semua Status';
      _filterPic = 'Semua PIC';
    });
  }

  // Pop-up Detail Catatan
  void _showDetailCatatan(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.speaker_notes_rounded, size: 16, color: corporateGreen),
            const SizedBox(width: 6),
            Text("Catatan: ${item["nama"]}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Token: ${item["token"]} | PIC: ${item["pic"]}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
            const Divider(height: 12),
            const Text("Isi Catatan Kunjungan:", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(6)),
              child: Text(item["catatan"], style: const TextStyle(fontSize: 10, color: Color(0xFF172033))),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: corporateGreen, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4)),
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup", style: TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List filteredTabel = _daftarKunjunganHariIni.where((item) {
      String query = _searchController.text.toLowerCase();
      bool matchSearch = item['nama'].toLowerCase().contains(query) ||
          item['instansi'].toLowerCase().contains(query);

      bool matchStatus = (_filterStatus == 'Semua Status') || (item['statusKunjungan'] == _filterStatus);
      bool matchPic = (_filterPic == 'Semua PIC') || (item['pic'] == _filterPic);

      return matchSearch && matchStatus && matchPic;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: corporateGreen,
        elevation: 0,
        title: const Text(
          "Dashboard Owner",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Ringkasan Operasional Hari Ini", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
            const SizedBox(height: 8),

            // ================= 6 CARD UTAMA GRID =================
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.85, 
              children: [
                _buildCardStatistik(
                  title: "Total Tamu",
                  value: "24 Orang",
                  icon: Icons.groups_rounded,
                  color: Colors.blue,
                  onTap: () => _filterByCard('statusKunjungan', 'Semua Status'),
                ),
                _buildCardStatistik(
                  title: "Terjadwal",
                  value: "5 Orang",
                  icon: Icons.calendar_month_rounded,
                  color: Colors.orange,
                  onTap: () => _filterByCard('statusKunjungan', 'Terjadwal'),
                ),
                _buildCardStatistik(
                  title: "Selesai",
                  value: "14 Orang",
                  icon: Icons.task_alt_rounded,
                  color: Colors.green,
                  onTap: () => _filterByCard('statusKunjungan', 'Meeting Selesai'),
                ),
                _buildCardStatistik(
                  title: "Menjadi Lead",
                  value: "8 Lead",
                  icon: Icons.trending_up_rounded,
                  color: Colors.purple,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Menampilkan filter Lead aktif."), duration: Duration(milliseconds: 700)));
                  },
                ),
                _buildCardStatistik(
                  title: "Produk Diminati",
                  value: "Software POS",
                  icon: Icons.bar_chart_rounded,
                  color: Colors.teal,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProdukDiminatiScreen()));
                  },
                ),
                _buildCardStatistik(
                  title: "Kategori Tamu",
                  value: "Mitra / Prospek",
                  icon: Icons.pie_chart_rounded,
                  color: Colors.indigo,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const KategoriTamuScreen()));
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ================= CARD AKTIVITAS TERBARU (DIPERCANTIK DENGAN IKON & BADGE) =================
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AktivitasTerbaruScreen()));
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 3, offset: const Offset(0, 1))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.bolt_rounded, size: 16, color: corporateGreen),
                            const SizedBox(width: 4),
                            const Text("Aktivitas Terbaru", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
                          ],
                        ),
                      
                      ],
                    ),
                    const Divider(height: 12),

                    // List Item Aktivitas
                    ..._aktivitasList.asMap().entries.map((entry) {
                      int idx = entry.key;
                      Map log = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(bottom: idx == _aktivitasList.length - 1 ? 0 : 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(color: log["color"].withOpacity(0.1), shape: BoxShape.circle),
                              child: Icon(log["icon"], size: 12, color: log["color"]),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("${log["nama"]} (${log["instansi"]})", style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
                                      Text(log["waktu"], style: const TextStyle(fontSize: 8, color: Colors.grey)),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(4)),
                                    child: Text(log["status"], style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w600, color: log["color"])),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 6),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text("Lihat Semua Log Aktivitas >", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blue)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ================= TABEL KUNJUNGAN HARI INI =================
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Tabel Kunjungan Hari Ini", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
                  const SizedBox(height: 8),

                  // Search Bar & Filter Compact (Ditukar & Disamakan Ukurannya)
                  Row(
                    children: [
                      // Baris 1: Dropdown Status & Dropdown PIC
                      Expanded(
                        child: Container(
                          height: 32,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFE2E8F0))),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _filterStatus,
                              isDense: true,
                              style: const TextStyle(fontSize: 10, color: Color(0xFF172033)),
                              items: ['Semua Status', 'Menunggu', 'Terjadwal', 'Meeting Selesai', 'Dibatalkan'].map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                              onChanged: (val) => setState(() => _filterStatus = val!),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Container(
                          height: 32,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFE2E8F0))),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _filterPic,
                              isDense: true,
                              style: const TextStyle(fontSize: 10, color: Color(0xFF172033)),
                              items: ['Semua PIC', 'Chyntia', 'Budi', 'Rian'].map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                              onChanged: (val) => setState(() => _filterPic = val!),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  Row(
                    children: [
                      // Baris 2: Kolom Cari Nama Tamu & Tombol Reset dengan tinggi yang sama (32)
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: 32,
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) => setState(() {}),
                            style: const TextStyle(fontSize: 10),
                            decoration: InputDecoration(
                              hintText: "Cari nama tamu...",
                              prefixIcon: const Icon(Icons.search, size: 14, color: Colors.grey),
                              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                              filled: true,
                              fillColor: const Color(0xFFF4F7FC),
                              isDense: true,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        height: 32,
                        child: OutlinedButton.icon(
                          onPressed: _resetFilter,
                          icon: const Icon(Icons.refresh, size: 12, color: Colors.grey),
                          label: const Text("Reset", style: TextStyle(fontSize: 10, color: Colors.grey)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Tabel Data
                  filteredTabel.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Center(child: Text("Tidak ada data kunjungan.", style: TextStyle(fontSize: 10, color: Colors.grey))),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowHeight: 28,
                            dataRowHeight: 38,
                            columnSpacing: 10,
                            columns: const [
                              DataColumn(label: Text('No', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Token', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Tamu & Jabatan', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Waktu', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Jenis', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Keperluan', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('PIC', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Catatan', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Status Kunjungan', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Status Lead', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                            ],
                            rows: List.generate(filteredTabel.length, (index) {
                              final item = filteredTabel[index];
                              return DataRow(cells: [
                                DataCell(Text((index + 1).toString(), style: const TextStyle(fontSize: 9))),
                                DataCell(Text(item['token'], style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: corporateGreen))),
                                DataCell(Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(item['nama'], style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                    Text(item['jabatan'], style: const TextStyle(fontSize: 8, color: Colors.grey)),
                                  ],
                                )),
                                DataCell(Text(item['waktu'], style: const TextStyle(fontSize: 9))),
                                DataCell(Text(item['jenis'], style: const TextStyle(fontSize: 9))),
                                DataCell(Text(item['keperluan'], style: const TextStyle(fontSize: 9))),
                                DataCell(Text(item['pic'], style: const TextStyle(fontSize: 9))),
                                DataCell(InkWell(
                                  onTap: () => _showDetailCatatan(context, item),
                                  child: Row(
                                    children: const [
                                      Icon(Icons.speaker_notes, size: 12, color: Colors.blue),
                                      SizedBox(width: 2),
                                      Text("Lihat", style: TextStyle(fontSize: 9, color: Colors.blue, decoration: TextDecoration.underline)),
                                    ],
                                  ),
                                )),
                                DataCell(Text(item['statusKunjungan'], style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600))),
                                DataCell(Text(item['statusLead'], style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: corporateGreen))),
                              ]);
                            }),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ================= 5 NAVBAR BAWAH OWNER =================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: corporateGreen,
        unselectedItemColor: const Color(0xFF778195),
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 9,
        unselectedFontSize: 9,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded, size: 16), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_rounded, size: 16), label: 'Kunjungan'),
          BottomNavigationBarItem(icon: Icon(Icons.group_rounded, size: 16), label: 'Database'),
          BottomNavigationBarItem(icon: Icon(Icons.trending_up_rounded, size: 16), label: 'Lead & FU'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_rounded, size: 16), label: 'Laporan'),
        ],
      ),
    );
  }

  // Widget Compact Card Statistik
  Widget _buildCardStatistik({required String title, required String value, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 3, offset: const Offset(0, 1))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                Icon(icon, size: 14, color: color),
              ],
            ),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            const Text("Ketuk untuk filter", style: TextStyle(fontSize: 7, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}