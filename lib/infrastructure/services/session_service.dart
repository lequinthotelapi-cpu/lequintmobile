import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/repositories/auth_repository.dart';

const _heartbeatInterval = Duration(minutes: 5);
const _sessionIdStorageKey = 'session_id';

/// Orquesta el heartbeat de sesión adaptado al ciclo de vida móvil
/// (ADR-006): timer cada 5 min solo en foreground, pausado en background,
/// con heartbeat inmediato al volver a foreground. También persiste el
/// `sessionId` localmente (SPEC-001) para poder retomar la sesión entre
/// reinicios de la app.
///
/// La escritura del documento de sesión en Firestore (crear/eliminar) vive
/// en [AuthRepository] (TASK-003) — este servicio solo administra el timer
/// local y el almacenamiento seguro del `sessionId`.
class SessionService with WidgetsBindingObserver {
  SessionService(this._authRepository, {FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final AuthRepository _authRepository;
  final FlutterSecureStorage _storage;

  Timer? _heartbeatTimer;
  String? _uid;
  String? _sessionId;
  bool _observing = false;

  Future<void> persistSessionId(String sessionId) =>
      _storage.write(key: _sessionIdStorageKey, value: sessionId);

  Future<String?> getStoredSessionId() =>
      _storage.read(key: _sessionIdStorageKey);

  Future<void> clearSessionId() => _storage.delete(key: _sessionIdStorageKey);

  void startHeartbeat(String uid, String sessionId) {
    _uid = uid;
    _sessionId = sessionId;
    if (!_observing) {
      WidgetsBinding.instance.addObserver(this);
      _observing = true;
    }
    _scheduleTimer();
  }

  void stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _uid = null;
    _sessionId = null;
    if (_observing) {
      WidgetsBinding.instance.removeObserver(this);
      _observing = false;
    }
  }

  void _scheduleTimer() {
    _heartbeatTimer?.cancel();
    unawaited(_sendHeartbeat());
    _heartbeatTimer = Timer.periodic(
      _heartbeatInterval,
      (_) => _sendHeartbeat(),
    );
  }

  Future<void> _sendHeartbeat() async {
    final uid = _uid;
    final sessionId = _sessionId;
    if (uid == null || sessionId == null) return;
    try {
      await _authRepository.heartbeat(uid, sessionId);
    } catch (_) {
      // El heartbeat es best-effort: un fallo puntual no debe cerrar la
      // sesión local ni interrumpir el uso de la app.
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _heartbeatTimer?.cancel();
        _heartbeatTimer = null;
      case AppLifecycleState.resumed:
        if (_uid != null && _sessionId != null) _scheduleTimer();
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.inactive:
        break;
    }
  }

  void dispose() => stopHeartbeat();
}
