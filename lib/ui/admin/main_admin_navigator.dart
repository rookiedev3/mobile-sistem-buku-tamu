import 'package:flutter/material.dart';

import 'dashboard_admin_screen.dart';
import 'daftar_tamu_screen.dart';
import 'janji_tamu_screen.dart';
import 'riwayat_screen.dart';
import 'manajemen_pengguna_screen.dart';

class MainAdminNavigator extends StatefulWidget {
  const MainAdminNavigator({super.key});

  @override
  State<MainAdminNavigator> createState() => _MainAdminNavigatorState();
}

class _MainAdminNavigatorState extends State<MainAdminNavigator> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardAdminScreen(),
    DaftarTamuScreen(),
    JanjiTamuScreen(),
    RiwayatScreen(),
    ManajemenPenggunaScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    const Color corporateGreen = Color(0xFF006B3F);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
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
            icon: Icon(Icons.dashboard_rounded, size: 18),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_rounded, size: 18),
            label: 'Daftar Tamu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded, size: 18),
            label: 'Janji Tamu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded, size: 18),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts_rounded, size: 18),
            label: 'Pengguna',
          ),
        ],
      ),
    );
  }
}