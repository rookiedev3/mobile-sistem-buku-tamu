import 'package:flutter/material.dart';

// Asumsi: hapus kata "lib/" dan sesuaikan '../' dengan posisi file ini berada
import 'core/shared_widgets.dart';
import 'branch_tab.dart';
import 'product_tab.dart';
import 'lead_tab.dart';
import 'visit_tab.dart';
import 'guest_tab.dart';

class BranchesScreen extends StatefulWidget {
  const BranchesScreen({Key? key}) : super(key: key);

  @override
  State<BranchesScreen> createState() => _BranchesScreenState();
}

class _BranchesScreenState extends State<BranchesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
        children: const [
          BranchTab(),
          ProductTab(),
          LeadTab(),
          VisitTab(),
          GuestTab(),
        ],
      ),
    );
  }
}