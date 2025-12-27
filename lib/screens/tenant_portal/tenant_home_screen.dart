import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/tenant_auth_provider.dart';
import '../../providers/tenant_provider.dart';
import '../../providers/kost_provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/complaint_provider.dart';
import '../../models/models.dart';
import 'tenant_complaints_screen.dart';
import 'tenant_payments_screen.dart';
import '../auth/tenant_login_screen.dart';

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

    // Get tenant's data
    final tenantId = tenantAuthProvider.tenantId;
    final myPayments = paymentProvider.payments
        .where((p) => p.tenantId == tenantId)
        .toList();
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
      appBar: AppBar(
        title: const Text('Portal Penyewa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur notifikasi segera hadir')),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(tenantAuthProvider.tenantName ?? 'Loading...'),
                  subtitle: Text('Kamar ${tenantAuthProvider.roomNumber ?? tenantAuthProvider.roomCode}'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                onTap: () {
                  Future.delayed(Duration.zero, () async {
                    await tenantAuthProvider.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const TenantLoginScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  });
                },
                child: const ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Keluar', style: TextStyle(color: Colors.red)),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Card(
                elevation: 2,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat Datang!',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tenantAuthProvider.tenantName ?? 'Loading...',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Room Info Card
              if (_currentRoom != null) ...[
                Text(
                  'Info Kamar',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.meeting_room,
                                color: Theme.of(context).colorScheme.primary,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Kamar ${_currentRoom!.roomNumber}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getRoomTypeText(_currentRoom!.type),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          'Harga',
                          NumberFormat.currency(
                            locale: 'id_ID',
                            symbol: 'Rp ',
                            decimalDigits: 0,
                          ).format(_currentRoom!.price),
                        ),
                        if (_currentTenant != null)
                          _buildInfoRow(
                            'Check-in',
                            DateFormat('dd MMM yyyy')
                                .format(_currentTenant!.checkInDate),
                          ),
                        if (_currentRoom!.description != null)
                          _buildInfoRow(
                              'Deskripsi', _currentRoom!.description!),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Quick Stats
              Text(
                'Ringkasan',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Tagihan Pending',
                      pendingPayments.toString(),
                      Icons.payment,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Keluhan Aktif',
                      pendingComplaints.toString(),
                      Icons.report_problem,
                      Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Menu Cepat',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _buildMenuCard(
                    context,
                    'Tagihan',
                    Icons.payment,
                    Colors.blue,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TenantPaymentsScreen(),
                      ),
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    'Keluhan',
                    Icons.report_problem,
                    Colors.red,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TenantComplaintsScreen(),
                      ),
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    'Info Kamar',
                    Icons.home,
                    Colors.green,
                    () {
                      if (_currentRoom != null) {
                        _showRoomDetail();
                      }
                    },
                  ),
                  _buildMenuCard(
                    context,
                    'Hubungi Owner',
                    Icons.phone,
                    Colors.purple,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur hubungi owner segera hadir'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
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

  Widget _buildMenuCard(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRoomDetail() {
    if (_currentRoom == null) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            Text(
              'Detail Kamar ${_currentRoom!.roomNumber}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Tipe', _getRoomTypeText(_currentRoom!.type)),
            _buildInfoRow(
              'Harga',
              NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
                decimalDigits: 0,
              ).format(_currentRoom!.price),
            ),
            if (_currentTenant != null) ...[
              _buildInfoRow(
                'Tanggal Masuk',
                DateFormat('dd MMMM yyyy').format(_currentTenant!.checkInDate),
              ),
              _buildInfoRow('Status', 'Aktif'),
            ],
            if (_currentRoom!.description != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Deskripsi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(_currentRoom!.description!),
            ],
          ],
        ),
      ),
    );
  }
}