import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  static const _statusColors = {
    'pending': Color(0xFFF59E0B),
    'confirmed': Color(0xFF3B82F6),
    'shipped': Color(0xFF8B5CF6),
    'delivered': Color(0xFF10B981),
    'cancelled': Color(0xFFEF4444),
    'active': Color(0xFF10B981),
    'inactive': Color(0xFF6B7280),
  };

  @override
  Widget build(BuildContext context) {
    final color = _statusColors[status.toLowerCase()] ?? const Color(0xFF6B7280);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
