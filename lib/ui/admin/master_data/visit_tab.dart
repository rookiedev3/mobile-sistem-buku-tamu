import 'package:flutter/material.dart';
import '../master_data/core/shared_widgets.dart';

class VisitTab extends StatefulWidget {
  const VisitTab({Key? key}) : super(key: key);

  @override
  State<VisitTab> createState() => _VisitTabState();
}

class _VisitTabState extends State<VisitTab> {
  final TextEditingController _searchVisitController = TextEditingController();
  final List<Map<String, dynamic>> _daftarVisit = [
    {"id": 1, "nama": "Meeting Bisnis", "status": "Aktif"},
    {"id": 2, "nama": "Konsultasi", "status": "Aktif"},
    {"id": 3, "nama": "Interview", "status": "Aktif"},
  ];

  @override
  Widget build(BuildContext context) {
    List filtered = _daftarVisit.where((item) => item['nama'].toLowerCase().contains(_searchVisitController.text.toLowerCase())).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextField(
                  controller: _searchVisitController,
                  onChanged: (val) => setState(() {}),
                  style: const TextStyle(fontSize: 12),
                  decoration: searchDecoration("Cari tujuan kunjungan..."),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: btnStyle(),
                onPressed: () => _showFormVisit(context, null),
                icon: const Icon(Icons.add, size: 14),
                label: const Text("Tambah", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];
                bool isActive = item["status"] == "Aktif";
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    title: Text(item["nama"], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    subtitle: Text(item["status"], style: TextStyle(fontSize: 10, color: isActive ? Colors.green : Colors.red)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        actionBtn("Edit", Colors.blue, Icons.edit, () => _showFormVisit(context, item)),
                        const SizedBox(width: 6),
                        actionBtn("Hapus", Colors.red, Icons.delete, () => setState(() => _daftarVisit.remove(item))),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFormVisit(BuildContext context, Map<String, dynamic>? visit) {
    final namaCtrl = TextEditingController(text: visit?["nama"] ?? '');
    bool aktif = visit?["status"] == "Aktif" ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(visit == null ? "Tambah Visit Purpose" : "Edit Visit Purpose", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              dialogField("Nama Tujuan", namaCtrl),
              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(value: aktif, activeColor: corporateGreen, onChanged: (v) => setDialogState(() => aktif = v ?? true)),
                  const Text("Aktif", style: TextStyle(fontSize: 11)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal", style: TextStyle(fontSize: 11))),
            ElevatedButton(
              style: btnStyle(),
              onPressed: () {
                setState(() {
                  if (visit == null) {
                    _daftarVisit.add({"id": _daftarVisit.length + 1, "nama": namaCtrl.text, "status": aktif ? "Aktif" : "Non-Aktif"});
                  } else {
                    visit["nama"] = namaCtrl.text;
                    visit["status"] = aktif ? "Aktif" : "Non-Aktif";
                  }
                });
                Navigator.pop(context);
              },
              child: const Text("Simpan", style: TextStyle(fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }
}