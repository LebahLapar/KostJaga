import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/complaint_provider.dart';
import '../../providers/tenant_provider.dart';
import '../../providers/kost_provider.dart';
import '../../models/models.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  String _filterStatus = 'all';
  String _filterCategory = 'all';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      context.read<ComplaintProvider>().fetchComplaints(),
      context.read<TenantProvider>().fetchTenants(),
      context.read<KostProvider>().fetchRooms(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final complaintProvider = context.watch<ComplaintProvider>();
    final tenantProvider = context.watch<TenantProvider>();
    final kostProvider = context.watch<KostProvider>();

    List<Complaint> filteredComplaints = complaintProvider.complaints.where((c) {
      final statusMatch =
          _filterStatus == 'all' || c.status == _filterStatus;
      final categoryMatch =
          _filterCategory == 'all' || c.category == _filterCategory;
      return statusMatch && categoryMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keluhan'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            itemBuilder: (context) => [
              const PopupMenuItem(
                enabled: false,
                child: Text(
                  'Filter Status',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              PopupMenuItem(
                child: const Text('Semua Status'),
                onTap: () => setState(() => _filterStatus = 'all'),
              ),
              PopupMenuItem(
                child: const Text('Pending'),
                onTap: () => setState(() => _filterStatus = 'pending'),
              ),
              PopupMenuItem(
                child: const Text('Diproses'),
                onTap: () => setState(() => _filterStatus = 'in_progress'),
              ),
              PopupMenuItem(
                child: const Text('Selesai'),
                onTap: () => setState(() => _filterStatus = 'resolved'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                enabled: false,
                child: Text(
                  'Filter Kategori',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              PopupMenuItem(
                child: const Text('Semua Kategori'),
                onTap: () => setState(() => _filterCategory = 'all'),
              ),
              PopupMenuItem(
                child: const Text('Maintenance'),
                onTap: () => setState(() => _filterCategory = 'maintenance'),
              ),
              PopupMenuItem(
                child: const Text('Kebersihan'),
                onTap: () => setState(() => _filterCategory = 'cleanliness'),
              ),
              PopupMenuItem(
                child: const Text('Fasilitas'),
                onTap: () => setState(() => _filterCategory = 'facility'),
              ),
              PopupMenuItem(
                child: const Text('Lainnya'),
                onTap: () => setState(() => _filterCategory = 'other'),
              ),
            ],
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
                    complaintProvider.pendingComplaints.toString(),
                    Colors.orange,
                    Icons.pending,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Diproses',
                    complaintProvider.inProgressComplaints.toString(),
                    Colors.blue,
                    Icons.engineering,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Selesai',
                    complaintProvider.resolvedComplaints.toString(),
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
              ],
            ),
          ),

          // Active Filters Indicator
          if (_filterStatus != 'all' || _filterCategory != 'all')
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.filter_alt, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Filter aktif: ${_filterStatus != 'all' ? _getStatusText(_filterStatus) : ''} ${_filterCategory != 'all' ? _getCategoryText(_filterCategory) : ''}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _filterStatus = 'all';
                        _filterCategory = 'all';
                      });
                    },
                    child: const Text('Reset', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Complaints List
          Expanded(
            child: complaintProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredComplaints.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.report_problem_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada keluhan',
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
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredComplaints.length,
                          itemBuilder: (context, index) {
                            final complaint = filteredComplaints[index];
                            final tenant = tenantProvider.tenants.firstWhere(
                              (t) => t.id == complaint.tenantId,
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
                                kostProvider.getRoomById(complaint.roomId);
                            return _buildComplaintCard(
                                context, complaint, tenant, room);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddComplaintDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Keluhan'),
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
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintCard(
      BuildContext context, Complaint complaint, Tenant tenant, KostRoom? room) {
    Color statusColor;
    IconData statusIcon;

    switch (complaint.status) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case 'in_progress':
        statusColor = Colors.blue;
        statusIcon = Icons.engineering;
        break;
      case 'resolved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    Color categoryColor = _getCategoryColor(complaint.category);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showComplaintDetail(complaint, tenant, room),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      complaint.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 12, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          _getStatusText(complaint.status),
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
              const SizedBox(height: 8),
              Text(
                complaint.description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    tenant.name,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.home, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    room != null ? 'Kamar ${room.roomNumber}' : 'N/A',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getCategoryText(complaint.category),
                      style: TextStyle(
                        color: categoryColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('dd MMM yyyy, HH:mm')
                        .format(complaint.createdAt),
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                  if (complaint.status != 'resolved')
                    TextButton.icon(
                      onPressed: () => _showUpdateStatusDialog(complaint),
                      icon: const Icon(Icons.edit, size: 14),
                      label: const Text('Update Status', style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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

  String _getStatusText(String status) {
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

  String _getCategoryText(String category) {
    switch (category) {
      case 'maintenance':
        return 'Maintenance';
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

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'maintenance':
        return Colors.red;
      case 'cleanliness':
        return Colors.blue;
      case 'facility':
        return Colors.purple;
      case 'other':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  void _showComplaintDetail(Complaint complaint, Tenant tenant, KostRoom? room) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
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
              Text(
                complaint.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildInfoChip(
                    _getStatusText(complaint.status),
                    _getStatusColor(complaint.status),
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    _getCategoryText(complaint.category),
                    _getCategoryColor(complaint.category),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Deskripsi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                complaint.description,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Pelapor', tenant.name),
              _buildDetailRow('Kamar',
                  room != null ? 'Kamar ${room.roomNumber}' : 'N/A'),
              _buildDetailRow('Telepon', tenant.phone),
              _buildDetailRow(
                'Tanggal Lapor',
                DateFormat('dd MMMM yyyy, HH:mm').format(complaint.createdAt),
              ),
              if (complaint.resolvedAt != null)
                _buildDetailRow(
                  'Tanggal Selesai',
                  DateFormat('dd MMMM yyyy, HH:mm')
                      .format(complaint.resolvedAt!),
                ),
              const SizedBox(height: 20),
              if (complaint.status != 'resolved')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showUpdateStatusDialog(complaint);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Update Status'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
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

  void _showAddComplaintDialog() {
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
    String selectedCategory = 'maintenance';
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

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
            title: const Text('Tambah Keluhan'),
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
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'maintenance', child: Text('Maintenance')),
                      DropdownMenuItem(
                          value: 'cleanliness', child: Text('Kebersihan')),
                      DropdownMenuItem(
                          value: 'facility', child: Text('Fasilitas')),
                      DropdownMenuItem(value: 'other', child: Text('Lainnya')),
                    ],
                    onChanged: (value) {
                      setDialogState(() => selectedCategory = value!);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Judul Keluhan',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                      hintText: 'Contoh: AC Tidak Dingin',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi',
                      border: OutlineInputBorder(),
                      hintText: 'Jelaskan detail keluhan...',
                      alignLabelWithHint: true,
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
                  if (selectedTenantId == null ||
                      titleController.text.isEmpty ||
                      descriptionController.text.isEmpty ||
                      room == null) {
                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                      const SnackBar(
                        content: Text('Mohon lengkapi semua data'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final complaint = Complaint(
                    id: '',
                    tenantId: selectedTenantId!,
                    roomId: room.id,
                    title: titleController.text,
                    description: descriptionController.text,
                    category: selectedCategory,
                    status: 'pending',
                    imageUrl: null,
                    createdAt: DateTime.now(),
                    resolvedAt: null,
                  );

                  final success = await scaffoldContext
                      .read<ComplaintProvider>()
                      .addComplaint(complaint);

                  if (scaffoldContext.mounted) {
                    Navigator.pop(dialogContext);
                    if (success) {
                      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                        const SnackBar(
                            content: Text('Keluhan berhasil ditambahkan')),
                      );
                    }
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showUpdateStatusDialog(Complaint complaint) {
    String selectedStatus = complaint.status;

    final scaffoldContext = context;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (stateContext, setDialogState) => AlertDialog(
          title: const Text('Update Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Pending'),
                value: 'pending',
                groupValue: selectedStatus,
                onChanged: (value) {
                  setDialogState(() => selectedStatus = value!);
                },
              ),
              RadioListTile<String>(
                title: const Text('Diproses'),
                value: 'in_progress',
                groupValue: selectedStatus,
                onChanged: (value) {
                  setDialogState(() => selectedStatus = value!);
                },
              ),
              RadioListTile<String>(
                title: const Text('Selesai'),
                value: 'resolved',
                groupValue: selectedStatus,
                onChanged: (value) {
                  setDialogState(() => selectedStatus = value!);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Map<String, dynamic> updates = {'status': selectedStatus};

                if (selectedStatus == 'resolved') {
                  updates['resolved_at'] = DateTime.now().toIso8601String();
                }

                final success = await scaffoldContext
                    .read<ComplaintProvider>()
                    .updateComplaint(complaint.id, updates);

                if (scaffoldContext.mounted) {
                  Navigator.pop(dialogContext);
                  if (success) {
                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                      const SnackBar(
                        content: Text('Status berhasil diupdate'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}