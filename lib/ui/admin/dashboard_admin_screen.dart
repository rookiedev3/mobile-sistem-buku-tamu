import 'package:flutter/material.dart';
import 'package:mobile_flutter/bloc/dashboard_admin_bloc.dart';
import 'package:mobile_flutter/services/notification_service.dart';
import 'package:mobile_flutter/ui/homepage_screen.dart';
import 'form_tambah_janji_dialog.dart';

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
  int _unreadNotifCount = 0;

  List<dynamic> _visits = [];
  List<dynamic> _notifications = [];

  // State Filter & Search
  String _filterStatus = 'Semua';
  final TextEditingController _searchController = TextEditingController();

  // 🆕 State Pagination — supaya tidak "nyangkut" di halaman lama saat
  // keyword pencarian / filter status berganti.
  int _currentPage = 1;
  int _lastPage = 1;
  int _totalData = 0;
  int _perPage = 10; // fallback jika API tidak mengirim field per_page

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
  ///
  /// [page] menentukan halaman data yang diambil. Saat parameter ini tidak
  /// diberikan, dianggap tetap di halaman yang sedang aktif (`_currentPage`).
  /// Gunakan [resetPage] = true setiap kali keyword pencarian atau filter
  /// status berubah, supaya pagination selalu mulai lagi dari halaman 1 dan
  /// tidak menampilkan data kosong akibat nyangkut di halaman lama.
  Future<void> _fetchDashboardData({int? page, bool resetPage = false}) async {
    final int targetPage = resetPage ? 1 : (page ?? _currentPage);

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = targetPage;
    });

    try {
      final String dateFilterParam = _filterStatus == 'Hari Ini'
          ? 'today'
          : 'all';

      final data = await DashboardAdminBloc.getDashboard(
        dateFilter: dateFilterParam,
        keyword: _searchController.text.trim(),
        page: targetPage,
      );

      final statistics = data['statistics'] ?? {};
      final visitsData = data['visits'];
      final notifData = data['notifications'];

      // Parsing data kunjungan + meta pagination (struktur Laravel paginator:
      // { data: [...], current_page, last_page, total, ... })
      List<dynamic> visitList = [];
      int parsedCurrentPage = targetPage;
      int parsedLastPage = 1;
      int parsedTotal = 0;
      int parsedPerPage = _perPage;

      if (visitsData is Map && visitsData.containsKey('data')) {
        visitList = visitsData['data'] ?? [];
        parsedCurrentPage =
            (visitsData['current_page'] as num?)?.toInt() ?? targetPage;
        parsedLastPage = (visitsData['last_page'] as num?)?.toInt() ?? 1;
        parsedTotal =
            (visitsData['total'] as num?)?.toInt() ?? visitList.length;
        parsedPerPage =
            (visitsData['per_page'] as num?)?.toInt() ??
            (visitList.isNotEmpty ? visitList.length : _perPage);
      } else if (visitsData is List) {
        visitList = visitsData;
        parsedLastPage = 1;
        parsedTotal = visitList.length;
        parsedPerPage = visitList.isNotEmpty ? visitList.length : _perPage;
      }

      // Parsing data notifikasi
      List<dynamic> notifList = [];
      if (notifData is Map && notifData.containsKey('data')) {
        notifList = notifData['data'] ?? [];
      } else if (notifData is List) {
        notifList = notifData;
      }

      // Filter hanya notifikasi yang belum dibaca (read_at == null)
      List<dynamic> unreadNotifs = notifList.where((item) {
        return item['read_at'] == null;
      }).toList();

      if (!mounted) return;

      setState(() {
        _totalToday = statistics['total_today'] ?? 0;
        _unfinishedTodayCount = statistics['unfinished_today'] ?? 0;
        _unreadNotifCount = statistics['unread_notifications'] ?? 0;

        _visits = visitList;
        _notifications = unreadNotifs;

        _currentPage = parsedCurrentPage;
        _lastPage = parsedLastPage < 1 ? 1 : parsedLastPage;
        _totalData = parsedTotal;
        _perPage = parsedPerPage > 0 ? parsedPerPage : _perPage;

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Pindah ke halaman berikutnya (kalau belum di halaman terakhir).
  void _goToNextPage() {
    if (_isLoading || _currentPage >= _lastPage) return;
    _fetchDashboardData(page: _currentPage + 1);
  }

  /// Pindah ke halaman sebelumnya (kalau belum di halaman pertama).
  void _goToPreviousPage() {
    if (_isLoading || _currentPage <= 1) return;
    _fetchDashboardData(page: _currentPage - 1);
  }

  /// Tandai 1 Notifikasi Dibaca
  Future<void> _markNotificationAsRead(String notifId) async {
    // 1. Update UI lokal secara langsung (Optimistic UI)
    setState(() {
      for (var notif in _notifications) {
        if (notif['id']?.toString() == notifId) {
          notif['read_at'] = DateTime.now().toIso8601String();
          notif['is_read'] = true;
        }
      }
      if (_unreadNotifCount > 0) {
        _unreadNotifCount--;
      }
    });

    // 2. Kirim perubahan ke API Backend
    try {
      await DashboardAdminBloc.markNotificationAsRead(notifId);
    } catch (e) {
      debugPrint('Gagal menandai notifikasi dibaca: $e');
      _fetchDashboardData();
    }
  }

  /// Tandai Semua Notifikasi Dibaca
  Future<void> _markAllNotificationsAsRead() async {
    // 1. Update UI lokal secara langsung
    setState(() {
      for (var notif in _notifications) {
        notif['read_at'] = DateTime.now().toIso8601String();
        notif['is_read'] = true;
      }
      _unreadNotifCount = 0;
    });

    // 2. Kirim perubahan ke API Backend
    try {
      await DashboardAdminBloc.markAllNotificationsAsRead();
    } catch (e) {
      debugPrint('Gagal menandai semua notifikasi dibaca: $e');
      _fetchDashboardData();
    }
  }

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
      // Tetap di halaman yang sama setelah check-in, bukan reset ke halaman 1.
      _fetchDashboardData(page: _currentPage);
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

  Future<void> _processCheckOut(int visitId) async {
    try {
      await DashboardAdminBloc.checkOut(visitId);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil melakukan Check-Out tamu!'),
          backgroundColor: Color(0xFF006B3F),
        ),
      );
      // Tetap di halaman yang sama setelah check-out
      _fetchDashboardData(page: _currentPage);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal Check-Out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
      // Tetap di halaman yang sama setelah pembatalan, bukan reset ke halaman 1.
      _fetchDashboardData(page: _currentPage);
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
          // ================= TOMBOL REFRESH DATA =================
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh Data',
            onPressed: () => _fetchDashboardData(page: _currentPage),
          ),

          // ================= DROPDOWN NOTIFIKASI DATABASE =================
          PopupMenuButton<String>(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, color: Colors.white),
                if (_unreadNotifCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 8,
                        minHeight: 8,
                      ),
                    ),
                  ),
              ],
            ),
            offset: const Offset(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (BuildContext context) {
              List<PopupMenuEntry<String>> items = [];

              // Header Dropdown Notifikasi
              items.add(
                PopupMenuItem<String>(
                  enabled: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Notifikasi Baru",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF172033),
                        ),
                      ),
                      if (_unreadNotifCount > 0)
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            _markAllNotificationsAsRead();
                          },
                          child: const Text(
                            "Tandai semua dibaca",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF006B3F),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );

              items.add(const PopupMenuDivider());

              // Render Notifikasi dari API Database
              if (_notifications.isEmpty) {
                items.add(
                  const PopupMenuItem<String>(
                    enabled: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "Tidak ada notifikasi baru.",
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ),
                  ),
                );
              } else {
                for (var notif in _notifications) {
                  final String notifId = notif['id']?.toString() ?? '0';
                  final String title = notif['title'] ?? 'Notifikasi';
                  final String body = notif['body'] ?? '-';
                  final String time = notif['created_at'] ?? '-';
                  final bool isRead =
                      notif['read_at'] != null || (notif['is_read'] ?? false);

                  items.add(
                    PopupMenuItem<String>(
                      value: notifId,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isRead
                                    ? Colors.grey.withValues(alpha: 0.1)
                                    : const Color(
                                        0xFF006B3F,
                                      ).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.notifications_active_rounded,
                                size: 16,
                                color: isRead
                                    ? Colors.grey
                                    : const Color(0xFF006B3F),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isRead
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                      color: const Color(0xFF172033),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    body,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF778195),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    time,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isRead)
                              IconButton(
                                icon: const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Color(0xFF006B3F),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  _markNotificationAsRead(notifId);
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              }

              return items;
            },
            onSelected: (String notifId) {
              _markNotificationAsRead(notifId);
            },
          ),

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
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchDashboardData(page: _currentPage),
        color: const Color(0xFF006B3F),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

                      if (rawResult != null && rawResult is Map) {
                        try {
                          await DashboardAdminBloc.storeAppointment(
                            name: (rawResult['nama'] ?? '').toString(),
                            companyName: (rawResult['instansi'] ?? '')
                                .toString(),
                            phone: (rawResult['phone'] ?? '').toString(),
                            scheduledAt: (rawResult['scheduled_at'] ?? '')
                                .toString(),
                            purposeId: rawResult['purpose_id'] as int,
                            assignedTo: rawResult['staff_id'] as int,
                            branchId: rawResult['branch_id'] as int,
                          );

                          // Data baru biasanya muncul di halaman pertama,
                          // jadi kita reset paginasi setelah berhasil menambah.
                          _fetchDashboardData(resetPage: true);

                          String namaTamu = (rawResult['nama'] ?? 'Tamu Baru')
                              .toString();
                          String jam = (rawResult['jam'] ?? '-').toString();

                          await NotificationService.showNotification(
                            id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                            title: 'Janji Temu Berhasil Dibuat! 📅',
                            body:
                                'Janji temu untuk $namaTamu pada $jam telah ditambahkan.',
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Gagal membuat janji temu: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                    icon: const Icon(Icons.add, size: 14),
                    label: const Text(
                      "Tambah Janji",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      // 🆕 Reset ke halaman 1 setiap kali submit pencarian,
                      // supaya tidak nyangkut di halaman lama yang mungkin
                      // sudah tidak relevan / kosong untuk keyword baru.
                      onSubmitted: (_) => _fetchDashboardData(resetPage: true),
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
                      // 🆕 Reset ke halaman 1 setiap kali filter status berubah.
                      _fetchDashboardData(resetPage: true);
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

                    // Nomor urut mengikuti halaman aktif (pakai per_page dari
                    // API, bukan jumlah item di halaman ini saja — supaya
                    // tetap benar walau halaman terakhir jumlah itemnya
                    // lebih sedikit dari halaman-halaman sebelumnya).
                    final int displayNumber =
                        ((_currentPage - 1) * _perPage) + index + 1;

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
                                  "No. $displayNumber • $visitCode",
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

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // 1. Kondisi Status: Terjadwal / Waiting -> Muncul Check-In & Batalkan
                              if (currentStatus.toLowerCase() == 'terjadwal' ||
                                  currentStatus.toLowerCase() == 'waiting') ...[
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
                              ] 
                              // 2. Kondisi Status: Menunggu / Proses -> Muncul Check-Out
                              else if (currentStatus.toLowerCase() == 'meeting selesai' ||
                                  currentStatus.toLowerCase() == 'proses') ...[
                                ElevatedButton.icon(
                                  onPressed: () => _processCheckOut(visitId),
                                  icon: const Icon(Icons.logout_rounded, size: 14),
                                  label: const Text(
                                    "Check-Out",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange.shade800,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    minimumSize: const Size(40, 28),
                                  ),
                                ),
                              ] 
                              // 3. Status Selesai / Dibatalkan -> Hanya Tampilkan Badge Status
                              else ...[
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

              // 🆕 Kontrol Pagination (Sebelumnya / Halaman X dari Y / Berikutnya)
              if (!_isLoading && _errorMessage == null && _visits.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _currentPage > 1 ? _goToPreviousPage : null,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          side: BorderSide(
                            color: _currentPage > 1
                                ? const Color(0xFF006B3F)
                                : const Color(0xFFE2E8F0),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: Icon(
                          Icons.chevron_left,
                          size: 16,
                          color: _currentPage > 1
                              ? const Color(0xFF006B3F)
                              : const Color(0xFF9CA3AF),
                        ),
                        label: Text(
                          "Sebelumnya",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _currentPage > 1
                                ? const Color(0xFF006B3F)
                                : const Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            "Halaman $_currentPage dari $_lastPage",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF172033),
                            ),
                          ),
                          Text(
                            "$_totalData total data",
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF778195),
                            ),
                          ),
                        ],
                      ),
                      OutlinedButton.icon(
                        onPressed: _currentPage < _lastPage
                            ? _goToNextPage
                            : null,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          side: BorderSide(
                            color: _currentPage < _lastPage
                                ? const Color(0xFF006B3F)
                                : const Color(0xFFE2E8F0),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: _currentPage < _lastPage
                              ? const Color(0xFF006B3F)
                              : const Color(0xFF9CA3AF),
                        ),
                        label: Text(
                          "Berikutnya",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _currentPage < _lastPage
                                ? const Color(0xFF006B3F)
                                : const Color(0xFF9CA3AF),
                          ),
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
