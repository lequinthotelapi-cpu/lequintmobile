/// Rutas nombradas de la app — ver docs/architecture/architecture.md sección 7.
/// La configuración de GoRouter que consume estas constantes se implementa
/// en TASK-005 (Shell y navegación).
abstract final class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const rooms = '/rooms';
  static const roomDetail = '/rooms/:id';
  static const arrivals = '/arrivals';
  static const arrivalDetail = '/arrivals/:id';
  static const departures = '/departures';
  static const departureDetail = '/departures/:id';
  static const inHouse = '/in-house';
  static const myTasks = '/my-tasks';
  static const tasks = '/tasks';
  static const taskDetail = '/tasks/:id';
  static const accountDetail = '/accounts/:id';
  static const notifications = '/notifications';
  static const profile = '/profile';

  // Agregadas en TASK-005 para las pestañas del bottom nav (SPEC-002) que
  // architecture.md no había enumerado: Recepción (admin/superadmin),
  // Housekeeping — vista general (admin/superadmin/manager), Reportes
  // (manager). No están respaldadas por una SPEC de contenido propia todavía
  // — ver TASK-005 para el detalle de esta decisión.
  static const frontDesk = '/front-desk';
  static const housekeepingOverview = '/housekeeping';
  static const reports = '/reports';

  static String roomDetailPath(String id) => '/rooms/$id';
  static String arrivalDetailPath(String id) => '/arrivals/$id';
  static String departureDetailPath(String id) => '/departures/$id';
  static String taskDetailPath(String id) => '/tasks/$id';
  static String accountDetailPath(String id) => '/accounts/$id';
}
