import 'package:flutter/material.dart';

/// App color definitions for JagaKost - Warm Modern Theme
/// Inspired by Airbnb warmth + Linear elegance
class AppColors {
  AppColors._();

  // ============================================
  // LIGHT MODE COLORS
  // ============================================
  
  // Background & Surface
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF5F5F5);
  
  // Primary - Forest Green (Trust, Home, Natural)
  static const Color lightPrimary = Color(0xFF2D5A3D);
  static const Color lightPrimaryLight = Color(0xFF4A7C5C);
  static const Color lightPrimaryDark = Color(0xFF1E3D29);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  
  // Secondary - Warm Tan (Homey, Comfortable)
  static const Color lightSecondary = Color(0xFFD4A574);
  static const Color lightSecondaryLight = Color(0xFFE8C9A8);
  static const Color lightSecondaryDark = Color(0xFFB8864E);
  static const Color lightOnSecondary = Color(0xFF1A1A1A);
  
  // Accent - Terracotta (Indonesian Warmth)
  static const Color lightAccent = Color(0xFFE8725A);
  static const Color lightAccentLight = Color(0xFFF09B89);
  static const Color lightAccentDark = Color(0xFFC5513A);
  
  // Text Colors
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTextTertiary = Color(0xFF9CA3AF);
  static const Color lightTextDisabled = Color(0xFFD1D5DB);
  
  // Border & Divider
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightDivider = Color(0xFFF3F4F6);
  
  // Status Colors
  static const Color lightSuccess = Color(0xFF059669);
  static const Color lightSuccessLight = Color(0xFFD1FAE5);
  static const Color lightWarning = Color(0xFFD97706);
  static const Color lightWarningLight = Color(0xFFFEF3C7);
  static const Color lightError = Color(0xFFDC2626);
  static const Color lightErrorLight = Color(0xFFFEE2E2);
  static const Color lightInfo = Color(0xFF0284C7);
  static const Color lightInfoLight = Color(0xFFE0F2FE);

  // ============================================
  // DARK MODE COLORS
  // ============================================
  
  // Background & Surface
  static const Color darkBackground = Color(0xFF0F0F0F);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkSurfaceVariant = Color(0xFF252525);
  static const Color darkSurfaceElevated = Color(0xFF2A2A2A);
  
  // Primary - Mint (Fresh, visible in dark)
  static const Color darkPrimary = Color(0xFF4ADE80);
  static const Color darkPrimaryLight = Color(0xFF86EFAC);
  static const Color darkPrimaryDark = Color(0xFF22C55E);
  static const Color darkOnPrimary = Color(0xFF0F0F0F);
  
  // Secondary - Warm Gold
  static const Color darkSecondary = Color(0xFFFBBF24);
  static const Color darkSecondaryLight = Color(0xFFFCD34D);
  static const Color darkSecondaryDark = Color(0xFFF59E0B);
  static const Color darkOnSecondary = Color(0xFF0F0F0F);
  
  // Accent - Bright Terracotta
  static const Color darkAccent = Color(0xFFFB923C);
  static const Color darkAccentLight = Color(0xFFFDBA74);
  static const Color darkAccentDark = Color(0xFFF97316);
  
  // Text Colors
  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkTextTertiary = Color(0xFF6B7280);
  static const Color darkTextDisabled = Color(0xFF4B5563);
  
  // Border & Divider
  static const Color darkBorder = Color(0xFF374151);
  static const Color darkDivider = Color(0xFF2D2D2D);
  
  // Status Colors (slightly adjusted for dark)
  static const Color darkSuccess = Color(0xFF10B981);
  static const Color darkSuccessLight = Color(0xFF064E3B);
  static const Color darkWarning = Color(0xFFFBBF24);
  static const Color darkWarningLight = Color(0xFF78350F);
  static const Color darkError = Color(0xFFEF4444);
  static const Color darkErrorLight = Color(0xFF7F1D1D);
  static const Color darkInfo = Color(0xFF38BDF8);
  static const Color darkInfoLight = Color(0xFF0C4A6E);

  // ============================================
  // CATEGORY COLORS (same for both modes)
  // ============================================
  static const Color categoryMaintenance = Color(0xFFEA580C);
  static const Color categoryCleanliness = Color(0xFF0891B2);
  static const Color categoryFacility = Color(0xFF7C3AED);
  static const Color categoryOther = Color(0xFF64748B);

  // Room Status Colors
  static const Color roomAvailable = Color(0xFF059669);
  static const Color roomOccupied = Color(0xFF0284C7);
  static const Color roomMaintenance = Color(0xFFDC2626);
}

/// Extension to easily access colors based on current theme
extension AppColorsExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  
  // Background
  Color get backgroundColor => isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;
  Color get surfaceColor => isDarkMode ? AppColors.darkSurface : AppColors.lightSurface;
  Color get surfaceVariant => isDarkMode ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant;
  
  // Primary
  Color get primaryColor => isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary;
  Color get primaryLightColor => isDarkMode ? AppColors.darkPrimaryLight : AppColors.lightPrimaryLight;
  Color get onPrimaryColor => isDarkMode ? AppColors.darkOnPrimary : AppColors.lightOnPrimary;
  
  // Secondary
  Color get secondaryColor => isDarkMode ? AppColors.darkSecondary : AppColors.lightSecondary;
  
  // Accent
  Color get accentColor => isDarkMode ? AppColors.darkAccent : AppColors.lightAccent;
  
  // Text
  Color get textPrimary => isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  Color get textSecondary => isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get textTertiary => isDarkMode ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;
  
  // Border
  Color get borderColor => isDarkMode ? AppColors.darkBorder : AppColors.lightBorder;
  Color get dividerColor => isDarkMode ? AppColors.darkDivider : AppColors.lightDivider;
  
  // Status
  Color get successColor => isDarkMode ? AppColors.darkSuccess : AppColors.lightSuccess;
  Color get successLightColor => isDarkMode ? AppColors.darkSuccessLight : AppColors.lightSuccessLight;
  Color get warningColor => isDarkMode ? AppColors.darkWarning : AppColors.lightWarning;
  Color get warningLightColor => isDarkMode ? AppColors.darkWarningLight : AppColors.lightWarningLight;
  Color get errorColor => isDarkMode ? AppColors.darkError : AppColors.lightError;
  Color get errorLightColor => isDarkMode ? AppColors.darkErrorLight : AppColors.lightErrorLight;
  Color get infoColor => isDarkMode ? AppColors.darkInfo : AppColors.lightInfo;
  Color get infoLightColor => isDarkMode ? AppColors.darkInfoLight : AppColors.lightInfoLight;
}
