import '../../core/errors/app_exception.dart';
import '../../domain/models/user.dart';

/// Estado de autenticación de la app — ver SPEC-001 y TASK-004.
///
/// [AuthInitial] cubre tanto el valor inicial como la verificación de
/// sesión al abrir la app (FA-001): no se usa [AuthLoading] para esa
/// verificación, para poder distinguirla del envío del formulario de login.
sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  final User user;
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthError extends AuthState {
  const AuthError(this.error);

  final AppException error;
}
