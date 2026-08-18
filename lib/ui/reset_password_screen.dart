import 'package:flutter/material.dart';
import 'dart:math' as math;

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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

          // 2. Motif Setengah Lingkaran Besar Tunggal di Background
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundArcsPainter(),
            ),
          ),

          // 3. Konten Tampilan Penuh
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo Perusahaan (Diperkecil agar lebih rapi)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/logo_perusahaan.jpg', // Sesuaikan jika format .png
                            width: 36,
                            height: 36,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Judul & Deskripsi
                      const Center(
                        child: Text(
                          "Reset Password Baru",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Center(
                        child: Text(
                          "Masukkan kata sandi baru untuk akun Anda.",
                          style: TextStyle(fontSize: 13, color: Colors.white70),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Form Password Baru
                      const Text(
                        "Password Baru",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _newPasswordController,
                        obscureText: _obscureNewPassword,
                        style: const TextStyle(color: Color(0xFF172033), fontSize: 13),
                        decoration: InputDecoration(
                          hintText: "Masukkan password baru",
                          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                              size: 18,
                              color: const Color(0xFF778195),
                            ),
                            onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Form Konfirmasi Password Baru
                      const Text(
                        "Konfirmasi Password Baru",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        style: const TextStyle(color: Color(0xFF172033), fontSize: 13),
                        decoration: InputDecoration(
                          hintText: "••••••••",
                          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                              size: 18,
                              color: const Color(0xFF778195),
                            ),
                            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Tombol Simpan Password Baru (Background #C7AB6B, Foreground Putih)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC7AB6B), // Warna background tombol baru
                            foregroundColor: Colors.white, // Warna teks putih
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            if (_newPasswordController.text != _confirmPasswordController.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Password baru dan konfirmasi tidak cocok!')),
                              );
                              return;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Password berhasil diatur ulang!')),
                            );
                          },
                          child: const Text(
                            "Simpan Password Baru",
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Tombol "Kembali" di Paling Bawah Sendiri
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.arrow_back_ios, size: 12, color: Colors.white60),
                              SizedBox(width: 4),
                              Text(
                                "Kembali",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white60,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter untuk Menggambar Setengah Lingkaran (Arc Tunggal) yang Elegan
class BackgroundArcsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final arcs = [
      {'x': size.width * 0.15, 'y': size.height * 0.2, 'r': 110.0, 'start': 0.0, 'sweep': math.pi, 'opacity': 0.12},
      {'x': size.width * 0.85, 'y': size.height * 0.3, 'r': 150.0, 'start': math.pi / 2, 'sweep': math.pi * 1.2, 'opacity': 0.08},
      {'x': size.width * 0.75, 'y': size.height * 0.8, 'r': 180.0, 'start': math.pi, 'sweep': math.pi, 'opacity': 0.1},
      {'x': size.width * 0.25, 'y': size.height * 0.75, 'r': 130.0, 'start': math.pi * 1.5, 'sweep': math.pi * 1.1, 'opacity': 0.14},
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
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}