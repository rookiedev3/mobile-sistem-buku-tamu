import 'package:flutter/material.dart';

// Model Data Lead & Follow Up
class FollowUpModel {
  final String status;
  final String? result;
  final double estimatedValue;
  final String createdAt;
  final String? dueAt;

  FollowUpModel({
    required this.status,
    this.result,
    required this.estimatedValue,
    required this.createdAt,
    this.dueAt,
  });
}

class LeadModel {
  final String token;
  final String guestName;
  final String jabatan;
  final String perusahaan;
  final String? ownerName;
  final String status; // 'new', 'meeting', 'negotiation', 'deal', 'lost'
  final double estimatedValue;
  final String? notes;
  final String? meetingResult;
  final List<FollowUpModel> followUps;
  final String? followUpAt;
  final String jenisKunjungan; // Mitra, Prospek, Klien, Vendor, Pelamar, Umum
  final String waktu;

  LeadModel({
    required this.token,
    required this.guestName,
    required this.jabatan,
    required this.perusahaan,
    this.ownerName,
    required this.status,
    required this.estimatedValue,
    this.notes,
    this.meetingResult,
    required this.followUps,
    this.followUpAt,
    required this.jenisKunjungan,
    required this.waktu,
  });
}

class LeadScreen extends StatefulWidget {
  const LeadScreen({Key? key}) : super(key: key);

  @override
  State<LeadScreen> createState() => _LeadScreenState();
}

class _LeadScreenState extends State<LeadScreen> {
  final Color corporateGreen = const Color(0xFF006B3F);

  // State Filter Tab & Dropdown
  String _selectedTab = 'Semua';
  String _filterJenis = 'Semua Tipe';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _tabs = ['Semua', 'Aktif', 'Terlambat', 'Hari Ini', 'Mendatang', 'Deal', 'Lost'];

  final Map<String, Map<String, dynamic>> _leadBadges = {
    'new': {'label': 'Baru', 'color': Colors.blue},
    'meeting': {'label': 'Meeting Selesai', 'color': Colors.orange},
    'negotiation': {'label': 'Negosiasi', 'color': Colors.purple},
    'deal': {'label': 'Deal / Selesai', 'color': const Color(0xFF006B3F)},
    'lost': {'label': 'Dibatalkan / Lost', 'color': Colors.red},
  };

  // Data Dummy Prospek Aktif & Leads
  final List<LeadModel> _daftarLead = [
    LeadModel(
      token: "TRX-001",
      guestName: "Budi Santoso",
      jabatan: "Direktur",
      perusahaan: "PT Maju Sejahtera",
      ownerName: "Chyntia",
      status: "negotiation",
      estimatedValue: 75000000,
      notes: "Meminta penawaran khusus POS Enterprise.",
      meetingResult: "Klien tertarik dengan integrasi keuangan otomatis.",
      jenisKunjungan: "Mitra",
      waktu: "14 Agu 2026",
      followUpAt: "2026-08-14T15:00:00Z",
      followUps: [
        FollowUpModel(
          status: "negotiation",
          result: "Diskusi penawaran harga via telepon.",
          estimatedValue: 75000000,
          createdAt: "2026-08-14T10:00:00Z",
          dueAt: "2026-08-14T15:00:00Z",
        )
      ],
    ),
    LeadModel(
      token: "TRX-002",
      guestName: "Siti Aminah",
      jabatan: "Consultant",
      perusahaan: "CV Konsultan Mandiri",
      ownerName: "Budi",
      status: "new",
      estimatedValue: 25000000,
      notes: "Konsultasi sistem modul inventaris.",
      meetingResult: "Menunggu ACC anggaran.",
      jenisKunjungan: "Prospek",
      waktu: "10 Agu 2026",
      followUpAt: "2026-08-12T10:00:00Z",
      followUps: [],
    ),
    LeadModel(
      token: "TRX-003",
      guestName: "Joko Widodo",
      jabatan: "Manager Operasional",
      perusahaan: "PT Inovasi Teknologi",
      ownerName: "Chyntia",
      status: "deal",
      estimatedValue: 120000000,
      notes: "Demo produk ERP komplit.",
      meetingResult: "Deal tercapai, MoU ditandatangani.",
      jenisKunjungan: "Mitra",
      waktu: "05 Agu 2026",
      followUpAt: null,
      followUps: [],
    ),
  ];

  String _rupiah(double amount) {
    return "Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
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
    if (lead.status == 'deal') return 'Sudah Deal 🎉';
    if (lead.status == 'lost') return 'Lead Hilang / Lost';
    if (lead.followUpAt != null) return _formatDate(lead.followUpAt!);
    return 'Tidak ada jadwal lanjutan';
  }

