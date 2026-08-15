import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '/helpers/api_url.dart'; // sesuaikan path import ApiUrl dengan struktur project kamu

class RiwayatPICScreen extends StatefulWidget {
  const RiwayatPICScreen({Key? key}) : super(key: key);

  @override
  State<RiwayatPICScreen> createState() => _RiwayatPICScreenState();
}

class _RiwayatPICScreenState extends State<RiwayatPICScreen> {
  final Color corporateGreen = const Color(0xFF006B3F);

  // Controller Pencarian & Filter
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  String _filterStatus = 'Semua Kategori'; // Semua Kategori / VIP / Reguler
  String _dariTanggal = '';
  String _sampaiTanggal = '';

  // Data dari API
  List<Map<String, dynamic>> _daftarRiwayat = [];
  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  // ← TAMBAHAN: badge warna per status pipeline, meniru $leadBadges di Blade
  final Map<String, Map<String, Color>> _statusColors = {
    'new':         {'bg': const Color(0xFFF1F5F9), 'fg': const Color(0xFF475569)},
    'contacted':   {'bg': const Color(0xFFDBEAFE), 'fg': const Color(0xFF1D4ED8)},
    'negotiation': {'bg': const Color(0xFFFEF3C7), 'fg': const Color(0xFFD97706)},
    'deal':        {'bg': const Color(0xFFDCFCE7), 'fg': const Color(0xFF15803D)},
    'lost':        {'bg': const Color(0xFFFEE2E2), 'fg': const Color(0xFFB91C1C)},
    'cancelled':   {'bg': const Color(0xFFFEF2F2), 'fg': const Color(0xFFDC2626)},
    'non_lead':    {'bg': const Color(0xFFF1F5F9), 'fg': const Color(0xFF475569)},
  };

  @override
  void initState() {
    super.initState();
    _fetchRiwayat(reset: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _currentPage < _lastPage) {
      _fetchRiwayat(loadMore: true);
    }
  }

  String? _mapVipStatus() {
    switch (_filterStatus) {
      case 'VIP':
        return 'vip';
      case 'Reguler':
        return 'reguler';
      default:
        return 'all';
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _fetchRiwayat({bool reset = false, bool loadMore = false}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _currentPage = 1;
        _daftarRiwayat = [];
      });
    } else if (loadMore) {
      setState(() => _isLoadingMore = true);
    }

