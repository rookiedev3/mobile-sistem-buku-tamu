import 'package:flutter/material.dart';

class RiwayatPICScreen extends StatefulWidget {
  const RiwayatPICScreen({Key? key}) : super(key: key);

  @override
  State<RiwayatPICScreen> createState() => _RiwayatPICScreenState();
}

class _RiwayatPICScreenState extends State<RiwayatPICScreen> {
  final Color corporateGreen = const Color(0xFF006B3F);

  
  // Controller Pencarian & Filter
  final TextEditingController _searchController = TextEditingController();
  String _filterStatus = 'Semua Kategori'; // Semua Kategori / VIP / Reguler
  String _dariTanggal = '';
  String _sampaiTanggal = '';

  // Data Simulasi Arsip Riwayat Kunjungan Tamu (Tanpa Keterangan PIC)
  final List<Map<String, dynamic>> _daftarRiwayat = [
    {
      "id": 1,
      "token": "TRX-RWT-01",
      "nama": "Budi Santoso",
      "jabatan": "Direktur PT Maju",
      "instansi": "PT Maju Sejahtera",
      "kategori": "VIP",
      "waktu": "13 Agu 2026, 10:00 WIB",
      "tanggal": "2026-08-13",
      "keperluan": "Meeting Bisnis",
      "tahapPipeline": "Deal",
      "keteranganStatus": "Selesai & Deal Klien",
      "catatanAwal": "Meminta penawaran harga khusus paket software POS.",
      "riwayatPipeline": [
        {"tanggal": "2026-08-13", "tahap": "Baru", "catatan": "Pertemuan pertama."},
        {"tanggal": "2026-08-13", "tahap": "Deal", "catatan": "Keluarga menyetujui kontrak."}
      ],
      "statusAkhir": "Baru", // Baru / Dibatalkan
    },
    {
      "id": 2,
      "token": "TRX-RWT-02",
      "nama": "Siti Aminah",
      "jabatan": "Consultant",
      "instansi": "CV Konsultan Mandiri",
      "kategori": "Reguler",
      "waktu": "11 Agu 2026, 14:15 WIB",
      "tanggal": "2026-08-11",
      "keperluan": "Konsultasi",
      "tahapPipeline": "Lost",
      "keteranganStatus": "Dibatalkan oleh Klien",
      "catatanAwal": "Konsultasi sistem manajemen inventaris.",
      "riwayatPipeline": [
        {"tanggal": "2026-08-11", "tahap": "Lost", "catatan": "Jadwal dibatalkan karena ada kendala mendadak."}
      ],
      "statusAkhir": "Dibatalkan",
    },
  ];

