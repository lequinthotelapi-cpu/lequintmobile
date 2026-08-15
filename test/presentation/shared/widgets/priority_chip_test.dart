import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lequintmobile/core/constants/app_colors.dart';
import 'package:lequintmobile/domain/models/housekeeping_task.dart';
import 'package:lequintmobile/presentation/shared/widgets/priority_chip.dart';

void main() {
  group('PriorityChip', () {
    for (final entry in {
      TaskPriority.urgent: ('Urgente', AppColors.priorityUrgent),
      TaskPriority.high: ('Alta', AppColors.priorityHigh),
      TaskPriority.normal: ('Normal', AppColors.priorityNormal),
      TaskPriority.low: ('Baja', AppColors.priorityLow),
    }.entries) {
      testWidgets('muestra el label y color correctos para ${entry.key}', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: PriorityChip(priority: entry.key)),
          ),
        );

        final (label, color) = entry.value;
        expect(find.text(label), findsOneWidget);
        expect(PriorityChip.colorFor(entry.key), color);
      });
    }
  });
}
