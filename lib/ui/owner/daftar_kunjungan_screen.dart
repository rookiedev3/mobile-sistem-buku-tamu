import 'package:flutter/material.dart';

import '/bloc/kunjungan_bloc.dart';
import '/model/kunjungan.dart';

/// Catatan migrasi:
/// Sebelumnya screen ini memakai data dummy statis (_daftarLead) dengan
/// model LeadModel/FollowUpModel lokal, sehingga tidak pernah menampilkan
/// data asli dari database. Sekarang screen ini memakai KunjunganBloc +
/// model Kunjungan yang SAMA seperti yang dipakai di
/// DaftarKunjunganManagerScreen, supaya datanya konsisten dan benar-benar
/// diambil dari backend/database.
///
/// Beberapa mapping field mengikuti apa yang sudah dipakai di file manager:
///   token       -> item.visitCode
///   jabatan     -> item.guestPosition
///   perusahaan  -> item.companyName
///   waktu       -> item.checkInAt ?? item.scheduledAt
///   PIC / Sales -> item.assignedUser
///   jenisKunjungan -> item.purpose
/// Jika nama field di model Kunjungan kamu berbeda, tinggal sesuaikan di
/// bagian yang ditandai "// SESUAIKAN" di bawah.
class DaftarKunjunganScreen extends StatefulWidget {
  const DaftarKunjunganScreen({Key? key}) : super(key: key);

  @override
  State<DaftarKunjunganScreen> createState() => _DaftarKunjunganScreenState();
}

class _DaftarKunjunganScreenState extends State<DaftarKunjunganScreen> {
  final Color corporateGreen = const Color(0xFF006B3F);

  final TextEditingController _searchController = TextEditingController();
  String _filterJenis = 'Semua Jenis';
  String _filterStatusPipeline = 'Semua Status';
  DateTime? _startDate;
  DateTime? _endDate;

  List<Kunjungan> _daftarKunjungan = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Badge Status Pipeline (dipakai untuk tampilan label + warna)
  final Map<String, Map<String, dynamic>> _leadBadges = {
    'new': {'label': 'Baru', 'color': Colors.blue},
    'meeting': {'label': 'Meeting Selesai', 'color': Colors.orange},
    'negotiation': {'label': 'Negosiasi', 'color': Colors.purple},
    'deal': {'label': 'Deal / Selesai', 'color': const Color(0xFF006B3F)},
    'lost': {'label': 'Dibatalkan / Lost', 'color': Colors.red},
  };

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // SESUAIKAN: KunjunganBloc.list() dipakai sama seperti di manager.
      // Owner tidak punya filter VIP, jadi kita minta 'all'.
      final result = await KunjunganBloc.list(
        vipStatus: 'all',
        keyword: _searchController.text.isNotEmpty ? _searchController.text : null,
      );
      setState(() => _daftarKunjungan = result.data);
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Badge lookup yang aman: cocok baik jika backend mengirim key mentah
  // ('new', 'meeting', dst) maupun jika backend sudah mengirim label jadi.
  Map<String, dynamic> _getBadge(String? status) {
    if (status == null || status.isEmpty) {
      return {'label': '-', 'color': Colors.grey};
    }
    if (_leadBadges.containsKey(status)) return _leadBadges[status]!;
    return _leadBadges.values.firstWhere(
      (v) => v['label'] == status,
      orElse: () => {'label': status, 'color': Colors.grey},
    );
  }

