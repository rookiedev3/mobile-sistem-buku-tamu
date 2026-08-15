// lib/ui/guest_category_tab.dart
import 'package:flutter/material.dart';
import 'package:mobile_flutter/bloc/guest_category_bloc.dart';
import 'package:mobile_flutter/model/guest_category.dart';
import '../master_data/core/shared_widgets.dart';

const List<String> _pilihanWarna = [
  '#013220', '#1463ff', '#ca8a04', '#7c3aed', '#0284c7', '#c2410c', '#21a86b', '#dc2626',
];

Color _hexToColor(String hex) {
  final h = hex.replaceAll('#', '');
  return Color(int.parse('FF$h', radix: 16));
}

class GuestCategoryTab extends StatefulWidget {
  const GuestCategoryTab({Key? key}) : super(key: key);

  @override
  State<GuestCategoryTab> createState() => _GuestCategoryTabState();
}

class _GuestCategoryTabState extends State<GuestCategoryTab> {
  final TextEditingController _searchController = TextEditingController();
  List<GuestCategory> _daftar = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final result = await GuestCategoryBloc.daftarGuestCategory();
      setState(() => _daftar = result.data ?? []);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: ${e.toString().replaceAll('Exception: ', '')}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<GuestCategory> filtered = _daftar
        .where((item) => item.name.toLowerCase().contains(_searchController.text.toLowerCase()))
        .toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() {}),
                  style: const TextStyle(fontSize: 12),
                  decoration: searchDecoration("Cari guest category..."),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: btnStyle(),
                onPressed: () => _showFormGuestCategory(context, null),
                icon: const Icon(Icons.add, size: 14),
                label: const Text("Tambah", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? const Center(child: Text("Belum ada data guest category", style: TextStyle(fontSize: 12)))
                    : RefreshIndicator(
                        onRefresh: _fetchData,
                        child: ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            return Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              child: ListTile(
                                leading: CircleAvatar(radius: 12, backgroundColor: _hexToColor(item.color)),
                                title: Text(item.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    actionBtn("Edit", Colors.blue, Icons.edit, () => _showFormGuestCategory(context, item)),
                                    const SizedBox(width: 6),
                                    actionBtn("Hapus", Colors.red, Icons.delete, () => _confirmDelete(item)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(GuestCategory item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Guest Category?", style: TextStyle(fontSize: 14)),
        content: Text("Yakin ingin menghapus ${item.name}?", style: const TextStyle(fontSize: 12)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await GuestCategoryBloc.hapusGuestCategory(item.id);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Guest category berhasil dihapus')));
                _fetchData();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showFormGuestCategory(BuildContext context, GuestCategory? item) {
    final namaCtrl = TextEditingController(text: item?.name ?? '');
    String warnaTerpilih = item?.color ?? _pilihanWarna.first;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(item == null ? "Tambah Guest Category" : "Edit Guest Category", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                dialogField("Nama Kategori", namaCtrl),
                const SizedBox(height: 10),
                const Align(alignment: Alignment.centerLeft, child: Text("Warna", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _pilihanWarna.map((hex) {
                    final selected = hex == warnaTerpilih;
                    return GestureDetector(
                      onTap: () => setDialogState(() => warnaTerpilih = hex),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _hexToColor(hex),
                          shape: BoxShape.circle,
                          border: selected ? Border.all(color: Colors.black, width: 2) : null,
                        ),
                        child: selected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Batal", style: TextStyle(fontSize: 11))),
            ElevatedButton(
              style: btnStyle(),
              onPressed: () async {
                try {
                  if (item == null) {
                    await GuestCategoryBloc.tambahGuestCategory(namaCtrl.text, warnaTerpilih);
                  } else {
                    await GuestCategoryBloc.updateGuestCategory(item.id, namaCtrl.text, warnaTerpilih);
                  }
                  Navigator.pop(dialogContext);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(item == null ? 'Guest category berhasil ditambahkan' : 'Guest category berhasil diperbarui')));
                  _fetchData();
                } catch (e) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text("Simpan", style: TextStyle(fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }
}