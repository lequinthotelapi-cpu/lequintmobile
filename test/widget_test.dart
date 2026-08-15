import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lequintmobile/core/constants/app_config.dart';
import 'package:lequintmobile/main.dart';

void main() {
  testWidgets('LeQuintApp muestra el nombre de la app al arrancar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: LeQuintApp()));

    expect(find.text(AppConfig.appName), findsOneWidget);
  });
}
