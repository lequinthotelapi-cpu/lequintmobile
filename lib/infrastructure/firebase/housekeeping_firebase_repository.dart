import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/errors/app_exception.dart';
import '../../domain/models/housekeeping_task.dart';
import '../../domain/models/room.dart';
import '../../domain/repositories/housekeeping_repository.dart';
import '../../domain/validators/housekeeping_validators.dart';
import 'firestore_error_mapper.dart';

/// Implementación Firebase de [HousekeepingRepository] — ver SPEC-004,
/// SPEC-005.
class HousekeepingFirebaseRepository implements HousekeepingRepository {
  HousekeepingFirebaseRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Stream<List<HousekeepingTask>> getByEmployee(String employeeId) {
    final stream = _firestore
        .collection('housekeepingTasks')
        .where('assignedTo', isEqualTo: employeeId)
        .where('status', whereIn: ['pending', 'in-progress'])
        .snapshots()
        .map((snap) => snap.docs.map(HousekeepingTask.fromFirestore).toList());
    return mapFirestoreStreamErrors(stream);
  }

  @override
  Stream<List<HousekeepingTask>> getAllByEmployee(String employeeId) {
    final stream = _firestore
        .collection('housekeepingTasks')
        .where('assignedTo', isEqualTo: employeeId)
        .snapshots()
        .map((snap) => snap.docs.map(HousekeepingTask.fromFirestore).toList());
    return mapFirestoreStreamErrors(stream);
  }

  @override
  Stream<List<HousekeepingTask>> getAll() {
    final stream = _firestore
        .collection('housekeepingTasks')
        .snapshots()
        .map((snap) => snap.docs.map(HousekeepingTask.fromFirestore).toList());
    return mapFirestoreStreamErrors(stream);
  }

  @override
  Future<void> startTask({
    required String taskId,
    required String userId,
  }) async {
    try {
      final taskRef = _firestore.collection('housekeepingTasks').doc(taskId);
      final taskSnap = await taskRef.get();
      if (!taskSnap.exists) throw const TaskNotFoundException();
      final task = HousekeepingTask.fromFirestore(taskSnap);

      validateStartTask(task: task, userId: userId);

      final now = Timestamp.fromDate(DateTime.now());
      await taskRef.update({
        'status': TaskStatus.inProgress.value,
        'startedAt': now,
        'updatedBy': userId,
        'updatedAt': now,
      });
    } on AppException {
      rethrow;
    } on FirebaseException catch (e) {
      throw mapFirestoreException(e);
    }
  }

  @override
  Future<void> completeTask({
    required String taskId,
    required String userId,
    required int actualDuration,
    String? completionNotes,
    bool requiresMaintenance = false,
    String? maintenanceNotes,
  }) async {
    try {
      final taskRef = _firestore.collection('housekeepingTasks').doc(taskId);
      final taskSnap = await taskRef.get();
      if (!taskSnap.exists) throw const TaskNotFoundException();
      final task = HousekeepingTask.fromFirestore(taskSnap);

      validateCompleteTask(
        task: task,
        userId: userId,
        actualDuration: actualDuration,
      );

      final roomRef = _firestore.collection('rooms').doc(task.roomId);
      final batch = _firestore.batch();
      final now = DateTime.now();
      final nowTimestamp = Timestamp.fromDate(now);

      batch.update(taskRef, {
        'status': TaskStatus.completed.value,
        // SPEC-005 regla 3: si la tarea estaba pending, se inicia
        // automáticamente antes de completarla.
        if (task.status == TaskStatus.pending) 'startedAt': nowTimestamp,
        'completedAt': nowTimestamp,
        'actualDuration': actualDuration,
        'completionNotes': completionNotes,
        'issuesFound': const <String>[],
        'updatedBy': userId,
        'updatedAt': nowTimestamp,
      });

      if (requiresMaintenance) {
        batch.update(roomRef, {
          'status': RoomStatus.maintenance.value,
          'updatedBy': userId,
          'updatedAt': nowTimestamp,
        });

        final maintenanceTaskRef = _firestore
            .collection('housekeepingTasks')
            .doc();
        final maintenanceTask = HousekeepingTask(
          id: maintenanceTaskRef.id,
          roomId: task.roomId,
          roomNumber: task.roomNumber,
          floor: task.floor,
          taskType: TaskType.maintenance,
          status: TaskStatus.pending,
          priority: TaskPriority.high,
          scheduledDate: now,
          estimatedDuration: 60,
          notes: maintenanceNotes ?? 'Requiere mantenimiento',
          createdAt: now,
          createdBy: userId,
          updatedAt: now,
          updatedBy: userId,
        );
        batch.set(maintenanceTaskRef, maintenanceTask.toFirestore());
      } else {
        batch.update(roomRef, {
          'status': RoomStatus.available.value,
          'assignedHousekeeperId': FieldValue.delete(),
          'updatedBy': userId,
          'updatedAt': nowTimestamp,
        });
      }

      await batch.commit();
    } on AppException {
      rethrow;
    } on FirebaseException catch (e) {
      throw mapFirestoreException(e);
    }
  }
}
