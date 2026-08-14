import 'package:flutter/material.dart';

class ProdukDiminatiScreen extends StatefulWidget {
  const ProdukDiminatiScreen({Key? key}) : super(key: key);

  @override
  State<ProdukDiminatiScreen> createState() => _ProdukDiminatiScreenState();
}

class _ProdukDiminatiScreenState extends State<ProdukDiminatiScreen> {
  final Color corporateGreen = const Color(0xFF006B3F);

  // State Filter Bulan & Tahun
  String _selectedBulan = 'Agustus';
  String _selectedTahun = '2026';

  final List<String> _bulanList = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  final List<String> _tahunList = ['2025', '2026', '2027'];

  // Simulasi data produk yang berubah-ubah berdasarkan filter bulan
  Map<String, List<Map<String, dynamic>>> get _dataPerBulan {
    return {
      'Agustus': [
        {"nama": "Software POS", "jumlah": 45, "persentase": "45.0%", "color": corporateGreen},
        {"nama": "ERP System", "jumlah": 30, "persentase": "30.0%", "color": Colors.teal},
        {"nama": "HRIS Mobile", "jumlah": 15, "persentase": "15.0%", "color": Colors.blue},
        {"nama": "Cloud Server", "jumlah": 10, "persentase": "10.0%", "color": Colors.orange},
      ],
      'Juli': [
        {"nama": "ERP System", "jumlah": 50, "persentase": "41.7%", "color": Colors.teal},
        {"nama": "Software POS", "jumlah": 40, "persentase": "33.3%", "color": corporateGreen},
        {"nama": "Cloud Server", "jumlah": 20, "persentase": "16.7%", "color": Colors.orange},
        {"nama": "HRIS Mobile", "jumlah": 10, "persentase": "8.3%", "color": Colors.blue},
      ],
      // Default jika bulan lain
      'Default': [
        {"nama": "Software POS", "jumlah": 25, "persentase": "40.0%", "color": corporateGreen},
        {"nama": "ERP System", "jumlah": 20, "persentase": "32.0%", "color": Colors.teal},
        {"nama": "HRIS Mobile", "jumlah": 12, "persentase": "19.2%", "color": Colors.blue},
        {"nama": "Cloud Server", "jumlah": 5, "persentase": "8.8%", "color": Colors.orange},
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data berdasarkan filter bulan yang dipilih (jika tidak ada pakai Default)
    List<Map<String, dynamic>> currentData = _dataPerBulan[_selectedBulan] ?? _dataPerBulan['Default']!;
    
    // Hitung total peminatan untuk validasi proporsi diagram
    int totalPeminatan = currentData.fold(0, (sum, item) => sum + (item['jumlah'] as int));

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: corporateGreen,
        elevation: 0,
        title: const Text(
          "Statistik Produk Sering Diminati",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= FILTER BULAN & TAHUN =================
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Row(
                children: [
                  const Icon(Icons.filter_alt_rounded, size: 16, color: Color(0xFF006B3F)),
                  const SizedBox(width: 8),
                  const Text("Filter Periode:", style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),

                  // Dropdown Bulan
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFE2E8F0))),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedBulan,
                          isDense: true,
                          style: const TextStyle(fontSize: 10, color: Color(0xFF172033)),
                          items: _bulanList.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                          onChanged: (val) => setState(() => _selectedBulan = val!),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Dropdown Tahun
                  Container(
                    width: 75,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedTahun,
                        isDense: true,
                        style: const TextStyle(fontSize: 10, color: Color(0xFF172033)),
                        items: _tahunList.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                        onChanged: (val) => setState(() => _selectedTahun = val!),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ================= BAGIAN DIAGRAM BATANG =================
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Grafik Peminatan ($_selectedBulan $_selectedTahun)", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
                      Text("Total: $totalPeminatan Peminat", style: const TextStyle(fontSize: 9.5, color: Colors.grey, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Render Diagram Batang
                  ...currentData.map((item) {
                    double progressValue = (item["jumlah"] as int) / (totalPeminatan == 0 ? 1 : totalPeminatan);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(item["nama"], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              Text("${item["jumlah"]} peminat (${item["persentase"]})", style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: progressValue,
                            backgroundColor: Colors.grey.shade100,
                            color: item["color"],
                            minHeight: 9,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ================= TABEL PERINGKAT PRODUK =================
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
                  const Text("Tabel Peringkat Peminatan Produk", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
                  const SizedBox(height: 8),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowHeight: 28,
                      dataRowHeight: 38,
                      columnSpacing: 25,
                      columns: const [
                        DataColumn(label: Text('Peringkat', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Nama Produk', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Jumlah Peminatan', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Persentase', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                      ],
                      rows: List.generate(currentData.length, (index) {
                        final item = currentData[index];
                        return DataRow(cells: [
                          DataCell(Row(
                            children: [
                              Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(color: corporateGreen.withOpacity(0.1), shape: BoxShape.circle),
                                child: Center(child: Text("${index + 1}", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: corporateGreen))),
                              ),
                            ],
                          )),
                          DataCell(Text(item['nama'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                          DataCell(Text("${item['jumlah']} Orang", style: const TextStyle(fontSize: 10))),
                          DataCell(Text(item['persentase'], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: corporateGreen))),
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