import 'package:flutter/material.dart';
import '../../bloc/produk_diminati_bloc.dart';
import '../../model/produk_diminati_model.dart';

class ProdukDiminatiScreen extends StatefulWidget {
  const ProdukDiminatiScreen({Key? key}) : super(key: key);

  @override
  State<ProdukDiminatiScreen> createState() => _ProdukDiminatiScreenState();
}

class _ProdukDiminatiScreenState extends State<ProdukDiminatiScreen> {
  final Color corporateGreen = const Color(0xFF006B3F);

  final List<String> _bulanList = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];
  final List<String> _tahunList = ['2025', '2026', '2027'];

  late int _selectedBulanIndex; // 1-12
  late String _selectedTahun;

  late Future<ProdukDiminatiResponse> _futureData;

  static const List<Color> _palette = [
    Color(0xFF006B3F), Colors.teal, Colors.blue, Colors.orange,
    Colors.purple, Colors.brown, Colors.pink,
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
    _futureData = ProdukDiminatiBloc.fetch(month: _selectedBulanIndex, year: int.parse(_selectedTahun));
  }

  @override
  Widget build(BuildContext context) {
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

              FutureBuilder<ProdukDiminatiResponse>(
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
                  final products = data.products;
                  final total = data.totalPeminatan;

                  if (products.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: const Center(
                        child: Text("Tidak ada data produk untuk periode ini.", style: TextStyle(fontSize: 12, color: Color(0xFF778195))),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ================= DIAGRAM BATANG =================
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
                                    "Grafik Peminatan (${_bulanList[_selectedBulanIndex - 1]} $_selectedTahun)",
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                                  ),
                                ),
                                Text("Total: $total Peminat", style: const TextStyle(fontSize: 9.5, color: Colors.grey, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 14),
                            ...products.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final item = entry.value;
                              final color = _palette[idx % _palette.length];
                              final progressValue = total == 0 ? 0.0 : item.jumlah / total;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(item.nama, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                        Text("${item.jumlah} peminat (${item.persentase}%)", style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.grey)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    LinearProgressIndicator(
                                      value: progressValue,
                                      backgroundColor: Colors.grey.shade100,
                                      color: color,
                                      minHeight: 9,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ],
                                ),
                              );
                            }),
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
                                rows: List.generate(products.length, (index) {
                                  final item = products[index];
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
                                    DataCell(Text(item.nama, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
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