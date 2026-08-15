import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/housekeeping/housekeeping_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../domain/models/housekeeping_task.dart';
import '../shared/widgets/empty_state_widget.dart';
import '../shared/widgets/error_widget.dart';
import '../shared/widgets/glass_card.dart';
import '../shared/widgets/loading_widget.dart';
import '../shared/widgets/offline_banner.dart';
import 'widgets/task_card.dart';
import 'widgets/task_supervision_filter_chips.dart';

/// Supervisión de housekeeping — manager/admin/superadmin, ver TASK-016.
/// El housekeeper usa MyTasksScreen (TASK-008), no esta pantalla.
class AllTasksScreen extends ConsumerStatefulWidget {
  const AllTasksScreen({super.key});

  @override
  ConsumerState<AllTasksScreen> createState() => _AllTasksScreenState();
}

class _AllTasksScreenState extends ConsumerState<AllTasksScreen> {
  bool _byEmployee = false;

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(allTasksProvider);
    final filter = ref.watch(taskSupervisionFilterProvider);

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
            'Housekeeping',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _byEmployee ? Icons.view_list_outlined : Icons.people_outline,
                color: AppColors.textPrimary,
              ),
              tooltip: _byEmployee ? 'Ver lista' : 'Ver por empleado',
              onPressed: () => setState(() => _byEmployee = !_byEmployee),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              const OfflineBanner(),
              Expanded(
                child: tasksAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(20),
                    child: SkeletonList(count: 5, itemHeight: 110),
                  ),
                  error: (error, stackTrace) => ErrorState(
                    message: 'No se pudieron cargar las tareas',
                    onRetry: () => ref.invalidate(allTasksProvider),
                  ),
                  data: (tasks) {
                    if (tasks.isEmpty) {
                      return const EmptyState(
                        icon: Icons.task_alt,
                        title: 'No hay tareas registradas',
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async => ref.invalidate(allTasksProvider),
                      child: _byEmployee
                          ? _ByEmployeeView(tasks: tasks)
                          : _ListView(
                              tasks: tasks,
                              filter: filter,
                              onFilterChanged: (value) =>
                                  ref
                                          .read(
                                            taskSupervisionFilterProvider
                                                .notifier,
                                          )
                                          .state =
                                      value,
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DaySummary extends StatelessWidget {
  const _DaySummary({required this.tasks});

  final List<HousekeepingTask> tasks;

  @override
  Widget build(BuildContext context) {
    final counts = countHousekeepingTasks(tasks);
    final overdue = countOverdueTasks(tasks, DateTime.now());

    return GlassCard.subtle(
      child: Row(
        children: [
          Expanded(
            child: _Count(
              value: counts.pending,
              label: 'Pendientes',
              color: AppColors.warning,
            ),
          ),
          Expanded(
            child: _Count(
              value: counts.inProgress,
              label: 'En progreso',
              color: AppColors.accentPrimary,
            ),
          ),
          Expanded(
            child: _Count(
              value: counts.completedToday,
              label: 'Completadas hoy',
              color: AppColors.success,
            ),
          ),
          Expanded(
            child: _Count(
              value: overdue,
              label: 'Vencidas',
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({required this.value, required this.label, required this.color});

  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
        ),
      ],
    );
  }
}

class _ListView extends StatelessWidget {
  const _ListView({
    required this.tasks,
    required this.filter,
    required this.onFilterChanged,
  });

  final List<HousekeepingTask> tasks;
  final TaskSupervisionFilter filter;
  final ValueChanged<TaskSupervisionFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final filtered = filterTasksForSupervision(
      sortTasksForDisplay(tasks),
      filter,
    );
    final now = DateTime.now();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        _DaySummary(tasks: tasks),
        const SizedBox(height: 16),
        TaskSupervisionFilterChips(
          selected: filter,
          onChanged: onFilterChanged,
        ),
        const SizedBox(height: 16),
        if (filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: EmptyState(
              icon: Icons.search_off,
              title: 'No hay tareas con este filtro',
            ),
          )
        else
          for (final task in filtered) ...[
            TaskCard(
              task: task,
              assignedToName: task.assignedToName,
              isOverdue: isTaskOverdue(task, now),
              onTap: () => context.push(AppRoutes.taskDetailPath(task.id)),
            ),
            if (task != filtered.last) const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _ByEmployeeView extends StatelessWidget {
  const _ByEmployeeView({required this.tasks});

  final List<HousekeepingTask> tasks;

  @override
  Widget build(BuildContext context) {
    final grouped = groupTasksByEmployee(tasks);
    final employeeIds = grouped.keys.toList()
      ..sort((a, b) {
        if (a == 'unassigned') return 1;
        if (b == 'unassigned') return -1;
        return (grouped[a]!.first.assignedToName ?? '').compareTo(
          grouped[b]!.first.assignedToName ?? '',
        );
      });
    final now = DateTime.now();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        _DaySummary(tasks: tasks),
        const SizedBox(height: 16),
        for (final employeeId in employeeIds) ...[
          _EmployeeSection(
            employeeName: employeeId == 'unassigned'
                ? 'Sin asignar'
                : (grouped[employeeId]!.first.assignedToName ?? 'Sin nombre'),
            tasks: sortTasksForDisplay(grouped[employeeId]!),
            now: now,
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}

class _EmployeeSection extends StatelessWidget {
  const _EmployeeSection({
    required this.employeeName,
    required this.tasks,
    required this.now,
  });

  final String employeeName;
  final List<HousekeepingTask> tasks;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final active = tasks
        .where(
          (t) =>
              t.status == TaskStatus.pending ||
              t.status == TaskStatus.inProgress,
        )
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                employeeName,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '$active activa${active == 1 ? '' : 's'}',
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final task in tasks) ...[
          TaskCard(
            task: task,
            isOverdue: isTaskOverdue(task, now),
            onTap: () => context.push(AppRoutes.taskDetailPath(task.id)),
          ),
          if (task != tasks.last) const SizedBox(height: 8),
        ],
      ],
    );
  }
}
