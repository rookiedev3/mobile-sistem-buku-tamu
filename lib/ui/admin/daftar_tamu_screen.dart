import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_flutter/bloc/check_in_bloc.dart';
import 'package:mobile_flutter/bloc/dashboard_admin_bloc.dart';
import 'package:mobile_flutter/helpers/api_url.dart';
import 'package:mobile_flutter/model/check_in.dart';
import 'package:mobile_flutter/ui/homepage_screen.dart';

class DaftarTamuScreen extends StatefulWidget {
  const DaftarTamuScreen({Key? key}) : super(key: key);

  @override
  State<DaftarTamuScreen> createState() => _DaftarTamuScreenState();
}

class _DaftarTamuScreenState extends State<DaftarTamuScreen> {
  final Color corporateGreen = const Color(0xFF006B3F);

  // State Data Tamu & Pagination
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _daftarTamu = [];

  int _currentPage = 1;
  int _lastPage = 1;
  int _totalData = 0;
  final int _perPage = 10;

  // State Notifikasi
  int _unreadNotifCount = 0;
  List<dynamic> _notifications = [];

  // State Filter & Search
  String _filterKategori = 'Semua Tamu';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchGuestsData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Memuat data Tamu & Notifikasi dari Backend API
  Future<void> _fetchGuestsData({int page = 1}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String? vipParam;
      if (_filterKategori == 'VIP') vipParam = '1';
      if (_filterKategori == 'Reguler') vipParam = '0';

      final Map<String, dynamic> responseData =
          await DashboardAdminBloc.getGuests(
            vipStatus: vipParam,
            keyword: _searchController.text.trim(),
            page: page,
          );

      if (!mounted) return;

      List<dynamic> guestList = [];
      int current = 1;
      int last = 1;
      int total = 0;

      if (responseData.containsKey('data')) {
        final dataProp = responseData['data'];
        if (dataProp is List) {
          guestList = List<dynamic>.from(dataProp);
        } else if (dataProp is Map<String, dynamic>) {
          guestList = List<dynamic>.from(dataProp['data'] ?? []);
          current = dataProp['current_page'] ?? 1;
          last = dataProp['last_page'] ?? 1;
          total = dataProp['total'] ?? guestList.length;
        }
      }

      if (responseData.containsKey('current_page')) {
        current = responseData['current_page'] ?? 1;
        last = responseData['last_page'] ?? 1;
        total = responseData['total'] ?? guestList.length;
      }

      int unreadCount = 0;
      List<dynamic> unreadNotifs = [];
      try {
        final dashboardData = await DashboardAdminBloc.getDashboard();
        if (!mounted) return;

        final statistics = dashboardData['statistics'] ?? {};
        final notifData = dashboardData['notifications'];

        List<dynamic> notifList = [];
        if (notifData is Map && notifData.containsKey('data')) {
          notifList = notifData['data'] ?? [];
        } else if (notifData is List) {
          notifList = notifData;
        }

        unreadNotifs = notifList.where((item) {
          return item['read_at'] == null;
        }).toList();

        unreadCount = statistics['unread_notifications'] ?? unreadNotifs.length;
      } catch (e) {
        debugPrint('Gagal memuat notifikasi: $e');
      }

      if (!mounted) return;

      setState(() {
        _daftarTamu = guestList;
        _currentPage = current;
        _lastPage = last;
        _totalData = total;
        _notifications = unreadNotifs;
        _unreadNotifCount = unreadCount;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Tandai 1 Notifikasi Dibaca
  Future<void> _markNotificationAsRead(String notifId) async {
    setState(() {
      for (var notif in _notifications) {
        if (notif['id']?.toString() == notifId) {
          notif['read_at'] = DateTime.now().toIso8601String();
          notif['is_read'] = true;
        }
      }
      if (_unreadNotifCount > 0) {
        _unreadNotifCount--;
      }
    });

    try {
      await DashboardAdminBloc.markNotificationAsRead(notifId);
    } catch (e) {
      debugPrint('Gagal menandai notifikasi dibaca: $e');
      if (mounted) _fetchGuestsData(page: _currentPage);
    }
  }

  /// Tandai Semua Notifikasi Dibaca
  Future<void> _markAllNotificationsAsRead() async {
    setState(() {
      for (var notif in _notifications) {
        notif['read_at'] = DateTime.now().toIso8601String();
        notif['is_read'] = true;
      }
      _unreadNotifCount = 0;
    });

    try {
      await DashboardAdminBloc.markAllNotificationsAsRead();
    } catch (e) {
      debugPrint('Gagal menandai semua notifikasi dibaca: $e');
      if (mounted) _fetchGuestsData(page: _currentPage);
    }
  }

  /// Mengubah Status VIP Tamu ke Backend API Laravel
  Future<void> _toggleVipStatus(int guestId, bool currentIsVip) async {
    final bool newVipStatus = !currentIsVip;
    final String statusTargetText = newVipStatus ? "VIP" : "Reguler";

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          "Konfirmasi Ubah VIP",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        content: Text("Ubah status tamu ini menjadi $statusTargetText?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: corporateGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Ya, Ubah"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      await DashboardAdminBloc.updateGuestVip(
        guestId: guestId,
        isVip: newVipStatus,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Status tamu berhasil diubah menjadi $statusTargetText",
          ),
          backgroundColor: corporateGreen,
        ),
      );

      _fetchGuestsData(page: _currentPage);
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal mengubah status VIP: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Widget Helper untuk Menampilkan Foto Profil Tamu
  Widget _buildAvatar(
    Map<String, dynamic> tamu, {
    double radius = 16,
    double iconSize = 18,
    XFile? localPhoto,
  }) {
    if (localPhoto != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: kIsWeb
            ? NetworkImage(localPhoto.path)
            : FileImage(File(localPhoto.path)) as ImageProvider,
      );
    }

    final String? photoUrl =
        tamu["photo_url"] ?? tamu["photo_path"] ?? tamu["photo"];

    if (photoUrl != null && photoUrl.toString().trim().isNotEmpty) {
      String finalUrl = photoUrl;

      if (!finalUrl.startsWith('http')) {
        final cleanPath = finalUrl.startsWith('/')
            ? finalUrl.substring(1)
            : finalUrl;
        finalUrl = '${ApiUrl.baseUrl}/storage/$cleanPath';
      }

      return SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: ClipOval(
          child: Image.network(
            finalUrl,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return CircleAvatar(
                radius: radius,
                backgroundColor: const Color(0xFFF4F7FC),
                child: Icon(
                  Icons.person,
                  size: iconSize,
                  color: corporateGreen,
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return CircleAvatar(
                radius: radius,
                backgroundColor: const Color(0xFFF4F7FC),
                child: SizedBox(
                  width: radius,
                  height: radius,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: corporateGreen,
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFF4F7FC),
      child: Icon(Icons.person, size: iconSize, color: corporateGreen),
    );
  }

  /// Format tanggal (D-M-Y)
  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '-';
    try {
      final dt = DateTime.parse(rawDate).toLocal();
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final year = dt.year;
      return '$day-$month-$year';
    } catch (_) {
      return rawDate;
    }
  }

  // Pop-up Detail Tamu
  void _showDetailTamuDialog(BuildContext context, Map<String, dynamic> tamu) {
    final int guestId = tamu["id"] ?? 0;
    final bool isVip =
        (tamu["is_vip"] == 1 ||
        tamu["is_vip"] == true ||
        tamu["status"] == "VIP");
    final String statusLabel = isVip ? "VIP" : "Reguler";
    final int totalKunjungan =
        tamu["visits_count"] ?? tamu["totalKunjungan"] ?? 0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.all(20),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                _buildAvatar(tamu, radius: 30, iconSize: 35),
                const SizedBox(height: 10),
                Text(
                  tamu["name"] ?? tamu["nama"] ?? "-",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172033),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isVip
                        ? Colors.amber.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isVip ? Colors.amber[800] : Colors.grey[700],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 10),
                _buildDetailRow("Kode Tamu", tamu["guest_code"] ?? "-"),
                _buildDetailRow(
                  "Instansi",
                  tamu["company_name"] ?? tamu["instansi"] ?? "-",
                ),
                _buildDetailRow(
                  "Jabatan",
                  tamu["position"] ?? tamu["jabatan"] ?? "-",
                ),
                _buildDetailRow("No. WA", tamu["phone"] ?? tamu["wa"] ?? "-"),
                _buildDetailRow("Email", tamu["email"] ?? "-"),
                _buildDetailRow(
                  "Alamat",
                  tamu["address"] ?? tamu["alamat"] ?? "-",
                ),
                _buildDetailRow(
                  "Terdaftar",
                  _formatDate(tamu["created_at"] ?? tamu["tanggal"]),
                ),
                _buildDetailRow("Frekuensi", "$totalKunjungan Kali"),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: isVip ? Colors.grey : Colors.amber.shade800,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _toggleVipStatus(guestId, isVip);
                        },
                        icon: Icon(
                          isVip ? Icons.star_border : Icons.star,
                          size: 14,
                          color: isVip ? Colors.grey[700] : Colors.amber[800],
                        ),
                        label: Text(
                          isVip ? "Set Reguler" : "Set VIP",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isVip ? Colors.grey[700] : Colors.amber[800],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: corporateGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Tutup",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Pop-up Ubah Profil Tamu
  void _showEditTamuDialog(BuildContext context, Map<String, dynamic> tamu) {
    final int guestId = tamu["id"] ?? 0;
    final TextEditingController namaController = TextEditingController(
      text: tamu["name"] ?? tamu["nama"] ?? "",
    );
    final TextEditingController waController = TextEditingController(
      text: tamu["phone"] ?? tamu["wa"] ?? "",
    );
    final TextEditingController emailController = TextEditingController(
      text: tamu["email"] ?? "",
    );
    final TextEditingController instansiController = TextEditingController(
      text: tamu["company_name"] ?? tamu["instansi"] ?? "",
    );
    final TextEditingController jabatanController = TextEditingController(
      text: tamu["position"] ?? tamu["jabatan"] ?? "",
    );
    final TextEditingController alamatController = TextEditingController(
      text: tamu["address"] ?? tamu["alamat"] ?? "",
    );

    bool isVip =
        (tamu["is_vip"] == 1 ||
        tamu["is_vip"] == true ||
        tamu["status"] == "VIP");
    String statusTamu = isVip ? 'VIP' : 'Reguler';
    XFile? pickedPhoto;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.edit_note_rounded,
                    color: corporateGreen,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Ubah Profil Tamu",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          _buildAvatar(
                            tamu,
                            radius: 32,
                            iconSize: 36,
                            localPhoto: pickedPhoto,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: corporateGreen,
                              child: const Icon(
                                Icons.camera_alt,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField("Nama Lengkap *", namaController),
                    const SizedBox(height: 6),
                    _buildTextField(
                      "No. WhatsApp *",
                      waController,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 6),
                    _buildTextField(
                      "Email *",
                      emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 6),
                    _buildTextField(
                      "Instansi / Perusahaan *",
                      instansiController,
                    ),
                    const SizedBox(height: 6),
                    _buildTextField("Jabatan *", jabatanController),
                    const SizedBox(height: 6),
                    const Text(
                      "Status Tamu",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF778195),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F7FC),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: statusTamu,
                          isExpanded: true,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF172033),
                            fontWeight: FontWeight.w600,
                          ),
                          items: ['Reguler', 'VIP'].map((val) {
                            return DropdownMenuItem(
                              value: val,
                              child: Text(val),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setStateDialog(() => statusTamu = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildTextField("Alamat", alamatController),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            if (image != null) {
                              setStateDialog(() => pickedPhoto = image);
                            }
                          },
                          icon: const Icon(
                            Icons.upload_file,
                            size: 12,
                            color: Color(0xFF006B3F),
                          ),
                          label: const Text(
                            "Ganti Foto",
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF006B3F),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: corporateGreen),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (pickedPhoto != null)
                          const Text(
                            "Foto Baru ✓",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text(
                    "Batal",
                    style: TextStyle(fontSize: 11, color: Color(0xFF778195)),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: corporateGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          // Validasi Wajib untuk Nama, No WA, Email, Instansi, dan Jabatan
                          if (namaController.text.trim().isEmpty ||
                              waController.text.trim().isEmpty ||
                              emailController.text.trim().isEmpty ||
                              instansiController.text.trim().isEmpty ||
                              jabatanController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Nama, No. WA, Email, Instansi, dan Jabatan wajib diisi!',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          setStateDialog(() => isSubmitting = true);

                          try {
                            await DashboardAdminBloc.updateGuest(
                              guestId: guestId,
                              name: namaController.text.trim(),
                              phone: waController.text.trim(),
                              email: emailController.text.trim(),
                              companyName: instansiController.text.trim(),
                              position: jabatanController.text.trim(),
                              address: alamatController.text.trim(),
                              isVip: statusTamu == 'VIP',
                              photoFile: pickedPhoto,
                            );

                            if (!mounted) return;
                            Navigator.pop(context);
                            _fetchGuestsData(page: _currentPage);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Profil tamu berhasil diperbarui!',
                                ),
                                backgroundColor: Color(0xFF006B3F),
                              ),
                            );
                          } catch (e) {
                            setStateDialog(() => isSubmitting = false);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Gagal memperbarui profil: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Simpan Perubahan",
                          style: TextStyle(fontSize: 11),
                        ),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      namaController.dispose();
      waController.dispose();
      emailController.dispose();
      instansiController.dispose();
      jabatanController.dispose();
      alamatController.dispose();
    });
  }

  // Pop-up Tambah Tamu Baru (Memanggil Widget Dialog Baru)
  void _showTambahTamuDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const FormTambahTamuDialog(),
    );

    if (result == true && mounted) {
      _fetchGuestsData(page: 1);
    }
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF778195),
          ),
        ),
        const SizedBox(height: 3),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 11),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              vertical: 6,
              horizontal: 8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            filled: true,
            fillColor: const Color(0xFFF4F7FC),
            isDense: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF778195),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Text(": ", style: TextStyle(fontSize: 11)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF172033),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Pagination Control
  Widget _buildPaginationControl() {
    int startItem = _totalData == 0 ? 0 : ((_currentPage - 1) * _perPage) + 1;
    int endItem = (_currentPage * _perPage) > _totalData
        ? _totalData
        : (_currentPage * _perPage);

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Menampilkan $startItem-$endItem dari $_totalData data",
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF778195),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "Hal $_currentPage dari $_lastPage",
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF172033),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.first_page, size: 18),
                onPressed: _currentPage > 1
                    ? () => _fetchGuestsData(page: 1)
                    : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                color: corporateGreen,
                disabledColor: Colors.grey.shade300,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 18),
                onPressed: _currentPage > 1
                    ? () => _fetchGuestsData(page: _currentPage - 1)
                    : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                color: corporateGreen,
                disabledColor: Colors.grey.shade300,
              ),
              const SizedBox(width: 6),
              ..._buildPageNumbers(),
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 18),
                onPressed: _currentPage < _lastPage
                    ? () => _fetchGuestsData(page: _currentPage + 1)
                    : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                color: corporateGreen,
                disabledColor: Colors.grey.shade300,
              ),
              IconButton(
                icon: const Icon(Icons.last_page, size: 18),
                onPressed: _currentPage < _lastPage
                    ? () => _fetchGuestsData(page: _lastPage)
                    : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                color: corporateGreen,
                disabledColor: Colors.grey.shade300,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Dynamic Page Number Calculation
  List<Widget> _buildPageNumbers() {
    List<Widget> pageButtons = [];
    int start = _currentPage - 1;
    int end = _currentPage + 1;

    if (start < 1) {
      start = 1;
      end = (start + 2).clamp(1, _lastPage);
    }
    if (end > _lastPage) {
      end = _lastPage;
      start = (end - 2).clamp(1, _lastPage);
    }

    for (int i = start; i <= end; i++) {
      final bool isCurrent = (i == _currentPage);
      pageButtons.add(
        InkWell(
          onTap: isCurrent ? null : () => _fetchGuestsData(page: i),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isCurrent ? corporateGreen : const Color(0xFFF4F7FC),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isCurrent ? corporateGreen : const Color(0xFFE2E8F0),
              ),
            ),
            child: Text(
              "$i",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isCurrent ? Colors.white : const Color(0xFF172033),
              ),
            ),
          ),
        ),
      );
    }
    return pageButtons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: corporateGreen,
        elevation: 0,
        title: const Text(
          "Admin - Daftar Direktori Tamu",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh Data',
            onPressed: () => _fetchGuestsData(page: _currentPage),
          ),
          PopupMenuButton<String>(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, color: Colors.white),
                if (_unreadNotifCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 8,
                        minHeight: 8,
                      ),
                    ),
                  ),
              ],
            ),
            offset: const Offset(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (BuildContext context) {
              List<PopupMenuEntry<String>> items = [];

              items.add(
                PopupMenuItem<String>(
                  enabled: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Notifikasi Baru",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF172033),
                        ),
                      ),
                      if (_unreadNotifCount > 0)
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            _markAllNotificationsAsRead();
                          },
                          child: Text(
                            "Tandai semua dibaca",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: corporateGreen,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );

              items.add(const PopupMenuDivider());

              if (_notifications.isEmpty) {
                items.add(
                  const PopupMenuItem<String>(
                    enabled: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "Tidak ada notifikasi baru.",
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ),
                  ),
                );
              } else {
                for (var notif in _notifications) {
                  final String notifId = notif['id']?.toString() ?? '0';
                  final String title = notif['title'] ?? 'Notifikasi';
                  final String body = notif['body'] ?? '-';
                  final String time = notif['created_at'] ?? '-';
                  final bool isRead =
                      notif['read_at'] != null || (notif['is_read'] ?? false);

                  items.add(
                    PopupMenuItem<String>(
                      value: notifId,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: isRead
                                    ? Colors.grey.withValues(alpha: 0.1)
                                    : corporateGreen.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.notifications_active_rounded,
                                size: 16,
                                color: isRead ? Colors.grey : corporateGreen,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isRead
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                      color: const Color(0xFF172033),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    body,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF778195),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    time,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isRead)
                              IconButton(
                                icon: Icon(
                                  Icons.check,
                                  size: 14,
                                  color: corporateGreen,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  _markNotificationAsRead(notifId);
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              }

              return items;
            },
            onSelected: (String notifId) {
              _markNotificationAsRead(notifId);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Keluar',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: const Text(
                    "Konfirmasi Keluar",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  content: const Text(
                    "Apakah Anda yakin ingin keluar?",
                    style: TextStyle(fontSize: 11),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Batal",
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomepageScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        "Keluar",
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchGuestsData(page: 1),
        color: corporateGreen,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Direktori Buku Tamu",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF172033),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Kelola seluruh data kunjungan",
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF778195),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: corporateGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _showTambahTamuDialog(context),
                    icon: const Icon(Icons.add, size: 14),
                    label: const Text(
                      "Tambah",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: (_) => _fetchGuestsData(page: 1),
                      decoration: InputDecoration(
                        hintText: "Cari nama / WA / perusahaan...",
                        hintStyle: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9CA3AF),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 16,
                          color: Color(0xFF778195),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 14),
                                onPressed: () {
                                  _searchController.clear();
                                  _fetchGuestsData(page: 1);
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _filterKategori,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF172033),
                          fontWeight: FontWeight.bold,
                        ),
                        items: ['Semua Tamu', 'VIP', 'Reguler'].map((
                          String val,
                        ) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val),
                          );
                        }).toList(),
                        onChanged: (String? val) {
                          if (val != null) {
                            setState(() => _filterKategori = val);
                            _fetchGuestsData(page: 1);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF006B3F)),
                  ),
                )
              else if (_errorMessage != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 11),
                    ),
                  ),
                )
              else if (_daftarTamu.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text(
                      "Tidak ada data tamu ditemukan.",
                      style: TextStyle(color: Color(0xFF778195), fontSize: 11),
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _daftarTamu.length,
                      itemBuilder: (context, index) {
                        final tamu = _daftarTamu[index] as Map<String, dynamic>;

                        final int guestId = tamu["id"] ?? (index + 1);
                        final String nama =
                            tamu["name"] ?? tamu["nama"] ?? "Tamu";
                        final String phone = tamu["phone"] ?? tamu["wa"] ?? "-";
                        final String instansi =
                            tamu["company_name"] ?? tamu["instansi"] ?? "-";
                        final String jabatan =
                            tamu["position"] ?? tamu["jabatan"] ?? "-";
                        final String tglTerdaftar = _formatDate(
                          tamu["created_at"] ?? tamu["tanggal"],
                        );
                        final int totalKunjungan =
                            tamu["visits_count"] ?? tamu["totalKunjungan"] ?? 0;
                        final bool isVip =
                            (tamu["is_vip"] == 1 ||
                            tamu["is_vip"] == true ||
                            tamu["status"] == "VIP");
                        final String statusText = isVip ? "VIP" : "Reguler";

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF4F7FC),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      "ID: $guestId",
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF778195),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isVip
                                          ? Colors.amber.withValues(alpha: 0.2)
                                          : Colors.grey.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      statusText,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isVip
                                            ? Colors.amber[800]
                                            : Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildAvatar(tamu, radius: 16, iconSize: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          nama,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Color(0xFF172033),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          "Terdaftar: $tglTerdaftar",
                                          style: const TextStyle(
                                            fontSize: 9,
                                            color: Color(0xFF778195),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Instansi: $instansi • $jabatan",
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF778195),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "No. WA: $phone",
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF778195),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Total Kunjungan: $totalKunjungan Kali",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: corporateGreen,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 6.0),
                                child: Divider(
                                  height: 1,
                                  color: Color(0xFFE5E7EB),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () =>
                                        _toggleVipStatus(guestId, isVip),
                                    icon: Icon(
                                      isVip ? Icons.star_border : Icons.star,
                                      size: 12,
                                      color: isVip
                                          ? Colors.grey[700]
                                          : Colors.amber[800],
                                    ),
                                    label: Text(
                                      isVip ? "Set Reguler" : "Ubah VIP",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isVip
                                            ? Colors.grey[700]
                                            : Colors.amber[800],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      side: BorderSide(
                                        color: isVip
                                            ? Colors.grey.shade400
                                            : Colors.amber.shade800,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      minimumSize: const Size(40, 24),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  OutlinedButton.icon(
                                    onPressed: () =>
                                        _showEditTamuDialog(context, tamu),
                                    icon: Icon(
                                      Icons.edit_outlined,
                                      size: 12,
                                      color: Colors.blue[700],
                                    ),
                                    label: Text(
                                      "Edit",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.blue[700],
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      side: BorderSide(
                                        color: Colors.blue.shade700,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      minimumSize: const Size(40, 24),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  OutlinedButton.icon(
                                    onPressed: () =>
                                        _showDetailTamuDialog(context, tamu),
                                    icon: Icon(
                                      Icons.visibility_outlined,
                                      size: 12,
                                      color: corporateGreen,
                                    ),
                                    label: Text(
                                      "Detail",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: corporateGreen,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      side: BorderSide(color: corporateGreen),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      minimumSize: const Size(40, 24),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    _buildPaginationControl(),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= WIDGET FORM TAMBAH TAMU DIALOG =================
class FormTambahTamuDialog extends StatefulWidget {
  const FormTambahTamuDialog({super.key});

  @override
  State<FormTambahTamuDialog> createState() => _FormTambahTamuDialogState();
}

class _FormTambahTamuDialogState extends State<FormTambahTamuDialog> {
  final Color corporateGreen = const Color(0xFF006B3F);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Key Form Validation
  bool _isSubmitting = false;

  // Controllers Identitas Tamu
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _waController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _instansiController = TextEditingController();
  final TextEditingController _jabatanController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();

  String _statusTamu = 'Reguler';
  XFile? _pickedPhoto;
  Uint8List? _imageBytes;

  // Master Data Guest Categories dari Table guest_categories
  List<OptionItem> _guestCategories = [];
  int? _selectedGuestCategoryId;
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _fetchGuestCategories();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _waController.dispose();
    _emailController.dispose();
    _instansiController.dispose();
    _jabatanController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  /// Memuat Kategori Tamu dari Table guest_categories via CheckInBloc
  Future<void> _fetchGuestCategories() async {
    try {
      CheckInMasterData masterData = await CheckInBloc.getFormData();
      if (!mounted) return;
      setState(() {
        _guestCategories = masterData.guestCategories;
        if (_guestCategories.isNotEmpty) {
          _selectedGuestCategoryId = _guestCategories.first.id;
        }
        _isLoadingCategories = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingCategories = false);
      debugPrint("Gagal memuat guest categories: $e");
    }
  }

  /// Picker Foto dengan Validasi Format (JPG, JPEG, PNG) & Ukuran Maksimal 2 MB
  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) return;

      final String fileNameLower = image.name.toLowerCase();
      final String pathLower = image.path.toLowerCase();
      final String? mimeType = image.mimeType?.toLowerCase();

      final bool isValidFormat = 
          fileNameLower.endsWith('.jpg') ||
          fileNameLower.endsWith('.jpeg') ||
          fileNameLower.endsWith('.png') ||
          pathLower.endsWith('.jpg') ||
          pathLower.endsWith('.jpeg') ||
          pathLower.endsWith('.png') ||
          (mimeType != null && (mimeType == 'image/jpeg' || mimeType == 'image/jpg' || mimeType == 'image/png'));

      if (!isValidFormat) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Format gambar harus berupa JPG, JPEG, atau PNG!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final int fileSizeInBytes = await image.length();
      const int maxSizeBytes = 2 * 1024 * 1024; // 2 MB

      if (fileSizeInBytes > maxSizeBytes) {
        if (!mounted) return;
        final double sizeInMb = fileSizeInBytes / (1024 * 1024);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ukuran gambar (${sizeInMb.toStringAsFixed(2)} MB) melebihi batas 2 MB!',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final bytes = await image.readAsBytes();
      setState(() {
        _pickedPhoto = image;
        _imageBytes = bytes;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Submit Data Tamu Baru
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await DashboardAdminBloc.storeGuest(
        name: _namaController.text.trim(),
        phone: _waController.text.trim(),
        email: _emailController.text.trim(),
        companyName: _instansiController.text.trim(),
        position: _jabatanController.text.trim(),
        address: _alamatController.text.trim(),
        guestCategoryId: _selectedGuestCategoryId,
        isVip: _statusTamu == 'VIP',
        photoFile: _pickedPhoto,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tamu baru berhasil ditambahkan!'),
          backgroundColor: Color(0xFF006B3F),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(20),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Tambah Tamu Baru",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF172033),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const Divider(height: 16),
                Text(
                  "Identitas Tamu",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: corporateGreen,
                  ),
                ),
                const SizedBox(height: 12),

                // 1. Validasi Nama (Wajib)
                _buildTextField(
                  "Nama Lengkap *",
                  _namaController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama lengkap wajib diisi!';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // 2. Validasi Nomor HP (Wajib & Format)
                _buildTextField(
                  "No. WhatsApp / Telepon *",
                  _waController,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'No. WhatsApp wajib diisi!';
                    }
                    final cleanValue = value.trim();
                    final phoneRegex = RegExp(r'^(?:\+62|62|08)[0-9]{8,13}$');
                    if (!phoneRegex.hasMatch(cleanValue)) {
                      return 'Nomor HP harus diawali 08, 62, atau +62 (10-15 digit)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // 3. Validasi Email (Wajib & Format)
                _buildTextField(
                  "Email *",
                  _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email wajib diisi!';
                    }
                    final emailRegex = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    );
                    if (!emailRegex.hasMatch(value.trim())) {
                      return 'Format email tidak valid!';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Dropdown Input Kategori Tamu
                _isLoadingCategories
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: LinearProgressIndicator(
                          color: Color(0xFF006B3F),
                        ),
                      )
                    : DropdownButtonFormField<int>(
                        value: _selectedGuestCategoryId,
                        isExpanded: true,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF172033),
                        ),
                        decoration: const InputDecoration(
                          labelText: "Kategori Tamu",
                          labelStyle: TextStyle(fontSize: 11),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: _guestCategories.map((OptionItem category) {
                          return DropdownMenuItem<int>(
                            value: category.id,
                            child: Text(
                              category.name,
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null)
                            setState(() => _selectedGuestCategoryId = val);
                        },
                      ),
                const SizedBox(height: 10),

                // 4. Validasi Asal Instansi (Wajib)
                _buildTextField(
                  "Asal Instansi / Perusahaan *",
                  _instansiController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Asal instansi wajib diisi!';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // 5. Validasi Jabatan (Wajib)
                _buildTextField(
                  "Jabatan *",
                  _jabatanController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Jabatan wajib diisi!';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: _statusTamu,
                  isExpanded: true,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF172033),
                  ),
                  decoration: const InputDecoration(
                    labelText: "Status Tamu",
                    labelStyle: TextStyle(fontSize: 11),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: ['Reguler', 'VIP'].map((val) {
                    return DropdownMenuItem<String>(
                      value: val,
                      child: Text(val, style: const TextStyle(fontSize: 12)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _statusTamu = val);
                  },
                ),
                const SizedBox(height: 10),
                _buildTextField("Alamat", _alamatController),
                const SizedBox(height: 14),
                const Text(
                  "Foto Tamu (Opsional)",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172033),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: _pickedPhoto != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: kIsWeb
                                ? Image.network(
                                    _pickedPhoto!.path,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(_pickedPhoto!.path),
                                    fit: BoxFit.cover,
                                  ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt_outlined,
                                size: 30,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Foto Opsional",
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickPhoto(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt, size: 14),
                        label: const Text(
                          "Kamera",
                          style: TextStyle(fontSize: 10),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: corporateGreen),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickPhoto(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library, size: 14),
                        label: const Text(
                          "Galeri",
                          style: TextStyle(fontSize: 10),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: corporateGreen),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: corporateGreen),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.pop(context),
                      child: Text(
                        "Batal",
                        style: TextStyle(fontSize: 11, color: corporateGreen),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: corporateGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _isSubmitting ? null : _submitForm,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              "Simpan",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Helper untuk membuat TextFormField dengan pesan error merah secara otomatis
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 12),
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 11),
        border: const OutlineInputBorder(),
        isDense: true,
        errorStyle: const TextStyle(
          fontSize: 10,
          color: Colors.red,
        ),
      ),
    );
  }
}