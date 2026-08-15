import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/auth/auth_provider.dart';
import '../../application/housekeeping/housekeeping_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/errors/app_exception.dart';
import '../../domain/models/housekeeping_task.dart';
import '../shared/widgets/empty_state_widget.dart';
import '../shared/widgets/error_widget.dart';
import '../shared/widgets/loading_widget.dart';

/// Formulario de completación de tarea — ver SPEC-005 (DECISION-011: mismos
/// campos que el sistema web).
class CompleteTaskScreen extends ConsumerStatefulWidget {
  const CompleteTaskScreen({required this.taskId, super.key});

  final String taskId;

  @override
  ConsumerState<CompleteTaskScreen> createState() => _CompleteTaskScreenState();
}

class _CompleteTaskScreenState extends ConsumerState<CompleteTaskScreen> {
  final _durationController = TextEditingController();
  final _completionNotesController = TextEditingController();
  final _maintenanceNotesController = TextEditingController();
  bool _requiresMaintenance = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _durationController.addListener(_onFieldsChanged);
    _maintenanceNotesController.addListener(_onFieldsChanged);
  }

  void _onFieldsChanged() => setState(() {});

  @override
  void dispose() {
    _durationController.dispose();
    _completionNotesController.dispose();
    _maintenanceNotesController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    final duration = int.tryParse(_durationController.text.trim());
    if (duration == null || duration <= 0) return false;
    if (_requiresMaintenance &&
        _maintenanceNotesController.text.trim().isEmpty) {
      return false;
    }
    return true;
  }

  Future<void> _submit(HousekeepingTask task) async {
    if (!_canSubmit) return;
    final userId = ref.read(currentUserProvider)?.uid;
    if (userId == null) return;

    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(housekeepingRepositoryProvider)
          .completeTask(
            taskId: task.id,
            userId: userId,
            actualDuration: int.parse(_durationController.text.trim()),
            completionNotes: _completionNotesController.text.trim().isEmpty
                ? null
                : _completionNotesController.text.trim(),
            requiresMaintenance: _requiresMaintenance,
            maintenanceNotes: _requiresMaintenance
                ? _maintenanceNotesController.text.trim()
                : null,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tarea completada')));
      context.go(AppRoutes.myTasks);
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            'Completar Tarea',
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
                );
              }
              return LoadingOverlay(
                isLoading: _isSubmitting,
                child: _CompleteTaskForm(
                  task: task,
                  durationController: _durationController,
                  completionNotesController: _completionNotesController,
                  maintenanceNotesController: _maintenanceNotesController,
                  requiresMaintenance: _requiresMaintenance,
                  onRequiresMaintenanceChanged: (value) =>
                      setState(() => _requiresMaintenance = value),
                  canSubmit: _canSubmit && !_isSubmitting,
                  onSubmit: () => _submit(task),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CompleteTaskForm extends StatelessWidget {
  const _CompleteTaskForm({
    required this.task,
    required this.durationController,
    required this.completionNotesController,
    required this.maintenanceNotesController,
    required this.requiresMaintenance,
    required this.onRequiresMaintenanceChanged,
    required this.canSubmit,
    required this.onSubmit,
  });

  final HousekeepingTask task;
  final TextEditingController durationController;
  final TextEditingController completionNotesController;
  final TextEditingController maintenanceNotesController;
  final bool requiresMaintenance;
  final ValueChanged<bool> onRequiresMaintenanceChanged;
  final bool canSubmit;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Habitación ${task.roomNumber}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          const _FieldLabel('Duración real (minutos) *'),
          _GlassTextField(
            controller: durationController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          const _FieldLabel('Notas de completación'),
          _GlassTextField(controller: completionNotesController, maxLines: 3),
          const SizedBox(height: 12),
          CheckboxListTile(
            value: requiresMaintenance,
            onChanged: (value) => onRequiresMaintenanceChanged(value ?? false),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: AppColors.accentPrimary,
            title: const Text(
              '¿Requiere mantenimiento?',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: requiresMaintenance
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel('Notas de mantenimiento *'),
                      _GlassTextField(
                        controller: maintenanceNotesController,
                        maxLines: 3,
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: canSubmit ? onSubmit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                disabledBackgroundColor: AppColors.success.withValues(
                  alpha: 0.4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Confirmar Completación',
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

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _GlassTextField extends StatelessWidget {
  const _GlassTextField({
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.glassPrimary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.glassPrimaryBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.glassPrimaryBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentPrimary),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
