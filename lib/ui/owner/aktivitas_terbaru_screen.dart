import 'dart:async';
import 'package:flutter/material.dart';
import '../../bloc/owner_bloc.dart'; // pastikan class DashboardOwnerBloc ada di file ini
import '../../model/dashboard_owner_model.dart';

class AktivitasTerbaruScreen extends StatefulWidget {
  const AktivitasTerbaruScreen({Key? key}) : super(key: key);

  @override
  State<AktivitasTerbaruScreen> createState() => _AktivitasTerbaruScreenState();
}

class _AktivitasTerbaruScreenState extends State<AktivitasTerbaruScreen> {
  final Color corporateGreen = const Color(0xFF006B3F);
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  final List<ActivityLogItem> _items = [];
  int _currentPage = 1;
  int _lastPage = 1;
  String _keyword = '';

  bool _isLoadingFirstPage = true;
  bool _isLoadingMore = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFirstPage();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      _isLoadingFirstPage = true;
      _errorMessage = null;
    });
    try {
      final result = await DashboardOwnerBloc.fetchActivityLog(keyword: _keyword, page: 1);
      setState(() {
        _items
          ..clear()
          ..addAll(result.items);
        _currentPage = result.currentPage;
        _lastPage = result.lastPage;
        _isLoadingFirstPage = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '$e';
        _isLoadingFirstPage = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _currentPage >= _lastPage) return;
    setState(() => _isLoadingMore = true);
    try {
      final result = await DashboardOwnerBloc.fetchActivityLog(
        keyword: _keyword,
        page: _currentPage + 1,
      );
      setState(() {
        _items.addAll(result.items);
        _currentPage = result.currentPage;
        _lastPage = result.lastPage;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data tambahan: $e')),
      );
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      setState(() => _keyword = value.trim());
      _loadFirstPage();
    });
  }

  String _formatWaktuLalu(String? iso) {
    if (iso == null) return '-';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes} min lalu';
      if (diff.inHours < 24) return '${diff.inHours} jam lalu';
      return '${diff.inDays} hari lalu';
    } catch (_) {
      return '-';
    }
  }

  Color _statusColor(String? status) {
    final s = (status ?? '').toLowerCase();
    if (s.contains('selesai') || s.contains('completed')) return Colors.green;
    if (s.contains('batal') || s.contains('cancel') || s.contains('tolak')) return Colors.red;
    if (s.contains('menunggu') || s.contains('waiting')) return Colors.orange;
    return corporateGreen;
  }

  IconData _statusIcon(String? status) {
    final s = (status ?? '').toLowerCase();
    if (s.contains('selesai') || s.contains('completed')) return Icons.check_circle_rounded;
    if (s.contains('batal') || s.contains('cancel') || s.contains('tolak')) return Icons.cancel_rounded;
    if (s.contains('menunggu') || s.contains('waiting')) return Icons.hourglass_top_rounded;
    return Icons.login_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        backgroundColor: corporateGreen,
        elevation: 0,
        title: const Text(
          "Log Aktivitas Terbaru",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 18, color: Colors.white),
            onPressed: _loadFirstPage,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(fontSize: 10.5),
              decoration: InputDecoration(
                hintText: "Cari nama tamu atau instansi...",
                prefixIcon: const Icon(Icons.search, size: 14, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                filled: true,
                fillColor: Colors.white,
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Riwayat Aktivitas Sistem",
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoadingFirstPage) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 32),
            const SizedBox(height: 8),
            Text(_errorMessage!, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _loadFirstPage, child: const Text('Coba Lagi')),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return const Center(
        child: Text("Tidak ada aktivitas yang ditemukan.", style: TextStyle(color: Colors.grey, fontSize: 10)),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFirstPage,
      child: NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 100) {
            _loadMore();
          }
          return false;
        },
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _items.length + (_currentPage < _lastPage ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _items.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }

            final item = _items[index];
            final color = _statusColor(item.newStatus);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                    child: Icon(_statusIcon(item.newStatus), size: 14, color: color),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "${item.guestName ?? '-'} (${item.companyName ?? '-'})",
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF172033)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(_formatWaktuLalu(item.changedAt), style: const TextStyle(fontSize: 8.5, color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(4)),
                          child: Text(
                            "Status diubah: ${item.newStatus ?? '-'}",
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: color),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}