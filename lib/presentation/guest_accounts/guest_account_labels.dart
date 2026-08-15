import '../../domain/models/guest_account.dart';

/// Labels en español para los enums de [GuestAccount] — ver SPEC-011.
extension ChargeTypeLabel on ChargeType {
  String get label => switch (this) {
    ChargeType.accommodation => 'Alojamiento',
    ChargeType.pos => 'Punto de venta',
    ChargeType.service => 'Servicio',
    ChargeType.minibar => 'Minibar',
    ChargeType.laundry => 'Lavandería',
    ChargeType.spa => 'Spa',
    ChargeType.restaurant => 'Restaurante',
    ChargeType.other => 'Otro',
  };
}

extension PaymentMethodLabel on PaymentMethod {
  String get label => switch (this) {
    PaymentMethod.cash => 'Efectivo',
    PaymentMethod.card => 'Tarjeta',
    PaymentMethod.transfer => 'Transferencia',
    PaymentMethod.deposit => 'Depósito',
  };
}

extension GuestAccountStatusLabel on GuestAccountStatus {
  String get label => switch (this) {
    GuestAccountStatus.open => 'Cuenta abierta',
    GuestAccountStatus.closed => 'Cuenta cerrada',
  };
}
