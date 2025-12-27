import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/tenant_auth_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/kost_provider.dart';
import '../../models/models.dart';

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
    
    // Filter only this tenant's payments
    var filtered = payments.where((p) => p.tenantId == tenantId).toList();
    
    // Apply status filter
    if (_selectedFilter == 'all') return filtered;
    return filtered.where((p) => p.status == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tagihan Saya'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() => _selectedFilter = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('Semua')),
              const PopupMenuItem(value: 'pending', child: Text('Belum Bayar')),
              const PopupMenuItem(value: 'paid', child: Text('Sudah Bayar')),
              const PopupMenuItem(value: 'overdue', child: Text('Terlambat')),
            ],
          ),
        ],
      ),
      body: Consumer2<PaymentProvider, TenantAuthProvider>(
        builder: (context, paymentProvider, tenantAuthProvider, child) {
          if (paymentProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final tenantId = tenantAuthProvider.tenantId;
          final filteredPayments = _getFilteredPayments(
            paymentProvider.payments,
            tenantId,
          );

          if (filteredPayments.isEmpty) {
            return _buildEmptyState();
          }

          // Calculate summary
          final allMyPayments = paymentProvider.payments
              .where((p) => p.tenantId == tenantId)
              .toList();
          final pendingCount = allMyPayments.where((p) => p.status == 'pending').length;
          final paidCount = allMyPayments.where((p) => p.status == 'paid').length;
          final overdueCount = allMyPayments.where((p) => p.status == 'overdue').length;

          return Column(
            children: [
              // Summary Cards
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard('Belum Bayar', pendingCount, Colors.orange),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard('Sudah Bayar', paidCount, Colors.green),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard('Terlambat', overdueCount, Colors.red),
                        ),
                      ],
                    ),
                    if (_selectedFilter != 'all') ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.filter_list, size: 16, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Filter: ${_getFilterLabel(_selectedFilter)}',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() => _selectedFilter = 'all');
                              },
                              child: Icon(Icons.close, size: 16, color: Colors.blue[700]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Payment List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await context.read<PaymentProvider>().fetchPayments();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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

  Widget _buildSummaryCard(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Payment payment) {
    final kostProvider = context.read<KostProvider>();
    final room = kostProvider.getRoomById(payment.roomId);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showPaymentDetail(payment, room),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getStatusColor(payment.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.payment,
                      color: _getStatusColor(payment.status),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kamar ${room?.roomNumber ?? payment.roomId}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          NumberFormat.currency(
                            locale: 'id_ID',
                            symbol: 'Rp ',
                            decimalDigits: 0,
                          ).format(payment.amount),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(payment.status),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    'Jatuh tempo: ${DateFormat('dd MMM yyyy').format(payment.dueDate)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  if (payment.status == 'overdue') ...[
                    const SizedBox(width: 8),
                    Text(
                      '(${_getDaysOverdue(payment.dueDate)} hari)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
              if (payment.paidDate != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.check_circle, size: 14, color: Colors.green[600]),
                    const SizedBox(width: 6),
                    Text(
                      'Dibayar: ${DateFormat('dd MMM yyyy').format(payment.paidDate!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
              if (payment.notes != null && payment.notes!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.note, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        payment.notes!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = 'Belum Bayar';
        break;
      case 'paid':
        color = Colors.green;
        label = 'Lunas';
        break;
      case 'overdue':
        color = Colors.red;
        label = 'Terlambat';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.payment, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Belum ada tagihan', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(
            'Tagihan akan muncul di sini',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showPaymentDetail(Payment payment, KostRoom? room) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getStatusColor(payment.status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.payment,
                        color: _getStatusColor(payment.status),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Detail Pembayaran',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          _buildStatusBadge(payment.status),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildDetailRow('Kamar', 'Kamar ${room?.roomNumber ?? payment.roomId}'),
                _buildDetailRow(
                  'Jumlah',
                  NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  ).format(payment.amount),
                ),
                _buildDetailRow(
                  'Tanggal Jatuh Tempo',
                  DateFormat('dd MMMM yyyy').format(payment.dueDate),
                ),
                if (payment.paidDate != null)
                  _buildDetailRow(
                    'Tanggal Bayar',
                    DateFormat('dd MMMM yyyy').format(payment.paidDate!),
                  ),
                if (payment.status == 'overdue')
                  _buildDetailRow(
                    'Keterlambatan',
                    '${_getDaysOverdue(payment.dueDate)} hari',
                    valueColor: Colors.red,
                  ),
                if (payment.notes != null && payment.notes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Catatan',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(payment.notes!, style: const TextStyle(fontSize: 14)),
                ],
                if (payment.status == 'pending' || payment.status == 'overdue') ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Informasi Pembayaran',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Silakan hubungi pemilik kost untuk melakukan pembayaran atau upload bukti transfer.',
                          style: TextStyle(color: Colors.blue[900], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.green;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'pending':
        return 'Belum Bayar';
      case 'paid':
        return 'Sudah Bayar';
      case 'overdue':
        return 'Terlambat';
      default:
        return 'Semua';
    }
  }

  int _getDaysOverdue(DateTime dueDate) {
    final now = DateTime.now();
    final difference = now.difference(dueDate);
    return difference.inDays;
  }
}