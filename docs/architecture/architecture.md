# ARQUITECTURA TÉCNICA — Le Quint Mobile App (Flutter)

**Framework**: Flutter (Dart)
**Backend**: Firebase (Firestore + Auth + FCM)

---

## 1. VISIÓN GENERAL

```
┌─────────────────────────────────────────────────────┐
│                  Flutter App                        │
│                                                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────┐  │
│  │Presentation│ │ Domain   │  │ Infrastructure   │  │
│  │ (Screens) │ │(Use Cases│  │ (Repositories    │  │
│  │ (Widgets) │ │ Models)  │  │  Firebase impl)  │  │
│  └──────────┘  └──────────┘  └──────────────────┘  │
│                                                     │
└─────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────┐
│                   Firebase                          │
│  Auth │ Firestore │ Cloud Messaging │ Storage       │
└─────────────────────────────────────────────────────┘
```

La app reutiliza directamente las colecciones Firestore existentes. No se requiere nuevo backend.

---

## 2. ARQUITECTURA DE CAPAS

### Capa de Presentación (UI)
- Screens (páginas completas)
- Widgets (componentes reutilizables)
- State management: **Riverpod** (ver ADR-003)
- Navegación: **GoRouter**

### Capa de Dominio
- Modelos de datos (equivalentes a los del sistema web)
- Interfaces de repositorios
- Use cases / lógica de negocio

### Capa de Infraestructura
- Implementaciones Firebase de repositorios
- Servicios: Auth, FCM, Storage
- Manejo de errores de red

---

## 3. ESTRUCTURA DE CARPETAS PROPUESTA

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart        # Colores de estado (habitaciones, prioridades)
│   │   └── app_routes.dart        # Rutas nombradas
│   ├── errors/
│   │   └── app_exception.dart     # Excepciones tipadas
│   ├── extensions/
│   │   └── date_extensions.dart
│   └── utils/
│       └── date_utils.dart
│
├── domain/
│   ├── models/
│   │   ├── user.dart
│   │   ├── room.dart
│   │   ├── booking.dart
│   │   ├── guest.dart
│   │   ├── guest_account.dart
│   │   ├── housekeeping_task.dart
│   │   └── notification.dart
│   └── repositories/
│       ├── auth_repository.dart
│       ├── room_repository.dart
│       ├── booking_repository.dart
│       ├── housekeeping_repository.dart
│       ├── guest_account_repository.dart
│       └── notification_repository.dart
│
├── infrastructure/
│   ├── firebase/
│   │   ├── auth_firebase_repository.dart
│   │   ├── room_firebase_repository.dart
│   │   ├── booking_firebase_repository.dart
│   │   ├── housekeeping_firebase_repository.dart
│   │   ├── guest_account_firebase_repository.dart
│   │   └── notification_firebase_repository.dart
│   └── services/
│       ├── fcm_service.dart
│       └── connectivity_service.dart
│
├── application/
│   ├── auth/
│   │   ├── auth_provider.dart
│   │   └── auth_state.dart
│   ├── dashboard/
│   │   └── dashboard_provider.dart
│   ├── rooms/
│   │   └── rooms_provider.dart
│   ├── bookings/
│   │   └── bookings_provider.dart
│   ├── housekeeping/
│   │   └── housekeeping_provider.dart
│   ├── guest_accounts/
│   │   └── guest_accounts_provider.dart
│   └── notifications/
│       └── notifications_provider.dart
│
├── presentation/
│   ├── auth/
│   │   └── login_screen.dart
│   ├── shell/
│   │   ├── shell_screen.dart       # Bottom nav + routing
│   │   └── app_shell.dart
│   ├── dashboard/
│   │   ├── dashboard_screen.dart
│   │   ├── widgets/
│   │   │   ├── operational_kpis_card.dart
│   │   │   ├── financial_kpis_card.dart
│   │   │   └── room_status_summary.dart
│   ├── rooms/
│   │   ├── rooms_screen.dart
│   │   ├── room_detail_screen.dart
│   │   └── widgets/
│   │       └── room_status_chip.dart
│   ├── front_desk/
│   │   ├── arrivals_screen.dart
│   │   ├── departures_screen.dart
│   │   ├── in_house_screen.dart
│   │   ├── arrival_detail_screen.dart
│   │   └── departure_detail_screen.dart
│   ├── housekeeping/
│   │   ├── my_tasks_screen.dart
│   │   ├── all_tasks_screen.dart
│   │   ├── task_detail_screen.dart
│   │   ├── complete_task_screen.dart
│   │   └── widgets/
│   │       └── task_priority_chip.dart
│   ├── guest_accounts/
│   │   ├── guest_account_screen.dart
│   │   └── add_charge_screen.dart
│   ├── notifications/
│   │   └── notifications_screen.dart
│   ├── profile/
│   │   └── profile_screen.dart
│   └── shared/
│       ├── widgets/
│       │   ├── loading_widget.dart
│       │   ├── empty_state_widget.dart
│       │   ├── error_widget.dart
│       │   └── offline_banner.dart
│       └── dialogs/
│           └── confirm_dialog.dart
│
├── firebase_options.dart
└── main.dart
```

---

## 4. DEPENDENCIAS PRINCIPALES (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase
  firebase_core: ^2.x
  firebase_auth: ^4.x
  cloud_firestore: ^4.x
  firebase_messaging: ^14.x
  firebase_storage: ^11.x

  # State Management
  flutter_riverpod: ^2.x
  riverpod_annotation: ^2.x

  # Navegación
  go_router: ^12.x

  # UI
  flutter_svg: ^2.x           # Íconos SVG si necesario
  cached_network_image: ^3.x  # Imágenes con caché
  shimmer: ^3.x               # Loading skeletons

  # Utilidades
  intl: ^0.18.x               # Formateo de fechas y moneda
  connectivity_plus: ^5.x     # Detección de conectividad
  shared_preferences: ^2.x    # Almacenamiento local simple
  flutter_secure_storage: ^9.x # Almacenamiento seguro (tokens)

dev_dependencies:
  flutter_test:
    sdk: flutter
  riverpod_generator: ^2.x
  build_runner: ^2.x
  flutter_lints: ^3.x
  mocktail: ^1.x              # Mocking para tests
```

