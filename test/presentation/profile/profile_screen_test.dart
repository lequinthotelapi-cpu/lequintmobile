import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lequintmobile/application/auth/auth_provider.dart';
import 'package:lequintmobile/domain/models/user.dart';
import 'package:lequintmobile/domain/repositories/auth_repository.dart';
import 'package:lequintmobile/infrastructure/services/session_service.dart';
import 'package:lequintmobile/presentation/profile/profile_screen.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockSessionService extends Mock implements SessionService {}

User _user({
  UserRole role = UserRole.receptionist,
  String? phone,
  String? position,
  String? department,
}) {
  return User(
    uid: 'user-1',
    firstName: 'Juan',
    lastName: 'García',
    email: 'juan@lequint.com',
    document: '12345678',
    gender: 'masculino',
    role: role,
    active: true,
    createdAt: DateTime(2026, 8, 14),
    phone: phone,
    position: position,
    department: department,
  );
}

void main() {
  late _MockAuthRepository authRepository;
  late _MockSessionService sessionService;

  setUp(() {
    authRepository = _MockAuthRepository();
    when(() => authRepository.currentUserId).thenReturn(null);
    when(() => authRepository.signOut()).thenAnswer((_) async {});

    sessionService = _MockSessionService();
    when(sessionService.stopHeartbeat).thenReturn(null);
    when(() => sessionService.clearSessionId()).thenAnswer((_) async {});
  });

  Future<void> pumpScreen(WidgetTester tester, User user) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          sessionServiceProvider.overrideWithValue(sessionService),
          currentUserProvider.overrideWithValue(user),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );
    await tester.pump();
  }

  testWidgets('muestra el nombre y el rol traducido', (tester) async {
    await pumpScreen(tester, _user(role: UserRole.receptionist));

    expect(find.text('Juan García'), findsOneWidget);
    expect(find.text('Recepcionista'), findsOneWidget);
  });

  testWidgets('traduce cada rol correctamente', (tester) async {
    await pumpScreen(tester, _user(role: UserRole.superadmin));
    expect(find.text('Super Administrador'), findsOneWidget);
  });

  testWidgets('muestra email y documento siempre', (tester) async {
    await pumpScreen(tester, _user());

    expect(find.text('juan@lequint.com'), findsOneWidget);
    expect(find.text('12345678'), findsOneWidget);
  });

  testWidgets('no muestra campos vacíos (teléfono, cargo, departamento)', (
    tester,
  ) async {
    await pumpScreen(tester, _user());

    expect(find.text('Teléfono'), findsNothing);
    expect(find.text('Cargo'), findsNothing);
    expect(find.text('Departamento'), findsNothing);
  });

  testWidgets('muestra los campos opcionales cuando tienen valor', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      _user(phone: '+506 8888-8888', position: 'Recepcionista senior'),
    );

    expect(find.text('Teléfono'), findsOneWidget);
    expect(find.text('+506 8888-8888'), findsOneWidget);
    expect(find.text('Cargo'), findsOneWidget);
    expect(find.text('Departamento'), findsNothing);
  });

  testWidgets('cerrar sesión muestra confirmación antes de ejecutar', (
    tester,
  ) async {
    await pumpScreen(tester, _user());

    await tester.tap(find.text('Cerrar Sesión'));
    await tester.pumpAndSettle();

    expect(find.text('¿Cerrar sesión?'), findsOneWidget);
    verifyNever(() => authRepository.signOut());
  });

  testWidgets('confirmar el diálogo ejecuta el cierre de sesión', (
    tester,
  ) async {
    await pumpScreen(tester, _user());

    await tester.tap(find.text('Cerrar Sesión'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cerrar Sesión').last);
    await tester.pumpAndSettle();

    verify(() => authRepository.signOut()).called(1);
  });
}
