import 'package:flutter/material.dart';

class LaporanManagerScreen extends StatefulWidget {
  const LaporanManagerScreen({Key? key}) : super(key: key);

  @override
  State<LaporanManagerScreen> createState() => _LaporanManagerScreenState();
}

class _LaporanManagerScreenState extends State<LaporanManagerScreen> {
  final Color corporateGreen = const Color(0xFF006B3F);

  // State Filter Laporan
  String _selectedBulan = 'Agustus';
  String _selectedTahun = '2026';
  String _selectedKategori = 'Semua Kategori'; // VIP / Reguler
  String _selectedCabang = 'Semua Cabang'; // Sleman / Magelang
  String _selectedPic = 'Semua PIC';

  final List<String> _bulanList = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];
  final List<String> _tahunList = ['2025', '2026', '2027'];
  final List<String> _kategoriList = ['Semua Kategori', 'VIP', 'Reguler'];
  final List<String> _cabangList = ['Semua Cabang', 'Sleman', 'Magelang'];
  final List<String> _picList = ['Semua PIC', 'Chyntia', 'Budi', 'Rian'];

  // Data Simulasi Laporan Kunjungan
  final List<Map<String, dynamic>> _laporanData = [
    {
      "no": 1,
      "checkIn": "14 Agu 2026, 09:00",
      "checkOut": "14 Agu 2026, 10:15",
      "durasi": "1 Jam 15 Menit",
      "nama": "Budi Santoso",
      "kontak": "+62 812-3456-7890",
      "cabang": "Sleman",
      "pic": "Chyntia",
      "tujuan": "Meeting Bisnis",
      "produk": "Software POS",
      "sumber": "Google",
      "potensi": "Hot",
      "catatanHasil": "Klien sepakat lanjut ke tahap penawaran harga enterprise.",
      "status": "Deal",
      "kategori": "VIP"
    },
    {
      "no": 2,
      "checkIn": "14 Agu 2026, 10:30",
      "checkOut": "14 Agu 2026, 11:10",
      "durasi": "40 Menit",
      "nama": "Siti Aminah",
      "kontak": "+62 856-9876-5432",
      "cabang": "Magelang",
      "pic": "Budi",
      "tujuan": "Konsultasi Sistem",
      "produk": "ERP System",
      "sumber": "LinkedIn",
      "potensi": "Lead",
      "catatanHasil": "Menunggu konfirmasi anggaran dari divisi keuangan.",
      "status": "Baru",
      "kategori": "Reguler"
    },
    {
      "no": 3,
      "checkIn": "13 Agu 2026, 13:00",
      "checkOut": "13 Agu 2026, 13:30",
      "durasi": "30 Menit",
      "nama": "Dewi Lestari",
      "kontak": "+62 813-1122-3344",
      "cabang": "Sleman",
      "pic": "Rian",
      "tujuan": "Wawancara",
      "produk": "HRIS Mobile",
      "sumber": "Instagram",
      "potensi": "Lead",
      "catatanHasil": "Jadwal dibatalkan karena pelamar berhalangan hadir.",
      "status": "Dibatalkan",
      "kategori": "Reguler"
    },
  ];

  // Reset Filter
  void _resetFilter() {
    setState(() {
      _selectedBulan = 'Agustus';
      _selectedTahun = '2026';
      _selectedKategori = 'Semua Kategori';
      _selectedCabang = 'Semua Cabang';
      _selectedPic = 'Semua PIC';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Filter laporan berhasil direset."), duration: Duration(milliseconds: 600)),
    );
  }

  // Aksi Tampilkan Preview
  void _tampilkanPreview() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Menampilkan laporan periode $_selectedBulan $_selectedTahun..."), backgroundColor: corporateGreen, duration: const Duration(milliseconds: 800)),
    );
  }

  // Aksi Export Excel
  void _exportExcel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Berhasil meng-export laporan ke format Excel (.xlsx)!"), backgroundColor: Colors.teal),
    );
  }

  // Aksi Export PDF
  void _exportPdf() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Berhasil meng-export laporan ke format PDF (.pdf)!"), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Logika Filter
    List filteredLaporan = _laporanData.where((item) {
      bool matchKategori = (_selectedKategori == 'Semua Kategori') || (item['kategori'] == _selectedKategori);
      bool matchCabang = (_selectedCabang == 'Semua Cabang') || (item['cabang'] == _selectedCabang);
      bool matchPic = (_selectedPic == 'Semua PIC') || (item['pic'] == _selectedPic);
      return matchKategori && matchCabang && matchPic;
    }).toList();

    int totalKunjungan = filteredLaporan.length;
    int totalDeal = filteredLaporan.where((i) => i['status'] == 'Deal').length;
    double conversionRate = totalKunjungan > 0 ? (totalDeal / totalKunjungan) * 100 : 0.0;
    int totalVip = filteredLaporan.where((i) => i['kategori'] == 'VIP').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: corporateGreen,
        elevation: 0,
        title: const Text(
          "Laporan & Export Data Kunjungan",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= 4 CARD STATISTIK LAPORAN =================
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.1,
              children: [
                _buildStatCard("Total Kunjungan", "$totalKunjungan Tamu", Icons.groups_rounded, Colors.blue),
                _buildStatCard("Total Deal", "$totalDeal Klien", Icons.task_alt_rounded, corporateGreen),
                _buildStatCard("Conversion Rate", "${conversionRate.toStringAsFixed(1)}%", Icons.trending_up_rounded, Colors.purple),
                _buildStatCard("Tamu VIP", "$totalVip Orang", Icons.star_rounded, Colors.amber.shade800),
              ],
            ),
            const SizedBox(height: 12),

            // ================= FILTER PERIODE & PARAMETER =================
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
                  const Text("Filter Periode & Parameter Laporan", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
                  const SizedBox(height: 8),

                  // Baris 1: Bulan & Tahun
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 32,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFE2E8F0))),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedBulan,
                              isDense: true,
                              style: const TextStyle(fontSize: 10, color: Color(0xFF172033)),
                              items: _bulanList.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                              onChanged: (val) => setState(() => _selectedBulan = val!),
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
                              value: _selectedTahun,
                              isDense: true,
                              style: const TextStyle(fontSize: 10, color: Color(0xFF172033)),
                              items: _tahunList.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                              onChanged: (val) => setState(() => _selectedTahun = val!),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Baris 2: Kategori & Cabang
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 32,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFE2E8F0))),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedKategori,
                              isDense: true,
                              style: const TextStyle(fontSize: 10, color: Color(0xFF172033)),
                              items: _kategoriList.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                              onChanged: (val) => setState(() => _selectedKategori = val!),
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
                              value: _selectedCabang,
                              isDense: true,
                              style: const TextStyle(fontSize: 10, color: Color(0xFF172033)),
                              items: _cabangList.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                              onChanged: (val) => setState(() => _selectedCabang = val!),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Baris 3: PIC & Tombol Aksi (Tampilkan & Reset)
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 32,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFE2E8F0))),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedPic,
                              isDense: true,
                              style: const TextStyle(fontSize: 10, color: Color(0xFF172033)),
                              items: _picList.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                              onChanged: (val) => setState(() => _selectedPic = val!),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        height: 32,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: corporateGreen, padding: const EdgeInsets.symmetric(horizontal: 10), elevation: 0),
                          onPressed: _tampilkanPreview,
                          child: const Text("Tampilkan", style: TextStyle(fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        height: 32,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8), side: const BorderSide(color: Color(0xFFE2E8F0))),
                          onPressed: _resetFilter,
                          child: const Text("Reset", style: TextStyle(fontSize: 9.5, color: Colors.grey)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ================= TOMBOL EXPORT EXCEL & PDF =================
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 34,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, elevation: 0),
                      onPressed: _exportExcel,
                      icon: const Icon(Icons.table_chart_rounded, size: 14, color: Colors.white),
                      label: const Text("Export Excel", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 34,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, elevation: 0),
                      onPressed: _exportPdf,
                      icon: const Icon(Icons.picture_as_pdf_rounded, size: 14, color: Colors.white),
                      label: const Text("Export PDF", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ================= TABEL PREVIEW HASIL LAPORAN =================
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Preview Hasil Laporan", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
                      Text("$_selectedBulan $_selectedTahun", style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: corporateGreen)),
                    ],
                  ),
                  const SizedBox(height: 8),

                  filteredLaporan.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Center(child: Text("Tidak ada data laporan untuk filter ini.", style: TextStyle(fontSize: 10, color: Colors.grey))),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowHeight: 28,
                            dataRowHeight: 45,
                            columnSpacing: 10,
                            columns: const [
                              DataColumn(label: Text('No', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Waktu & Durasi', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Tamu & Kontak', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Cabang & PIC', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Tujuan & Product', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Sumber & Potensi', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Catatan Hasil', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Status', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                            ],
                            rows: List.generate(filteredLaporan.length, (index) {
                              final item = filteredLaporan[index];
                              return DataRow(cells: [
                                DataCell(Text((index + 1).toString(), style: const TextStyle(fontSize: 9))),
                                DataCell(Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("In: ${item['checkIn']}", style: const TextStyle(fontSize: 8.5)),
                                    Text("Out: ${item['checkOut']}", style: const TextStyle(fontSize: 8.5)),
                                    Text("Durasi: ${item['durasi']}", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: corporateGreen)),
                                  ],
                                )),
                                DataCell(Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(item['nama'], style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                    Text(item['kontak'], style: const TextStyle(fontSize: 8, color: Colors.grey)),
                                  ],
                                )),
                                DataCell(Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(item['cabang'], style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600)),
                                    Text("PIC: ${item['pic']}", style: const TextStyle(fontSize: 8, color: Colors.grey)),
                                  ],
                                )),
                                DataCell(Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(item['tujuan'], style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                    Text(item['produk'], style: TextStyle(fontSize: 8, color: corporateGreen, fontWeight: FontWeight.bold)),
                                  ],
                                )),
                                DataCell(Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(item['sumber'], style: const TextStyle(fontSize: 9)),
                                    Text("Potensi: ${item['potensi']}", style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.blue)),
                                  ],
                                )),
                                DataCell(SizedBox(
                                  width: 140,
                                  child: Text(item['catatanHasil'], style: const TextStyle(fontSize: 8.5), overflow: TextOverflow.ellipsis, maxLines: 2),
                                )),
                                DataCell(Text(item['status'], style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: item['status'] == 'Deal' ? corporateGreen : (item['status'] == 'Baru' ? Colors.blue : Colors.red)))),
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

     
    );
  }

  // Widget Compact Card Statistik Laporan
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
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
        ],
      ),
    );
  }
}