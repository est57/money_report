import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(
    0xFF00695C,
  ); // Teal 800 - Darker for contrast
  static const Color secondaryColor = Color(0xFF00796B); // Teal 700
  static const Color accentColor = Color(0xFFFFCA28); // Amber 400
  static const Color expenseColor = Color(0xFFE53935); // Red 600
  static const Color incomeColor = Color(0xFF43A047); // Green 600
  static const Color backgroundColor = Color(0xFFF0F2F5); // Light Blue Grey
  static const Color surfaceColor = Colors.white;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00695C), Color(0xFF4DB6AC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [
      Colors.white,
      Colors.white,
    ], // Placeholder if we want subtle gradient on cards
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.grey.withOpacity(0.1),
      blurRadius: 10,
      offset: const Offset(0, 5),
    ),
  ];

  static const Color darkPrimaryColor = Color(
    0xFF80CBC4,
  ); // Teal 200 - Lighter for Dark Mode
  static const Color darkBackgroundColor = Color(
    0xFF121212,
  ); // Material Dark Background
  static const Color darkSurfaceColor = Color(
    0xFF1E1E1E,
  ); // Material Dark Surface

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceColor,
        background: backgroundColor,
      ),
      useMaterial3: true,
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: const Color(0xFF263238),
        displayColor: const Color(0xFF263238),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors
            .transparent, // For glassmorphism effect later or just clean look
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          color: primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0, // We will use custom shadows
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey.shade400,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: darkPrimaryColor,
      scaffoldBackgroundColor: darkBackgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: darkPrimaryColor,
        brightness: Brightness.dark,
        primary: darkPrimaryColor,
        secondary: accentColor,
        surface: darkSurfaceColor,
        background: darkBackgroundColor,
      ),
      useMaterial3: true,
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.dark().textTheme,
      ).apply(bodyColor: Colors.grey.shade300, displayColor: Colors.white),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: darkPrimaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.white.withOpacity(0.05),
          ), // Subtle border
        ),
        margin: EdgeInsets.zero,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkPrimaryColor,
        foregroundColor: Colors.black, // Dark text on light primary
        elevation: 4,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurfaceColor,
        selectedItemColor: darkPrimaryColor,
        unselectedItemColor: Colors.grey,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}
