import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/kost_provider.dart';
import '../providers/tenant_provider.dart';
import '../providers/payment_provider.dart';
import '../main.dart';
import 'rooms/rooms_screen.dart';
import 'tenants/tenants_screen.dart';
import 'payments/payments_screen.dart';
import 'complaints/complaints_screen.dart';
import 'auth/login_screen.dart';
import '../theme/app_colors.dart';
import '../theme/design_system.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      context.read<KostProvider>().fetchRooms(),
      context.read<TenantProvider>().fetchTenants(),
      context.read<PaymentProvider>().fetchPayments(),
    ]);
  }

  void _handleLogout() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.signOut();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final kostProvider = context.watch<KostProvider>();
    final paymentProvider = context.watch<PaymentProvider>();
    final themeProvider = context.watch<ThemeModeProvider>();

    return Scaffold(
      appBar: _buildAppBar(authProvider, themeProvider),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Section
              _buildGreeting(authProvider),
              const SizedBox(height: Spacing.lg),

              // Stats Section
              const SectionHeader(title: 'Ringkasan'),
              const SizedBox(height: Spacing.sm),
              _buildStatsGrid(kostProvider),
              const SizedBox(height: Spacing.lg),

              // Payment Summary
              const SectionHeader(title: 'Status Pembayaran'),
              const SizedBox(height: Spacing.sm),
              _buildPaymentSummary(paymentProvider),
              const SizedBox(height: Spacing.lg),

              // Quick Actions
              const SectionHeader(title: 'Menu'),
              const SizedBox(height: Spacing.sm),
              _buildQuickActions(paymentProvider),
              const SizedBox(height: Spacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    AuthProvider authProvider,
    ThemeModeProvider themeProvider,
  ) {
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.primaryColor,
              borderRadius: BorderRadius.circular(Radius.sm),
            ),
            child: Icon(
              Icons.home_work_rounded,
              color: context.onPrimaryColor,
              size: 18,
            ),
          ),
          const SizedBox(width: Spacing.sm),
          const Text('JagaKost'),
        ],
      ),
      actions: [
        // Theme Toggle
        IconButton(
          icon: Icon(
            themeProvider.isDarkMode
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
          ),
          onPressed: () => themeProvider.toggleTheme(),
        ),
        // Profile Menu
        PopupMenuButton<String>(
          icon: CircleAvatar(
            radius: 16,
            backgroundColor: context.primaryColor,
            child: Text(
              (authProvider.user?.email?.isNotEmpty ?? false)
                  ? authProvider.user!.email![0].toUpperCase()
                  : '?',
              style: TextStyle(
                color: context.onPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              enabled: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pemilik Kost',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    authProvider.user?.email ?? '',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              onTap: () => Future.delayed(Duration.zero, _handleLogout),
              child: Row(
                children: [
                  Icon(Icons.logout_rounded,
                      color: context.errorColor, size: 20),
                  const SizedBox(width: Spacing.sm),
                  Text(
                    'Keluar',
                    style: TextStyle(color: context.errorColor),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: Spacing.sm),
      ],
    );
  }

  Widget _buildGreeting(AuthProvider authProvider) {
    final greeting = GreetingHelper.getGreeting();
    final date =
        DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              GreetingHelper.getGreetingIcon(),
              color: context.secondaryColor,
              size: 20,
            ),
            const SizedBox(width: Spacing.sm),
            Text(
              greeting,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.textSecondary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          'Dashboard',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          date,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildStatsGrid(KostProvider kostProvider) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCardHorizontal(
                'Total Kamar',
                '${kostProvider.rooms.length}',
                Icons.meeting_room_rounded,
                context.infoColor,
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: _buildStatCardHorizontal(
                'Kamar Terisi',
                '${kostProvider.occupiedRooms}',
                Icons.home_rounded,
                context.successColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        Row(
          children: [
            Expanded(
              child: _buildStatCardHorizontal(
                'Kamar Kosong',
                '${kostProvider.availableRooms}',
                Icons.home_outlined,
                context.warningColor,
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: _buildStatCardHorizontal(
                'Maintenance',
                '${kostProvider.maintenanceRooms}',
                Icons.construction_rounded,
                context.errorColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCardHorizontal(
      String label, String value, IconData icon, Color color) {
    return AppCard(
      padding: const EdgeInsets.all(Spacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: context.isDarkMode ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(Radius.md),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(PaymentProvider paymentProvider) {
    return Row(
      children: [
        Expanded(
          child: _buildPaymentCard(
            'Pending',
            paymentProvider.pendingPayments,
            context.warningColor,
            Icons.schedule_rounded,
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: _buildPaymentCard(
            'Terlambat',
            paymentProvider.overduePayments,
            context.errorColor,
            Icons.warning_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentCard(
      String title, int count, Color color, IconData icon) {
    return AppCard(
      padding: const EdgeInsets.all(Spacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: context.isDarkMode ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(Radius.md),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(PaymentProvider paymentProvider) {
    return Column(
      children: [
        ActionItem(
          title: 'Kelola Kamar',
          subtitle: 'Lihat dan atur kamar kost',
          icon: Icons.meeting_room_rounded,
          iconColor: context.infoColor,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RoomsScreen()),
          ),
        ),
        const SizedBox(height: Spacing.sm),
        ActionItem(
          title: 'Kelola Penyewa',
          subtitle: 'Daftar penghuni kost',
          icon: Icons.people_rounded,
          iconColor: context.successColor,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TenantsScreen()),
          ),
        ),
        const SizedBox(height: Spacing.sm),
        ActionItem(
          title: 'Pembayaran',
          subtitle: 'Tagihan dan riwayat pembayaran',
          icon: Icons.payment_rounded,
          iconColor: context.warningColor,
          badge: paymentProvider.pendingPayments > 0
              ? paymentProvider.pendingPayments
              : null,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PaymentsScreen()),
          ),
        ),
        const SizedBox(height: Spacing.sm),
        ActionItem(
          title: 'Keluhan',
          subtitle: 'Laporan dari penghuni',
          icon: Icons.report_rounded,
          iconColor: context.accentColor,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ComplaintsScreen()),
          ),
        ),
      ],
    );
  }
}
