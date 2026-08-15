import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lequintmobile/application/bookings/bookings_provider.dart';
import 'package:lequintmobile/domain/models/booking.dart';
import 'package:lequintmobile/presentation/front_desk/front_desk_screen.dart';

void main() {
  testWidgets('muestra las 3 pestañas de Recepción', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          arrivalsProvider.overrideWith((ref) => Stream.value(const <Booking>[])),
          departuresProvider.overrideWith(
            (ref) => Stream.value(const <Booking>[]),
          ),
          inHouseProvider.overrideWith((ref) => Stream.value(const <Booking>[])),
        ],
        child: const MaterialApp(home: FrontDeskScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Recepción'), findsOneWidget);
    expect(find.text('Llegadas'), findsOneWidget);
    expect(find.text('Salidas'), findsOneWidget);
    expect(find.text('En Casa'), findsOneWidget);
  });
}
