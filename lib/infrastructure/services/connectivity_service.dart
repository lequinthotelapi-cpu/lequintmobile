import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectivityStatus { online, offline }

/// Estado de conectividad en tiempo real — usado por [OfflineBanner] y por
/// cualquier pantalla que necesite adaptar su comportamiento sin conexión
/// (DECISION-006).
final connectivityProvider = StreamProvider<ConnectivityStatus>((ref) {
  final connectivity = Connectivity();
  return connectivity.onConnectivityChanged.map(_toStatus);
});

ConnectivityStatus _toStatus(List<ConnectivityResult> results) {
  final hasConnection = results.any(
    (result) => result != ConnectivityResult.none,
  );
  return hasConnection ? ConnectivityStatus.online : ConnectivityStatus.offline;
}
