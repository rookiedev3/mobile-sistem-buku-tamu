import 'package:flutter/material.dart';
import 'package:mobile_flutter/ui/homepage_screen.dart';

// Impor halaman HomepageScreen Anda di sini (sesuaikan path foldernya)
// import 'homepage_screen.dart';

class DashboardPICScreen extends StatefulWidget {
  const DashboardPICScreen({Key? key}) : super(key: key);

  @override
  State<DashboardPICScreen> createState() => _DashboardPICScreenState();
}

class _DashboardPICScreenState extends State<DashboardPICScreen> with SingleTickerProviderStateMixin {
  final Color corporateGreen = const Color(0xFF006B3F);
  late TabController _tabController;

  String _filterKategori = 'Semua Kategori'; // Semua / VIP / Reguler

  // Data Simulasi Tamu Masuk Front Office
  final List<Map<String, dynamic>> _daftarTamuFO = [
    {
      "id": 1,
      "token": "TRX-FO-01",
      "nama": "Budi Santoso",
      "jabatan": "Direktur PT Maju",
      "kategori": "VIP",
      "waktu": "13 Agu 2026, 10:00 WIB",
      "tanggal": "2026-08-13", // Hari ini
      "jenis": "Meeting Bisnis",
      "keperluan": "Diskusi kerja sama proyek IT",
      "catatan": "Tamu meminta membawa proposal cetak terbaru.",
      "statusKonfirmasi": "Belum", 
      "tamuDitemui": "",
      "ringkasan": "",
      "prospek": "Hot Lead",
      "followUp": "",
    },
    {
      "id": 2,
      "token": "TRX-FO-02",
      "nama": "Siti Aminah",
      "jabatan": "Consultant",
      "kategori": "Reguler",
      "waktu": "14 Agu 2026, 09:30 WIB",
      "tanggal": "2026-08-14", // Terjadwal mendatang
      "jenis": "Konsultasi",
      "keperluan": "Konsultasi sistem POS toko",
      "catatan": "Membawa sampel data produk lama.",
      "statusKonfirmasi": "Belum",
      "tamuDitemui": "",
      "ringkasan": "",
      "prospek": "Warm Lead",
      "followUp": "",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Dialog Konfirmasi Keluar / Logout
  void _konfirmasiLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Konfirmasi Keluar", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        content: const Text("Apakah Anda yakin ingin keluar?", style: TextStyle(fontSize: 11)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Tutup dialog
            child: const Text("Batal", style: TextStyle(fontSize: 10, color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(context); // Tutup dialog konfirmasi

              // REDIRECT KE HOMESCREEN DAN HAPUS SEMUA RIWAYAT HALAMAN SEBELUMNYA
              // Pastikan class HomepageScreen sudah diimport
               Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomepageScreen()),
                (route) => false,
              );
              
              
              // Contoh sementara menggunakan SnackBar jika HomepageScreen belum diimport:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Berhasil keluar sesi."), duration: Duration(seconds: 1)),
              );
            },
            child: const Text("Keluar", style: TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  }

