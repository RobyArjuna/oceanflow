import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final success = await ref.read(authStateProvider.notifier).login(
          _usernameController.text,
          _passwordController.text,
        );

    if (!mounted) return;

    if (!success) {
      final errorMsg = ref.read(authStateProvider).errorMessage ?? 'Login failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: OceanColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _fillCredentials(String username) {
    setState(() {
      _usernameController.text = username;
      _passwordController.text = 'password123';
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authStateProvider);
    final isLoading = state.status == AuthStatus.loading;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Mobile layout: single column with compact branding header
          if (constraints.maxWidth < 768) {
            return Container(
              color: OceanColors.backgroundDark,
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Compact branding header for mobile
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: OceanColors.primary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: OceanColors.primary.withOpacity(0.3),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.anchor_rounded,
                                  size: 36,
                                  color: OceanColors.primary,
                                ),
                              ),
                            ).animate().fade(duration: 500.ms).scale(delay: 200.ms),
                            const SizedBox(height: 16),
                            Center(
                              child: Text(
                                'OceanFlow Logistics',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                            ).animate().fadeIn(delay: 100.ms),
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                'Maritime cargo operations platform',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: OceanColors.grey400,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ).animate().fadeIn(delay: 200.ms),
                            const SizedBox(height: 36),

                            // Login form fields
                            Text(
                              'Portal Access',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Authenticate with your credentials to access operations.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 32),

                            TextFormField(
                              controller: _usernameController,
                              enabled: !isLoading,
                              decoration: const InputDecoration(
                                labelText: 'Username or Email',
                                prefixIcon: Icon(Icons.person_outline_rounded),
                              ),
                              validator: (val) => val == null || val.isEmpty
                                  ? 'Enter your username'
                                  : null,
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _passwordController,
                              enabled: !isLoading,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(Icons.lock_outline_rounded),
                              ),
                              validator: (val) => val == null || val.isEmpty
                                  ? 'Enter your password'
                                  : null,
                            ),
                            const SizedBox(height: 24),

                            ElevatedButton(
                              onPressed: isLoading ? null : _submit,
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(Colors.white),
                                      ),
                                    )
                                  : const Text('Access Dashboard'),
                            ),

                            const SizedBox(height: 36),
                            const Divider(),
                            const SizedBox(height: 24),

                            Text(
                              'Quick-Switch Demo Profiles:',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: OceanColors.grey400,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _DemoRoleChip(
                                  label: 'Admin',
                                  onTap: () => _fillCredentials('admin'),
                                ),
                                _DemoRoleChip(
                                  label: 'Supervisor',
                                  onTap: () => _fillCredentials('supervisor'),
                                ),
                                _DemoRoleChip(
                                  label: 'Operator',
                                  onTap: () => _fillCredentials('operator'),
                                ),
                                _DemoRoleChip(
                                  label: 'Driver',
                                  onTap: () => _fillCredentials('driver'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          // Tablet/Desktop layout: side-by-side branding + form
          return Row(
            children: [
              Expanded(
                flex: 6,
                child: Container(
                  color: OceanColors.backgroundDark,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.1,
                          child: CustomPaint(
                            painter: GridPatternPainter(),
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(48.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: OceanColors.primary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: OceanColors.primary.withOpacity(0.3),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.anchor_rounded,
                                  size: 40,
                                  color: OceanColors.primary,
                                ),
                              )
                                  .animate()
                                  .fade(duration: 500.ms)
                                  .scale(delay: 200.ms),
                              const SizedBox(height: 24),
                              Text(
                                'OceanFlow Logistics',
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1, end: 0),
                              const SizedBox(height: 12),
                              Text(
                                'Real-time offline-first shipment cargo monitoring, port logistics tracking, and AI-powered operations scheduling engine.',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: OceanColors.grey400,
                                      fontSize: 16,
                                      height: 1.5,
                                    ),
                              ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1, end: 0),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                flex: 5,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Portal Access',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Authenticate with your credentials to access operations.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 32),

                            TextFormField(
                              controller: _usernameController,
                              enabled: !isLoading,
                              decoration: const InputDecoration(
                                labelText: 'Username or Email',
                                prefixIcon: Icon(Icons.person_outline_rounded),
                              ),
                              validator: (val) => val == null || val.isEmpty
                                  ? 'Enter your username'
                                  : null,
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _passwordController,
                              enabled: !isLoading,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(Icons.lock_outline_rounded),
                              ),
                              validator: (val) => val == null || val.isEmpty
                                  ? 'Enter your password'
                                  : null,
                            ),
                            const SizedBox(height: 24),

                            ElevatedButton(
                              onPressed: isLoading ? null : _submit,
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(Colors.white),
                                      ),
                                    )
                                  : const Text('Access Dashboard'),
                            ),

                            const SizedBox(height: 36),
                            const Divider(),
                            const SizedBox(height: 24),

                            Text(
                              'Quick-Switch Demo Profiles:',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: OceanColors.grey400,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _DemoRoleChip(
                                  label: 'Admin',
                                  onTap: () => _fillCredentials('admin'),
                                ),
                                _DemoRoleChip(
                                  label: 'Supervisor',
                                  onTap: () => _fillCredentials('supervisor'),
                                ),
                                _DemoRoleChip(
                                  label: 'Operator',
                                  onTap: () => _fillCredentials('operator'),
                                ),
                                _DemoRoleChip(
                                  label: 'Driver',
                                  onTap: () => _fillCredentials('driver'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DemoRoleChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DemoRoleChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.4),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_circle_outlined, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = OceanColors.primary.withOpacity(0.1)
      ..strokeWidth = 1.0;

    const step = 40.0;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
