import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/housekeeping_task.dart';
import '../../domain/repositories/housekeeping_repository.dart';
import '../../infrastructure/firebase/housekeeping_firebase_repository.dart';
import '../auth/auth_provider.dart';

final housekeepingRepositoryProvider = Provider<HousekeepingRepository>((ref) {
  return HousekeepingFirebaseRepository();
});

/// Tareas pendientes/en progreso del housekeeper actual — ver SPEC-004.
final myTasksProvider = StreamProvider.autoDispose<List<HousekeepingTask>>((
  ref,
) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(housekeepingRepositoryProvider).getByEmployee(uid);
});

/// Todas las tareas (supervisión — manager/admin, ver TASK-016).
final allTasksProvider = StreamProvider.autoDispose<List<HousekeepingTask>>((
  ref,
) {
  return ref.watch(housekeepingRepositoryProvider).getAll();
});

/// Todas las tareas del housekeeper actual (sin filtrar por status) — usado
/// por el resumen "Mis tareas hoy" del dashboard (TASK-007), que necesita
/// contar también las completadas hoy (fuera del alcance de
/// [myTasksProvider], que solo trae pending/in-progress).
final myAllTasksProvider = StreamProvider.autoDispose<List<HousekeepingTask>>((
  ref,
) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(housekeepingRepositoryProvider).getAllByEmployee(uid);
});

/// Tareas de [allTasksProvider] agrupadas por `assignedTo` — ver TASK-016
/// (vista "por empleado" de AllTasksScreen). Las tareas sin asignar caen
/// bajo la llave `'unassigned'`.
final tasksByEmployeeProvider =
    Provider.autoDispose<Map<String, List<HousekeepingTask>>>((ref) {
      final tasks = ref.watch(allTasksProvider).value ?? const [];
      return groupTasksByEmployee(tasks);
    });

Map<String, List<HousekeepingTask>> groupTasksByEmployee(
  List<HousekeepingTask> tasks,
) {
  final groups = <String, List<HousekeepingTask>>{};
  for (final task in tasks) {
    groups.putIfAbsent(task.assignedTo ?? 'unassigned', () => []).add(task);
  }
  return groups;
}

/// Busca una tarea puntual dentro de una lista ya cargada (usado por
/// TaskDetailScreen/CompleteTaskScreen a partir de [myTasksProvider]) —
/// evita agregar un método de lectura individual al repositorio (TASK-003)
/// solo para este caso de uso.
HousekeepingTask? findTaskById(List<HousekeepingTask> tasks, String id) {
  for (final task in tasks) {
    if (task.id == id) return task;
  }
  return null;
}

const _priorityOrder = {
  TaskPriority.urgent: 0,
  TaskPriority.high: 1,
  TaskPriority.normal: 2,
  TaskPriority.low: 3,
};

/// Ordena las tareas para MyTasksScreen: en progreso primero, luego
/// pendientes por prioridad (urgent > high > normal > low) y, dentro de
/// cada grupo, por `scheduledDate` ascendente — ver SPEC-004.
List<HousekeepingTask> sortTasksForDisplay(List<HousekeepingTask> tasks) {
  final sorted = [...tasks];
  sorted.sort((a, b) {
    final aInProgress = a.status == TaskStatus.inProgress;
    final bInProgress = b.status == TaskStatus.inProgress;
    if (aInProgress != bInProgress) return aInProgress ? -1 : 1;

    final priorityCompare = (_priorityOrder[a.priority] ?? 99).compareTo(
      _priorityOrder[b.priority] ?? 99,
    );
    if (priorityCompare != 0) return priorityCompare;

    return a.scheduledDate.compareTo(b.scheduledDate);
  });
  return sorted;
}

/// Resumen "pendientes / en progreso / completadas hoy" — ver SPEC-003
/// (dashboard housekeeper) y SPEC-003 "Resumen housekeeping" (dashboard
/// manager, sobre [allTasksProvider] en vez de las tareas de un solo
/// empleado).
class HousekeepingTaskCounts {
  const HousekeepingTaskCounts({
    required this.pending,
    required this.inProgress,
    required this.completedToday,
  });

  final int pending;
  final int inProgress;
  final int completedToday;
}

HousekeepingTaskCounts countHousekeepingTasks(List<HousekeepingTask> tasks) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  var pending = 0;
  var inProgress = 0;
  var completedToday = 0;
  for (final task in tasks) {
    switch (task.status) {
      case TaskStatus.pending:
        pending++;
      case TaskStatus.inProgress:
        inProgress++;
      case TaskStatus.completed:
        final completedAt = task.completedAt;
        if (completedAt != null) {
          final completedDay = DateTime(
            completedAt.year,
            completedAt.month,
            completedAt.day,
          );
          if (completedDay == today) completedToday++;
        }
      case TaskStatus.cancelled:
        break;
    }
  }
  return HousekeepingTaskCounts(
    pending: pending,
    inProgress: inProgress,
    completedToday: completedToday,
  );
}

/// `true` si [task] sigue pendiente/en progreso y su `scheduledDate` ya
/// pasó — ver TASK-016 "Resumen del día: ... vencidas".
bool isTaskOverdue(HousekeepingTask task, DateTime now) {
  if (task.status != TaskStatus.pending &&
      task.status != TaskStatus.inProgress) {
    return false;
  }
  final today = DateTime(now.year, now.month, now.day);
  final scheduledDay = DateTime(
    task.scheduledDate.year,
    task.scheduledDate.month,
    task.scheduledDate.day,
  );
  return scheduledDay.isBefore(today);
}

int countOverdueTasks(List<HousekeepingTask> tasks, DateTime now) =>
    tasks.where((task) => isTaskOverdue(task, now)).length;

/// Filtros de AllTasksScreen — ver TASK-016. `urgent` filtra por
/// *prioridad* (no por status), a diferencia de los demás.
enum TaskSupervisionFilter { all, pending, inProgress, completed, urgent }

List<HousekeepingTask> filterTasksForSupervision(
  List<HousekeepingTask> tasks,
  TaskSupervisionFilter filter,
) {
  switch (filter) {
    case TaskSupervisionFilter.all:
      return tasks;
    case TaskSupervisionFilter.pending:
      return tasks.where((t) => t.status == TaskStatus.pending).toList();
    case TaskSupervisionFilter.inProgress:
      return tasks.where((t) => t.status == TaskStatus.inProgress).toList();
    case TaskSupervisionFilter.completed:
      return tasks.where((t) => t.status == TaskStatus.completed).toList();
    case TaskSupervisionFilter.urgent:
      return tasks.where((t) => t.priority == TaskPriority.urgent).toList();
  }
}

/// `null` = "Todos" (sin filtrar).
final taskSupervisionFilterProvider =
    StateProvider.autoDispose<TaskSupervisionFilter>(
      (ref) => TaskSupervisionFilter.all,
    );
