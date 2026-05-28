import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../providers/notification_provider.dart';

class NotificationCenterScreen extends ConsumerWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsState = ref.watch(notificationListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NOTIFICATION CENTER'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: 'Clear notifications',
            onPressed: () {
              ref.read(notificationListProvider.notifier).clearAll();
            },
          ),
        ],
      ),
      body: notificationsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorState(
          title: 'Access Denied',
          errorMessage: err.toString(),
          onRetry: () {
            ref.read(notificationListProvider.notifier).loadNotifications();
          },
        ),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyState(
              title: 'Inbox Clean',
              description: 'You do not have any new operations reports or clearance announcements.',
              icon: Icons.notifications_none_rounded,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return _NotificationCard(item: item);
            },
          );
        },
      ),
    );
  }
}

class _NotificationCard extends ConsumerWidget {
  final AppNotification item;

  const _NotificationCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    IconData icon;
    Color color;

    switch (item.type) {
      case 'shipment_update':
        icon = Icons.directions_boat_outlined;
        color = OceanColors.primary;
      case 'sync_result':
        icon = Icons.cloud_done_outlined;
        color = OceanColors.success;
      default:
        icon = Icons.info_outline;
        color = OceanColors.teal;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: item.isRead ? null : OceanColors.surfaceElevated,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(item.body),
            const SizedBox(height: 6),
            Text(
              item.createdAt.substring(11, 16),
              style: const TextStyle(fontSize: 10, color: OceanColors.grey400),
            ),
          ],
        ),
        trailing: !item.isRead
            ? IconButton(
                icon: const Icon(Icons.done_all_rounded, size: 18),
                tooltip: 'Mark read',
                onPressed: () {
                  ref.read(notificationListProvider.notifier).markAsRead(item.id);
                },
              )
            : null,
      ),
    );
  }
}
