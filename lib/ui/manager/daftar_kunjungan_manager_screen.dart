import 'package:flutter/material.dart';

import '/bloc/kunjungan_bloc.dart';
import '/model/kunjungan.dart';

class DaftarKunjunganManagerScreen extends StatefulWidget {
  const DaftarKunjunganManagerScreen({Key? key}) : super(key: key);

  @override
  State<DaftarKunjunganManagerScreen> createState() => _DaftarKunjunganManagerScreenState();
}

class _DaftarKunjunganManagerScreenState extends State<DaftarKunjunganManagerScreen> {
  String _searchQuery = '';
  String _selectedStatus = 'Semua'; // Semua / VIP / Reguler -> mapped ke vip_status di API
  final List<String> _statusOptions = ['Semua', 'VIP', 'Reguler'];

  // ← TAMBAHAN: filter tanggal, samain pola RiwayatPICScreen
  String _dariTanggal = '';
  String _sampaiTanggal = '';

  int _currentPage = 1;
  int _lastPage = 1;

  List<Kunjungan> _daftarArsip = [];
  bool _isLoading = true;
  String? _errorMessage;

  final Map<String, Map<String, dynamic>> _leadBadges = {
    'new': {'label': 'Baru', 'color': Color(0xFF64748B)},
    'contacted': {'label': 'Dihubungi', 'color': Color(0xFF1B65E3)},
    'negotiation': {'label': 'Negosiasi', 'color': Color(0xFFF59E0B)},
    'deal': {'label': 'Deal / Berhasil', 'color': Color(0xFF006B3F)},
    'lost': {'label': 'Lost', 'color': Color(0xFFDC2626)},
  };

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData({int? page}) async {
    if (page != null) _currentPage = page;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final vipParam = _selectedStatus == 'VIP'
          ? 'vip'
          : _selectedStatus == 'Reguler'
              ? 'reguler'
              : 'all';
      final result = await KunjunganBloc.list(
        vipStatus: vipParam,
        keyword: _searchQuery.isNotEmpty ? _searchQuery : null,
        startDate: _dariTanggal.isEmpty ? null : _dariTanggal,
        endDate: _sampaiTanggal.isEmpty ? null : _sampaiTanggal,
        page: _currentPage,
      );
      setState(() {
        _daftarArsip = result.data;
        _currentPage = result.currentPage;
        _lastPage = result.lastPage;
      });
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ← TAMBAHAN: date picker, samain pola RiwayatPICScreen._pilihTanggal
  Future<void> _pilihTanggal(BuildContext context, bool isDari) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF006B3F),
              onPrimary: Colors.white,
              onSurface: Color(0xFF172033),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(0.85)),
            child: child!,
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        String formatted =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        if (isDari) {
          _dariTanggal = formatted;
        } else {
          _sampaiTanggal = formatted;
        }
      });
      _fetchData(page: 1); // filter tanggal baru → reset ke halaman 1
    }
  }

  String _formatValue(double? value) {
    if (value == null) return '-';
    return 'Rp ${value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        )}';
  }

  static const List<String> _bulanIndo = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  String _formatWaktu(String? iso) {
    if (iso == null) return '-';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day} ${_bulanIndo[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return '-';
    }
  }

  // ← TAMBAHAN: badge "Tahap" yang benar-benar sadar akan status kunjungan asli
  // (dibatalkan/dsb), bukan cuma leadStatus. Sebelumnya kunjungan yang dibatalkan
  // (leadStatus == null, karena gak pernah convert jadi lead) selalu jatuh ke
  // fallback _leadBadges['new'] dan nongol "Baru" alih-alih "Dibatalkan".
  Map<String, dynamic> _tahapBadge(Kunjungan item) {
    final s = item.status.toLowerCase().trim();
    final isCancelled = s.contains('batal') || s.contains('cancel') || s.contains('tolak');

    if (isCancelled) {
      return {'label': 'Dibatalkan', 'color': const Color(0xFFDC2626)};
    }

    final key = item.leadStatus;
    if (key == null || key.isEmpty) {
      return {'label': 'Bukan Lead', 'color': const Color(0xFF94A3B8)};
    }

    return _leadBadges[key] ?? {'label': 'Baru', 'color': const Color(0xFF64748B)};
  }

  void _showCatatanDialog(BuildContext context, Kunjungan item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Row(
            children: [
              const Icon(Icons.note_alt_rounded, color: Color(0xFF006B3F), size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text("Riwayat – ${item.guestName ?? item.visitCode}",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("PIC/Sales: ${item.assignedUser ?? '-'}",
                      style: const TextStyle(fontSize: 11, color: Color(0xFF778195), fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 8,
                      children: [
                        _summaryItem("Tahap Pipeline Terakhir", _pipelineTerakhirText(item)),
                        _summaryItem("Jadwal Follow-Up", _jadwalFollowUpText(item)),
                        _summaryItem("Estimasi Value", _formatValue(item.estimatedValue)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text("📝 Catatan Awal Kunjungan:",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(item.notes ?? 'Tidak ada catatan awal.',
                        style: const TextStyle(fontSize: 12, height: 1.4)),
                  ),
                  const SizedBox(height: 14),
                  const Text("📌 Hasil Meeting:",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(item.meetingResult ?? 'Tidak ada hasil meeting.',
                        style: const TextStyle(fontSize: 12, height: 1.4)),
                  ),
                  const SizedBox(height: 14),
                  const Text("🔄 Riwayat Update Pipeline:",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                  const SizedBox(height: 6),
                  if (item.followUps.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Belum ada catatan update follow-up.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontStyle: FontStyle.italic)),
                    )
                  else
                    ...item.followUps.map((fu) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDFDFD),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('📅 ${_formatWaktu(fu.createdAt)}',
                                    style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                                if (fu.status != null)
                                  Text(
                                    'Tahap: ${(_leadBadges[fu.status] ?? _leadBadges['new']!)['label']}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: (_leadBadges[fu.status] ?? _leadBadges['new']!)['color'] as Color,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(fu.result ?? '-', style: const TextStyle(fontSize: 12)),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 16,
                              runSpacing: 4,
                              children: [
                                Text('💰 ${_formatValue(fu.estimatedValue?.toDouble())}',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF006B3F))),
                                if (fu.dueAt != null)
                                  Text('Tanggal Follow Up: ${_formatWaktu(fu.dueAt!)}',
                                      style: const TextStyle(fontSize: 10, color: Color(0xFF475569))),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Tutup", style: TextStyle(color: Color(0xFF006B3F), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // ← DIUBAH: sekarang cek status kunjungan asli dulu (dibatalkan → "Dibatalkan"),
  // baru fallback ke leadStatus follow-up terakhir kalau bukan dibatalkan.
  String _pipelineTerakhirText(Kunjungan item) {
    final s = item.status.toLowerCase().trim();
    final isCancelled = s.contains('batal') || s.contains('cancel') || s.contains('tolak');
    if (isCancelled) return 'Dibatalkan';

    String? statusKey;
    if (item.followUps.isNotEmpty && item.followUps.last.status != null && item.followUps.last.status!.isNotEmpty) {
      statusKey = item.followUps.last.status;
    } else {
      statusKey = item.leadStatus;
    }
    if (statusKey == null || statusKey.isEmpty) return 'Bukan Lead';
    return (_leadBadges[statusKey] ?? _leadBadges['new']!)['label'] as String;
  }

  String _jadwalFollowUpText(Kunjungan item) {
    if (item.followUps.isNotEmpty) {
      final last = item.followUps.last;
      if (last.dueAt != null) return _formatWaktu(last.dueAt!);
    }
    return 'Belum dijadwalkan';
  }

  Widget _summaryItem(String label, String value) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
        ],
      ),
    );
  }

  // ← TAMBAHAN: reset filter, termasuk tanggal
  void _resetFilter() {
    setState(() {
      _searchQuery = '';
      _selectedStatus = 'Semua';
      _dariTanggal = '';
      _sampaiTanggal = '';
    });
    _fetchData(page: 1);
  }

  @override
  Widget build(BuildContext context) {
    // Filter pencarian client-side tambahan (selain keyword yang sudah dikirim ke API).
    // Perlakukan hanya sebagai penghalus tampilan halaman aktif — bukan pengganti
    // pencarian server-side, karena data yang ada di memori cuma 1 halaman.
    final filteredArsip = _daftarArsip.where((item) {
      final q = _searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          (item.guestName ?? '').toLowerCase().contains(q) ||
          item.visitCode.toLowerCase().contains(q) ||
          (item.purpose ?? '').toLowerCase().contains(q);
      return matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF006B3F),
        elevation: 0,
        title: const Text(
          "Arsip Kunjungan Tamu",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: () => _fetchData(page: 1)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchData(page: 1),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===================== FILTER =====================
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      onChanged: (value) => setState(() => _searchQuery = value),
                      onSubmitted: (_) => _fetchData(page: 1),
                      decoration: InputDecoration(
                        hintText: "Cari nama tamu, token, atau keperluan...",
                        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF778195)),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF006B3F), size: 20),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF4F7FC),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ← DIUBAH: filter tanggal jadi field "Dari Tgl" / "Sampai Tgl" pakai showDatePicker,
                    // sama polanya dengan RiwayatPICScreen (sebelumnya cuma tombol snackbar placeholder).
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _pilihTanggal(context, true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4F7FC),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 12, color: Color(0xFF006B3F)),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      _dariTanggal.isEmpty ? "Dari Tgl" : _dariTanggal,
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF172033)),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () => _pilihTanggal(context, false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4F7FC),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 12, color: Color(0xFF006B3F)),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      _sampaiTanggal.isEmpty ? "Sampai Tgl" : _sampaiTanggal,
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF172033)),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F7FC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedStatus,
                              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF006B3F)),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                              items: _statusOptions.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value == 'Semua' ? 'Status: Semua' : value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() => _selectedStatus = newValue);
                                  _fetchData(page: 1);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ← TAMBAHAN: tombol reset filter, muncul kalau ada filter tanggal/status/keyword aktif
                    if (_dariTanggal.isNotEmpty || _sampaiTanggal.isNotEmpty || _selectedStatus != 'Semua' || _searchQuery.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          onPressed: _resetFilter,
                          icon: const Icon(Icons.refresh, size: 12, color: Colors.grey),
                          label: const Text("Reset Filter", style: TextStyle(fontSize: 10, color: Color(0xFF778195))),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            minimumSize: const Size(60, 24),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Hasil Arsip Kunjungan",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
              ),
              const SizedBox(height: 12),

              // ===================== LIST =====================
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF006B3F))),
                )
              else if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      Text(_errorMessage!, style: const TextStyle(fontSize: 12, color: Colors.red), textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      TextButton(onPressed: () => _fetchData(page: 1), child: const Text("Coba Lagi")),
                    ],
                  ),
                )
              else if (filteredArsip.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: const Center(
                    child: Text("Tidak ada arsip kunjungan yang cocok.", style: TextStyle(fontSize: 12, color: Color(0xFF778195))),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredArsip.length,
                  itemBuilder: (context, index) {
                    final item = filteredArsip[index];
                    final catatan = item.catatanTerakhir ?? 'Belum ada catatan.';
                    final tahap = _tahapBadge(item);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(4)),
                                    // nomor urut ikut halaman aktif — konsisten dengan pola PipelineScreen.
                                    // Catatan: perPage sekarang diambil dari result.perPage (backend), bukan
                                    // hardcode 10. Kalau kamu mau pastikan angka ini akurat walau per_page
                                    // backend berubah, simpan result.perPage ke state (lihat catatan di bawah).
                                    child: Text("No. ${index + 1 + (_currentPage - 1) * 10}",
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF778195))),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(item.visitCode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF006B3F))),
                                ],
                              ),
                              // ← DIUBAH: pakai _tahapBadge(item) supaya kunjungan yang
                              // dibatalkan nunjukin "Dibatalkan", bukan "Baru".
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: (tahap['color'] as Color).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "Tahap: ${tahap['label']}",
                                  style: TextStyle(
                                    color: tahap['color'] as Color,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.person_outline_rounded, size: 14, color: Color(0xFF778195)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "Tamu: ${item.guestName ?? '-'}"
                                  "${item.guestPosition != null ? '\n(${item.guestPosition})' : ''}"
                                  "${item.companyName != null ? ' - ${item.companyName}' : ''}",
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                                ),
                              ),
                              if (item.isVip) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),

                          Row(
                            children: [
                              const Icon(Icons.schedule_rounded, size: 14, color: Color(0xFF778195)),
                              const SizedBox(width: 6),
                              Text("Waktu: ${_formatWaktu(item.checkInAt ?? item.scheduledAt)}", style: const TextStyle(fontSize: 12, color: Color(0xFF778195))),
                            ],
                          ),
                          const SizedBox(height: 6),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.category_outlined, size: 14, color: Color(0xFF778195)),
                                  const SizedBox(width: 6),
                                  Text("Jenis Kunjungan: ${item.categoryName ?? '-'}", style: const TextStyle(fontSize: 12, color: Color(0xFF778195))),
                                ],
                              ),
                              Text(_formatValue(item.estimatedValue), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF006B3F))),
                            ],
                          ),
                          const SizedBox(height: 6),

                          Row(
                            children: [
                              const Icon(Icons.description_outlined, size: 14, color: Color(0xFF778195)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text("Keperluan: ${item.purpose ?? '-'}", style: const TextStyle(fontSize: 12, color: Color(0xFF778195))),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          Row(
                            children: [
                              const Icon(Icons.badge_outlined, size: 14, color: Color(0xFF778195)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text("PIC/Sales: ${item.assignedUser ?? '-'}", style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                              ),
                            ],
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  "Catatan: $catatan",
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () => _showCatatanDialog(context, item),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF006B3F).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text("Lihat Catatan", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF006B3F))),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

              // ===================== KONTROL HALAMAN =====================
              if (!_isLoading && _errorMessage == null && filteredArsip.isNotEmpty && _lastPage > 1) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      color: const Color(0xFF006B3F),
                      onPressed: _currentPage > 1 ? () => _fetchData(page: _currentPage - 1) : null,
                    ),
                    Text(
                      ' $_currentPage / $_lastPage',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      color: const Color(0xFF006B3F),
                      onPressed: _currentPage < _lastPage ? () => _fetchData(page: _currentPage + 1) : null,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}