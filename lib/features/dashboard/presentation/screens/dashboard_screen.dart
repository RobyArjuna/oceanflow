import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../routing/route_names.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../shipment/presentation/providers/shipment_provider.dart';
import '../../../sync/presentation/providers/sync_provider.dart';
import '../../../shipment/domain/entities/shipment_entity.dart';
import '../../../../core/sync/models/sync_action.dart';
import '../../../../core/auth/auth_state.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    final shipmentsState = ref.watch(shipmentListProvider);
    final syncListState = ref.watch(syncListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OCEANFLOW CONTROL PORTAL'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout session',
            onPressed: () {
              ref.read(authStateProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Welcome Card
            _UserWelcomeBanner(
              displayName: user?.displayName ?? 'Operator',
              roleName: user?.role.name.toUpperCase() ?? 'OPERATOR',
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 20),

            // Analytics Metrics Rows
            Row(
              children: [
                Expanded(
                  child: shipmentsState.when(
                    loading: () => const _MetricBoxSkeleton(),
                    error: (_, __) => const _MetricBoxError(),
                    data: (list) {
                      final activeCount = list.where((s) => s.status != ShipmentStatus.delivered).length;
                      return _MetricSummaryCard(
                        title: 'Active Cargo',
                        value: '$activeCount',
                        icon: Icons.directions_boat_outlined,
                        color: OceanColors.primary,
                        onTap: () => context.go(RouteNames.shipments),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: syncListState.when(
                    loading: () => const _MetricBoxSkeleton(),
                    error: (_, __) => const _MetricBoxError(),
                    data: (list) {
                      final dirtyCount = list.where((s) => s.status == SyncStatus.pending).length;
                      return _MetricSummaryCard(
                        title: 'Pending Sync',
                        value: '$dirtyCount',
                        icon: Icons.cloud_sync_outlined,
                        color: OceanColors.warning,
                        onTap: () {
                          if (user?.role == UserRole.admin || user?.role == UserRole.supervisor) {
                            context.go(RouteNames.sync);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 24),

            // AI logistics assistant banner
            Card(
              child: InkWell(
                onTap: () => context.go(RouteNames.aiAssistant),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.psychology_outlined,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Logistics Scheduler',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Ask our Gemini-powered engine for ETA breakdowns, draft response reports, and vessel route risks analysis.',
                              style: TextStyle(
                                color: Color(0xBFFFFFFF),
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ).gradient(const LinearGradient(
              colors: [OceanColors.primaryDark, OceanColors.tealDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )).animate().fadeIn(duration: 500.ms, delay: 200.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 24),

            // Active shipment feed
            Text(
              'Operational Shipment Overview',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            shipmentsState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Text('Error loading shipments: $err'),
              data: (list) {
                final activeList = list.take(3).toList();
                if (activeList.isEmpty) {
                  return const Text('No operational cargo logs.');
                }

                return Column(
                  children: activeList.map((shipment) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: OceanColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.inventory_2_outlined, color: OceanColors.primary),
                        ),
                        title: Text(
                          shipment.trackingNumber,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'ETA: ${shipment.eta != null ? shipment.eta!.substring(0, 10) : "TBD"} | ${shipment.origin.split(',')[0]}',
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          context.go('${RouteNames.shipments}/detail/${shipment.id}');
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _UserWelcomeBanner extends StatelessWidget {
  final String displayName;
  final String roleName;

  const _UserWelcomeBanner({required this.displayName, required this.roleName});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: OceanColors.primary.withOpacity(0.15),
              child: const Icon(
                Icons.account_circle_outlined,
                size: 36,
                color: OceanColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: OceanColors.grey400,
                        ),
                  ),
                  Text(
                    displayName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: OceanColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      roleName,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: OceanColors.primary,
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

class _MetricSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MetricSummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: color,
                        ),
                  ),
                  Icon(icon, color: color, size: 24),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.6,
                  color: OceanColors.grey400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricBoxSkeleton extends StatelessWidget {
  const _MetricBoxSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: SizedBox(
          height: 60,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      ),
    );
  }
}

class _MetricBoxError extends StatelessWidget {
  const _MetricBoxError();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: SizedBox(
          height: 60,
          child: Center(child: Icon(Icons.error_outline, color: OceanColors.error)),
        ),
      ),
    );
  }
}

extension on Card {
  Widget gradient(Gradient gradient) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
