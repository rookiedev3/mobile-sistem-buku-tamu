import 'package:flutter/material.dart';
import '../master_data/core/shared_widgets.dart';

class BranchTab extends StatefulWidget {
  const BranchTab({Key? key}) : super(key: key);

  @override
  State<BranchTab> createState() => _BranchTabState();
}

class _BranchTabState extends State<BranchTab> {
  final TextEditingController _searchBranchController = TextEditingController();
  final List<Map<String, dynamic>> _daftarBranch = [
    {"id": 1, "kode": "SLM", "nama": "Cabang Sleman", "alamat": "Jl. Ringroad Utara, Sleman", "telepon": "0274-123456", "status": "Aktif"},
    {"id": 2, "kode": "MGL", "nama": "Cabang Magelang", "alamat": "Jl. Pemuda No. 15, Magelang", "telepon": "0293-654321", "status": "Aktif"},
  ];

  @override
  Widget build(BuildContext context) {
    List filtered = _daftarBranch.where((item) => 
        item['nama'].toLowerCase().contains(_searchBranchController.text.toLowerCase()) || 
        item['kode'].toLowerCase().contains(_searchBranchController.text.toLowerCase())).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextField(
                  controller: _searchBranchController,
                  onChanged: (val) => setState(() {}),
                  style: const TextStyle(fontSize: 12),
                  decoration: searchDecoration("Cari branch..."),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: btnStyle(),
                onPressed: () => _showFormBranch(context, null),
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
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Kode: ${item["kode"]}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: corporateGreen)),
                            Text(item["status"], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isActive ? Colors.green : Colors.red)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(item["nama"], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        Text("Alamat: ${item["alamat"]} | Telp: ${item["telepon"]}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        const Divider(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            actionBtn("Edit", Colors.blue, Icons.edit, () => _showFormBranch(context, item)),
                            const SizedBox(width: 6),
                            actionBtn("Hapus", Colors.red, Icons.delete, () => setState(() => _daftarBranch.remove(item))),
                          ],
                        ),
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

  void _showFormBranch(BuildContext context, Map<String, dynamic>? branch) {
    final kodeCtrl = TextEditingController(text: branch?["kode"] ?? '');
    final namaCtrl = TextEditingController(text: branch?["nama"] ?? '');
    final alamatCtrl = TextEditingController(text: branch?["alamat"] ?? '');
    final telpCtrl = TextEditingController(text: branch?["telepon"] ?? '');
    bool aktif = branch?["status"] == "Aktif" ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(branch == null ? "Tambah Branch" : "Edit Branch", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                dialogField("Kode Branch", kodeCtrl),
                const SizedBox(height: 6),
                dialogField("Nama Branch", namaCtrl),
                const SizedBox(height: 6),
                dialogField("Alamat", alamatCtrl),
                const SizedBox(height: 6),
                dialogField("No. Telepon", telpCtrl, keyboardType: TextInputType.phone),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(value: aktif, activeColor: corporateGreen, onChanged: (v) => setDialogState(() => aktif = v ?? true)),
                    const Text("Aktif", style: TextStyle(fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal", style: TextStyle(fontSize: 11))),
            ElevatedButton(
              style: btnStyle(),
              onPressed: () {
                setState(() {
                  if (branch == null) {
                    _daftarBranch.add({"id": _daftarBranch.length + 1, "kode": kodeCtrl.text, "nama": namaCtrl.text, "alamat": alamatCtrl.text, "telepon": telpCtrl.text, "status": aktif ? "Aktif" : "Non-Aktif"});
                  } else {
                    branch["kode"] = kodeCtrl.text;
                    branch["nama"] = namaCtrl.text;
                    branch["alamat"] = alamatCtrl.text;
                    branch["telepon"] = telpCtrl.text;
                    branch["status"] = aktif ? "Aktif" : "Non-Aktif";
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