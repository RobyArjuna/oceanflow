import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../providers/sync_provider.dart';
import '../../../../core/sync/models/sync_action.dart';

class SyncDashboardScreen extends ConsumerWidget {
  const SyncDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OFFLINE SYNC CONTROL PANEL'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services_rounded),
            tooltip: 'Clear Synced Records',
            onPressed: () {
              ref.read(syncListProvider.notifier).clearCompletedActions();
            },
          ),
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            tooltip: 'Process Queue Now',
            onPressed: () {
              ref.read(syncListProvider.notifier).triggerSync();
            },
          ),
        ],
      ),
      body: syncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorState(
          title: 'Sync Queue Access Failure',
          errorMessage: err.toString(),
          onRetry: () {
            ref.read(syncListProvider.notifier).loadSyncQueue();
          },
        ),
        data: (actions) {
          if (actions.isEmpty) {
            return const EmptyState(
              title: 'Sync Queue Empty',
              description: 'All offline operational updates have been fully synced to the remote server.',
              icon: Icons.cloud_done_outlined,
            );
          }

          final pendingCount = actions.where((a) => a.status == SyncStatus.pending).length;
          final doneCount = actions.where((a) => a.status == SyncStatus.done).length;
          final failedCount = actions.where((a) => a.status == SyncStatus.failed).length;

          return Column(
            children: [
              // Metrics Summary Board
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    _MetricSummaryCard(
                      label: 'Pending',
                      value: '$pendingCount',
                      color: OceanColors.warning,
                    ),
                    const SizedBox(width: 12),
                    _MetricSummaryCard(
                      label: 'Synced',
                      value: '$doneCount',
                      color: OceanColors.success,
                    ),
                    const SizedBox(width: 12),
                    _MetricSummaryCard(
                      label: 'Retrying',
                      value: '$failedCount',
                      color: OceanColors.error,
                    ),
                  ],
                ),
              ),
              const Divider(),
              
              // Queue Log list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: actions.length,
                  itemBuilder: (context, index) {
                    final action = actions[index];
                    return _SyncQueueItemTile(action: action);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MetricSummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricSummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: OceanColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
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
    );
  }
}

class _SyncQueueItemTile extends StatelessWidget {
  final SyncAction action;

  const _SyncQueueItemTile({required this.action});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(action.createdAt);
    final formattedDate = date != null
        ? DateFormat('HH:mm:ss - MMM dd').format(date)
        : 'Unknown Time';

    Color statusColor;
    IconData statusIcon;

    switch (action.status) {
      case SyncStatus.pending:
        statusColor = OceanColors.warning;
        statusIcon = Icons.hourglass_empty_rounded;
      case SyncStatus.syncing:
        statusColor = OceanColors.primary;
        statusIcon = Icons.sync_rounded;
      case SyncStatus.done:
        statusColor = OceanColors.success;
        statusIcon = Icons.cloud_done_outlined;
      case SyncStatus.failed:
        statusColor = OceanColors.error;
        statusIcon = Icons.error_outline_rounded;
      case SyncStatus.cancelled:
        statusColor = OceanColors.pending;
        statusIcon = Icons.cancel_outlined;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      action.actionType.name.toUpperCase(),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    action.status.name.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            _QueueSpecRow(label: 'Entity Code', value: action.entityId),
            _QueueSpecRow(label: 'Created At', value: formattedDate),
            _QueueSpecRow(label: 'Retries log', value: '${action.retryCount} / ${action.maxRetries}'),
            if (action.lastError != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: OceanColors.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Error: ${action.lastError}',
                  style: const TextStyle(
                    color: OceanColors.error,
                    fontSize: 10,
                    fontFamily: 'monospace',
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

class _QueueSpecRow extends StatelessWidget {
  final String label;
  final String value;

  const _QueueSpecRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: OceanColors.grey400),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
