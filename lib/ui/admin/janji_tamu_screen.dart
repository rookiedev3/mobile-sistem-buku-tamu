import 'package:flutter/material.dart';
import 'package:mobile_flutter/bloc/dashboard_admin_bloc.dart';
import 'package:mobile_flutter/services/notification_service.dart';
import 'package:mobile_flutter/ui/homepage_screen.dart';
import 'form_tambah_janji_dialog.dart';

class JanjiTamuScreen extends StatefulWidget {
  const JanjiTamuScreen({super.key});

  @override
  State<JanjiTamuScreen> createState() => _JanjiTamuScreenState();
}

class _JanjiTamuScreenState extends State<JanjiTamuScreen> {
  final Color corporateGreen = const Color(0xFF006B3F);

  // State Management Data Database API & Pagination
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _daftarJanji = [];
  int _currentPage = 1;
  int _lastPage = 1;
  int _totalData = 0;
  int _perPage = 10;

  // State Notifikasi
  int _unreadNotifCount = 0;
  List<dynamic> _notifications = [];

  // Filter Status & Controller Search
  String _filterStatus = 'Semua';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchJanjiData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Helper format tanggal & jam (D-M-Y HH:mm WIB)
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

  /// Helper penentuan warna status dinamis
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

  /// Memuat Data dari Database Backend via DashboardAdminBloc
  Future<void> _fetchJanjiData({int page = 1}) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String dateFilterParam = _filterStatus == 'Hari Ini'
          ? 'today'
          : 'all';
      final String keywordQuery = _searchController.text.trim();

      final data = await DashboardAdminBloc.getDashboard(
        dateFilter: dateFilterParam,
        keyword: keywordQuery,
        page: page,
      );

      // Parsing Kunjungan
      dynamic targetData = data;
      if (data is Map && data.containsKey('data') && data['data'] != null) {
        if (data['data'] is Map) {
          targetData = data['data'];
        }
      }

      dynamic visitsData;
      if (targetData is Map) {
        visitsData = targetData['visits'];
      }

      List<dynamic> visitList = [];
      int current = 1;
      int last = 1;
      int total = 0;
      int perPage = 10;

      if (visitsData is Map &&
          visitsData.containsKey('data') &&
          visitsData['data'] != null) {
        visitList = visitsData['data'] is List ? visitsData['data'] : [];
        current = visitsData['current_page'] ?? 1;
        last = visitsData['last_page'] ?? 1;
        total = visitsData['total'] ?? visitList.length;
        perPage = visitsData['per_page'] ?? 10;
      } else if (visitsData is List) {
        visitList = visitsData;
      } else if (targetData is List) {
        visitList = targetData;
      }

      // Parsing Notifikasi
      final statistics = data['statistics'] ?? {};
      final notifData = data['notifications'];

      List<dynamic> notifList = [];
      if (notifData is Map && notifData.containsKey('data')) {
        notifList = notifData['data'] ?? [];
      } else if (notifData is List) {
        notifList = notifData;
      }

      List<dynamic> unreadNotifs = notifList.where((item) {
        return item['read_at'] == null;
      }).toList();

      int unreadCount =
          statistics['unread_notifications'] ?? unreadNotifs.length;

