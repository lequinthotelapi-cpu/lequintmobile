/// Formateo de moneda sin depender de `intl` (mismo motivo que
/// `date_extensions.dart` — DECISION-018: app solo en español, sin datos de
/// locale). Separador de miles `,`, 2 decimales, símbolo `$`.
extension CurrencyFormatting on num {
  String toCurrency() {
    final fixed = toStringAsFixed(2);
    final parts = fixed.split('.');
    final integerPart = parts[0];
    final isNegative = integerPart.startsWith('-');
    final digits = isNegative ? integerPart.substring(1) : integerPart;

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }

    return '${isNegative ? '-' : ''}\$${buffer.toString()}.${parts[1]}';
  }
}
