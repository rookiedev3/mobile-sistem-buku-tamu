import 'package:flutter/material.dart';

class BranchesScreen extends StatefulWidget {
  const BranchesScreen({Key? key}) : super(key: key);

  @override
  State<BranchesScreen> createState() => _BranchesScreenState();
}

class _BranchesScreenState extends State<BranchesScreen> with SingleTickerProviderStateMixin {
  final Color corporateGreen = const Color(0xFF006B3F);
  late TabController _tabController;

  // Search Controllers per Tab
  final TextEditingController _searchBranchController = TextEditingController();
  final TextEditingController _searchProductController = TextEditingController();
  final TextEditingController _searchLeadController = TextEditingController();
  final TextEditingController _searchVisitController = TextEditingController();
  final TextEditingController _searchGuestController = TextEditingController();

  // --- DATA SIMULASI MASTER DATA ---
  final List<Map<String, dynamic>> _daftarBranch = [
    {"id": 1, "kode": "SLM", "nama": "Cabang Sleman", "alamat": "Jl. Ringroad Utara, Sleman", "telepon": "0274-123456", "status": "Aktif"},
    {"id": 2, "kode": "MGL", "nama": "Cabang Magelang", "alamat": "Jl. Pemuda No. 15, Magelang", "telepon": "0293-654321", "status": "Aktif"},
  ];

  final List<Map<String, dynamic>> _daftarProduct = [
    {"id": 1, "kode": "PRD-01", "nama": "Software POS", "kategori": "Aplikasi", "status": "Aktif"},
    {"id": 2, "kode": "PRD-02", "nama": "Sistem Buku Tamu", "kategori": "SaaS", "status": "Aktif"},
  ];

  final List<Map<String, dynamic>> _daftarLead = [
    {"id": 1, "nama": "Google Search"},
    {"id": 2, "nama": "Media Sosial"},
    {"id": 3, "nama": "Rekomendasi Klien"},
  ];

  final List<Map<String, dynamic>> _daftarVisit = [
    {"id": 1, "nama": "Meeting Bisnis", "status": "Aktif"},
    {"id": 2, "nama": "Konsultasi", "status": "Aktif"},
    {"id": 3, "nama": "Interview", "status": "Aktif"},
  ];