  // Pop-up Lihat Catatan Tamu
  void _showCatatanDialog(BuildContext context, String catatan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.speaker_notes_rounded, size: 18, color: corporateGreen),
            const SizedBox(width: 8),
            const Text("Catatan Tamu", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            catatan.isNotEmpty ? catatan : "Tidak ada catatan khusus untuk tamu ini.",
            style: const TextStyle(fontSize: 12, color: Color(0xFF172033)),
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

  // Pop-up Catat Hasil Pertemuan / Edit Catatan
  void _showCatatHasilDialog(BuildContext context, Map<String, dynamic> item) {
    final ditemuiCtrl = TextEditingController(text: item["tamuDitemui"]);
    final ringkasanCtrl = TextEditingController(text: item["ringkasan"]);
    String prospekSelected = item["prospek"].isNotEmpty ? item["prospek"] : "Warm Lead";
    final followUpCtrl = TextEditingController(text: item["followUp"]);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(item["statusKonfirmasi"] == "Selesai" ? "Edit Catatan Pertemuan" : "Catat Hasil Pertemuan", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _dialogField("Tamu yang Ditemui", ditemuiCtrl),
                const SizedBox(height: 8),
                _dialogField("Catatan / Ringkasan Diskusi", ringkasanCtrl, maxLines: 3),
                const SizedBox(height: 8),
                const Text("Prospek Klien", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF778195))),
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
                      value: prospekSelected,
                      isExpanded: true,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF172033), fontWeight: FontWeight.bold),
                      items: ['Warm Lead', 'Hot Lead', 'Cold Lead', 'Non-Lead'].map((val) {
                        return DropdownMenuItem(value: val, child: Text(val));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => prospekSelected = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                const Text("Tanggal Follow-Up", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF778195))),
                const SizedBox(height: 3),
                TextField(
                  controller: followUpCtrl,
                  readOnly: true,
                  style: const TextStyle(fontSize: 11),
                  decoration: InputDecoration(
                    hintText: "Pilih tanggal follow-up...",
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
                      initialEntryMode: DatePickerEntryMode.calendarOnly,
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: corporateGreen,
                              onPrimary: Colors.white,
                              onSurface: const Color(0xFF172033),
                            ),
                          ),
                          child: MediaQuery(
                            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(0.85)),
                            child: child!,
                          ),
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
                  item["tamuDitemui"] = ditemuiCtrl.text;
                  item["ringkasan"] = ringkasanCtrl.text;
                  item["prospek"] = prospekSelected;
                  item["followUp"] = followUpCtrl.text;
                  item["statusKonfirmasi"] = "Selesai";
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Catatan pertemuan berhasil disimpan!'), backgroundColor: Color(0xFF006B3F)),
                );
              },
              child: const Text("Simpan", style: TextStyle(fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF778195))),
        const SizedBox(height: 3),
        TextField(
          controller: controller,
          maxLines: maxLines,
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
    int totalVip = _daftarTamuFO.where((e) => e['kategori'] == 'VIP').length;
    int totalReguler = _daftarTamuFO.where((e) => e['kategori'] == 'Reguler').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: corporateGreen,
        elevation: 0,
        title: const Text(
          "PIC - Dashboard Tamu",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        // ================= TOMBOL NOTIFIKASI & LOGOUT DI KANAN ATAS =================
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            tooltip: "Notifikasi",
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Tidak ada notifikasi baru."), duration: Duration(milliseconds: 700)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: "Keluar",
            onPressed: () => _konfirmasiLogout(context),
          ),
        ],
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Card Total Tamu VIP & Reguler
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Total Tamu VIP", style: TextStyle(fontSize: 11, color: Colors.amber, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text("$totalVip Orang", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber[900])),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Total Tamu Reguler", style: TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text("$totalReguler Orang", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 2. Card Header: Daftar Tamu Masuk & Kategori Pelanggan
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
                    "Daftar Tamu Masuk & Kategori Pelanggan",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                  ),
                  const SizedBox(height: 10),

                  // 3. Tab Bar Diperkecil Ukurannya
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

            // 5. Konten Data Tamu (Berdasarkan Tab & Filter)
            SizedBox(
              height: 450,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTamuList(_daftarTamuFO, "Semua"),
                  _buildTamuList(_daftarTamuFO.where((e) => e['tanggal'] == '2026-08-13').toList(), "Hari Ini"),
                  _buildTamuList(_daftarTamuFO.where((e) => e['tanggal'] != '2026-08-13').toList(), "Mendatang"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTamuList(List<Map<String, dynamic>> listData, String tabName) {
    List filtered = listData.where((item) {
      if (_filterKategori == 'VIP') return item['kategori'] == 'VIP';
      if (_filterKategori == 'Reguler') return item['kategori'] == 'Reguler';
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text("Tidak ada data tamu untuk tab $tabName.", style: const TextStyle(color: Color(0xFF778195), fontSize: 11)),
      );
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        bool isConfirmed = item["statusKonfirmasi"] != "Belum";
        bool isMeeting = item["statusKonfirmasi"] == "Sedang Bertemu";
        bool isFinished = item["statusKonfirmasi"] == "Selesai";

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
              Text("Waktu: ${item["waktu"]}", style: const TextStyle(fontSize: 10, color: Color(0xFF006B3F), fontWeight: FontWeight.w600)),
              Text("Jenis: ${item["jenis"]} • Keperluan: ${item["keperluan"]}", style: const TextStyle(fontSize: 10, color: Color(0xFF778195)), overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),

              InkWell(
                onTap: () => _showCatatanDialog(context, item["catatan"]),
                child: Row(
                  children: [
                    const Icon(Icons.speaker_notes_rounded, size: 13, color: Colors.blue),
                    const SizedBox(width: 4),
                    const Text("Lihat Catatan Tamu", style: TextStyle(fontSize: 10, color: Colors.blue, decoration: TextDecoration.underline)),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6.0),
                child: Divider(height: 1, color: Color(0xFFE5E7EB)),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text("Konfirmasi: ", style: TextStyle(fontSize: 10, color: Color(0xFF778195))),
                      if (!isConfirmed) ...[
                        InkWell(
                          onTap: () {
                            setState(() {
                              item["statusKonfirmasi"] = "Dikonfirmasi";
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                            child: const Icon(Icons.check, size: 14, color: Colors.green),
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _daftarTamuFO.remove(item);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                            child: const Icon(Icons.close, size: 14, color: Colors.red),
                          ),
                        ),
                      ] else ...[
                        Text(
                          item["statusKonfirmasi"],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isMeeting ? Colors.orange[700] : Colors.green[700],
                          ),
                        ),
                      ],
                    ],
                  ),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isConfirmed ? corporateGreen : Colors.grey[300],
                      foregroundColor: isConfirmed ? Colors.white : Colors.grey[600],
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: const Size(60, 26),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: !isConfirmed
                        ? null
                        : () {
                            if (item["statusKonfirmasi"] == "Dikonfirmasi") {
                              setState(() {
                                item["statusKonfirmasi"] = "Sedang Bertemu";
                              });
                            } else {
                              _showCatatHasilDialog(context, item);
                            }
                          },
                    child: Text(
                      isFinished
                          ? "Edit Catatan"
                          : isMeeting
                              ? "Catat Hasil"
                              : "Mulai Pertemuan",
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
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