import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../domain/models/housekeeping_task.dart';
import '../../shared/widgets/priority_chip.dart';
import '../task_labels.dart';

/// Tarjeta de tarea en MyTasksScreen — ver docs/ux/components.md
/// "TaskCard".
class TaskCard extends StatelessWidget {
  const TaskCard({
    required this.task,
    required this.onTap,
    this.assignedToName,
    this.isOverdue = false,
    super.key,
  });

  final HousekeepingTask task;
  final VoidCallback onTap;

  /// Nombre del empleado asignado — solo se usa en AllTasksScreen (TASK-016,
  /// supervisión); en MyTasksScreen es redundante (siempre es "yo") y no se
  /// pasa.
  final String? assignedToName;

  /// Resalta el borde izquierdo cuando la tarea está vencida (TASK-016).
  final bool isOverdue;

  @override
  Widget build(BuildContext context) {
    final priorityColor = isOverdue
        ? AppColors.error
        : PriorityChip.colorFor(task.priority);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.glassSecondary,
            border: Border.all(
              color: isOverdue
                  ? AppColors.error.withValues(alpha: 0.5)
                  : AppColors.glassSecondaryBorder,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(16),
                    ),
                  ),
                  child: const SizedBox(width: 3),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            PriorityChip(priority: task.priority),
                            const Spacer(),
                            Text(
                              'Hab. ${task.roomNumber}',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          task.taskType.label,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _StatusIndicator(status: task.status),
                            const SizedBox(width: 6),
                            Text(
                              task.status.label,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Piso ${task.floor}',
                              style: const TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        if (assignedToName != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Asignado a: $assignedToName',
                            style: const TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        if (isOverdue) ...[
                          const SizedBox(height: 6),
                          const Text(
                            'Vencida',
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.chevron_right,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusIndicator extends StatefulWidget {
  const _StatusIndicator({required this.status});

  final TaskStatus status;

  @override
  State<_StatusIndicator> createState() => _StatusIndicatorState();
}

class _StatusIndicatorState extends State<_StatusIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.status == TaskStatus.inProgress) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
      )..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.status == TaskStatus.inProgress
        ? AppColors.accentPrimary
        : AppColors.warning;

    final dot = Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );

    final controller = _controller;
    if (controller == null) return dot;

    return FadeTransition(
      opacity: Tween(begin: 0.3, end: 1.0).animate(controller),
      child: dot,
    );
  }
}
