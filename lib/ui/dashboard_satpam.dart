import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_flutter/bloc/security_bloc.dart';
import 'package:mobile_flutter/model/guest.dart';

class DashboardSatpam extends StatefulWidget {
  const DashboardSatpam({Key? key}) : super(key: key);

  @override
  State<DashboardSatpam> createState() => _DashboardSatpamState();
}

class _DashboardSatpamState extends State<DashboardSatpam> {
  DateTime _selectedDate = DateTime.now();
  late Future<SecurityDashboardResponse> _future;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _future = SecurityBloc.dashboard(
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
        perPage: 50,
      );
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime.now(), // 🔒 tidak boleh pilih tanggal masa depan
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _loadData();
    }
  }

  // Status di-derive dari check_in_at/check_out_at, SAMA seperti blade web.
  Map<String, dynamic> _statusInfo(Visit v) {
    if (v.checkOutAt != null) {
      return {"label": "Selesai / Keluar", "warna": "abu"};
    } else if (v.checkInAt != null) {
      return {"label": "Sedang Meeting", "warna": "hijau"};
    }
    return {"label": "Belum Masuk", "warna": "kuning"};
  }

  String _formatJam(DateTime? dt) {
    if (dt == null) return "-";
    return "${DateFormat('HH:mm').format(dt)} WIB";
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
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sapaan & Status Pos
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF006B3F).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.security, color: Color(0xFF006B3F), size: 26),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Selamat Bertugas",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Pos Penjagaan",
                            style: TextStyle(fontSize: 12, color: Color(0xFF778195)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Judul + Filter tanggal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Daftar Tamu",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                  ),
                  InkWell(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE8EDF5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 13, color: Color(0xFF006B3F)),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('d MMM yyyy').format(_selectedDate),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF172033)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              FutureBuilder<SecurityDashboardResponse>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator(color: Color(0xFF006B3F))),
                    );
                  }

                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 32),
                            const SizedBox(height: 8),
                            Text(
                              snapshot.error.toString().replaceAll('Exception: ', ''),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12, color: Colors.red),
                            ),
                            const SizedBox(height: 12),
                            TextButton(onPressed: _loadData, child: const Text("Coba Lagi")),
                          ],
                        ),
                      ),
                    );
                  }

                  final visits = snapshot.data?.visits ?? [];

                  if (visits.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          "Tidak ada data tamu pada tanggal ini.",
                          style: TextStyle(fontSize: 13, color: Color(0xFF778195)),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: visits.length,
                    itemBuilder: (context, index) {
                      final v = visits[index];
                      final info = _statusInfo(v);

                      Color badgeColor;
                      Color textColor;
                      if (info["warna"] == "hijau") {
                        badgeColor = Colors.green.withOpacity(0.1);
                        textColor = Colors.green[700]!;
                      } else if (info["warna"] == "kuning") {
                        badgeColor = Colors.orange.withOpacity(0.1);
                        textColor = Colors.orange[800]!;
                      } else {
                        badgeColor = Colors.grey.withOpacity(0.1);
                        textColor = Colors.grey[700]!;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      const CircleAvatar(
                                        radius: 16,
                                        backgroundColor: Color(0xFFF4F7FC),
                                        child: Icon(Icons.person, color: Color(0xFF778195), size: 18),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    v.guest?.name ?? '-',
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                                                  ),
                                                ),
                                                if (v.guest?.isVip == true) ...[
                                                  const SizedBox(width: 4),
                                                  const Text("⭐", style: TextStyle(fontSize: 12)),
                                                ],
                                              ],
                                            ),
                                            if ((v.guest?.companyName ?? '').isNotEmpty)
                                              Text(
                                                v.guest!.companyName!,
                                                style: const TextStyle(fontSize: 11, color: Color(0xFF778195)),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: badgeColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    info["label"],
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            Text(
                              "Bertemu: ${v.assignedUser?.name ?? '-'}",
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
                                    Text(
                                      "In: ${_formatJam(v.checkInAt)}",
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF172033)),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.logout, size: 13, color: Colors.red),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Out: ${_formatJam(v.checkOutAt)}",
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF172033)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
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