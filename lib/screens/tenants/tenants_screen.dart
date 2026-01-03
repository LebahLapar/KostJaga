import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/tenant_provider.dart';
import '../../providers/kost_provider.dart';
import '../../models/models.dart';
import '../../utils/empty_state_widget.dart'; // ADD THIS
import '../../utils/shimmer_loading.dart'; // ADD THIS

class TenantsScreen extends StatefulWidget {
  const TenantsScreen({super.key});

  @override
  State<TenantsScreen> createState() => _TenantsScreenState();
}

class _TenantsScreenState extends State<TenantsScreen> {
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      context.read<TenantProvider>().fetchTenants(),
      context.read<KostProvider>().fetchRooms(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final tenantProvider = context.watch<TenantProvider>();
    final kostProvider = context.watch<KostProvider>();

    List<Tenant> filteredTenants = _filterStatus == 'all'
        ? tenantProvider.tenants
        : tenantProvider.tenants
            .where((t) => t.status == _filterStatus)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Penyewa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: tenantProvider.isLoading
          ? ShimmerLoading.cardList(itemCount: 5) // UPDATED: Shimmer loading
          : filteredTenants.isEmpty
              ? _buildEmptyState() // UPDATED: Better empty state
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredTenants.length,
                    itemBuilder: (context, index) {
                      final tenant = filteredTenants[index];
                      final room = kostProvider.getRoomById(tenant.roomId);
                      return _buildTenantCard(context, tenant, room);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTenantDialog(),
        icon: const Icon(Icons.person_add),
        label: const Text('Tambah Penyewa'),
      ),
    );
  }

  Widget _buildTenantCard(BuildContext context, Tenant tenant, KostRoom? room) {
    final isActive = tenant.status == 'active';
    final statusColor = isActive ? Colors.green : Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showTenantDetail(tenant, room),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                child: Text(
                  tenant.name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            tenant.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isActive ? Icons.check_circle : Icons.cancel,
                                size: 12,
                                color: statusColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isActive ? 'Aktif' : 'Tidak Aktif',
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.home, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          room != null
                              ? 'Kamar ${room.roomNumber}'
                              : 'Kamar tidak ditemukan',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          tenant.phone,
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
              PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  if (isActive)
                    const PopupMenuItem(
                      value: 'checkout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 20, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Check Out',
                              style: TextStyle(color: Colors.orange)),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Hapus', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditTenantDialog(tenant);
                  } else if (value == 'checkout') {
                    _confirmCheckout(tenant);
                  } else if (value == 'delete') {
                    _confirmDelete(tenant);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // UPDATED: Better empty state with filter logic
  Widget _buildEmptyState() {
    final tenantProvider = context.read<TenantProvider>();
    
    // Jika ada filter aktif dan hasil kosong
    if (_filterStatus != 'all' && tenantProvider.tenants.isNotEmpty) {
      return RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: EmptyStateWidget.noFilterResults(
                filterName: _filterStatus == 'active' ? 'Aktif' : 'Tidak Aktif',
                onClearFilter: () {
                  setState(() => _filterStatus = 'all');
                },
              ),
            ),
          ],
        ),
      );
    }

    // Jika memang belum ada tenant sama sekali
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: EmptyStateWidget.noTenants(
              onAddTenant: _showAddTenantDialog,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Penyewa'),
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
              title: const Text('Aktif'),
              value: 'active',
              groupValue: _filterStatus,
              onChanged: (value) {
                setState(() => _filterStatus = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Tidak Aktif'),
              value: 'inactive',
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

  void _showTenantDetail(Tenant tenant, KostRoom? room) {
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
              Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    child: Text(
                      tenant.name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tenant.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          tenant.status == 'active'
                              ? 'Penyewa Aktif'
                              : 'Tidak Aktif',
                          style: TextStyle(
                            color: tenant.status == 'active'
                                ? Colors.green
                                : Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Kamar',
                  room != null ? 'Kamar ${room.roomNumber}' : 'N/A'),
              _buildDetailRow('Telepon', tenant.phone),
              _buildDetailRow('Email', tenant.email),
              if (tenant.ktpNumber != null)
                _buildDetailRow('No. KTP', tenant.ktpNumber!),
              _buildDetailRow('Check-in',
                  DateFormat('dd MMM yyyy').format(tenant.checkInDate)),
              if (tenant.checkOutDate != null)
                _buildDetailRow('Check-out',
                    DateFormat('dd MMM yyyy').format(tenant.checkOutDate!)),
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

  void _showAddTenantDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final ktpController = TextEditingController();
    String? selectedRoomId;
    DateTime selectedDate = DateTime.now();

    final scaffoldContext = context;
    final kostProvider = context.read<KostProvider>();
    final availableRooms =
        kostProvider.rooms.where((r) => r.status == 'available').toList();

    if (availableRooms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada kamar tersedia'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (stateContext, setDialogState) => AlertDialog(
          title: const Text('Tambah Penyewa'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'No. Telepon',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ktpController,
                  decoration: const InputDecoration(
                    labelText: 'No. KTP (Opsional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedRoomId,
                  decoration: const InputDecoration(
                    labelText: 'Pilih Kamar',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.home),
                  ),
                  items: availableRooms.map((room) {
                    return DropdownMenuItem(
                      value: room.id,
                      child: Text(
                          'Kamar ${room.roomNumber} - ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(room.price)}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedRoomId = value);
                  },
                ),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text('Tanggal Check-in'),
                  subtitle: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: dialogContext,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      setDialogState(() => selectedDate = date);
                    }
                  },
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
                if (nameController.text.isEmpty ||
                    phoneController.text.isEmpty ||
                    emailController.text.isEmpty ||
                    selectedRoomId == null) {
                  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                    const SnackBar(
                      content: Text('Mohon lengkapi data wajib'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final tenant = Tenant(
                  id: '',
                  name: nameController.text,
                  phone: phoneController.text,
                  email: emailController.text,
                  ktpNumber: ktpController.text.isEmpty
                      ? null
                      : ktpController.text,
                  roomId: selectedRoomId!,
                  checkInDate: selectedDate,
                  checkOutDate: null,
                  status: 'active',
                  photoUrl: null,
                );

                final success =
                    await scaffoldContext.read<TenantProvider>().addTenant(tenant);

                if (scaffoldContext.mounted) {
                  Navigator.pop(dialogContext);
                  if (success) {
                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                      const SnackBar(
                          content: Text('Penyewa berhasil ditambahkan')),
                    );
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTenantDialog(Tenant tenant) {
    final nameController = TextEditingController(text: tenant.name);
    final phoneController = TextEditingController(text: tenant.phone);
    final emailController = TextEditingController(text: tenant.email);
    final ktpController = TextEditingController(text: tenant.ktpNumber ?? '');

    final scaffoldContext = context;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Penyewa'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'No. Telepon',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ktpController,
                decoration: const InputDecoration(
                  labelText: 'No. KTP',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
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
              final updates = {
                'name': nameController.text,
                'phone': phoneController.text,
                'email': emailController.text,
                'ktp_number': ktpController.text.isEmpty
                    ? null
                    : ktpController.text,
              };

              final success = await scaffoldContext
                  .read<TenantProvider>()
                  .updateTenant(tenant.id, updates);

              if (scaffoldContext.mounted) {
                Navigator.pop(dialogContext);
                if (success) {
                  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                    const SnackBar(content: Text('Penyewa berhasil diupdate')),
                  );
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmCheckout(Tenant tenant) {
    final scaffoldContext = context;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Check Out Penyewa'),
        content: Text(
            'Apakah Anda yakin ${tenant.name} akan check out dari kamar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              final updates = {
                'status': 'inactive',
                'check_out_date': DateTime.now().toIso8601String(),
              };

              final success = await scaffoldContext
                  .read<TenantProvider>()
                  .updateTenant(tenant.id, updates);

              if (scaffoldContext.mounted) {
                Navigator.pop(dialogContext);
                if (success) {
                  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                    const SnackBar(
                        content: Text('Penyewa berhasil check out')),
                  );
                  // Reload rooms to update status
                  await scaffoldContext.read<KostProvider>().fetchRooms();
                }
              }
            },
            child: const Text('Check Out'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Tenant tenant) {
    final scaffoldContext = context;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Penyewa'),
        content: Text('Apakah Anda yakin ingin menghapus ${tenant.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final success = await scaffoldContext
                  .read<TenantProvider>()
                  .deleteTenant(tenant.id);

              if (scaffoldContext.mounted) {
                Navigator.pop(dialogContext);
                if (success) {
                  ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                    const SnackBar(content: Text('Penyewa berhasil dihapus')),
                  );
                }
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}