  // Pop-up Detail Catatan & Riwayat Kunjungan
  void _showDetailCatatanDialog(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.history_edu_rounded, size: 18, color: corporateGreen),
            const SizedBox(width: 8),
            Text("Detail Kunjungan: ${item["nama"]}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _infoRow("Token:", item["token"]),
              _infoRow("Instansi:", item["instansi"]),
              const Divider(height: 16),
              _infoRow("Tahap Pipeline Terakhir:", item["tahapPipeline"], isBold: true),
              _infoRow("Keterangan Status:", item["keteranganStatus"], isBold: true),
              const SizedBox(height: 8),
              const Text("Catatan Pertemuan Awal:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(6)),
                child: Text(item["catatanAwal"], style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
              ),
              const SizedBox(height: 8),
              const Text("Riwayat Update Pipeline:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
              const SizedBox(height: 4),
              ...((item["riwayatPipeline"] as List).map((riwayat) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(6)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Tgl: ${riwayat["tanggal"]} • Tahap: ${riwayat["tahap"]}", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: corporateGreen)),
                      const SizedBox(height: 2),
                      Text(riwayat["catatan"], style: const TextStyle(fontSize: 10, color: Color(0xFF172033))),
                    ],
                  ),
                );
              }).toList()),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: corporateGreen, foregroundColor: Colors.white, elevation: 0),
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup", style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF778195))),
          Text(value, style: TextStyle(fontSize: 11, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: const Color(0xFF172033))),
        ],
      ),
    );
  }

  // Fungsi Pilih Tanggal Filter
  Future<void> _pilihTanggal(BuildContext context, bool isDari) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: corporateGreen, onPrimary: Colors.white, onSurface: const Color(0xFF172033)),
          ),
          child: MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(0.85)), child: child!),
        );
      },
    );
    if (picked != null) {
      setState(() {
        String formatted = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        if (isDari) {
          _dariTanggal = formatted;
        } else {
          _sampaiTanggal = formatted;
        }
      });
    }
  }

  // Reset Filter
  void _resetFilter() {
    setState(() {
      _searchController.clear();
      _filterStatus = 'Semua Kategori';
      _dariTanggal = '';
      _sampaiTanggal = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    // Logika Filter & Pencarian Data Riwayat (Berdasarkan Nama atau Instansi)
    List filteredList = _daftarRiwayat.where((item) {
      String query = _searchController.text.toLowerCase();
      bool matchSearch = item['nama'].toLowerCase().contains(query) ||
          item['instansi'].toLowerCase().contains(query);

      bool matchStatus = true;
      if (_filterStatus == 'VIP') matchStatus = item['kategori'] == 'VIP';
      if (_filterStatus == 'Reguler') matchStatus = item['kategori'] == 'Reguler';

      bool matchTanggal = true;
      if (_dariTanggal.isNotEmpty && _sampaiTanggal.isNotEmpty) {
        matchTanggal = item['tanggal'].compareTo(_dariTanggal) >= 0 && item['tanggal'].compareTo(_sampaiTanggal) <= 0;
      } else if (_dariTanggal.isNotEmpty) {
        matchTanggal = item['tanggal'].compareTo(_dariTanggal) >= 0;
      } else if (_sampaiTanggal.isNotEmpty) {
        matchTanggal = item['tanggal'].compareTo(_sampaiTanggal) <= 0;
      }

      return matchSearch && matchStatus && matchTanggal;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: corporateGreen,
        elevation: 0,
        title: const Text(
          "Front Office - Riwayat Kunjungan",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Pencarian & Filter Lengkap
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Filter & Pencarian Arsip Kunjungan", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
                  const SizedBox(height: 8),

                  // Search Bar berdasarkan Nama / Instansi
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() {}),
                    style: const TextStyle(fontSize: 11),
                    decoration: InputDecoration(
                      hintText: "Cari nama tamu atau instansi...",
                      hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                      prefixIcon: const Icon(Icons.search, size: 16, color: Color(0xFF778195)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      filled: true,
                      fillColor: const Color(0xFFF4F7FC),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Filter Tanggal & Status (VIP / Reguler)
                  Row(
                    children: [
                      // Dari Tanggal
                      Expanded(
                        child: InkWell(
                          onTap: () => _pilihTanggal(context, true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F7FC),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 12, color: Color(0xFF778195)),
                                const SizedBox(width: 4),
                                Text(_dariTanggal.isEmpty ? "Dari Tgl" : _dariTanggal, style: const TextStyle(fontSize: 10, color: Color(0xFF172033))),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Sampai Tanggal
                      Expanded(
                        child: InkWell(
                          onTap: () => _pilihTanggal(context, false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F7FC),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 12, color: Color(0xFF778195)),
                                const SizedBox(width: 4),
                                Text(_sampaiTanggal.isEmpty ? "Sampai Tgl" : _sampaiTanggal, style: const TextStyle(fontSize: 10, color: Color(0xFF172033))),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Dropdown Status VIP / Reguler
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F7FC),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _filterStatus,
                            isDense: true,
                            style: const TextStyle(fontSize: 10, color: Color(0xFF172033), fontWeight: FontWeight.bold),
                            items: ['Semua Kategori', 'VIP', 'Reguler'].map((String val) {
                              return DropdownMenuItem<String>(value: val, child: Text(val));
                            }).toList(),
                            onChanged: (String? val) {
                              if (val != null) setState(() => _filterStatus = val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Tombol Reset Filter
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: _resetFilter,
                      icon: const Icon(Icons.refresh, size: 12, color: Colors.grey),
                      label: const Text("Reset Filter", style: TextStyle(fontSize: 10, color: Color(0xFF778195))),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        minimumSize: const Size(60, 24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Daftar List Riwayat Kunjungan
            filteredList.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Text("Tidak ada arsip riwayat kunjungan yang ditemukan.", style: TextStyle(color: Color(0xFF778195), fontSize: 11)),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      bool isDibatalkan = item["statusAkhir"] == "Dibatalkan";

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
                                  child: Text("Token: ${item["token"]}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF006B3F))),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isDibatalkan ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item["statusAkhir"],
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isDibatalkan ? Colors.red[700] : Colors.green[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(item["nama"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF172033))),
                            Text("${item["jabatan"]} • ${item["instansi"]}", style: const TextStyle(fontSize: 10, color: Color(0xFF778195))),
                            const SizedBox(height: 4),
                            Text("Waktu: ${item["waktu"]}", style: const TextStyle(fontSize: 10, color: Color(0xFF006B3F), fontWeight: FontWeight.w600)),
                            Text("Keperluan: ${item["keperluan"]}", style: const TextStyle(fontSize: 10, color: Color(0xFF778195))),
                            const SizedBox(height: 6),

                            // Kolom Catatan (Pop-up detail riwayat)
                            InkWell(
                              onTap: () => _showDetailCatatanDialog(context, item),
                              child: Row(
                                children: const [
                                  Icon(Icons.speaker_notes_rounded, size: 13, color: Colors.blue),
                                  SizedBox(width: 4),
                                  Text("Lihat Detail Catatan & Riwayat", style: TextStyle(fontSize: 10, color: Colors.blue, decoration: TextDecoration.underline)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),

      // ================= NAVBAR BAWAH FRONT OFFICE (3 MENU) =================
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: _currentIndex,
      //   selectedItemColor: corporateGreen,
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
      //       Navigator.pop(context);
      //     } else if (index == 1) {
      //       Navigator.pop(context);
      //     } else if (index == 2) {
      //       // Sedang di halaman Riwayat
      //     }
      //   },
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded, size: 20), label: 'Dashboard'),
      //     BottomNavigationBarItem(icon: Icon(Icons.trending_up_rounded, size: 20), label: 'Lead'),
      //     BottomNavigationBarItem(icon: Icon(Icons.history_rounded, size: 20), label: 'Riwayat'),
      //   ],
      // ),
    );
  }
}