import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_flutter/ui/homepage_screen.dart';
import 'package:mobile_flutter/model/pic_model.dart';
import 'package:mobile_flutter/bloc/pic_bloc.dart';
import 'package:mobile_flutter/bloc/logout_bloc.dart';

/// Formatter buat nampilin angka pakai titik ribuan saat diketik,
/// contoh: user ngetik "100000" -> tampil "100.000".
/// Value yang tersimpan di controller.text TETAP string berformat titik,
/// jadi wajib di-strip titiknya lagi sebelum di-parse ke num (lihat
/// bagian onPressed tombol Simpan di _showCatatHasilDialog).
class _RibuanInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return const TextEditingValue(text: '');

    final formatted = digitsOnly.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

String _formatRibuan(num value) {
  if (value <= 0) return '';
  return value.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );
}

class DashboardPICScreen extends StatefulWidget {
  const DashboardPICScreen({Key? key}) : super(key: key);

  @override
  State<DashboardPICScreen> createState() => _DashboardPICScreenState();
}

class _DashboardPICScreenState extends State<DashboardPICScreen>
    with SingleTickerProviderStateMixin {
  final Color corporateGreen = const Color(0xFF006B3F);
  late TabController _tabController;

  String _filterKategori = 'Semua Kategori'; // Semua / VIP / Reguler

  static const int _perPage = 10;

  final Map<int, List<PicVisitModel>> _dataPerTab = {0: [], 1: [], 2: []};
  final Map<int, bool> _loadingPerTab = {0: true, 1: true, 2: true};
  final Map<int, String?> _errorPerTab = {0: null, 1: null, 2: null};
  int _totalVip = 0;
  int _totalReguler = 0;

  // === STATE NOTIFIKASI ===
  int _unreadNotifCount = 0;
  List<dynamic> _notifications = [];

  // === PAGINATION STATE ===
  final Map<int, int> _currentPagePerTab = {0: 1, 1: 1, 2: 1};
  final Map<int, int> _lastPagePerTab = {0: 1, 1: 1, 2: 1};

  static const List<String> _tabFilters = ['all', 'today', 'upcoming'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadTab(_tabController.index);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final alreadyLoaded =
        (_dataPerTab[_tabController.index]?.isNotEmpty ?? false) &&
            _errorPerTab[_tabController.index] == null;
    if (!alreadyLoaded) {
      _loadTab(_tabController.index);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  String get _vipStatusParam {
    if (_filterKategori == 'VIP') return 'vip';
    if (_filterKategori == 'Reguler') return 'reguler';
    return 'all';
  }

  int _countFor(int tabIndex) => _dataPerTab[tabIndex]?.length ?? 0;

  Future<void> _loadTab(int tabIndex, {int page = 1}) async {
    if (!mounted) return;
    setState(() {
      _loadingPerTab[tabIndex] = true;
      _errorPerTab[tabIndex] = null;
    });

    try {
      final result = await PicBloc.dashboard(
        filter: _tabFilters[tabIndex],
        vipStatus: _vipStatusParam,
        page: page,
        perPage: _perPage,
      );

      if (!mounted) return;
      setState(() {
        _dataPerTab[tabIndex] = result.visits;
        _totalVip = result.vipCount;
        _totalReguler = result.regularCount;
        _currentPagePerTab[tabIndex] = result.currentPage;
        _lastPagePerTab[tabIndex] = result.lastPage;
        _notifications = result.notifications;
        _unreadNotifCount = result.unreadNotifications;
        _loadingPerTab[tabIndex] = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorPerTab[tabIndex] = e is ApiException
            ? e.message
            : 'Gagal memuat data. Periksa koneksi Anda.';
        _loadingPerTab[tabIndex] = false;
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
      await PicBloc.markNotificationAsRead(notifId);
    } catch (e) {
      debugPrint('Gagal menandai notifikasi dibaca: $e');
      _loadTab(_tabController.index, page: _currentPagePerTab[_tabController.index] ?? 1);
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
      await PicBloc.markAllNotificationsAsRead();
    } catch (e) {
      debugPrint('Gagal menandai semua notifikasi dibaca: $e');
      _loadTab(_tabController.index, page: _currentPagePerTab[_tabController.index] ?? 1);
    }
  }

  void _gotoPage(int tabIndex, int page) {
    final lastPage = _lastPagePerTab[tabIndex] ?? 1;
    if (page < 1 || page > lastPage) return;
    _loadTab(tabIndex, page: page);
  }

  Future<void> _reloadAllTabs() async {
    for (var i = 0; i < 3; i++) {
      await _loadTab(i, page: 1);
    }
  }

  void _onFilterKategoriChanged(String? val) {
    if (val == null) return;
    setState(() => _filterKategori = val);
    _loadTab(_tabController.index, page: 1);
  }

  Future<void> _confirmVisit(PicVisitModel item) async {
    try {
      await PicBloc.updateStatus(id: item.id, status: 'confirmed');
      await _loadTab(_tabController.index,
          page: _currentPagePerTab[_tabController.index] ?? 1);
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _cancelVisit(PicVisitModel item) async {
    try {
      await PicBloc.updateStatus(id: item.id, status: 'cancelled');
      await _loadTab(_tabController.index,
          page: _currentPagePerTab[_tabController.index] ?? 1);
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _startMeeting(PicVisitModel item) async {
    try {
      await PicBloc.startMeeting(item.id);
      await _loadTab(_tabController.index,
          page: _currentPagePerTab[_tabController.index] ?? 1);
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _completeMeeting(
    PicVisitModel item, {
    required String meetingResult,
    required String potentialLevel,
    String? followUpAt,
    num? estimatedValue,
  }) async {
    try {
      await PicBloc.completeMeeting(
        id: item.id,
        meetingResult: meetingResult,
        potentialLevel: potentialLevel,
        followUpAt: followUpAt,
        estimatedValue: estimatedValue,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Catatan pertemuan berhasil disimpan!'),
            backgroundColor: Color(0xFF006B3F)),
      );
      await _loadTab(_tabController.index,
          page: _currentPagePerTab[_tabController.index] ?? 1);
    } catch (e) {
      _showError(e);
    }
  }

  void _showError(Object e) {
    if (!mounted) return;
    final msg =
        e is ApiException ? e.message : 'Terjadi kesalahan, silakan coba lagi.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red[700]),
    );
  }

  void _konfirmasiLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Konfirmasi Keluar",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        content: const Text("Apakah Anda yakin ingin keluar?",
            style: TextStyle(fontSize: 11)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal",
                style: TextStyle(fontSize: 10, color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await LogoutBloc.logout();
              if (context.mounted) {
                LogoutBloc.keluarKeHomepage(context);
              }
            },
            child: const Text("Ya, Keluar", style: TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  }

  void _showCatatanDialog(BuildContext context, PicVisitModel item) {
    final catatan = item.notes;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.speaker_notes_rounded, size: 18, color: corporateGreen),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Catatan dari ${item.guestName ?? 'Tamu'}",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              (catatan != null && catatan.isNotEmpty)
                  ? catatan
                  : "Tidak ada catatan khusus untuk tamu ini.",
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF172033), height: 1.5),
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: corporateGreen,
                foregroundColor: Colors.white,
                elevation: 0),
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup", style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  void _showCatatHasilDialog(BuildContext context, PicVisitModel item) {
    final ringkasanCtrl = TextEditingController(text: item.meetingResult ?? '');
    String? prospekSelected = _prospekLabelFromLevel(item.potentialLevel);
    final followUpDate = item.followUpDate;
    final followUpCtrl = TextEditingController(
      text: followUpDate != null
          ? "${followUpDate.year}-${followUpDate.month.toString().padLeft(2, '0')}-${followUpDate.day.toString().padLeft(2, '0')}"
          : '',
    );
    final estimasiCtrl =
        TextEditingController(text: _formatRibuan(item.estimatedValue ?? 0));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isDateOptional =
              prospekSelected != null && _isFollowUpOptional(prospekSelected!);
          final showEstimasi =
              prospekSelected != null && _showEstimasiField(prospekSelected!);
          final isDeal = prospekSelected == 'Deal';

          if (isDateOptional && followUpCtrl.text.isNotEmpty) {
            followUpCtrl.text = '';
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              item.isFinished ? "Edit Catatan Pertemuan" : "Catat Hasil Pertemuan",
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F7FC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "TAMU YANG DITEMUI",
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF778195),
                              letterSpacing: 0.3),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.guestName ?? '-',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF172033)),
                        ),
                        if ((item.companyName ?? '').isNotEmpty)
                          Text(
                            item.companyName!,
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF778195)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _dialogField("Catatan / Ringkasan Diskusi", ringkasanCtrl,
                      maxLines: 3),
                  const SizedBox(height: 8),
                  const Text("Prospek Klien",
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF778195))),
                  const SizedBox(height: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F7FC),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: prospekSelected,
                        isExpanded: true,
                        style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF172033),
                            fontWeight: FontWeight.bold),
                        items: [
                          'Warm Lead',
                          'Hot Lead',
                          'Cold Lead',
                          'Non-Lead',
                          'Deal'
                        ].map((val) {
                          return DropdownMenuItem(value: val, child: Text(val));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() {
                              prospekSelected = val;
                              if (!_showEstimasiField(val)) {
                                estimasiCtrl.text = '';
                              }
                              if (_isFollowUpOptional(val)) {
                                followUpCtrl.text = '';
                              }
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (showEstimasi) ...[
                    Text(
                      isDeal
                          ? "Estimasi Nilai Deal (Rp) *"
                          : "Estimasi Nilai (Rp)",
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF778195)),
                    ),
                    const SizedBox(height: 3),
                    TextField(
                      controller: estimasiCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [_RibuanInputFormatter()],
                      style: const TextStyle(fontSize: 11),
                      decoration: InputDecoration(
                        prefixText: 'Rp ',
                        prefixStyle: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF172033),
                            fontWeight: FontWeight.bold),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 8),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide:
                                const BorderSide(color: Color(0xFFE2E8F0))),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide:
                                const BorderSide(color: Color(0xFFE2E8F0))),
                        filled: true,
                        fillColor: const Color(0xFFF4F7FC),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    isDateOptional
                        ? "Tanggal Follow-Up (tidak diperlukan)"
                        : "Tanggal Follow-Up *",
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF778195)),
                  ),
                  const SizedBox(height: 3),
                  TextField(
                    controller: followUpCtrl,
                    readOnly: true,
                    enabled: !isDateOptional,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDateOptional
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF172033),
                    ),
                    decoration: InputDecoration(
                      hintText: isDateOptional
                          ? "Tidak memerlukan follow up"
                          : "Pilih tanggal follow-up...",
                      hintStyle: const TextStyle(
                          fontSize: 11, color: Color(0xFF9CA3AF)),
                      suffixIcon: Icon(Icons.calendar_today_rounded,
                          size: 16,
                          color: isDateOptional
                              ? const Color(0xFF9CA3AF)
                              : const Color(0xFF006B3F)),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 8),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      filled: true,
                      fillColor: isDateOptional
                          ? const Color(0xFFF1F5F9)
                          : const Color(0xFFF4F7FC),
                      isDense: true,
                    ),
                    onTap: isDateOptional
                        ? null
                        : () async {
                            final now = DateTime.now();
                            final today =
                                DateTime(now.year, now.month, now.day);

                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: today,
                              firstDate: today,
                              lastDate: DateTime(now.year + 2),
                              initialEntryMode:
                                  DatePickerEntryMode.calendarOnly,
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: corporateGreen,
                                      onPrimary: Colors.white,
                                      onSurface: const Color(0xFF172033),
                                    ),
                                  ),
                                  child: MediaQuery(
                                    data: MediaQuery.of(context).copyWith(
                                        textScaler:
                                            const TextScaler.linear(0.85)),
                                    child: child!,
                                  ),
                                );
                              },
                            );
                            if (pickedDate != null) {
                              setDialogState(() {
                                followUpCtrl.text =
                                    "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                              });
                            }
                          },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal",
                    style: TextStyle(fontSize: 11, color: Color(0xFF778195))),
              ),
              ElevatedButton(
  style: ElevatedButton.styleFrom(
      backgroundColor: corporateGreen,
      foregroundColor: Colors.white,
      elevation: 0),
  onPressed: () {
    // === VALIDASI CATATAN / RINGKASAN DISKUSI ===
    if (ringkasanCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Catatan / Ringkasan Diskusi wajib diisi.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    if (prospekSelected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Pilih Potensi Klien terlebih dahulu.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    final level = _levelFromProspekLabel(prospekSelected!);

    if (!_isFollowUpOptional(prospekSelected!) &&
        followUpCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Tanggal follow-up wajib dipilih.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    num? estimasiValue;
    if (showEstimasi) {
      final rawDigits = estimasiCtrl.text.replaceAll('.', '');
      estimasiValue =
          rawDigits.isNotEmpty ? num.tryParse(rawDigits) : null;
    }

    // === VALIDASI ESTIMASI NILAI KHUSUS "DEAL" ===
    if (isDeal && (estimasiValue == null || estimasiValue <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Estimasi Nilai Deal wajib diisi.'),
            backgroundColor: Colors.red),
      );
      return;
    }

    Navigator.pop(context);

    _completeMeeting(
      item,
      meetingResult: ringkasanCtrl.text.trim(),
      potentialLevel: level,
      followUpAt: !_isFollowUpOptional(prospekSelected!) &&
              followUpCtrl.text.isNotEmpty
          ? followUpCtrl.text
          : null,
      estimatedValue: showEstimasi ? estimasiValue : null,
    );
  },
  child: const Text("Simpan", style: TextStyle(fontSize: 11)),
),
            ],
          );
        },
      ),
    );
  }

  String? _prospekLabelFromLevel(String? level) {
    switch (level) {
      case 'hot':
        return 'Hot Lead';
      case 'warm':
        return 'Warm Lead';
      case 'cold':
        return 'Cold Lead';
      case 'non_lead':
        return 'Non-Lead';
      case 'deal':
        return 'Deal';
      default:
        return null;
    }
  }

  String _levelFromProspekLabel(String label) {
    switch (label) {
      case 'Hot Lead':
        return 'hot';
      case 'Warm Lead':
        return 'warm';
      case 'Cold Lead':
        return 'cold';
      case 'Non-Lead':
        return 'non_lead';
      case 'Deal':
        return 'deal';
      default:
        return 'warm';
    }
  }

  bool _isFollowUpOptional(String prospekLabel) {
    return prospekLabel == 'Cold Lead' ||
        prospekLabel == 'Non-Lead' ||
        prospekLabel == 'Deal';
  }

  bool _showEstimasiField(String prospekLabel) {
    return prospekLabel == 'Hot Lead' ||
        prospekLabel == 'Warm Lead' ||
        prospekLabel == 'Deal';
  }

  Widget _dialogField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF778195))),
        const SizedBox(height: 3),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 11),
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            filled: true,
            fillColor: const Color(0xFFF4F7FC),
            isDense: true,
          ),
        ),
      ],
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
          "PIC - Dashboard Tamu",
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          // ================= TOMBOL RELOAD =================
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: "Muat ulang",
            onPressed: () {
              _loadTab(
                _tabController.index,
                page: _currentPagePerTab[_tabController.index] ?? 1,
              );
            },
          ),
          // ================= DROPDOWN NOTIFIKASI =================
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

              // Render Notifikasi
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
                                    ? Colors.grey.withOpacity(0.1)
                                    : corporateGreen.withOpacity(0.1),
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
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: "Keluar",
            onPressed: () => _konfirmasiLogout(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reloadAllTabs,
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
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Total Tamu VIP",
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text("$_totalVip Orang",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber[900])),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Total Tamu Reguler",
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text("$_totalReguler Orang",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[900])),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Daftar Tamu Masuk & Kategori Pelanggan",
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF172033)),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 32,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: corporateGreen,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: Colors.white,
                          unselectedLabelColor: const Color(0xFF778195),
                          labelStyle: const TextStyle(
                              fontSize: 10, fontWeight: FontWeight.bold),
                          tabs: [
                            Tab(text: "Semua(${_countFor(0)})"),
                            Tab(text: "Hari Ini(${_countFor(1)})"),
                            Tab(text: "Mendatang(${_countFor(2)})"),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Filter Kategori: ",
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF778195))),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F7FC),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _filterKategori,
                              isDense: true,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF172033),
                                  fontWeight: FontWeight.bold),
                              items: ['Semua Kategori', 'VIP', 'Reguler']
                                  .map((val) {
                                return DropdownMenuItem(
                                    value: val, child: Text(val));
                              }).toList(),
                              onChanged: _onFilterKategoriChanged,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 450,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTabContent(0),
                    _buildTabContent(1),
                    _buildTabContent(2),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(int tabIndex) {
    final loading = _loadingPerTab[tabIndex] ?? false;
    final error = _errorPerTab[tabIndex];
    final data = _dataPerTab[tabIndex] ?? [];
    final currentPage = _currentPagePerTab[tabIndex] ?? 1;
    final lastPage = _lastPagePerTab[tabIndex] ?? 1;

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.grey, size: 28),
            const SizedBox(height: 8),
            Text(error,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _loadTab(tabIndex, page: currentPage),
              child: const Text("Coba lagi", style: TextStyle(fontSize: 11)),
            ),
          ],
        ),
      );
    }

    if (data.isEmpty) {
      return const Center(
        child: Text("Tidak ada data tamu.",
            style: TextStyle(color: Color(0xFF778195), fontSize: 11)),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) => _buildTamuCard(data[index]),
          ),
        ),
        if (lastPage > 1) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                color: corporateGreen,
                onPressed: currentPage > 1
                    ? () => _gotoPage(tabIndex, currentPage - 1)
                    : null,
              ),
              Text(
                '$currentPage / $lastPage',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172033)),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                color: corporateGreen,
                onPressed: currentPage < lastPage
                    ? () => _gotoPage(tabIndex, currentPage + 1)
                    : null,
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTamuCard(PicVisitModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: const Color(0xFFF4F7FC),
                    borderRadius: BorderRadius.circular(4)),
                child: Text("Token: ${item.token ?? '-'}",
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF006B3F))),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: item.kategori == "VIP"
                      ? Colors.amber.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(item.kategori,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: item.kategori == "VIP"
                            ? Colors.amber[800]
                            : Colors.grey[700])),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(item.guestName ?? '-',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Color(0xFF172033))),
          if ((item.guestPosition ?? '').isNotEmpty ||
              (item.companyName ?? '').isNotEmpty)
            Text(
              [item.guestPosition, item.companyName]
                  .where((s) => (s ?? '').isNotEmpty)
                  .join(' • '),
              style: const TextStyle(fontSize: 10, color: Color(0xFF778195)),
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 4),
          Text("Waktu: ${item.formattedTime}",
              style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF006B3F),
                  fontWeight: FontWeight.w600)),
          if (item.purposeDetail != null || item.purposeType != null)
            Text(
              "Jenis: ${item.categoryName ?? '-'} • Keperluan: ${item.purposeType ?? '-'}",
              style: const TextStyle(fontSize: 10, color: Color(0xFF778195)),
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 6),
          InkWell(
            onTap: () => _showCatatanDialog(context, item),
            child: Row(
              children: [
                const Icon(Icons.speaker_notes_rounded,
                    size: 13, color: Colors.blue),
                const SizedBox(width: 4),
                const Text("Lihat Catatan Tamu",
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue,
                        decoration: TextDecoration.underline)),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6.0),
            child: Divider(height: 1, color: Color(0xFFE5E7EB)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text("Konfirmasi: ",
                      style:
                          TextStyle(fontSize: 10, color: Color(0xFF778195))),
                  if (item.canConfirm) ...[
                    InkWell(
                      onTap: () => _confirmVisit(item),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4)),
                        child: const Icon(Icons.check,
                            size: 14, color: Colors.green),
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => _cancelVisit(item),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4)),
                        child: const Icon(Icons.close,
                            size: 14, color: Colors.red),
                      ),
                    ),
                  ] else if (item.isScheduled) ...[
                    const Text(
                      "Belum Check-In",
                      style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF94A3B8),
                          fontStyle: FontStyle.italic),
                    ),
                  ] else ...[
                    Text(
                      item.statusKonfirmasi,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: item.isMeeting
                            ? Colors.orange[700]
                            : Colors.green[700],
                      ),
                    ),
                  ],
                ],
              ),
              if (item.isFinished)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 6),
                  child: Text(
                    "✔ Hasil Tercatat",
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[600]),
                  ),
                )
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        item.isConfirmed ? corporateGreen : Colors.grey[300],
                    foregroundColor:
                        item.isConfirmed ? Colors.white : Colors.grey[600],
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    minimumSize: const Size(60, 26),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: !item.isConfirmed
                      ? null
                      : () {
                          if (item.statusKonfirmasi == "Dikonfirmasi") {
                            _startMeeting(item);
                          } else {
                            _showCatatHasilDialog(context, item);
                          }
                        },
                  child: Text(
                    item.isMeeting ? "Catat Hasil" : "Mulai Pertemuan",
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}