import 'package:flutter/material.dart';
import 'package:mobile_flutter/bloc/database_tamu_bloc.dart';

class DatabaseTamuScreen extends StatefulWidget {
  const DatabaseTamuScreen({Key? key}) : super(key: key);

  @override
  State<DatabaseTamuScreen> createState() => _DatabaseTamuScreenState();
}

class _DatabaseTamuScreenState extends State<DatabaseTamuScreen> {
  final Color corporateGreen = const Color(0xFF006B3F);
  final TextEditingController _searchController = TextEditingController();

  // State API
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _databaseTamuList = [];

  @override
  void initState() {
    super.initState();
    _fetchDatabaseTamu();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Memuat data dari API Backend Laravel
  Future<void> _fetchDatabaseTamu() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await DatabaseTamuBloc.getDatabaseTamu(
        search: _searchController.text.trim(),
      );

      setState(() {
        _databaseTamuList = response['data'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Pop-up Detail & Timeline Riwayat Kunjungan Tamu
  void _showRiwayatPopup(BuildContext context, Map<String, dynamic> item) {
    final List timelineList = item["timelineRiwayat"] ?? [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.history_rounded, size: 18, color: corporateGreen),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                "Riwayat: ${item["nama"] ?? '-'}",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 320,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Info Profil Singkat Tamu
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F7FC),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Jabatan : ${item["jabatan"] ?? '-'} - ${item["instansi"] ?? '-'}",
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "WhatsApp: ${item["kontak"] ?? '-'}",
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Minat Produk: ${item["minatProduk"] ?? '-'} | Kategori: ${item["kategoriTamu"] ?? '-'}",
                        style: const TextStyle(
                          fontSize: 9.5,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Total Kunjungan: ${item["totalKunjungan"] ?? 0} Kali",
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: corporateGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Judul Timeline
                const Text(
                  "Timeline Riwayat Kunjungan:",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172033),
                  ),
                ),
                const SizedBox(height: 8),

                // List Timeline Riwayat
                if (timelineList.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: Text(
                        "Belum ada riwayat kunjungan.",
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ...List.generate(timelineList.length, (i) {
                    var riwayat = timelineList[i];
                    bool isTerjadwal = riwayat["status"] == "Terjadwal" ||
                        riwayat["status"] == "Selesai";

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                riwayat["waktu"] ?? '-',
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isTerjadwal
                                      ? Colors.green.shade50
                                      : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  riwayat["status"] ?? '-',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    color: isTerjadwal
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "Bertemu PIC: ${riwayat["pic"] ?? '-'}",
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: corporateGreen,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Keperluan: ${riwayat["keperluan"] ?? '-'}",
                            style: const TextStyle(
                              fontSize: 9.5,
                              color: Color(0xFF172033),
                            ),
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: corporateGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup", style: TextStyle(fontSize: 10)),
          ),
        ],
      ),
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
          "Database Tamu & Klien",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDatabaseTamu,
        color: corporateGreen,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= SEARCH BAR COMPACT =================
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SizedBox(
                  height: 32,
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _fetchDatabaseTamu(),
                    style: const TextStyle(fontSize: 10),
                    decoration: InputDecoration(
                      hintText:
                          "Cari nama tamu, instansi, atau minat produk...",
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 14,
                        color: Colors.grey,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                _fetchDatabaseTamu();
                              },
                              child: const Icon(
                                Icons.clear,
                                size: 14,
                                color: Colors.grey,
                              ),
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(
                          color: Color(0xFFE2E8F0),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(
                          color: Color(0xFFE2E8F0),
                        ),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF4F7FC),
                      isDense: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ================= TABEL DATABASE TAMU =================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tabel Database Arsip Tamu",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF172033),
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(30.0),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF006B3F),
                          ),
                        ),
                      )
                    else if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Center(
                          child: Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      )
                    else if (_databaseTamuList.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(15.0),
                        child: Center(
                          child: Text(
                            "Tidak ada data database tamu.",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowHeight: 28,
                          dataRowHeight: 40,
                          columnSpacing: 10,
                          columns: const [
                            DataColumn(
                              label: Text(
                                'No',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Nama & Kontak',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Instansi / Perusahaan',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Minat Produk',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Total Kunjungan',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Terakhir Berkunjung',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Aksi Riwayat',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          rows: List.generate(_databaseTamuList.length, (index) {
                            final item =
                                _databaseTamuList[index] as Map<String, dynamic>;

                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    (index + 1).toString(),
                                    style: const TextStyle(fontSize: 9),
                                  ),
                                ),
                                DataCell(
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        item['nama'] ?? '-',
                                        style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        item['kontak'] ?? '-',
                                        style: const TextStyle(
                                          fontSize: 8,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    item['instansi'] ?? '-',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    item['minatProduk'] ?? '-',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: corporateGreen,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    "${item['totalKunjungan'] ?? 0} Kali",
                                    style: const TextStyle(fontSize: 9),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    item['terakhirBerkunjung'] ?? '-',
                                    style: const TextStyle(fontSize: 9),
                                  ),
                                ),
                                DataCell(
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade50,
                                      foregroundColor: Colors.blue,
                                      elevation: 0,
                                      minimumSize: const Size(50, 24),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                    ),
                                    onPressed: () =>
                                        _showRiwayatPopup(context, item),
                                    child: const Text(
                                      "Lihat Riwayat",
                                      style: TextStyle(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}