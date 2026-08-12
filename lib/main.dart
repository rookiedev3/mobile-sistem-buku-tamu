import 'package:flutter/material.dart';
import 'package:mobile_sistem_buku_tamu/views/auth/homepage_screen.dart'; // Halaman awal pilihan (Tamu / Login)
import 'package:mobile_sistem_buku_tamu/views/auth/login_screen.dart'; // Halaman Login Pegawai

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
      // LANGSUNG ATUR HALAMAN UTAMA DI SINI TANPA PERLU IF-ELSE ATAU TOKEN CEK DULU
      home: const HomepageScreen(), 
    );
  }
}