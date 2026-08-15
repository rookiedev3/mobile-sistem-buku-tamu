import 'package:flutter/material.dart';

// Model Dummy untuk contoh struktur LeadModel & FollowUpModel
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
  final String? guestName;
  final String? ownerName;
  final String status; // 'new', 'meeting', 'negotiation', 'deal', 'lost'
  final double estimatedValue;
  final String? notes;
  final String? meetingResult;
  final List<FollowUpModel> followUps;
  final String? followUpAt;
  final String jenisKunjungan; // Mitra, Prospek, Klien, Vendor, Pelamar, Umum
  final String token;
  final String jabatan;
  final String perusahaan;
  final String waktu;

  LeadModel({
    this.guestName,
    this.ownerName,
    required this.status,
    required this.estimatedValue,
    this.notes,
    this.meetingResult,
    required this.followUps,
    this.followUpAt,
    required this.jenisKunjungan,
    required this.token,
    required this.jabatan,
    required this.perusahaan,
    required this.waktu,
  });
}

class DaftarKunjunganScreen extends StatefulWidget {
  const DaftarKunjunganScreen({Key? key}) : super(key: key);

  @override
  State<DaftarKunjunganScreen> createState() => _DaftarKunjunganScreenState();
}

class _DaftarKunjunganScreenState extends State<DaftarKunjunganScreen> {
  final Color corporateGreen = const Color(0xFF006B3F);

  final TextEditingController _searchController = TextEditingController();
  String _filterJenis = 'Semua Jenis';
  String _filterStatusPipeline = 'Semua Status';
  DateTime? _startDate;
  DateTime? _endDate;

  // Badge Status Pipeline
  final Map<String, Map<String, dynamic>> _leadBadges = {
    'new': {'label': 'Baru', 'color': Colors.blue},
    'meeting': {'label': 'Meeting Selesai', 'color': Colors.orange},
    'negotiation': {'label': 'Negosiasi', 'color': Colors.purple},
    'deal': {'label': 'Deal / Selesai', 'color': const Color(0xFF006B3F)},
    'lost': {'label': 'Dibatalkan / Lost', 'color': Colors.red},
  };

  // Data Simulasi Daftar Tamu & Lead
  final List<LeadModel> _daftarLead = [
    LeadModel(
      guestName: "Budi Santoso",
      ownerName: "Chyntia",
      status: "meeting",
      estimatedValue: 75000000,
      notes: "Meminta penawaran harga khusus paket software POS skala enterprise.",
      meetingResult: "Klien sangat tertarik dengan fitur laporan keuangan otomatis.",
      jenisKunjungan: "Mitra",
      token: "TRX-001",
      jabatan: "Direktur",
      perusahaan: "PT Maju Sejahtera",
      waktu: "14 Agu 2026, 10:00",
      followUpAt: "2026-08-20T10:00:00Z",
      followUps: [
        FollowUpModel(
          status: "negotiation",
          result: "Klien meminta diskon 10% untuk pembayaran di muka.",
          estimatedValue: 70000000,
          createdAt: "2026-08-14T11:00:00Z",
          dueAt: "2026-08-18T10:00:00Z",
        )
      ],
    ),
    LeadModel(
      guestName: "Siti Aminah",
      ownerName: "Budi",
      status: "new",
      estimatedValue: 15000000,
      notes: "Diskusi implementasi modul inventaris gudang cabang.",
      meetingResult: "Menunggu persetujuan anggaran dari komisaris.",
      jenisKunjungan: "Prospek",
      token: "TRX-002",
      jabatan: "Consultant",
      perusahaan: "CV Konsultan Mandiri",
      waktu: "14 Agu 2026, 11:30",
      followUps: [],
    ),
  ];

  String _rupiah(double amount) {
    return "Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  void _resetFilter() {
    setState(() {
      _searchController.clear();
      _filterJenis = 'Semua Jenis';
      _filterStatusPipeline = 'Semua Status';
      _startDate = null;
      _endDate = null;
    });
  }

  // --- POP-UP DIALOG RIWAYAT SESUAI REQUEST REVISI ---
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

                  // Ringkasan status/jadwal/estimasi value di bagian atas
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

