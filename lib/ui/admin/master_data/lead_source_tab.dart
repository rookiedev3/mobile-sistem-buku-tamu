// lib/ui/lead_source_tab.dart
import 'package:flutter/material.dart';
import 'package:mobile_flutter/bloc/lead_source_bloc.dart';
import 'package:mobile_flutter/model/lead_source.dart';
import '../master_data/core/shared_widgets.dart';

class LeadSourceTab extends StatefulWidget {
  const LeadSourceTab({Key? key}) : super(key: key);

  @override
  State<LeadSourceTab> createState() => _LeadSourceTabState();
}

class _LeadSourceTabState extends State<LeadSourceTab> {
  final TextEditingController _searchController = TextEditingController();
  List<LeadSource> _daftar = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final result = await LeadSourceBloc.daftarLeadSource();
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
    List<LeadSource> filtered = _daftar
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
                  decoration: searchDecoration("Cari lead source..."),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: btnStyle(),
                onPressed: () => _showFormLeadSource(context, null),
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
                    ? const Center(child: Text("Belum ada data lead source", style: TextStyle(fontSize: 12)))
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
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    actionBtn("Edit", Colors.blue, Icons.edit, () => _showFormLeadSource(context, item)),
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

  void _confirmDelete(LeadSource item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Lead Source?", style: TextStyle(fontSize: 14)),
        content: Text("Yakin ingin menghapus ${item.name}?", style: const TextStyle(fontSize: 12)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await LeadSourceBloc.hapusLeadSource(item.id);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lead source berhasil dihapus')));
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

  void _showFormLeadSource(BuildContext context, LeadSource? item) {
    final namaCtrl = TextEditingController(text: item?.name ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(item == null ? "Tambah Lead Source" : "Edit Lead Source", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        content: dialogField("Nama Lead Source", namaCtrl),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Batal", style: TextStyle(fontSize: 11))),
          ElevatedButton(
            style: btnStyle(),
            onPressed: () async {
              try {
                if (item == null) {
                  await LeadSourceBloc.tambahLeadSource(namaCtrl.text);
                } else {
                  await LeadSourceBloc.updateLeadSource(item.id, namaCtrl.text);
                }
                Navigator.pop(dialogContext);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(item == null ? 'Lead source berhasil ditambahkan' : 'Lead source berhasil diperbarui')));
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
    );
  }
}