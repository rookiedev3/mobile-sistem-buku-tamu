// lib/ui/product_tab.dart
import 'package:flutter/material.dart';
import 'package:mobile_flutter/bloc/product_bloc.dart';
import 'package:mobile_flutter/model/product.dart';
import '../master_data/core/shared_widgets.dart';

class ProductTab extends StatefulWidget {
  const ProductTab({Key? key}) : super(key: key);

  @override
  State<ProductTab> createState() => _ProductTabState();
}

class _ProductTabState extends State<ProductTab> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _daftarProduk = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final result = await ProductBloc.daftarProduk();
      setState(() => _daftarProduk = result.data ?? []);
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
    List<Product> filtered = _daftarProduk.where((item) {
      final kw = _searchController.text.toLowerCase();
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
                  controller: _searchController,
                  onChanged: (val) => setState(() {}),
                  style: const TextStyle(fontSize: 12),
                  decoration: searchDecoration("Cari produk..."),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: btnStyle(),
                onPressed: () => _showFormProduk(context, null),
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
                    ? const Center(child: Text("Belum ada data produk", style: TextStyle(fontSize: 12)))
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
                                    Text("Kategori: ${item.category ?? '-'}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                    const Divider(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        actionBtn("Edit", Colors.blue, Icons.edit, () => _showFormProduk(context, item)),
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

  void _confirmDelete(Product item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Produk?", style: TextStyle(fontSize: 14)),
        content: Text("Yakin ingin menghapus ${item.name}?", style: const TextStyle(fontSize: 12)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ProductBloc.hapusProduk(item.id);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produk berhasil dihapus')));
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
  String? _validateFormProduk({
    required String kode,
    required String nama,
    required String kategori,
  }) {
    if (kode.trim().isEmpty) return 'Kode produk wajib diisi';
    if (nama.trim().isEmpty) return 'Nama produk wajib diisi';
    if (kategori.trim().isEmpty) return 'Kategori wajib diisi';
    return null;
  }

  void _showFormProduk(BuildContext context, Product? produk) {
    final kodeCtrl = TextEditingController(text: produk?.code ?? '');
    final namaCtrl = TextEditingController(text: produk?.name ?? '');
    final kategoriCtrl = TextEditingController(text: produk?.category ?? '');
    bool aktif = produk?.isActive ?? true;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(produk == null ? "Tambah Produk" : "Edit Produk", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
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
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Batal", style: TextStyle(fontSize: 11))),
            ElevatedButton(
              style: btnStyle(),
              onPressed: () async {
                // TAMBAHAN: cek validasi dulu sebelum panggil API
                final errorMsg = _validateFormProduk(
                  kode: kodeCtrl.text,
                  nama: namaCtrl.text,
                  kategori: kategoriCtrl.text,
                );
                if (errorMsg != null) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
                  );
                  return;
                }

                try {
                  if (produk == null) {
                    await ProductBloc.tambahProduk(code: kodeCtrl.text, name: namaCtrl.text, category: kategoriCtrl.text, isActive: aktif);
                  } else {
                    await ProductBloc.updateProduk(id: produk.id, code: kodeCtrl.text, name: namaCtrl.text, category: kategoriCtrl.text, isActive: aktif);
                  }
                  Navigator.pop(dialogContext);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(produk == null ? 'Produk berhasil ditambahkan' : 'Produk berhasil diperbarui')));
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