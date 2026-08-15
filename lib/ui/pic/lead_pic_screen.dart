import 'package:flutter/material.dart';
import '/bloc/pic_lead_bloc.dart'; // sesuaikan path
import '/model/pic_model.dart'; // sesuaikan path (PicLeadModel, PicLeadsResponse, dst)

class LeadPICScreen extends StatefulWidget {
  const LeadPICScreen({Key? key}) : super(key: key);

  @override
  State<LeadPICScreen> createState() => _LeadPICScreenState();
}

class _LeadPICScreenState extends State<LeadPICScreen> with SingleTickerProviderStateMixin {
  final Color corporateGreen = const Color(0xFF006B3F);
  late TabController _tabController;

  String _filterKategori = 'Semua Kategori'; // Semua Kategori / VIP / Reguler
  bool _isLoading = true;
  String? _errorMessage;
  List<PicLeadModel> _daftarLead = [];
  Map<String, int> _counts = {};

  // Urutan tab harus sama persis dengan urutan Tab() di TabBar di bawah.
  static const List<String> _tabFilters = ['all', 'active', 'deal', 'overdue', 'today', 'upcoming'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) _fetchLeads();
    });
    _fetchLeads();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _vipParam {
    if (_filterKategori == 'VIP') return 'vip';
    if (_filterKategori == 'Reguler') return 'reguler';
    return 'all';
  }

