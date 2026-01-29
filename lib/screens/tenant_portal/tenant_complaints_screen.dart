import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../providers/complaint_provider.dart';
import '../../providers/tenant_auth_provider.dart';
import '../../models/models.dart';
import '../../utils/toast_helper.dart';
import '../../utils/shimmer_loading.dart';
import '../../utils/empty_state_widget.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_system.dart';

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
      ),
      body: Consumer2<ComplaintProvider, TenantAuthProvider>(
        builder: (context, complaintProvider, tenantAuthProvider, child) {
          if (complaintProvider.isLoading) {
            return ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) => ShimmerLoading.complaintCard(),
            );
          }

          final tenantId = tenantAuthProvider.tenantId;
          if (tenantId == null) {
            return const Center(child: Text('User tidak ditemukan'));
          }

          // Filter complaints
          var complaints = complaintProvider.complaints
              .where((c) => c.tenantId == tenantId)
              .toList();

          if (_filterStatus != 'all') {
            complaints =
                complaints.where((c) => c.status == _filterStatus).toList();
          }

          if (complaints.isEmpty) {
            return RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: _buildEmptyState(),
                  ),
                ],
              ),
            );
          }

          // Calculate summary
          final allMyComplaints = complaintProvider.complaints
              .where((c) => c.tenantId == tenantId)
              .toList();
          final pendingCount =
              allMyComplaints.where((c) => c.status == 'pending').length;
          final inProgressCount =
              allMyComplaints.where((c) => c.status == 'in_progress').length;
          final resolvedCount =
              allMyComplaints.where((c) => c.status == 'resolved').length;

          return Column(
            children: [
              // Filter Chips
              _buildFilterChips(pendingCount, inProgressCount, resolvedCount),

              // Complaints List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(Spacing.md),
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
        icon: const Icon(Icons.add_rounded),
        label: const Text('Buat Keluhan'),
      ),
    );
  }

  Widget _buildFilterChips(int pending, int inProgress, int resolved) {
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
          _buildFilterChip('in_progress', 'Diproses', inProgress),
          const SizedBox(width: Spacing.sm),
          _buildFilterChip('resolved', 'Selesai', resolved),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, int? count) {
    final isSelected = _filterStatus == value;

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
        setState(() => _filterStatus = value);
      },
    );
  }

  Widget _buildComplaintCard(Complaint complaint) {
    final categoryColor = CategoryHelper.getColor(complaint.category);
    final categoryIcon = CategoryHelper.getIcon(complaint.category);
    final categoryLabel = CategoryHelper.getLabel(complaint.category);
    final statusColor = StatusHelper.getComplaintColor(complaint.status, context);
    final statusLabel = StatusHelper.getComplaintLabel(complaint.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: AppCard(
        onTap: () => _showComplaintDetail(complaint),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(
                      alpha: context.isDarkMode ? 0.2 : 0.1,
                    ),
                    borderRadius: BorderRadius.circular(Radius.md),
                  ),
                  child: Icon(categoryIcon, color: categoryColor, size: 22),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        complaint.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        categoryLabel,
                        style: Theme.of(context).textTheme.bodySmall,
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
            const SizedBox(height: Spacing.sm),
            Text(
              complaint.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: Spacing.md),
            Divider(color: context.dividerColor, height: 1),
            const SizedBox(height: Spacing.sm),
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: context.textTertiary,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatDate(complaint.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (complaint.imageUrl != null) ...[
                  const SizedBox(width: Spacing.md),
                  Icon(
                    Icons.image_rounded,
                    size: 16,
                    color: context.primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Foto',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.primaryColor,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final complaintProvider = context.read<ComplaintProvider>();
    final tenantAuthProvider = context.read<TenantAuthProvider>();
    final tenantId = tenantAuthProvider.tenantId;

    final allMyComplaints = complaintProvider.complaints
        .where((c) => c.tenantId == tenantId)
        .toList();

    if (_filterStatus != 'all' && allMyComplaints.isNotEmpty) {
      return EmptyStateWidget.noFilterResults(
        filterName: StatusHelper.getComplaintLabel(_filterStatus),
        onClearFilter: () => setState(() => _filterStatus = 'all'),
      );
    }

    return EmptyStateWidget.noComplaints(
      onCreateComplaint: _showAddComplaintDialog,
    );
  }

  void _showComplaintDetail(Complaint complaint) {
    final categoryColor = CategoryHelper.getColor(complaint.category);
    final categoryIcon = CategoryHelper.getIcon(complaint.category);
    final categoryLabel = CategoryHelper.getLabel(complaint.category);
    final statusColor = StatusHelper.getComplaintColor(complaint.status, context);
    final statusLabel = StatusHelper.getComplaintLabel(complaint.status);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
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
                        color: categoryColor.withValues(
                          alpha: context.isDarkMode ? 0.2 : 0.1,
                        ),
                        borderRadius: BorderRadius.circular(Radius.md),
                      ),
                      child: Icon(categoryIcon, color: categoryColor, size: 24),
                    ),
                    const SizedBox(width: Spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            complaint.title,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              StatusBadge(
                                label: statusLabel,
                                color: statusColor,
                                small: true,
                              ),
                              const SizedBox(width: Spacing.sm),
                              StatusBadge(
                                label: categoryLabel,
                                color: categoryColor,
                                small: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.lg),

                // Description
                Text(
                  'Deskripsi',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  complaint.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.textSecondary,
                    height: 1.5,
                  ),
                ),

                // Image
                if (complaint.imageUrl != null) ...[
                  const SizedBox(height: Spacing.lg),
                  Text(
                    'Foto',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: Spacing.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Radius.md),
                    child: Image.network(
                      complaint.imageUrl!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: context.surfaceVariant,
                            borderRadius: BorderRadius.circular(Radius.md),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.broken_image_rounded,
                              size: 50,
                              color: context.textTertiary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],

                // Timeline
                const SizedBox(height: Spacing.lg),
                Text(
                  'Timeline',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: Spacing.md),
                _buildTimeline(complaint),
                const SizedBox(height: Spacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline(Complaint complaint) {
    return Column(
      children: [
        _buildTimelineItem(
          'Keluhan dibuat',
          _formatDate(complaint.createdAt),
          context.infoColor,
          isFirst: true,
          isLast: complaint.status == 'pending',
        ),
        if (complaint.status == 'in_progress' || complaint.status == 'resolved')
          _buildTimelineItem(
            'Sedang diproses',
            'Tim sedang menangani',
            context.warningColor,
            isLast: complaint.status == 'in_progress',
          ),
        if (complaint.status == 'resolved' && complaint.resolvedAt != null)
          _buildTimelineItem(
            'Selesai',
            _formatDate(complaint.resolvedAt!),
            context.successColor,
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
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: context.dividerColor,
              ),
          ],
        ),
        const SizedBox(width: Spacing.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
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
      builder: (modalContext) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: Spacing.lg,
            right: Spacing.lg,
            top: Spacing.lg,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BottomSheetHandle(),
                Text(
                  'Buat Keluhan',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  'Sampaikan keluhan Anda',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: Spacing.lg),

                // Title
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Judul',
                    hintText: 'Contoh: AC tidak dingin',
                    prefixIcon: Icon(Icons.title_rounded),
                  ),
                ),
                const SizedBox(height: Spacing.md),

                // Category
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    prefixIcon: Icon(Icons.category_rounded),
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
                const SizedBox(height: Spacing.md),

                // Description
                TextField(
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    hintText: 'Jelaskan keluhan Anda...',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: Spacing.md),

                // Image
                OutlinedButton.icon(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image =
                        await picker.pickImage(source: ImageSource.camera);
                    if (image != null) {
                      setModalState(() => imagePath = image.path);
                    }
                  },
                  icon: Icon(
                    imagePath != null
                        ? Icons.check_circle_rounded
                        : Icons.camera_alt_rounded,
                  ),
                  label: Text(
                    imagePath != null ? 'Foto terlampir' : 'Ambil Foto (Opsional)',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: imagePath != null
                        ? context.successColor
                        : context.primaryColor,
                    side: BorderSide(
                      color: imagePath != null
                          ? context.successColor
                          : context.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: Spacing.lg),

                // Submit
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (titleController.text.isEmpty ||
                          descriptionController.text.isEmpty) {
                        ToastHelper.error('Harap isi semua field');
                        return;
                      }

                      final tenantAuthProvider =
                          context.read<TenantAuthProvider>();
                      final complaintProvider =
                          context.read<ComplaintProvider>();

                      final success = await tenantAuthProvider.submitComplaint(
                        title: titleController.text,
                        description: descriptionController.text,
                        category: selectedCategory,
                        imageUrl: imagePath,
                      );

                      if (context.mounted) {
                        Navigator.pop(modalContext);
                        if (success) {
                          ToastHelper.success('Keluhan berhasil dibuat');
                          await complaintProvider.fetchComplaints();
                        } else {
                          ToastHelper.error(
                            tenantAuthProvider.errorMessage ??
                                'Gagal membuat keluhan',
                          );
                        }
                      }
                    },
                    child: const Text('Kirim Keluhan'),
                  ),
                ),
                const SizedBox(height: Spacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes} menit lalu';
      }
      return '${diff.inHours} jam lalu';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari lalu';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
}