import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/bloc/pic_lead_bloc.dart'; // sesuaikan path
import '/model/pic_model.dart'; // sesuaikan path (PicLeadModel, PicLeadsResponse, dst)

/// Formatter buat nampilin angka pakai titik ribuan saat diketik,
/// contoh: user ngetik "5000000" -> tampil "5.000.000".
/// Value yang tersimpan di controller.text TETAP string berformat titik,
/// jadi wajib di-strip titiknya lagi sebelum di-parse ke num (lihat
/// bagian onPressed tombol Simpan).
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

  // === PAGINATION STATE (page-based, sama pola dengan DashboardPICScreen) ===
  static const int _perPage = 10; // sesuaikan kalau perlu
  int _currentPage = 1;
  int _lastPage = 1;

  // Urutan tab harus sama persis dengan urutan Tab() di TabBar di bawah.
  static const List<String> _tabFilters = ['all', 'active', 'deal', 'overdue', 'today', 'upcoming'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) _fetchLeads(page: 1); // ganti tab -> reset ke halaman 1
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

  Future<void> _fetchLeads({int page = 1}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await PicLeadBloc.fetchLeads(
        filter: _tabFilters[_tabController.index],
        vipStatus: _vipParam,
        page: page,
        perPage: _perPage,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _daftarLead = result.leads;
        _counts = result.counts;
        _currentPage = result.currentPage;
        _lastPage = result.lastPage;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  // Dipanggil dari tombol prev/next di _buildBody.
  void _gotoPage(int page) {
    if (page < 1 || page > _lastPage) return;
    _fetchLeads(page: page);
  }

  void _onFilterKategoriChanged(String val) {
    setState(() => _filterKategori = val);
    _fetchLeads(page: 1); // ganti filter kategori -> reset ke halaman 1
  }

  // ===================== HELPERS: LABEL, TANGGAL & STATUS =====================

  String _statusLabel(String? status) {
    switch (status) {
      case 'new':
        return 'Baru (Belum Dihubungi)';
      case 'contacted':
        return 'Dihubungi';
      case 'negotiation':
        return 'Negosiasi';
      case 'deal':
        return 'Deal / Berhasil';
      case 'lost':
        return 'Lost';
      default:
        return status ?? '-';
    }
  }

  // Deal & Lost = pipeline sudah final, gak bisa diupdate lagi.
  bool _isFollowUpLocked(String status) => status == 'deal' || status == 'lost';

  bool _isZeroOrEmptyDate(String? raw) {
    if (raw == null || raw.isEmpty) return true;
    if (raw.startsWith('0000-00-00') || raw.startsWith('0001-01-01')) return true;
    return false;
  }

  String _formatFollowUp(String? raw) {
    if (_isZeroOrEmptyDate(raw)) return 'Belum dijadwalkan';
    try {
      final date = DateTime.parse(raw!);
      return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
    } catch (_) {
      return 'Belum dijadwalkan';
    }
  }

  String _followUpInputValue(String? raw) {
    if (_isZeroOrEmptyDate(raw)) return '';
    try {
      final date = DateTime.parse(raw!);
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    } catch (_) {
      return '';
    }
  }

  int? _overdueDays(String? followUpAt, String? status) {
    if (_isZeroOrEmptyDate(followUpAt) || _isFollowUpLocked(status ?? '')) return null;
    try {
      final date = DateTime.parse(followUpAt!);
      final today = DateTime.now();
      final dateOnly = DateTime(date.year, date.month, date.day);
      final todayOnly = DateTime(today.year, today.month, today.day);
      final diff = todayOnly.difference(dateOnly).inDays;
      return diff > 0 ? diff : null;
    } catch (_) {
      return null;
    }
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
              _infoRow("Tahap Pipeline Terakhir:", _statusLabel(item.status), isBold: true),
              const SizedBox(height: 4),
              _followUpInfoRow(item.followUpAt, item.status),
              const SizedBox(height: 8),
              const Divider(),
              const Text(
                "Hasil Pertemuan:",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(6)),
                child: Text(
                  (item.meetingResult ?? '').isNotEmpty ? item.meetingResult! : '-',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Catatan Awal:",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(6)),
                child: Text(item.notes ?? '-', style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
              ),
              const SizedBox(height: 8),
              const Text(
                "Riwayat Update Pipeline:",
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
                          "Tgl: ${f.createdAt ?? '-'} • Tahap: ${_statusLabel(f.status)}",
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: corporateGreen),
                        ),
                        const SizedBox(height: 2),
                        Text(f.result ?? '-', style: const TextStyle(fontSize: 10, color: Color(0xFF172033))),
                        if (f.estimatedValue != null && f.estimatedValue! > 0) ...[
                          const SizedBox(height: 2),
                          Text(
                            "Estimasi: Rp ${_formatRibuan(f.estimatedValue!)}",
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF006B3F)),
                          ),
                        ],
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

  Widget _followUpInfoRow(String? followUpAt, String? status) {
    final overdueDays = _overdueDays(followUpAt, status);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Jadwal Follow-Up:", style: TextStyle(fontSize: 11, color: Color(0xFF778195))),
        Text(
          overdueDays != null
              ? "${_formatFollowUp(followUpAt)} (Terlambat $overdueDays hari)"
              : _formatFollowUp(followUpAt),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: overdueDays != null ? Colors.red[700] : const Color(0xFF172033),
          ),
        ),
      ],
    );
  }

  // ===================== DIALOG: UPDATE TAHAPAN =====================

  void _showUpdateTahapanDialog(BuildContext context, PicLeadModel item) {
    String tahapSelected = item.status ?? 'new';
    final observasiCtrl = TextEditingController();
    final valueCtrl = TextEditingController(text: _formatRibuan(item.estimatedValue ?? 0));
    final followUpCtrl = TextEditingController(text: _followUpInputValue(item.followUpAt));

    // Status loading khusus dialog ini, biar tombol Simpan bisa
    // nunjukin spinner + kedisable pas lagi ngirim ke server.
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final isLocked = _isFollowUpLocked(tahapSelected);

          Future<void> handleSimpan() async {
            final cleanValueText = valueCtrl.text.replaceAll('.', '').trim();
            final estValue = cleanValueText.isEmpty ? null : num.tryParse(cleanValueText);

            if (tahapSelected == 'deal' && (estValue == null || estValue <= 0)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Estimasi nilai wajib diisi (lebih dari Rp 0) untuk status Deal.'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            if (!_isFollowUpLocked(tahapSelected) && followUpCtrl.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tanggal follow-up wajib dipilih.'), backgroundColor: Colors.red),
              );
              return;
            }

            // Mulai loading — dialog TETAP kebuka sampai request selesai,
            // jadi user lihat spinner, bukan cuma diem.
            setDialogState(() => isSaving = true);

            try {
              await PicLeadBloc.updateFollowUp(
                leadId: item.id,
                status: tahapSelected,
                result: observasiCtrl.text.isNotEmpty ? observasiCtrl.text : null,
                estimatedValue: estValue,
                dueAt: !_isFollowUpLocked(tahapSelected) && followUpCtrl.text.isNotEmpty ? followUpCtrl.text : null,
              ).timeout(
                const Duration(seconds: 15),
                onTimeout: () => throw Exception(
                  'Waktu tunggu server habis (15 detik). Coba lagi atau periksa koneksi.',
                ),
              );

              if (!mounted) return;
              Navigator.pop(dialogContext); // Tutup dialog HANYA setelah request beneran selesai/berhasil.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tahap pipeline berhasil diperbarui!'),
                  backgroundColor: Color(0xFF006B3F),
                ),
              );
              _fetchLeads(page: _currentPage); // reload di halaman yang sama, bukan reset ke 1
            } catch (e) {
              // Kalau gagal, dialog TETAP kebuka + spinner dimatiin,
              // biar user bisa coba lagi tanpa isi ulang form dari nol.
              setDialogState(() => isSaving = false);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Gagal memperbarui data: ${e.toString().replaceFirst('Exception: ', '')}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }

          return AlertDialog(
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
                        if ((item.companyName ?? '').isNotEmpty)
                          Text(item.companyName!, style: const TextStyle(fontSize: 10, color: Color(0xFF778195))),
                        if ((item.guestPhone ?? '').isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              children: [
                                const Icon(Icons.phone, size: 11, color: Color(0xFF25D366)),
                                const SizedBox(width: 4),
                                Text(item.guestPhone!, style: const TextStyle(fontSize: 10, color: Color(0xFF475569), fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
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
                        items: const [
                          DropdownMenuItem(value: 'new', child: Text('Baru (Belum Dihubungi)')),
                          DropdownMenuItem(value: 'contacted', child: Text('Dihubungi')),
                          DropdownMenuItem(value: 'negotiation', child: Text('Negosiasi')),
                          DropdownMenuItem(value: 'deal', child: Text('Deal / Berhasil')),
                          DropdownMenuItem(value: 'lost', child: Text('Lost')),
                        ],
                        onChanged: isSaving
                            ? null
                            : (val) {
                                if (val != null) {
                                  setDialogState(() {
                                    tahapSelected = val;
                                    if (_isFollowUpLocked(val)) followUpCtrl.text = '';
                                  });
                                }
                              },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _dialogField("Hasil Observasi Follow-Up Hari Ini", observasiCtrl, maxLines: 2, enabled: !isSaving),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tahapSelected == 'deal' ? "Estimasi Nilai Deal (Rp) *" : "Estimasi Nilai Deal (Rp)",
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF778195)),
                      ),
                      const SizedBox(height: 3),
                      TextField(
                        controller: valueCtrl,
                        enabled: !isSaving,
                        keyboardType: TextInputType.number,
                        inputFormatters: [_RibuanInputFormatter()],
                        style: const TextStyle(fontSize: 11),
                        decoration: InputDecoration(
                          prefixText: 'Rp ',
                          prefixStyle: const TextStyle(fontSize: 11, color: Color(0xFF172033), fontWeight: FontWeight.bold),
                          contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                          filled: true,
                          fillColor: const Color(0xFFF4F7FC),
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isLocked ? "Jadwal Follow-Up (tidak diperlukan)" : "Jadwal Follow-Up",
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF778195)),
                  ),
                  const SizedBox(height: 3),
                  TextField(
                    controller: followUpCtrl,
                    readOnly: true,
                    enabled: !isLocked && !isSaving,
                    style: TextStyle(fontSize: 11, color: isLocked ? const Color(0xFF9CA3AF) : const Color(0xFF172033)),
                    decoration: InputDecoration(
                      hintText: isLocked ? "Tidak perlu follow-up" : "Pilih tanggal...",
                      hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                      suffixIcon: Icon(Icons.calendar_today_rounded,
                          size: 16, color: isLocked ? const Color(0xFF9CA3AF) : const Color(0xFF006B3F)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      filled: true,
                      fillColor: isLocked ? const Color(0xFFF1F5F9) : const Color(0xFFF4F7FC),
                      isDense: true,
                    ),
                    onTap: (isLocked || isSaving)
                        ? null
                        : () async {
                            // 🔒 firstDate = hari ini → tanggal kebelakang (masa lalu)
                            // otomatis di-block/disable di kalender.
                            final now = DateTime.now();
                            final today = DateTime(now.year, now.month, now.day);

                            // Kalau followUp yang lagi tersimpan sudah lewat
                            // (lead overdue), jangan pakai tanggal itu sebagai
                            // initialDate — nanti crash karena initialDate wajib
                            // >= firstDate. Fallback ke hari ini.
                            DateTime initial = today;
                            final existing = _followUpInputValue(item.followUpAt);
                            if (existing.isNotEmpty) {
                              final parsed = DateTime.tryParse(existing);
                              if (parsed != null && !parsed.isBefore(today)) {
                                initial = parsed;
                              }
                            }

                            DateTime? pickedDate = await showDatePicker(
                              context: dialogContext,
                              initialDate: initial,
                              firstDate: today,
                              lastDate: DateTime(now.year + 2),
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
                onPressed: isSaving ? null : () => Navigator.pop(dialogContext),
                child: const Text("Batal", style: TextStyle(fontSize: 11, color: Color(0xFF778195))),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: corporateGreen, foregroundColor: Colors.white, elevation: 0),
                onPressed: isSaving ? null : handleSimpan,
                child: isSaving
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text("Simpan", style: TextStyle(fontSize: 11)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _dialogField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF778195))),
        const SizedBox(height: 3),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          enabled: enabled,
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
        onRefresh: () => _fetchLeads(page: 1),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: _summaryCard("Total Berhasil (Deal)", "$totalDeal Klien", Colors.green)),
                  const SizedBox(width: 10),
                  Expanded(child: _summaryCard("Total Pipeline Aktif", "$totalAktif Klien", Colors.orange)),
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
                          // NOTE: gak boleh `const` lagi karena isinya sekarang
                          // dinamis (ikut _counts yang berubah tiap fetch).
                          tabs: [
                            Tab(text: "Semua(${_counts['all'] ?? 0})"),
                            Tab(text: "Aktif(${_counts['active'] ?? 0})"),
                            Tab(text: "Deal(${_counts['deal'] ?? 0})"),
                            Tab(text: "Terlambat(${_counts['overdue'] ?? 0})"),
                            Tab(text: "Hari Ini(${_counts['today'] ?? 0})"),
                            Tab(text: "Mendatang(${_counts['upcoming'] ?? 0})"),
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
            OutlinedButton(onPressed: () => _fetchLeads(page: _currentPage), child: const Text("Coba Lagi", style: TextStyle(fontSize: 11))),
          ],
        ),
      );
    }
    if (_daftarLead.isEmpty) {
      return const Center(
        child: Text("Tidak ada data lead untuk tab ini.", style: TextStyle(color: Color(0xFF778195), fontSize: 11)),
      );
    }

    // === PAGINATION: page-based (prev/next), tanpa garis pemisah ===
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _daftarLead.length,
            itemBuilder: (context, index) => _leadCard(_daftarLead[index]),
          ),
        ),
        if (_lastPage > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                color: corporateGreen,
                onPressed: _currentPage > 1 ? () => _gotoPage(_currentPage - 1) : null,
              ),
              Text(
                '$_currentPage / $_lastPage',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                color: corporateGreen,
                onPressed: _currentPage < _lastPage ? () => _gotoPage(_currentPage + 1) : null,
              ),
            ],
          ),
      ],
    );
  }

  Widget _leadCard(PicLeadModel item) {
    final overdueDays = _overdueDays(item.followUpAt, item.status);
    final isLocked = _isFollowUpLocked(item.status ?? '');

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
          if ((item.companyName ?? '').isNotEmpty)
            Text(item.companyName!, style: const TextStyle(fontSize: 10, color: Color(0xFF778195))),
          if ((item.guestPhone ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                children: [
                  const Icon(Icons.phone, size: 11, color: Color(0xFF25D366)),
                  const SizedBox(width: 4),
                  Text(item.guestPhone!, style: const TextStyle(fontSize: 10, color: Color(0xFF475569), fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          const SizedBox(height: 4),
          Text(
            "Value: Rp ${_formatRibuan(item.estimatedValue ?? 0)}",
            style: const TextStyle(fontSize: 10, color: Color(0xFF006B3F), fontWeight: FontWeight.bold),
          ),
          Text(
            overdueDays != null
                ? "Follow-Up: ${_formatFollowUp(item.followUpAt)} (Terlambat $overdueDays hari) • Tahap: ${_statusLabel(item.status)}"
                : "Follow-Up: ${_formatFollowUp(item.followUpAt)} • Tahap: ${_statusLabel(item.status)}",
            style: TextStyle(
              fontSize: 10,
              color: overdueDays != null ? Colors.red[700] : const Color(0xFF778195),
              fontWeight: overdueDays != null ? FontWeight.bold : FontWeight.normal,
            ),
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
              // Deal/Lost = pipeline sudah final -> tombol update dikunci,
              // gak perlu nunggu backend nolak dulu buat kasih tau user.
              ElevatedButton.icon(
                onPressed: isLocked ? null : () => _showUpdateTahapanDialog(context, item),
                icon: Icon(Icons.update, size: 12, color: isLocked ? Colors.grey[400] : Colors.white),
                label: Text(
                  isLocked ? "Sudah Final" : "Update Tahapan",
                  style: TextStyle(fontSize: 10, color: isLocked ? Colors.grey[400] : Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLocked ? Colors.grey[300] : corporateGreen,
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