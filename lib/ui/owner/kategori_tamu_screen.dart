import 'package:flutter/material.dart';
import 'dart:math' as math;

class KategoriTamuScreen extends StatefulWidget {
  const KategoriTamuScreen({Key? key}) : super(key: key);

  @override
  State<KategoriTamuScreen> createState() => _KategoriTamuScreenState();
}

class _KategoriTamuScreenState extends State<KategoriTamuScreen> {
  final Color corporateGreen = const Color(0xFF006B3F);

  // State Filter Bulan & Tahun
  String _selectedBulan = 'Agustus';
  String _selectedTahun = '2026';

  final List<String> _bulanList = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  final List<String> _tahunList = ['2025', '2026', '2027'];

  // Data kategori tamu berdasarkan bulan
  Map<String, List<Map<String, dynamic>>> get _dataKategoriPerBulan {
    return {
      'Agustus': [
        {"kategori": "Prospek", "jumlah": 35, "persentase": 35.0, "color": const Color(0xFF006B3F)},
        {"kategori": "Mitra", "jumlah": 25, "persentase": 25.0, "color": Colors.teal},
        {"kategori": "Klien", "jumlah": 15, "persentase": 15.0, "color": Colors.blue},
        {"kategori": "Vendor", "jumlah": 10, "persentase": 10.0, "color": Colors.orange},
        {"kategori": "Pelamar", "jumlah": 10, "persentase": 10.0, "color": Colors.purple},
        {"kategori": "Umum", "jumlah": 5, "persentase": 5.0, "color": Colors.grey},
      ],
      'Juli': [
        {"kategori": "Mitra", "jumlah": 30, "persentase": 33.3, "color": Colors.teal},
        {"kategori": "Prospek", "jumlah": 25, "persentase": 27.8, "color": const Color(0xFF006B3F)},
        {"kategori": "Klien", "jumlah": 15, "persentase": 16.7, "color": Colors.blue},
        {"kategori": "Pelamar", "jumlah": 10, "persentase": 11.1, "color": Colors.purple},
        {"kategori": "Vendor", "jumlah": 5, "persentase": 5.6, "color": Colors.orange},
        {"kategori": "Umum", "jumlah": 5, "persentase": 5.5, "color": Colors.grey},
      ],
      'Default': [
        {"kategori": "Prospek", "jumlah": 20, "persentase": 40.0, "color": const Color(0xFF006B3F)},
        {"kategori": "Mitra", "jumlah": 12, "persentase": 24.0, "color": Colors.teal},
        {"kategori": "Klien", "jumlah": 8, "persentase": 16.0, "color": Colors.blue},
        {"kategori": "Vendor", "jumlah": 5, "persentase": 10.0, "color": Colors.orange},
        {"kategori": "Pelamar", "jumlah": 3, "persentase": 6.0, "color": Colors.purple},
        {"kategori": "Umum", "jumlah": 2, "persentase": 4.0, "color": Colors.grey},
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> currentData = _dataKategoriPerBulan[_selectedBulan] ?? _dataKategoriPerBulan['Default']!;
    int totalTamu = currentData.fold(0, (sum, item) => sum + (item['jumlah'] as int));

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: corporateGreen,
        elevation: 0,
        title: const Text(
          "Dominasi Kategori Tamu",
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

            // ================= DIAGRAM LINGKARAN (PIE / DONUT CHART) =================
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
                      Text("Diagram Lingkaran ($_selectedBulan $_selectedTahun)", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
                      Text("Total: $totalTamu Tamu", style: const TextStyle(fontSize: 9.5, color: Colors.grey, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Custom Paint Pie Chart
                  Center(
                    child: SizedBox(
                      width: 170,
                      height: 170,
                      child: CustomPaint(
                        painter: PieChartPainter(items: currentData, total: totalTamu),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Total", style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                              Text("$totalTamu", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: corporateGreen)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Keterangan Legend Warna
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: currentData.map((item) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 8, height: 8, decoration: BoxDecoration(color: item["color"], shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Text("${item["kategori"]} (${item["persentase"]}%)", style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600)),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ================= TABEL PERINGKAT KATEGORI TAMU =================
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
                  const Text("Tabel Peringkat Kategori Tamu", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
                  const SizedBox(height: 8),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowHeight: 28,
                      dataRowHeight: 38,
                      columnSpacing: 22,
                      columns: const [
                        DataColumn(label: Text('Ranking', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Kategori Tamu', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Jumlah Tamu', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Persentase (%)', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold))),
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
                          DataCell(Text(item['kategori'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                          DataCell(Text("${item['jumlah']} Orang", style: const TextStyle(fontSize: 10))),
                          DataCell(Text("${item['persentase']}%", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: corporateGreen))),
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

// Custom Painter untuk Menggambar Diagram Lingkaran Proporsional
class PieChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> items;
  final int total;

  PieChartPainter({required this.items, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;

    final double strokeWidth = 28.0;
    final Rect rect = Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2, size.width - strokeWidth, size.height - strokeWidth);
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    double startAngle = -math.pi / 2;

    for (var item in items) {
      double sweepAngle = (item['jumlah'] as int) / total * 2 * math.pi;
      paint.color = item['color'] as Color;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}