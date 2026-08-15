import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/auth/auth_provider.dart';
import '../../application/housekeeping/housekeeping_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/errors/app_exception.dart';
import '../../core/extensions/date_extensions.dart';
import '../../domain/models/housekeeping_task.dart';
import '../shared/widgets/confirm_dialog.dart';
import '../shared/widgets/empty_state_widget.dart';
import '../shared/widgets/error_widget.dart';
import '../shared/widgets/loading_widget.dart';
import '../shared/widgets/priority_chip.dart';
import 'task_labels.dart';

/// Detalle de tarea + iniciar tarea — ver SPEC-005.
class TaskDetailScreen extends ConsumerStatefulWidget {
  const TaskDetailScreen({required this.taskId, super.key});

  final String taskId;

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  bool _isStarting = false;

  Future<void> _startTask(HousekeepingTask task, String userId) async {
    setState(() => _isStarting = true);
    try {
      await ref
          .read(housekeepingRepositoryProvider)
          .startTask(taskId: task.id, userId: userId);
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(myTasksProvider);
    final currentUserId = ref.watch(currentUserProvider)?.uid;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundGradientTop,
            AppColors.backgroundGradientBottom,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Detalle de tarea',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),
        body: SafeArea(
          child: tasksAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(20),
              child: SkeletonCard(height: 320),
            ),
            error: (error, stackTrace) => ErrorState(
              message: 'No se pudo cargar la tarea',
              onRetry: () => ref.invalidate(myTasksProvider),
            ),
            data: (tasks) {
              final task = findTaskById(tasks, widget.taskId);
              if (task == null) {
                return const EmptyState(
                  icon: Icons.search_off,
                  title: 'No se encontró la tarea',
                  subtitle: 'Puede que ya haya sido completada.',
                );
              }
              return _TaskDetailBody(
                task: task,
                isOwner:
                    currentUserId != null && task.assignedTo == currentUserId,
                isStarting: _isStarting,
                onStart: currentUserId == null
                    ? null
                    : () => ConfirmDialog.show(
                        context: context,
                        title: '¿Iniciar tarea?',
                        message:
                            '¿Iniciar limpieza de habitación ${task.roomNumber}?',
                        confirmLabel: 'Iniciar',
                        onConfirm: () => _startTask(task, currentUserId),
                      ),
                onComplete: () =>
                    context.push(AppRoutes.completeTaskPath(task.id)),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TaskDetailBody extends StatelessWidget {
  const _TaskDetailBody({
    required this.task,
    required this.isOwner,
    required this.isStarting,
    required this.onStart,
    required this.onComplete,
  });

  final HousekeepingTask task;
  final bool isOwner;
  final bool isStarting;
  final VoidCallback? onStart;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Habitación ${task.roomNumber} — Piso ${task.floor}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              PriorityChip(priority: task.priority),
              const SizedBox(width: 8),
              Text(
                task.taskType.label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _GlassSection(
            children: [
              _InfoRow('Estado', task.status.label),
              _InfoRow('Programada', task.scheduledDate.toShortDateTimeEs()),
              _InfoRow('Duración estimada', '${task.estimatedDuration} min'),
              if (task.startedAt != null)
                _InfoRow('Iniciada', task.startedAt!.toShortDateTimeEs()),
            ],
          ),
          if (task.notes != null && task.notes!.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'NOTAS DEL SUPERVISOR',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              task.notes!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 32),
          if (isOwner && task.status == TaskStatus.pending)
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: isStarting ? null : onStart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isStarting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Iniciar Tarea',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          if (isOwner && task.status == TaskStatus.inProgress)
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: onComplete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Completar Tarea',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GlassSection extends StatelessWidget {
  const _GlassSection({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassPrimary,
        border: Border.all(color: AppColors.glassPrimaryBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
