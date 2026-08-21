// lib/ui/branch_tab.dart
import 'package:flutter/material.dart';
import 'package:mobile_flutter/bloc/branch_bloc.dart';
import 'package:mobile_flutter/model/branch.dart';
import '../master_data/core/shared_widgets.dart';

class BranchTab extends StatefulWidget {
  const BranchTab({Key? key}) : super(key: key);

  @override
  State<BranchTab> createState() => _BranchTabState();
}

class _BranchTabState extends State<BranchTab> {
  final TextEditingController _searchBranchController = TextEditingController();
  List<Branch> _daftarBranch = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final result = await BranchBloc.daftarBranch();
      setState(() => _daftarBranch = result.data ?? []);
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
    List<Branch> filtered = _daftarBranch.where((item) {
      final kw = _searchBranchController.text.toLowerCase();
      return item.name.toLowerCase().contains(kw) || (item.code ?? '').toLowerCase().contains(kw);
    }).toList();

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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? const Center(child: Text("Belum ada data branch", style: TextStyle(fontSize: 12)))
                    : RefreshIndicator(
                        onRefresh: _fetchData,
                        child: ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final item = filtered[index];
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
                                        Text("Kode: ${item.code ?? '-'}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: corporateGreen)),
                                        Text(item.isActive ? "Aktif" : "Non-Aktif",
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: item.isActive ? Colors.green : Colors.red)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(item.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    Text("Alamat: ${item.address ?? '-'} | Telp: ${item.phone ?? '-'}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                    const Divider(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        actionBtn("Edit", Colors.blue, Icons.edit, () => _showFormBranch(context, item)),
                                        const SizedBox(width: 6),
                                        actionBtn("Hapus", Colors.red, Icons.delete, () => _confirmDelete(item)),
                                      ],
                                    ),
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

  void _confirmDelete(Branch item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Branch?", style: TextStyle(fontSize: 14)),
        content: Text("Yakin ingin menghapus ${item.name}?", style: const TextStyle(fontSize: 12)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await BranchBloc.hapusBranch(item.id);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Branch berhasil dihapus')));
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

  // TAMBAHAN: validasi client-side sebelum request dikirim ke API.
  // Sebelumnya field kosong lolos ke backend dan pesan error Laravel
  // default ("The code field is required.") ditampilkan mentah-mentah
  // dalam bahasa Inggris lewat SnackBar. Sekarang dicegat lebih dulu
  // di Flutter dengan pesan Indonesia.
  String? _validateFormBranch({
    required String kode,
    required String nama,
    required String alamat,
    required String telp,
  }) {
    if (kode.trim().isEmpty) return 'Kode branch wajib diisi';
    if (nama.trim().isEmpty) return 'Nama branch wajib diisi';
    if (alamat.trim().isEmpty) return 'Alamat wajib diisi';
    if (telp.trim().isEmpty) return 'No. telepon wajib diisi';
    if (!RegExp(r'^[0-9]+$').hasMatch(telp.trim())) return 'No. telepon hanya boleh berupa angka';
    return null;
  }

  void _showFormBranch(BuildContext context, Branch? branch) {
    final kodeCtrl = TextEditingController(text: branch?.code ?? '');
    final namaCtrl = TextEditingController(text: branch?.name ?? '');
    final alamatCtrl = TextEditingController(text: branch?.address ?? '');
    final telpCtrl = TextEditingController(text: branch?.phone ?? '');
    bool aktif = branch?.isActive ?? true;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
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
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Batal", style: TextStyle(fontSize: 11))),
            ElevatedButton(
              style: btnStyle(),
              onPressed: () async {
                // TAMBAHAN: cek validasi dulu sebelum panggil API
                final errorMsg = _validateFormBranch(
                  kode: kodeCtrl.text,
                  nama: namaCtrl.text,
                  alamat: alamatCtrl.text,
                  telp: telpCtrl.text,
                );
                if (errorMsg != null) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
                  );
                  return;
                }

                try {
                  if (branch == null) {
                    await BranchBloc.tambahBranch(
                      code: kodeCtrl.text, name: namaCtrl.text, address: alamatCtrl.text,
                      phone: telpCtrl.text, isActive: aktif,
                    );
                  } else {
                    await BranchBloc.updateBranch(
                      id: branch.id, code: kodeCtrl.text, name: namaCtrl.text,
                      address: alamatCtrl.text, phone: telpCtrl.text, isActive: aktif,
                    );
                  }
                  Navigator.pop(dialogContext);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(branch == null ? 'Branch berhasil ditambahkan' : 'Branch berhasil diperbarui')));
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