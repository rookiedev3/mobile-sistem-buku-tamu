import 'package:flutter/material.dart';

class DatabaseTamuScreen extends StatefulWidget {
  const DatabaseTamuScreen({Key? key}) : super(key: key);

  @override
  State<DatabaseTamuScreen> createState() => _DatabaseTamuScreenState();
}

class _DatabaseTamuScreenState extends State<DatabaseTamuScreen> {
  final Color corporateGreen = const Color(0xFF006B3F);
  int _currentIndex = 2; // Index 2 untuk menu Database pada 5 Navbar Bawah

  final TextEditingController _searchController = TextEditingController();

  // Data Simulasi Database Tamu
  final List<Map<String, dynamic>> _databaseTamuList = [
    {
      "id": 1,
      "nama": "Budi Santoso",
      "kontak": "+62 812-3456-7890",
      "instansi": "PT Global Solusi",
      "jabatan": "Business Analyst",
      "kategoriTamu": "VIP", // VIP / Regular
      "minatProduk": "Software POS",
      "totalKunjungan": 3,
      "terakhirBerkunjung": "Selasa, 18 Agustus 2026",
      "timelineRiwayat": [
        {
          "waktu": "18 Agu 2026, 10:00 WIB",
          "pic": "Chyntia",
          "keperluan": "Demo lanjutan modul integrasi keuangan POS.",
          "status": "Terjadwal"
        },
        {
          "waktu": "10 Jul 2026, 13:30 WIB",
          "pic": "Budi",
          "keperluan": "Konsultasi awal kebutuhan software gudang.",
          "status": "Terjadwal"
        },
        {
          "waktu": "22 Jun 2026, 09:15 WIB",
          "pic": "Rian",
          "keperluan": "Penyerahan dokumen profil perusahaan.",
          "status": "Dibatalkan"
        }
      ]
    },
    {
      "id": 2,
      "nama": "Siti Aminah",
      "kontak": "+62 856-9876-5432",
      "instansi": "CV Konsultan Mandiri",
      "jabatan": "IT Consultant",
      "kategoriTamu": "Regular",
      "minatProduk": "ERP System",
      "totalKunjungan": 2,
      "terakhirBerkunjung": "Senin, 17 Agustus 2026",
      "timelineRiwayat": [
        {
          "waktu": "17 Agu 2026, 11:00 WIB",
          "pic": "Budi",
          "keperluan": "Diskusi implementasi modul inventaris.",
          "status": "Terjadwal"
        },
        {
          "waktu": "05 Agu 2026, 14:00 WIB",
          "pic": "Chyntia",
          "keperluan": "Pengenalan fitur sistem ERP.",
          "status": "Terjadwal"
        }
      ]
    },
  ];

  // Pop-up Detail & Timeline Riwayat Kunjungan Tamu
  void _showRiwayatPopup(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.history_rounded, size: 18, color: corporateGreen),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                "Riwayat: ${item["nama"]}",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 320,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Info Profil Singkat Tamu
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F7FC),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Jabatan : ${item["jabatan"]} - ${item["instansi"]}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text("WhatsApp: ${item["kontak"]}", style: const TextStyle(fontSize: 10, color: Colors.blueGrey)),
                      const SizedBox(height: 2),
                      Text("Minat Produk: ${item["minatProduk"]} | Kategori: ${item["kategoriTamu"]}", style: const TextStyle(fontSize: 9.5, color: Colors.grey)),
                      const SizedBox(height: 2),
                      Text("Total Kunjungan: ${item["totalKunjungan"]} Kali", style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: corporateGreen)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Judul Timeline
                const Text("Timeline Riwayat Kunjungan:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
                const SizedBox(height: 8),

                // List Timeline Riwayat
                ...List.generate((item["timelineRiwayat"] as List).length, (i) {
                  var riwayat = item["timelineRiwayat"][i];
                  bool isTerjadwal = riwayat["status"] == "Terjadwal";
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(riwayat["waktu"], style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: isTerjadwal ? Colors.green.shade50 : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                riwayat["status"],
                                style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: isTerjadwal ? Colors.green : Colors.red),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text("Bertemu PIC: ${riwayat["pic"]}", style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: corporateGreen)),
                        const SizedBox(height: 2),
                        Text("Keperluan: ${riwayat["keperluan"]}", style: const TextStyle(fontSize: 9.5, color: Color(0xFF172033))),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: corporateGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup", style: TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Logika Pencarian Tamu
    List filteredList = _databaseTamuList.where((item) {
      String query = _searchController.text.toLowerCase();
      return item['nama'].toLowerCase().contains(query) ||
          item['instansi'].toLowerCase().contains(query) ||
          item['minatProduk'].toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: corporateGreen,
        elevation: 0,
        title: const Text(
          "Database Tamu & Klien",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= SEARCH BAR COMPACT =================
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: SizedBox(
                height: 32,
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() {}),
                  style: const TextStyle(fontSize: 10),
                  decoration: InputDecoration(
                    hintText: "Cari nama tamu, instansi, atau minat produk...",
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
            const SizedBox(height: 14),

            // ================= TABEL DATABASE TAMU =================
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
                  const Text("Tabel Database Arsip Tamu", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
                  const SizedBox(height: 8),

                  filteredList.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Center(child: Text("Tidak ada data database tamu.", style: TextStyle(fontSize: 10, color: Colors.grey))),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowHeight: 28,
                            dataRowHeight: 40,
                            columnSpacing: 10,
                            columns: const [
                              DataColumn(label: Text('No', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Nama & Kontak', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Instansi / Perusahaan', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Minat Produk', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Total Kunjungan', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Terakhir Berkunjung', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Aksi Riwayat', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                            ],
                            rows: List.generate(filteredList.length, (index) {
                              final item = filteredList[index];
                              return DataRow(cells: [
                                DataCell(Text((index + 1).toString(), style: const TextStyle(fontSize: 9))),
                                DataCell(Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(item['nama'], style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                    Text(item['kontak'], style: const TextStyle(fontSize: 8, color: Colors.grey)),
                                  ],
                                )),
                                DataCell(Text(item['instansi'], style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600))),
                                DataCell(Text(item['minatProduk'], style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: corporateGreen))),
                                DataCell(Text("${item['totalKunjungan']} Kali", style: const TextStyle(fontSize: 9))),
                                DataCell(Text(item['terakhirBerkunjung'], style: const TextStyle(fontSize: 9))),
                                DataCell(ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade50,
                                    foregroundColor: Colors.blue,
                                    elevation: 0,
                                    minimumSize: const Size(50, 24),
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  ),
                                  onPressed: () => _showRiwayatPopup(context, item),
                                  child: const Text("Lihat Riwayat", style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold)),
                                )),
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
}