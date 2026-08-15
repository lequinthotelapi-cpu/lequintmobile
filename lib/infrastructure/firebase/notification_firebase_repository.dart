import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import 'firestore_error_mapper.dart';

/// Implementación Firebase de [NotificationRepository] — ver SPEC-009.
class NotificationFirebaseRepository implements NotificationRepository {
  NotificationFirebaseRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Stream<List<AppNotification>> getByUserId(String userId) {
    final stream = _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map(AppNotification.fromFirestore).toList());
    return mapFirestoreStreamErrors(stream);
  }

  @override
  Stream<int> getUnreadCount(String userId) {
    final stream = _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
    return mapFirestoreStreamErrors(stream);
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'read': true,
      });
    } on FirebaseException catch (e) {
      throw mapFirestoreException(e);
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      final unread = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('read', isEqualTo: false)
          .get();
      if (unread.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in unread.docs) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();
    } on FirebaseException catch (e) {
      throw mapFirestoreException(e);
    }
  }
}
