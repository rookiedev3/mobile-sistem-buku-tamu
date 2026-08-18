// export_helper_web.dart
// Dipakai HANYA saat build/run di Flutter Web.
import 'dart:html' as html;

/// Buka tab kosong SYNCHRONOUS dulu (sebelum ada 'await' apapun),
/// supaya tidak kena popup blocker browser.
Object? prepareExportTab() {
  return html.window.open('', '_blank');
}

/// Setelah fileUrl didapat dari backend, arahkan tab yang sudah dibuka
/// ke fileUrl tsb -> browser otomatis mulai download.
Future<void> completeExport(Object? tabHandle, String url) async {
  final tab = tabHandle as html.WindowBase;
  tab.location.href = url;
}

/// Dipanggil kalau proses export gagal, supaya tab kosong tadi tidak
/// menggantung terbuka.
void closeExportTab(Object? tabHandle) {
  (tabHandle as html.WindowBase?)?.close();
}