  final List<Map<String, dynamic>> _daftarGuestCat = [
    {"id": 1, "nama": "Vendor", "warna": "Merah"},
    {"id": 2, "nama": "Mitra", "warna": "Hijau"},
    {"id": 3, "nama": "VIP", "warna": "Kuning"},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: corporateGreen,
        elevation: 0,
        title: const Text(
          "Master Data Perusahaan",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Branches"),
            Tab(text: "Products"),
            Tab(text: "Lead Sources"),
            Tab(text: "Visit Purposes"),
            Tab(text: "Guest Categories"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBranchTab(),
          _buildProductTab(),
          _buildLeadTab(),
          _buildVisitTab(),
          _buildGuestCatTab(),
        ],
      ),
    );
  }

  // ==================== 1. TAB BRANCHES ====================
  Widget _buildBranchTab() {
    List filtered = _daftarBranch.where((item) => item['nama'].toLowerCase().contains(_searchBranchController.text.toLowerCase()) || item['kode'].toLowerCase().contains(_searchBranchController.text.toLowerCase())).toList();

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
                  decoration: _searchDecoration("Cari branch..."),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: _btnStyle(),
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
                            Text("Kode: ${item["kode"]}", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: corporateGreen)),
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
                            _actionBtn("Edit", Colors.blue, Icons.edit, () => _showFormBranch(context, item)),
                            const SizedBox(width: 6),
                            _actionBtn("Hapus", Colors.red, Icons.delete, () => setState(() => _daftarBranch.remove(item))),
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
                _dialogField("Kode Branch", kodeCtrl),
                const SizedBox(height: 6),
                _dialogField("Nama Branch", namaCtrl),
                const SizedBox(height: 6),
                _dialogField("Alamat", alamatCtrl),
                const SizedBox(height: 6),
                _dialogField("No. Telepon", telpCtrl, keyboardType: TextInputType.phone),
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
              style: _btnStyle(),
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

  // ==================== 2. TAB PRODUCTS ====================
  Widget _buildProductTab() {
    List filtered = _daftarProduct.where((item) => item['nama'].toLowerCase().contains(_searchProductController.text.toLowerCase()) || item['kode'].toLowerCase().contains(_searchProductController.text.toLowerCase())).toList();

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
                  decoration: _searchDecoration("Cari produk..."),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: _btnStyle(),
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
                            Text(item["kode"], style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: corporateGreen)),
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
                            _actionBtn("Edit", Colors.blue, Icons.edit, () => _showFormProduct(context, item)),
                            const SizedBox(width: 6),
                            _actionBtn("Hapus", Colors.red, Icons.delete, () => setState(() => _daftarProduct.remove(item))),
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
              _dialogField("Kode Produk", kodeCtrl),
              const SizedBox(height: 6),
              _dialogField("Nama Produk", namaCtrl),
              const SizedBox(height: 6),
              _dialogField("Kategori", kategoriCtrl),
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
              style: _btnStyle(),
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

  // ==================== 3. TAB LEAD SOURCES (Diperbaiki agar proporsional) ====================
  Widget _buildLeadTab() {
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
                  decoration: _searchDecoration("Cari lead source..."),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: _btnStyle(),
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
                        _actionBtn("Edit", Colors.blue, Icons.edit, () => _showFormLead(context, item)),
                        const SizedBox(width: 6),
                        _actionBtn("Hapus", Colors.red, Icons.delete, () => setState(() => _daftarLead.remove(item))),
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
          width: 300, // Membatasi lebar dialog agar tidak terlalu lebar
          child: Column(
            mainAxisSize: MainAxisSize.min, // Membuat tinggi pop-up menyesuaikan isi secara pas
            children: [
              _dialogField("Nama Sumber Lead", namaCtrl),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(fontSize: 11, color: Color(0xFF778195))),
          ),
          ElevatedButton(
            style: _btnStyle(),
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

  // ==================== 4. TAB VISIT PURPOSES ====================
  Widget _buildVisitTab() {
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
                  decoration: _searchDecoration("Cari tujuan kunjungan..."),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: _btnStyle(),
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
                        _actionBtn("Edit", Colors.blue, Icons.edit, () => _showFormVisit(context, item)),
                        const SizedBox(width: 6),
                        _actionBtn("Hapus", Colors.red, Icons.delete, () => setState(() => _daftarVisit.remove(item))),
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
              _dialogField("Nama Tujuan", namaCtrl),
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
              style: _btnStyle(),
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

  // ==================== 5. TAB GUEST CATEGORIES ====================
  Widget _buildGuestCatTab() {
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
                  decoration: _searchDecoration("Cari kategori tamu..."),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: _btnStyle(),
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
                        _actionBtn("Edit", Colors.blue, Icons.edit, () => _showFormGuestCat(context, item)),
                        const SizedBox(width: 6),
                        _actionBtn("Hapus", Colors.red, Icons.delete, () => setState(() => _daftarGuestCat.remove(item))),
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
            _dialogField("Nama Kategori", namaCtrl),
            const SizedBox(height: 6),
            _dialogField("Warna Badge", warnaCtrl),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal", style: TextStyle(fontSize: 11))),
          ElevatedButton(
            style: _btnStyle(),
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

  // --- HELPER COMPONENTS ---
  InputDecoration _searchDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
      prefixIcon: const Icon(Icons.search, size: 16, color: Color(0xFF778195)),
      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      filled: true,
      fillColor: Colors.white,
    );
  }

  Widget _dialogField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF778195))),
        const SizedBox(height: 3),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 11),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            filled: true,
            fillColor: const Color(0xFFF4F7FC),
            isDense: true,
          ),
        ),
      ],
    );
  }

  ButtonStyle _btnStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: corporateGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _actionBtn(String label, Color color, IconData icon, VoidCallback onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 12, color: color),
      label: Text(label, style: TextStyle(fontSize: 10, color: color)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        side: BorderSide(color: color),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        minimumSize: const Size(36, 24),
      ),
    );
  }
}