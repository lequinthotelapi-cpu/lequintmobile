import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/auth/auth_provider.dart';
import '../../application/notifications/notifications_provider.dart';
import '../../domain/models/notification.dart';
import '../../domain/services/notification_route_resolver.dart';
import '../notifications/notification_banner.dart';
import 'app_router.dart';

/// Conecta [FCMService] con la UI (TASK-012, SPEC-009): al autenticarse,
/// inicializa los listeners de FCM; los mensajes en foreground se muestran
/// como banner sobre [rootNavigatorKey], y el tap en push (background o
/// terminada) navega usando el mismo navigator.
///
/// No renderiza nada propio — solo envuelve [child] para tener acceso a
/// `ref` con el ciclo de vida de un widget.
class NotificationsBootstrap extends ConsumerStatefulWidget {
  const NotificationsBootstrap({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<NotificationsBootstrap> createState() =>
      _NotificationsBootstrapState();
}

class _NotificationsBootstrapState
    extends ConsumerState<NotificationsBootstrap> {
  String? _initializedUid;

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(currentUserProvider.select((u) => u?.uid), (
      previous,
      uid,
    ) {
      if (uid != null && uid != _initializedUid) {
        _initializedUid = uid;
        unawaited(_initialize(uid));
      } else if (uid == null) {
        _initializedUid = null;
      }
    });
    return widget.child;
  }

  Future<void> _initialize(String uid) {
    return ref
        .read(fcmServiceProvider)
        .initialize(
          uid: uid,
          onForegroundMessage: (notification) {
            final overlay = rootNavigatorKey.currentState?.overlay;
            if (overlay == null) return;
            showNotificationBanner(
              overlay,
              notification,
              onTap: () => _navigateFromNotification(notification),
            );
          },
          onNavigate: (route) {
            final navigatorContext = rootNavigatorKey.currentContext;
            if (navigatorContext == null) return;
            GoRouter.of(navigatorContext).push(route);
          },
        );
  }

  void _navigateFromNotification(AppNotification notification) {
    final route = resolveNotificationRoute(notification);
    final navigatorContext = rootNavigatorKey.currentContext;
    if (route != null && navigatorContext != null) {
      GoRouter.of(navigatorContext).push(route);
    }
  }
}
