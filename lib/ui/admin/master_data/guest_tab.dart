import 'package:flutter/material.dart';
import '../master_data/core/shared_widgets.dart';

class GuestTab extends StatefulWidget {
  const GuestTab({Key? key}) : super(key: key);

  @override
  State<GuestTab> createState() => _GuestTabState();
}

class _GuestTabState extends State<GuestTab> {
  final TextEditingController _searchGuestController = TextEditingController();
  final List<Map<String, dynamic>> _daftarGuestCat = [
    {"id": 1, "nama": "Vendor", "warna": "Merah"},
    {"id": 2, "nama": "Mitra", "warna": "Hijau"},
    {"id": 3, "nama": "VIP", "warna": "Kuning"},
  ];

  @override
  Widget build(BuildContext context) {
    List filtered = _daftarGuestCat.where((item) => item['nama'].toLowerCase().contains(_searchGuestController.text.toLowerCase())).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextField(
                  controller: _searchGuestController,
                  onChanged: (val) => setState(() {}),
                  style: const TextStyle(fontSize: 12),
                  decoration: searchDecoration("Cari kategori tamu..."),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: btnStyle(),
                onPressed: () => _showFormGuestCat(context, null),
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
                    subtitle: Text("Warna: ${item["warna"]}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        actionBtn("Edit", Colors.blue, Icons.edit, () => _showFormGuestCat(context, item)),
                        const SizedBox(width: 6),
                        actionBtn("Hapus", Colors.red, Icons.delete, () => setState(() => _daftarGuestCat.remove(item))),
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

  void _showFormGuestCat(BuildContext context, Map<String, dynamic>? guestCat) {
    final namaCtrl = TextEditingController(text: guestCat?["nama"] ?? '');
    final warnaCtrl = TextEditingController(text: guestCat?["warna"] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(guestCat == null ? "Tambah Guest Category" : "Edit Guest Category", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            dialogField("Nama Kategori", namaCtrl),
            const SizedBox(height: 6),
            dialogField("Warna Badge", warnaCtrl),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal", style: TextStyle(fontSize: 11))),
          ElevatedButton(
            style: btnStyle(),
            onPressed: () {
              setState(() {
                if (guestCat == null) {
                  _daftarGuestCat.add({"id": _daftarGuestCat.length + 1, "nama": namaCtrl.text, "warna": warnaCtrl.text});
                } else {
                  guestCat["nama"] = namaCtrl.text;
                  guestCat["warna"] = warnaCtrl.text;
                }
              });
              Navigator.pop(context);
            },
            child: const Text("Simpan", style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }
}