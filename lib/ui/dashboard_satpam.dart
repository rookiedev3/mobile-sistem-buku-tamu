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

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final result = await SecurityBloc.dashboard();
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
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: const Color(0xFF006B3F).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.security, color: Color(0xFF006B3F), size: 26),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Selamat Bertugas, Danru", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
                                SizedBox(height: 2),
                                Text("Pos Penjagaan", style: TextStyle(fontSize: 12, color: Color(0xFF778195))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text("Daftar Tamu Masuk Hari Ini", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
                    const SizedBox(height: 10),
                    if (_daftarTamu.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: Text('Belum ada tamu hari ini', style: TextStyle(color: Color(0xFF778195)))),
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
  tamu.guest?.name ?? '-',   // asumsi Guest juga punya field 'name', cek modelnya
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
  "Bertemu: ${tamu.assignedUser?['name'] ?? '-'}",  // ← akses Map pakai ['name'], bukan .name
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