---

## 5. AUTENTICACIÓN Y SESIONES

### Flujo de autenticación
```
LoginScreen
  → FirebaseAuth.signInWithEmailAndPassword()
  → Verificar usuario activo en Firestore (users/{uid}.active)
  → Verificar expiración (users/{uid}.activeUntil)
  → Verificar límite de sesiones (users/{uid}.maxSessions)
  → Crear sesión en Firestore (users/{uid}.sessions.{sessionId})
  → Iniciar heartbeat (AppLifecycleObserver)
  → Navegar a HomeScreen según rol
```

### Heartbeat adaptado a móvil
El sistema web usa `setInterval` en browser. En Flutter se usa `AppLifecycleState`:

```dart
// Heartbeat cada 5 minutos cuando la app está en foreground
// Se pausa cuando la app va a background
// Se reanuda cuando vuelve a foreground
// Se limpia al hacer logout o cuando la app se cierra
```

### Almacenamiento seguro
- Token de sesión: `flutter_secure_storage` (Keychain en iOS, Keystore en Android)
- Estado de login: `shared_preferences` (no sensible)

---

## 6. GESTIÓN DE ESTADO — Riverpod

### Providers principales

```dart
// Auth
final authStateProvider = StreamProvider<User?>(...);
final currentUserProvider = FutureProvider<AppUser?>(...);

// Dashboard
final dashboardStatsProvider = FutureProvider.family<DashboardStats, DateRange>(...);

// Rooms
final roomsWithStatusProvider = StreamProvider<List<RoomWithStatus>>(...);

// Bookings
final arrivalsProvider = StreamProvider<List<Booking>>(...);
final departuresProvider = StreamProvider<List<Booking>>(...);
final inHouseProvider = StreamProvider<List<Booking>>(...);

// Housekeeping
final myTasksProvider = StreamProvider<List<HousekeepingTask>>(...);
final allTasksProvider = StreamProvider<List<HousekeepingTask>>(...);

// Notifications
final notificationsProvider = StreamProvider<List<AppNotification>>(...);
final unreadCountProvider = StreamProvider<int>(...);

// Connectivity
final connectivityProvider = StreamProvider<ConnectivityStatus>(...);
```

---

## 7. NAVEGACIÓN — GoRouter

```dart
final router = GoRouter(
  redirect: (context, state) {
    final isLoggedIn = ref.read(authStateProvider).value != null;
    if (!isLoggedIn) return '/login';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_,__) => LoginScreen()),
    ShellRoute(
      builder: (_, __, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/dashboard', builder: (_,__) => DashboardScreen()),
        GoRoute(path: '/rooms', builder: (_,__) => RoomsScreen()),
        GoRoute(path: '/rooms/:id', builder: (_,s) => RoomDetailScreen(id: s.pathParameters['id']!)),
        GoRoute(path: '/arrivals', builder: (_,__) => ArrivalsScreen()),
        GoRoute(path: '/arrivals/:id', builder: (_,s) => ArrivalDetailScreen(id: s.pathParameters['id']!)),
        GoRoute(path: '/departures', builder: (_,__) => DeparturesScreen()),
        GoRoute(path: '/departures/:id', builder: (_,s) => DepartureDetailScreen(id: s.pathParameters['id']!)),
        GoRoute(path: '/in-house', builder: (_,__) => InHouseScreen()),
        GoRoute(path: '/my-tasks', builder: (_,__) => MyTasksScreen()),
        GoRoute(path: '/tasks', builder: (_,__) => AllTasksScreen()),
        GoRoute(path: '/tasks/:id', builder: (_,s) => TaskDetailScreen(id: s.pathParameters['id']!)),
        GoRoute(path: '/accounts/:id', builder: (_,s) => GuestAccountScreen(id: s.pathParameters['id']!)),
        GoRoute(path: '/notifications', builder: (_,__) => NotificationsScreen()),
        GoRoute(path: '/profile', builder: (_,__) => ProfileScreen()),
      ],
    ),
  ],
);
```

