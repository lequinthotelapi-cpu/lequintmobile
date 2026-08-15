import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lequintmobile/application/auth/auth_provider.dart';
import 'package:lequintmobile/core/errors/app_exception.dart';
import 'package:lequintmobile/domain/repositories/auth_repository.dart';
import 'package:lequintmobile/presentation/auth/login_screen.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository authRepository;

  setUp(() {
    authRepository = _MockAuthRepository();
    when(() => authRepository.currentUserId).thenReturn(null);
  });

  Future<void> pumpLoginScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(authRepository)],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    // Deja que AuthNotifier resuelva AuthInitial -> AuthUnauthenticated.
    await tester.pump();
  }

  testWidgets(
    'muestra errores de validación sin llamar al repositorio si los campos están vacíos',
    (tester) async {
      await pumpLoginScreen(tester);

      await tester.tap(find.text('Iniciar sesión'));
      await tester.pump();

      expect(find.text('Ingresa tu correo'), findsOneWidget);
      expect(find.text('Ingresa tu contraseña'), findsOneWidget);
      verifyNever(
        () => authRepository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    },
  );

  testWidgets(
    'muestra "Correo o contraseña incorrectos" con credenciales inválidas',
    (tester) async {
      when(
        () => authRepository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const InvalidCredentialsException());

      await pumpLoginScreen(tester);

      await tester.enterText(
        find.byType(TextFormField).first,
        'juan@example.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'wrong-password');
      await tester.tap(find.text('Iniciar sesión'));
      await tester.pump();

      expect(find.text('Correo o contraseña incorrectos'), findsOneWidget);
    },
  );
}
