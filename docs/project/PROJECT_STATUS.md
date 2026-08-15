# ESTADO DEL PROYECTO — Le Quint Mobile App

> Este archivo es el punto de entrada para cualquier sesión futura.
> Leer este archivo primero, antes que cualquier otro.

---

## Resumen ejecutivo

App móvil Flutter para el personal del hotel Le Quint. Complementa el sistema web existente (Angular + Firebase). No es una copia del sistema web — selecciona las funcionalidades con mayor valor en movilidad.

**Estado**: MVP IMPLEMENTADO — las 16 TASKs completadas (TASK-001 a TASK-016), más `InHouseScreen` y `FrontDeskScreen` (referenciadas en navigation.md/architecture.md desde el inicio pero sin TASK propia asignada — quedaron como placeholder hasta ahora). Único pendiente: configuración manual de APNs para push en iOS (ver TASK-012) y verificación en dispositivos físicos.

---

## Documentos clave (leer en este orden)

1. Este archivo (`PROJECT_STATUS.md`) — contexto general
2. `decisions.md` — 19 decisiones confirmadas
3. `docs/ai/claude-development-guide.md` — contrato para implementación
4. `docs/architecture/architecture.md` — arquitectura técnica
5. `docs/ux/design-system.md` — sistema de diseño
6. SPEC de la tarea a implementar
7. TASK correspondiente

---

## Decisiones definitivas (resumen)

| # | Decisión |
|---|---|
| 001 | Framework: **Flutter** |
| 002 | Plataformas: **iOS y Android** |
| 003 | Distribución: **App Store y Google Play** |
| 004 | Propietario = rol **superadmin** |
| 005 | IVA: **ignorar en MVP**, parametrizado en sistema web |
| 006 | Offline: **Firestore nativo** (persistenceEnabled) |
| 007 | Notificaciones: **FCM** reutilizado |
| 008 | Navegación: **bottom nav por rol** + menú secundario |
| 009 | Dashboards: **diferenciados por rol** |
| 010 | Check-in/out: **confirmación explícita** obligatoria |
| 011 | Completar tarea: **mismos campos** que sistema web |
| 012 | Proyecto: **repositorio Flutter nuevo** independiente |
| 013 | Nombre: **Le Quint** |
| 014 | Agregar cargo: **desde catálogo de productos** |
| 015 | Dashboard financiero: **mes actual** por defecto |
| 016 | Housekeeper: ve **todas las habitaciones** |
| 017 | Backend: **Firebase directo** (sin API REST intermedia) |
| 018 | Idioma: **español únicamente** |
| 019 | Habitaciones: **lista/grid** (sin mapa SVG) |

Ver detalle completo en `decisions.md`.

---

## Tecnología

| Componente | Decisión |
|---|---|
| Framework | Flutter (Dart) |
| State management | Riverpod |
| Navegación | GoRouter |
| Backend | Firebase Firestore + Auth + FCM |
| Firebase project | `lequinthotel-ca6ef` (compartido con sistema web) |
| Offline | Firestore persistence nativa |
| Almacenamiento seguro | flutter_secure_storage |

---

## Usuarios y roles

| Rol en sistema | Perfil | Dashboard |
|---|---|---|
| `superadmin` | Propietario / Super Admin | Completo (KPIs operacionales + financieros) |
| `admin` | Administrador | Completo |
| `manager` | Gerente | KPIs operacionales + financieros + housekeeping |
| `receptionist` | Recepcionista | Llegadas/salidas + habitaciones |
| `housekeeper` | Personal de limpieza | Solo sus tareas del día |
| `guest` | Huésped | **Fuera del MVP — release futuro** |

---

## SPECs del MVP (todas READY_FOR_DEVELOPMENT)

