import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Design System - Tokens, Components, and Utilities
/// Warm Modern Design for JagaKost

// ============================================
// DESIGN TOKENS
// ============================================

class Spacing {
  Spacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class Radius {
  Radius._();
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double full = 100;
}

class AppShadows {
  AppShadows._();
  
  static List<BoxShadow> get sm => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get md => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get lg => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}

// ============================================
// REUSABLE WIDGETS
// ============================================

/// App Card - Consistent card styling
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final bool hasBorder;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.hasBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? (isDark ? AppColors.darkSurface : AppColors.lightSurface),
        borderRadius: BorderRadius.circular(Radius.lg),
        border: hasBorder 
            ? Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Radius.lg),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(Spacing.md),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Status Badge - For status indicators
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool small;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 12,
        vertical: small ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(small ? 6 : 8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: small ? 12 : 14, color: color),
            SizedBox(width: small ? 4 : 6),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: small ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Stat Card - For displaying statistics
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(Radius.md),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Action Item - For menu items in a list
class ActionItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;
  final Widget? trailing;
  final int? badge;

  const ActionItem({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.iconColor,
    required this.onTap,
    this.trailing,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveIconColor = iconColor ?? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary);
    
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: effectiveIconColor.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(Radius.md),
            ),
            child: Icon(icon, color: effectiveIconColor, size: 22),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          if (badge != null && badge! > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkError : AppColors.lightError,
                borderRadius: BorderRadius.circular(Radius.full),
              ),
              child: Text(
                badge! > 99 ? '99+' : '$badge',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: Spacing.sm),
          ],
          trailing ?? Icon(
            Icons.chevron_right_rounded,
            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
          ),
        ],
      ),
    );
  }
}

/// Section Header - For section titles
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry? padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: Spacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          if (action != null && onAction != null)
            TextButton(
              onPressed: onAction,
              child: Text(action!),
            ),
        ],
      ),
    );
  }
}

/// Info Row - For displaying key-value pairs
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 18,
              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
            ),
            const SizedBox(width: Spacing.sm),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Empty State - For empty lists
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(Spacing.lg),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              ),
            ),
            const SizedBox(height: Spacing.lg),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: Spacing.sm),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: Spacing.lg),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Greeting Helper
class GreetingHelper {
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  static IconData getGreetingIcon() {
    final hour = DateTime.now().hour;
    if (hour < 6 || hour >= 18) return Icons.nights_stay_rounded;
    if (hour < 12) return Icons.wb_sunny_rounded;
    return Icons.wb_sunny_outlined;
  }
}

/// Bottom Sheet Handle
class BottomSheetHandle extends StatelessWidget {
  const BottomSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: Spacing.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

/// Category Helper - for complaints/issues
class CategoryHelper {
  static IconData getIcon(String category) {
    switch (category) {
      case 'maintenance':
        return Icons.build_rounded;
      case 'cleanliness':
        return Icons.cleaning_services_rounded;
      case 'facility':
        return Icons.chair_rounded;
      default:
        return Icons.report_rounded;
    }
  }

  static Color getColor(String category) {
    switch (category) {
      case 'maintenance':
        return AppColors.categoryMaintenance;
      case 'cleanliness':
        return AppColors.categoryCleanliness;
      case 'facility':
        return AppColors.categoryFacility;
      default:
        return AppColors.categoryOther;
    }
  }

  static String getLabel(String category) {
    switch (category) {
      case 'maintenance':
        return 'Perbaikan';
      case 'cleanliness':
        return 'Kebersihan';
      case 'facility':
        return 'Fasilitas';
      case 'other':
        return 'Lainnya';
      default:
        return category;
    }
  }
}

/// Status Helper - for payments/complaints
class StatusHelper {
  static Color getPaymentColor(String status, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (status) {
      case 'pending':
        return isDark ? AppColors.darkWarning : AppColors.lightWarning;
      case 'paid':
        return isDark ? AppColors.darkSuccess : AppColors.lightSuccess;
      case 'overdue':
        return isDark ? AppColors.darkError : AppColors.lightError;
      default:
        return isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    }
  }

  static String getPaymentLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Belum Bayar';
      case 'paid':
        return 'Lunas';
      case 'overdue':
        return 'Terlambat';
      default:
        return status;
    }
  }

  static Color getComplaintColor(String status, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (status) {
      case 'pending':
        return isDark ? AppColors.darkWarning : AppColors.lightWarning;
      case 'in_progress':
        return isDark ? AppColors.darkInfo : AppColors.lightInfo;
      case 'resolved':
        return isDark ? AppColors.darkSuccess : AppColors.lightSuccess;
      default:
        return isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    }
  }

  static String getComplaintLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'in_progress':
        return 'Diproses';
      case 'resolved':
        return 'Selesai';
      default:
        return status;
    }
  }
}