Future<void> _fetchLeads() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    final result = await PicLeadBloc.fetchLeads(
      filter: _tabFilters[_tabController.index],
      vipStatus: _vipParam,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _daftarLead = result.leads;
      _counts = result.counts;
    });
  } catch (e) {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    });
  }
}

  void _onFilterKategoriChanged(String val) {
    setState(() => _filterKategori = val);
    _fetchLeads();
  }

  // ========================= DIALOG: RIWAYAT =========================

  void _showRiwayatDialog(BuildContext context, PicLeadModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.history_rounded, size: 18, color: corporateGreen),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Riwayat: ${item.guestName ?? '-'}",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _infoRow("Tahap Pipeline Terakhir:", item.status ?? '-', isBold: true),
              const SizedBox(height: 4),
              _infoRow("Jadwal Follow-Up:", item.followUpAt ?? '-'),
              const SizedBox(height: 8),
              const Divider(),
              const Text(
                "Catatan Awal:",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(6)),
                child: Text(item.notes ?? '-', style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
              ),
              const SizedBox(height: 8),
              const Text(
                "Riwayat Observasi:",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
              ),
              const SizedBox(height: 4),
              if (item.followUps.isEmpty)
                const Text("Belum ada riwayat.", style: TextStyle(fontSize: 10, color: Color(0xFF778195)))
              else
                ...item.followUps.map((f) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(6)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Tgl: ${f.createdAt ?? '-'} • Tahap: ${f.status ?? '-'}",
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: corporateGreen),
                        ),
                        const SizedBox(height: 2),
                        Text(f.result ?? '-', style: const TextStyle(fontSize: 10, color: Color(0xFF172033))),
                      ],
                    ),
                  );
                }),
            ],
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

  Widget _infoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF778195))),
        Text(
          value,
          style: TextStyle(fontSize: 11, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: const Color(0xFF172033)),
        ),
      ],
    );
  }

  // ===================== DIALOG: UPDATE TAHAPAN =====================

  void _showUpdateTahapanDialog(BuildContext context, PicLeadModel item) {
    String tahapSelected = item.status ?? 'baru';
    final observasiCtrl = TextEditingController();
    final valueCtrl = TextEditingController(text: item.estimatedValue?.toString() ?? '');
    final followUpCtrl = TextEditingController(text: item.followUpAt ?? '');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Update Tahapan Lead", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(6)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.guestName ?? '-', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
                      Text(item.guestPosition ?? '-', style: const TextStyle(fontSize: 10, color: Color(0xFF778195))),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text("Tahap Pipeline Terbaru", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF778195))),
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
                      value: tahapSelected,
                      isExpanded: true,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF172033), fontWeight: FontWeight.bold),
                      items: ['baru', 'dihubungi', 'negosiasi', 'deal', 'lost'].map((val) {
                        return DropdownMenuItem(
                          value: val,
                          child: Text(val[0].toUpperCase() + val.substring(1)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => tahapSelected = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _dialogField("Hasil Observasi Follow-Up Hari Ini", observasiCtrl, maxLines: 2),
                const SizedBox(height: 8),
                _dialogField("Estimasi Nilai Deal (Rp)", valueCtrl, keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                const Text("Jadwal Follow-Up", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF778195))),
                const SizedBox(height: 3),
                TextField(
                  controller: followUpCtrl,
                  readOnly: true,
                  style: const TextStyle(fontSize: 11),
                  decoration: InputDecoration(
                    hintText: "Pilih tanggal...",
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
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(primary: corporateGreen, onPrimary: Colors.white, onSurface: const Color(0xFF172033)),
                          ),
                          child: MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(0.85)), child: child!),
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
              child: const Text("Batal", style: TextStyle(fontSize: 11, color: Color(0xFF778195))),
            ),
ElevatedButton(
  style: ElevatedButton.styleFrom(backgroundColor: corporateGreen, foregroundColor: Colors.white, elevation: 0),
  onPressed: () async {
    Navigator.pop(context);
    try {
      await PicLeadBloc.updateFollowUp(
        leadId: item.id,
        status: tahapSelected,
        result: observasiCtrl.text.isNotEmpty ? observasiCtrl.text : null,
        estimatedValue: num.tryParse(valueCtrl.text),
        dueAt: followUpCtrl.text.isNotEmpty ? followUpCtrl.text : null,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tahap pipeline berhasil diperbarui!'),
          backgroundColor: Color(0xFF006B3F),
        ),
      );
      _fetchLeads();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui data: ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  },
  child: const Text("Simpan", style: TextStyle(fontSize: 11)),
),
          ],
        ),
      ),
    );
  }

  Widget _dialogField(String label, TextEditingController controller, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF778195))),
        const SizedBox(height: 3),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
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

  // ============================= BUILD =============================

  @override
  Widget build(BuildContext context) {
    int totalDeal = _counts['deal'] ?? 0;
    int totalAktif = _counts['active'] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: corporateGreen,
        elevation: 0,
        title: const Text(
          "Front Office - Pipeline Lead",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchLeads,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Card ringkasan Deal & Aktif
              Row(
                children: [
                  Expanded(child: _summaryCard("Total Berhasil (Deal)", "$totalDeal Klien", Colors.green)),
                  const SizedBox(width: 10),
                  Expanded(child: _summaryCard("Total Pipeline Aktif", "$totalAktif Klien", Colors.orange)),
                ],
              ),
              const SizedBox(height: 16),

              // 2. Card Header: tab + filter kategori
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
                      "Pipeline Lead & Status Konvensional",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 32,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(color: const Color(0xFFE2E8F0).withOpacity(0.5), borderRadius: BorderRadius.circular(6)),
                        child: TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          indicator: BoxDecoration(color: corporateGreen, borderRadius: BorderRadius.circular(4)),
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: Colors.white,
                          unselectedLabelColor: const Color(0xFF778195),
                          labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          tabs: const [
                            Tab(text: "Semua"),
                            Tab(text: "Aktif"),
                            Tab(text: "Deal"),
                            Tab(text: "Terlambat"),
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
                              items: ['Semua Kategori', 'VIP', 'Reguler'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                              onChanged: (val) {
                                if (val != null) _onFilterKategoriChanged(val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 3. Konten data (loading / error / list)
              SizedBox(height: 450, child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(String label, String value, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color[50], borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.3))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color[900])),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 11), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: _fetchLeads, child: const Text("Coba Lagi", style: TextStyle(fontSize: 11))),
          ],
        ),
      );
    }
    if (_daftarLead.isEmpty) {
      return const Center(
        child: Text("Tidak ada data lead untuk tab ini.", style: TextStyle(color: Color(0xFF778195), fontSize: 11)),
      );
    }
    return ListView.builder(
      itemCount: _daftarLead.length,
      itemBuilder: (context, index) => _leadCard(_daftarLead[index]),
    );
  }

  Widget _leadCard(PicLeadModel item) {
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
                child: Text(
                  "Token: ${item.visitCode ?? '-'}",
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF006B3F)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: item.isVip ? Colors.amber.withOpacity(0.2) : Colors.grey.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.isVip ? "VIP" : "Reguler",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: item.isVip ? Colors.amber[800] : Colors.grey[700]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(item.guestName ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF172033))),
          Text(item.guestPosition ?? '-', style: const TextStyle(fontSize: 10, color: Color(0xFF778195))),
          const SizedBox(height: 4),
          Text(
            "Value: Rp ${item.estimatedValue ?? 0}",
            style: const TextStyle(fontSize: 10, color: Color(0xFF006B3F), fontWeight: FontWeight.bold),
          ),
          Text(
            "Follow-Up: ${item.followUpAt ?? '-'} • Tahap: ${item.status ?? '-'}",
            style: const TextStyle(fontSize: 10, color: Color(0xFF778195)),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 6.0), child: Divider(height: 1, color: Color(0xFFE5E7EB))),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () => _showRiwayatDialog(context, item),
                icon: const Icon(Icons.history, size: 12, color: Colors.blue),
                label: const Text("Riwayat", style: TextStyle(fontSize: 10, color: Colors.blue)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  side: const BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  minimumSize: const Size(40, 24),
                ),
              ),
              const SizedBox(width: 6),
              ElevatedButton.icon(
                onPressed: () => _showUpdateTahapanDialog(context, item),
                icon: const Icon(Icons.update, size: 12, color: Colors.white),
                label: const Text("Update Tahapan", style: TextStyle(fontSize: 10, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: corporateGreen,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  minimumSize: const Size(40, 24),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}