import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class KpiCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color accentColor;

  const KpiCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.accentColor = AppTheme.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: accentColor, width: 4)),
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
