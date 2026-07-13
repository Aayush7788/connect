import 'package:connect_app/src/data/engagement_models.dart';
import 'package:connect_app/src/features/engagement/engagement_controller.dart';
import 'package:connect_app/src/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(engagementControllerProvider.notifier).loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(engagementControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: state.isLoadingNotifications && state.notifications.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.notifications.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_none_outlined,
                    size: 44,
                    color: connectTeal,
                  ),
                  SizedBox(height: 12),
                  Text('No notifications'),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () => ref
                  .read(engagementControllerProvider.notifier)
                  .loadNotifications(),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.notifications.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final notification = state.notifications[index];
                  return _NotificationCard(
                    notification: notification,
                    onTap: () => ref
                        .read(engagementControllerProvider.notifier)
                        .markRead(notification.id),
                  );
                },
              ),
            ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification, required this.onTap});

  final NotificationResult notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final unread = notification.readAt == null;
    return AppCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              color: unread ? connectAmber : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 5),
                Text(notification.message),
                const SizedBox(height: 8),
                Text(
                  _dateTime(notification.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _dateTime(DateTime value) {
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/${local.year}  $hour:$minute';
  }
}
