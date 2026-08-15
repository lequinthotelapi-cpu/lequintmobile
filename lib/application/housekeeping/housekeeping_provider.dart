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
