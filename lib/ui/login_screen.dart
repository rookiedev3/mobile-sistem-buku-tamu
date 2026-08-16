import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'dashboard_satpam.dart';
import 'package:mobile_flutter/ui/manager/main_manager_navigator.dart';
import 'package:mobile_flutter/ui/owner/main_owner_navigator.dart';
import 'package:mobile_flutter/ui/pic/main_pic_navigator.dart';
import 'package:mobile_flutter/ui/admin/main_admin_navigator.dart';
import 'package:mobile_flutter/bloc/login_bloc.dart';
import 'package:mobile_flutter/helpers/user_info.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false; // Variabel state untuk Checkbox "Ingat Saya"

  @override
  void initState() {
    super.initState();
    _loadSavedEmail(); // ← TAMBAHAN: autofill email kalau sebelumnya "Ingat Saya" dicentang
  }

  // ← TAMBAHAN: ambil email tersimpan dari UserInfo jika remember_me sebelumnya true
  Future<void> _loadSavedEmail() async {
    final remembered = await UserInfo().getRememberMe();
    if (remembered) {
      final savedEmail = await UserInfo().getSavedEmail();
      if (savedEmail != null && mounted) {
        setState(() {
          _emailController.text = savedEmail;
          _rememberMe = true;
        });
      }
    }
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email dan password wajib diisi'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await LoginBloc.login(
        email: email,
        password: password,
        remember: _rememberMe, // ← TAMBAHAN: kirim flag remember ke bloc
      );

      await UserInfo().setToken(result.token ?? '');
      await UserInfo().setUserId(result.userID ?? 0);
      await UserInfo().setRememberMe(_rememberMe, email: email); // ← TAMBAHAN

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Selamat datang, ${result.userName ?? result.userEmail ?? ''}!',
          ),
        ),
      );

      _navigateByRole(result.userRole);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Navigasi berdasarkan role user
  void _navigateByRole(String? role) {
    switch (role) {
      case 'security':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DashboardSatpam(),
          ),
        );
        break;

      case 'admin':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MainAdminNavigator(),
          ),
        );
        break;

      case 'pic':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MainPicNavigator(),
          ),
        );
        break;

      case 'manager':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MainManagerNavigator(),
          ),
        );
        break;

      case 'owner':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MainOwnerNavigator(),
          ),
        );
        break;

      default:
        Navigator.pop(context);
        break;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                            'assets/images/logo_perusahaan.jpg',
                            width: 36, // Ukuran logo diperkecil
                            height: 36,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Judul & Deskripsi
                      const Center(
                        child: Text(
                          "Login Pegawai",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Center(
                        child: Text(
                          "Silakan masuk menggunakan akun internal Anda.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Form Input Email
                      const Text(
                        "Email",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Color(0xFF172033), fontSize: 13),
                        decoration: InputDecoration(
                          hintText: "Masukkan email Anda",
                          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Form Input Password
                      const Text(
                        "Password",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Color(0xFF172033), fontSize: 13),
                        decoration: InputDecoration(
                          hintText: "Masukkan password Anda",
                          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 18,
                              color: const Color(0xFF778195),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Baris Checkbox "Ingat Saya" & Tombol "Lupa Password?"
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Checkbox Ingat Saya
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                  activeColor: const Color(0xFFC7AB6B),
                                  checkColor: Colors.white,
                                  side: const BorderSide(color: Colors.white70, width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Ingat Saya",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),

                          // Tombol Lupa Password
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Lupa Password?",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Tombol Masuk
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
                          onPressed: _isLoading ? null : _handleLogin,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF006B3F),
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Masuk",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Footer Daftar Akun
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Belum punya akun? ",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Daftar",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Tombol Kembali ke Beranda
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.arrow_back_ios,
                                size: 12,
                                color: Colors.white60,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Kembali ke Beranda",
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