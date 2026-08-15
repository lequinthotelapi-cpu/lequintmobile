# NOTA PARA FUTURAS SESIONES — Estructura del proyecto

## Situación actual

La documentación del proyecto móvil está en:
```
/workspace/docs/   ← proyecto Angular (sistema web existente)
```

## Situación futura

Cuando se cree el proyecto Flutter nuevo, la documentación se migrará a:
```
/[nuevo-proyecto-flutter]/docs/
```

## Impacto en TASKs

- Las rutas de archivos en las TASKs son **relativas al proyecto Flutter**, no al workspace Angular.
- Ejemplo: cuando una TASK dice `lib/main.dart`, se refiere a `[nuevo-proyecto]/lib/main.dart`.
- La TASK-001 incluye `flutter create` y la estructura inicial del proyecto.

## Cómo retomar el proyecto en una nueva sesión

1. Leer este archivo primero.
2. Leer `/docs/project/decisions.md` para conocer todas las decisiones.
3. Leer `/docs/product/mvp.md` para conocer el alcance.
4. Leer `/docs/architecture/architecture.md` para la arquitectura técnica.
5. Revisar qué SPECs están en `/docs/specs/` y cuáles tienen estado READY_FOR_DEVELOPMENT.
6. Revisar qué TASKs están en `/docs/tasks/` y cuáles están pendientes.
7. Continuar desde la primera TASK pendiente.

## Firebase

El proyecto Flutter usará el **mismo proyecto Firebase** que el sistema web:
- Project ID: `lequinthotel-ca6ef`
- Las colecciones Firestore son compartidas
- Los usuarios son los mismos
- Las Firestore Rules existentes aplican

Al crear el proyecto Flutter, se debe ejecutar `flutterfire configure` apuntando a `lequinthotel-ca6ef`.
