# TASK-004 — Autenticación y sesiones

**ID**: TASK-004
**SPEC**: SPEC-001
**Dependencias**: TASK-003
**Estado**: PENDING

---

## Objetivo

Implementar el flujo completo de autenticación: login, verificación de usuario, control de sesiones, heartbeat adaptado al ciclo de vida móvil, y logout.

## Alcance

### 1. AuthProvider (lib/application/auth/)

```dart
// auth_state.dart
sealed class AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(AppUser user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(AppException error) = _Error;
}

// auth_provider.dart
// - signIn(email, password)
// - signOut()
// - currentUser getter
// - role getter
```

### 2. SessionService (lib/infrastructure/services/)

```dart
class SessionService with WidgetsBindingObserver {
  // generateSessionId()
  // createSession(uid, sessionId, role)
  // deleteSession(uid, sessionId)
  // startHeartbeat(uid, sessionId)
  // stopHeartbeat()
  // pauseHeartbeat()   ← AppLifecycleState.paused
  // resumeHeartbeat()  ← AppLifecycleState.resumed
  // cleanInactiveSessions(uid)  ← llamado en login
}
```

### 3. LoginScreen (lib/presentation/auth/login_screen.dart)

- Campo email con validación
- Campo contraseña con toggle mostrar/ocultar
- Botón "Iniciar sesión" con loading state
- Manejo de todos los errores de SPEC-001 (AUTH-001 a AUTH-006)
- Logo "Le Quint" centrado en la parte superior

### 4. Protección de rutas en GoRouter

```dart
// Redirect en GoRouter:
// - Si no autenticado → /login
// - Si autenticado y en /login → /dashboard (o home según rol)
```

### 5. FCM Token al login

- Después de login exitoso, obtener token FCM y guardarlo en `users/{uid}.fcmToken`

## Criterios de aceptación

- [ ] Login exitoso con credenciales válidas navega al home correcto según rol
- [ ] Login con credenciales incorrectas muestra mensaje "Correo o contraseña incorrectos"
- [ ] Login con usuario inactivo muestra mensaje específico
- [ ] Login con límite de sesiones muestra mensaje específico
- [ ] Sesión persiste al cerrar y reabrir la app
- [ ] Heartbeat se pausa en background y se reanuda en foreground
- [ ] Logout limpia sesión en Firestore y navega a LoginScreen
- [ ] Token FCM se guarda en Firestore al hacer login
- [ ] Rutas protegidas redirigen a /login si no hay sesión
- [ ] Widget test: LoginScreen muestra error con credenciales inválidas

## Notas

- Usar `flutter_secure_storage` para persistir el `sessionId` entre reinicios de la app
- El `WidgetsBindingObserver` para el heartbeat debe registrarse en el `main.dart` o en un widget raíz
- La limpieza de sesiones inactivas se hace dentro de la transacción de login (igual que el sistema web)
