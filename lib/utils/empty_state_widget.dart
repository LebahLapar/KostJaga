import 'package:flutter/material.dart';

/// Empty State Widget dengan berbagai preset untuk berbagai skenario
class EmptyStateWidget extends StatelessWidget {
  final String icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.iconColor,
  });

  // Preset: No Complaints
  factory EmptyStateWidget.noComplaints({
    VoidCallback? onCreateComplaint,
  }) {
    return EmptyStateWidget(
      icon: '📋',
      title: 'Belum Ada Keluhan',
      message: 'Anda belum memiliki keluhan.\nTap tombol di bawah untuk membuat keluhan baru.',
      actionLabel: onCreateComplaint != null ? 'Buat Keluhan' : null,
      onAction: onCreateComplaint,
      iconColor: Colors.blue,
    );
  }

  // Preset: No Payments
  factory EmptyStateWidget.noPayments() {
    return const EmptyStateWidget(
      icon: '💰',
      title: 'Belum Ada Tagihan',
      message: 'Anda belum memiliki tagihan pembayaran.\nTagihan akan muncul di sini setelah owner membuatnya.',
      iconColor: Colors.orange,
    );
  }

  // Preset: No Filtered Results
  factory EmptyStateWidget.noFilterResults({
    required String filterName,
    VoidCallback? onClearFilter,
  }) {
    return EmptyStateWidget(
      icon: '🔍',
      title: 'Tidak Ada Data',
      message: 'Tidak ada data dengan filter "$filterName".\nCoba ubah filter atau reset pencarian.',
      actionLabel: onClearFilter != null ? 'Reset Filter' : null,
      onAction: onClearFilter,
      iconColor: Colors.grey,
    );
  }

  // Preset: No Rooms (Owner)
  factory EmptyStateWidget.noRooms({
    VoidCallback? onAddRoom,
  }) {
    return EmptyStateWidget(
      icon: '🏠',
      title: 'Belum Ada Kamar',
      message: 'Mulai dengan menambahkan kamar kost Anda.\nTap tombol di bawah untuk menambah kamar.',
      actionLabel: onAddRoom != null ? 'Tambah Kamar' : null,
      onAction: onAddRoom,
      iconColor: Colors.green,
    );
  }

  // Preset: No Tenants (Owner)
  factory EmptyStateWidget.noTenants({
    VoidCallback? onAddTenant,
  }) {
    return EmptyStateWidget(
      icon: '👥',
      title: 'Belum Ada Penyewa',
      message: 'Belum ada penyewa yang terdaftar.\nTambahkan penyewa untuk mulai mengelola kost Anda.',
      actionLabel: onAddTenant != null ? 'Tambah Penyewa' : null,
      onAction: onAddTenant,
      iconColor: Colors.purple,
    );
  }

  // Preset: No Search Results
  factory EmptyStateWidget.noSearchResults({
    required String query,
  }) {
    return EmptyStateWidget(
      icon: '🔎',
      title: 'Tidak Ditemukan',
      message: 'Tidak ada hasil untuk pencarian "$query".\nCoba gunakan kata kunci yang berbeda.',
      iconColor: Colors.grey[600],
    );
  }

  // Preset: Network Error
  factory EmptyStateWidget.networkError({
    VoidCallback? onRetry,
  }) {
    return EmptyStateWidget(
      icon: '📡',
      title: 'Koneksi Bermasalah',
      message: 'Tidak dapat terhubung ke server.\nPastikan koneksi internet Anda aktif.',
      actionLabel: onRetry != null ? 'Coba Lagi' : null,
      onAction: onRetry,
      iconColor: Colors.red,
    );
  }

  // Preset: Loading Failed
  factory EmptyStateWidget.loadFailed({
    VoidCallback? onRetry,
  }) {
    return EmptyStateWidget(
      icon: '⚠️',
      title: 'Gagal Memuat Data',
      message: 'Terjadi kesalahan saat memuat data.\nSilakan coba lagi.',
      actionLabel: onRetry != null ? 'Muat Ulang' : null,
      onAction: onRetry,
      iconColor: Colors.orange,
    );
  }

  // Preset: Maintenance
  factory EmptyStateWidget.maintenance() {
    return const EmptyStateWidget(
      icon: '🔧',
      title: 'Dalam Perbaikan',
      message: 'Fitur ini sedang dalam perbaikan.\nMohon coba beberapa saat lagi.',
      iconColor: Colors.blue,
    );
  }

  // Preset: Coming Soon
  factory EmptyStateWidget.comingSoon({
    required String featureName,
  }) {
    return EmptyStateWidget(
      icon: '🚀',
      title: 'Segera Hadir',
      message: 'Fitur $featureName akan segera tersedia.\nNantikan update selanjutnya!',
      iconColor: Colors.purple,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: (iconColor ?? Colors.grey).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 56),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),

            // Action Button (if provided)
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Simple Empty State (minimalis untuk space terbatas)
class SimpleEmptyState extends StatelessWidget {
  final String icon;
  final String message;

  const SimpleEmptyState({
    super.key,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}