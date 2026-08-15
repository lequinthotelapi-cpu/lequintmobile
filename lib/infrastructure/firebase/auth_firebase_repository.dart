import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import '../../core/errors/app_exception.dart';
import '../../domain/models/user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'firestore_error_mapper.dart';

const _staleSessionThreshold = Duration(minutes: 15);
const _sessionIdChars = 'abcdefghijklmnopqrstuvwxyz0123456789';

String _generateSessionId() {
  final random = Random.secure();
  final randomPart = List.generate(
    13,
    (_) => _sessionIdChars[random.nextInt(_sessionIdChars.length)],
  ).join();
  return '${DateTime.now().millisecondsSinceEpoch}_$randomPart';
}

AppException _mapAuthException(fb_auth.FirebaseAuthException error) {
  switch (error.code) {
    case 'network-request-failed':
      return const NetworkException();
    case 'invalid-credential':
    case 'invalid-email':
    case 'user-not-found':
    case 'wrong-password':
      return const InvalidCredentialsException();
    default:
      return const UnknownException(
        'Error al iniciar sesión. Intenta nuevamente.',
      );
  }
}

/// Implementación Firebase de [AuthRepository] — ver SPEC-001.
///
/// La sesión (creación/eliminación) es un paso separado de [signIn], para
/// que la capa de aplicación (TASK-004) orqueste el flujo completo:
/// signIn → createSession → iniciar heartbeat.
class AuthFirebaseRepository implements AuthRepository {
  AuthFirebaseRepository({
    fb_auth.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? fb_auth.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final fb_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  Stream<String?> authStateChanges() =>
      _auth.authStateChanges().map((user) => user?.uid);

  @override
  Future<User> signIn({required String email, required String password}) async {
    final String uid;
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      uid = credential.user!.uid;
    } on fb_auth.FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    }

    try {
      return await _validateAndCleanupSessions(uid);
    } on AppException {
      await _auth.signOut();
      rethrow;
    } on FirebaseException catch (e) {
      await _auth.signOut();
      throw mapFirestoreException(e);
    }
  }

  /// Transacción de login (SPEC-001, regla 2): verifica `active`,
  /// `activeUntil`, limpia sesiones con `lastHeartbeat` > 15 min, y valida
  /// `activeSessionsCount < maxSessions` (superadmin sin límite).
  Future<User> _validateAndCleanupSessions(String uid) {
    final userRef = _firestore.collection('users').doc(uid);
    return _firestore.runTransaction<User>((transaction) async {
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) {
        throw const UnknownException(
          'No se encontró tu perfil de usuario. Contacta al administrador.',
        );
      }
      final user = User.fromMap(snapshot.data()!, uid);

      if (!user.active) throw const UserInactiveException();
      if (user.activeUntil != null &&
          user.activeUntil!.isBefore(DateTime.now())) {
        throw const UserExpiredException();
      }

      final isSuperadmin = user.role == UserRole.superadmin;
      final now = DateTime.now();
      final staleSessionIds = isSuperadmin
          ? const <String>[]
          : [
              for (final entry in user.sessions.entries)
                if (now.difference(entry.value.lastHeartbeat) >
                    _staleSessionThreshold)
                  entry.key,
            ];

      final currentCount = user.activeSessionsCount ?? 0;
      final realCount = isSuperadmin
          ? 0
          : max(currentCount - staleSessionIds.length, 0);

      if (!isSuperadmin) {
        final maxSessions = user.maxSessions ?? 1;
        if (realCount >= maxSessions) throw const MaxSessionsException();
      }

      if (staleSessionIds.isNotEmpty || realCount != currentCount) {
        transaction.update(userRef, {
          'activeSessionsCount': realCount,
          for (final staleId in staleSessionIds)
            'sessions.$staleId': FieldValue.delete(),
        });
      }

      return user;
    });
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<User?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return User.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw mapFirestoreException(e);
    }
  }

  @override
  Future<String> createSession(String uid) async {
    final sessionId = _generateSessionId();
    final userRef = _firestore.collection('users').doc(uid);
    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);
        final currentCount =
            (snapshot.data()?['activeSessionsCount'] as num?)?.toInt() ?? 0;
        final role =
            snapshot.data()?['role'] as String? ?? UserRole.guest.value;
        transaction.update(userRef, {
          'sessions.$sessionId': {
            'createdAt': FieldValue.serverTimestamp(),
            'lastHeartbeat': FieldValue.serverTimestamp(),
            'role': role,
            'platform': 'mobile',
          },
          'activeSessionsCount': currentCount + 1,
          'hasActiveSession': true,
        });
      });
      return sessionId;
    } on FirebaseException catch (e) {
      throw mapFirestoreException(e);
    }
  }

  @override
  Future<void> deleteSession(String uid, String sessionId) async {
    final userRef = _firestore.collection('users').doc(uid);
    try {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);
        if (!snapshot.exists) return;
        final currentCount =
            (snapshot.data()?['activeSessionsCount'] as num?)?.toInt() ?? 0;
        final newCount = max(currentCount - 1, 0);
        transaction.update(userRef, {
          'sessions.$sessionId': FieldValue.delete(),
          'activeSessionsCount': newCount,
          'hasActiveSession': newCount > 0,
        });
      });
    } on FirebaseException catch (e) {
      throw mapFirestoreException(e);
    }
  }

  @override
  Future<void> heartbeat(String uid, String sessionId) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'sessions.$sessionId.lastHeartbeat': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw mapFirestoreException(e);
    }
  }

  @override
  Future<void> saveFcmToken(String uid, String token) async {
    try {
      await _firestore.collection('users').doc(uid).update({'fcmToken': token});
    } on FirebaseException catch (e) {
      throw mapFirestoreException(e);
    }
  }
}
