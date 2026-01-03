import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastHelper {
  // Success Toast (Green)
  static void success(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // Error Toast (Red)
  static void error(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 4,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // Info Toast (Blue)
  static void info(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // Warning Toast (Orange)
  static void warning(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // Custom Toast
  static void custom({
    required String message,
    required Color backgroundColor,
    Color textColor = Colors.white,
    ToastGravity gravity = ToastGravity.TOP,
    int duration = 3,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: gravity,
      timeInSecForIosWeb: duration,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: 16.0,
    );
  }
}

// Custom Snackbar with Icon (Alternative)
class CustomSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    required SnackbarType type,
  }) {
    final theme = _getTheme(type);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(theme.icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
        backgroundColor: theme.color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: theme.duration),
      ),
    );
  }

  static _SnackbarTheme _getTheme(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return _SnackbarTheme(
          color: Colors.green,
          icon: Icons.check_circle,
          duration: 2,
        );
      case SnackbarType.error:
        return _SnackbarTheme(
          color: Colors.red,
          icon: Icons.error,
          duration: 4,
        );
      case SnackbarType.info:
        return _SnackbarTheme(
          color: Colors.blue,
          icon: Icons.info,
          duration: 3,
        );
      case SnackbarType.warning:
        return _SnackbarTheme(
          color: Colors.orange,
          icon: Icons.warning,
          duration: 3,
        );
    }
  }
}

enum SnackbarType { success, error, info, warning }

class _SnackbarTheme {
  final Color color;
  final IconData icon;
  final int duration;

  _SnackbarTheme({
    required this.color,
    required this.icon,
    required this.duration,
  });
}