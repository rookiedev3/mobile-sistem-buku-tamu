import 'package:flutter/material.dart';
import '../master_data/core/shared_widgets.dart';

class LeadTab extends StatefulWidget {
  const LeadTab({Key? key}) : super(key: key);

  @override
  State<LeadTab> createState() => _LeadTabState();
}

class _LeadTabState extends State<LeadTab> {
  final TextEditingController _searchLeadController = TextEditingController();
  final List<Map<String, dynamic>> _daftarLead = [
    {"id": 1, "nama": "Google Search"},
    {"id": 2, "nama": "Media Sosial"},
    {"id": 3, "nama": "Rekomendasi Klien"},
  ];

  @override
  Widget build(BuildContext context) {
    List filtered = _daftarLead.where((item) => item['nama'].toLowerCase().contains(_searchLeadController.text.toLowerCase())).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextField(
                  controller: _searchLeadController,
                  onChanged: (val) => setState(() {}),
                  style: const TextStyle(fontSize: 12),
                  decoration: searchDecoration("Cari lead source..."),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: btnStyle(),
                onPressed: () => _showFormLead(context, null),
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
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    title: Text(item["nama"], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        actionBtn("Edit", Colors.blue, Icons.edit, () => _showFormLead(context, item)),
                        const SizedBox(width: 6),
                        actionBtn("Hapus", Colors.red, Icons.delete, () => setState(() => _daftarLead.remove(item))),
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

  void _showFormLead(BuildContext context, Map<String, dynamic>? lead) {
    final namaCtrl = TextEditingController(text: lead?["nama"] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        title: Text(lead == null ? "Tambah Lead Source" : "Edit Lead Source", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              dialogField("Nama Sumber Lead", namaCtrl),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(fontSize: 11, color: Color(0xFF778195))),
          ),
          ElevatedButton(
            style: btnStyle(),
            onPressed: () {
              if (namaCtrl.text.isNotEmpty) {
                setState(() {
                  if (lead == null) {
                    _daftarLead.add({"id": _daftarLead.length + 1, "nama": namaCtrl.text});
                  } else {
                    lead["nama"] = namaCtrl.text;
                  }
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Simpan", style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}