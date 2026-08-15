import 'package:flutter/material.dart';
import 'produk_diminati_screen.dart';
import 'kategori_tamu_screen.dart';
import 'aktivitas_terbaru_screen.dart';
import 'package:mobile_flutter/ui/homepage_screen.dart';
import '../../bloc/owner_bloc.dart';
import '../../model/dashboard_owner_model.dart';

class DashboardOwnerScreen extends StatefulWidget {
  const DashboardOwnerScreen({Key? key}) : super(key: key);

  @override
  State<DashboardOwnerScreen> createState() => _DashboardOwnerScreenState();
}

class _DashboardOwnerScreenState extends State<DashboardOwnerScreen> {
  final Color corporateGreen = const Color(0xFF006B3F);

  final TextEditingController _searchController = TextEditingController();
  String _filterStatus = 'Semua Status';
  String _filterPic = 'Semua PIC';

  late Future<DashboardOwnerResponse> _futureDashboard;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _futureDashboard = DashboardOwnerBloc.fetch(
      status: _filterStatus == 'Semua Status' ? null : _filterStatus,
      keyword: _searchController.text.isNotEmpty ? _searchController.text : null,
    );
  }

  void _resetFilter() {
    setState(() {
      _searchController.clear();
      _filterStatus = 'Semua Status';
      _filterPic = 'Semua PIC';
      _loadData();
    });
  }

  String _formatJam(String? iso) {
    if (iso == null) return '-';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} WIB';
    } catch (_) {
      return '-';
    }
  }

  String _formatWaktuLalu(String? iso) {
    if (iso == null) return '-';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes} min lalu';
      if (diff.inHours < 24) return '${diff.inHours} jam lalu';
      return '${diff.inDays} hari lalu';
    } catch (_) {
      return '-';
    }
  }

  Color _statusColor(String? status) {
    final s = (status ?? '').toLowerCase();
    if (s.contains('selesai') || s.contains('completed')) return Colors.green;
    if (s.contains('batal') || s.contains('cancel') || s.contains('tolak')) return Colors.red;
    if (s.contains('menunggu') || s.contains('waiting')) return Colors.orange;
    return Colors.blue;
  }

  IconData _statusIcon(String? status) {
    final s = (status ?? '').toLowerCase();
    if (s.contains('selesai') || s.contains('completed')) return Icons.check_circle_rounded;
    if (s.contains('batal') || s.contains('cancel') || s.contains('tolak')) return Icons.cancel_rounded;
    if (s.contains('menunggu') || s.contains('waiting')) return Icons.hourglass_top_rounded;
    return Icons.info_rounded;
  }

  void _showDetailCatatan(BuildContext context, VisitOwnerItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.speaker_notes_rounded, size: 16, color: corporateGreen),
            const SizedBox(width: 6),
            Expanded(
              child: Text("Catatan: ${item.nama ?? '-'}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Token: ${item.token} | PIC: ${item.pic ?? '-'}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
            const Divider(height: 12),
            const Text("Isi Catatan Kunjungan:", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(6)),
              child: Text(item.catatan ?? 'Belum ada catatan.', style: const TextStyle(fontSize: 10, color: Color(0xFF172033))),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: corporateGreen, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4)),
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup", style: TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  }

  // Dialog Konfirmasi Keluar / Logout dengan Redirect ke HomeScreen
  void _konfirmasiLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Konfirmasi Keluar", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        content: const Text("Apakah Anda yakin ingin keluar dari sesi Owner?", style: TextStyle(fontSize: 11)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(fontSize: 10, color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, elevation: 0),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomepageScreen()),
                (route) => false,
              );
            },
            child: const Text("Keluar", style: TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: corporateGreen,
        elevation: 0,
        title: const Text(
          "Dashboard Owner",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 18, color: Colors.white),
            tooltip: "Refresh",
            onPressed: () => setState(_loadData),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, size: 18, color: Colors.white),
            tooltip: "Keluar",
            onPressed: () => _konfirmasiLogout(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(_loadData);
          await _futureDashboard;
        },
        child: FutureBuilder<DashboardOwnerResponse>(
          future: _futureDashboard,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
                        const SizedBox(height: 8),
                        Text('${snapshot.error}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
                        const SizedBox(height: 12),
                        ElevatedButton(onPressed: () => setState(_loadData), child: const Text('Coba Lagi')),
                      ],
                    ),
                  ),
                ),
              );
            }

            final data = snapshot.data!;
            final summary = data.summary;

            final filteredTabel = data.visits.where((item) {
              final matchPic = _filterPic == 'Semua PIC' || item.pic == _filterPic;
              return matchPic;
            }).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(10.0),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Ringkasan Operasional Hari Ini", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
                  const SizedBox(height: 8),

                  // ================= 6 CARD UTAMA GRID =================
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.85,
                    children: [
                      _buildCardStatistik(
                        title: "Total Tamu",
                        value: "${summary.totalTamuHariIni} Orang",
                        icon: Icons.groups_rounded,
                        color: Colors.blue,
                        onTap: () => setState(() { _filterStatus = 'Semua Status'; _loadData(); }),
                      ),
                      _buildCardStatistik(
                        title: "Terjadwal",
                        value: "${summary.terjadwalHariIni} Orang",
                        icon: Icons.calendar_month_rounded,
                        color: Colors.orange,
                        onTap: () => setState(() { _filterStatus = 'Terjadwal'; _loadData(); }),
                      ),
                      _buildCardStatistik(
                        title: "Selesai",
                        value: "${summary.pertemuanSelesai} Orang",
                        icon: Icons.task_alt_rounded,
                        color: Colors.green,
                        onTap: () => setState(() { _filterStatus = 'Meeting Selesai'; _loadData(); }),
                      ),
                      _buildCardStatistik(
                        title: "Menjadi Lead",
                        value: "${summary.menjadiLeadHariIni} Lead",
                        icon: Icons.trending_up_rounded,
                        color: Colors.purple,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Menampilkan filter Lead aktif."), duration: Duration(milliseconds: 700)),
                          );
                        },
                      ),
                      _buildCardStatistik(
                        title: "Produk Diminati",
                        value: data.topProduct.name ?? '-',
                        icon: Icons.bar_chart_rounded,
                        color: Colors.teal,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ProdukDiminatiScreen()));
                        },
                      ),
                      _buildCardStatistik(
                        title: "Kategori Tamu",
                        value: data.topCategory.name ?? '-',
                        icon: Icons.pie_chart_rounded,
                        color: Colors.indigo,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const KategoriTamuScreen()));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // ================= CARD AKTIVITAS TERBARU =================
                  InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AktivitasTerbaruScreen()));
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 3, offset: const Offset(0, 1))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Icon(Icons.bolt_rounded, size: 16, color: corporateGreen),
                              const SizedBox(width: 4),
                              const Text("Aktivitas Terbaru", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
                            ],
                          ),
                          const Divider(height: 12),

                          if (data.recentActivities.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text("Belum ada aktivitas terbaru.", style: TextStyle(fontSize: 9, color: Colors.grey)),
                            )
                          else
                            ...data.recentActivities.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final log = entry.value;
                              final color = _statusColor(log.newStatus);
                              return Padding(
                                padding: EdgeInsets.only(bottom: idx == data.recentActivities.length - 1 ? 0 : 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 2),
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                                      child: Icon(_statusIcon(log.newStatus), size: 12, color: color),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "${log.guestName ?? '-'} (${log.companyName ?? '-'})",
                                                  style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Text(_formatWaktuLalu(log.changedAt), style: const TextStyle(fontSize: 8, color: Colors.grey)),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(4)),
                                            child: Text("Status diubah: ${log.newStatus ?? '-'}", style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w600, color: color)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),

                          const SizedBox(height: 6),
                          const Align(
                            alignment: Alignment.centerRight,
                            child: Text("Lihat Semua Log Aktivitas >", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blue)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ================= TABEL KUNJUNGAN HARI INI =================
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
                        const Text("Tabel Kunjungan Hari Ini", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 32,
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFE2E8F0))),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _filterStatus,
                                    isDense: true,
                                    isExpanded: true,
                                    style: const TextStyle(fontSize: 10, color: Color(0xFF172033)),
                                    items: [
                                      'Semua Status',
                                      ...data.statusOptions,
                                    ].toSet().map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                                    onChanged: (val) => setState(() { _filterStatus = val!; _loadData(); }),
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
                                    value: _filterPic,
                                    isDense: true,
                                    isExpanded: true,
                                    style: const TextStyle(fontSize: 10, color: Color(0xFF172033)),
                                    items: [
                                      'Semua PIC',
                                      ...data.picOptions.map((p) => p['name'].toString()),
                                    ].toSet().map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                                    onChanged: (val) => setState(() => _filterPic = val!),
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
                              flex: 3,
                              child: SizedBox(
                                height: 32,
                                child: TextField(
                                  controller: _searchController,
                                  onSubmitted: (_) => setState(_loadData),
                                  style: const TextStyle(fontSize: 10),
                                  decoration: InputDecoration(
                                    hintText: "Cari nama tamu...",
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
                            ),
                            const SizedBox(width: 6),
                            SizedBox(
                              height: 32,
                              child: OutlinedButton.icon(
                                onPressed: _resetFilter,
                                icon: const Icon(Icons.refresh, size: 12, color: Colors.grey),
                                label: const Text("Reset", style: TextStyle(fontSize: 10, color: Colors.grey)),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        filteredTabel.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(15.0),
                                child: Center(child: Text("Tidak ada data kunjungan.", style: TextStyle(fontSize: 10, color: Colors.grey))),
                              )
                            : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  headingRowHeight: 28,
                                  dataRowHeight: 38,
                                  columnSpacing: 10,
                                  columns: const [
                                    DataColumn(label: Text('No', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Token', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Tamu & Jabatan', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Waktu', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Jenis', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Keperluan', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('PIC', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Catatan', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Status Kunjungan', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Status Lead', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                                  ],
                                  rows: List.generate(filteredTabel.length, (index) {
                                    final item = filteredTabel[index];
                                    return DataRow(cells: [
                                      DataCell(Text((index + 1).toString(), style: const TextStyle(fontSize: 9))),
                                      DataCell(Text(item.token, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: corporateGreen))),
                                      DataCell(Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(item.nama ?? '-', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                          Text(item.jabatan ?? '-', style: const TextStyle(fontSize: 8, color: Colors.grey)),
                                        ],
                                      )),
                                      DataCell(Text(_formatJam(item.waktu), style: const TextStyle(fontSize: 9))),
                                      DataCell(Text(item.jenis ?? '-', style: const TextStyle(fontSize: 9))),
                                      DataCell(Text(item.keperluan ?? '-', style: const TextStyle(fontSize: 9))),
                                      DataCell(Text(item.pic ?? '-', style: const TextStyle(fontSize: 9))),
                                      DataCell(InkWell(
                                        onTap: () => _showDetailCatatan(context, item),
                                        child: Row(
                                          children: const [
                                            // Icon(Icons.speaker_notes, size: 12, color: Colors.blue),
                                            SizedBox(width: 2),
                                            Text("Lihat", style: TextStyle(fontSize: 9, color: Colors.blue, decoration: TextDecoration.underline)),
                                          ],
                                        ),
                                      )),
                                      DataCell(Text(item.statusKunjungan, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600))),
                                      DataCell(Text(item.statusLead ?? '-', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: corporateGreen))),
                                    ]);
                                  }),
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
//       bottomNavigationBar: BottomNavigationBar(
//   currentIndex: _currentIndex,
//   selectedItemColor: corporateGreen,
//   unselectedItemColor: const Color(0xFF778195),
//   backgroundColor: Colors.white,
//   type: BottomNavigationBarType.fixed,
//   selectedFontSize: 9,
//   unselectedFontSize: 9,
//   onTap: (index) {
//     setState(() => _currentIndex = index);
//     if (index == 0) {
//       // Sudah di Dashboard
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Navigasi ke menu indeks $index (Segera Hadir)')),
//       );
//     }
//   },
//   items: const [
//     BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded, size: 16), label: 'Dashboard'),
//     BottomNavigationBarItem(icon: Icon(Icons.assignment_rounded, size: 16), label: 'Kunjungan'),
//     BottomNavigationBarItem(icon: Icon(Icons.group_rounded, size: 16), label: 'Database'),
//     BottomNavigationBarItem(icon: Icon(Icons.trending_up_rounded, size: 16), label: 'Lead & FU'),
//     BottomNavigationBarItem(icon: Icon(Icons.analytics_rounded, size: 16), label: 'Laporan'),
//   ],
// ),
    );
  }

  Widget _buildCardStatistik({required String title, required String value, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
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
            Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            const Text("Ketuk untuk filter", style: TextStyle(fontSize: 7, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}