# ESTRATEGIA DE TESTING — Le Quint Mobile App

---

## Niveles de Testing

### 1. Unit Tests
**Qué se testea**: Lógica de negocio pura, modelos, utilidades, providers de Riverpod.
**Herramientas**: `flutter_test`, `mocktail`
**Cobertura mínima**: Toda la lógica de negocio crítica debe tener unit tests.

**Casos obligatorios**:
- Cálculo de noches entre fechas
- Cálculo de RevPAR, ADR, ocupación
- Validaciones de check-in (estado de reserva)
- Validaciones de check-out (balance = 0)
- Validaciones de completar tarea (estado in-progress)
- Lógica de estado de habitaciones (RoomStatusService equivalente)
- Parsing de modelos desde Firestore

### 2. Widget Tests
**Qué se testea**: Widgets individuales y pantallas con datos mockeados.
**Herramientas**: `flutter_test`, `mocktail`
**Cobertura mínima**: Pantallas críticas (login, dashboard, check-in, completar tarea).

**Casos obligatorios**:
- LoginScreen: muestra error con credenciales inválidas
- ArrivalsScreen: muestra lista vacía correctamente
- ArrivalDetailScreen: botón check-in deshabilitado si reserva no está confirmed
- DepartureDetailScreen: muestra advertencia si balance > 0
- CompleteTaskScreen: valida duración > 0
- TaskDetailScreen: muestra botón correcto según estado de tarea

### 3. Integration Tests
**Qué se testea**: Flujos completos end-to-end con Firebase emulador.
**Herramientas**: `integration_test`, Firebase Local Emulator Suite
**Cobertura mínima**: Flujos críticos del MVP.

**Flujos obligatorios**:
- Login exitoso → navegar a dashboard según rol
- Login fallido → mostrar error
- Housekeeper: ver tareas → iniciar → completar
- Receptionist: ver llegadas → check-in
- Receptionist: ver salidas → check-out (con balance = 0)

---

## Criterios de Aceptación Técnicos (Definition of Done)

Una tarea se considera terminada cuando:

1. El código compila sin errores ni warnings
2. Los unit tests pasan
3. Los widget tests de la pantalla pasan
4. El flujo funciona manualmente en simulador iOS y dispositivo Android
5. Los estados de pantalla están implementados: loading, success, empty, error
6. El comportamiento offline está verificado (desconectar red y probar)
7. Las notificaciones push llegan correctamente (si aplica a la tarea)
8. El código sigue las convenciones del proyecto (linting pasa)
9. No hay `print()` en código de producción
10. Los errores de negocio muestran mensajes específicos al usuario

---

## Convenciones de Código

- Archivos: `snake_case.dart`
- Clases: `PascalCase`
- Variables y métodos: `camelCase`
- Constantes: `kCamelCase` (convención Flutter)
- Providers: sufijo `Provider` (ej: `arrivalsProvider`)
- Screens: sufijo `Screen` (ej: `ArrivalsScreen`)
- Widgets reutilizables: sufijo `Widget` o nombre descriptivo
- Sin comentarios obvios — el código debe ser autoexplicativo
- Strings de UI en español
- Código (variables, métodos, clases) en inglés

---

## Linting

Usar `flutter_lints` con reglas adicionales:
- `avoid_print`: prohibir `print()` en producción
- `prefer_const_constructors`: widgets const cuando sea posible
- `avoid_unnecessary_containers`: no envolver en Container innecesariamente
