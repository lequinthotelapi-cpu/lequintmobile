import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Varias pantallas (dashboards, ReportsScreen) combinan streams/futures
/// independientes en vez de un solo provider combinado, para no perder la
/// reactividad de cada uno. Esto decide un solo skeleton/error para toda
/// la pantalla a partir de esos valores — ver SPEC-003/SPEC-010 "Estados
/// de pantalla".
bool anyLoading(List<AsyncValue<Object?>> values) =>
    values.any((value) => value.isLoading && !value.hasValue);

Object? firstError(List<AsyncValue<Object?>> values) {
  for (final value in values) {
    if (value.hasError) return value.error;
  }
  return null;
}