                  // Catatan Awal Kunjungan & Hasil Meeting Pertama
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

                  // Riwayat Update Pipeline
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

  @override
  Widget build(BuildContext context) {
    List<LeadModel> filteredList = _daftarLead.where((item) {
      String query = _searchController.text.toLowerCase();
      bool matchSearch = (item.guestName ?? '').toLowerCase().contains(query) ||
          item.perusahaan.toLowerCase().contains(query);

      bool matchJenis = (_filterJenis == 'Semua Jenis') || (item.jenisKunjungan == _filterJenis);
      bool matchStatus = (_filterStatusPipeline == 'Semua Status') || 
          ((_leadBadges[item.status]?['label'] ?? '') == _filterStatusPipeline);

      return matchSearch && matchJenis && matchStatus;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: corporateGreen,
        elevation: 0,
        title: const Text(
          "Daftar Kunjungan & Pipeline",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= FILTER & SEARCH BAR =================
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
                      // Dropdown Jenis Kunjungan (Mitra, Prospek, Klien, Vendor, Pelamar, Umum)
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
                              items: ['Semua Jenis', 'Mitra', 'Prospek', 'Klien', 'Vendor', 'Pelamar', 'Umum']
                                  .map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                              onChanged: (val) => setState(() => _filterJenis = val!),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Dropdown Status Pipeline
                      Expanded(
                        child: Container(
                          height: 32,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFE2E8F0))),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _filterStatusPipeline,
                              isDense: true,
                              style: const TextStyle(fontSize: 10, color: Color(0xFF172033)),
                              items: ['Semua Status', 'Baru', 'Meeting Selesai', 'Negosiasi', 'Deal / Selesai', 'Dibatalkan / Lost']
                                  .map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                              onChanged: (val) => setState(() => _filterStatusPipeline = val!),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 32,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2025),
                                lastDate: DateTime(2027),
                              );
                              if (picked != null) setState(() => _startDate = picked);
                            },
                            icon: const Icon(Icons.date_range, size: 12, color: Colors.grey),
                            label: Text(_startDate == null ? "Dari Tanggal" : "${_startDate!.day}/${_startDate!.month}/${_startDate!.year}", style: const TextStyle(fontSize: 9.5, color: Colors.grey)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: SizedBox(
                          height: 32,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2025),
                                lastDate: DateTime(2027),
                              );
                              if (picked != null) setState(() => _endDate = picked);
                            },
                            icon: const Icon(Icons.date_range, size: 12, color: Colors.grey),
                            label: Text(_endDate == null ? "Sampai Tanggal" : "${_endDate!.day}/${_endDate!.month}/${_endDate!.year}", style: const TextStyle(fontSize: 9.5, color: Colors.grey)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        height: 32,
                        child: OutlinedButton.icon(
                          onPressed: _resetFilter,
                          icon: const Icon(Icons.refresh, size: 12, color: Colors.grey),
                          label: const Text("Reset", style: TextStyle(fontSize: 9.5, color: Colors.grey)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ================= TABEL DAFTAR KUNJUNGAN =================
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
                  const Text("Tabel Riwayat Kunjungan & Pipeline", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
                  const SizedBox(height: 8),

                  filteredList.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Center(child: Text("Tidak ada data kunjungan.", style: TextStyle(fontSize: 10, color: Colors.grey))),
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
                              DataColumn(label: Text('Tanggal & Waktu', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Jenis Kunjungan', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Keperluan', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('PIC / Sales', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Value', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Catatan & Riwayat', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Tahap Pipeline', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
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
                                    Text(item.guestName ?? '-', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                    Text(item.jabatan, style: const TextStyle(fontSize: 8, color: Colors.grey)),
                                  ],
                                )),
                                DataCell(Text(item.waktu, style: const TextStyle(fontSize: 9))),
                                DataCell(Text(item.jenisKunjungan, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600))),
                                DataCell(Text(item.notes ?? '-', style: const TextStyle(fontSize: 9))),
                                DataCell(Text(item.ownerName ?? '-', style: const TextStyle(fontSize: 9))),
                                DataCell(Text(_rupiah(item.estimatedValue), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: corporateGreen))),
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
                                DataCell(Text(badge['label'], style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: badge['color']))),
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