import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../providers/tenant_auth_provider.dart';
import '../tenant_portal/tenant_home_screen.dart';
import '../../utils/page_transitions.dart';
import '../splash_screen.dart';

class TenantLoginScreen extends StatefulWidget {
  const TenantLoginScreen({super.key});

  @override
  State<TenantLoginScreen> createState() => _TenantLoginScreenState();
}

class _TenantLoginScreenState extends State<TenantLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roomCodeController = TextEditingController();
  final _pinCodeController = TextEditingController();
  bool _isPinVisible = false;

  @override
  void dispose() {
    _roomCodeController.dispose();
    _pinCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final tenantAuthProvider = context.read<TenantAuthProvider>();
    
    final success = await tenantAuthProvider.loginWithRoomCode(
      roomCode: _roomCodeController.text.trim(),
      pinCode: _pinCodeController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      // Login berhasil, navigate ke tenant home
      AppNavigator.replaceWith(
        context,
        const TenantHomeScreen(),
        useSlide: false, // Use fade untuk login → dashboard
      );
    } else {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tenantAuthProvider.errorMessage ?? 'Login gagal',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).canPop()) return true;
        // If this is the only route, replace it with SplashScreen instead of popping to avoid a black screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SplashScreen()),
        );
        return false;
      },
      child: Scaffold(
        body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_background.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback gradient untuk tenant (Green theme)
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF4CAF50),
                        Color(0xFF388E3C),
                        Color(0xFF2E7D32),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Dark Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Back Button with Glass Effect
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          final nav = Navigator.of(context);
                          if (nav.canPop()) {
                            nav.pop();
                          } else {
                            // Replace with SplashScreen to avoid leaving an empty navigator
                            nav.pushReplacement(
                              MaterialPageRoute(builder: (_) => const SplashScreen()),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),

                // Main Content
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo with Glass Effect
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: Column(
                              children: [
                                // Logo Icon
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.home_work_rounded,
                                    size: 40,
                                    color: Color(0xFF4CAF50),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Title
                                const Text(
                                  'Portal Penyewa',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Subtitle
                                Text(
                                  'Masuk dengan kode kamar dan PIN Anda',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.9),
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Login Form with Glassmorphism
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1.5,
                                  ),
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // Room Code Field
                                      TextFormField(
                                        controller: _roomCodeController,
                                        style: const TextStyle(color: Colors.white),
                                        textCapitalization: TextCapitalization.characters,
                                        decoration: InputDecoration(
                                          labelText: 'Kode Kamar',
                                          labelStyle: TextStyle(
                                            color: Colors.white.withOpacity(0.8),
                                          ),
                                          hintText: 'Contoh: A101, 102, B201',
                                          hintStyle: TextStyle(
                                            color: Colors.white.withOpacity(0.4),
                                          ),
                                          prefixIcon: Icon(
                                            Icons.meeting_room,
                                            color: Colors.white.withOpacity(0.8),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white.withOpacity(0.1),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: Colors.white.withOpacity(0.3),
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: Colors.white.withOpacity(0.3),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                          errorStyle: const TextStyle(
                                            color: Colors.yellowAccent,
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Kode kamar tidak boleh kosong';
                                          }
                                          return null;
                                        },
                                      ),

                                      const SizedBox(height: 16),

                                      // PIN Field
                                      TextFormField(
                                        controller: _pinCodeController,
                                        obscureText: !_isPinVisible,
                                        style: const TextStyle(color: Colors.white),
                                        keyboardType: TextInputType.number,
                                        maxLength: 4,
                                        decoration: InputDecoration(
                                          labelText: 'PIN',
                                          labelStyle: TextStyle(
                                            color: Colors.white.withOpacity(0.8),
                                          ),
                                          hintText: '4 digit PIN',
                                          hintStyle: TextStyle(
                                            color: Colors.white.withOpacity(0.4),
                                          ),
                                          prefixIcon: Icon(
                                            Icons.lock_outline,
                                            color: Colors.white.withOpacity(0.8),
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _isPinVisible
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                              color: Colors.white.withOpacity(0.8),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _isPinVisible = !_isPinVisible;
                                              });
                                            },
                                          ),
                                          filled: true,
                                          fillColor: Colors.white.withOpacity(0.1),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: Colors.white.withOpacity(0.3),
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: Colors.white.withOpacity(0.3),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                          errorStyle: const TextStyle(
                                            color: Colors.yellowAccent,
                                          ),
                                          counterText: '',
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'PIN tidak boleh kosong';
                                          }
                                          if (value.length != 4) {
                                            return 'PIN harus 4 digit';
                                          }
                                          return null;
                                        },
                                      ),

                                      const SizedBox(height: 24),

                                      // Login Button
                                      Consumer<TenantAuthProvider>(
                                        builder: (context, tenantAuthProvider, _) {
                                          return ElevatedButton(
                                            onPressed: tenantAuthProvider.isLoading 
                                                ? null 
                                                : _handleLogin,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              foregroundColor: const Color(0xFF4CAF50),
                                              padding: const EdgeInsets.symmetric(vertical: 16),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              elevation: 8,
                                              shadowColor: Colors.black.withOpacity(0.3),
                                            ),
                                            child: tenantAuthProvider.isLoading
                                                ? const SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor: AlwaysStoppedAnimation<Color>(
                                                        Color(0xFF4CAF50),
                                                      ),
                                                    ),
                                                  )
                                                : const Text(
                                                    'Masuk',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      letterSpacing: 0.5,
                                                    ),
                                                  ),
                                          );
                                        },
                                      ),

                                      const SizedBox(height: 16),

                                      // Info Box
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.blue.withOpacity(0.3),
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              color: Colors.white.withOpacity(0.9),
                                              size: 20,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Informasi Login',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '• Kode kamar dan PIN diberikan oleh pemilik kost saat Anda check-in',
                                                    style: TextStyle(
                                                      color: Colors.white.withOpacity(0.9),
                                                      fontSize: 11,
                                                      height: 1.4,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '• Jika lupa PIN, silakan hubungi pemilik kost',
                                                    style: TextStyle(
                                                      color: Colors.white.withOpacity(0.9),
                                                      fontSize: 11,
                                                      height: 1.4,
                                                    ),
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
                          ),

                          const SizedBox(height: 24),

                          // Help Button
                          TextButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Butuh Bantuan?'),
                                  content: const Text(
                                    'Hubungi pemilik kost Anda untuk mendapatkan:\n\n'
                                    '1. Kode Kamar (contoh: A101, 102)\n'
                                    '2. PIN 4 digit\n\n'
                                    'Credentials ini diberikan saat Anda check-in ke kamar.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Mengerti'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.help_outline,
                              color: Colors.white.withOpacity(0.8),
                              size: 20,
                            ),
                            label: Text(
                              'Butuh Bantuan?',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}
