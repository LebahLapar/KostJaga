import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// App Theme Configuration - Warm Modern Style
class AppTheme {
  AppTheme._();

  // ============================================
  // LIGHT THEME
  // ============================================
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightPrimary,
      onPrimary: AppColors.lightOnPrimary,
      primaryContainer: AppColors.lightPrimaryLight,
      secondary: AppColors.lightSecondary,
      onSecondary: AppColors.lightOnSecondary,
      tertiary: AppColors.lightAccent,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightTextPrimary,
      surfaceContainerHighest: AppColors.lightSurfaceVariant,
      error: AppColors.lightError,
      outline: AppColors.lightBorder,
    ),
    
    // Background
    scaffoldBackgroundColor: AppColors.lightBackground,
    
    // Typography
    textTheme: _buildTextTheme(Brightness.light),
    
    // AppBar
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      backgroundColor: AppColors.lightBackground,
      foregroundColor: AppColors.lightTextPrimary,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.lightTextPrimary,
      ),
    ),
    
    // Card
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.lightBorder, width: 1),
      ),
      color: AppColors.lightSurface,
      margin: EdgeInsets.zero,
    ),
    
    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: AppColors.lightOnPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.lightPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: const BorderSide(color: AppColors.lightPrimary, width: 1.5),
        textStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.lightPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Floating Action Button
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 2,
      backgroundColor: AppColors.lightPrimary,
      foregroundColor: AppColors.lightOnPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurfaceVariant,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightError, width: 1),
      ),
      hintStyle: GoogleFonts.inter(
        color: AppColors.lightTextTertiary,
        fontSize: 14,
      ),
      labelStyle: GoogleFonts.inter(
        color: AppColors.lightTextSecondary,
        fontSize: 14,
      ),
    ),
    
    // Bottom Navigation
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightSurface,
      selectedItemColor: AppColors.lightPrimary,
      unselectedItemColor: AppColors.lightTextTertiary,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    
    // Bottom Sheet
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    
    // Divider
    dividerTheme: const DividerThemeData(
      color: AppColors.lightDivider,
      thickness: 1,
      space: 1,
    ),
    
    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.lightSurfaceVariant,
      labelStyle: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      side: BorderSide.none,
    ),
    
    // Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    
    // Snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.lightTextPrimary,
      contentTextStyle: GoogleFonts.inter(
        color: AppColors.lightSurface,
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    
    // List Tile
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),
    
    // Icon
    iconTheme: const IconThemeData(
      color: AppColors.lightTextSecondary,
      size: 24,
    ),
    
    // PopupMenu
    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
    ),
  );

  // ============================================
  // DARK THEME
  // ============================================
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    // Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      onPrimary: AppColors.darkOnPrimary,
      primaryContainer: AppColors.darkPrimaryDark,
      secondary: AppColors.darkSecondary,
      onSecondary: AppColors.darkOnSecondary,
      tertiary: AppColors.darkAccent,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      surfaceContainerHighest: AppColors.darkSurfaceVariant,
      error: AppColors.darkError,
      outline: AppColors.darkBorder,
    ),
    
    // Background
    scaffoldBackgroundColor: AppColors.darkBackground,
    
    // Typography
    textTheme: _buildTextTheme(Brightness.dark),
    
    // AppBar
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.darkTextPrimary,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.darkTextPrimary,
      ),
    ),
    
    // Card
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.darkBorder, width: 1),
      ),
      color: AppColors.darkSurface,
      margin: EdgeInsets.zero,
    ),
    
    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: AppColors.darkOnPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.darkPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: const BorderSide(color: AppColors.darkPrimary, width: 1.5),
        textStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.darkPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Floating Action Button
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 0,
      backgroundColor: AppColors.darkPrimary,
      foregroundColor: AppColors.darkOnPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurfaceVariant,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkError, width: 1),
      ),
      hintStyle: GoogleFonts.inter(
        color: AppColors.darkTextTertiary,
        fontSize: 14,
      ),
      labelStyle: GoogleFonts.inter(
        color: AppColors.darkTextSecondary,
        fontSize: 14,
      ),
    ),
    
    // Bottom Navigation
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.darkPrimary,
      unselectedItemColor: AppColors.darkTextTertiary,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    
    // Bottom Sheet
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    
    // Divider
    dividerTheme: const DividerThemeData(
      color: AppColors.darkDivider,
      thickness: 1,
      space: 1,
    ),
    
    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkSurfaceVariant,
      labelStyle: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.darkTextPrimary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      side: BorderSide.none,
    ),
    
    // Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    
    // Snackbar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.darkSurfaceElevated,
      contentTextStyle: GoogleFonts.inter(
        color: AppColors.darkTextPrimary,
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    
    // List Tile
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),
    
    // Icon
    iconTheme: const IconThemeData(
      color: AppColors.darkTextSecondary,
      size: 24,
    ),
    
    // PopupMenu
    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.darkSurfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0,
    ),
  );

  // ============================================
  // TEXT THEME
  // ============================================
  static TextTheme _buildTextTheme(Brightness brightness) {
    final Color textPrimary = brightness == Brightness.dark 
        ? AppColors.darkTextPrimary 
        : AppColors.lightTextPrimary;
    final Color textSecondary = brightness == Brightness.dark 
        ? AppColors.darkTextSecondary 
        : AppColors.lightTextSecondary;

    return TextTheme(
      // Display
      displayLarge: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: textPrimary,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textPrimary,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      
      // Headline
      headlineLarge: GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      headlineSmall: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      
      // Title
      titleLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      
      // Body
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: textPrimary,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.normal,
        color: textSecondary,
      ),
      
      // Label
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }
}
