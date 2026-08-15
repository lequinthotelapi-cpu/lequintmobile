import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lequintmobile/core/constants/app_colors.dart';
import 'package:lequintmobile/domain/models/room.dart';
import 'package:lequintmobile/presentation/shared/widgets/status_chip.dart';

void main() {
  group('StatusChip', () {
    for (final entry in {
      RoomStatus.available: ('Disponible', AppColors.roomAvailable),
      RoomStatus.occupied: ('Ocupada', AppColors.roomOccupied),
      RoomStatus.dirty: ('Sucia', AppColors.roomDirty),
      RoomStatus.cleaning: ('En limpieza', AppColors.roomCleaning),
      RoomStatus.maintenance: ('Mantenimiento', AppColors.roomMaintenance),
    }.entries) {
      testWidgets('muestra el label y color correctos para ${entry.key}', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: StatusChip(status: entry.key)),
          ),
        );

        final (label, color) = entry.value;
        expect(find.text(label), findsOneWidget);
        expect(StatusChip.colorFor(entry.key), color);
      });
    }
  });
}
