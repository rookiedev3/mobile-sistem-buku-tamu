import 'package:flutter/material.dart';

class LeadPICScreen extends StatefulWidget {
  const LeadPICScreen({Key? key}) : super(key: key);

  @override
  State<LeadPICScreen> createState() => _LeadPICScreenState();
}

class _LeadPICScreenState extends State<LeadPICScreen> with SingleTickerProviderStateMixin {
  final Color corporateGreen = const Color(0xFF006B3F);
  late TabController _tabController;

  // int _currentIndex = 1; // 1: Menu Lead di Navbar Bawah
  String _filterKategori = 'Semua Kategori'; // Semua / VIP / Reguler

  // Data Simulasi Lead & Pipeline
  final List<Map<String, dynamic>> _daftarLead = [
    {
      "id": 1,
      "token": "TRX-LD-01",
      "nama": "Budi Santoso",
      "jabatan": "Direktur PT Maju",
      "kategori": "VIP",
      "wa": "081234567890",
      "value": "Rp 15.000.000",
      "tanggalFollowUp": "2026-08-15",
      "tahap": "Baru", // Baru, Dihubungi, Negosiasi, Deal, Lost
      "statusDeal": "Aktif", // Aktif, Deal, Terlambat
      "catatanAwal": "Meminta penawaran harga khusus paket software POS.",
      "riwayatCatatan": [
        {"tanggal": "2026-08-13", "hasil": "Pertemuan pertama berjalan lancar, klien tertarik.", "tahap": "Baru"}
      ],
    },
    {
      "id": 2,
      "token": "TRX-LD-02",
      "nama": "Siti Aminah",
      "jabatan": "Consultant",
      "kategori": "Reguler",
      "wa": "089876543210",
      "value": "Rp 5.500.000",
      "tanggalFollowUp": "2026-08-13", // Hari ini
      "tahap": "Negosiasi",
      "statusDeal": "Aktif",
      "catatanAwal": "Konsultasi sistem manajemen inventaris.",
      "riwayatCatatan": [
        {"tanggal": "2026-08-10", "hasil": "Klien meminta diskon tambahan 10%.", "tahap": "Negosiasi"}
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this); // Semua, Aktif, Deal, Terlambat, Hari Ini, Mendatang
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Pop-up Riwayat Lead
  void _showRiwayatDialog(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.history_rounded, size: 18, color: corporateGreen),
            const SizedBox(width: 8),
            Text("Riwayat: ${item["nama"]}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _infoRow("Tahap Pipeline Terakhir:", item["tahap"], isBold: true),
              const SizedBox(height: 4),
              _infoRow("Jadwal Follow-Up:", item["tanggalFollowUp"]),
              const SizedBox(height: 8),
              const Divider(),
              const Text("Catatan & Pertemuan:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(6)),
                child: Text(item["catatanAwal"], style: const TextStyle(fontSize: 11, color: Color(0xFF475569))),
              ),
              const SizedBox(height: 8),
              const Text("Riwayat Observasi:", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
              const SizedBox(height: 4),
              ...((item["riwayatCatatan"] as List).map((riwayat) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(6)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Tgl: ${riwayat["tanggal"]} • Tahap: ${riwayat["tahap"]}", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: corporateGreen)),
                      const SizedBox(height: 2),
                      Text(riwayat["hasil"], style: const TextStyle(fontSize: 10, color: Color(0xFF172033))),
                    ],
                  ),
                );
              }).toList()),
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
        Text(value, style: TextStyle(fontSize: 11, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: const Color(0xFF172033))),
      ],
    );
  }

  // Pop-up Update Tahapan Lead
  void _showUpdateTahapanDialog(BuildContext context, Map<String, dynamic> item) {
    String tahapSelected = item["tahap"];
    final observasiCtrl = TextEditingController();
    final valueCtrl = TextEditingController(text: item["value"].replaceAll(RegExp(r'[^0-9]'), ''));
    final followUpCtrl = TextEditingController(text: item["tanggalFollowUp"]);

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
                // Info Klien
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(6)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item["nama"], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
                      Text("${item["jabatan"]} • WA: ${item["wa"]}", style: const TextStyle(fontSize: 10, color: Color(0xFF778195))),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Dropdown Tahap Pipeline Terbaru
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
                      items: ['Baru', 'Dihubungi', 'Negosiasi', 'Deal', 'Lost'].map((val) {
                        return DropdownMenuItem(value: val, child: Text(val));
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

                // Tanggal Follow Up dengan Date Picker Ringkas
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
                        followUpCtrl.text = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
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
              onPressed: () {
                setState(() {
                  item["tahap"] = tahapSelected;
                  if (tahapSelected == "Deal") {
                    item["statusDeal"] = "Deal";
                  } else {
                    item["statusDeal"] = "Aktif";
                  }
                  item["value"] = "Rp ${valueCtrl.text}";
                  item["tanggalFollowUp"] = followUpCtrl.text;
                  if (observasiCtrl.text.isNotEmpty) {
                    (item["riwayatCatatan"] as List).add({
                      "tanggal": followUpCtrl.text,
                      "hasil": observasiCtrl.text,
                      "tahap": tahapSelected,
                    });
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tahap pipeline berhasil diperbarui!'), backgroundColor: Color(0xFF006B3F)),
                );
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

  @override
  Widget build(BuildContext context) {
    int totalDeal = _daftarLead.where((e) => e['statusDeal'] == 'Deal').length;
    int totalAktif = _daftarLead.where((e) => e['statusDeal'] == 'Aktif').length;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Card Total Berhasil (Deal) & Total Pipeline Aktif
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Total Berhasil (Deal)", style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text("$totalDeal Klien", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[900])),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Total Pipeline Aktif", style: TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text("$totalAktif Klien", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange[900])),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 2. Card Header: Pipeline Lead & Status Konvensional
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

                  // 3. Tab Bar Ramping (Semua, Aktif, Deal, Terlambat, Hari Ini, Mendatang)
                  SizedBox(
                    height: 32,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        indicator: BoxDecoration(
                          color: corporateGreen,
                          borderRadius: BorderRadius.circular(4),
                        ),
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

                  // 4. Filter Kategori (VIP / Reguler)
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
                            items: ['Semua Kategori', 'VIP', 'Reguler'].map((String val) {
                              return DropdownMenuItem<String>(value: val, child: Text(val));
                            }).toList(),
                            onChanged: (String? val) {
                              if (val != null) setState(() => _filterKategori = val);
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

            // 5. Konten Data Lead Berdasarkan Tab & Filter
            SizedBox(
              height: 450,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLeadList(_daftarLead, "Semua"),
                  _buildLeadList(_daftarLead.where((e) => e['statusDeal'] == 'Aktif').toList(), "Aktif"),
                  _buildLeadList(_daftarLead.where((e) => e['statusDeal'] == 'Deal').toList(), "Deal"),
                  _buildLeadList([], "Terlambat"),
                  _buildLeadList(_daftarLead.where((e) => e['tanggalFollowUp'] == '2026-08-13').toList(), "Hari Ini"),
                  _buildLeadList(_daftarLead.where((e) => e['tanggalCode'] != '2026-08-13').toList(), "Mendatang"),
                ],
              ),
            ),
          ],
        ),
      ),

      // ================= NAVBAR BAWAH FRONT OFFICE (3 MENU) =================
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: _currentIndex,
      //   selectedItemColor: corporateGreen,
      //   unselectedItemColor: const Color(0xFF778195),
      //   backgroundColor: Colors.white,
      //   type: BottomNavigationBarType.fixed,
      //   selectedFontSize: 10,
      //   unselectedFontSize: 10,
      //   onTap: (index) {
      //     setState(() {
      //       _currentIndex = index;
      //     });
      //     if (index == 0) {
      //       // Navigasi ke Dashboard FO (Bisa pakai Navigator.pop jika sudah terhubung)
      //       Navigator.pop(context);
      //     } else if (index == 1) {
      //       // Sedang di halaman Lead
      //     } else if (index == 2) {
      //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Navigasi ke Riwayat Kunjungan')));
      //     }
      //   },
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded, size: 20), label: 'Dashboard'),
      //     BottomNavigationBarItem(icon: Icon(Icons.trending_up_rounded, size: 20), label: 'Lead'),
      //     BottomNavigationBarItem(icon: Icon(Icons.history_rounded, size: 20), label: 'Riwayat'),
      //   ],
      // ),
    );
  }

  Widget _buildLeadList(List<Map<String, dynamic>> listData, String tabName) {
    List filtered = listData.where((item) {
      if (_filterKategori == 'VIP') return item['kategori'] == 'VIP';
      if (_filterKategori == 'Reguler') return item['kategori'] == 'Reguler';
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text("Tidak ada data lead untuk tab $tabName.", style: const TextStyle(color: Color(0xFF778195), fontSize: 11)),
      );
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];

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
                    child: Text("Token: ${item["token"]}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF006B3F))),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: item["kategori"] == "VIP" ? Colors.amber.withOpacity(0.2) : Colors.grey.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(item["kategori"], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: item["kategori"] == "VIP" ? Colors.amber[800] : Colors.grey[700])),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(item["nama"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF172033))),
              Text(item["jabatan"], style: const TextStyle(fontSize: 10, color: Color(0xFF778195))),
              const SizedBox(height: 4),
              Text("No. WA: ${item["wa"]} • Value: ${item["value"]}", style: const TextStyle(fontSize: 10, color: Color(0xFF006B3F), fontWeight: FontWeight.bold)),
              Text("Follow-Up: ${item["tanggalFollowUp"]} • Tahap: ${item["tahap"]}", style: const TextStyle(fontSize: 10, color: Color(0xFF778195))),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6.0),
                child: Divider(height: 1, color: Color(0xFFE5E7EB)),
              ),

              // Tombol Aksi (Riwayat & Update Tahapan)
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
      },
    );
  }
}