import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lequintmobile/application/auth/auth_provider.dart';
import 'package:lequintmobile/application/guest_accounts/guest_account_provider.dart';
import 'package:lequintmobile/core/constants/app_colors.dart';
import 'package:lequintmobile/domain/models/guest_account.dart';
import 'package:lequintmobile/domain/models/user.dart';
import 'package:lequintmobile/presentation/guest_accounts/guest_account_screen.dart';

GuestAccount _account({
  required double balance,
  GuestAccountStatus status = GuestAccountStatus.open,
}) {
  return GuestAccount(
    id: 'acc-1',
    bookingId: 'b-1',
    bookingNumber: 'BK-1',
    guestId: 'guest-1',
    guestName: 'Juan Pérez',
    roomId: 'r1',
    roomNumber: '205',
    status: status,
    checkInDate: DateTime(2026, 8, 12),
    charges: const [],
    payments: const [],
    subtotal: 80,
    tax: 8,
    total: 88,
    paid: 88 - balance,
    balance: balance,
    createdAt: DateTime(2026, 8, 12),
    createdBy: 'admin-1',
  );
}

Future<void> _pump(
  WidgetTester tester, {
  required UserRole role,
  required GuestAccount account,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentUserRoleProvider.overrideWithValue(role),
        guestAccountProvider('acc-1').overrideWith((ref) async => account),
      ],
      child: const MaterialApp(home: GuestAccountScreen(accountId: 'acc-1')),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('receptionist ve el botón Agregar Cargo en cuenta abierta', (
    tester,
  ) async {
    await _pump(
      tester,
      role: UserRole.receptionist,
      account: _account(balance: 50),
    );

    expect(find.text('Agregar Cargo'), findsOneWidget);
  });

  testWidgets('manager NO ve el botón Agregar Cargo', (tester) async {
    await _pump(tester, role: UserRole.manager, account: _account(balance: 50));

    expect(find.text('Agregar Cargo'), findsNothing);
  });

  testWidgets('admin ve el botón Agregar Cargo', (tester) async {
    await _pump(tester, role: UserRole.admin, account: _account(balance: 50));

    expect(find.text('Agregar Cargo'), findsOneWidget);
  });

  testWidgets('receptionist no ve el botón si la cuenta está cerrada', (
    tester,
  ) async {
    await _pump(
      tester,
      role: UserRole.receptionist,
      account: _account(balance: 0, status: GuestAccountStatus.closed),
    );

    expect(find.text('Agregar Cargo'), findsNothing);
  });

  testWidgets('saldo > 0 se muestra en rojo', (tester) async {
    await _pump(
      tester,
      role: UserRole.receptionist,
      account: _account(balance: 50),
    );

    final balanceText = tester.widget<Text>(find.text(r'$50.00'));
    expect(balanceText.style?.color, AppColors.error);
  });

  testWidgets('saldo == 0 se muestra en verde', (tester) async {
    await _pump(
      tester,
      role: UserRole.receptionist,
      account: _account(balance: 0),
    );

    final balanceText = tester.widget<Text>(find.text(r'$0.00'));
    expect(balanceText.style?.color, AppColors.success);
  });
}
