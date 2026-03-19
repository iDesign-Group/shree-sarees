import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF6D1C2E);
  static const Color primaryDark = Color(0xFF4A1020);
  static const Color accent = Color(0xFFC9A84C);
  static const Color accentLight = Color(0xFFE8C97A);
  static const Color background = Color(0xFFFAF7F2);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1C1C1C);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color border = Color(0xFFE8E0D5);
  static const Color success = Color(0xFF2E7D52);
  static const Color warning = Color(0xFFD4860B);
  static const Color error = Color(0xFFB00020);

  static ThemeData get theme => ThemeData(
        primaryColor: primary,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.light(
          primary: primary,
          secondary: accent,
          surface: surface,
          error: error,
        ),
        textTheme: GoogleFonts.interTextTheme().copyWith(
          displayLarge: GoogleFonts.playfairDisplay(
              fontSize: 32, fontWeight: FontWeight.w700, color: textPrimary),
          displayMedium: GoogleFonts.playfairDisplay(
              fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary),
          titleLarge: GoogleFonts.playfairDisplay(
              fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
          titleMedium: GoogleFonts.playfairDisplay(
              fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
          bodyLarge:
              GoogleFonts.inter(fontSize: 15, color: textPrimary),
          bodyMedium:
              GoogleFonts.inter(fontSize: 14, color: textPrimary),
          bodySmall:
              GoogleFonts.inter(fontSize: 12, color: textSecondary),
          labelLarge: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w600),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: textPrimary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            textStyle:
                GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            side: const BorderSide(color: primary),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          ),
        ),
        cardTheme: CardThemeData(
          color: surface,
          elevation: 3,
          shadowColor: Colors.black.withValues(alpha: 0.08),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: accent, width: 2),
          ),
          labelStyle: GoogleFonts.inter(color: textSecondary, fontSize: 14),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: surface,
          selectedItemColor: accent,
          unselectedItemColor: textSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: background,
          labelStyle:
              GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          side: const BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        ),
        dividerTheme:
            const DividerThemeData(color: border, thickness: 1),
      );
}