| SPEC | Nombre |
|---|---|
| SPEC-001 | Autenticación |
| SPEC-002 | Shell y navegación |
| SPEC-003 | Dashboard por rol |
| SPEC-004 | Mis tareas (Housekeeper) |
| SPEC-005 | Completar tarea |
| SPEC-006 | Llegadas y Check-In |
| SPEC-007 | Salidas y Check-Out |
| SPEC-008 | Estado de habitaciones |
| SPEC-009 | Notificaciones push |
| SPEC-010 | Dashboard financiero |
| SPEC-011 | Cuenta de huésped y agregar cargo |
| SPEC-012 | Perfil y cerrar sesión |

---

## TASKs y orden de implementación

```
TASK-001  Setup del proyecto Flutter          ← empezar aquí
TASK-002  Modelos de dominio                  ← después de 001
TASK-006  Widgets compartidos                 ← en paralelo con 002
TASK-003  Repositorios Firebase               ← después de 002
TASK-004  Autenticación y sesiones            ← después de 003
TASK-005  Shell y navegación                  ← después de 004
TASK-008  Mis tareas y completar tarea        ← mayor impacto, primero
TASK-009  Llegadas y Check-In                 ← en paralelo con 008
TASK-010  Salidas y Check-Out                 ← después de 009
TASK-011  Estado de habitaciones
TASK-012  Notificaciones push
TASK-007  Dashboard por rol
TASK-013  Dashboard financiero
TASK-014  Cuenta de huésped y agregar cargo
TASK-015  Perfil y cerrar sesión
TASK-016  Supervisión housekeeping (Manager)
```

---

## Firebase

- **Project ID**: `lequinthotel-ca6ef`
- **Colecciones usadas**: users, rooms, bookings, guestAccounts, housekeepingTasks, notifications, products, sales
- **Firestore Rules**: las existentes aplican directamente
- **FCM**: infraestructura existente reutilizada

Al crear el proyecto Flutter ejecutar:
```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=lequinthotel-ca6ef
```

---

## Estructura de documentación

```
docs/
├── project/
│   ├── PROJECT_STATUS.md           ← este archivo (leer primero)
│   ├── PROJECT_READINESS_REVIEW.md ← evaluación de readiness
│   ├── decisions.md                ← 19 decisiones definitivas
│   ├── glossary.md                 ← términos del dominio y técnicos
│   └── project-structure-note.md  ← nota sobre repositorio nuevo
├── product/
│   ├── vision.md
│   ├── personas.md
│   ├── scope.md
│   └── mvp.md
├── requirements/
│   └── functional.md               ← 31 funcionalidades clasificadas
├── ux/
│   ├── navigation.md               ← mapa de pantallas por rol
│   ├── visual-direction.md         ← dirección visual (Premium Hospitality Glass UI)
│   ├── design-system.md            ← sistema de diseño completo
│   ├── design-tokens.md            ← tokens (colores, tipografía, spacing)
│   ├── components.md               ← especificación de componentes
│   ├── interaction.md              ← patrones de interacción
│   └── references.md               ← guía para usar las referencias visuales
├── design-references/
│   ├── dashboard.jpg
│   ├── glass-effect.jpg
│   ├── colors.jpg
│   ├── controls.jpg
│   └── general.jpg
├── architecture/
│   ├── architecture.md             ← Flutter + Riverpod + GoRouter
│   ├── api.md                      ← colecciones, queries, operaciones
│   └── decisions/
│       └── ADR-001-006.md
├── specs/
│   └── SPEC-001 al SPEC-012
├── tasks/
│   └── TASK-001 al TASK-016
├── testing/
│   └── strategy.md
└── ai/
    └── claude-development-guide.md ← contrato para implementación con Claude
```

---

## Cómo retomar en una nueva sesión

1. Leer este archivo (`PROJECT_STATUS.md`)
2. Leer `docs/ai/claude-development-guide.md` (contrato completo)
3. Identificar la primera TASK con estado PENDING
4. Leer la SPEC correspondiente a esa TASK
5. Implementar siguiendo los criterios de aceptación de la TASK
6. Marcar la TASK como DONE al completarla
7. Continuar con la siguiente TASK en el orden indicado arriba
