import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'login_screen.dart';
import 'tamu_form_step1.dart';
import 'package:mobile_flutter/helpers/user_info.dart';
import 'package:mobile_flutter/bloc/me_bloc.dart';
import 'dashboard_satpam.dart';
import 'package:mobile_flutter/ui/manager/main_manager_navigator.dart';
import 'package:mobile_flutter/ui/owner/main_owner_navigator.dart';
import 'package:mobile_flutter/ui/pic/main_pic_navigator.dart';
import 'package:mobile_flutter/ui/admin/main_admin_navigator.dart';

class HomepageScreen extends StatelessWidget {
  const HomepageScreen({Key? key}) : super(key: key);

  // ← TAMBAHAN: dipanggil saat tombol "Login Pegawai" ditekan
  Future<void> _handleTombolLoginPegawai(BuildContext context) async {
    final rememberMe = await UserInfo().getRememberMe();
    final token = await UserInfo().getToken();

    // Tidak ada sesi tersimpan → langsung ke LoginScreen seperti biasa
    if (!rememberMe || token == null || token.isEmpty) {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
      return;
    }

    // Tampilkan loading kecil selagi validasi token ke server
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    try {
      final user = await MeBloc.getMe(token);
      if (!context.mounted) return;
      Navigator.pop(context); // tutup loading dialog
      _navigateByRole(context, user['role']);
    } catch (e) {
      // Token expired/invalid → bersihkan sesi, arahkan ke LoginScreen manual
      await UserInfo().clearSession();
      if (!context.mounted) return;
      Navigator.pop(context); // tutup loading dialog
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _navigateByRole(BuildContext context, String? role) {
    Widget target;
    switch (role) {
      case 'security':
        target = const DashboardSatpam();
        break;
      case 'admin':
        target = const MainAdminNavigator();
        break;
      case 'pic':
        target = const MainPicNavigator();
        break;
      case 'manager':
        target = const MainManagerNavigator();
        break;
      case 'owner':
        target = const MainOwnerNavigator();
        break;
      default:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
        return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => target),
    );
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
                  Color(0xFF01281b),
                  Color(0xFF013220),
                  Color(0xFF006B3F),
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

          // 3. Card Utama di Tengah — SELALU tampil normal, tidak ada pengecekan sesi di sini
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 36.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/logo_perusahaan.jpg',
                        width: 48,
                        height: 48,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 22),

                    const Text(
                      "Selamat Datang",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF006B3F),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const SizedBox(height: 6),
                    const Text(
                      "Silakan pilih jenis akses masuk Anda di bawah ini.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12.5, color: Color(0xFF778195)),
                    ),
                    const SizedBox(height: 32),

                    // Tombol 1: Check-in Tamu
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TamuFormStep1()),
                          );
                        },
                        child: const Text(
                          "Check-in Tamu",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Tombol 2: Login Pegawai — ← DIUBAH: cek sesi dulu sebelum navigasi
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC7AB6B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => _handleTombolLoginPegawai(context), // ← DIUBAH
                        child: const Text(
                          "Login Pegawai",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
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