    try {
      final token = await _getToken();
      final page = reset ? 1 : (loadMore ? _currentPage + 1 : _currentPage);

      final url = ApiUrl.picRiwayat(
        keyword: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
        startDate: _dariTanggal.isEmpty ? null : _dariTanggal,
        endDate: _sampaiTanggal.isEmpty ? null : _sampaiTanggal,
        vipStatus: _mapVipStatus() ?? 'all',
        page: page,
        perPage: 10,
      );

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List data = body['data'] ?? [];
        final meta = body['meta'] ?? {};

        setState(() {
          if (loadMore) {
            _daftarRiwayat.addAll(data.cast<Map<String, dynamic>>());
          } else {
            _daftarRiwayat = data.cast<Map<String, dynamic>>();
          }
          _currentPage = meta['current_page'] ?? page;
          _lastPage = meta['last_page'] ?? 1;
          _errorMessage = null;
        });
      } else if (response.statusCode == 401) {
        setState(() => _errorMessage = 'Sesi berakhir, silakan login kembali.');
      } else {
        setState(() => _errorMessage = 'Gagal memuat data (${response.statusCode}).');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Terjadi kesalahan koneksi. Coba lagi.');
    } finally {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchRiwayat(reset: true);
    });
  }

  // ← TAMBAHAN: format angka jadi Rupiah, meniru helper rupiah() di Blade
  String _formatRupiah(dynamic value) {
    if (value == null) return '-';
    final number = value is String ? num.tryParse(value) : value as num?;
    if (number == null) return '-';
    final str = number.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final posFromEnd = str.length - i;
      buffer.write(str[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) buffer.write('.');
    }
    return 'Rp $buffer';
  }

  Map<String, Color> _colorForStatus(String? key) {
    return _statusColors[key] ?? _statusColors['non_lead']!;
  }

  // Pop-up Detail Catatan & Riwayat Kunjungan
  void _showDetailCatatanDialog(BuildContext context, Map<String, dynamic> item) {
    final List riwayatPipeline = item["riwayatPipeline"] ?? [];
    final bool isVip = item["isVip"] == true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.history_edu_rounded, size: 18, color: corporateGreen),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      "Detail Kunjungan: ${item["nama"] ?? '-'}",
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isVip) const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text("⭐", style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _infoRow("Token:", item["token"] ?? '-'),
              _infoRow("Jabatan:", item["jabatan"] ?? '-'),
              _infoRow("Instansi:", item["instansi"] ?? '-'),
              const Divider(height: 16),
              _infoRow("Tahap Pipeline Terakhir:", item["tahapPipeline"] ?? '-', isBold: true),
              _infoRow("Jadwal / Keterangan Status:", item["keteranganStatus"] ?? '-', isBold: true),
              _infoRow("Estimasi Value:", _formatRupiah(item["estimasiValue"]), isBold: true),
              const SizedBox(height: 8),

              const Text("📝 Catatan Awal Kunjungan:",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(6)),
                child: Text(item["catatanAwal"] ?? '-', style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
              ),
              const SizedBox(height: 10),

              // ← TAMBAHAN: Hasil Meeting Pertama (sebelumnya belum ditampilkan)
              const Text("📌 Hasil Meeting Pertama:",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(6)),
                child: Text(item["hasilMeeting"] ?? '-', style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
              ),
              const SizedBox(height: 10),

              const Text("🔄 Riwayat Update Pipeline:",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
              const SizedBox(height: 4),
              if (riwayatPipeline.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: const Text(
                    "Tidak ada riwayat update pipeline untuk kunjungan ini.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontStyle: FontStyle.italic),
                  ),
                )
              else
                ...riwayatPipeline.map((riwayat) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDFDFD),
                      borderRadius: BorderRadius.circular(8),
                      border: const Border(
                        top: BorderSide(color: Color(0xFFE2E8F0)),
                        right: BorderSide(color: Color(0xFFE2E8F0)),
                        bottom: BorderSide(color: Color(0xFFE2E8F0)),
                        left: BorderSide(color: Color(0xFF006B3F), width: 4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "📅 ${riwayat["tanggal"] ?? '-'}",
                                style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                              ),
                            ),
                            Text(
                              "Tahap: ${riwayat["tahap"] ?? '-'}",
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: corporateGreen),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          riwayat["catatan"] ?? 'Tidak ada detail catatan pada pembaruan ini.',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF334155)),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 12,
                          children: [
                            Text(
                              "💰 ${_formatRupiah(riwayat["estimasiValue"])}",
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: corporateGreen),
                            ),
                            if (riwayat["dueDate"] != null)
                              Text(
                                "Target: ${riwayat["dueDate"]}",
                                style: const TextStyle(fontSize: 10, color: Color(0xFF475569)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF778195))),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 11, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: const Color(0xFF172033)),
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi Pilih Tanggal Filter
  Future<void> _pilihTanggal(BuildContext context, bool isDari) async {
    DateTime? picked = await showDatePicker(
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
    if (picked != null) {
      setState(() {
        String formatted = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        if (isDari) {
          _dariTanggal = formatted;
        } else {
          _sampaiTanggal = formatted;
        }
      });
      _fetchRiwayat(reset: true);
    }
  }

  // Reset Filter
  void _resetFilter() {
    setState(() {
      _searchController.clear();
      _filterStatus = 'Semua Kategori';
      _dariTanggal = '';
      _sampaiTanggal = '';
    });
    _fetchRiwayat(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: corporateGreen,
        elevation: 0,
        title: const Text(
          "Front Office - Riwayat Kunjungan",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: RefreshIndicator(
        color: corporateGreen,
        onRefresh: () => _fetchRiwayat(reset: true),
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card Pencarian & Filter Lengkap
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
                    const Text("Filter & Pencarian Arsip Kunjungan", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
                    const SizedBox(height: 8),

                    // Search Bar berdasarkan Nama / Instansi
                    TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: const TextStyle(fontSize: 11),
                      decoration: InputDecoration(
                        hintText: "Cari nama tamu atau instansi...",
                        hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                        prefixIcon: const Icon(Icons.search, size: 16, color: Color(0xFF778195)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        filled: true,
                        fillColor: const Color(0xFFF4F7FC),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Filter Tanggal & Status (VIP / Reguler)
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _pilihTanggal(context, true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4F7FC),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 12, color: Color(0xFF778195)),
                                  const SizedBox(width: 4),
                                  Text(_dariTanggal.isEmpty ? "Dari Tgl" : _dariTanggal, style: const TextStyle(fontSize: 10, color: Color(0xFF172033))),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: InkWell(
                            onTap: () => _pilihTanggal(context, false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF4F7FC),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 12, color: Color(0xFF778195)),
                                  const SizedBox(width: 4),
                                  Text(_sampaiTanggal.isEmpty ? "Sampai Tgl" : _sampaiTanggal, style: const TextStyle(fontSize: 10, color: Color(0xFF172033))),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F7FC),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _filterStatus,
                              isDense: true,
                              style: const TextStyle(fontSize: 10, color: Color(0xFF172033), fontWeight: FontWeight.bold),
                              items: ['Semua Kategori', 'VIP', 'Reguler'].map((String val) {
                                return DropdownMenuItem<String>(value: val, child: Text(val));
                              }).toList(),
                              onChanged: (String? val) {
                                if (val != null) {
                                  setState(() => _filterStatus = val);
                                  _fetchRiwayat(reset: true);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: _resetFilter,
                        icon: const Icon(Icons.refresh, size: 12, color: Colors.grey),
                        label: const Text("Reset Filter", style: TextStyle(fontSize: 10, color: Color(0xFF778195))),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          minimumSize: const Size(60, 24),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Konten: loading / error / kosong / list
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.wifi_off_rounded, color: Colors.grey[400], size: 32),
                        const SizedBox(height: 8),
                        Text(_errorMessage!, style: const TextStyle(color: Color(0xFF778195), fontSize: 11), textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => _fetchRiwayat(reset: true),
                          child: const Text("Coba Lagi", style: TextStyle(fontSize: 11)),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_daftarRiwayat.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Text("Belum ada riwayat kunjungan yang ditangani.", style: TextStyle(color: Color(0xFF778195), fontSize: 11)),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _daftarRiwayat.length,
                  itemBuilder: (context, index) {
                    final item = _daftarRiwayat[index];
                    final bool isVip = item["isVip"] == true;
                    final String statusKey = item["statusAkhirKey"] ?? 'non_lead';
                    final statusColor = _colorForStatus(statusKey);

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
                                child: Text("Token: ${item["token"] ?? '-'}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF006B3F))),
                              ),
                              // ← DIUBAH: badge status pipeline berwarna sesuai tahap, bukan cuma merah/hijau
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: statusColor['bg'],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item["statusAkhir"] ?? '-',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor['fg']),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // ← DIUBAH: tampilkan bintang VIP di sebelah nama, seperti di Blade
                          Row(
                            children: [
                              Flexible(
                                child: Text(item["nama"] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF172033))),
                              ),
                              if (isVip) const Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Text("⭐", style: TextStyle(fontSize: 11)),
                              ),
                            ],
                          ),
                          // ← DIUBAH: jabatan & instansi ditampilkan (sebelumnya sudah ada tapi urutannya disesuaikan dgn Blade: Instansi (Jabatan))
                          Text("${item["instansi"] ?? '-'} (${item["jabatan"] ?? '-'})", style: const TextStyle(fontSize: 10, color: Color(0xFF778195))),
                          const SizedBox(height: 4),
                          Text("Waktu: ${item["waktu"] ?? '-'}", style: const TextStyle(fontSize: 10, color: Color(0xFF006B3F), fontWeight: FontWeight.w600)),
                          Text("Keperluan: ${item["keperluan"] ?? '-'}", style: const TextStyle(fontSize: 10, color: Color(0xFF778195))),

                          // ← TAMBAHAN: tampilkan estimasi value langsung di kartu kalau ada
                          if (item["estimasiValue"] != null) ...[
                            const SizedBox(height: 2),
                            Text("Estimasi Value: ${_formatRupiah(item["estimasiValue"])}", style: TextStyle(fontSize: 10, color: corporateGreen, fontWeight: FontWeight.w600)),
                          ],
                          const SizedBox(height: 6),

                          // ← DIUBAH: tombol catatan hanya aktif kalau isCompleted (samakan dgn Blade: dibatalkan/belum selesai tidak ada catatan)
                          if (item["isCompleted"] == true)
                            InkWell(
                              onTap: () => _showDetailCatatanDialog(context, item),
                              child: Row(
                                children: const [
                                  Icon(Icons.speaker_notes_rounded, size: 13, color: Colors.blue),
                                  SizedBox(width: 4),
                                  Text("Lihat Detail Catatan & Riwayat", style: TextStyle(fontSize: 10, color: Colors.blue, decoration: TextDecoration.underline)),
                                ],
                              ),
                            )
                          else
                            const Text("Dibatalkan / Belum Selesai", style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontStyle: FontStyle.italic)),
                        ],
                      ),
                    );
                  },
                ),

              if (_isLoadingMore)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}