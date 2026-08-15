const _shortMonthsEs = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

/// Formateo de fechas en español sin depender de la inicialización de
/// datos de locale de `intl` (DECISION-018: la app es solo en español).
extension DateFormattingEs on DateTime {
  /// Ej: "14 ago, 10:00 AM".
  String toShortDateTimeEs() {
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    final period = hour < 12 ? 'AM' : 'PM';
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$day ${_shortMonthsEs[month - 1]}, $hour12:$minuteStr $period';
  }

  /// Ej: "14 ago 2026".
  String toShortDateEs() => '$day ${_shortMonthsEs[month - 1]} $year';
}
