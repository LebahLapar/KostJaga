import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/tenant_auth_provider.dart';
import '../../providers/tenant_provider.dart';
import '../../providers/kost_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../models/models.dart';
import '../../main.dart';
import 'tenant_complaints_screen.dart';
import 'tenant_payments_screen.dart';
import '../auth/tenant_login_screen.dart';
import '../../utils/page_transitions.dart';
import '../../utils/shimmer_loading.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_system.dart';

class TenantHomeScreen extends StatefulWidget {
  const TenantHomeScreen({super.key});

  @override
  State<TenantHomeScreen> createState() => _TenantHomeScreenState();
}

class _TenantHomeScreenState extends State<TenantHomeScreen> {
  Tenant? _currentTenant;
  KostRoom? _currentRoom;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final tenantAuthProvider = context.read<TenantAuthProvider>();
    final tenantId = tenantAuthProvider.tenantId;

    if (tenantId == null) return;

    await Future.wait([
      context.read<TenantProvider>().fetchTenants(),
      context.read<KostProvider>().fetchRooms(),
      context.read<PaymentProvider>().fetchPayments(),
      context.read<ComplaintProvider>().fetchComplaints(),
    ]);

    final tenantProvider = context.read<TenantProvider>();
    final kostProvider = context.read<KostProvider>();

    setState(() {
      _currentTenant = tenantProvider.tenants.firstWhere(
        (t) => t.id == tenantId,
        orElse: () => Tenant(
          id: '',
          name: 'Unknown',
          phone: '',
          email: '',
          roomId: '',
          checkInDate: DateTime.now(),
          status: 'active',
        ),
      );

      if (_currentTenant != null && _currentTenant!.roomId.isNotEmpty) {
        _currentRoom = kostProvider.getRoomById(_currentTenant!.roomId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tenantAuthProvider = context.watch<TenantAuthProvider>();
    final paymentProvider = context.watch<PaymentProvider>();
    final complaintProvider = context.watch<ComplaintProvider>();
    final tenantProvider = context.watch<TenantProvider>();
    final themeProvider = context.watch<ThemeModeProvider>();

    if (tenantProvider.isLoading) {
      return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              ShimmerLoading.tenantInfoCard(),
              ShimmerLoading.statsCards(),
              ShimmerLoading.list(itemCount: 4, itemHeight: 80),
            ],
          ),
        ),
      );
    }

    // Get tenant's data
    final tenantId = tenantAuthProvider.tenantId;
    final myPayments =
        paymentProvider.payments.where((p) => p.tenantId == tenantId).toList();
    final myComplaints = complaintProvider.complaints
        .where((c) => c.tenantId == tenantId)
        .toList();

    final pendingPayments = myPayments
        .where((p) => p.status == 'pending' || p.status == 'overdue')
        .length;
    final pendingComplaints = myComplaints
        .where((c) => c.status == 'pending' || c.status == 'in_progress')
        .length;

    return Scaffold(
      appBar: _buildAppBar(tenantAuthProvider, themeProvider),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              _buildGreeting(tenantAuthProvider),
              const SizedBox(height: Spacing.lg),

              // Room Info
              if (_currentRoom != null) ...[
                const SectionHeader(title: 'Kamar Saya'),
                const SizedBox(height: Spacing.sm),
                _buildRoomCard(),
                const SizedBox(height: Spacing.lg),
              ],

              // Quick Stats
              const SectionHeader(title: 'Ringkasan'),
              const SizedBox(height: Spacing.sm),
              _buildQuickStats(pendingPayments, pendingComplaints),
              const SizedBox(height: Spacing.lg),

              // Menu
              const SectionHeader(title: 'Menu'),
              const SizedBox(height: Spacing.sm),
              _buildMenuItems(pendingPayments, pendingComplaints),
              const SizedBox(height: Spacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    TenantAuthProvider tenantAuthProvider,
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
              Icons.home_rounded,
              color: context.onPrimaryColor,
              size: 18,
            ),
          ),
          const SizedBox(width: Spacing.sm),
          const Text('Portal Penyewa'),
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
              (tenantAuthProvider.tenantName?.isNotEmpty ?? false)
                  ? tenantAuthProvider.tenantName![0].toUpperCase()
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
                    tenantAuthProvider.tenantName ?? 'Penghuni',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  StatusBadge(
                    label: 'Kamar ${tenantAuthProvider.roomNumber ?? tenantAuthProvider.roomCode ?? '-'}',
                    color: context.primaryColor,
                    small: true,
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              onTap: () {
                Future.delayed(Duration.zero, () async {
                  await tenantAuthProvider.logout();
                  if (context.mounted) {
                    AppNavigator.pushAndRemoveAll(
                      context,
                      const TenantLoginScreen(),
                    );
                  }
                });
              },
              child: Row(
                children: [
                  Icon(Icons.logout_rounded, color: context.errorColor, size: 20),
                  const SizedBox(width: Spacing.sm),
                  Text('Keluar', style: TextStyle(color: context.errorColor)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: Spacing.sm),
      ],
    );
  }

