/// Configuración de entorno de la app.
/// Un único proyecto Firebase (`lequinthotel-ca6ef`) es compartido con el
/// sistema web — no hay entornos dev/staging/prod separados (ver
/// docs/project/decisions.md DECISION-017).
abstract final class AppConfig {
  static const appName = 'Le Quint';
  static const firebaseProjectId = 'lequinthotel-ca6ef';
}
