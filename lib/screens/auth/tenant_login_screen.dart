import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/tenant_auth_provider.dart';
import '../tenant_portal/tenant_home_screen.dart';
import '../../utils/page_transitions.dart';

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
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.home_work_rounded,
                    size: 50,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Title
                Text(
                  'Portal Penyewa',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                
                const SizedBox(height: 10),
                
                // Subtitle
                Text(
                  'Masuk dengan kode kamar dan PIN Anda',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                
                const SizedBox(height: 40),
                
                // Room Code Field
                TextFormField(
                  controller: _roomCodeController,
                  decoration: InputDecoration(
                    labelText: 'Kode Kamar',
                    hintText: 'Contoh: A101, 102, B201',
                    prefixIcon: const Icon(Icons.meeting_room),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  textCapitalization: TextCapitalization.characters,
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
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: InputDecoration(
                    labelText: 'PIN',
                    hintText: '4 digit PIN',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPinVisible ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPinVisible = !_isPinVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
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
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: tenantAuthProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Masuk',
                              style: TextStyle(fontSize: 16),
                            ),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Info Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Informasi Login',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '• Kode kamar dan PIN diberikan oleh pemilik kost saat Anda check-in',
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Jika lupa PIN, silakan hubungi pemilik kost',
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Help Text
                Center(
                  child: TextButton.icon(
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
                    icon: const Icon(Icons.help_outline, size: 20),
                    label: const Text('Butuh Bantuan?'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}