  String _rupiah(double? amount) {
    if (amount == null) return '-';
    return "Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  static const List<String> _bulanIndo = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      final d = DateTime.parse(raw).toLocal();
      return '${d.day} ${_bulanIndo[d.month - 1]} ${d.year}';
    } catch (_) {
      return raw;
    }
  }

  void _resetFilter() {
    setState(() {
      _searchController.clear();
      _filterJenis = 'Semua Jenis';
      _filterStatusPipeline = 'Semua Status';
      _startDate = null;
      _endDate = null;
    });
    _fetchData();
  }

  // --- POP-UP DIALOG RIWAYAT ---
  void _showCatatanDialog(BuildContext context, Kunjungan item) {
    final badge = _getBadge(item.leadStatus);
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
                  Text("Ditangani oleh: ${item.assignedUser ?? '-'} (PIC)",
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
                        _summaryItem("Tahap Pipeline Terakhir", badge['label'] as String),
                        _summaryItem("Jadwal Follow-Up", _scheduleText(item)),
                        _summaryItem("Estimasi Value", _rupiah(item.estimatedValue)),
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

                  const Text("📌 Hasil Meeting Pertama:",
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
                      final fuBadge = _getBadge(fu.status);
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
                                Text('📅 ${_formatDate(fu.createdAt)}',
                                    style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                                Text('Tahap: ${fuBadge['label']}',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fuBadge['color'])),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(fu.result ?? '-', style: const TextStyle(fontSize: 12)),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 16,
                              runSpacing: 4,
                              children: [
                                Text('💰 Estimasi Value: ${_rupiah(fu.estimatedValue?.toDouble())}',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF006B3F))),
                                if (fu.dueAt != null)
                                  Text('Target Due Date: ${_formatDate(fu.dueAt)}',
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

  String _scheduleText(Kunjungan item) {
    final status = _getBadge(item.leadStatus)['label'];
    if (status == 'Deal / Selesai') return 'Sudah Deal 🎉';
    if (status == 'Dibatalkan / Lost') return 'Lead Hilang / Lost';
    if (item.followUps.isNotEmpty && item.followUps.last.dueAt != null) {
      return _formatDate(item.followUps.last.dueAt);
    }
    return 'Tidak ada jadwal lanjutan';
  }

  Widget _summaryItem(String label, String value) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Kunjungan> filteredList = _daftarKunjungan.where((item) {
      String query = _searchController.text.toLowerCase();
      bool matchSearch = query.isEmpty ||
          (item.guestName ?? '').toLowerCase().contains(query) ||
          (item.companyName ?? '').toLowerCase().contains(query);

      bool matchJenis = (_filterJenis == 'Semua Jenis') || (item.purpose == _filterJenis);
      bool matchStatus = (_filterStatusPipeline == 'Semua Status') ||
          (_getBadge(item.leadStatus)['label'] == _filterStatusPipeline);

      bool matchDate = true;
      final waktuRaw = item.checkInAt ?? item.scheduledAt;
      if (waktuRaw != null && (_startDate != null || _endDate != null)) {
        try {
          final d = DateTime.parse(waktuRaw).toLocal();
          if (_startDate != null && d.isBefore(_startDate!)) matchDate = false;
          if (_endDate != null && d.isAfter(_endDate!.add(const Duration(days: 1)))) matchDate = false;
        } catch (_) {}
      }

      return matchSearch && matchJenis && matchStatus && matchDate;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: corporateGreen,
        elevation: 0,
        title: const Text(
          "Daftar Kunjungan & Pipeline",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _fetchData),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= FILTER & SEARCH BAR =================
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 32,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() {}),
                        onSubmitted: (_) => _fetchData(),
                        style: const TextStyle(fontSize: 10),
                        decoration: InputDecoration(
                          hintText: "Cari nama tamu / perusahaan...",
                          prefixIcon: const Icon(Icons.search, size: 14, color: Colors.grey),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          filled: true,
                          fillColor: const Color(0xFFF4F7FC),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 32,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFE2E8F0))),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _filterJenis,
                                isDense: true,
                                style: const TextStyle(fontSize: 10, color: Color(0xFF172033)),
                                items: ['Semua Jenis', 'Mitra', 'Prospek', 'Klien', 'Vendor', 'Pelamar', 'Umum']
                                    .map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                                onChanged: (val) => setState(() => _filterJenis = val!),
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
                                value: _filterStatusPipeline,
                                isDense: true,
                                style: const TextStyle(fontSize: 10, color: Color(0xFF172033)),
                                items: ['Semua Status', 'Baru', 'Meeting Selesai', 'Negosiasi', 'Deal / Selesai', 'Dibatalkan / Lost']
                                    .map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                                onChanged: (val) => setState(() => _filterStatusPipeline = val!),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 32,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2025),
                                  lastDate: DateTime(2027),
                                );
                                if (picked != null) setState(() => _startDate = picked);
                              },
                              icon: const Icon(Icons.date_range, size: 12, color: Colors.grey),
                              label: Text(_startDate == null ? "Dari Tanggal" : "${_startDate!.day}/${_startDate!.month}/${_startDate!.year}", style: const TextStyle(fontSize: 9.5, color: Colors.grey)),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                side: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: SizedBox(
                            height: 32,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2025),
                                  lastDate: DateTime(2027),
                                );
                                if (picked != null) setState(() => _endDate = picked);
                              },
                              icon: const Icon(Icons.date_range, size: 12, color: Colors.grey),
                              label: Text(_endDate == null ? "Sampai Tanggal" : "${_endDate!.day}/${_endDate!.month}/${_endDate!.year}", style: const TextStyle(fontSize: 9.5, color: Colors.grey)),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                side: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        SizedBox(
                          height: 32,
                          child: OutlinedButton.icon(
                            onPressed: _resetFilter,
                            icon: const Icon(Icons.refresh, size: 12, color: Colors.grey),
                            label: const Text("Reset", style: TextStyle(fontSize: 9.5, color: Colors.grey)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ================= TABEL DAFTAR KUNJUNGAN =================
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
                    const Text("Tabel Riwayat Kunjungan & Pipeline", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
                    const SizedBox(height: 8),

                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CircularProgressIndicator(color: Color(0xFF006B3F))),
                      )
                    else if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Column(
                          children: [
                            Text(_errorMessage!, style: const TextStyle(fontSize: 11, color: Colors.red), textAlign: TextAlign.center),
                            const SizedBox(height: 8),
                            TextButton(onPressed: _fetchData, child: const Text("Coba Lagi")),
                          ],
                        ),
                      )
                    else if (filteredList.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(15.0),
                        child: Center(child: Text("Tidak ada data kunjungan.", style: TextStyle(fontSize: 10, color: Colors.grey))),
                      )
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowHeight: 28,
                          dataRowHeight: 40,
                          columnSpacing: 10,
                          columns: const [
                            DataColumn(label: Text('No', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Token', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Tamu & Jabatan', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Tanggal & Waktu', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Jenis Kunjungan', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Keperluan', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('PIC / Sales', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Value', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Catatan & Riwayat', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Tahap Pipeline', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                          ],
                          rows: List.generate(filteredList.length, (index) {
                            final item = filteredList[index];
                            final badge = _getBadge(item.leadStatus);
                            return DataRow(cells: [
                              DataCell(Text((index + 1).toString(), style: const TextStyle(fontSize: 9))),
                              DataCell(Text(item.visitCode, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: corporateGreen))),
                              DataCell(Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(item.guestName ?? '-', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                  Text(item.guestPosition ?? '-', style: const TextStyle(fontSize: 8, color: Colors.grey)),
                                ],
                              )),
                              DataCell(Text(_formatDate(item.checkInAt ?? item.scheduledAt), style: const TextStyle(fontSize: 9))),
                              DataCell(Text(item.purpose ?? '-', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600))),
                              DataCell(Text(item.purpose ?? '-', style: const TextStyle(fontSize: 9))),
                              DataCell(Text(item.assignedUser ?? '-', style: const TextStyle(fontSize: 9))),
                              DataCell(Text(_rupiah(item.estimatedValue), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: corporateGreen))),
                              DataCell(ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade50,
                                  foregroundColor: Colors.blue,
                                  elevation: 0,
                                  minimumSize: const Size(50, 24),
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                ),
                                onPressed: () => _showCatatanDialog(context, item),
                                child: const Text("Catatan", style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold)),
                              )),
                              DataCell(Text(badge['label'], style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: badge['color']))),
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
}