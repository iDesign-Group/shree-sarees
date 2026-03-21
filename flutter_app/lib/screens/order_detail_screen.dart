import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Order? _order;
  Shipment? _shipment;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final order = await ApiService.getOrder(widget.orderId);
      Shipment? shipment;
      try { shipment = await ApiService.getShipment(widget.orderId); } catch (_) {}
      setState(() { _order = order; _shipment = shipment; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order #${widget.orderId}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
          : _order == null
              ? const Center(child: Text('Order not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Order Summary',
                                  style: GoogleFonts.sourceSerif4(fontSize: 18, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 12),
                              _Row('Status', _order!.status.toUpperCase()),
                              _Row('Total Sarees', '${_order!.totalSarees}'),
                              _Row('Total Amount', '\u20b9${_order!.totalAmount.toStringAsFixed(0)}'),
                              _Row('Date', '${_order!.orderDate.day}/${_order!.orderDate.month}/${_order!.orderDate.year}'),
                              if (_order!.storeName != null && _order!.storeName!.isNotEmpty)
                                _Row('Store', _order!.storeName!),
                              if (_order!.storeAddress != null && _order!.storeAddress!.isNotEmpty)
                                _Row('Store address', _order!.storeAddress!),
                              if (_order!.storePhone != null && _order!.storePhone!.isNotEmpty)
                                _Row('Contact', _order!.storePhone!),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Items', style: GoogleFonts.sourceSerif4(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      ..._order!.items.map((item) => Card(
                            child: ListTile(
                              title: Text(item.productName),
                              subtitle: Text('${item.bundlesOrdered} bundles \u00d7 ${item.sareesCount} sarees'),
                              trailing: Text('\u20b9${item.bundleCost.toStringAsFixed(0)}',
                                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: AppTheme.primary)),
                            ),
                          )),
                      if (_shipment != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: const Border(left: BorderSide(color: AppTheme.primary, width: 4)),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Shipment Info',
                                  style: GoogleFonts.sourceSerif4(fontSize: 16, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              _Row('Courier', _shipment!.courierName ?? '-'),
                              _Row('Tracking', _shipment!.trackingNumber ?? '-'),
                              _Row('Date', _shipment!.shipmentDate ?? '-'),
                              if (_shipment!.notes != null && _shipment!.notes!.isNotEmpty)
                                _Row('Notes', _shipment!.notes!),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary)),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
