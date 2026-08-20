import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../bloc/owner_bloc.dart';
import '../../model/lead_pipeline_model.dart';
import 'aktivitas_terbaru_screen.dart'; // sesuaikan path kalau berbeda
// import 'dashboard_owner_screen.dart'; // TODO: sesuaikan nama file & class Dashboard Owner kamu

class LeadScreen extends StatefulWidget {
  const LeadScreen({Key? key}) : super(key: key);

  @override
  State<LeadScreen> createState() => _LeadScreenState();
}

class _LeadScreenState extends State<LeadScreen> {
  int _currentIndex = 1;
  int _currentPage = 1; // ⬅️ BARU: state halaman aktif untuk pagination

  final Map<String, String> _categoryMap = {
    'Semua': 'all',
    'Aktif': 'active',
    'Deal': 'deal',
    'Terlambat': 'overdue',
    'Hari Ini': 'today',
    'Menunggu': 'upcoming',
    'Lost': 'lost',
  };
  String _selectedCategory = 'Semua';
  String _vipFilter = 'all';

  late Future<LeadPipelineResponse> _futureLeads;

  static const Map<String, Map<String, dynamic>> _leadBadges = {
    'new':        {'bg': Color(0xFFF1F5F9), 'color': Color(0xFF475569), 'label': 'Baru'},
    'contacted':   {'bg': Color(0xFFDBEAFE), 'color': Color(0xFF1D4ED8), 'label': 'Dihubungi'},
    'negotiation': {'bg': Color(0xFFFEF3C7), 'color': Color(0xFFD97706), 'label': 'Negosiasi '},
    'deal':        {'bg': Color(0xFFDCFCE7), 'color': Color(0xFF15803D), 'label': 'Deal '},
    'lost':        {'bg': Color(0xFFFEE2E2), 'color': Color(0xFFB91C1C), 'label': 'Lost'},
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ⬅️ DIUBAH: sekarang bisa terima parameter page opsional.
  void _loadData({int? page}) {
    if (page != null) _currentPage = page;
    _futureLeads = DashboardOwnerBloc.fetchLeads(
      filter: _categoryMap[_selectedCategory]!,
      vipStatus: _vipFilter,
      page: _currentPage,
    );
  }

  String _rupiah(num? value) {
    if (value == null) return '-';
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(value);
  }

  static const List<String> _bulanIndo = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  String _formatDate(String raw) {
    try {
      final d = DateTime.parse(raw).toLocal();
      return '${d.day} ${_bulanIndo[d.month - 1]} ${d.year}';
    } catch (_) {
      return raw;
    }
  }

  String _scheduleText(LeadModel lead) {
    if (lead.status == 'deal') return 'Sudah Deal ';
    if (lead.status == 'lost') return 'Lead Hilang / Lost';
    if (lead.followUpAt != null) return _formatDate(lead.followUpAt!);
    return 'Tidak ada jadwal lanjutan';
  }

  Widget _summaryItem(String label, String value) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
        ],
      ),
    );
  }

  Widget _buildFollowUpBadge(String? followUpAt, String status) {
    if (status == 'deal') return const SizedBox.shrink();
    if (followUpAt == null) {
      return const Text('Belum dijadwalkan', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)));
    }
    final fuDate = DateTime.parse(followUpAt);
    final today = DateTime.now();
    final fuDay = DateTime(fuDate.year, fuDate.month, fuDate.day);
    final todayDay = DateTime(today.year, today.month, today.day);
    final diff = fuDay.difference(todayDay).inDays;

    Color bg, color;
    String label;
    if (diff < 0) {
      bg = const Color(0xFFFEF2F2);
      color = const Color(0xFFDC2626);
      label = ' Terlambat ${diff.abs()} hari';
    } else if (diff == 0) {
      bg = const Color(0xFFFEF3C7);
      color = const Color(0xFFD97706);
      label = 'Hari Ini';
    } else {
      bg = const Color(0xFFE6F4ED);
      color = const Color(0xFF006B3F);
      label = diff == 1 ? 'Besok' : '$diff hari mendatang';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
    );
  }

  void _showCatatanDialog(BuildContext context, LeadModel lead) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Row(
            children: [
              const SizedBox(width: 8),
              Expanded(
                child: Text("Riwayat – ${lead.guestName ?? 'Klien'}",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Ditangani oleh: ${lead.ownerName ?? '-'} (PIC)",
                      style: const TextStyle(fontSize: 11, color: Color(0xFF778195), fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 8,
                      children: [
                        _summaryItem("Tahap Pipeline Terakhir",
                            (_leadBadges[lead.status] ?? _leadBadges['new']!)['label'] as String),
                        _summaryItem("Jadwal Follow-Up", _scheduleText(lead)),
                        _summaryItem("Estimasi Value", _rupiah(lead.estimatedValue)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(" Catatan Awal Kunjungan:",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(lead.notes ?? 'Tidak ada catatan awal.',
                        style: const TextStyle(fontSize: 12, height: 1.4)),
                  ),
                  const SizedBox(height: 14),
                  const Text(" Hasil Meeting Pertama:",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(lead.meetingResult ?? 'Tidak ada hasil meeting.',
                        style: const TextStyle(fontSize: 12, height: 1.4)),
                  ),
                  const SizedBox(height: 14),
                  const Text(" Riwayat Update Pipeline:",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                  const SizedBox(height: 6),
                  if (lead.followUps.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Belum ada catatan update follow-up.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontStyle: FontStyle.italic)),
                    )
                  else
                    ...lead.followUps.map((fu) {
                      final badge = _leadBadges[fu.status] ?? _leadBadges['new']!;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDFDFD),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(' ${_formatDate(fu.createdAt)}',
                                    style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                                Text('Tahap: ${badge['label']}',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badge['color'])),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(fu.result ?? '-', style: const TextStyle(fontSize: 12)),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 16,
                              runSpacing: 4,
                              children: [
                                Text(' Estimasi Value: ${_rupiah(fu.estimatedValue)}',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF006B3F))),
                                if (fu.dueAt != null)
                                  Text('Target Due Date: ${_formatDate(fu.dueAt!)}',
                                      style: const TextStyle(fontSize: 10, color: Color(0xFF475569))),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Tutup", style: TextStyle(color: Color(0xFF006B3F), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF778195), fontWeight: FontWeight.w500)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF006B3F),
        elevation: 0,
        title: const Text("Manajemen Lead & Follow-Up",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _loadData());
          await _futureLeads;
        },
        child: FutureBuilder<LeadPipelineResponse>(
          future: _futureLeads,
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
                        ElevatedButton(onPressed: () => setState(() => _loadData()), child: const Text('Coba Lagi')),
                      ],
                    ),
                  ),
                ),
              );
            }

            final result = snapshot.data!;
            final leads = result.data;
            final counts = result.counts;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: "Total Prospek Aktif",
                          value: "${counts['active'] ?? 0}",
                          icon: Icons.trending_up_rounded,
                          color: const Color(0xFF1B65E3),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          title: "Total Deal",
                          value: "${counts['deal'] ?? 0}",
                          icon: Icons.check_circle_outline_rounded,
                          color: const Color(0xFF006B3F),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    height: 38,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categoryMap.length,
                      itemBuilder: (context, index) {
                        final label = _categoryMap.keys.elementAt(index);
                        final key = _categoryMap[label]!;
                        final isSelected = _selectedCategory == label;
                        final count = counts[key] ?? 0;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(count > 0 ? '$label ($count)' : label),
                            selected: isSelected,
                            selectedColor: const Color(0xFF006B3F),
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : const Color(0xFF778195),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: isSelected ? const Color(0xFF006B3F) : const Color(0xFFE2E8F0)),
                            ),
                            onSelected: (_) => setState(() {
                              _selectedCategory = label;
                              _currentPage = 1; // ⬅️ BARU: reset ke halaman 1 saat ganti kategori
                              _loadData();
                            }),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text("Status: ", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF5C6678))),
                      DropdownButton<String>(
                        value: _vipFilter,
                        underline: const SizedBox(),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('Semua Status')),
                          DropdownMenuItem(value: 'vip', child: Text(' VIP')),
                          DropdownMenuItem(value: 'reguler', child: Text('Reguler')),
                        ],
                        onChanged: (value) {
                          if (value != null) setState(() {
                            _vipFilter = value;
                            _currentPage = 1; // ⬅️ BARU: reset ke halaman 1 saat ganti filter VIP
                            _loadData();
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text("Daftar Prospek - $_selectedCategory",
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
                  const SizedBox(height: 12),

                  leads.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                          child: const Center(
                            child: Text("Tidak ada data prospek untuk kategori ini.",
                                style: TextStyle(fontSize: 12, color: Color(0xFF778195))),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: leads.length,
                          itemBuilder: (context, index) {
                            final lead = leads[index];
                            final badge = _leadBadges[lead.status] ?? _leadBadges['new']!;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
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
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(4)),
                                            child: Text("No. ${leads.indexOf(lead) + 1 + (result.currentPage - 1) * 10}",
                                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF778195))),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(lead.visitCode,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF006B3F))),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(color: (badge['bg'] as Color), borderRadius: BorderRadius.circular(6)),
                                        child: Text(badge['label'] as String,
                                            style: TextStyle(color: badge['color'] as Color, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      const Icon(Icons.person_outline_rounded, size: 14, color: Color(0xFF778195)),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              const TextSpan(text: "Tamu: ", style: TextStyle(fontSize: 12, color: Color(0xFF778195))),
                                              TextSpan(
                                                text: "${lead.guestName ?? '-'}"
                                                    "${(lead.guestPosition != null && lead.guestPosition!.isNotEmpty) ? '(${lead.guestPosition})' : ''}",
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // 🔄 DIUBAH: Badge VIP disamakan persis dengan halaman PIC
                                      if (lead.isVip) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEF3C7),
                                            borderRadius: BorderRadius.circular(20),
                                            // border: Border.all(
                                            //   color: const Color(0xFFFDE68A),
                                            //   width: 0,
                                            // ),
                                          ),
                                          child: const Text(
                                            'VIP',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFFB45309),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.apartment_rounded, size: 14, color: Color(0xFF778195)),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text.rich(
                                          TextSpan(
                                            children: [
                                              const TextSpan(text: "Instansi: ", style: TextStyle(fontSize: 12, color: Color(0xFF778195))),
                                              TextSpan(
                                                text: (lead.companyName != null && lead.companyName!.isNotEmpty)
                                                    ? lead.companyName!
                                                    : '-',
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                                              ),
                                            ],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.badge_outlined, size: 14, color: Color(0xFF778195)),
                                          const SizedBox(width: 6),
                                          Text("PIC: #${lead.ownerId ?? '-'} ${lead.ownerName ?? ''}",
                                              style: const TextStyle(fontSize: 12, color: Color(0xFF778195))),
                                        ],
                                      ),
                                      Text(_rupiah(lead.estimatedValue),
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF006B3F))),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF778195)),
                                      const SizedBox(width: 6),
                                      const Text("Follow Up: ", style: TextStyle(fontSize: 12, color: Color(0xFF778195))),
                                      if (lead.followUpAt != null) ...[
                                        Text(_formatDate(lead.followUpAt!),
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
                                        const SizedBox(width: 6),
                                      ],
                                      _buildFollowUpBadge(lead.followUpAt, lead.status),
                                    ],
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8.0),
                                    child: Divider(height: 1, color: Color(0xFFE5E7EB)),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Catatan: ${lead.latestNote}",
                                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      InkWell(
                                        onTap: () => _showCatatanDialog(context, lead),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(color: const Color(0xFF006B3F).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                          child: const Text("Lihat Catatan", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF006B3F))),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                  // ⬅️ BARU: kontrol navigasi halaman, cuma muncul kalau ada data & lebih dari 1 halaman
                  if (leads.isNotEmpty && result.lastPage > 1) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          color: const Color(0xFF006B3F),
                          onPressed: result.currentPage > 1
                              ? () => setState(() => _loadData(page: result.currentPage - 1))
                              : null,
                        ),
                        Text(
                          ' ${result.currentPage} / ${result.lastPage}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          color: const Color(0xFF006B3F),
                          onPressed: result.currentPage < result.lastPage
                              ? () => setState(() => _loadData(page: result.currentPage + 1))
                              : null,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}