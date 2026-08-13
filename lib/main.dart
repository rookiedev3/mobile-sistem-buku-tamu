import 'package:flutter/material.dart';
// import 'package:mobile_flutter/ui/homepage_screen.dart'; // Sesuaikan jika diletakkan di folder ui/
import 'package:mobile_flutter/ui/homepage_screen.dart'; // Impor halaman utama buatanmu
import 'ui/manager/dashboard_manager.dart'; // <-- Impor dashboard manager (atau satpam) yang mau kamu lihat
import 'ui/admin/manajemen_pengguna_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buku Tamu Digital',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Plus Jakarta Sans',
      ),
      // Langsung arahkan ke HomepageScreen sebagai pintu utama aplikasi
      home: const HomepageScreen(),
    );
  }
}