import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/errors/app_exception.dart';

/// Convierte errores de Firestore/Firebase en [AppException] tipadas.
/// Los errores de negocio ([AppException] lanzadas explícitamente por los
/// repositorios) deben re-lanzarse tal cual, sin pasar por aquí.
AppException mapFirestoreException(Object error) {
  if (error is FirebaseException) {
    switch (error.code) {
      case 'unavailable':
      case 'network-request-failed':
        return const NetworkException();
      case 'deadline-exceeded':
        return const TimeoutException();
      default:
        return const UnknownException();
    }
  }
  return const UnknownException();
}

/// Re-emite los errores de un stream de Firestore como [AppException].
Stream<T> mapFirestoreStreamErrors<T>(Stream<T> source) {
  return source.transform(
    StreamTransformer<T, T>.fromHandlers(
      handleError: (Object error, StackTrace stackTrace, EventSink<T> sink) {
        sink.addError(
          error is AppException ? error : mapFirestoreException(error),
          stackTrace,
        );
      },
    ),
  );
}
