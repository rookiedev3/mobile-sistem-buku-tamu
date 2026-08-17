import 'package:flutter/material.dart';
import 'package:mobile_flutter/bloc/dashboard_admin_bloc.dart';
import 'package:mobile_flutter/services/notification_service.dart';
import 'package:mobile_flutter/ui/homepage_screen.dart';
<<<<<<< HEAD
import 'form_tambah_janji_dialog.dart';
=======
import 'package:mobile_flutter/bloc/logout_bloc.dart'; // kalau foldernya "blocs" bukan "bloc"


>>>>>>> 05787630ebc4c8ff8fe7caf2b0661d9796711325

class DashboardAdminScreen extends StatefulWidget {
  const DashboardAdminScreen({super.key});

  @override
  State<DashboardAdminScreen> createState() => _DashboardAdminScreenState();
}

class _DashboardAdminScreenState extends State<DashboardAdminScreen> {
  // State Management Data
  bool _isLoading = true;
  String? _errorMessage;

  int _totalToday = 0;
  int _unfinishedTodayCount = 0;
  List<dynamic> _visits = [];

  // State Filter & Search
  String _filterStatus = 'Semua'; // 'Semua' atau 'Hari Ini'
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Helper untuk penentuan warna status dinamis
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'terjadwal':
      case 'waiting':
        return Colors.blue;
      case 'menunggu':
      case 'proses':
        return Colors.orange;
      case 'selesai':
      case 'completed':
        return Colors.green;
      case 'dibatalkan':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Helper untuk memformat tanggal dari API menjadi format (D-M-Y HH:mm WIB)
  String _formatDateTime(String? rawDateTime) {
    if (rawDateTime == null || rawDateTime.isEmpty) return '-';
    try {
      final dt = DateTime.parse(rawDateTime).toLocal();
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final year = dt.year;
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');

      return '$day-$month-$year $hour:$minute WIB';
    } catch (_) {
      return rawDateTime;
    }
  }

  /// Memuat Data Dashboard via DashboardAdminBloc
  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String dateFilterParam =
          _filterStatus == 'Hari Ini' ? 'today' : 'all';

      final data = await DashboardAdminBloc.getDashboard(
        dateFilter: dateFilterParam,
        keyword: _searchController.text.trim(),
      );

      final statistics = data['statistics'] ?? {};
      final visitsData = data['visits'];

      List<dynamic> visitList = [];
      if (visitsData is Map && visitsData.containsKey('data')) {
        visitList = visitsData['data'] ?? [];
      } else if (visitsData is List) {
        visitList = visitsData;
      }