  Widget _summaryItem(String label, String value) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
        ],
      ),
    );
  }

  // --- POP-UP DIALOG CATATAN & RIWAYAT ---
  void _showCatatanDialog(BuildContext context, LeadModel lead) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Row(
            children: [
              const Icon(Icons.note_alt_rounded, color: Color(0xFF006B3F), size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text("Riwayat – ${lead.guestName}",
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

                  const Text("📝 Catatan Awal Kunjungan:",
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

                  const Text("📌 Hasil Meeting Pertama:",
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

                  const Text("🔄 Riwayat Update Pipeline:",
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
                                Text('📅 ${_formatDate(fu.createdAt)}',
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
                                Text('💰 Estimasi Value: ${_rupiah(fu.estimatedValue)}',
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

  @override
  Widget build(BuildContext context) {
    // Hitung jumlah orang/klien prospek aktif
    int totalProspekAktifOrang = _daftarLead
        .where((l) => l.status != 'deal' && l.status != 'lost')
        .length;

    // Hitung total karyawan yang deal
    int totalKaryawanDeal = _daftarLead
        .where((l) => l.status == 'deal')
        .length;

    // Logika Filter Berdasarkan Tab & Dropdown Jenis
    List<LeadModel> filteredList = _daftarLead.where((item) {
      String query = _searchController.text.toLowerCase();
      bool matchSearch = item.guestName.toLowerCase().contains(query) ||
          item.perusahaan.toLowerCase().contains(query);

      bool matchJenis = (_filterJenis == 'Semua Tipe') || (item.jenisKunjungan == _filterJenis);

      bool matchTab = true;
      if (_selectedTab == 'Aktif') {
        matchTab = item.status != 'deal' && item.status != 'lost';
      } else if (_selectedTab == 'Terlambat') {
        matchTab = item.followUpAt != null && DateTime.parse(item.followUpAt!).isBefore(DateTime.now()) && item.status != 'deal';
      } else if (_selectedTab == 'Hari Ini') {
        matchTab = item.followUpAt != null && DateTime.parse(item.followUpAt!).day == DateTime.now().day;
      } else if (_selectedTab == 'Mendatang') {
        matchTab = item.followUpAt != null && DateTime.parse(item.followUpAt!).isAfter(DateTime.now());
      } else if (_selectedTab == 'Deal') {
        matchTab = item.status == 'deal';
      } else if (_selectedTab == 'Lost') {
        matchTab = item.status == 'lost';
      }

      return matchSearch && matchJenis && matchTab;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: corporateGreen,
        elevation: 0,
        title: const Text(
          "Manajemen Lead & Follow-Up",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= 2 CARD STATISTIK DI ATAS =================
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 3, offset: const Offset(0, 1))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Prospek Aktif", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                            Icon(Icons.trending_up_rounded, size: 14, color: corporateGreen),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text("$totalProspekAktifOrang Orang", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: corporateGreen)),
                        const SizedBox(height: 2),
                        const Text("Klien dalam pipeline", style: TextStyle(fontSize: 7, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 3, offset: const Offset(0, 1))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Karyawan Deal", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                            const Icon(Icons.task_alt_rounded, size: 14, color: Colors.blue),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text("$totalKaryawanDeal Orang", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue)),
                        const SizedBox(height: 2),
                        const Text("Berhasil konversi", style: TextStyle(fontSize: 7, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ================= 7 TAB FILTER (TANPA IKON CENTANG) =================
            SizedBox(
              height: 28,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _tabs.length,
                itemBuilder: (context, index) {
                  String tab = _tabs[index];
                  bool isSelected = _selectedTab == tab;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: InkWell(
                      onTap: () => setState(() => _selectedTab = tab),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? corporateGreen : Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: isSelected ? corporateGreen : const Color(0xFFE2E8F0)),
                        ),
                        child: Center(
                          child: Text(
                            tab,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : const Color(0xFF172033),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // ================= SEARCH BAR & FILTER TIPE TAMU =================
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 32,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() {}),
                      style: const TextStyle(fontSize: 10),
                      decoration: InputDecoration(
                        hintText: "Cari nama tamu / perusahaan...",
                        prefixIcon: const Icon(Icons.search, size: 14, color: Colors.grey),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        filled: true,
                        fillColor: const Color(0xFFF4F7FC),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 32,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFE2E8F0))),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _filterJenis,
                              isDense: true,
                              style: const TextStyle(fontSize: 10, color: Color(0xFF172033)),
                              items: ['Semua Tipe', 'Mitra', 'Prospek', 'Klien', 'Vendor', 'Pelamar', 'Umum']
                                  .map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                              onChanged: (val) => setState(() => _filterJenis = val!),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ================= TABEL DAFTAR LEAD =================
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Daftar Prospek & PIC Penanggung Jawab ($_selectedTab)", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
                  const SizedBox(height: 8),

                  filteredList.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Center(child: Text("Tidak ada data lead pada kategori ini.", style: TextStyle(fontSize: 10, color: Colors.grey))),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowHeight: 28,
                            dataRowHeight: 40,
                            columnSpacing: 10,
                            columns: const [
                              DataColumn(label: Text('No', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Token', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Tamu & Jabatan', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('PIC / Sales', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Value', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Tanggal Follow Up', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Tahap Pipeline', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Catatan', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                            ],
                            rows: List.generate(filteredList.length, (index) {
                              final item = filteredList[index];
                              final badge = _leadBadges[item.status] ?? _leadBadges['new']!;
                              return DataRow(cells: [
                                DataCell(Text((index + 1).toString(), style: const TextStyle(fontSize: 9))),
                                DataCell(Text(item.token, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: corporateGreen))),
                                DataCell(Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(item.guestName, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                    Text("${item.perusahaan} (${item.jabatan})", style: const TextStyle(fontSize: 8, color: Colors.grey)),
                                  ],
                                )),
                                DataCell(Text(item.ownerName ?? '-', style: const TextStyle(fontSize: 9))),
                                DataCell(Text(_rupiah(item.estimatedValue), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: corporateGreen))),
                                DataCell(Text(item.followUpAt != null ? _formatDate(item.followUpAt!) : '-', style: const TextStyle(fontSize: 9))),
                                DataCell(Text(badge['label'], style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: badge['color']))),
                                DataCell(ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade50,
                                    foregroundColor: Colors.blue,
                                    elevation: 0,
                                    minimumSize: const Size(50, 24),
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  ),
                                  onPressed: () => _showCatatanDialog(context, item),
                                  child: const Text("Catatan", style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold)),
                                )),
                              ]);
                            }),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),

      
    );
  }
}