  Widget _buildGreeting(TenantAuthProvider tenantAuthProvider) {
    final greeting = GreetingHelper.getGreeting();

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
          tenantAuthProvider.tenantName ?? 'Penghuni',
          style: Theme.of(context).textTheme.displaySmall,
        ),
      ],
    );
  }

  Widget _buildRoomCard() {
    if (_currentRoom == null) return const SizedBox();

    return AppCard(
      onTap: _showRoomDetail,
      padding: const EdgeInsets.all(Spacing.md),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(
                alpha: context.isDarkMode ? 0.2 : 0.1,
              ),
              borderRadius: BorderRadius.circular(Radius.md),
            ),
            child: Icon(
              Icons.meeting_room_rounded,
              color: context.primaryColor,
              size: 32,
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kamar ${_currentRoom!.roomNumber}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  _getRoomTypeText(_currentRoom!.type),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  ).format(_currentRoom!.price),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: context.successColor,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: context.textTertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(int pendingPayments, int pendingComplaints) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            label: 'Tagihan',
            value: '$pendingPayments',
            icon: Icons.receipt_long_rounded,
            color: pendingPayments > 0 ? context.warningColor : context.successColor,
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: StatCard(
            label: 'Keluhan',
            value: '$pendingComplaints',
            icon: Icons.report_rounded,
            color: pendingComplaints > 0 ? context.errorColor : context.successColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItems(int pendingPayments, int pendingComplaints) {
    return Column(
      children: [
        ActionItem(
          title: 'Tagihan Saya',
          subtitle: 'Lihat dan bayar tagihan',
          icon: Icons.payment_rounded,
          iconColor: context.infoColor,
          badge: pendingPayments > 0 ? pendingPayments : null,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TenantPaymentsScreen()),
          ),
        ),
        const SizedBox(height: Spacing.sm),
        ActionItem(
          title: 'Keluhan',
          subtitle: 'Sampaikan keluhan Anda',
          icon: Icons.report_rounded,
          iconColor: context.accentColor,
          badge: pendingComplaints > 0 ? pendingComplaints : null,
          onTap: () => AppNavigator.slideRight(
            context,
            const TenantComplaintsScreen(),
          ),
        ),
        const SizedBox(height: Spacing.sm),
        ActionItem(
          title: 'Info Kamar',
          subtitle: 'Detail kamar Anda',
          icon: Icons.home_rounded,
          iconColor: context.successColor,
          onTap: () {
            if (_currentRoom != null) {
              _showRoomDetail();
            }
          },
        ),
        const SizedBox(height: Spacing.sm),
        ActionItem(
          title: 'Hubungi Pemilik',
          subtitle: 'Kontak pemilik kost',
          icon: Icons.phone_rounded,
          iconColor: context.secondaryColor,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fitur segera hadir')),
            );
          },
        ),
      ],
    );
  }

  String _getRoomTypeText(String type) {
    switch (type) {
      case 'single':
        return 'Kamar Single';
      case 'double':
        return 'Kamar Double';
      case 'shared':
        return 'Kamar Shared';
      default:
        return type;
    }
  }

  void _showRoomDetail() {
    if (_currentRoom == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BottomSheetHandle(),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.primaryColor.withValues(
                      alpha: context.isDarkMode ? 0.2 : 0.1,
                    ),
                    borderRadius: BorderRadius.circular(Radius.md),
                  ),
                  child: Icon(
                    Icons.meeting_room_rounded,
                    color: context.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Text(
                    'Kamar ${_currentRoom!.roomNumber}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                StatusBadge(
                  label: 'Aktif',
                  color: context.successColor,
                ),
              ],
            ),
            const SizedBox(height: Spacing.lg),
            Divider(color: context.dividerColor),
            const SizedBox(height: Spacing.sm),
            InfoRow(
              label: 'Tipe',
              value: _getRoomTypeText(_currentRoom!.type),
              icon: Icons.category_rounded,
            ),
            InfoRow(
              label: 'Harga per Bulan',
              value: NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
                decimalDigits: 0,
              ).format(_currentRoom!.price),
              icon: Icons.payments_rounded,
              valueColor: context.successColor,
            ),
            if (_currentTenant != null)
              InfoRow(
                label: 'Tanggal Masuk',
                value: DateFormat('dd MMMM yyyy').format(_currentTenant!.checkInDate),
                icon: Icons.calendar_today_rounded,
              ),
            if (_currentRoom!.description != null &&
                _currentRoom!.description!.isNotEmpty) ...[
              const SizedBox(height: Spacing.md),
              Text(
                'Deskripsi',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                _currentRoom!.description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: Spacing.lg),
          ],
        ),
      ),
    );
  }
}