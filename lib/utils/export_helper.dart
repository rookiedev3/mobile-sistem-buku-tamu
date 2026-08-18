// export_helper.dart
// Ini file yang di-import oleh LaporanManagerScreen (atau screen lain
// yang butuh export Excel/PDF). Compiler otomatis memilih implementasi
// yang cocok dengan platform saat build:
//   - Flutter Web   -> export_helper_web.dart     (pakai dart:html)
//   - Android/iOS   -> export_helper_mobile.dart  (pakai url_launcher)
//   - lainnya       -> export_helper_stub.dart    (fallback)
//
// Taruh file ini bersama 3 file lain (export_helper_stub.dart,
// export_helper_web.dart, export_helper_mobile.dart) di folder yang sama,
// misalnya lib/utils/.

export 'export_helper_stub.dart'
    if (dart.library.html) 'export_helper_web.dart'
    if (dart.library.io) 'export_helper_mobile.dart';