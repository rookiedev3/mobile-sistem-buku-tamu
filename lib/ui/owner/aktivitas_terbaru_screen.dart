import 'package:flutter/material.dart';

class AktivitasTerbaruScreen extends StatefulWidget {
  const AktivitasTerbaruScreen({Key? key}) : super(key: key);

  @override
  State<AktivitasTerbaruScreen> createState() => _AktivitasTerbaruScreenState();
}

class _AktivitasTerbaruScreenState extends State<AktivitasTerbaruScreen> {
  final Color corporateGreen = const Color(0xFF006B3F);
  final TextEditingController _searchController = TextEditingController();

  // Data aktivitas dengan format yang sama persis seperti di card dashboard
  final List<Map<String, dynamic>> _aktivitasList = [
    {
      "nama": "Hendri Setiawan",
      "instansi": "PT Mitra Teknologi",
      "status": "Status diubah menjadi meeting",
      "waktu": "14 Agu 2026, 11:15 WIB",
      "color": Colors.green,
      "icon": Icons.check_circle_rounded
    },
    {
      "nama": "Rian Utama",
      "instansi": "CV Berkah Jaya",
      "status": "Status diubah: Menunggu Konfirmasi",
      "waktu": "14 Agu 2026, 10:30 WIB",
      "color": Colors.orange,
      "icon": Icons.hourglass_top_rounded
    },
    {
      "nama": "Budi Santoso",
      "instansi": "PT Maju Sejahtera",
      "status": "Check-in (VIP) bertemu Chyntia",
      "waktu": "14 Agu 2026, 09:45 WIB",
      "color": const Color(0xFF006B3F),
      "icon": Icons.login_rounded
    },
    {
      "nama": "Siti Aminah",
      "instansi": "CV Konsultan Mandiri",
      "status": "Membuat jadwal janji temu baru",
      "waktu": "14 Agu 2026, 09:00 WIB",
      "color": Colors.blue,
      "icon": Icons.calendar_today_rounded
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Logika pencarian reaktif
    List filteredList = _aktivitasList.where((item) {
      String query = _searchController.text.toLowerCase();
      return item['nama'].toLowerCase().contains(query) ||
          item['instansi'].toLowerCase().contains(query) ||
          item['status'].toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: corporateGreen,
        elevation: 0,
        title: const Text(
          "Log Aktivitas Terbaru",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar Compact khusus Mobile
            TextField(
              controller: _searchController,
              onChanged: (val) => setState(() {}),
              style: const TextStyle(fontSize: 10.5),
              decoration: InputDecoration(
                hintText: "Cari nama tamu, instansi, atau status...",
                prefixIcon: const Icon(Icons.search, size: 14, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                filled: true,
                fillColor: Colors.white,
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),

            const Text(
              "Riwayat Aktivitas Sistem Real-Time",
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
            ),
            const SizedBox(height: 8),

            // Daftar List Aktivitas dengan Ukuran Pas Anti-Overflow
            Expanded(
              child: filteredList.isEmpty
                  ? const Center(
                      child: Text("Tidak ada aktivitas yang ditemukan.", style: TextStyle(color: Colors.grey, fontSize: 10)),
                    )
                  : ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: item["color"].withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(item["icon"], size: 14, color: item["color"]),
                              ),
                              const SizedBox(width: 8),
                              
                              // Menggunakan Expanded agar teks otomatis menyesuaikan lebar layar HP tanpa overflow
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "${item["nama"]} (${item["instansi"]})",
                                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          item["waktu"],
                                          style: const TextStyle(fontSize: 8.5, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF4F7FC),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        item["status"],
                                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: item["color"]),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}