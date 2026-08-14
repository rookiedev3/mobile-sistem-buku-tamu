import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../bloc/kategori_tamu_bloc.dart';
import '../../model/kategori_tamu_model.dart';

class KategoriTamuScreen extends StatefulWidget {
  const KategoriTamuScreen({Key? key}) : super(key: key);

  @override
  State<KategoriTamuScreen> createState() => _KategoriTamuScreenState();
}

class _KategoriTamuScreenState extends State<KategoriTamuScreen> {
  final Color corporateGreen = const Color(0xFF006B3F);

  final List<String> _bulanList = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];
  final List<String> _tahunList = ['2025', '2026', '2027'];

  late int _selectedBulanIndex;
  late String _selectedTahun;

  late Future<KategoriTamuResponse> _futureData;

  static const List<Color> _palette = [
    Color(0xFF006B3F), Colors.teal, Colors.blue, Colors.orange,
    Colors.purple, Colors.grey, Colors.brown, Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedBulanIndex = now.month;
    _selectedTahun = now.year.toString();
    _loadData();
  }

  void _loadData() {
    _futureData = KategoriTamuBloc.fetch(month: _selectedBulanIndex, year: int.parse(_selectedTahun));
  }

  @override
  Widget build(BuildContext context) {
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
      body: RefreshIndicator(
        onRefresh: () async {
          setState(_loadData);
          await _futureData;
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFE2E8F0))),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _selectedBulanIndex,
                            isDense: true,
                            isExpanded: true,
                            style: const TextStyle(fontSize: 10, color: Color(0xFF172033)),
                            items: List.generate(12, (i) => i + 1)
                                .map((m) => DropdownMenuItem(value: m, child: Text(_bulanList[m - 1])))
                                .toList(),
                            onChanged: (val) => setState(() { _selectedBulanIndex = val!; _loadData(); }),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
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
                          onChanged: (val) => setState(() { _selectedTahun = val!; _loadData(); }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              FutureBuilder<KategoriTamuResponse>(
                future: _futureData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          Text('${snapshot.error}', style: const TextStyle(fontSize: 11, color: Colors.red), textAlign: TextAlign.center),
                          const SizedBox(height: 8),
                          TextButton(onPressed: () => setState(_loadData), child: const Text("Coba Lagi")),
                        ],
                      ),
                    );
                  }

                  final data = snapshot.data!;
                  final categories = data.categories;
                  final total = data.totalTamu;

                  if (categories.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: const Center(
                        child: Text("Tidak ada data kategori untuk periode ini.", style: TextStyle(fontSize: 12, color: Color(0xFF778195))),
                      ),
                    );
                  }

                  // Beri warna per kategori dari palette
                  final coloredData = categories.asMap().entries.map((e) {
                    return {
                      'kategori': e.value.kategori,
                      'jumlah': e.value.jumlah,
                      'persentase': e.value.persentase,
                      'color': _palette[e.key % _palette.length],
                    };
                  }).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ================= PIE CHART =================
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
                                Expanded(
                                  child: Text(
                                    "Diagram Lingkaran (${_bulanList[_selectedBulanIndex - 1]} $_selectedTahun)",
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                                  ),
                                ),
                                Text("Total: $total Tamu", style: const TextStyle(fontSize: 9.5, color: Colors.grey, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 16),

                            Center(
                              child: SizedBox(
                                width: 170,
                                height: 170,
                                child: CustomPaint(
                                  painter: PieChartPainter(items: coloredData, total: total),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text("Total", style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                                        Text("$total", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: corporateGreen)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            Wrap(
                              spacing: 12,
                              runSpacing: 6,
                              alignment: WrapAlignment.center,
                              children: coloredData.map((item) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(width: 8, height: 8, decoration: BoxDecoration(color: item["color"] as Color, shape: BoxShape.circle)),
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

                      // ================= TABEL PERINGKAT =================
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
                                rows: List.generate(categories.length, (index) {
                                  final item = categories[index];
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
                                    DataCell(Text(item.kategori, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                                    DataCell(Text("${item.jumlah} Orang", style: const TextStyle(fontSize: 10))),
                                    DataCell(Text("${item.persentase}%", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: corporateGreen))),
                                  ]);
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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