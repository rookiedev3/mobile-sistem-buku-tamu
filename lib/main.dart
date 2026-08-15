import 'package:flutter/material.dart';
import 'package:mobile_flutter/ui/homepage_screen.dart';

import 'ui/manager/dashboard_manager.dart';
import 'ui/manager/daftar_kunjungan_manager_screen.dart';
import 'ui/manager/laporan_manager_screen.dart';
import 'ui/manager/pipeline_screen.dart';
import 'ui/manager/main_manager_navigator.dart';

import 'ui/admin/manajemen_pengguna_screen.dart';
import 'ui/admin/dashboard_admin_screen.dart';
import 'ui/admin/daftar_tamu_screen.dart';
import 'ui/admin/riwayat_screen.dart';
import 'ui/admin/janji_tamu_screen.dart';

import 'ui/pic/dashboard_pic_screen.dart';
import 'ui/pic/lead_pic_screen.dart';
import 'ui/pic/riwayat_pic_screen.dart';
import 'ui/pic/main_pic_navigator.dart';


import 'ui/owner/dashboard_owner_screen.dart';
import 'ui/owner/daftar_kunjungan_screen.dart';
import 'ui/owner/database_tamu_screen.dart';
import 'ui/owner/lead_screen.dart';
import 'ui/owner/laporan_screen.dart';
import 'ui/owner/main_owner_navigator.dart';

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