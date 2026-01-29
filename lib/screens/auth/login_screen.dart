import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../home_screen.dart';
import '../splash_screen.dart';
import '../../theme/app_colors.dart';
import '../../theme/design_system.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Login gagal'),
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
            color: context.primaryColor,
            borderRadius: BorderRadius.circular(Radius.xl),
          ),
          child: Icon(
            Icons.home_work_rounded,
            size: 40,
            color: context.onPrimaryColor,
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
          'Portal Pemilik Kost',
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
              'Silakan masuk ke akun Anda',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: Spacing.lg),

            // Email Field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'nama@email.com',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email tidak boleh kosong';
                }
                if (!value.contains('@')) {
                  return 'Email tidak valid';
                }
                return null;
              },
            ),
            const SizedBox(height: Spacing.md),

            // Password Field
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleLogin(),
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: '••••••••',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password tidak boleh kosong';
                }
                if (value.length < 6) {
                  return 'Password minimal 6 karakter';
                }
                return null;
              },
            ),
            const SizedBox(height: Spacing.lg),

            // Login Button
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _handleLogin,
                    child: authProvider.isLoading
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
}