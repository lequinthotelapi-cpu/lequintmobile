import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/housekeeping/housekeeping_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../domain/models/housekeeping_task.dart';
import '../shared/widgets/empty_state_widget.dart';
import '../shared/widgets/error_widget.dart';
import '../shared/widgets/loading_widget.dart';
import '../shared/widgets/offline_banner.dart';
import 'widgets/task_card.dart';

/// Home del housekeeper — ver SPEC-004.
class MyTasksScreen extends ConsumerWidget {
  const MyTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(myTasksProvider);

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
            'Mis Tareas',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              const OfflineBanner(),
              Expanded(
                child: tasksAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(20),
                    child: SkeletonList(count: 4, itemHeight: 104),
                  ),
                  error: (error, stackTrace) => ErrorState(
                    message: 'No se pudieron cargar tus tareas',
                    onRetry: () => ref.invalidate(myTasksProvider),
                  ),
                  data: (tasks) => _TaskSections(tasks: tasks),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskSections extends ConsumerWidget {
  const _TaskSections({required this.tasks});

  final List<HousekeepingTask> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (tasks.isEmpty) {
      return const EmptyState(
        icon: Icons.task_alt,
        title: 'No tienes tareas asignadas por ahora',
      );
    }

    final sorted = sortTasksForDisplay(tasks);
    final inProgress = sorted
        .where((task) => task.status == TaskStatus.inProgress)
        .toList();
    final pending = sorted
        .where((task) => task.status == TaskStatus.pending)
        .toList();

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(myTasksProvider),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            '${pending.length + inProgress.length} tareas pendientes',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          if (inProgress.isNotEmpty) ...[
            const _SectionHeader('En progreso'),
            const SizedBox(height: 12),
            for (final task in inProgress) ...[
              TaskCard(
                task: task,
                onTap: () => context.push(AppRoutes.taskDetailPath(task.id)),
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 8),
          ],
          if (pending.isNotEmpty) ...[
            const _SectionHeader('Pendientes'),
            const SizedBox(height: 12),
            for (final task in pending) ...[
              TaskCard(
                task: task,
                onTap: () => context.push(AppRoutes.taskDetailPath(task.id)),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: AppColors.textTertiary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }
}
