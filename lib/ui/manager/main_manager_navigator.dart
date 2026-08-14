import 'package:flutter/material.dart';

// Import keempat halaman menu manager sesuai path file Anda
import 'dashboard_manager.dart';
import 'daftar_kunjungan_manager_screen.dart';
import 'pipeline_screen.dart';
import 'laporan_manager_screen.dart';

class MainManagerNavigator extends StatefulWidget {
  const MainManagerNavigator({Key? key}) : super(key: key);

  @override
  State<MainManagerNavigator> createState() => _MainManagerNavigatorState();
}

class _MainManagerNavigatorState extends State<MainManagerNavigator> {
  int _currentIndex = 0; // Indeks awal (0: Dashboard Manager)

  // Daftar list halaman manager yang terhubung ke 4 menu navbar bawah
  final List<Widget> _pages = [
    const DashboardManager(),
    const DaftarKunjunganManagerScreen(),
    const PipelineScreen(),
    const LaporanManagerScreen(),
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

      // 4 Navbar Bawah khusus Role Manager
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
            label: 'Kunjungan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_rounded, size: 16),
            label: 'Pipeline',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_rounded, size: 16),
            label: 'Laporan',
          ),
        ],
      ),
    );
  }
}