import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/utils/firestore_converters.dart';

enum TaskType {
  cleaning('cleaning'),
  maintenance('maintenance'),
  inspection('inspection'),
  deepCleaning('deep-cleaning');

  const TaskType(this.value);

  final String value;

  static TaskType fromValue(String? value) => TaskType.values.firstWhere(
    (type) => type.value == value,
    orElse: () => TaskType.cleaning,
  );
}

enum TaskStatus {
  pending('pending'),
  inProgress('in-progress'),
  completed('completed'),
  cancelled('cancelled');

  const TaskStatus(this.value);

  final String value;

  static TaskStatus fromValue(String? value) => TaskStatus.values.firstWhere(
    (status) => status.value == value,
    orElse: () => TaskStatus.pending,
  );
}

enum TaskPriority {
  low('low'),
  normal('normal'),
  high('high'),
  urgent('urgent');

  const TaskPriority(this.value);

  final String value;

  static TaskPriority fromValue(String? value) =>
      TaskPriority.values.firstWhere(
        (priority) => priority.value == value,
        orElse: () => TaskPriority.normal,
      );
}

class ChecklistItem {
  const ChecklistItem({
    required this.item,
    required this.completed,
    required this.order,
  });

  factory ChecklistItem.fromMap(Map<String, dynamic> map) => ChecklistItem(
    item: map['item'] as String? ?? '',
    completed: map['completed'] as bool? ?? false,
    order: (map['order'] as num?)?.toInt() ?? 0,
  );

  final String item;
  final bool completed;
  final int order;

  Map<String, dynamic> toMap() => {
    'item': item,
    'completed': completed,
    'order': order,
  };
}

/// Tarea de housekeeping (limpieza o mantenimiento). Los campos
/// `updatedAt`/`updatedBy` son requeridos (no opcionales) — igual que en el
/// sistema web, donde toda tarea se crea ya con auditoría de actualización.
class HousekeepingTask {
  const HousekeepingTask({
    required this.id,
    required this.roomId,
    required this.roomNumber,
    required this.floor,
    required this.taskType,
    required this.status,
    required this.priority,
    required this.scheduledDate,
    required this.estimatedDuration,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
    this.assignedTo,
    this.assignedToName,
    this.startedAt,
    this.completedAt,
    this.actualDuration,
    this.notes,
    this.completionNotes,
    this.issuesFound = const [],
    this.checklist = const [],
  });

  factory HousekeepingTask.fromFirestore(DocumentSnapshot doc) =>
      HousekeepingTask.fromMap(
        (doc.data() as Map<String, dynamic>?) ?? {},
        doc.id,
      );

  factory HousekeepingTask.fromMap(Map<String, dynamic> map, String id) =>
      HousekeepingTask(
        id: id,
        roomId: map['roomId'] as String? ?? '',
        roomNumber: map['roomNumber'] as String? ?? '',
        floor: (map['floor'] as num?)?.toInt() ?? 0,
        taskType: TaskType.fromValue(map['taskType'] as String?),
        status: TaskStatus.fromValue(map['status'] as String?),
        priority: TaskPriority.fromValue(map['priority'] as String?),
        scheduledDate: parseTimestamp(map['scheduledDate']),
        estimatedDuration: (map['estimatedDuration'] as num?)?.toInt() ?? 0,
        createdAt: parseTimestamp(map['createdAt']),
        createdBy: map['createdBy'] as String? ?? '',
        updatedAt: parseTimestamp(map['updatedAt']),
        updatedBy: map['updatedBy'] as String? ?? '',
        assignedTo: map['assignedTo'] as String?,
        assignedToName: map['assignedToName'] as String?,
        startedAt: tryParseTimestamp(map['startedAt']),
        completedAt: tryParseTimestamp(map['completedAt']),
        actualDuration: (map['actualDuration'] as num?)?.toInt(),
        notes: map['notes'] as String?,
        completionNotes: map['completionNotes'] as String?,
        issuesFound:
            (map['issuesFound'] as List<dynamic>?)?.cast<String>() ?? const [],
        checklist:
            (map['checklist'] as List<dynamic>?)
                ?.map(
                  (e) =>
                      ChecklistItem.fromMap((e as Map<String, dynamic>?) ?? {}),
                )
                .toList() ??
            const [],
      );

  final String id;
  final String roomId;
  final String roomNumber;
  final int floor;
  final String? assignedTo;
  final String? assignedToName;
  final TaskType taskType;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime scheduledDate;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int estimatedDuration;
  final int? actualDuration;
  final String? notes;
  final String? completionNotes;
  final List<String> issuesFound;
  final List<ChecklistItem> checklist;
  final DateTime createdAt;
  final String createdBy;
  final DateTime updatedAt;
  final String updatedBy;

  Map<String, dynamic> toFirestore() => {
    'roomId': roomId,
    'roomNumber': roomNumber,
    'floor': floor,
    if (assignedTo != null) 'assignedTo': assignedTo,
    if (assignedToName != null) 'assignedToName': assignedToName,
    'taskType': taskType.value,
    'status': status.value,
    'priority': priority.value,
    'scheduledDate': Timestamp.fromDate(scheduledDate),
    if (startedAt != null) 'startedAt': Timestamp.fromDate(startedAt!),
    if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
    'estimatedDuration': estimatedDuration,
    if (actualDuration != null) 'actualDuration': actualDuration,
    if (notes != null) 'notes': notes,
    if (completionNotes != null) 'completionNotes': completionNotes,
    if (issuesFound.isNotEmpty) 'issuesFound': issuesFound,
    if (checklist.isNotEmpty)
      'checklist': checklist.map((c) => c.toMap()).toList(),
    'createdAt': Timestamp.fromDate(createdAt),
    'createdBy': createdBy,
    'updatedAt': Timestamp.fromDate(updatedAt),
    'updatedBy': updatedBy,
  };
}
