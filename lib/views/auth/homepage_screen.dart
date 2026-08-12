import 'package:flutter/material.dart';
import 'package:mobile_sistem_buku_tamu/views/auth/login_screen.dart';

class HomepageScreen extends StatelessWidget {
  const HomepageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.all(36.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Perusahaan / Ikon Sistem
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF013220), // Hijau korporat
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.business_center, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 24),

                // Judul Utama
                const Text(
                  "Sistem Buku Tamu Digital",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172033),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Selamat datang! Silakan pilih akses masuk sesuai kebutuhan Anda di bawah ini.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.5, color: Color(0xFF778195), height: 1.4),
                ),
                const SizedBox(height: 36),

                // Tombol 1: Tamu / Check-in Mandiri
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006B3F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      // TODO: Arahkan ke Form Check-in Tamu Mandiri
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Navigasi ke Form Tamu (Segera Dibuat)')),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.person_outline, size: 20),
                        SizedBox(width: 10),
                        Text(
                          "Saya Tamu / Check-in",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tombol 2: Login Pegawai / Internal
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF006B3F), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // Pindah ke Halaman Login Pegawai
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.lock_outline, size: 20, color: Color(0xFF006B3F)),
                        SizedBox(width: 10),
                        Text(
                          "Login Pegawai / Karyawan",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF006B3F)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Catatan Kaki Kecil
                const Text(
                  "© 2026 IT Solution Corp",
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}