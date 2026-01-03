import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/complaint_provider.dart';
import '../../providers/tenant_provider.dart';
import '../../providers/kost_provider.dart';
import '../../models/models.dart';
import '../../utils/empty_state_widget.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ComplaintProvider>().fetchComplaints();
      context.read<TenantProvider>().fetchTenants();
      context.read<KostProvider>().fetchRooms();
    });
  }

  List<Complaint> _getFilteredComplaints(List<Complaint> complaints) {
    var filtered = complaints;
    
    if (_filterStatus != 'all') {
      filtered = filtered.where((c) => c.status == _filterStatus).toList();
    }
    
    if (_filterCategory != 'all') {
      filtered = filtered.where((c) => c.category == _filterCategory).toList();
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Keluhan'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              if (value.startsWith('status_')) {
                setState(() => _filterStatus = value.substring(7));
              } else if (value.startsWith('category_')) {
                setState(() => _filterCategory = value.substring(9));
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                enabled: false,
                child: Text('Filter Status', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const PopupMenuItem(value: 'status_all', child: Text('Semua Status')),
              const PopupMenuItem(value: 'status_pending', child: Text('Pending')),
              const PopupMenuItem(value: 'status_in_progress', child: Text('Diproses')),
              const PopupMenuItem(value: 'status_resolved', child: Text('Selesai')),
              const PopupMenuDivider(),
              const PopupMenuItem(
                enabled: false,
                child: Text('Filter Kategori', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const PopupMenuItem(value: 'category_all', child: Text('Semua Kategori')),
              const PopupMenuItem(value: 'category_maintenance', child: Text('Perbaikan')),
              const PopupMenuItem(value: 'category_cleanliness', child: Text('Kebersihan')),
              const PopupMenuItem(value: 'category_facility', child: Text('Fasilitas')),
              const PopupMenuItem(value: 'category_other', child: Text('Lainnya')),
            ],
          ),
        ],
      ),
      body: Consumer<ComplaintProvider>(
        builder: (context, complaintProvider, child) {
          if (complaintProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredComplaints = _getFilteredComplaints(complaintProvider.complaints);

          if (filteredComplaints.isEmpty) {
            // Jika ada filter
            if (_filterStatus != 'all' || _filterCategory != 'all') {
              return EmptyStateWidget.noFilterResults(
                filterName: '${_getStatusLabel(_filterStatus)} - ${_getCategoryLabel(_filterCategory)}',
                onClearFilter: () {
                  setState(() {
                    _filterStatus = 'all';
                    _filterCategory = 'all';
                  });
                },
              );
            }

            // Jika memang kosong (tenant belum submit keluhan)
            return const EmptyStateWidget(
              icon: '✅',
              title: 'Tidak Ada Keluhan',
              message: 'Belum ada keluhan dari penyewa.\nSemua berjalan lancar!',
              iconColor: Colors.green,
            );
          }

          return Column(
            children: [
              _buildSummaryCards(complaintProvider),
              if (_filterStatus != 'all' || _filterCategory != 'all')
                _buildActiveFilters(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await context.read<ComplaintProvider>().fetchComplaints();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredComplaints.length,
                    itemBuilder: (context, index) {
                      return _buildComplaintCard(filteredComplaints[index]);
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

  Widget _buildSummaryCards(ComplaintProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Pending',
              provider.pendingComplaints,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Diproses',
              provider.inProgressComplaints,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Selesai',
              provider.resolvedComplaints,
              Colors.green,
            ),
          ),
        ],
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
            style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        children: [
          if (_filterStatus != 'all')
            Chip(
              label: Text('Status: ${_getStatusLabel(_filterStatus)}'),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () => setState(() => _filterStatus = 'all'),
            ),
          if (_filterCategory != 'all')
            Chip(
              label: Text('Kategori: ${_getCategoryLabel(_filterCategory)}'),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () => setState(() => _filterCategory = 'all'),
            ),
        ],
      ),
    );
  }

  Widget _buildComplaintCard(Complaint complaint) {
    final tenantProvider = context.read<TenantProvider>();
    final kostProvider = context.read<KostProvider>();
    
    final tenant = tenantProvider.tenants.firstWhere(
      (t) => t.id == complaint.tenantId,
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
    
    final room = kostProvider.getRoomById(complaint.roomId);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  _buildCategoryIcon(complaint.category),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          complaint.title,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
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
                              'Kamar ${room?.roomNumber ?? complaint.roomId}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(complaint.status),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                complaint.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(complaint.category).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getCategoryLabel(complaint.category),
                          style: TextStyle(
                            fontSize: 11,
                            color: _getCategoryColor(complaint.category),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(complaint.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  if (complaint.status != 'resolved')
                    TextButton(
                      onPressed: () => _quickUpdateStatus(complaint),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        complaint.status == 'pending' ? 'Proses' : 'Selesai',
                        style: const TextStyle(fontSize: 12),
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

  Widget _buildCategoryIcon(String category) {
    IconData icon;
    Color color;

    switch (category) {
      case 'maintenance':
        icon = Icons.build;
        color = Colors.orange;
        break;
      case 'cleanliness':
        icon = Icons.cleaning_services;
        color = Colors.blue;
        break;
      case 'facility':
        icon = Icons.chair;
        color = Colors.purple;
        break;
      default:
        icon = Icons.report_problem;
        color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        break;
      case 'in_progress':
        color = Colors.blue;
        label = 'Diproses';
        break;
      case 'resolved':
        color = Colors.green;
        label = 'Selesai';
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
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Belum ada keluhan', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(
            'Keluhan dari penyewa akan muncul di sini',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _quickUpdateStatus(Complaint complaint) async {
    final newStatus = complaint.status == 'pending' ? 'in_progress' : 'resolved';
    
    final scaffoldContext = context;
    final success = await scaffoldContext.read<ComplaintProvider>().updateComplaint(
      complaint.id,
      {
        'status': newStatus,
        if (newStatus == 'resolved') 'resolved_at': DateTime.now().toIso8601String(),
      },
    );

    if (scaffoldContext.mounted && success) {
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        SnackBar(
          content: Text(
            newStatus == 'in_progress' 
              ? 'Keluhan sedang diproses' 
              : 'Keluhan telah diselesaikan',
          ),
        ),
      );
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
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
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
                    _buildCategoryIcon(complaint.category),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            complaint.title,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getCategoryLabel(complaint.category),
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(complaint.status),
                  ],
                ),
                const SizedBox(height: 24),
                _buildInfoRow('Penyewa', tenant.name),
                _buildInfoRow('Kamar', 'Kamar ${room?.roomNumber ?? complaint.roomId}'),
                _buildInfoRow('Telepon', tenant.phone),
                const SizedBox(height: 16),
                const Text('Deskripsi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(complaint.description, style: const TextStyle(fontSize: 14, height: 1.5)),
                if (complaint.imageUrl != null) ...[
                  const SizedBox(height: 24),
                  const Text('Foto Bukti', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      complaint.imageUrl!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: const Center(child: Icon(Icons.broken_image, size: 50)),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                const Text('Update Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (complaint.status != 'resolved')
                  Row(
                    children: [
                      if (complaint.status == 'pending')
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await context.read<ComplaintProvider>().updateComplaint(
                                complaint.id,
                                {'status': 'in_progress'},
                              );
                              if (context.mounted) Navigator.pop(context);
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Mulai Proses'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      if (complaint.status == 'pending') const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await context.read<ComplaintProvider>().resolveComplaint(complaint.id);
                            if (context.mounted) Navigator.pop(context);
                          },
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Tandai Selesai'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Keluhan Selesai',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                              if (complaint.resolvedAt != null)
                                Text(
                                  'Diselesaikan: ${DateFormat('dd MMM yyyy, HH:mm').format(complaint.resolvedAt!)}',
                                  style: const TextStyle(fontSize: 12, color: Colors.green),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          const Text(': ', style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'maintenance':
        return Colors.orange;
      case 'cleanliness':
        return Colors.blue;
      case 'facility':
        return Colors.purple;
      default:
        return Colors.red;
    }
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'maintenance':
        return 'Perbaikan';
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

  String _getStatusLabel(String status) {
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return DateFormat('HH:mm').format(date);
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari lalu';
    } else {
      return DateFormat('dd MMM yyyy').format(date);
    }
  }
}