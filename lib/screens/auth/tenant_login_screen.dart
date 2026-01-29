import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/tenant_auth_provider.dart';
import '../tenant_portal/tenant_home_screen.dart';
import '../../utils/page_transitions.dart';
import '../splash_screen.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_system.dart';

class TenantLoginScreen extends StatefulWidget {
  const TenantLoginScreen({super.key});

  @override
  State<TenantLoginScreen> createState() => _TenantLoginScreenState();
}

class _TenantLoginScreenState extends State<TenantLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roomCodeController = TextEditingController();
  final _accessCodeController = TextEditingController();
  bool _isAccessCodeVisible = false;

  @override
  void dispose() {
    _roomCodeController.dispose();
    _accessCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final tenantAuthProvider = context.read<TenantAuthProvider>();

    final success = await tenantAuthProvider.loginWithRoomCode(
      roomCode: _roomCodeController.text.trim().toUpperCase(),
      pinCode: _accessCodeController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      AppNavigator.pushAndRemoveAll(
        context,
        const TenantHomeScreen(),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tenantAuthProvider.errorMessage ?? 'Login gagal'),
          backgroundColor: context.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.of(context).canPop(),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const SplashScreen()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: Column(
                children: [
                  // Back Button
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () {
                        final nav = Navigator.of(context);
                        if (nav.canPop()) {
                          nav.pop();
                        } else {
                          nav.pushReplacement(
                            MaterialPageRoute(builder: (_) => const SplashScreen()),
                          );
                        }
                      },
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: context.textPrimary,
                      ),
                    ),
                  ),

                  const SizedBox(height: Spacing.xl),

                  // Logo Section
                  _buildLogoSection(),

                  const SizedBox(height: Spacing.xxl),

                  // Login Form
                  _buildLoginForm(),

                  const SizedBox(height: Spacing.lg),

                  // Info Card
                  _buildInfoCard(),

                  const SizedBox(height: Spacing.xl),

                  // Footer
                  Text(
                    '© 2025 JagaKost',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        // Logo Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: context.secondaryColor,
            borderRadius: BorderRadius.circular(Radius.xl),
          ),
          child: const Icon(
            Icons.person_rounded,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: Spacing.md),

        // App Name
        Text(
          'JagaKost',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: context.primaryColor,
          ),
        ),
        const SizedBox(height: Spacing.xs),

        // Subtitle
        Text(
          'Portal Penyewa',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: context.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return AppCard(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Text(
              'Masuk',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              'Masukkan kode kamar dan akses Anda',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.lg),

            // Room Code Field
            TextFormField(
              controller: _roomCodeController,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Kode Kamar',
                hintText: 'Contoh: A101',
                prefixIcon: Icon(Icons.meeting_room_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Kode kamar tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: Spacing.md),

            // Access Code Field
            TextFormField(
              controller: _accessCodeController,
              obscureText: !_isAccessCodeVisible,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleLogin(),
              decoration: InputDecoration(
                labelText: 'Kode Akses',
                hintText: '••••••',
                prefixIcon: const Icon(Icons.key_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isAccessCodeVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      _isAccessCodeVisible = !_isAccessCodeVisible;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Kode akses tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: Spacing.lg),

            // Login Button
            Consumer<TenantAuthProvider>(
              builder: (context, tenantAuthProvider, _) {
                return SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: tenantAuthProvider.isLoading ? null : _handleLogin,
                    child: tenantAuthProvider.isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.onPrimaryColor,
                            ),
                          )
                        : const Text('Masuk'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: context.infoLightColor,
        borderRadius: BorderRadius.circular(Radius.md),
        border: Border.all(
          color: context.infoColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: context.infoColor,
            size: 20,
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Belum punya kode akses?',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: context.infoColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hubungi pemilik kost untuk mendapatkan kode kamar dan kode akses Anda.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.infoColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
