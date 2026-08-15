import 'package:flutter_test/flutter_test.dart';
import 'package:lequintmobile/domain/services/report_period.dart';

void main() {
  final now = DateTime(2026, 8, 14, 15, 30);

  group('dateRangeForPeriod', () {
    test('today: 00:00 a 23:59:59 del día actual', () {
      final range = dateRangeForPeriod(ReportPeriod.today, now);

      expect(range.start, DateTime(2026, 8, 14));
      expect(range.end, DateTime(2026, 8, 14, 23, 59, 59));
    });

    test('week: últimos 7 días (incluye hoy)', () {
      final range = dateRangeForPeriod(ReportPeriod.week, now);

      expect(range.start, DateTime(2026, 8, 8));
      expect(range.end, now);
    });

    test('month: primer día del mes actual hasta ahora', () {
      final range = dateRangeForPeriod(ReportPeriod.month, now);

      expect(range.start, DateTime(2026, 8));
      expect(range.end, now);
    });

    test('year: primer día del año actual hasta ahora', () {
      final range = dateRangeForPeriod(ReportPeriod.year, now);

      expect(range.start, DateTime(2026));
      expect(range.end, now);
    });
  });
}
