import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lequintmobile/core/constants/app_colors.dart';
import 'package:lequintmobile/domain/models/room.dart';
import 'package:lequintmobile/presentation/rooms/widgets/room_grid_card.dart';

RoomWithStatus _room({required String displayStatus}) {
  return RoomWithStatus(
    id: 'room-1',
    roomNumber: '101',
    floor: 1,
    roomType: 'standard',
    bedType: 'double',
    capacity: 2,
    amenities: const [],
    status: RoomStatus.available,
    isActive: true,
    basePrice: 100,
    displayStatus: displayStatus,
  );
}

void main() {
  group('RoomGridCard', () {
    for (final entry in {
      'available': ('Disponible', AppColors.roomAvailable),
      'reserved': ('Reservada', AppColors.roomReserved),
      'occupied': ('Ocupada', AppColors.roomOccupied),
      'dirty': ('Sucia', AppColors.roomDirty),
      'cleaning': ('En limpieza', AppColors.roomCleaning),
      'maintenance': ('Mantenimiento', AppColors.roomMaintenance),
    }.entries) {
      testWidgets('muestra el label y color correctos para ${entry.key}', (
        tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RoomGridCard(
                room: _room(displayStatus: entry.key),
                onTap: () {},
              ),
            ),
          ),
        );

        final (label, color) = entry.value;
        expect(find.text(label), findsOneWidget);

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(RoomGridCard),
            matching: find.byType(Container),
          ),
        );
        final decoration = container.decoration! as BoxDecoration;
        expect(
          (decoration.border! as Border).top.color,
          color.withValues(alpha: 0.4),
        );
      });
    }
  });
}