      if (!mounted) return;
      setState(() {
        _daftarJanji = visitList;
        _currentPage = current;
        _lastPage = last;
        _totalData = total;
        _perPage = perPage;
        _notifications = unreadNotifs;
        _unreadNotifCount = unreadCount;
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

  /// Tandai 1 Notifikasi Dibaca
  Future<void> _markNotificationAsRead(String notifId) async {
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

    try {
      await DashboardAdminBloc.markNotificationAsRead(notifId);
    } catch (e) {
      debugPrint('Gagal menandai notifikasi dibaca: $e');
      _fetchJanjiData();
    }
  }

  /// Tandai Semua Notifikasi Dibaca
  Future<void> _markAllNotificationsAsRead() async {
    setState(() {
      for (var notif in _notifications) {
        notif['read_at'] = DateTime.now().toIso8601String();
        notif['is_read'] = true;
      }
      _unreadNotifCount = 0;
    });

    try {
      await DashboardAdminBloc.markAllNotificationsAsRead();
    } catch (e) {
      debugPrint('Gagal menandai semua notifikasi dibaca: $e');
      _fetchJanjiData();
    }
  }

  /// Memproses Check-In Kunjungan ke Database
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
      _fetchJanjiData();
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
      // Panggil _fetchJanjiData sesuai dengan nama method di class ini
      _fetchJanjiData(page: _currentPage);
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

  /// Memproses Pembatalan Kunjungan di Database
  Future<void> _processCancel(int visitId) async {
    try {
      await DashboardAdminBloc.cancel(visitId);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Janji tamu berhasil dibatalkan.'),
          backgroundColor: Color(0xFF006B3F),
        ),
      );
      _fetchJanjiData();
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
        backgroundColor: corporateGreen,
        elevation: 0,
        title: const Text(
          "Admin - Janji Tamu & Reservasi",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          // ================= 1. TOMBOL REFRESH DATA =================
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh Data',
            onPressed: () => _fetchJanjiData(page: _currentPage),
          ),

          // ================= 2. DROPDOWN NOTIFIKASI =================
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
                          child: Text(
                            "Tandai semua dibaca",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: corporateGreen,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );

              items.add(const PopupMenuDivider());

              // Render Notifikasi dari Backend API
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
                                    : corporateGreen.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.notifications_active_rounded,
                                size: 16,
                                color: isRead ? Colors.grey : corporateGreen,
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
                                icon: Icon(
                                  Icons.check,
                                  size: 14,
                                  color: corporateGreen,
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

          // ================= 3. TOMBOL LOGOUT =================
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Keluar',
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
        onRefresh: () => _fetchJanjiData(page: _currentPage),
        color: corporateGreen,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Tombol Buat Janji Tamu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Daftar Janji Tamu Terjadwal",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF172033),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Kelola jadwal kedatangan dan reservasi tamu",
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF778195),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: corporateGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
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

                          _fetchJanjiData();

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
                      "Buat Janji",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Search Bar & Filter Status Dropdown
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: (_) => _fetchJanjiData(),
                      style: const TextStyle(fontSize: 12),
                      decoration: InputDecoration(
                        hintText: "Cari nama tamu, token, atau PIC...",
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
                      _fetchJanjiData();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'Semua',
                        child: Text("Semua Data"),
                      ),
                      const PopupMenuItem(
                        value: 'Hari Ini',
                        child: Text("Hari Ini Saja"),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
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

              // Content State (Loading / Error / Empty / List Data API)
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
              else if (_daftarJanji.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text(
                      "Tidak ada data janji temu ditemukan di database.",
                      style: TextStyle(color: Color(0xFF778195), fontSize: 11),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _daftarJanji.length,
                  itemBuilder: (context, index) {
                    final dynamic itemRaw = _daftarJanji[index];
                    if (itemRaw is! Map) return const SizedBox.shrink();

                    final Map<String, dynamic> item = Map<String, dynamic>.from(
                      itemRaw,
                    );

                    final int visitId = item['id'] is int
                        ? item['id']
                        : int.tryParse(item['id']?.toString() ?? '0') ?? 0;
                    final String visitCode =
                        item['visit_code']?.toString() ?? '-';

                    final Map<String, dynamic>? guest = item['guest'] is Map
                        ? Map<String, dynamic>.from(item['guest'])
                        : null;
                    final String guestName =
                        guest?['name']?.toString() ?? 'Tamu Tanpa Nama';
                    final String companyName =
                        guest?['company_name']?.toString() ?? '-';

                    final Map<String, dynamic>? purpose = item['purpose'] is Map
                        ? Map<String, dynamic>.from(item['purpose'])
                        : null;
                    final String purposeName =
                        purpose?['name']?.toString() ?? '-';

                    final Map<String, dynamic>? assignedUser =
                        item['assigned_user'] is Map
                        ? Map<String, dynamic>.from(item['assigned_user'])
                        : null;
                    final String picName =
                        assignedUser?['name']?.toString() ?? '-';

                    final String scheduledAtFormatted = _formatDateTime(
                      item['scheduled_at']?.toString(),
                    );
                    final String currentStatus =
                        item['status']?.toString() ?? 'Terjadwal';

                    final Color statusColor = _getStatusColor(currentStatus);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
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
                                  "No. ${((_currentPage - 1) * _perPage) + index + 1} • $visitCode",
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
                                  vertical: 2,
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
                              fontSize: 12,
                              color: Color(0xFF172033),
                            ),
                          ),
                          Text(
                            companyName,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF778195),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 12,
                                color: Color(0xFF006B3F),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Jadwal: $scheduledAtFormatted",
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF006B3F),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.assignment_outlined,
                                size: 12,
                                color: Color(0xFF778195),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Jenis Kunjungan: $purposeName",
                                style: const TextStyle(
                                  fontSize: 10,
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
                                size: 12,
                                color: Color(0xFF006B3F),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Tujuan PIC: $picName",
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF006B3F),
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 6.0),
                            child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                          ),

                          // Tombol Aksi Kunjungan
                          // Tombol Aksi Kunjungan
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
                              // 2. Kondisi Status: Menunggu / Proses / Meeting Selesai -> Muncul Check-Out
                             else if (currentStatus.toLowerCase() == 'meeting selesai' ||
                                  currentStatus.toLowerCase() == 'proses') ...[
                                ElevatedButton.icon(
                                  onPressed: () => _processCheckOut(visitId),
                                  icon: const Icon(
                                    Icons.logout_rounded,
                                    size: 14,
                                  ),
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
              if (!_isLoading &&
                  _errorMessage == null &&
                  _daftarJanji.isNotEmpty) ...[
                const SizedBox(height: 10),
                _buildPaginationControl(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationControl() {
    int startItem = _totalData == 0 ? 0 : ((_currentPage - 1) * _perPage) + 1;
    int endItem = (_currentPage * _perPage) > _totalData
        ? _totalData
        : (_currentPage * _perPage);

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Menampilkan $startItem-$endItem dari $_totalData data",
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF778195),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "Hal $_currentPage dari $_lastPage",
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF172033),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.first_page, size: 18),
                onPressed: _currentPage > 1
                    ? () => _fetchJanjiData(page: 1)
                    : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                color: corporateGreen,
                disabledColor: Colors.grey.shade300,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 18),
                onPressed: _currentPage > 1
                    ? () => _fetchJanjiData(page: _currentPage - 1)
                    : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                color: corporateGreen,
                disabledColor: Colors.grey.shade300,
              ),
              const SizedBox(width: 6),
              ..._buildPageNumbers(),
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 18),
                onPressed: _currentPage < _lastPage
                    ? () => _fetchJanjiData(page: _currentPage + 1)
                    : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                color: corporateGreen,
                disabledColor: Colors.grey.shade300,
              ),
              IconButton(
                icon: const Icon(Icons.last_page, size: 18),
                onPressed: _currentPage < _lastPage
                    ? () => _fetchJanjiData(page: _lastPage)
                    : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                color: corporateGreen,
                disabledColor: Colors.grey.shade300,
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    List<Widget> pageButtons = [];
    int start = _currentPage - 1;
    int end = _currentPage + 1;

    if (start < 1) {
      start = 1;
      end = start + 2;
    }
    if (end > _lastPage) {
      end = _lastPage;
      start = end - 2;
      if (start < 1) start = 1;
    }

    for (int i = start; i <= end; i++) {
      final bool isCurrent = (i == _currentPage);
      pageButtons.add(
        InkWell(
          onTap: isCurrent ? null : () => _fetchJanjiData(page: i),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isCurrent ? corporateGreen : const Color(0xFFF4F7FC),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isCurrent ? corporateGreen : const Color(0xFFE2E8F0),
              ),
            ),
            child: Text(
              "$i",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isCurrent ? Colors.white : const Color(0xFF172033),
              ),
            ),
          ),
        ),
      );
    }
    return pageButtons;
  }
}
