import 'package:flutter/material.dart';
import 'package:mobile_flutter/helpers/user_info.dart';
import '/ui/homepage_screen.dart'; // ← sesuaikan path relatif/absolut sesuai lokasi file kamu

class LogoutBloc {
  // Logout "sungguhan" — hapus token & remember_me dari penyimpanan lokal.
  // Simpan untuk dipakai nanti kalau butuh tombol "Ganti Akun" atau logout permanen.
  static Future<void> logout() async {
    await UserInfo().logout();
  }

  // Logout "ringan" — kembali ke Homepage tanpa menghapus sesi tersimpan,
  // supaya tombol "Login Pegawai" masih bisa auto-masuk dashboard lagi.
  static void keluarKeHomepage(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomepageScreen()),
      (route) => false, // bersihkan semua stack navigasi sebelumnya
    );
  }
}