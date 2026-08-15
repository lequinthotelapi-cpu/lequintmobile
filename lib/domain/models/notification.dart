import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/utils/firestore_converters.dart';

enum NotificationType {
  checkIn('check-in'),
  checkOut('check-out'),
  housekeeping('housekeeping'),
  booking('booking'),
  payment('payment'),
  inventory('inventory'),
  system('system');

  const NotificationType(this.value);

  final String value;

  static NotificationType fromValue(String? value) =>
      NotificationType.values.firstWhere(
        (type) => type.value == value,
        orElse: () => NotificationType.system,
      );
}

/// Solo 3 niveles — distinto de [TaskPriority] (que tiene 4), aunque ambos
/// se llamen "priority" en el sistema web.
enum NotificationPriority {
  low('low'),
  medium('medium'),
  high('high');

  const NotificationPriority(this.value);

  final String value;

  static NotificationPriority fromValue(String? value) =>
      NotificationPriority.values.firstWhere(
        (priority) => priority.value == value,
        orElse: () => NotificationPriority.low,
      );
}

class NotificationMetadata {
  const NotificationMetadata({
    this.bookingId,
    this.taskId,
    this.roomId,
    this.productId,
  });

  factory NotificationMetadata.fromMap(Map<String, dynamic> map) =>
      NotificationMetadata(
        bookingId: map['bookingId'] as String?,
        taskId: map['taskId'] as String?,
        roomId: map['roomId'] as String?,
        productId: map['productId'] as String?,
      );

  final String? bookingId;
  final String? taskId;
  final String? roomId;
  final String? productId;

  Map<String, dynamic> toMap() => {
    if (bookingId != null) 'bookingId': bookingId,
    if (taskId != null) 'taskId': taskId,
    if (roomId != null) 'roomId': roomId,
    if (productId != null) 'productId': productId,
  };
}

/// Nombrado `AppNotification` (no `Notification`) para evitar conflicto con
/// `dart:ui`/`flutter/material.dart`.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.read,
    required this.createdAt,
    required this.priority,
    this.actionUrl,
    this.metadata,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) =>
      AppNotification.fromMap(
        (doc.data() as Map<String, dynamic>?) ?? {},
        doc.id,
      );

  factory AppNotification.fromMap(Map<String, dynamic> map, String id) =>
      AppNotification(
        id: id,
        userId: map['userId'] as String? ?? '',
        type: NotificationType.fromValue(map['type'] as String?),
        title: map['title'] as String? ?? '',
        message: map['message'] as String? ?? '',
        read: map['read'] as bool? ?? false,
        createdAt: parseTimestamp(map['createdAt']),
        priority: NotificationPriority.fromValue(map['priority'] as String?),
        actionUrl: map['actionUrl'] as String?,
        metadata: map['metadata'] == null
            ? null
            : NotificationMetadata.fromMap(
                map['metadata'] as Map<String, dynamic>,
              ),
      );

  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String message;
  final bool read;
  final DateTime createdAt;
  final String? actionUrl;
  final NotificationPriority priority;
  final NotificationMetadata? metadata;

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'type': type.value,
    'title': title,
    'message': message,
    'read': read,
    'createdAt': Timestamp.fromDate(createdAt),
    if (actionUrl != null) 'actionUrl': actionUrl,
    'priority': priority.value,
    if (metadata != null) 'metadata': metadata!.toMap(),
  };
}
