import 'package:flutter/material.dart';

class TamuFormStep4 extends StatelessWidget {
  const TamuFormStep4({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ikon Sukses Ceklis Hijau
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF006B3F).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF006B3F),
                    size: 64,
                  ),
                ),
                const SizedBox(height: 24),

                // Judul Berhasil
                const Text(
                  "Check-in Berhasil!",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172033),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Terima kasih telah mengisi buku tamu. Jadwal pertemuan Anda telah dicatat dalam sistem.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF778195), height: 1.4),
                ),
                const SizedBox(height: 24),

                // Kartu Informasi Jadwal Pertemuan
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F7FC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF006B3F).withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Jadwal Pertemuan Terkonfirmasi:",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006B3F),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: const [
                          Icon(Icons.calendar_today, size: 16, color: Color(0xFF778195)),
                          SizedBox(width: 8),
                          Text(
                            "Tanggal: 12-06-2026",
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: const [
                          Icon(Icons.access_time, size: 16, color: Color(0xFF778195)),
                          SizedBox(width: 8),
                          Text(
                            "Jam: 10:00 WIB",
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Tombol Selesai / Kembali ke Awal
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006B3F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      // Mengembalikan aplikasi langsung ke halaman paling awal (Homepage / Tahap 1)
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: const Text(
                      "Selesai",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}