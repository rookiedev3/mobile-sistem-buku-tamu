import 'package:flutter/material.dart';
import '../master_data/core/shared_widgets.dart';

class ProductTab extends StatefulWidget {
  const ProductTab({Key? key}) : super(key: key);

  @override
  State<ProductTab> createState() => _ProductTabState();
}

class _ProductTabState extends State<ProductTab> {
  final TextEditingController _searchProductController = TextEditingController();
  final List<Map<String, dynamic>> _daftarProduct = [
    {"id": 1, "kode": "PRD-01", "nama": "Software POS", "kategori": "Aplikasi", "status": "Aktif"},
    {"id": 2, "kode": "PRD-02", "nama": "Sistem Buku Tamu", "kategori": "SaaS", "status": "Aktif"},
  ];

  @override
  Widget build(BuildContext context) {
    List filtered = _daftarProduct.where((item) => 
        item['nama'].toLowerCase().contains(_searchProductController.text.toLowerCase()) || 
        item['kode'].toLowerCase().contains(_searchProductController.text.toLowerCase())).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextField(
                  controller: _searchProductController,
                  onChanged: (val) => setState(() {}),
                  style: const TextStyle(fontSize: 12),
                  decoration: searchDecoration("Cari produk..."),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: btnStyle(),
                onPressed: () => _showFormProduct(context, null),
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
                            Text(item["kode"], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: corporateGreen)),
                            Text(item["status"], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isActive ? Colors.green : Colors.red)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(item["nama"], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        Text("Kategori: ${item["kategori"]}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        const Divider(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            actionBtn("Edit", Colors.blue, Icons.edit, () => _showFormProduct(context, item)),
                            const SizedBox(width: 6),
                            actionBtn("Hapus", Colors.red, Icons.delete, () => setState(() => _daftarProduct.remove(item))),
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

  void _showFormProduct(BuildContext context, Map<String, dynamic>? product) {
    final kodeCtrl = TextEditingController(text: product?["kode"] ?? '');
    final namaCtrl = TextEditingController(text: product?["nama"] ?? '');
    final kategoriCtrl = TextEditingController(text: product?["kategori"] ?? '');
    bool aktif = product?["status"] == "Aktif" ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(product == null ? "Tambah Produk" : "Edit Produk", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              dialogField("Kode Produk", kodeCtrl),
              const SizedBox(height: 6),
              dialogField("Nama Produk", namaCtrl),
              const SizedBox(height: 6),
              dialogField("Kategori", kategoriCtrl),
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
                  if (product == null) {
                    _daftarProduct.add({"id": _daftarProduct.length + 1, "kode": kodeCtrl.text, "nama": namaCtrl.text, "kategori": kategoriCtrl.text, "status": aktif ? "Aktif" : "Non-Aktif"});
                  } else {
                    product["kode"] = kodeCtrl.text;
                    product["nama"] = namaCtrl.text;
                    product["kategori"] = kategoriCtrl.text;
                    product["status"] = aktif ? "Aktif" : "Non-Aktif";
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