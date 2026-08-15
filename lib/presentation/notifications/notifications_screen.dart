import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/auth/auth_provider.dart';
import '../../application/notifications/notifications_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/services/notification_route_resolver.dart';
import '../shared/widgets/empty_state_widget.dart';
import '../shared/widgets/error_widget.dart';
import '../shared/widgets/loading_widget.dart';
import '../shared/widgets/offline_banner.dart';
import 'widgets/notification_item.dart';

/// Centro de notificaciones — ver SPEC-009.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final user = ref.watch(currentUserProvider);

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundGradientTop,
            AppColors.backgroundGradientBottom,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Notificaciones',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          actions: [
            notificationsAsync.maybeWhen(
              data: (notifications) {
                final hasUnread = notifications.any((n) => !n.read);
                if (!hasUnread || user == null) return const SizedBox.shrink();
                return TextButton(
                  onPressed: () => ref
                      .read(notificationRepositoryProvider)
                      .markAllAsRead(user.uid),
                  child: const Text('Marcar todas ✓'),
                );
              },
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              const OfflineBanner(),
              Expanded(
                child: notificationsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: SkeletonList(count: 5, itemHeight: 84),
                  ),
                  error: (error, stackTrace) => ErrorState(
                    message: 'No se pudieron cargar las notificaciones',
                    onRetry: () => ref.invalidate(notificationsProvider),
                  ),
                  data: (notifications) {
                    if (notifications.isEmpty) {
                      return const EmptyState(
                        icon: Icons.notifications_none,
                        title: 'No tienes notificaciones',
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async =>
                          ref.invalidate(notificationsProvider),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: notifications.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return NotificationItem(
                            notification: notification,
                            onTap: () {
                              if (!notification.read) {
                                ref
                                    .read(notificationRepositoryProvider)
                                    .markAsRead(notification.id);
                              }
                              final route = resolveNotificationRoute(
                                notification,
                              );
                              if (route != null) context.push(route);
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
