import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Corporate palette — brand burgundy #6E1D2E
class AppTheme {
  static const Color primary = Color(0xFF6E1D2E);
  static const Color primaryDark = Color(0xFF4A1420);
  static const Color primaryLight = Color(0x1A6E1D2E);
  /// Restrained metallic accent (secondary CTAs / highlights)
  static const Color accent = Color(0xFF9A7B4F);
  static const Color accentLight = Color(0xFFB8976A);
  static const Color background = Color(0xFFF4F6F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFAFBFC);
  static const Color textPrimary = Color(0xFF1A1D24);
  static const Color textSecondary = Color(0xFF5C6370);
  static const Color border = Color(0xFFE2E5EB);
  static const Color success = Color(0xFF1D6F4A);
  static const Color warning = Color(0xFFB86E0A);
  static const Color error = Color(0xFFB42318);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        primaryColor: primary,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.light(
          primary: primary,
          onPrimary: Colors.white,
          secondary: accent,
          onSecondary: Colors.white,
          surface: surface,
          onSurface: textPrimary,
          error: error,
          onError: Colors.white,
          outline: border,
          surfaceContainerHighest: surfaceElevated,
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
          displayLarge: GoogleFonts.sourceSerif4(
              fontSize: 32, fontWeight: FontWeight.w600, color: textPrimary, height: 1.2),
          displayMedium: GoogleFonts.sourceSerif4(
              fontSize: 26, fontWeight: FontWeight.w600, color: textPrimary, height: 1.25),
          titleLarge: GoogleFonts.sourceSerif4(
              fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
          titleMedium: GoogleFonts.sourceSerif4(
              fontSize: 17, fontWeight: FontWeight.w600, color: textPrimary),
          bodyLarge:
              GoogleFonts.plusJakartaSans(fontSize: 15, color: textPrimary, height: 1.45),
          bodyMedium:
              GoogleFonts.plusJakartaSans(fontSize: 14, color: textPrimary, height: 1.45),
          bodySmall:
              GoogleFonts.plusJakartaSans(fontSize: 12, color: textSecondary, height: 1.4),
          labelLarge: GoogleFonts.plusJakartaSans(
              fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            textStyle:
                GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            side: const BorderSide(color: primary, width: 1.25),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: primary),
        ),
        cardTheme: CardThemeData(
          color: surface,
          elevation: 0,
          shadowColor: Colors.black.withValues(alpha: 0.06),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: border),
          ),
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
            borderSide: const BorderSide(color: primary, width: 1.5),
          ),
          labelStyle: GoogleFonts.plusJakartaSans(color: textSecondary, fontSize: 14),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: surface,
          foregroundColor: textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
          titleTextStyle: GoogleFonts.sourceSerif4(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textPrimary),
          iconTheme: const IconThemeData(color: textPrimary),
          shape: const Border(
            bottom: BorderSide(color: border),
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: surface,
          selectedItemColor: primary,
          unselectedItemColor: textSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          selectedLabelStyle:
              GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 11),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: surfaceElevated,
          labelStyle:
              GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: const BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        ),
        dividerTheme:
            const DividerThemeData(color: border, thickness: 1),
        navigationRailTheme: NavigationRailThemeData(
          backgroundColor: primary,
          selectedIconTheme: const IconThemeData(color: accentLight),
          unselectedIconTheme: IconThemeData(color: Colors.white.withValues(alpha: 0.6)),
          selectedLabelTextStyle: GoogleFonts.plusJakartaSans(
              color: accentLight, fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelTextStyle: GoogleFonts.plusJakartaSans(
              color: Colors.white70, fontSize: 11),
        ),
      );
}
