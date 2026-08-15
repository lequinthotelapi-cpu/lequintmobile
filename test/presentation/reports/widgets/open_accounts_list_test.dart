import 'package:flutter_test/flutter_test.dart';
import 'package:lequintmobile/domain/models/guest_account.dart';
import 'package:lequintmobile/presentation/reports/widgets/open_accounts_list.dart';

GuestAccount _account(String id, double balance) {
  return GuestAccount(
    id: id,
    bookingId: 'b-$id',
    bookingNumber: 'BK-$id',
    guestId: 'guest-$id',
    guestName: 'Guest $id',
    roomId: 'r-$id',
    roomNumber: id,
    status: GuestAccountStatus.open,
    checkInDate: DateTime(2026, 8, 10),
    charges: const [],
    payments: const [],
    subtotal: balance,
    tax: 0,
    total: balance,
    paid: 0,
    balance: balance,
    createdAt: DateTime(2026, 8, 10),
    createdBy: 'admin-1',
  );
}

void main() {
  group('topOpenAccountsByBalance', () {
    test('ordena por balance descendente', () {
      final accounts = [
        _account('1', 50),
        _account('2', 200),
        _account('3', 100),
      ];

      final sorted = topOpenAccountsByBalance(accounts);

      expect(sorted.map((a) => a.id).toList(), ['2', '3', '1']);
    });

    test('limita a 5 por defecto', () {
      final accounts = List.generate(8, (i) => _account('$i', i.toDouble()));

      expect(topOpenAccountsByBalance(accounts).length, 5);
    });

    test('respeta un límite custom', () {
      final accounts = [
        _account('1', 10),
        _account('2', 20),
        _account('3', 30),
      ];

      expect(topOpenAccountsByBalance(accounts, limit: 2).length, 2);
    });
  });
}
