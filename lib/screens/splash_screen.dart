import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth/login_screen.dart';
import 'auth/tenant_login_screen.dart';
import '../main.dart';
import '../theme/app_colors.dart';
import '../theme/design_system.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeModeProvider>();

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Column(
              children: [
                // Theme Toggle (Top Right)
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () => themeProvider.toggleTheme(),
                    icon: Icon(
                      themeProvider.isDarkMode
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      color: context.textSecondary,
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Logo & Title Section
                _buildLogoSection(),

                const Spacer(flex: 1),

                // Role Selection Cards
                _buildRoleCards(),

                const Spacer(flex: 1),

                // Footer
                _buildFooter(),

                const SizedBox(height: Spacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        // Logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: context.primaryColor,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: context.primaryColor.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.home_work_rounded,
            size: 50,
            color: context.onPrimaryColor,
          ),
        ),
        const SizedBox(height: Spacing.lg),

        // App Name
        Text(
          'JagaKost',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: context.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: Spacing.xs),

        // Tagline
        Text(
          'Kelola kost dengan mudah',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: context.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Title
        Text(
          'Masuk sebagai',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: context.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Spacing.lg),

        // Owner Card
        _RoleCard(
          icon: Icons.business_center_rounded,
          iconColor: context.primaryColor,
          title: 'Pemilik Kost',
          subtitle: 'Kelola kamar, penyewa & pembayaran',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
        ),
        const SizedBox(height: Spacing.md),

        // Tenant Card
        _RoleCard(
          icon: Icons.person_rounded,
          iconColor: context.secondaryColor,
          title: 'Penyewa Kost',
          subtitle: 'Lihat tagihan & buat keluhan',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TenantLoginScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Versi 1.0.0',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: context.textTertiary,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          '© 2025 JagaKost',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: context.textTertiary,
          ),
        ),
      ],
    );
  }
}

/// Role Selection Card Widget
class _RoleCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(Spacing.md),
      child: Row(
        children: [
          // Icon Container
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconColor.withValues(
                alpha: context.isDarkMode ? 0.2 : 0.1,
              ),
              borderRadius: BorderRadius.circular(Radius.md),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
          ),
          const SizedBox(width: Spacing.md),

          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // Arrow
          Icon(
            Icons.chevron_right_rounded,
            color: context.textTertiary,
          ),
        ],
      ),
    );
  }
}