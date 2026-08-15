/// Período seleccionable en ReportsScreen — ver SPEC-010.
enum ReportPeriod {
  today('Hoy'),
  week('Semana'),
  month('Mes'),
  year('Año');

  const ReportPeriod(this.label);

  final String label;
}

class DateRange {
  const DateRange(this.start, this.end);

  final DateTime start;
  final DateTime end;
}

/// Traduce [period] a un rango de fechas concreto, relativo a [now] — ver
/// SPEC-010 "Reglas de negocio" 2-5:
/// - Hoy: 00:00 a 23:59:59 del día actual
/// - Semana: últimos 7 días (incluye hoy)
/// - Mes: primer día del mes actual hasta hoy
/// - Año: primer día del año actual hasta hoy
///
/// [now] es un parámetro (no `DateTime.now()` interno) para que el
/// resultado sea determinista y comparable — la capa de providers pasa
/// `DateTime.now()` en producción.
DateRange dateRangeForPeriod(ReportPeriod period, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  switch (period) {
    case ReportPeriod.today:
      return DateRange(
        today,
        DateTime(now.year, now.month, now.day, 23, 59, 59),
      );
    case ReportPeriod.week:
      return DateRange(today.subtract(const Duration(days: 6)), now);
    case ReportPeriod.month:
      return DateRange(DateTime(now.year, now.month), now);
    case ReportPeriod.year:
      return DateRange(DateTime(now.year), now);
  }
}
