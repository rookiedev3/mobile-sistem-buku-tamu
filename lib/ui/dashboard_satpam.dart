import 'package:flutter/material.dart';

class DashboardSatpam extends StatelessWidget {
  const DashboardSatpam({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Simulasi data status tamu lengkap dengan Waktu Check-in dan Check-out
    final List<Map<String, String>> daftarTamu = [
      {
        "nama": "Budi Santoso", 
        "info": "Bertemu: Budi (Staff IT)", 
        "checkIn": "10:00 WIB", 
        "checkOut": "Menunggu", 
        "status": "Sedang Menunggu", 
        "warna": "kuning"
      },
      {
        "nama": "Siti Aminah", 
        "info": "Bertemu: Andi (Sales)", 
        "checkIn": "10:30 WIB", 
        "checkOut": "11:45 WIB", 
        "status": "Sedang Meeting", 
        "warna": "hijau"
      },
      {
        "nama": "Joko Widodo", 
        "info": "Bertemu: Dewi (Admin)", 
        "checkIn": "11:00 WIB", 
        "checkOut": "Menunggu", 
        "status": "Sedang Menunggu", 
        "warna": "kuning"
      },
      {
        "nama": "Rina Melati", 
        "info": "Bertemu: Budi (Staff IT)", 
        "checkIn": "13:00 WIB", 
        "checkOut": "14:15 WIB", 
        "status": "Selesai", 
        "warna": "abu"
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF006B3F),
        elevation: 0,
        title: const Text(
          "Dashboard Satpam - Pos Penjagaan",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              // Kembali ke halaman Login / Beranda
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sapaan & Status Pos
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF006B3F).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.security, color: Color(0xFF006B3F), size: 30),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Selamat Bertugas, Danru / Satpam",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Cabang: Sleman • Shift Pagi",
                        style: TextStyle(fontSize: 12, color: Color(0xFF778195)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Judul Daftar Tamu Hari Ini
            const Text(
              "Daftar Tamu Masuk Hari Ini",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
            ),
            const SizedBox(height: 12),

            // Daftar List Tamu dengan Waktu Check-in & Check-out
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: daftarTamu.length,
              itemBuilder: (context, index) {
                final tamu = daftarTamu[index];
                
                // Menentukan warna badge status
                Color badgeColor;
                Color textColor;
                if (tamu["warna"] == "hijau") {
                  badgeColor = Colors.green.withOpacity(0.1);
                  textColor = Colors.green[700]!;
                } else if (tamu["warna"] == "kuning") {
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
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF4F7FC),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person, color: Color(0xFF778195), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tamu["nama"]!,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                tamu["info"]!,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF778195)),
                              ),
                              const SizedBox(height: 6),
                              // Waktu Check-in & Check-out
                              Row(
                                children: [
                                  const Icon(Icons.login, size: 12, color: Colors.green),
                                  const SizedBox(height: 2, width: 4),
                                  Text(
                                    " Check In: ${tamu["checkIn"]}",
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF172033)),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.logout, size: 12, color: Colors.red),
                                  const SizedBox(width: 4),
                                  Text(
                                    " Check Out: ${tamu["checkOut"]}",
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF172033)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Badge Status Kunjungan
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tamu["status"]!,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor),
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
    );
  }
}