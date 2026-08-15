import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../application/auth/auth_provider.dart';
import '../../../application/housekeeping/housekeeping_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../domain/models/housekeeping_task.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/error_widget.dart';
import 'dashboard_header.dart';
import 'dashboard_skeleton.dart';
import 'housekeeping_summary_card.dart';
import 'task_preview_list.dart';

/// Dashboard del housekeeper — ver SPEC-003. El más liviano de los 4: sin
/// KPIs financieros ni estado general del hotel (nota de diseño de la
/// spec), una sola query (`myAllTasksProvider`).
class HousekeeperDashboard extends ConsumerWidget {
  const HousekeeperDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final tasksAsync = ref.watch(myAllTasksProvider);

    return tasksAsync.when(
      loading: () => const DashboardSkeleton(),
      error: (error, stackTrace) => ErrorState(
        message: 'No se pudieron cargar los datos',
        onRetry: () => ref.invalidate(myAllTasksProvider),
      ),
      data: (tasks) {
        final counts = countHousekeepingTasks(tasks);
        final pendingOrInProgress = sortTasksForDisplay(
          tasks
              .where(
                (t) =>
                    t.status == TaskStatus.pending ||
                    t.status == TaskStatus.inProgress,
              )
              .toList(),
        );

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(myAllTasksProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            children: [
              DashboardHeader(
                greeting: 'Buenos días, ${user?.firstName ?? ''}',
              ),
              const SizedBox(height: 20),
              HousekeepingSummaryCard(counts: counts),
              const SizedBox(height: 24),
              const Text(
                'Tus tareas',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              if (pendingOrInProgress.isEmpty)
                const EmptyState(
                  icon: Icons.task_alt,
                  title: 'No tienes tareas pendientes',
                )
              else
                TaskPreviewList(
                  tasks: pendingOrInProgress,
                  onTaskTap: (task) =>
                      context.push(AppRoutes.taskDetailPath(task.id)),
                ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => context.push(AppRoutes.myTasks),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.glassPrimaryBorder),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Ver todas mis tareas'),
              ),
            ],
          ),
        );
      },
    );
  }
}
