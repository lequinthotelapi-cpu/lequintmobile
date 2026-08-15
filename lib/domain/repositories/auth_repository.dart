import '../models/user.dart';

/// Contrato de autenticación y sesiones — ver SPEC-001.
abstract interface class AuthRepository {
  /// Uid del usuario actualmente autenticado en Firebase Auth, o `null` si
  /// no hay sesión. Lectura síncrona del estado local del SDK.
  String? get currentUserId;

  /// Emite el uid del usuario autenticado, o `null` al cerrar sesión.
  Stream<String?> authStateChanges();

  /// Autentica con email/contraseña y devuelve los datos del usuario desde
  /// Firestore. Lanza [InvalidCredentialsException], [UserInactiveException],
  /// [UserExpiredException] o [MaxSessionsException] según corresponda.
  Future<User> signIn({required String email, required String password});

  Future<void> signOut();

  Future<User?> getUserData(String uid);

  /// Crea una nueva sesión en `users/{uid}.sessions.{sessionId}` y
  /// devuelve el `sessionId` generado.
  Future<String> createSession(String uid);

  Future<void> deleteSession(String uid, String sessionId);

  /// Actualiza `lastHeartbeat` de la sesión activa.
  Future<void> heartbeat(String uid, String sessionId);

  /// Guarda el token FCM del dispositivo en `users/{uid}.fcmToken`.
  Future<void> saveFcmToken(String uid, String token);
}
