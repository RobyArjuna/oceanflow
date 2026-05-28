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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: item.isRead ? Colors.white : OceanColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.isRead ? OceanColors.grey200 : OceanColors.primary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: item.isRead ? Colors.transparent : OceanColors.primary,
                width: 4,
              ),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            title: Text(
              item.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: item.isRead ? FontWeight.w500 : FontWeight.w600,
                color: OceanColors.grey900,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  item.body,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: OceanColors.grey600,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.createdAt.substring(11, 16),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: OceanColors.grey400,
                  ),
                ),
              ],
            ),
            trailing: !item.isRead
                ? IconButton(
                    icon: const Icon(Icons.done_all_rounded, size: 18, color: OceanColors.primary),
                    tooltip: 'Mark read',
                    onPressed: () {
                      ref.read(notificationListProvider.notifier).markAsRead(item.id);
                    },
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
