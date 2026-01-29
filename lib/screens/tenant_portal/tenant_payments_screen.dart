import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/tenant_auth_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/kost_provider.dart';
import '../../models/models.dart';
import '../../utils/shimmer_loading.dart';
import '../../utils/empty_state_widget.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_system.dart';

class TenantPaymentsScreen extends StatefulWidget {
  const TenantPaymentsScreen({super.key});

  @override
  State<TenantPaymentsScreen> createState() => _TenantPaymentsScreenState();
}

class _TenantPaymentsScreenState extends State<TenantPaymentsScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().fetchPayments();
      context.read<KostProvider>().fetchRooms();
    });
  }

  List<Payment> _getFilteredPayments(List<Payment> payments, String? tenantId) {
    if (tenantId == null) return [];

    var filtered = payments.where((p) => p.tenantId == tenantId).toList();

    if (_selectedFilter == 'all') return filtered;
    return filtered.where((p) => p.status == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tagihan Saya'),
      ),
      body: Consumer2<PaymentProvider, TenantAuthProvider>(
        builder: (context, paymentProvider, tenantAuthProvider, child) {
          if (paymentProvider.isLoading) {
            return Column(
              children: [
                ShimmerLoading.statsCards(),
                Expanded(
                  child: ListView.builder(
                    itemCount: 4,
                    itemBuilder: (context, index) =>
                        ShimmerLoading.paymentCard(),
                  ),
                ),
              ],
            );
          }

          final tenantId = tenantAuthProvider.tenantId;
          final filteredPayments = _getFilteredPayments(
            paymentProvider.payments,
            tenantId,
          );

          if (filteredPayments.isEmpty) {
            if (_selectedFilter != 'all') {
              return EmptyStateWidget.noFilterResults(
                filterName: StatusHelper.getPaymentLabel(_selectedFilter),
                onClearFilter: () => setState(() => _selectedFilter = 'all'),
              );
            }
            return EmptyStateWidget.noPayments();
          }

          // Calculate summary
          final allMyPayments = paymentProvider.payments
              .where((p) => p.tenantId == tenantId)
              .toList();
          final pendingCount =
              allMyPayments.where((p) => p.status == 'pending').length;
          final paidCount =
              allMyPayments.where((p) => p.status == 'paid').length;
          final overdueCount =
              allMyPayments.where((p) => p.status == 'overdue').length;

          return Column(
            children: [
              // Filter Chips
              _buildFilterChips(pendingCount, paidCount, overdueCount),

              // Payment List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await context.read<PaymentProvider>().fetchPayments();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(Spacing.md),
                    itemCount: filteredPayments.length,
                    itemBuilder: (context, index) {
                      final payment = filteredPayments[index];
                      return _buildPaymentCard(payment);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChips(int pending, int paid, int overdue) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm,
      ),
      child: Row(
        children: [
          _buildFilterChip('all', 'Semua', null),
          const SizedBox(width: Spacing.sm),
          _buildFilterChip('pending', 'Pending', pending),
          const SizedBox(width: Spacing.sm),
          _buildFilterChip('paid', 'Lunas', paid),
          const SizedBox(width: Spacing.sm),
          _buildFilterChip('overdue', 'Terlambat', overdue),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, int? count) {
    final isSelected = _selectedFilter == value;

    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count != null && count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? context.onPrimaryColor.withValues(alpha: 0.2)
                    : context.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? context.onPrimaryColor : context.primaryColor,
                ),
              ),
            ),
          ],
        ],
      ),
      selectedColor: context.primaryColor,
      checkmarkColor: context.onPrimaryColor,
      labelStyle: TextStyle(
        color: isSelected ? context.onPrimaryColor : context.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      onSelected: (selected) {
        setState(() => _selectedFilter = value);
      },
    );
  }

  Widget _buildPaymentCard(Payment payment) {
    final kostProvider = context.read<KostProvider>();
    final room = kostProvider.getRoomById(payment.roomId);
    final statusColor = StatusHelper.getPaymentColor(payment.status, context);
    final statusLabel = StatusHelper.getPaymentLabel(payment.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: AppCard(
        onTap: () => _showPaymentDetail(payment, room),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(
                      alpha: context.isDarkMode ? 0.2 : 0.1,
                    ),
                    borderRadius: BorderRadius.circular(Radius.md),
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: statusColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kamar ${room?.roomNumber ?? payment.roomId}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        ).format(payment.amount),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: context.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(
                  label: statusLabel,
                  color: statusColor,
                ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Divider(color: context.dividerColor, height: 1),
            const SizedBox(height: Spacing.sm),
            Row(
              children: [
                Icon(
                  Icons.event_rounded,
                  size: 16,
                  color: context.textTertiary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Jatuh tempo: ${DateFormat('dd MMM yyyy').format(payment.dueDate)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (payment.status == 'overdue') ...[
                  const SizedBox(width: Spacing.sm),
                  StatusBadge(
                    label: '${_getDaysOverdue(payment.dueDate)} hari',
                    color: context.errorColor,
                    small: true,
                  ),
                ],
              ],
            ),
            if (payment.paidDate != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: context.successColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Dibayar: ${DateFormat('dd MMM yyyy').format(payment.paidDate!)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.successColor,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showPaymentDetail(Payment payment, KostRoom? room) {
    final statusColor = StatusHelper.getPaymentColor(payment.status, context);
    final statusLabel = StatusHelper.getPaymentLabel(payment.status);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BottomSheetHandle(),

                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(
                          alpha: context.isDarkMode ? 0.2 : 0.1,
                        ),
                        borderRadius: BorderRadius.circular(Radius.md),
                      ),
                      child: Icon(
                        Icons.receipt_long_rounded,
                        color: statusColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detail Pembayaran',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          StatusBadge(
                            label: statusLabel,
                            color: statusColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.lg),
                Divider(color: context.dividerColor),
                const SizedBox(height: Spacing.sm),

                // Details
                InfoRow(
                  label: 'Kamar',
                  value: 'Kamar ${room?.roomNumber ?? payment.roomId}',
                  icon: Icons.meeting_room_rounded,
                ),
                InfoRow(
                  label: 'Jumlah',
                  value: NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  ).format(payment.amount),
                  icon: Icons.payments_rounded,
                  valueColor: context.primaryColor,
                ),
                InfoRow(
                  label: 'Jatuh Tempo',
                  value: DateFormat('dd MMMM yyyy').format(payment.dueDate),
                  icon: Icons.event_rounded,
                ),
                if (payment.paidDate != null)
                  InfoRow(
                    label: 'Tanggal Bayar',
                    value: DateFormat('dd MMMM yyyy').format(payment.paidDate!),
                    icon: Icons.check_circle_rounded,
                    valueColor: context.successColor,
                  ),
                if (payment.status == 'overdue')
                  InfoRow(
                    label: 'Keterlambatan',
                    value: '${_getDaysOverdue(payment.dueDate)} hari',
                    icon: Icons.warning_rounded,
                    valueColor: context.errorColor,
                  ),

                if (payment.notes != null && payment.notes!.isNotEmpty) ...[
                  const SizedBox(height: Spacing.md),
                  Text(
                    'Catatan',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    payment.notes!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ],

                // Info box for pending
                if (payment.status == 'pending' || payment.status == 'overdue') ...[
                  const SizedBox(height: Spacing.lg),
                  Container(
                    padding: const EdgeInsets.all(Spacing.md),
                    decoration: BoxDecoration(
                      color: context.infoLightColor,
                      borderRadius: BorderRadius.circular(Radius.md),
                      border: Border.all(
                        color: context.infoColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_rounded,
                          color: context.infoColor,
                          size: 20,
                        ),
                        const SizedBox(width: Spacing.sm),
                        Expanded(
                          child: Text(
                            'Silakan hubungi pemilik kost untuk melakukan pembayaran.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.infoColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: Spacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _getDaysOverdue(DateTime dueDate) {
    return DateTime.now().difference(dueDate).inDays;
  }
}