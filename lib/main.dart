import 'package:flutter/material.dart';
import 'package:mobile_flutter/ui/homepage_screen.dart';
import 'ui/manager/dashboard_manager.dart';
import 'ui/admin/manajemen_pengguna_screen.dart';
import 'ui/admin/dashboard_admin_screen.dart';

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
      home: const HomepageScreen(),
    );
  }
}