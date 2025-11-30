import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

// === FORMAT HELPERS ===
class FormatHelper {
  // Format currency IDR
  static String formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  // Format date
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  // Format date with time
  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date);
  }

  // Format phone number
  static String formatPhone(String phone) {
    // Remove any non-digit characters
    String cleaned = phone.replaceAll(RegExp(r'\D'), '');
    
    // Add country code if not present
    if (!cleaned.startsWith('62')) {
      if (cleaned.startsWith('0')) {
        cleaned = '62${cleaned.substring(1)}';
      } else {
        cleaned = '62$cleaned';
      }
    }
    
    return cleaned;
  }
}

// === WHATSAPP HELPER ===
class WhatsAppHelper {
  // Send payment reminder via WhatsApp
  static Future<void> sendPaymentReminder({
    required String phone,
    required String tenantName,
    required String roomNumber,
    required double amount,
    required DateTime dueDate,
  }) async {
    final formattedPhone = FormatHelper.formatPhone(phone);
    final formattedAmount = FormatHelper.formatCurrency(amount);
    final formattedDate = FormatHelper.formatDate(dueDate);
    
    final message = '''
Halo $tenantName,

Ini adalah pengingat pembayaran kost untuk:
🏠 Kamar: $roomNumber
💰 Jumlah: $formattedAmount
📅 Jatuh Tempo: $formattedDate

Mohon segera lakukan pembayaran sebelum tanggal jatuh tempo.

Terima kasih!
JagaKost Management
''';

    final url = 'https://wa.me/$formattedPhone?text=${Uri.encodeComponent(message)}';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch WhatsApp';
    }
  }

  // Send general message via WhatsApp
  static Future<void> sendMessage({
    required String phone,
    required String message,
  }) async {
    final formattedPhone = FormatHelper.formatPhone(phone);
    final url = 'https://wa.me/$formattedPhone?text=${Uri.encodeComponent(message)}';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch WhatsApp';
    }
  }
}

// === NOTIFICATION HELPER ===
class NotificationHelper {
  // Show snackbar
  static void showSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Show success message
  static void showSuccess(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: Colors.green,
    );
  }

  // Show error message
  static void showError(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: Colors.red,
    );
  }

  // Show info message
  static void showInfo(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: Colors.blue,
    );
  }

  // Show warning message
  static void showWarning(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: Colors.orange,
    );
  }
}

// === VALIDATION HELPER ===
class ValidationHelper {
  // Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    
    return null;
  }

  // Validate phone
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }
    
    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length < 10 || cleaned.length > 13) {
      return 'Nomor telepon tidak valid';
    }
    
    return null;
  }

  // Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  // Validate number
  static String? validateNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    
    if (double.tryParse(value) == null) {
      return '$fieldName harus berupa angka';
    }
    
    return null;
  }

  // Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    
    return null;
  }

  // Validate confirm password
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    
    if (value != password) {
      return 'Password tidak cocok';
    }
    
    return null;
  }
}

// Continue in Part 2...

// Continuation from Part 1...

// === DIALOG HELPER ===
class DialogHelper {
  // Show confirmation dialog
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Ya',
    String cancelText = 'Batal',
    Color? confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? Colors.red,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  // Show loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(message),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
}

// === DATE HELPER ===
class DateHelper {
  // Check if date is overdue
  static bool isOverdue(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  // Get days until date
  static int daysUntil(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(DateTime(now.year, now.month, now.day));
    return difference.inDays;
  }

  // Get days since date
  static int daysSince(DateTime date) {
    final now = DateTime.now();
    final difference = DateTime(now.year, now.month, now.day).difference(date);
    return difference.inDays;
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Check if date is this month
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  // Get next month due date
  static DateTime getNextMonthDueDate(DateTime lastDueDate) {
    return DateTime(
      lastDueDate.month == 12 ? lastDueDate.year + 1 : lastDueDate.year,
      lastDueDate.month == 12 ? 1 : lastDueDate.month + 1,
      lastDueDate.day,
    );
  }
}

// === COLOR HELPER ===
class ColorHelper {
  // Get status color
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
      case 'active':
      case 'paid':
      case 'resolved':
        return Colors.green;
      
      case 'occupied':
      case 'pending':
      case 'in_progress':
        return Colors.orange;
      
      case 'maintenance':
      case 'inactive':
      case 'overdue':
        return Colors.red;
      
      default:
        return Colors.grey;
    }
  }

  // Get room type color
  static Color getRoomTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'single':
        return Colors.blue;
      case 'double':
        return Colors.purple;
      case 'shared':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}

// === CONSTANTS ===
class AppConstants {
  // Room types
  static const List<String> roomTypes = ['single', 'double', 'shared'];
  
  // Room statuses
  static const List<String> roomStatuses = ['available', 'occupied', 'maintenance'];
  
  // Tenant statuses
  static const List<String> tenantStatuses = ['active', 'inactive'];
  
  // Payment statuses
  static const List<String> paymentStatuses = ['pending', 'paid', 'overdue'];
  
  // Complaint categories
  static const List<String> complaintCategories = [
    'maintenance',
    'cleanliness',
    'facility',
    'other',
  ];
  
  // Complaint statuses
  static const List<String> complaintStatuses = [
    'pending',
    'in_progress',
    'resolved',
  ];
  
  // Get localized room type
  static String getRoomTypeLabel(String type) {
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
  
  // Get localized status
  static String getStatusLabel(String status) {
    switch (status) {
      case 'available':
        return 'Tersedia';
      case 'occupied':
        return 'Terisi';
      case 'maintenance':
        return 'Maintenance';
      case 'active':
        return 'Aktif';
      case 'inactive':
        return 'Tidak Aktif';
      case 'pending':
        return 'Pending';
      case 'paid':
        return 'Lunas';
      case 'overdue':
        return 'Terlambat';
      case 'in_progress':
        return 'Diproses';
      case 'resolved':
        return 'Selesai';
      default:
        return status;
    }
  }
}