---

## 8. FIRESTORE — ESTRATEGIA OFFLINE

Firestore Flutter SDK tiene persistencia offline nativa:

```dart
// main.dart — habilitar persistencia
await FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

**Comportamiento**:
- Lecturas: sirven desde caché cuando no hay conexión
- Escrituras: se encolan localmente y sincronizan al reconectar
- Streams: emiten datos del caché inmediatamente, luego actualizan con datos del servidor

**No se requiere lógica de sincronización manual para el MVP.**

---

## 9. NOTIFICACIONES PUSH — FCM

### Configuración
```dart
// Solicitar permisos (iOS requiere permiso explícito)
await FirebaseMessaging.instance.requestPermission();

// Obtener token FCM del dispositivo
final token = await FirebaseMessaging.instance.getToken();

// Guardar token en Firestore (users/{uid}.fcmToken)
// Actualizar cuando el token se renueva
FirebaseMessaging.instance.onTokenRefresh.listen(saveToken);
```

### Manejo de mensajes
```dart
// App en foreground: mostrar notificación in-app (banner)
FirebaseMessaging.onMessage.listen(handleForegroundMessage);

// App en background/cerrada: tap en notificación abre pantalla específica
FirebaseMessaging.onMessageOpenedApp.listen(handleNotificationTap);
```

### Deep linking desde notificación
Cada notificación incluye `actionUrl` (del modelo existente). Al hacer tap, GoRouter navega a esa ruta.

---

## 10. SEGURIDAD

### Autenticación
- Firebase Auth con email/password
- Token JWT renovado automáticamente por Firebase SDK
- Almacenamiento seguro del estado de sesión

### Autorización
- Verificación de rol en cada pantalla (Riverpod provider)
- Firestore Rules existentes aplican directamente (la app accede con el mismo usuario Firebase)
- No se exponen rutas de otros roles en la UI

### Datos sensibles
- Tokens FCM: almacenados en Firestore (ya implementado en sistema web)
- Credenciales: nunca almacenadas localmente, solo el token Firebase Auth
- `flutter_secure_storage` para cualquier dato sensible local

### Sesiones
- Heartbeat adaptado al ciclo de vida de la app Flutter
- Logout limpia sesión en Firestore (igual que sistema web)
- Sesiones inactivas >15 min se limpian en el próximo login

---

## 11. MANEJO DE ERRORES

### Tipos de error
```dart
sealed class AppException {
  // Auth
  UserInactiveException
  UserExpiredException
  MaxSessionsException
  InvalidCredentialsException
  
  // Network
  NetworkException
  TimeoutException
  
  // Business
  BookingNotConfirmedException      // Check-in en reserva no confirmada
  AccountBalancePendingException    // Check-out con saldo pendiente
  TaskNotAssignedException          // Iniciar tarea sin asignar
  TaskInvalidStatusException        // Completar tarea no en progreso
  
  // Generic
  UnknownException
}
```

### Presentación de errores
- Errores de negocio: SnackBar con mensaje específico
- Errores críticos: Dialog con mensaje y opción de reintentar
- Errores de red: Banner offline + mensaje contextual

---

## 12. OBSERVABILIDAD

### Logging
- Firebase Crashlytics para crashes en producción
- `debugPrint` en desarrollo (eliminado en producción)

### Analytics (FUTURE)
- Firebase Analytics para eventos de uso
- No en MVP

---

## 13. COMPATIBILIDAD FUTURA CON HUÉSPEDES

Decisiones arquitectónicas que facilitan la incorporación futura de huéspedes (DECISION-006 implícito):

1. **Autenticación**: Firebase Auth ya soporta múltiples tipos de usuario. El rol `guest` ya existe en el sistema.
2. **Firestore Rules**: Las reglas existentes ya tienen lógica por rol. Agregar reglas para `guest` es incremental.
3. **Repositorios**: La capa de dominio es agnóstica al tipo de usuario. Los repositorios de huéspedes ya existen en el sistema web.
4. **Navegación**: GoRouter permite agregar rutas nuevas sin afectar las existentes.
5. **State management**: Riverpod permite agregar providers sin modificar los existentes.
6. **Bottom nav**: El shell puede renderizar una navegación completamente diferente para el rol `guest`.

**No se implementa nada para huéspedes en el MVP. Solo se evitan decisiones que lo dificulten.**
