import 'package:flutter/material.dart';

// Import kelima halaman menu owner yang sudah kita buat sebelumnya
// Sesuaikan path import folder ini dengan struktur project Anda
import 'dashboard_owner_screen.dart';
import 'daftar_kunjungan_screen.dart';
import 'database_tamu_screen.dart';
import 'lead_screen.dart';
import 'laporan_screen.dart';

class MainOwnerNavigator extends StatefulWidget {
  const MainOwnerNavigator({Key? key}) : super(key: key);

  @override
  State<MainOwnerNavigator> createState() => _MainOwnerNavigatorState();
}

class _MainOwnerNavigatorState extends State<MainOwnerNavigator> {
  int _currentIndex = 0; // Indeks awal (0: Dashboard)

  // Daftar list halaman yang terhubung ke masing-masing menu navbar
  final List<Widget> _pages = [
    const DashboardOwnerScreen(),
    const DaftarKunjunganScreen(),
    const DatabaseTamuScreen(),
    const LeadScreen(),
    const LaporanScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    const Color corporateGreen = Color(0xFF006B3F);

    return Scaffold(
      // Menampilkan halaman sesuai indeks yang aktif saat ini
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      // 5 Navbar Bawah Korporat yang konsisten di semua halaman
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
            _currentIndex = index; // Mengubah indeks halaman saat navbar diklik
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
            icon: Icon(Icons.group_rounded, size: 16),
            label: 'Database',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_rounded, size: 16),
            label: 'Lead & FU',
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