import 'package:flutter/material.dart';
import 'package:mobile_flutter/bloc/security_bloc.dart';
import 'package:mobile_flutter/model/visit.dart';

class DashboardSatpam extends StatefulWidget {
  const DashboardSatpam({Key? key}) : super(key: key);

  @override
  State<DashboardSatpam> createState() => _DashboardSatpamState();
}

class _DashboardSatpamState extends State<DashboardSatpam> {
  List<Visit> _daftarTamu = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

Future<void> _fetchData() async {
  setState(() => _isLoading = true);
  try {
    final result = await SecurityBloc.dashboard(
      date: _formatDateForApi(_selectedDate), // "2026-08-16"
    );
    setState(() => _daftarTamu = result.data ?? []);
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal memuat data: ${e.toString().replaceAll('Exception: ', '')}')),
    );
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

String _formatDateForApi(DateTime d) {
  return '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

  Future<void> _pilihTanggal() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 2), // batas paling lama, sesuaikan kalau perlu
      lastDate: now, // 🔒 blok tanggal ke depan — user hanya bisa lihat ke belakang
      helpText: 'Pilih Tanggal',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF006B3F)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _fetchData();
    }
  }

  String _formatTanggal(DateTime d) {
    const namaBulan = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${d.day} ${namaBulan[d.month - 1]} ${d.year}';
  }

  bool get _isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  // Tentukan status tampilan dari check_in_at/check_out_at, bukan dari string 'status' mentah
  Map<String, dynamic> _statusInfo(Visit v) {
    if (v.checkOutAt != null) {
      return {"label": "Selesai", "badgeColor": Colors.grey.withOpacity(0.1), "textColor": Colors.grey[700]};
    }
    if (v.checkInAt != null) {
      return {"label": "Sedang Meeting", "badgeColor": Colors.green.withOpacity(0.1), "textColor": Colors.green[700]};
    }
    return {"label": "Sedang Menunggu", "badgeColor": Colors.orange.withOpacity(0.1), "textColor": Colors.orange[800]};
  }

  String _formatJam(String? isoTime) {
    if (isoTime == null) return '-';
    try {
      final dt = DateTime.parse(isoTime).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} WIB';
    } catch (_) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF006B3F),
        elevation: 0,
        title: const Text(
          "Dashboard Satpam - Pos Penjagaan",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _fetchData),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF006B3F)))
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selector tanggal
                    InkWell(
                      onTap: _pilihTanggal,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 18, color: Color(0xFF006B3F)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isToday ? "Hari Ini" : "Tanggal Dipilih",
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF778195)),
                                  ),
                                  Text(
                                    _formatTanggal(_selectedDate),
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                                  ),
                                ],
                              ),
                            ),
                            if (!_isToday)
                              TextButton(
                                onPressed: () {
                                  setState(() => _selectedDate = DateTime.now());
                                  _fetchData();
                                },
                                child: const Text("Kembali ke Hari Ini", style: TextStyle(fontSize: 11, color: Color(0xFF006B3F))),
                              ),
                            const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF778195)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _isToday ? "Daftar Tamu Masuk Hari Ini" : "Daftar Tamu Masuk (${_formatTanggal(_selectedDate)})",
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                    ),
                    const SizedBox(height: 10),
                    if (_daftarTamu.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: Text('Belum ada tamu pada tanggal ini', style: TextStyle(color: Color(0xFF778195)))),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _daftarTamu.length,
                        itemBuilder: (context, index) {
                          final tamu = _daftarTamu[index];
                          final statusInfo = _statusInfo(tamu);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const CircleAvatar(
                                          radius: 16,
                                          backgroundColor: Color(0xFFF4F7FC),
                                          child: Icon(Icons.person, color: Color(0xFF778195), size: 18),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          tamu.guest?.name ?? '-',
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: statusInfo["badgeColor"], borderRadius: BorderRadius.circular(6)),
                                      child: Text(
                                        statusInfo["label"],
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusInfo["textColor"]),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Bertemu: ${tamu.assignedUser?['name'] ?? '-'}",
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF778195)),
                                ),
                                const SizedBox(height: 10),
                                const Divider(height: 1, color: Color(0xFFF4F7FC)),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.login, size: 13, color: Colors.green),
                                        const SizedBox(width: 4),
                                        Text("In: ${_formatJam(tamu.checkInAt)}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF172033))),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.logout, size: 13, color: Colors.red),
                                        const SizedBox(width: 4),
                                        Text("Out: ${_formatJam(tamu.checkOutAt)}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF172033))),
                                      ],
                                    ),
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