import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/order_provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'order_detail_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrders();
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return AppTheme.warning;
      case 'confirmed':
        return const Color(0xFF2471A3);
      case 'shipped':
        return AppTheme.primary;
      case 'delivered':
        return AppTheme.success;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accent))
          : provider.orders.isEmpty
              ? Center(
                  child: Text('No orders yet.',
                      style:
                          GoogleFonts.inter(color: AppTheme.textSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.orders.length,
                  itemBuilder: (ctx, i) {
                    final order = provider.orders[i];
                    return _OrderCard(
                      order: order,
                      statusColor: _statusColor(order.status),
                    );
                  },
                ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final Color statusColor;
  const _OrderCard({required this.order, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => OrderDetailScreen(orderId: order.id)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('#${order.id}',
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.accent,
                            fontFeatures: [
                              const FontFeature.tabularFigures()
                            ])),
                    const SizedBox(height: 4),
                    Text(
                        '${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year}',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: AppTheme.textSecondary)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        order.status,
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor),
                      ),
                    ),
                  ],
                ),
              ),
              Text('₹${order.totalAmount.toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary)),
            ],
          ),
        ),
      ),
    );
  }
}
