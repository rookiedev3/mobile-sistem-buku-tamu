import 'package:flutter/material.dart';
import 'package:mobile_flutter/bloc/dashboard_admin_bloc.dart';
import 'package:mobile_flutter/services/notification_service.dart';
import 'form_tambah_janji_dialog.dart';

class JanjiTamuScreen extends StatefulWidget {
  const JanjiTamuScreen({super.key});

  @override
  State<JanjiTamuScreen> createState() => _JanjiTamuScreenState();
}

class _JanjiTamuScreenState extends State<JanjiTamuScreen> {
  final Color corporateGreen = const Color(0xFF006B3F);

  // State Management Data Database API
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _daftarJanji = [];

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
  Future<void> _fetchJanjiData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String dateFilterParam = _filterStatus == 'Hari Ini' ? 'today' : 'all';

      // Aman dari error membaca controller.text jika belum siap/disposed
      final String keywordQuery = _searchController.text.trim();

      final data = await DashboardAdminBloc.getDashboard(
        dateFilter: dateFilterParam,
        keyword: keywordQuery,
      );

      // Defensive Parsing JSON API
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
      if (visitsData is Map && visitsData.containsKey('data') && visitsData['data'] != null) {
        visitList = visitsData['data'] is List ? visitsData['data'] : [];
      } else if (visitsData is List) {
        visitList = visitsData;
      } else if (targetData is List) {
        visitList = targetData;
      }

      if (!mounted) return;
      setState(() {
        _daftarJanji = visitList;
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
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchJanjiData,
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
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Kelola jadwal kedatangan dan reservasi tamu",
                          style: TextStyle(fontSize: 11, color: Color(0xFF778195)),
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      final dynamic rawResult = await showDialog(
                        context: context,
                        builder: (context) => const FormTambahJanjiDialog(),
                      );

                      if (rawResult != null) {
                        _fetchJanjiData();

                        String namaTamu = 'Tamu Baru';
                        String jam = '-';

                        if (rawResult is Map) {
                          namaTamu = (rawResult['nama'] ?? rawResult['name'] ?? 'Tamu Baru').toString();
                          jam = (rawResult['jam'] ?? '-').toString();
                        }

                        await NotificationService.showNotification(
                          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                          title: 'Janji Temu Berhasil Dibuat! 📅',
                          body: 'Janji temu untuk $namaTamu pada $jam telah ditambahkan.',
                        );
                      }
                    },
                    icon: const Icon(Icons.add, size: 14),
                    label: const Text("Buat Janji", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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
                        hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                        prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF778195)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
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
                      const PopupMenuItem(value: 'Semua', child: Text("Semua Data")),
                      const PopupMenuItem(value: 'Hari Ini', child: Text("Hari Ini Saja")),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.filter_list, size: 16, color: Color(0xFF006B3F)),
                          const SizedBox(width: 4),
                          Text(_filterStatus, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF172033))),
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
                  child: Center(child: CircularProgressIndicator(color: Color(0xFF006B3F))),
                )
              else if (_errorMessage != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ),
                )
              else if (_daftarJanji.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text("Tidak ada data janji temu ditemukan di database.", style: TextStyle(color: Color(0xFF778195), fontSize: 11)),
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

                    final Map<String, dynamic> item = Map<String, dynamic>.from(itemRaw);

                    final int visitId = item['id'] is int ? item['id'] : int.tryParse(item['id']?.toString() ?? '0') ?? 0;
                    final String visitCode = item['visit_code']?.toString() ?? '-';

                    final Map<String, dynamic>? guest = item['guest'] is Map ? Map<String, dynamic>.from(item['guest']) : null;
                    final String guestName = guest?['name']?.toString() ?? 'Tamu Tanpa Nama';
                    final String companyName = guest?['company_name']?.toString() ?? '-';

                    final Map<String, dynamic>? purpose = item['purpose'] is Map ? Map<String, dynamic>.from(item['purpose']) : null;
                    final String purposeName = purpose?['name']?.toString() ?? '-';

                    final Map<String, dynamic>? assignedUser = item['assigned_user'] is Map ? Map<String, dynamic>.from(item['assigned_user']) : null;
                    final String picName = assignedUser?['name']?.toString() ?? '-';

                    final String scheduledAtFormatted = _formatDateTime(item['scheduled_at']?.toString());
                    final String currentStatus = item['status']?.toString() ?? 'Terjadwal';

                    final Color statusColor = _getStatusColor(currentStatus);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(4)),
                                child: Text("No. ${index + 1} • $visitCode", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF778195))),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                          Text(guestName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF172033))),
                          Text(companyName, style: const TextStyle(fontSize: 10, color: Color(0xFF778195))),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.access_time_rounded, size: 12, color: Color(0xFF006B3F)),
                              const SizedBox(width: 4),
                              Text("Jadwal: $scheduledAtFormatted", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF006B3F))),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.assignment_outlined, size: 12, color: Color(0xFF778195)),
                              const SizedBox(width: 4),
                              Text("Jenis Kunjungan: $purposeName", style: const TextStyle(fontSize: 10, color: Color(0xFF778195))),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.person_outline_rounded, size: 12, color: Color(0xFF006B3F)),
                              const SizedBox(width: 4),
                              Text("Tujuan PIC: $picName", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF006B3F))),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 6.0),
                            child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                          ),
                          // Tombol Aksi Kunjungan
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (currentStatus == 'Terjadwal' || currentStatus == 'waiting') ...[
                                OutlinedButton.icon(
                                  onPressed: () => _processCheckIn(visitId),
                                  icon: const Icon(Icons.check_circle_outline, size: 12, color: Colors.green),
                                  label: const Text("Check-In", style: TextStyle(fontSize: 10, color: Colors.green)),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    side: const BorderSide(color: Colors.green),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    minimumSize: const Size(40, 24),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                OutlinedButton.icon(
                                  onPressed: () => _processCancel(visitId),
                                  icon: const Icon(Icons.cancel_outlined, size: 12, color: Colors.red),
                                  label: const Text("Batalkan", style: TextStyle(fontSize: 10, color: Colors.red)),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    side: const BorderSide(color: Colors.red),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    minimumSize: const Size(40, 24),
                                  ),
                                ),
                              ] else ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Status: $currentStatus',
                                    style: TextStyle(
                                      fontSize: 10,
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