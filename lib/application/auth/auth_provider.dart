import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/models/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../infrastructure/firebase/auth_firebase_repository.dart';
import '../../infrastructure/services/session_service.dart';
import 'auth_state.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthFirebaseRepository();
});

final sessionServiceProvider = Provider<SessionService>((ref) {
  final service = SessionService(ref.watch(authRepositoryProvider));
  ref.onDispose(service.dispose);
  return service;
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  return AuthNotifier(
    ref.watch(authRepositoryProvider),
    ref.watch(sessionServiceProvider),
  );
});

/// Usuario autenticado actual, o `null` si no hay sesión — conveniencia
/// para pantallas que solo necesitan leer el usuario sin manejar todos los
/// estados de [AuthState].
final currentUserProvider = Provider<User?>((ref) {
  final state = ref.watch(authNotifierProvider);
  return state is AuthAuthenticated ? state.user : null;
});

final currentUserRoleProvider = Provider<UserRole?>((ref) {
  return ref.watch(currentUserProvider)?.role;
});

/// Orquesta el flujo completo de autenticación (SPEC-001): login, creación
/// y persistencia de sesión, heartbeat, token FCM, y logout.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authRepository, this._sessionService)
    : super(const AuthInitial()) {
    _restoreSession();
  }

  final AuthRepository _authRepository;
  final SessionService _sessionService;

  /// FA-001: si Firebase Auth ya tiene una sesión válida al abrir la app,
  /// verifica que el usuario siga activo y retoma el heartbeat con el
  /// `sessionId` persistido — sin volver a ejecutar la transacción de login.
  Future<void> _restoreSession() async {
    final uid = _authRepository.currentUserId;
    if (uid == null) {
      state = const AuthUnauthenticated();
      return;
    }

    try {
      final user = await _authRepository.getUserData(uid);
      final expired =
          user?.activeUntil != null &&
          user!.activeUntil!.isBefore(DateTime.now());
      if (user == null || !user.active || expired) {
        await _authRepository.signOut();
        await _sessionService.clearSessionId();
        state = const AuthUnauthenticated();
        return;
      }

      final sessionId = await _sessionService.getStoredSessionId();
      if (sessionId != null) {
        _sessionService.startHeartbeat(uid, sessionId);
      }
      state = AuthAuthenticated(user);
    } catch (_) {
      state = const AuthUnauthenticated();
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AuthLoading();
    try {
      final user = await _authRepository.signIn(
        email: email,
        password: password,
      );
      final sessionId = await _authRepository.createSession(user.uid);
      await _sessionService.persistSessionId(sessionId);
      _sessionService.startHeartbeat(user.uid, sessionId);
      await _saveFcmToken(user.uid);
      state = AuthAuthenticated(user);
    } on AppException catch (e) {
      state = AuthError(e);
    } catch (_) {
      state = const AuthError(UnknownException());
    }
  }

  /// Best-effort: si el usuario deniega permisos o falla la obtención del
  /// token, el login no se bloquea (SPEC-009).
  Future<void> _saveFcmToken(String uid) async {
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;
      final token = await messaging.getToken();
      if (token != null) await _authRepository.saveFcmToken(uid, token);
    } catch (_) {
      // No bloquea el login — ver SPEC-009.
    }
  }

  Future<void> signOut() async {
    final current = state;
    _sessionService.stopHeartbeat();
    if (current is AuthAuthenticated) {
      final sessionId = await _sessionService.getStoredSessionId();
      if (sessionId != null) {
        try {
          await _authRepository.deleteSession(current.user.uid, sessionId);
        } catch (_) {
          // La sesión local se cierra igual aunque falle la limpieza remota.
        }
      }
    }
    await _sessionService.clearSessionId();
    await _authRepository.signOut();
    state = const AuthUnauthenticated();
  }
}
