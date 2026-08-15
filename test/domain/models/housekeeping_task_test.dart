import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lequintmobile/domain/models/housekeeping_task.dart';

void main() {
  group('HousekeepingTask.fromMap', () {
    test('parsea un documento completo correctamente', () {
      final scheduled = DateTime(2026, 8, 14, 9);
      final task = HousekeepingTask.fromMap({
        'roomId': 'room-1',
        'roomNumber': '101',
        'floor': 1,
        'assignedTo': 'user-1',
        'assignedToName': 'María Gómez',
        'taskType': 'deep-cleaning',
        'status': 'in-progress',
        'priority': 'urgent',
        'scheduledDate': Timestamp.fromDate(scheduled),
        'estimatedDuration': 45,
        'createdAt': Timestamp.fromDate(scheduled),
        'createdBy': 'admin-1',
        'updatedAt': Timestamp.fromDate(scheduled),
        'updatedBy': 'admin-1',
        'checklist': [
          {'item': 'Cambiar sábanas', 'completed': true, 'order': 1},
        ],
      }, 'task-1');

      expect(task.id, 'task-1');
      expect(task.taskType, TaskType.deepCleaning);
      expect(task.status, TaskStatus.inProgress);
      expect(task.priority, TaskPriority.urgent);
      expect(task.checklist, hasLength(1));
      expect(task.checklist.first.item, 'Cambiar sábanas');
    });

    test(
      'no lanza excepción con un mapa vacío y aplica valores por defecto',
      () {
        final task = HousekeepingTask.fromMap(const {}, 'task-empty');

        expect(task.id, 'task-empty');
        expect(task.taskType, TaskType.cleaning);
        expect(task.status, TaskStatus.pending);
        expect(task.priority, TaskPriority.normal);
        expect(task.assignedTo, isNull);
        expect(task.issuesFound, isEmpty);
        expect(task.checklist, isEmpty);
      },
    );

    test('valores de enum desconocidos caen a los valores por defecto', () {
      final task = HousekeepingTask.fromMap({
        'taskType': 'unknown',
        'status': 'unknown',
        'priority': 'unknown',
      }, 'task-2');

      expect(task.taskType, TaskType.cleaning);
      expect(task.status, TaskStatus.pending);
      expect(task.priority, TaskPriority.normal);
    });

    test('roundtrip toFirestore -> fromMap preserva los datos', () {
      final original = HousekeepingTask.fromMap({
        'roomId': 'room-2',
        'roomNumber': '202',
        'floor': 2,
        'taskType': 'maintenance',
        'status': 'completed',
        'priority': 'high',
        'scheduledDate': Timestamp.fromDate(DateTime(2026, 8, 14)),
        'estimatedDuration': 30,
        'actualDuration': 35,
        'completionNotes': 'Listo',
        'createdAt': Timestamp.fromDate(DateTime(2026, 8, 14)),
        'createdBy': 'admin-1',
        'updatedAt': Timestamp.fromDate(DateTime(2026, 8, 14)),
        'updatedBy': 'admin-1',
      }, 'task-3');

      final roundtripped = HousekeepingTask.fromMap(
        original.toFirestore(),
        'task-3',
      );

      expect(roundtripped.taskType, original.taskType);
      expect(roundtripped.status, original.status);
      expect(roundtripped.actualDuration, original.actualDuration);
      expect(roundtripped.completionNotes, original.completionNotes);
    });
  });
}
