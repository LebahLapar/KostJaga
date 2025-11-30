import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/kost_provider.dart';
import '../providers/tenant_provider.dart';
import '../providers/payment_provider.dart';
import 'rooms/rooms_screen.dart';
import 'tenants/tenants_screen.dart';
import 'payments/payments_screen.dart';
import 'complaints/complaints_screen.dart';
import 'auth/login_screen.dart';

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
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final kostProvider = context.watch<KostProvider>();
    final paymentProvider = context.watch<PaymentProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('JagaKost Dashboard'),
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
                  title: Text(authProvider.user?.email ?? ''),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                child: const ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Keluar', style: TextStyle(color: Colors.red)),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: () {
                  Future.delayed(Duration.zero, _handleLogout);
                },
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
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                            .format(DateTime.now()),
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Statistics Cards
              Text(
                'Ringkasan',
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
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(
                    context,
                    'Total Kamar',
                    '${kostProvider.rooms.length}',
                    Icons.meeting_room,
                    Colors.blue,
                  ),
                  _buildStatCard(
                    context,
                    'Kamar Terisi',
                    '${kostProvider.occupiedRooms}',
                    Icons.home,
                    Colors.green,
                  ),
                  _buildStatCard(
                    context,
                    'Kamar Kosong',
                    '${kostProvider.availableRooms}',
                    Icons.home_outlined,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    context,
                    'Maintenance',
                    '${kostProvider.maintenanceRooms}',
                    Icons.construction,
                    Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Payment Status
              Text(
                'Status Pembayaran',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildPaymentCard(
                      context,
                      'Pending',
                      paymentProvider.pendingPayments,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPaymentCard(
                      context,
                      'Overdue',
                      paymentProvider.overduePayments,
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
                childAspectRatio: 1.2,
                children: [
                  _buildMenuCard(
                    context,
                    'Kelola Kamar',
                    Icons.meeting_room,
                    Colors.blue,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RoomsScreen()),
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    'Kelola Penyewa',
                    Icons.people,
                    Colors.green,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TenantsScreen()),
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    'Pembayaran',
                    Icons.payment,
                    Colors.orange,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PaymentsScreen()),
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
                          builder: (_) => const ComplaintsScreen()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
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
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(
    BuildContext context,
    String title,
    int count,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '$count',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
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
}