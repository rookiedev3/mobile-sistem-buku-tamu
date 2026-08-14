import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'pipeline_screen.dart';
import '../../bloc/manager_bloc.dart';
import '../../model/manager_dashboard_model.dart';
import 'package:mobile_flutter/ui/homepage_screen.dart';


class DashboardManager extends StatefulWidget {
  const DashboardManager({Key? key}) : super(key: key);

  @override
  State<DashboardManager> createState() => _DashboardManagerState();
}

class _DashboardManagerState extends State<DashboardManager> {

  String _selectedFilter = 'Semua'; // Semua | VIP | Reguler
  final List<String> _filterOptions = ['Semua', 'VIP', 'Reguler'];

  late Future<ManagerDashboardResponse> _futureDashboard;
  final DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final vipParam = switch (_selectedFilter) {
      'VIP' => 'vip',
      'Reguler' => 'reguler',
      _ => 'all',
    };
    _futureDashboard = ManagerBloc.dashboard(
      date: DateFormat('yyyy-MM-dd').format(_selectedDate),
      vipStatus: vipParam,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF006B3F),
        elevation: 0,
        title: const Text(
          "Dashboard Manager - Executive View",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),

          //button logout sementara
         IconButton(
  icon: const Icon(Icons.logout, color: Colors.white),
  onPressed: () {
    // Menampilkan dialog konfirmasi atau langsung redirect
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Konfirmasi Keluar", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        content: const Text("Apakah Anda yakin ingin keluar?", style: TextStyle(fontSize: 11)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Tutup dialog
            child: const Text("Batal", style: TextStyle(fontSize: 10, color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(context); // Tutup dialog konfirmasi

              // REDIRECT KE HOMESCREEN DAN HAPUS SEMUA RIWAYAT HALAMAN SEBELUMNYA
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomepageScreen()), // Ganti dengan nama widget HomeScreen Anda
                (route) => false,
              );
            },
            child: const Text("Keluar", style: TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  },
),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _loadData());
          await _futureDashboard;
        },
        child: FutureBuilder<ManagerDashboardResponse>(
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
                        Text('${snapshot.error}', textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => setState(() => _loadData()),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final data = snapshot.data!;
            final visits = data.visits;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderBanner(),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: "Total Tamu Hari Ini",
                          value: "${data.totalToday}",
                          subtext: DateFormat('d MMM yyyy').format(_selectedDate),
                          icon: Icons.people_alt,
                          iconColor: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          title: "Lead Deal Bulan Ini",
                          value: "${data.leadDealsCount}",
                          subtext: "Total deal bulan berjalan",
                          icon: Icons.trending_up,
                          iconColor: const Color(0xFF006B3F),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    "Aktivitas Kunjungan & Lead",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                  ),
                  const SizedBox(height: 10),

                  _buildFilterCard(),
                  const SizedBox(height: 14),

                  visits.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              "Tidak ada data kunjungan untuk kategori ini.",
                              style: TextStyle(fontSize: 12, color: Color(0xFF778195)),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: visits.length,
                          itemBuilder: (context, index) => _buildVisitCard(visits[index]),
                        ),
                ],
              ),
            );
          },
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: _currentIndex,
      //   selectedItemColor: const Color(0xFF006B3F),
      //   unselectedItemColor: const Color(0xFF778195),
      //   backgroundColor: Colors.white,
      //   type: BottomNavigationBarType.fixed,
      //   onTap: (index) {
      //     setState(() => _currentIndex = index);
      //     if (index == 1) {
      //       Navigator.push(context, MaterialPageRoute(builder: (context) => const PipelineScreen()));
      //     }
      //   },
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Beranda'),
      //     BottomNavigationBarItem(icon: Icon(Icons.timeline_rounded), label: 'Pipeline'),
      //     BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'Guest'),
      //     BottomNavigationBarItem(icon: Icon(Icons.analytics_rounded), label: 'Reports'),
      //   ],
      // ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF006B3F).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.admin_panel_settings, color: Color(0xFF006B3F), size: 26),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Selamat Datang, Manager",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
                SizedBox(height: 2),
                Text("Pantau performa kunjungan dan lead bisnis hari ini.",
                    style: TextStyle(fontSize: 12, color: Color(0xFF778195))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(Icons.filter_alt_outlined, size: 18, color: Color(0xFF006B3F)),
              SizedBox(width: 10),
              Text("Filter Tipe Tamu:",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF778195))),
            ],
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedFilter,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF006B3F)),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
              items: _filterOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value == 'Semua' ? 'Semua Tipe Tamu' : value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedFilter = newValue;
                    _loadData(); // trigger fetch ulang ke backend dengan vip_status baru
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitCard(VisitModel item) {
  Color badgeColor;
  Color textColor;
  switch (item.status?.toLowerCase()) {
    case 'meeting':
    case 'sedang meeting':
      badgeColor = Colors.green.withOpacity(0.1);
      textColor = Colors.green[700]!;
      break;
    case 'dikonfirmasi':
    case 'confirmed':
      badgeColor = Colors.blue.withOpacity(0.1);
      textColor = Colors.blue[700]!;
      break;
    case 'menunggu':
    case 'pending':
      badgeColor = Colors.orange.withOpacity(0.1);
      textColor = Colors.orange[800]!;
      break;
    default:
      badgeColor = Colors.grey.withOpacity(0.1);
      textColor = Colors.grey[700]!;
  }

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Baris 1: Token & Status
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.visitCode ?? 'VST-${item.id.toString().padLeft(4, '0')}',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF006B3F)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(6)),
              child: Text(item.status ?? '-',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor)),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Baris 2: Perusahaan + bintang VIP
        Row(
          children: [
            Expanded(
              child: Text(item.companyName ?? '-',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                  overflow: TextOverflow.ellipsis),
            ),
            if (item.isVip) ...[
              const SizedBox(width: 6),
              const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
            ],
          ],
        ),
        const SizedBox(height: 4),

        // Tamu & Jabatan
        Text(
          "Tamu: ${item.guestName ?? '-'}"
          "${item.guestPosition != null ? ' (${item.guestPosition})' : ''}",
          style: const TextStyle(fontSize: 12, color: Color(0xFF778195)),
        ),
        const SizedBox(height: 2),

        // Waktu
        Text(
          "Waktu: ${_formatTime(item.displayTime)}",
          style: const TextStyle(fontSize: 12, color: Color(0xFF778195)),
        ),
        const SizedBox(height: 6),

        // Jenis Kunjungan
        Row(
          children: [
            const Text("Jenis Kunjungan: ", style: TextStyle(fontSize: 11, color: Color(0xFF778195))),
            Text(item.purposeName ?? '-',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF006B3F))),
          ],
        ),
        const SizedBox(height: 8),

        const Divider(color: Color(0xFFE2E8F0), height: 12),

        // Keperluan & PIC (id + nama)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Keperluan: ${item.keperluan ?? '-'}",
                style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "PIC: #${item.assignedUserId ?? '-'} ${item.assignedUserName ?? ''}",
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF172033)),
            ),
          ],
        ),
      ],
    ),
  );
}

  String _formatTime(String raw) {
    try {
      return DateFormat('HH:mm').format(DateTime.parse(raw)) + ' WIB';
    } catch (_) {
      return raw;
    }
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF778195))),
              Icon(icon, color: iconColor, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
          const SizedBox(height: 4),
          Text(subtext, style: TextStyle(fontSize: 10, color: iconColor, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}