      setState(() {
        _totalToday = statistics['total_today'] ?? 0;
        _unfinishedTodayCount = statistics['unfinished_today'] ?? 0;
        _visits = visitList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Memproses Check-In Kunjungan
  Future<void> _processCheckIn(int visitId) async {
    try {
      await DashboardAdminBloc.checkIn(visitId);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil melakukan Check-in tamu!'),
          backgroundColor: Color(0xFF006B3F),
        ),
      );
      _fetchDashboardData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal Check-In: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Memproses Pembatalan Kunjungan
  Future<void> _processCancel(int visitId) async {
    try {
      await DashboardAdminBloc.cancel(visitId);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kunjungan berhasil dibatalkan.'),
          backgroundColor: Color(0xFF006B3F),
        ),
      );
      _fetchDashboardData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal Membatalkan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF006B3F),
        elevation: 0,
        title: const Text(
          "Admin - Dashboard",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
<<<<<<< HEAD
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: const Text(
                    "Konfirmasi Keluar",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  content: const Text(
                    "Apakah Anda yakin ingin keluar?",
                    style: TextStyle(fontSize: 11),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Batal",
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomepageScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        "Keluar",
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              );
            },
=======
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
            onPressed: () async {
              Navigator.pop(context); // tutup dialog dulu
              await LogoutBloc.logout(); // hapus token & remember_me
              if (context.mounted) {
                LogoutBloc.keluarKeHomepage(context); // redirect ke Homepage
              }
            },
            child: const Text("Ya, Keluar", style: TextStyle(fontSize: 10)),
>>>>>>> 05787630ebc4c8ff8fe7caf2b0661d9796711325
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDashboardData,
        color: const Color(0xFF006B3F),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= RINGKASAN STATISTIK =================
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Total Hari Ini",
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF778195),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "$_totalToday",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF006B3F),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Belum Selesai (Hari Ini)",
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF778195),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "$_unfinishedTodayCount",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD97706),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ================= HEADER & TAMBAH JANJI =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Daftar Reservasi & Janji Tamu",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF172033),
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006B3F),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      final dynamic rawResult = await showDialog(
                        context: context,
                        builder: (context) => const FormTambahJanjiDialog(),
                      );

                      if (rawResult != null) {
                        // 1. Refresh data dashboard
                        _fetchDashboardData();

                        // 2. Ekstrak data dan tampilkan Notifikasi Lokal
                        String namaTamu = 'Tamu Baru';
                        String jam = '-';

                        if (rawResult is Map) {
                          namaTamu = rawResult['nama'] ?? rawResult['name'] ?? 'Tamu Baru';
                          jam = rawResult['jam'] ?? '-';
                        }

                        await NotificationService.showNotification(
                          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                          title: 'Janji Temu Berhasil Dibuat! 📅',
                          body: 'Janji temu untuk $namaTamu pada $jam telah ditambahkan.',
                        );
                      }
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text(
                      "Tambah Janji",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ================= SEARCH BAR & FILTER =================
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: (_) => _fetchDashboardData(),
                      decoration: InputDecoration(
                        hintText: "Cari nama tamu / token...",
                        hintStyle: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9CA3AF),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 18,
                          color: Color(0xFF778195),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    onSelected: (val) {
                      setState(() => _filterStatus = val);
                      _fetchDashboardData();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'Semua',
                        child: Text("Semua Data"),
                      ),
                      const PopupMenuItem(
                        value: 'Hari Ini',
                        child: Text("Data Hari Ini Aja"),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.filter_list,
                            size: 16,
                            color: Color(0xFF006B3F),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _filterStatus,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF172033),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ================= CONTENT LIST / LOADING / ERROR =================
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF006B3F)),
                  ),
                )
              else if (_errorMessage != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                )
              else if (_visits.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text(
                      "Tidak ada data reservasi yang ditemukan.",
                      style: TextStyle(color: Color(0xFF778195), fontSize: 12),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _visits.length,
                  itemBuilder: (context, index) {
                    final item = _visits[index];

                    final int visitId = item['id'] ?? 0;
                    final String visitCode = item['visit_code'] ?? '-';
                    final String guestName =
                        item['guest']?['name'] ?? 'Tamu Tanpa Nama';
                    final String companyName =
                        item['guest']?['company_name'] ?? '-';
                    final String purposeName = item['purpose']?['name'] ?? '-';
                    final String picName =
                        item['assigned_user']?['name'] ?? '-';
                    final String scheduledAtFormatted = _formatDateTime(
                      item['scheduled_at'],
                    );
                    final String currentStatus = item['status'] ?? 'Terjadwal';

                    final Color statusColor = _getStatusColor(currentStatus);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Token & Status Badge (Kanan Atas)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4F7FC),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  "No. ${index + 1} • $visitCode",
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF778195),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  currentStatus,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Data Tamu
                          Text(
                            guestName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF172033),
                            ),
                          ),
                          Text(
                            companyName,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF778195),
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Jadwal (D-M-Y HH:mm WIB)
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 13,
                                color: Color(0xFF006B3F),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Jadwal: $scheduledAtFormatted",
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF006B3F),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Keperluan
                          Row(
                            children: [
                              const Icon(
                                Icons.assignment_outlined,
                                size: 13,
                                color: Color(0xFF778195),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Keperluan: $purposeName",
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF778195),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),

                          // Tujuan PIC
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline_rounded,
                                size: 13,
                                color: Color(0xFF006B3F),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Tujuan PIC: $picName",
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF006B3F),
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                          ),

                          // Tombol Aksi / Indicator Status (Kanan Bawah)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (currentStatus == 'Terjadwal' ||
                                  currentStatus == 'waiting') ...[
                                OutlinedButton(
                                  onPressed: () => _processCheckIn(visitId),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 2,
                                    ),
                                    side: const BorderSide(color: Colors.green),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    minimumSize: const Size(40, 26),
                                  ),
                                  child: const Text(
                                    "Check-In",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                OutlinedButton(
                                  onPressed: () => _processCancel(visitId),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 2,
                                    ),
                                    side: const BorderSide(color: Colors.red),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    minimumSize: const Size(40, 26),
                                  ),
                                  child: const Text(
                                    "Batalkan",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ] else ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Status: $currentStatus',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                              ],
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
    );
  }
}