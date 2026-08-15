import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:mobile_flutter/ui/homepage_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Mengatur durasi splash screen (misalnya 3 detik) sebelum otomatis pindah ke HomepageScreen
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomepageScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Gradasi Hijau Korporat
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF01281b), // #01281b (0%)
                  Color(0xFF013220), // #013220 (40%)
                  Color(0xFF006B3F), // #006B3F (100%)
                ],
                stops: [0.0, 0.4, 1.0],
              ),
            ),
          ),

          // 2. Motif Setengah Lingkaran Padat (Solid Fill) di Background
         // 2. Motif Setengah Lingkaran Besar Tunggal di Background
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundArcsPainter(),
            ),
          ),
          // 3. Konten Tengah: Logo Perusahaan & Nama Aplikasi
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Container untuk Logo Perusahaan
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(20), // Atur besar kelengkungan sudutnya di sini (misal: 20)
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/logo_perusahaan.jpg', // Ganti dengan path logo Anda di pubspec.yaml
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Judul / Nama Aplikasi
               
                const SizedBox(height: 8),
                const Text(
                  "Memuat aplikasi...",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 32),

                // Indikator Loading Putih
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                  strokeWidth: 2.5,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter untuk Menggambar Setengah Lingkaran Padat (Solid Fill)
class BackgroundSolidArcsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // List posisi dan ukuran setengah lingkaran background
    final arcs = [
      {'x': size.width * 0.15, 'y': size.height * 0.2, 'r': 120.0, 'start': 0.0, 'sweep': math.pi, 'opacity': 0.05},
      {'x': size.width * 0.85, 'y': size.height * 0.3, 'r': 160.0, 'start': math.pi / 2, 'sweep': math.pi, 'opacity': 0.04},
      {'x': size.width * 0.75, 'y': size.height * 0.8, 'r': 190.0, 'start': math.pi, 'sweep': math.pi, 'opacity': 0.05},
      {'x': size.width * 0.25, 'y': size.height * 0.75, 'r': 140.0, 'start': math.pi * 1.5, 'sweep': math.pi, 'opacity': 0.06},
    ];

    for (var a in arcs) {
      paint.color = Colors.white.withOpacity(a['opacity'] as double);
      
      final rect = Rect.fromCircle(
        center: Offset(a['x'] as double, a['y'] as double),
        radius: a['r'] as double,
      );
      
      canvas.drawArc(
        rect,
        a['start'] as double,
        a['sweep'] as double,
        true, // Menggunakan true agar membentuk setengah lingkaran padat penuh
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}