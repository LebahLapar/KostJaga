import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/payment_provider.dart';
import '../../providers/tenant_provider.dart';
import '../../providers/kost_provider.dart';
import '../../models/models.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      context.read<PaymentProvider>().fetchPayments(),
      context.read<TenantProvider>().fetchTenants(),
      context.read<KostProvider>().fetchRooms(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = context.watch<PaymentProvider>();
    final tenantProvider = context.watch<TenantProvider>();
    final kostProvider = context.watch<KostProvider>();

    List<Payment> filteredPayments = _filterStatus == 'all'
        ? paymentProvider.payments
        : paymentProvider.payments
            .where((p) => p.status == _filterStatus)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Cards
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Pending',
                    paymentProvider.pendingPayments.toString(),
                    Colors.orange,
                    Icons.pending,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Overdue',
                    paymentProvider.overduePayments.toString(),
                    Colors.red,
                    Icons.warning,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Paid',
                    paymentProvider.paidPayments.toString(),
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
              ],
            ),
          ),

          // Revenue Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Pendapatan',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(paymentProvider.totalRevenue),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 40,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Payments List
          Expanded(
            child: paymentProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredPayments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.payment,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada pembayaran',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredPayments.length,
                          itemBuilder: (context, index) {
                            final payment = filteredPayments[index];
                            final tenant = tenantProvider.tenants.firstWhere(
                              (t) => t.id == payment.tenantId,
                              orElse: () => Tenant(
                                id: '',
                                name: 'Unknown',
                                phone: '',
                                email: '',
                                roomId: '',
                                checkInDate: DateTime.now(),
                                status: 'inactive',
                              ),
                            );
                            final room =
                                kostProvider.getRoomById(payment.roomId);
                            return _buildPaymentCard(
                                context, payment, tenant, room);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGeneratePaymentDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Buat Tagihan'),
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(
      BuildContext context, Payment payment, Tenant tenant, KostRoom? room) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (payment.status) {
      case 'paid':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Lunas';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        statusText = 'Pending';
        break;
      case 'overdue':
        statusColor = Colors.red;
        statusIcon = Icons.warning;
        statusText = 'Terlambat';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = payment.status;
    }

    final isOverdue = payment.status == 'overdue' ||
        (payment.status == 'pending' &&
            payment.dueDate.isBefore(DateTime.now()));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showPaymentDetail(payment, tenant, room),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tenant.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.home, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              room != null
                                  ? 'Kamar ${room.roomNumber}'
                                  : 'N/A',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jumlah',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp ',
                          decimalDigits: 0,
                        ).format(payment.amount),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Jatuh Tempo',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMM yyyy').format(payment.dueDate),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isOverdue ? Colors.red : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (payment.status == 'pending' || payment.status == 'overdue')
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _markAsPaid(payment),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Tandai Lunas'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Pembayaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Semua'),
              value: 'all',
              groupValue: _filterStatus,
              onChanged: (value) {
                setState(() => _filterStatus = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Pending'),
              value: 'pending',
              groupValue: _filterStatus,
              onChanged: (value) {
                setState(() => _filterStatus = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Lunas'),
              value: 'paid',
              groupValue: _filterStatus,
              onChanged: (value) {
                setState(() => _filterStatus = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Terlambat'),
              value: 'overdue',
              groupValue: _filterStatus,
              onChanged: (value) {
                setState(() => _filterStatus = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentDetail(Payment payment, Tenant tenant, KostRoom? room) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
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
              const SizedBox(height: 20),
              const Text(
                'Detail Pembayaran',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Penyewa', tenant.name),
              _buildDetailRow(
                  'Kamar', room != null ? 'Kamar ${room.roomNumber}' : 'N/A'),
              _buildDetailRow(
                'Jumlah',
                NumberFormat.currency(
                  locale: 'id_ID',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                ).format(payment.amount),
              ),
              _buildDetailRow(
                'Jatuh Tempo',
                DateFormat('dd MMMM yyyy').format(payment.dueDate),
              ),
              if (payment.paidDate != null)
                _buildDetailRow(
                  'Tanggal Bayar',
                  DateFormat('dd MMMM yyyy').format(payment.paidDate!),
                ),
              _buildDetailRow(
                'Status',
                payment.status == 'paid'
                    ? 'Lunas'
                    : payment.status == 'pending'
                        ? 'Pending'
                        : 'Terlambat',
              ),
              if (payment.notes != null && payment.notes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Catatan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(payment.notes!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showGeneratePaymentDialog() {
    final tenantProvider = context.read<TenantProvider>();
    final kostProvider = context.read<KostProvider>();

    final activeTenants =
        tenantProvider.tenants.where((t) => t.status == 'active').toList();

    if (activeTenants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada penyewa aktif'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String? selectedTenantId;
    DateTime selectedDueDate = DateTime.now().add(const Duration(days: 7));
    final notesController = TextEditingController();

    final scaffoldContext = context;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (stateContext, setDialogState) {
          final selectedTenant = selectedTenantId != null
              ? activeTenants.firstWhere((t) => t.id == selectedTenantId)
              : null;
          final room = selectedTenant != null
              ? kostProvider.getRoomById(selectedTenant.roomId)
              : null;

          return AlertDialog(
            title: const Text('Buat Tagihan Baru'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedTenantId,
                    decoration: const InputDecoration(
                      labelText: 'Pilih Penyewa',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    items: activeTenants.map((tenant) {
                      final tenantRoom =
                          kostProvider.getRoomById(tenant.roomId);
                      return DropdownMenuItem(
                        value: tenant.id,
                        child: Text(
                            '${tenant.name} - Kamar ${tenantRoom?.roomNumber ?? "N/A"}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() => selectedTenantId = value);
                    },
                  ),
                  if (room != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Harga Kamar:',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            NumberFormat.currency(
                              locale: 'id_ID',
                              symbol: 'Rp ',
                              decimalDigits: 0,
                            ).format(room.price),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Jatuh Tempo'),
                    subtitle: Text(
                        DateFormat('dd MMM yyyy').format(selectedDueDate)),
                    trailing: const Icon(Icons.calendar_today),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: dialogContext,
                        initialDate: selectedDueDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setDialogState(() => selectedDueDate = date);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Catatan (Opsional)',
                      border: OutlineInputBorder(),
                      hintText: 'Tambahkan catatan pembayaran...',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (selectedTenantId == null || room == null) {
                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                      const SnackBar(
                        content: Text('Mohon pilih penyewa'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final payment = Payment(
                    id: '',
                    tenantId: selectedTenantId!,
                    roomId: room.id,
                    amount: room.price,
                    dueDate: selectedDueDate,
                    paidDate: null,
                    status: 'pending',
                    proofImageUrl: null,
                    notes: notesController.text.isEmpty
                        ? null
                        : notesController.text,
                    createdAt: DateTime.now(),
                  );

                  final success = await scaffoldContext
                      .read<PaymentProvider>()
                      .addPayment(payment);

                  if (scaffoldContext.mounted) {
                    Navigator.pop(dialogContext);
                    if (success) {
                      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                        const SnackBar(
                            content: Text('Tagihan berhasil dibuat')),
                      );
                    }
                  }
                },
                child: const Text('Buat Tagihan'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _markAsPaid(Payment payment) {
    final scaffoldContext = context;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi Pembayaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tandai pembayaran ini sebagai lunas?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Jumlah:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(payment.amount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final success = await scaffoldContext
                  .read<PaymentProvider>()
                  .markAsPaid(payment.id, null);

              if (scaffoldContext.mounted) {
                Navigator.pop(dialogContext);
                if (success) {
                  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                    const SnackBar(
                      content: Text('Pembayaran berhasil ditandai lunas'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            child: const Text('Tandai Lunas'),
          ),
        ],
      ),
    );
  }
}