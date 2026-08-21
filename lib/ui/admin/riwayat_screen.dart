import 'package:flutter/material.dart';
import 'package:mobile_flutter/bloc/dashboard_admin_bloc.dart';
import 'package:mobile_flutter/ui/homepage_screen.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  final Color corporateGreen = const Color(0xFF006B3F);

  // State Management Data API Database & Pagination
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _daftarRiwayat = [];
  int _currentPage = 1;
  int _lastPage = 1;
  int _totalData = 0;
  int _perPage = 10;

  // State Notifikasi
  int _unreadNotifCount = 0;
  List<dynamic> _notifications = [];

  // Controller Search & Filter Tanggal
  final TextEditingController _searchController = TextEditingController();
  String? _selectedDateFilter; // Format: "YYYY-MM-DD"

  @override
  void initState() {
    super.initState();
    _fetchRiwayatData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Helper untuk format tanggal & jam (D-M-Y HH:mm WIB)
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
      case 'selesai':
      case 'completed':
      case 'deal':
        return Colors.green;
      case 'dibatalkan':
      case 'cancelled':
        return Colors.red;
      case 'menunggu':
      case 'proses':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  /// Memuat Data Riwayat & Notifikasi dari Database Backend
  Future<void> _fetchRiwayatData({int page = 1}) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String keywordQuery = _searchController.text.trim();

      // 1. Ambil data riwayat yang terpaginasi dari backend
      final dynamic historyData = await DashboardAdminBloc.getHistory(
        date: _selectedDateFilter,
        keyword: keywordQuery,
        page: page,
      );

      List<dynamic> visitList = [];
      int current = 1;
      int last = 1;
      int total = 0;
      int perPage = 10;

      if (historyData is Map) {
        if (historyData.containsKey('data')) {
          final dataProp = historyData['data'];
          if (dataProp is List) {
            visitList = dataProp;
          }
        } else {
          visitList = historyData['data'] ?? [];
        }
        current = historyData['current_page'] ?? 1;
        last = historyData['last_page'] ?? 1;
        total = historyData['total'] ?? visitList.length;
        perPage = historyData['per_page'] ?? 10;
      }

      // 2. Ambil data notifikasi jika di halaman pertama
      List<dynamic> unreadNotifs = _notifications;
      int unreadCount = _unreadNotifCount;

      if (page == 1) {
        try {
          final dynamic dashboardData = await DashboardAdminBloc.getDashboard(dateFilter: 'all');
          if (dashboardData is Map) {
            final statistics = dashboardData['statistics'] ?? {};
            final notifData = dashboardData['notifications'];

            List<dynamic> notifList = [];
            if (notifData is Map && notifData.containsKey('data')) {
              notifList = notifData['data'] ?? [];
            } else if (notifData is List) {
              notifList = notifData;
            }

            unreadNotifs = notifList.where((item) {
              return item['read_at'] == null;
            }).toList();

            unreadCount = statistics['unread_notifications'] ?? unreadNotifs.length;
          }
        } catch (ne) {
          debugPrint("Gagal memuat notifikasi riwayat: $ne");
        }
      }

      if (!mounted) return;
      setState(() {
        _daftarRiwayat = visitList;
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
      _fetchRiwayatData();
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
      _fetchRiwayatData();
    }
  }

  /// Pop-up Detail Arsip Kunjungan Dinamis
  void _showDetailRiwayatDialog(
      BuildContext context, Map<String, dynamic> item) {
    final Map<String, dynamic>? guest = item['guest'] is Map
        ? Map<String, dynamic>.from(item['guest'])
        : null;
    final Map<String, dynamic>? purpose = item['purpose'] is Map
        ? Map<String, dynamic>.from(item['purpose'])
        : null;
    final Map<String, dynamic>? assignedUser = item['assigned_user'] is Map
        ? Map<String, dynamic>.from(item['assigned_user'])
        : null;

    final String visitCode = item['visit_code']?.toString() ?? '-';
    final String currentStatus = item['status']?.toString() ?? '-';
    final String guestName = guest?['name']?.toString() ?? 'Tamu Tanpa Nama';
    final String companyName = guest?['company_name']?.toString() ?? '-';
    final String occupation = guest?['position']?.toString() ??
        guest?['jabatan']?.toString() ??
        '-';
    final String phoneNumber = guest?['phone_number']?.toString() ??
        guest?['phone']?.toString() ??
        '-';
    final String purposeName = purpose?['name']?.toString() ?? '-';
    final String picName = assignedUser?['name']?.toString() ?? '-';
    final String checkInTime = _formatDateTime(
        item['check_in_at']?.toString() ?? item['created_at']?.toString());
    final String checkOutTime =
        _formatDateTime(item['check_out_at']?.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.all(20),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Detail Arsip Kunjungan",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF172033),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const Divider(height: 12),

                // Icon Avatar
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.person_rounded,
                        size: 45,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Baris Informasi Lengkap
                _buildDetailRow("No. Token", visitCode),
                _buildDetailRow("Status Kelanjutan", currentStatus),
                _buildDetailRow("Nama Lengkap", guestName),
                _buildDetailRow("Asal Instansi", companyName),
                _buildDetailRow("Jabatan", occupation),
                _buildDetailRow("No. WhatsApp", phoneNumber),
                _buildDetailRow("Jenis Kunjungan", purposeName),
                _buildDetailRow("Tujuan PIC", picName),
                _buildDetailRow("Waktu Check-In", checkInTime),
                _buildDetailRow("Waktu Check-Out", checkOutTime),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: corporateGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Tutup",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF778195),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Text(": ", style: TextStyle(fontSize: 11)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF172033),
              ),
            ),
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
          "Admin - Riwayat Kunjungan",
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
            onPressed: () => _fetchRiwayatData(page: _currentPage),
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
                  final bool isRead = notif['read_at'] != null ||
                      (notif['is_read'] ?? false);

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
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
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
        onRefresh: () => _fetchRiwayatData(page: _currentPage),
        color: corporateGreen,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Arsip Data Kunjungan",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF172033),
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                "Cari dan tinjau riwayat seluruh tamu yang telah berkunjung",
                style: TextStyle(fontSize: 11, color: Color(0xFF778195)),
              ),
              const SizedBox(height: 14),

              // Search Bar
              TextField(
                controller: _searchController,
                onSubmitted: (_) => _fetchRiwayatData(),
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  hintText: "Cari nama tamu, instansi, atau PIC...",
                  hintStyle: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 18,
                    color: Color(0xFF778195),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Color(0xFF006B3F),
                    ),
                    onPressed: _fetchRiwayatData,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 10),

              // Filter Tanggal & Reset Button
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedDateFilter =
                                "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                          });
                          _fetchRiwayatData();
                        }
                      },
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
                              Icons.calendar_today_rounded,
                              size: 16,
                              color: Color(0xFF006B3F),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedDateFilter == null
                                  ? "Filter Tanggal..."
                                  : "Tanggal: $_selectedDateFilter",
                              style: TextStyle(
                                fontSize: 11,
                                color: _selectedDateFilter == null
                                    ? const Color(0xFF9CA3AF)
                                    : const Color(0xFF172033),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_selectedDateFilter != null) ...[
                    const SizedBox(width: 8),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedDateFilter = null;
                        });
                        _fetchRiwayatData();
                      },
                      child: const Text(
                        "Reset",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),

              // Dynamic List State Handling
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
              else if (_daftarRiwayat.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text(
                      "Tidak ada arsip riwayat kunjungan yang ditemukan.",
                      style: TextStyle(color: Color(0xFF778195), fontSize: 11),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _daftarRiwayat.length,
                  itemBuilder: (context, index) {
                    final dynamic itemRaw = _daftarRiwayat[index];
                    if (itemRaw is! Map) return const SizedBox.shrink();

                    final Map<String, dynamic> item =
                        Map<String, dynamic>.from(itemRaw);

                    final String visitCode =
                        item['visit_code']?.toString() ?? '-';
                    final Map<String, dynamic>? guest = item['guest'] is Map
                        ? Map<String, dynamic>.from(item['guest'])
                        : null;
                    final String guestName =
                        guest?['name']?.toString() ?? 'Tamu Tanpa Nama';
                    final String companyName =
                        guest?['company_name']?.toString() ?? '-';
                    final String occupation = guest?['position']?.toString() ??
                        guest?['jabatan']?.toString() ??
                        '-';

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
                        item['scheduled_at']?.toString() ??
                            item['created_at']?.toString());
                    final String currentStatus =
                        item['status']?.toString() ?? 'Selesai';
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
                            "$occupation • $companyName",
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
                                "Waktu: $scheduledAtFormatted",
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
                                "Jenis: $purposeName",
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () =>
                                    _showDetailRiwayatDialog(context, item),
                                icon: const Icon(
                                  Icons.visibility_outlined,
                                  size: 12,
                                  color: Color(0xFF006B3F),
                                ),
                                label: const Text(
                                  "Detail",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF006B3F),
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  side: BorderSide(color: corporateGreen),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  minimumSize: const Size(40, 24),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              if (!_isLoading && _errorMessage == null && _daftarRiwayat.isNotEmpty) ...[
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
                onPressed: _currentPage > 1 ? () => _fetchRiwayatData(page: 1) : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                color: corporateGreen,
                disabledColor: Colors.grey.shade300,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 18),
                onPressed: _currentPage > 1
                    ? () => _fetchRiwayatData(page: _currentPage - 1)
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
                    ? () => _fetchRiwayatData(page: _currentPage + 1)
                    : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                color: corporateGreen,
                disabledColor: Colors.grey.shade300,
              ),
              IconButton(
                icon: const Icon(Icons.last_page, size: 18),
                onPressed: _currentPage < _lastPage
                    ? () => _fetchRiwayatData(page: _lastPage)
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
          onTap: isCurrent ? null : () => _fetchRiwayatData(page: i),
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