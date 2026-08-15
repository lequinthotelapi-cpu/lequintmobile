import 'package:flutter_test/flutter_test.dart';
import 'package:lequintmobile/domain/models/user.dart';
import 'package:lequintmobile/presentation/shell/bottom_nav_config.dart';

void main() {
  group('hasMoreMenu', () {
    test('es false solo para housekeeper (4 ítems fijos)', () {
      expect(hasMoreMenu(UserRole.housekeeper), isFalse);
      expect(hasMoreMenu(UserRole.receptionist), isTrue);
      expect(hasMoreMenu(UserRole.manager), isTrue);
      expect(hasMoreMenu(UserRole.admin), isTrue);
      expect(hasMoreMenu(UserRole.superadmin), isTrue);
    });
  });

  group('bottomNavItemsForRole', () {
    test('housekeeper tiene exactamente 4 ítems', () {
      expect(bottomNavItemsForRole(UserRole.housekeeper), hasLength(4));
    });

    test('superadmin y admin tienen la misma configuración', () {
      final superadminLabels = bottomNavItemsForRole(
        UserRole.superadmin,
      ).map((i) => i.label);
      final adminLabels = bottomNavItemsForRole(
        UserRole.admin,
      ).map((i) => i.label);
      expect(superadminLabels, equals(adminLabels));
    });
  });

  group('moreMenuItemsForRole', () {
    test('vacío para housekeeper', () {
      expect(moreMenuItemsForRole(UserRole.housekeeper), isEmpty);
    });

    test('incluye Notificaciones y Perfil para receptionist', () {
      final labels = moreMenuItemsForRole(
        UserRole.receptionist,
      ).map((i) => i.label);
      expect(labels, containsAll(['Notificaciones', 'Perfil']));
    });
  });
}
