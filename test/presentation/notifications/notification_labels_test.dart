import 'package:flutter_test/flutter_test.dart';
import 'package:lequintmobile/presentation/notifications/notification_labels.dart';

void main() {
  group('relativeTimeEs', () {
    test('menos de 1 minuto -> "Ahora"', () {
      final now = DateTime.now();
      expect(relativeTimeEs(now), 'Ahora');
    });

    test('minutos -> "Hace N min"', () {
      final time = DateTime.now().subtract(const Duration(minutes: 5));
      expect(relativeTimeEs(time), 'Hace 5 min');
    });

    test('1 hora -> "Hace 1 hora" (singular)', () {
      final time = DateTime.now().subtract(const Duration(hours: 1));
      expect(relativeTimeEs(time), 'Hace 1 hora');
    });

    test('2 horas -> "Hace 2 horas" (plural)', () {
      final time = DateTime.now().subtract(const Duration(hours: 2));
      expect(relativeTimeEs(time), 'Hace 2 horas');
    });

    test('1 día -> "Ayer"', () {
      final time = DateTime.now().subtract(const Duration(days: 1, hours: 1));
      expect(relativeTimeEs(time), 'Ayer');
    });

    test('varios días (menos de una semana) -> "Hace N días"', () {
      final time = DateTime.now().subtract(const Duration(days: 3, hours: 1));
      expect(relativeTimeEs(time), 'Hace 3 días');
    });
  });
}
