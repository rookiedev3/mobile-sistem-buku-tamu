// export_helper_mobile.dart
// Dipakai HANYA saat build/run di Android, iOS, atau platform dart:io lain.
import 'package:url_launcher/url_launcher.dart';

/// Di mobile tidak ada konsep "tab baru", jadi tidak perlu apa-apa di sini.
Object? prepareExportTab() => null;

/// Buka fileUrl lewat browser/aplikasi eksternal di HP.
/// Browser HP yang akan menangani proses download filenya.
Future<void> completeExport(Object? tabHandle, String url) async {
  final uri = Uri.parse(url);
  final berhasil = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!berhasil) {
    throw Exception('Tidak bisa membuka file export di perangkat ini.');
  }
}

/// Tidak ada tab yang perlu ditutup di mobile.
void closeExportTab(Object? tabHandle) {}