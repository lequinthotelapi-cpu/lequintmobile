import 'package:cloud_firestore/cloud_firestore.dart';

/// Convierte un valor de Firestore (`Timestamp`) a [DateTime].
/// Devuelve `null` si el valor es nulo o de un tipo inesperado, en vez de
/// lanzar una excepción — los modelos deben tolerar documentos incompletos.
DateTime? tryParseTimestamp(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}

/// Igual que [tryParseTimestamp] pero para campos requeridos: si el valor
/// es nulo o inválido, recurre a [fallback] (por defecto, el momento actual)
/// en vez de lanzar una excepción.
DateTime parseTimestamp(dynamic value, {DateTime? fallback}) =>
    tryParseTimestamp(value) ?? fallback ?? DateTime.now();
