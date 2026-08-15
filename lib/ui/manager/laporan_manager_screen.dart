import 'package:flutter/material.dart';

import '/bloc/laporan_bloc.dart';
import '/model/laporan_model.dart';
import 'dart:html' as html; // taruh di paling atas file, hanya jalan di web

class LaporanManagerScreen extends StatefulWidget {
  const LaporanManagerScreen({Key? key}) : super(key: key);

  @override
  State<LaporanManagerScreen> createState() => _LaporanManagerScreenState();
}

class _LaporanManagerScreenState extends State<LaporanManagerScreen> {
  final Color corporateGreen = const Color(0xFF006B3F);

  // State Filter Laporan
  String _selectedBulan = 'Agustus';
  String _selectedTahun = '2026';
  String _selectedKategori = 'Semua Kategori'; // VIP / Reguler
  String _selectedCabang = 'Semua Cabang';
  String _selectedPic = 'Semua PIC';

  final List<String> _bulanList = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];
  final List<String> _tahunList = ['2025', '2026', '2027'];
  final List<String> _kategoriList = ['Semua Kategori', 'VIP', 'Reguler'];

  List<String> _cabangList = ['Semua Cabang'];
  List<String> _picList = ['Semua PIC'];

  // Samain dengan $leadBadges di web (leads.status -> badge)
  static const Map<String, Map<String, dynamic>> _leadBadges = {
    'new':         {'bg': Color(0xFFF1F5F9), 'color': Color(0xFF475569), 'label': 'Baru'},
    'contacted':   {'bg': Color(0xFFDBEAFE), 'color': Color(0xFF1D4ED8), 'label': 'Dihubungi'},
    'negotiation': {'bg': Color(0xFFFEF3C7), 'color': Color(0xFFD97706), 'label': 'Negosiasi'},
    'deal':        {'bg': Color(0xFFDCFCE7), 'color': Color(0xFF15803D), 'label': 'Deal'},
    'lost':        {'bg': Color(0xFFFEE2E2), 'color': Color(0xFFB91C1C), 'label': 'Lost'},
  };

  // ================= STATE DATA DARI API =================
  LaporanResponse? _laporanResponse;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchLaporan();
  }

  Future<void> _fetchLaporan() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final bulanIndex = _bulanList.indexOf(_selectedBulan) + 1;
      final result = await LaporanBloc.fetch(
        month: bulanIndex,
        year: int.parse(_selectedTahun),
        category: _selectedKategori == 'Semua Kategori'
            ? ''
            : _selectedKategori.toLowerCase(),
      );

      setState(() {
        _laporanResponse = result;
        _cabangList = ['Semua Cabang', ...result.branches.map((b) => b.name)];
        _picList = ['Semua PIC', ...result.picUsers.map((p) => p.name)];
      });
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Reset Filter
  void _resetFilter() {
    setState(() {
      _selectedBulan = 'Agustus';
      _selectedTahun = '2026';
      _selectedKategori = 'Semua Kategori';
      _selectedCabang = 'Semua Cabang';
      _selectedPic = 'Semua PIC';
    });
    _fetchLaporan();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Filter laporan berhasil direset."), duration: Duration(milliseconds: 600)),
    );
  }

  // Aksi Tampilkan Preview -> ambil ulang data dari API sesuai filter aktif
  void _tampilkanPreview() {
    _fetchLaporan();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Menampilkan laporan periode $_selectedBulan $_selectedTahun..."), backgroundColor: corporateGreen, duration: const Duration(milliseconds: 800)),
    );
  }

  // Aksi Export Excel
  Future<void> _exportExcel() async {
    final newTab = html.window.open('', '_blank'); // buka tab KOSONG dulu, synchronous
    try {
      final bulanIndex = _bulanList.indexOf(_selectedBulan) + 1;
      final fileUrl = await LaporanBloc.exportExcel(
        month: bulanIndex,
        year: int.parse(_selectedTahun),
        category: _selectedKategori == 'Semua Kategori' ? '' : _selectedKategori.toLowerCase(),
      );
      newTab.location.href = fileUrl; // baru arahkan setelah URL didapat -> auto download
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Berhasil export Excel"), backgroundColor: Colors.teal),
        );
      }
    } catch (e) {
      newTab.close();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal export Excel: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Aksi Export PDF
  Future<void> _exportPdf() async {
    final newTab = html.window.open('', '_blank');
    try {
      final bulanIndex = _bulanList.indexOf(_selectedBulan) + 1;
      final fileUrl = await LaporanBloc.exportPdf(
        month: bulanIndex,
        year: int.parse(_selectedTahun),
        category: _selectedKategori == 'Semua Kategori' ? '' : _selectedKategori.toLowerCase(),
      );
      newTab.location.href = fileUrl;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Berhasil export PDF"), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      newTab.close();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal export PDF: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ================= HELPER FORMAT =================
  String _formatDateTime(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    try {
      final d = DateTime.parse(iso).toLocal();
      const bulanIndo = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      final jam = d.hour.toString().padLeft(2, '0');
      final menit = d.minute.toString().padLeft(2, '0');
      return '${d.day} ${bulanIndo[d.month - 1]} ${d.year}, $jam:$menit';
    } catch (_) {
      return iso;
    }
  }

  String _formatJamSaja(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    try {
      final d = DateTime.parse(iso).toLocal();
      final jam = d.hour.toString().padLeft(2, '0');
      final menit = d.minute.toString().padLeft(2, '0');
      return '$jam:$menit';
    } catch (_) {
      return '-';
    }
  }

  String _formatDurasi(int? menit) {
    if (menit == null) return '-';
    return '$menit Menit';
  }

  // Meniru logika status di web (riwayat.blade.php):
  // 1) status dibatalkan/cancelled/ditolak -> chip merah "Dibatalkan"
  // 2) sudah selesai (isCompleted) & punya leadStatus -> pakai _leadBadges
  // 3) sudah selesai tapi tidak ada leadStatus -> chip abu "Non-Lead"
  // 4) belum selesai -> chip kuning "Menunggu"
  Widget _buildStatusChip(LaporanItem item) {
    final statusLower = (item.status ?? '').toLowerCase();

    if (['cancelled', 'dibatalkan', 'ditolak'].contains(statusLower)) {
      return _statusPill(bg: const Color(0xFFFEF2F2), color: const Color(0xFFDC2626), label: 'Dibatalkan');
    }

    if (item.isCompleted && item.leadStatus != null && item.leadStatus!.isNotEmpty) {
      final b = _leadBadges[item.leadStatus] ?? _leadBadges['new']!;
      return _statusPill(bg: b['bg'] as Color, color: b['color'] as Color, label: b['label'] as String);
    }

    if (item.isCompleted) {
      return _statusPill(bg: const Color(0xFFF1F5F9), color: const Color(0xFF475569), label: 'Non-Lead');
    }

    return _statusPill(bg: const Color(0xFFFEF3C7), color: const Color(0xFFB45309), label: 'Menunggu');
  }

  Widget _statusPill({required Color bg, required Color color, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: color)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allData = _laporanResponse?.data ?? <LaporanItem>[];

    // Filter tambahan di client (kategori VIP/Reguler, cabang, PIC)
    final List<LaporanItem> filteredLaporan = allData.where((item) {
      final matchKategori = _selectedKategori == 'Semua Kategori' ||
          item.kategoriLabel == _selectedKategori;
      final matchCabang = _selectedCabang == 'Semua Cabang' ||
          item.branchName == _selectedCabang;
      final matchPic = _selectedPic == 'Semua PIC' || item.picName == _selectedPic;
      return matchKategori && matchCabang && matchPic;
    }).toList();

    final int totalKunjungan = filteredLaporan.length;
    final int totalDeal = filteredLaporan.where((i) => i.status == 'Deal').length;
    final int totalVip = filteredLaporan.where((i) => i.isVip).length;
    final double avgDurasi = _laporanResponse?.summary.avgDuration ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: corporateGreen,
        elevation: 0,
        title: const Text(
          "Laporan & Export Data Kunjungan",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _fetchLaporan),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchLaporan();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= 4 CARD STATISTIK LAPORAN =================
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 2.1,
                children: [
                  _buildStatCard("Total Kunjungan", "$totalKunjungan Tamu", Icons.groups_rounded, Colors.blue),
                  _buildStatCard("Total Deal", "$totalDeal Klien", Icons.task_alt_rounded, corporateGreen),
                  _buildStatCard("Rata-rata Durasi", "${avgDurasi.round()} Menit", Icons.timer_outlined, Colors.purple),
                  _buildStatCard("Tamu VIP", "$totalVip Orang", Icons.star_rounded, Colors.amber.shade800),
                ],
              ),
              const SizedBox(height: 12),

              // ================= FILTER PERIODE & PARAMETER =================
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Filter Periode & Parameter Laporan", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
                    const SizedBox(height: 8),

                    // Baris 1: Bulan & Tahun
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 32,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFE2E8F0))),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedBulan,
                                isDense: true,
                                style: const TextStyle(fontSize: 10, color: Color(0xFF172033)),
                                items: _bulanList.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                                onChanged: _isLoading
                                    ? null
                                    : (val) {
                                        setState(() => _selectedBulan = val!);
                                        _fetchLaporan();
                                      },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Container(
                            height: 32,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFE2E8F0))),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedTahun,
                                isDense: true,
                                style: const TextStyle(fontSize: 10, color: Color(0xFF172033)),
                                items: _tahunList.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                                onChanged: _isLoading
                                    ? null
                                    : (val) {
                                        setState(() => _selectedTahun = val!);
                                        _fetchLaporan();
                                      },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Baris 2: Kategori & Cabang
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 32,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFE2E8F0))),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedKategori,
                                isDense: true,
                                style: const TextStyle(fontSize: 10, color: Color(0xFF172033)),
                                items: _kategoriList.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                                onChanged: (val) => setState(() => _selectedKategori = val!),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Container(
                            height: 32,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFE2E8F0))),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedCabang,
                                isDense: true,
                                style: const TextStyle(fontSize: 10, color: Color(0xFF172033)),
                                items: _cabangList.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                                onChanged: _isLoading ? null : (val) => setState(() => _selectedCabang = val!),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Baris 3: PIC & Tombol Aksi (Tampilkan & Reset)
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 32,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFE2E8F0))),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedPic,
                                isDense: true,
                                style: const TextStyle(fontSize: 10, color: Color(0xFF172033)),
                                items: _picList.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                                onChanged: _isLoading ? null : (val) => setState(() => _selectedPic = val!),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        SizedBox(
                          height: 32,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: corporateGreen, padding: const EdgeInsets.symmetric(horizontal: 10), elevation: 0),
                            onPressed: _tampilkanPreview,
                            child: const Text("Tampilkan", style: TextStyle(fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 4),
                        SizedBox(
                          height: 32,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8), side: const BorderSide(color: Color(0xFFE2E8F0))),
                            onPressed: _resetFilter,
                            child: const Text("Reset", style: TextStyle(fontSize: 9.5, color: Colors.grey)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ================= TOMBOL EXPORT EXCEL & PDF =================
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 34,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, elevation: 0),
                        onPressed: _exportExcel,
                        icon: const Icon(Icons.table_chart_rounded, size: 14, color: Colors.white),
                        label: const Text("Export Excel", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 34,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, elevation: 0),
                        onPressed: _exportPdf,
                        icon: const Icon(Icons.picture_as_pdf_rounded, size: 14, color: Colors.white),
                        label: const Text("Export PDF", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ================= TABEL PREVIEW HASIL LAPORAN =================
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Preview Hasil Laporan", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
                        Text("$_selectedBulan $_selectedTahun", style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: corporateGreen)),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            Text(_errorMessage!, style: const TextStyle(fontSize: 11, color: Colors.red), textAlign: TextAlign.center),
                            const SizedBox(height: 8),
                            TextButton(onPressed: _fetchLaporan, child: const Text("Coba Lagi")),
                          ],
                        ),
                      )
                    else if (filteredLaporan.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(15.0),
                        child: Center(child: Text("Tidak ada data laporan untuk filter ini.", style: TextStyle(fontSize: 10, color: Colors.grey))),
                      )
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowHeight: 28,
                          dataRowHeight: 45,
                          columnSpacing: 10,
                          columns: const [
                            DataColumn(label: Text('No', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Waktu & Durasi', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Tamu & Kontak', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Cabang & PIC', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Tujuan & Product', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Sumber & Potensi', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Catatan Hasil', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Status', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                          ],
                          rows: List.generate(filteredLaporan.length, (index) {
                            final item = filteredLaporan[index];
                            return DataRow(cells: [
                              DataCell(Text((index + 1).toString(), style: const TextStyle(fontSize: 9))),
                              DataCell(Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("In: ${_formatDateTime(item.checkInAt)}", style: const TextStyle(fontSize: 8.5)),
                                  Text("Out: ${_formatJamSaja(item.checkOutAt)}", style: const TextStyle(fontSize: 8.5)),
                                  Text("Durasi: ${_formatDurasi(item.durasiMenit)}", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: corporateGreen)),
                                ],
                              )),
                              DataCell(Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(item.guestName ?? '-', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                  Text(item.guestPhone ?? '-', style: const TextStyle(fontSize: 8, color: Colors.grey)),
                                  if (item.companyName != null && item.companyName!.isNotEmpty)
                                    Text(item.companyName!, style: const TextStyle(fontSize: 8, color: Colors.grey, fontStyle: FontStyle.italic)),
                                ],
                              )),
                              DataCell(Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(item.branchName ?? '-', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600)),
                                  Text("PIC: ${item.picName ?? '-'}", style: const TextStyle(fontSize: 8, color: Colors.grey)),
                                ],
                              )),
                              DataCell(Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(item.purposeName ?? '-', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                  Text(item.productNames ?? '-', style: TextStyle(fontSize: 8, color: corporateGreen, fontWeight: FontWeight.bold)),
                                ],
                              )),
                              DataCell(Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(item.sourceName ?? '-', style: const TextStyle(fontSize: 9)),
                                  if (item.potentialLevel != null && item.potentialLevel!.isNotEmpty)
                                    Text("Potensi: ${item.potentialLevel}", style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.blue)),
                                ],
                              )),
                              DataCell(SizedBox(
                                width: 140,
                                child: Text(item.notes ?? '-', style: const TextStyle(fontSize: 8.5), overflow: TextOverflow.ellipsis, maxLines: 2),
                              )),
                              DataCell(_buildStatusChip(item)),
                            ]);
                          }),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Compact Card Statistik Laporan
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 3, offset: const Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
              Icon(icon, size: 14, color: color),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}