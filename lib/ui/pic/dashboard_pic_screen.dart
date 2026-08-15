import 'package:flutter/material.dart';
import 'package:mobile_flutter/ui/homepage_screen.dart';
import 'package:mobile_flutter/model/pic_model.dart';
import 'package:mobile_flutter/bloc/pic_bloc.dart';

class DashboardPICScreen extends StatefulWidget {
  const DashboardPICScreen({Key? key}) : super(key: key);

  @override
  State<DashboardPICScreen> createState() => _DashboardPICScreenState();
}

class _DashboardPICScreenState extends State<DashboardPICScreen> with SingleTickerProviderStateMixin {
  final Color corporateGreen = const Color(0xFF006B3F);
  late TabController _tabController;

  String _filterKategori = 'Semua Kategori'; // Semua / VIP / Reguler

  final Map<int, List<PicVisitModel>> _dataPerTab = {0: [], 1: [], 2: []};
  final Map<int, bool> _loadingPerTab = {0: true, 1: true, 2: true};
  final Map<int, String?> _errorPerTab = {0: null, 1: null, 2: null};
  int _totalVip = 0;
  int _totalReguler = 0;

  static const List<String> _tabFilters = ['all', 'today', 'upcoming'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    // Muat tab pertama begitu layar dibuka.
    _loadTab(_tabController.index);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    // Hindari fetch ulang kalau tab ini sudah pernah dimuat & tidak sedang error.
    final alreadyLoaded = (_dataPerTab[_tabController.index]?.isNotEmpty ?? false) &&
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

  Future<void> _loadTab(int tabIndex) async {
    if (!mounted) return;
    setState(() {
      _loadingPerTab[tabIndex] = true;
      _errorPerTab[tabIndex] = null;
    });

    try {
      final result = await PicBloc.dashboard(
        filter: _tabFilters[tabIndex],
        vipStatus: _vipStatusParam,
      );

      if (!mounted) return;
      setState(() {
        _dataPerTab[tabIndex] = result.visits;
        _totalVip = result.vipCount;
        _totalReguler = result.regularCount;
        _loadingPerTab[tabIndex] = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorPerTab[tabIndex] = e is ApiException ? e.message : 'Gagal memuat data. Periksa koneksi Anda.';
        _loadingPerTab[tabIndex] = false;
      });
    }
  }

  Future<void> _reloadAllTabs() async {
    for (var i = 0; i < 3; i++) {
      await _loadTab(i);
    }
  }

  void _onFilterKategoriChanged(String? val) {
    if (val == null) return;
    setState(() => _filterKategori = val);
    _loadTab(_tabController.index);
  }

  // ---------------------------------------------------------------------
  // Aksi-aksi yang memanggil API
  // ---------------------------------------------------------------------

  Future<void> _confirmVisit(PicVisitModel item) async {
    try {
      await PicBloc.updateStatus(id: item.id, status: 'confirmed');
      await _loadTab(_tabController.index);
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _cancelVisit(PicVisitModel item) async {
    try {
      await PicBloc.updateStatus(id: item.id, status: 'cancelled');
      await _loadTab(_tabController.index);
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _startMeeting(PicVisitModel item) async {
    try {
      await PicBloc.startMeeting(item.id);
      await _loadTab(_tabController.index);
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
        const SnackBar(content: Text('Catatan pertemuan berhasil disimpan!'), backgroundColor: Color(0xFF006B3F)),
      );
      await _loadTab(_tabController.index);
    } catch (e) {
      _showError(e);
    }
  }

  void _showError(Object e) {
    if (!mounted) return;
    final msg = e is ApiException ? e.message : 'Terjadi kesalahan, silakan coba lagi.';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red[700]),
    );
  }

  void _konfirmasiLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Konfirmasi Keluar", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        content: const Text("Apakah Anda yakin ingin keluar?", style: TextStyle(fontSize: 11)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(fontSize: 10, color: Colors.grey)),
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

  void _showCatatanDialog(BuildContext context, String? catatan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.speaker_notes_rounded, size: 18, color: corporateGreen),
            const SizedBox(width: 8),
            const Text("Catatan Tamu", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            (catatan != null && catatan.isNotEmpty) ? catatan : "Tidak ada catatan khusus untuk tamu ini.",
            style: const TextStyle(fontSize: 12, color: Color(0xFF172033)),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: corporateGreen, foregroundColor: Colors.white, elevation: 0),
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup", style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  void _showCatatHasilDialog(BuildContext context, PicVisitModel item) {
    final ditemuiCtrl = TextEditingController();
    final ringkasanCtrl = TextEditingController(text: item.meetingResult ?? '');
    String prospekSelected = _prospekLabelFromLevel(item.potentialLevel) ?? 'Warm Lead';
    final followUpDate = item.followUpDate;
    final followUpCtrl = TextEditingController(
      text: followUpDate != null
          ? "${followUpDate.year}-${followUpDate.month.toString().padLeft(2, '0')}-${followUpDate.day.toString().padLeft(2, '0')}"
          : '',
    );
    final estimasiCtrl = TextEditingController(text: item.estimatedValue?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(item.isFinished ? "Edit Catatan Pertemuan" : "Catat Hasil Pertemuan", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _dialogField("Tamu yang Ditemui", ditemuiCtrl),
                const SizedBox(height: 8),
                _dialogField("Catatan / Ringkasan Diskusi", ringkasanCtrl, maxLines: 3),
                const SizedBox(height: 8),
                const Text("Prospek Klien", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF778195))),
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
                      style: const TextStyle(fontSize: 11, color: Color(0xFF172033), fontWeight: FontWeight.bold),
                      items: ['Warm Lead', 'Hot Lead', 'Cold Lead', 'Non-Lead', 'Deal'].map((val) {
                        return DropdownMenuItem(value: val, child: Text(val));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => prospekSelected = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                if (prospekSelected == 'Deal') ...[
                  _dialogField("Estimasi Nilai Deal (Rp)", estimasiCtrl),
                  const SizedBox(height: 8),
                ],

                const Text("Tanggal Follow-Up", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF778195))),
                const SizedBox(height: 3),
                TextField(
                  controller: followUpCtrl,
                  readOnly: true,
                  style: const TextStyle(fontSize: 11),
                  decoration: InputDecoration(
                    hintText: "Pilih tanggal follow-up...",
                    hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                    suffixIcon: const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF006B3F)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    filled: true,
                    fillColor: const Color(0xFFF4F7FC),
                    isDense: true,
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2025),
                      lastDate: DateTime(2030),
                      initialEntryMode: DatePickerEntryMode.calendarOnly,
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
                            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(0.85)),
                            child: child!,
                          ),
                        );
                      },
                    );
                    if (pickedDate != null) {
                      setDialogState(() {
                        followUpCtrl.text = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
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
              child: const Text("Batal", style: TextStyle(fontSize: 11, color: Color(0xFF778195))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: corporateGreen, foregroundColor: Colors.white, elevation: 0),
              onPressed: () {
                final level = _levelFromProspekLabel(prospekSelected);
                final estimasiValue = num.tryParse(estimasiCtrl.text);

                if (level == 'deal' && (estimasiValue == null || estimasiValue <= 0)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Estimasi nilai Deal wajib diisi (lebih dari Rp 0).'), backgroundColor: Colors.red),
                  );
                  return;
                }

                if (followUpCtrl.text.isEmpty && level != 'deal') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tanggal follow-up wajib dipilih.'), backgroundColor: Colors.red),
                  );
                  return;
                }

                Navigator.pop(context);

                _completeMeeting(
                  item,
                  meetingResult: ringkasanCtrl.text.isNotEmpty ? ringkasanCtrl.text : '-',
                  potentialLevel: level,
                  // Follow-up date cuma relevan kalau bukan deal (deal tidak butuh follow-up).
                  followUpAt: level != 'deal' && followUpCtrl.text.isNotEmpty ? followUpCtrl.text : null,
                  estimatedValue: level == 'deal' ? estimasiValue : null,
                );
              },
              child: const Text("Simpan", style: TextStyle(fontSize: 11)),
            ),
          ],
        ),
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

  Widget _dialogField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF778195))),
        const SizedBox(height: 3),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 11),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
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
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            tooltip: "Notifikasi",
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Tidak ada notifikasi baru."), duration: Duration(milliseconds: 700)),
              );
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
                          const Text("Total Tamu VIP", style: TextStyle(fontSize: 11, color: Colors.amber, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text("$_totalVip Orang", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber[900])),
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
                          const Text("Total Tamu Reguler", style: TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text("$_totalReguler Orang", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[900])),
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
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Daftar Tamu Masuk & Kategori Pelanggan",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
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
                          labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          tabs: const [
                            Tab(text: "Semua"),
                            Tab(text: "Hari Ini"),
                            Tab(text: "Mendatang"),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("Filter Kategori: ", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF778195))),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F7FC),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _filterKategori,
                              isDense: true,
                              style: const TextStyle(fontSize: 10, color: Color(0xFF172033), fontWeight: FontWeight.bold),
                              items: ['Semua Kategori', 'VIP', 'Reguler'].map((String val) {
                                return DropdownMenuItem<String>(value: val, child: Text(val));
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
            Text(error, style: const TextStyle(fontSize: 11, color: Colors.grey), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            TextButton(onPressed: () => _loadTab(tabIndex), child: const Text("Coba lagi", style: TextStyle(fontSize: 11))),
          ],
        ),
      );
    }

    if (data.isEmpty) {
      return const Center(
        child: Text("Tidak ada data tamu.", style: TextStyle(color: Color(0xFF778195), fontSize: 11)),
      );
    }

    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) => _buildTamuCard(data[index]),
    );
  }

  Widget _buildTamuCard(PicVisitModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
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
                child: Text("Token: ${item.token ?? '-'}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF006B3F))),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: item.kategori == "VIP" ? Colors.amber.withOpacity(0.2) : Colors.grey.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(item.kategori, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: item.kategori == "VIP" ? Colors.amber[800] : Colors.grey[700])),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(item.guestName ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF172033))),
          if ((item.guestPosition ?? '').isNotEmpty) Text(item.guestPosition!, style: const TextStyle(fontSize: 10, color: Color(0xFF778195))),
          const SizedBox(height: 4),
          Text("Waktu: ${item.displayTime}", style: const TextStyle(fontSize: 10, color: Color(0xFF006B3F), fontWeight: FontWeight.w600)),
          if (item.purposeDetail != null || item.purposeDetail != null)
            Text(
              "Jenis: ${item.categoryName ?? '-'} • Keperluan: ${item.purposeType ?? '-'}",
              style: const TextStyle(fontSize: 10, color: Color(0xFF778195)),
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 6),

          InkWell(
            onTap: () => _showCatatanDialog(context, item.notes),
            child: Row(
              children: [
                const Icon(Icons.speaker_notes_rounded, size: 13, color: Colors.blue),
                const SizedBox(width: 4),
                const Text("Lihat Catatan Tamu", style: TextStyle(fontSize: 10, color: Colors.blue, decoration: TextDecoration.underline)),
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
                  const Text("Konfirmasi: ", style: TextStyle(fontSize: 10, color: Color(0xFF778195))),
                  if (!item.isConfirmed) ...[
                    InkWell(
                      onTap: () => _confirmVisit(item),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                        child: const Icon(Icons.check, size: 14, color: Colors.green),
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => _cancelVisit(item),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                        child: const Icon(Icons.close, size: 14, color: Colors.red),
                      ),
                    ),
                  ] else ...[
                    Text(
                      item.statusKonfirmasi,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: item.isMeeting ? Colors.orange[700] : Colors.green[700],
                      ),
                    ),
                  ],
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: item.isConfirmed ? corporateGreen : Colors.grey[300],
                  foregroundColor: item.isConfirmed ? Colors.white : Colors.grey[600],
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: const Size(60, 26),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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
                  item.isFinished
                      ? "Edit Catatan"
                      : item.isMeeting
                          ? "Catat Hasil"
                          : "Mulai Pertemuan",
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}