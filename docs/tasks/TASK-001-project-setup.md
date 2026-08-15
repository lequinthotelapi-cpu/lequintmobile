# TASK-001 — Setup del proyecto Flutter

**ID**: TASK-001
**SPEC**: N/A (fundación)
**Dependencias**: Ninguna
**Estado**: PENDING

---

## Objetivo

Crear el proyecto Flutter desde cero con toda la configuración inicial: estructura de carpetas, dependencias, Firebase, linting y variables de entorno.

## Alcance

1. Crear proyecto Flutter: `flutter create le_quint --org com.lequint --platforms ios,android`
2. Configurar `pubspec.yaml` con todas las dependencias del MVP (ver `architecture.md` sección 4)
3. Ejecutar `flutterfire configure` apuntando al proyecto Firebase `lequinthotel-ca6ef`
4. Crear estructura de carpetas según `architecture.md` sección 3
5. Configurar `flutter_lints` con reglas adicionales (`avoid_print`, `prefer_const_constructors`)
6. Crear `lib/core/constants/app_colors.dart` con colores de estado de habitaciones y prioridades
7. Crear `lib/core/constants/app_routes.dart` con constantes de rutas
8. Crear `lib/firebase_options.dart` (generado por flutterfire)
9. Configurar `main.dart`: inicializar Firebase, configurar Firestore offline persistence
10. Crear `.env` o `app_config.dart` para configuración de entorno
11. Verificar que la app compila y corre en iOS simulator y Android emulator

## Archivos afectados (rutas relativas al proyecto Flutter)

```
pubspec.yaml
lib/main.dart
lib/firebase_options.dart
lib/core/constants/app_colors.dart
lib/core/constants/app_routes.dart
analysis_options.yaml
```

## Criterios de aceptación

- [ ] `flutter pub get` sin errores
- [ ] `flutter run` en iOS simulator sin errores
- [ ] `flutter run` en Android emulator sin errores
- [ ] Firebase inicializado correctamente (sin errores en consola)
- [ ] Firestore offline persistence habilitado
- [ ] Linting configurado (`flutter analyze` sin warnings)
- [ ] Estructura de carpetas creada según arquitectura

## Notas

- El proyecto Firebase es `lequinthotel-ca6ef` (mismo que el sistema web)
- Ejecutar `flutterfire configure` requiere tener instalado `firebase-tools` y `flutterfire_cli`
- Comando: `dart pub global activate flutterfire_cli`
