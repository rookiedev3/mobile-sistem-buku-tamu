import 'package:flutter/material.dart';

// Import halaman khusus Admin sesuai path Anda
import 'dashboard_admin_screen.dart';
import 'daftar_tamu_screen.dart';
import 'janji_tamu_screen.dart';
import 'riwayat_screen.dart';
import 'manajemen_pengguna_screen.dart';

class MainAdminNavigator extends StatefulWidget {
  const MainAdminNavigator({Key? key}) : super(key: key);

  @override
  State<MainAdminNavigator> createState() => _MainAdminNavigatorState();
}

class _MainAdminNavigatorState extends State<MainAdminNavigator> {
  int _currentIndex = 0; // Indeks awal (0: Dashboard Admin)

  // Daftar list halaman Admin yang terhubung ke 5 menu navbar bawah
  final List<Widget> _pages = [
    const DashboardAdminScreen(),
    const DaftarTamuScreen(),
    const JanjiTamuScreen(),
    const RiwayatScreen(),
    const ManajemenPenggunaScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    const Color corporateGreen = Color(0xFF006B3F);

    return Scaffold(
      // Menampilkan halaman sesuai indeks aktif dan menjaga state-nya tetap utuh
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      // 5 Navbar Bawah khusus Role Admin
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: corporateGreen,
        unselectedItemColor: const Color(0xFF778195),
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 9,
        unselectedFontSize: 9,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded, size: 16),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_rounded, size: 16),
            label: 'Daftar Tamu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded, size: 16),
            label: 'Janji Tamu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded, size: 16),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts_rounded, size: 16),
            label: 'Pengguna',
          ),
        ],
      ),
    );
  }
}