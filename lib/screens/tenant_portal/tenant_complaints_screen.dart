import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../providers/complaint_provider.dart';
import '../../providers/tenant_auth_provider.dart';
import '../../providers/tenant_provider.dart';
import '../../models/models.dart';

class TenantComplaintsScreen extends StatefulWidget {
  const TenantComplaintsScreen({super.key});

  @override
  State<TenantComplaintsScreen> createState() => _TenantComplaintsScreenState();
}

class _TenantComplaintsScreenState extends State<TenantComplaintsScreen> {
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await context.read<ComplaintProvider>().fetchComplaints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keluhan Saya'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() => _filterStatus = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('Semua')),
              const PopupMenuItem(value: 'pending', child: Text('Pending')),
              const PopupMenuItem(value: 'in_progress', child: Text('Diproses')),
              const PopupMenuItem(value: 'resolved', child: Text('Selesai')),
            ],
          ),
        ],
      ),
      body: Consumer2<ComplaintProvider, TenantAuthProvider>(
        builder: (context, complaintProvider, tenantAuthProvider, child) {
          if (complaintProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final tenantId = tenantAuthProvider.tenantId;
          if (tenantId == null) {
            return const Center(child: Text('User tidak ditemukan'));
          }

          // Filter complaints untuk tenant ini saja
          var complaints = complaintProvider.complaints
              .where((c) => c.tenantId == tenantId)
              .toList();

          // Apply status filter
          if (_filterStatus != 'all') {
            complaints = complaints.where((c) => c.status == _filterStatus).toList();
          }

          if (complaints.isEmpty) {
            return _buildEmptyState();
          }

          // Calculate summary
          final allMyComplaints = complaintProvider.complaints
              .where((c) => c.tenantId == tenantId)
              .toList();
          final pendingCount = allMyComplaints.where((c) => c.status == 'pending').length;
          final inProgressCount = allMyComplaints.where((c) => c.status == 'in_progress').length;
          final resolvedCount = allMyComplaints.where((c) => c.status == 'resolved').length;

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
                          child: _buildSummaryCard('Pending', pendingCount, Colors.orange),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard('Proses', inProgressCount, Colors.blue),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard('Selesai', resolvedCount, Colors.green),
                        ),
                      ],
                    ),
                    if (_filterStatus != 'all') ...[
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
                              'Filter: ${_getStatusLabel(_filterStatus)}',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => setState(() => _filterStatus = 'all'),
                              child: Icon(Icons.close, size: 16, color: Colors.blue[700]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Complaints List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: complaints.length,
                    itemBuilder: (context, index) {
                      return _buildComplaintCard(complaints[index]);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddComplaintDialog,
        icon: const Icon(Icons.add),
        label: const Text('Buat Keluhan'),
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

  Widget _buildComplaintCard(Complaint complaint) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showComplaintDetail(complaint),
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
                        Text(
                          _getCategoryLabel(complaint.category),
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(complaint.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  if (complaint.imageUrl != null) ...[
                    const SizedBox(width: 12),
                    Icon(Icons.image, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('Ada foto', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
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
        label = 'Proses';
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
            'Tap tombol + untuk membuat keluhan baru',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showComplaintDetail(Complaint complaint) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
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
                      child: Text(
                        complaint.title,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    _buildStatusBadge(complaint.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _getCategoryLabel(complaint.category),
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
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
                _buildTimeline(complaint),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline(Complaint complaint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Timeline', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildTimelineItem(
          'Keluhan dibuat',
          _formatDate(complaint.createdAt),
          Colors.blue,
          isFirst: true,
        ),
        if (complaint.status == 'in_progress')
          _buildTimelineItem(
            'Sedang diproses',
            'Tim sedang menangani keluhan Anda',
            Colors.orange,
          ),
        if (complaint.status == 'resolved' && complaint.resolvedAt != null)
          _buildTimelineItem(
            'Keluhan selesai',
            _formatDate(complaint.resolvedAt!),
            Colors.green,
            isLast: true,
          ),
      ],
    );
  }

  Widget _buildTimelineItem(
    String title,
    String subtitle,
    Color color, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            if (!isLast)
              Container(width: 2, height: 40, color: Colors.grey[300]),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddComplaintDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'maintenance';
    String? imagePath;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Buat Keluhan Baru',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Judul Keluhan',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title),
                  ),
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
                    DropdownMenuItem(value: 'maintenance', child: Text('Perbaikan')),
                    DropdownMenuItem(value: 'cleanliness', child: Text('Kebersihan')),
                    DropdownMenuItem(value: 'facility', child: Text('Fasilitas')),
                    DropdownMenuItem(value: 'other', child: Text('Lainnya')),
                  ],
                  onChanged: (value) {
                    setModalState(() => selectedCategory = value!);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(source: ImageSource.camera);
                    if (image != null) {
                      setModalState(() => imagePath = image.path);
                    }
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: Text(imagePath == null ? 'Ambil Foto (Opsional)' : 'Foto terlampir'),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (titleController.text.isEmpty || descriptionController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Harap isi semua field')),
                        );
                        return;
                      }

                      final tenantAuthProvider = context.read<TenantAuthProvider>();
                      final complaintProvider = context.read<ComplaintProvider>();

                      final success = await tenantAuthProvider.submitComplaint(
                        title: titleController.text,
                        description: descriptionController.text,
                        category: selectedCategory,
                        imageUrl: imagePath,
                      );

                      if (context.mounted) {
                        Navigator.pop(modalContext);
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Keluhan berhasil dibuat')),
                          );
                          await complaintProvider.fetchComplaints();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                tenantAuthProvider.errorMessage ?? 'Gagal membuat keluhan',
                              ),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Kirim Keluhan'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
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
      if (diff.inHours == 0) {
        return '${diff.inMinutes} menit yang lalu';
      }
      return '${diff.inHours} jam yang lalu';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari yang lalu';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
}