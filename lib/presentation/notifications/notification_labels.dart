import 'package:flutter/material.dart';

import '../../core/extensions/date_extensions.dart';
import '../../domain/models/notification.dart';

/// Ícono por tipo de notificación — ver SPEC-009.
extension NotificationTypeIcon on NotificationType {
  IconData get icon => switch (this) {
    NotificationType.checkIn => Icons.login_outlined,
    NotificationType.checkOut => Icons.logout_outlined,
    NotificationType.housekeeping => Icons.cleaning_services_outlined,
    NotificationType.booking => Icons.event_note_outlined,
    NotificationType.payment => Icons.payments_outlined,
    NotificationType.inventory => Icons.inventory_2_outlined,
    NotificationType.system => Icons.info_outline,
  };
}

/// Tiempo relativo en español — ver SPEC-009 ("Hace 5 min", "Hace 2 horas",
/// "Ayer").
String relativeTimeEs(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inMinutes < 1) return 'Ahora';
  if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
  if (diff.inHours < 24) {
    return 'Hace ${diff.inHours} ${diff.inHours == 1 ? 'hora' : 'horas'}';
  }
  if (diff.inDays == 1) return 'Ayer';
  if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
  return dateTime.toShortDateEs();
}
