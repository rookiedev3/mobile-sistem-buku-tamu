import 'package:flutter/material.dart';
import 'dashboard_manager.dart';
import 'pipeline_screen.dart';
import '/bloc/kunjungan_bloc.dart';
import '/model/kunjungan.dart';

class DaftarKunjunganManagerScreen extends StatefulWidget {
  const DaftarKunjunganManagerScreen({Key? key}) : super(key: key);

  @override
  State<DaftarKunjunganManagerScreen> createState() => _DaftarKunjunganManagerScreenState();
}

class _DaftarKunjunganManagerScreenState extends State<DaftarKunjunganManagerScreen> {
  int _currentIndex = 2;

  String _searchQuery = '';
  String _selectedStatus = 'Semua'; // Semua / VIP / Reguler -> mapped ke vip_status di API
  final List<String> _statusOptions = ['Semua', 'VIP', 'Reguler'];

  List<Kunjungan> _daftarArsip = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
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
      );
      setState(() => _daftarArsip = result.data);
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatValue(double? value) {
    if (value == null) return '-';
    return 'Rp ${value.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        )}';
  }

  // String _formatWaktu(String? iso) {
  //   if (iso == null) return '-';
  //   try {
  //     final dt = DateTime.parse(iso).toLocal();
  //     const bulan = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Ags','Sep','Okt','Nov','Des'];
  //     return '${dt.day} ${bulan[dt.month - 1]} ${dt.year}, '
  //         '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} WIB';
  //   } catch (_) {
  //     return '-';
  //   }
  // }

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

                // Ringkasan atas: Jenis Kunjungan / Tahap / Estimasi Value
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
                      _summaryItem("Jenis Kunjungan", item.purpose ?? '-'),
                      _summaryItem("Tahap Pipeline", item.leadStatus ?? '-'),
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
                                Text('Tahap: ${fu.status}',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1B65E3))),
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
  @override
  Widget build(BuildContext context) {
    // Filter pencarian dilakukan client-side tambahan (selain keyword yang dikirim ke API)
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
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _fetchData),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
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
                      onSubmitted: (_) => _fetchData(),
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
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Membuka kalender filter tanggal...')),
                              );
                            },
                            icon: const Icon(Icons.date_range, size: 16, color: Color(0xFF006B3F)),
                            label: const Text("Pilih Tanggal", style: TextStyle(fontSize: 11, color: Color(0xFF172033))),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                                  _fetchData();
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
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
                      TextButton(onPressed: _fetchData, child: const Text("Coba Lagi")),
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
                    final statusLabel = item.isVip ? 'VIP' : 'Reguler';
                    final catatan = item.catatanTerakhir ?? 'Belum ada catatan.';

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
                          // No + Token & Status VIP/Reguler
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(4)),
                                    child: Text("No. ${index + 1}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF778195))),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(item.visitCode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF006B3F))),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: item.isVip ? Colors.amber.withOpacity(0.15) : Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  statusLabel,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: item.isVip ? Colors.amber[800] : Colors.blue[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Tamu & Jabatan
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
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Tanggal & Waktu
                          Row(
                            children: [
                              const Icon(Icons.schedule_rounded, size: 14, color: Color(0xFF778195)),
                              const SizedBox(width: 6),
                              Text("Waktu: ${_formatWaktu(item.checkInAt ?? item.scheduledAt)}", style: const TextStyle(fontSize: 12, color: Color(0xFF778195))),
                            ],
                          ),
                          const SizedBox(height: 6),
// Jenis Kunjungan (purpose) & Value
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Row(
      children: [
        const Icon(Icons.category_outlined, size: 14, color: Color(0xFF778195)),
        const SizedBox(width: 6),
        Text("Jenis Kunjungan: ${item.purpose ?? '-'}", style: const TextStyle(fontSize: 12, color: Color(0xFF778195))),
      ],
    ),
    Text(_formatValue(item.estimatedValue), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF006B3F))),
  ],
),
const SizedBox(height: 6),

// Keperluan (notes)
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

// PIC / Sales
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

                          // Tahap Pipeline (lead_status) & Catatan (Pop-up)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1B65E3).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "Tahap: ${item.leadStatus ?? '-'}",
                                  style: const TextStyle(color: Color(0xFF1B65E3), fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF006B3F),
        unselectedItemColor: const Color(0xFF778195),
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 0) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardManager()));
          } else if (index == 1) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PipelineScreen()));
          } else if (index == 2) {
            // Sudah di halaman ini
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Navigasi ke menu indeks $index (Segera Hadir)')),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.timeline_rounded), label: 'Pipeline'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'Kunjungan'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_rounded), label: 'Laporan'),
          BottomNavigationBarItem(icon: Icon(Icons.download_rounded), label: 'Eksport'),
        ],
      ),
    );
  }
}