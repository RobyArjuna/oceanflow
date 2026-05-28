import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/auth_state.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

class RoleGuard extends ConsumerWidget {
  final List<UserRole> allowedRoles;
  final Widget child;
  final Widget? fallback;

  const RoleGuard({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    
    if (user != null && allowedRoles.contains(user.role)) {
      return child;
    }

    if (fallback != null) return fallback!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Access Denied'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_person_outlined,
                size: 80,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 24),
              Text(
                'Unauthorized Area',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your current role (${user?.role.name.toUpperCase()}) does not have permission to view this section. Please contact an administrator.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
