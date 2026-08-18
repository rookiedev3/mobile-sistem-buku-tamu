// export_helper_stub.dart
// Fallback default. Di-override otomatis oleh export_helper_web.dart
// (kalau dart.library.html tersedia -> Flutter Web) atau
// export_helper_mobile.dart (kalau dart.library.io tersedia -> Android/iOS/Desktop).
// File ini praktis tidak pernah benar-benar dieksekusi.

Object? prepareExportTab() => null;

Future<void> completeExport(Object? tabHandle, String url) async {
  throw UnsupportedError('Platform ini belum didukung untuk export.');
}

void closeExportTab(Object? tabHandle) {}