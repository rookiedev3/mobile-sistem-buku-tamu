import 'package:flutter/material.dart';
import 'dashboard_manager.dart';
import 'pipeline_screen.dart';
import 'daftar_kunjungan_manager_screen.dart';

class LaporanManagerScreen extends StatefulWidget {
  const LaporanManagerScreen({Key? key}) : super(key: key);

  @override
  State<LaporanManagerScreen> createState() => _LaporanManagerScreenState();
}

class _LaporanManagerScreenState extends State<LaporanManagerScreen> {
  // Indeks 3 untuk menu Laporan pada Bottom Navigation Bar
  int _currentIndex = 3;

  // State Filter Periode Laporan
  String _selectedPeriode = 'Bulan Ini (Agustus 2026)';
  final List<String> _periodeOptions = [
    'Hari Ini',
    'Minggu Ini',
    'Bulan Ini (Agustus 2026)',
    'Tahun Ini'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF006B3F),
        elevation: 0,
        title: const Text(
          "Laporan & Analitik Performa",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===================================================
            // BAGIAN 1: FILTER PERIODE LAPORAN
            // ===================================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.date_range_rounded, size: 18, color: Color(0xFF006B3F)),
                      const SizedBox(width: 8),
                      const Text(
                        "Periode:",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF778195)),
                      ),
                    ],
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedPeriode,
                      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF006B3F)),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                      items: _periodeOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedPeriode = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ===================================================
            // BAGIAN 2: RINGKASAN KARTU METRIK EKSEKUTIF
            // ===================================================
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    title: "Total Kunjungan",
                    value: "142",
                    subtext: "+18% dari bln lalu",
                    icon: Icons.people_alt_rounded,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    title: "Konversi Deal",
                    value: "34",
                    subtext: "24% conversion rate",
                    icon: Icons.task_alt_rounded,
                    color: const Color(0xFF006B3F),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Total Potensi Nilai Bisnis (Pipeline Value)", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF778195))),
                      SizedBox(height: 6),
                      Text("Rp 1.450.000.000", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF006B3F).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF006B3F), size: 24),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ===================================================
            // BAGIAN 3: ANALISIS BERDASARKAN KATEGORI & PRODUK
            // ===================================================
            const Text(
              "Distribusi Kategori Tamu",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildProgressBarItem(label: "Tamu VIP (Enterprise/Partner)", percentage: 0.65, count: "92 Kunjungan", color: Colors.amber[800]!),
                  const SizedBox(height: 14),
                  _buildProgressBarItem(label: "Tamu Reguler (Vendor/Umum)", percentage: 0.35, count: "50 Kunjungan", color: Colors.blue),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ===================================================
            // BAGIAN 4: KINERJA PIC / SALES TERBAIK
            // ===================================================
            const Text(
              "Performa PIC / Sales",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
            ),
            const SizedBox(height: 10),

            _buildPicPerformanceCard(name: "Rian (Sales Utama)", totalDeal: "14 Deal", value: "Rp 650.000.000", rank: "1"),
            _buildPicPerformanceCard(name: "Siska (Sales Senior)", totalDeal: "11 Deal", value: "Rp 420.000.000", rank: "2"),
            _buildPicPerformanceCard(name: "Ahmad (Sales Eksekutif)", totalDeal: "9 Deal", value: "Rp 380.000.000", rank: "3"),
            
            const SizedBox(height: 20),
          ],
        ),
      ),

      // ===================================================
      // BAGIAN 5: NAVBAR BAWAH
      // ===================================================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF006B3F),
        unselectedItemColor: const Color(0xFF778195),
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardManager()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PipelineScreen()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DaftarKunjunganManagerScreen()),
            );
          } else if (index == 3) {
            // Sudah di halaman Laporan
          } else if (index == 4) {
            // Indeks 4 untuk Eksport (bisa diarahkan ke menu eksport atau menampilkan dialog)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Mengarahkan ke menu Eksport Laporan...')),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.timeline_rounded), label: 'Pipeline'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'Kunjungan'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_rounded), label: 'Laporan'),
          BottomNavigationBarItem(icon: Icon(Icons.download_rounded), label: 'Eksport'),
        ],
      ),
    );
  }

  // Widget Kartu Ringkasan Atas
  Widget _buildSummaryCard({required String title, required String value, required String subtext, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
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
              Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF778195), fontWeight: FontWeight.w600)),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(subtext, style: const TextStyle(fontSize: 10, color: Color(0xFF778195))),
        ],
      ),
    );
  }

  // Widget Indikator Progress Bar Distribusi Tamu
  Widget _buildProgressBarItem({required String label, required double percentage, required String count, required Color color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF172033))),
            Text(count, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF778195))),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: const Color(0xFFF4F7FC),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  // Widget Kinerja PIC / Sales
  Widget _buildPicPerformanceCard({required String name, required String totalDeal, required String value, required String rank}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xFF006B3F).withOpacity(0.1),
                child: Text(rank, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF006B3F))),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF172033))),
                  const SizedBox(height: 2),
                  Text("Pencapaian: $totalDeal", style: const TextStyle(fontSize: 11, color: Color(0xFF778195))),
                ],
              ),
            ],
          ),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF006B3F))),
        ],
      ),
    );
  }
}