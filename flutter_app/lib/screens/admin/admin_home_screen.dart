import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../product_listing_screen.dart';
import '../order_history_screen.dart';
import '../profile_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _index = 0;

  final _pages = <Widget>[
    const _AdminDashboard(),
    const ProductListingScreen(),
    const _AdminOrdersPage(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              labelType: NavigationRailLabelType.all,
              backgroundColor: AppTheme.primary,
              selectedIconTheme: const IconThemeData(color: AppTheme.accent),
              unselectedIconTheme: IconThemeData(color: Colors.white.withValues(alpha: 0.6)),
              selectedLabelTextStyle: GoogleFonts.inter(color: AppTheme.accent, fontSize: 11, fontWeight: FontWeight.w600),
              unselectedLabelTextStyle: GoogleFonts.inter(color: Colors.white70, fontSize: 11),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: AppTheme.accent, borderRadius: BorderRadius.circular(8)),
                  alignment: Alignment.center,
                  child: Text('SS', style: GoogleFonts.playfairDisplay(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primaryDark)),
                ),
              ),
              destinations: const [
                NavigationRailDestination(icon: Icon(LucideIcons.layoutDashboard), label: Text('Dashboard')),
                NavigationRailDestination(icon: Icon(LucideIcons.package2), label: Text('Products')),
                NavigationRailDestination(icon: Icon(LucideIcons.shoppingCart), label: Text('Orders')),
                NavigationRailDestination(icon: Icon(LucideIcons.user), label: Text('Profile')),
              ],
            ),
            Expanded(child: _pages[_index]),
          ],
        ),
      );
    }

    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(LucideIcons.layoutDashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.package2), label: 'Products'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.shoppingCart), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.user), label: 'Profile'),
        ],
      ),
    );
  }
}

// ── Admin Dashboard ─────────────────────────────────
class _AdminDashboard extends StatefulWidget {
  const _AdminDashboard();

  @override
  State<_AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<_AdminDashboard> {
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final stats = await ApiService.getDashboardStats();
      setState(() { _stats = stats; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
          : _stats == null
              ? const Center(child: Text('Failed to load'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.5,
                        children: [
                          _KpiCard(icon: LucideIcons.package2, value: '${_stats!['totalProducts']}', label: 'Products'),
                          _KpiCard(icon: LucideIcons.layers, value: '${_stats!['totalBundles']}', label: 'Bundles'),
                          _KpiCard(icon: LucideIcons.clock, value: '${_stats!['pendingOrders']}', label: 'Pending'),
                          _KpiCard(icon: LucideIcons.users, value: '${_stats!['totalUsers']}', label: 'Users'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text('Recent Orders', style: GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      ...(_stats!['recentOrders'] as List<Order>).map((o) => Card(
                        child: ListTile(
                          leading: CircleAvatar(backgroundColor: AppTheme.accent.withValues(alpha: 0.2), child: Text('#${o.id}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.accent))),
                          title: Text(o.userName ?? 'Customer'),
                          subtitle: Text('${o.totalSarees} sarees • ${o.status}'),
                          trailing: Text('₹${o.totalAmount.toStringAsFixed(0)}', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppTheme.primary)),
                        ),
                      )),
                    ],
                  ),
                ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _KpiCard({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.accent, width: 4)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.primary, size: 22),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.w700)),
            Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// ── Admin Orders Page ────────────────────────────────
class _AdminOrdersPage extends StatefulWidget {
  const _AdminOrdersPage();

  @override
  State<_AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<_AdminOrdersPage> {
  List<Order> _orders = [];
  bool _loading = true;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      _orders = await ApiService.getOrders();
    } catch (_) {}
    setState(() => _loading = false);
  }

  List<Order> get _filtered => _filter == 'all' ? _orders : _orders.where((o) => o.status == _filter).toList();

  Future<void> _deleteOrder(Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Order'),
        content: Text('Delete Order #${order.id} for ${order.userName ?? "Customer"}?\nInventory will be restored automatically.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ApiService.deleteOrder(order.id);
      setState(() => _orders.removeWhere((o) => o.id == order.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order #${order.id} deleted & inventory restored'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Orders')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
          : Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: ['all', 'pending', 'confirmed', 'shipped', 'delivered'].map((s) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(s == 'all' ? 'All' : s[0].toUpperCase() + s.substring(1)),
                        selected: _filter == s,
                        selectedColor: AppTheme.accent,
                        onSelected: (_) => setState(() => _filter = s),
                      ),
                    )).toList(),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final o = _filtered[i];
                      return Card(
                        child: ListTile(
                          title: Text('#${o.id} — ${o.userName ?? "Customer"}'),
                          subtitle: Text('${o.totalSarees} sarees • ${o.status}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('₹${o.totalAmount.toStringAsFixed(0)}',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppTheme.primary)),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(LucideIcons.trash2, color: Colors.red, size: 20),
                                tooltip: 'Delete Order',
                                onPressed: () => _deleteOrder(o),
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
}
