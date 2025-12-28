import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class NothingTheme {
  // Brand Colors
  static const Color nothingRed = Color(0xFFD71920);
  static const Color nothingBlack = Color(0xFF000000);
  static const Color nothingWhite = Color(0xFFFFFFFF);

  // Surface Colors
  static const Color darkSurface = Color(0xFF121212); // Deep grey/almost black
  static const Color lightSurface = Color(0xFFF2F2F2); // Very light grey

  static TextTheme _buildTextTheme(TextTheme base, Color color) {
    // Apply DotGothic16 to everything to ensure visibility of the "Nothing" style,
    // as requested by the user. If they want legibility, we can revert body to Inter.
    // Given "font is not correctly visible", applying it globally helps debug if it's a mapping issue.
    return GoogleFonts.dotGothic16TextTheme(
      base,
    ).apply(bodyColor: color, displayColor: color);
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: nothingBlack,
      scaffoldBackgroundColor: nothingWhite,
      colorScheme: const ColorScheme.light(
        primary: nothingBlack,
        secondary: nothingRed,
        surface: nothingWhite,
        background: nothingWhite,
        error: nothingRed,
        onPrimary: nothingWhite,
        onSecondary: nothingWhite,
        onSurface: nothingBlack,
        onBackground: nothingBlack,
      ),

      // Typrography
      textTheme: _buildTextTheme(ThemeData.light().textTheme, nothingBlack),

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: nothingWhite,
        foregroundColor: nothingBlack,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.dotGothic16(
          color: nothingBlack,
          fontSize: 24,
          fontWeight: FontWeight.w900, // Thick headers
          letterSpacing: -0.5,
        ),
        iconTheme: const IconThemeData(color: nothingBlack),
      ),

      // Tab Bar
      tabBarTheme: TabBarThemeData(
        labelColor: nothingRed,
        unselectedLabelColor: Colors.grey,
        indicatorColor: nothingRed,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.dotGothic16(fontWeight: FontWeight.bold),
      ),

      // Card
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide.none,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        activeIndicatorBorder: const BorderSide(color: nothingRed),
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: nothingRed,
        foregroundColor: nothingWhite,
        shape: CircleBorder(),
      ),

      iconTheme: const IconThemeData(color: nothingBlack),
      listTileTheme: const ListTileThemeData(
        iconColor: nothingBlack,
        textColor: nothingBlack,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: nothingWhite,
      scaffoldBackgroundColor: nothingBlack,
      colorScheme: const ColorScheme.dark(
        primary: nothingWhite,
        secondary: nothingRed,
        surface: darkSurface,
        background: nothingBlack,
        error: nothingRed,
        onPrimary: nothingBlack,
        onSecondary: nothingWhite,
        onSurface: nothingWhite,
        onBackground: nothingWhite,
      ),

      // Typography
      textTheme: _buildTextTheme(ThemeData.dark().textTheme, nothingWhite),

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: nothingBlack,
        foregroundColor: nothingWhite,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.dotGothic16(
          color: nothingWhite,
          fontSize: 24,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
        iconTheme: const IconThemeData(color: nothingWhite),
      ),

      // Tab Bar
      tabBarTheme: TabBarThemeData(
        labelColor: nothingRed,
        unselectedLabelColor: Colors.grey,
        indicatorColor: nothingRed,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.dotGothic16(fontWeight: FontWeight.bold),
      ),

      // Card
      cardTheme: CardThemeData(
        color: darkSurface, // distinct from background
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: Color(0xFF333333),
            width: 1,
          ), // Subtle border
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        activeIndicatorBorder: const BorderSide(color: nothingRed),
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: nothingRed,
        foregroundColor: nothingWhite,
        shape: CircleBorder(),
      ),

      iconTheme: const IconThemeData(color: nothingWhite),
      listTileTheme: const ListTileThemeData(
        iconColor: nothingWhite,
        textColor: nothingWhite,
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkSurface,
        modalBackgroundColor: darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
