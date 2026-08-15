import 'package:flutter/material.dart';

// Import halaman khusus PIC sesuai path Anda
import 'dashboard_pic_screen.dart';
import 'lead_pic_screen.dart';
import 'riwayat_pic_screen.dart';

class MainPicNavigator extends StatefulWidget {
  const MainPicNavigator({Key? key}) : super(key: key);

  @override
  State<MainPicNavigator> createState() => _MainPicNavigatorState();
}

class _MainPicNavigatorState extends State<MainPicNavigator> {
  int _currentIndex = 0; // Indeks awal (0: Dashboard PIC)

  // Daftar list halaman PIC yang terhubung ke menu navbar bawah
  final List<Widget> _pages = [
    const DashboardPICScreen(),
    const LeadPICScreen(),
    const RiwayatPICScreen(),
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

      // 3 Navbar Bawah khusus Role PIC
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
            icon: Icon(Icons.trending_up_rounded, size: 16),
            label: 'Lead',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded, size: 16),
            label: 'Riwayat',
          ),
        ],
      ),
    );
  }
}