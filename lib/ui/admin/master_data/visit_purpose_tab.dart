// lib/ui/visit_purpose_tab.dart
import 'package:flutter/material.dart';
import 'package:mobile_flutter/bloc/visit_purpose_bloc.dart';
import 'package:mobile_flutter/model/visit_purpose.dart';
import '../master_data/core/shared_widgets.dart';

class VisitPurposeTab extends StatefulWidget {
  const VisitPurposeTab({Key? key}) : super(key: key);

  @override
  State<VisitPurposeTab> createState() => _VisitPurposeTabState();
}

class _VisitPurposeTabState extends State<VisitPurposeTab> {
  final TextEditingController _searchController = TextEditingController();
  List<VisitPurpose> _daftar = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final result = await VisitPurposeBloc.daftarVisitPurpose();
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
    List<VisitPurpose> filtered = _daftar
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
                  decoration: searchDecoration("Cari visit purpose..."),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: btnStyle(),
                onPressed: () => _showFormVisitPurpose(context, null),
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
                    ? const Center(child: Text("Belum ada data visit purpose", style: TextStyle(fontSize: 12)))
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
                                title: Text(item.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                  item.isActive ? "Aktif" : "Non-Aktif",
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: item.isActive ? Colors.green : Colors.red),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    actionBtn("Edit", Colors.blue, Icons.edit, () => _showFormVisitPurpose(context, item)),
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

  void _confirmDelete(VisitPurpose item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Visit Purpose?", style: TextStyle(fontSize: 14)),
        content: Text("Yakin ingin menghapus ${item.name}?", style: const TextStyle(fontSize: 12)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await VisitPurposeBloc.hapusVisitPurpose(item.id);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Visit purpose berhasil dihapus')));
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

  // TAMBAHAN: validasi client-side sebelum request dikirim ke API,
  // supaya pesan error Laravel default ("The name field is required.")
  // tidak sampai tampil mentah dalam bahasa Inggris di SnackBar.
  String? _validateFormVisitPurpose(String nama) {
    if (nama.trim().isEmpty) return 'Nama visit purpose wajib diisi';
    return null;
  }

  void _showFormVisitPurpose(BuildContext context, VisitPurpose? item) {
    final namaCtrl = TextEditingController(text: item?.name ?? '');
    bool aktif = item?.isActive ?? true;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(item == null ? "Tambah Visit Purpose" : "Edit Visit Purpose", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              dialogField("Nama Visit Purpose", namaCtrl),
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
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Batal", style: TextStyle(fontSize: 11))),
            ElevatedButton(
              style: btnStyle(),
              onPressed: () async {
                // TAMBAHAN: cek validasi dulu sebelum panggil API
                final errorMsg = _validateFormVisitPurpose(namaCtrl.text);
                if (errorMsg != null) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
                  );
                  return;
                }

                try {
                  if (item == null) {
                    await VisitPurposeBloc.tambahVisitPurpose(namaCtrl.text, aktif);
                  } else {
                    await VisitPurposeBloc.updateVisitPurpose(item.id, namaCtrl.text, aktif);
                  }
                  Navigator.pop(dialogContext);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(item == null ? 'Visit purpose berhasil ditambahkan' : 'Visit purpose berhasil diperbarui')));
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