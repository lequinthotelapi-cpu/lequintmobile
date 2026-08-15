# PROJECT READINESS REVIEW — Le Quint Mobile App

> Evaluación del estado de preparación para comenzar la implementación.
> Actualizado al finalizar la Fase 2 (Consolidación + Design System + Claude Handoff).

---

## Veredicto

```
╔══════════════════════════════════════════╗
║   PROJECT DEFINITION READY              ║
║   Listo para comenzar implementación    ║
╚══════════════════════════════════════════╝
```

---

## CONFIRMED — Todo lo decidido y validado

### Producto
- [x] Visión del producto definida (`docs/product/vision.md`)
- [x] 4 personas definidas con necesidades claras (`docs/product/personas.md`)
- [x] Alcance MVP definido — in scope / out of scope (`docs/product/scope.md`)
- [x] 31 funcionalidades clasificadas (`docs/requirements/functional.md`)
- [x] Criterios de éxito del MVP definidos

### Decisiones técnicas (19 decisiones CONFIRMED)
- [x] Framework: Flutter (DECISION-001)
- [x] Plataformas: iOS + Android (DECISION-002)
- [x] Backend: Firebase directo, sin API REST (DECISION-017)
- [x] State management: Riverpod (ADR-003, CONFIRMED)
- [x] Navegación: GoRouter (ADR-004, CONFIRMED)
- [x] Offline: Firestore persistence nativa (DECISION-006)
- [x] Notificaciones: FCM reutilizado (DECISION-007)
- [x] Sesiones: heartbeat con AppLifecycleObserver (ADR-006, CONFIRMED)
- [x] Navegación por rol: bottom nav diferenciada (DECISION-008)
- [x] Dashboards diferenciados por rol (DECISION-009)
- [x] Check-in/out con confirmación explícita (DECISION-010)
- [x] Completar tarea: mismos campos que sistema web (DECISION-011)
- [x] Nombre: Le Quint (DECISION-013)
- [x] Agregar cargo: desde catálogo de productos (DECISION-014)
- [x] Dashboard financiero: mes actual por defecto (DECISION-015)
- [x] Housekeeper ve todas las habitaciones (DECISION-016)
- [x] Habitaciones: lista/grid sin SVG (DECISION-019)
- [x] Idioma: español únicamente (DECISION-018)
- [x] IVA: ignorar en MVP, IVA=0 con TODO (DECISION-005)

### Arquitectura
- [x] Arquitectura de capas definida (Presentation → Domain → Infrastructure)
- [x] Estructura de carpetas definida
- [x] Dependencias principales definidas (pubspec.yaml)
- [x] Colecciones Firestore mapeadas
- [x] Queries críticas documentadas
- [x] Operaciones WriteBatch identificadas
- [x] Índices Firestore necesarios documentados

### UX y Design System
- [x] Visual direction definida (`docs/ux/visual-direction.md`)
- [x] Design System completo (`docs/ux/design-system.md`)
- [x] Design tokens definidos (`docs/ux/design-tokens.md`)
- [x] Componentes especificados (`docs/ux/components.md`)
- [x] Patrones de interacción definidos (`docs/ux/interaction.md`)
- [x] Referencias visuales disponibles y documentadas (`docs/ux/references.md`)
- [x] Mapa de navegación por rol (`docs/ux/navigation.md`)

### SPECs (12 SPECs, todas READY_FOR_DEVELOPMENT)
- [x] SPEC-001 Autenticación
- [x] SPEC-002 Shell y navegación
- [x] SPEC-003 Dashboard por rol
- [x] SPEC-004 Mis tareas (Housekeeper)
- [x] SPEC-005 Completar tarea
- [x] SPEC-006 Llegadas y Check-In
- [x] SPEC-007 Salidas y Check-Out
- [x] SPEC-008 Estado de habitaciones
- [x] SPEC-009 Notificaciones push
- [x] SPEC-010 Dashboard financiero
- [x] SPEC-011 Cuenta de huésped y agregar cargo
- [x] SPEC-012 Perfil y cerrar sesión
- [x] Todas las SPECs tienen sección UX/DESIGN REQUIREMENTS

### TASKs (16 TASKs, todas PENDING con criterios claros)
- [x] TASK-001 al TASK-016 definidas con dependencias y criterios de aceptación

### Testing
- [x] Estrategia de testing definida (`docs/testing/strategy.md`)
- [x] Casos de test obligatorios identificados por nivel

### Claude Handoff
- [x] Guía de desarrollo para Claude (`docs/ai/claude-development-guide.md`)
- [x] Protocolo de inicio de TASK definido
- [x] Definition of Done definido
- [x] Formato de entrega de TASK definido
- [x] Reglas de libertad creativa definidas

---

## OPEN — Preguntas genuinamente pendientes

### OQ-012 — Múltiples tokens FCM por usuario
**Pregunta**: ¿Soportar múltiples tokens FCM por usuario (múltiples dispositivos)?
**Impacto**: Arquitectura de notificaciones. Requeriría cambiar `fcmToken: string` a `fcmTokens: string[]`
**Estado**: No bloquea el MVP. Un solo token es suficiente para el MVP.
**Acción requerida**: Decidir antes del Release 2.

---

## RISKS — Riesgos identificados

### RISK-001 — Índices Firestore
**Descripción**: Las queries compuestas (checkInDate + status, checkOutDate + status, assignedTo + status) requieren índices en Firestore que pueden no existir.
**Impacto**: Error en runtime al ejecutar las queries por primera vez.
**Mitigación**: Firestore proporciona el link para crear el índice en el mensaje de error. Documentar en TASK-003.
**Severidad**: Baja (fácil de resolver, no bloquea el desarrollo)

### RISK-002 — Configuración APNs para iOS
**Descripción**: Las notificaciones push en iOS requieren un certificado APNs en Apple Developer Console.
**Impacto**: Las notificaciones push no funcionarán en iOS sin esta configuración.
**Mitigación**: Documentado en TASK-012. Requiere acceso a Apple Developer Account.
**Severidad**: Media (bloquea notificaciones en iOS, no bloquea el resto de la app)

### RISK-003 — Firestore Rules existentes
**Descripción**: Las Firestore Rules del sistema web pueden no permitir todas las operaciones que necesita la app móvil (ej: crear guestAccount desde móvil).
**Impacto**: Errores de permisos en runtime.
**Mitigación**: Verificar las rules existentes en `/workspace/firestore.rules` antes de implementar cada operación de escritura.
**Severidad**: Media (puede requerir actualizar las rules)

### RISK-004 — Cálculo de noches para RevPAR/ADR
**Descripción**: El algoritmo de cálculo de noches que intersectan un período es complejo. Si la implementación Flutter difiere del sistema web, los KPIs financieros serán inconsistentes.
**Impacto**: Datos financieros incorrectos en el dashboard.
**Mitigación**: Revisar `FinancialReportsService` del sistema web y replicar exactamente el algoritmo.
**Severidad**: Media

---

## DEPENDENCIES — Dependencias externas

| Dependencia | Responsable | Estado |
|---|---|---|
| Proyecto Firebase `lequinthotel-ca6ef` | Sistema web existente | ✅ Disponible |
| Apple Developer Account (para APNs) | Propietario del hotel | ⚠️ Verificar acceso |
| Google Play Console | Propietario del hotel | ⚠️ Verificar acceso |
| `flutterfire_cli` instalado | Desarrollador | Instalar en TASK-001 |
| `firebase-tools` instalado | Desarrollador | Instalar en TASK-001 |

---

## ORDEN DE IMPLEMENTACIÓN RECOMENDADO

```
TASK-001  Setup del proyecto Flutter          ← empezar aquí
TASK-002  Modelos de dominio
TASK-006  Widgets compartidos (Design System) ← en paralelo con TASK-002
TASK-003  Repositorios Firebase
TASK-004  Autenticación y sesiones
TASK-005  Shell y navegación
TASK-008  Mis tareas y completar tarea        ← mayor impacto, primero
TASK-009  Llegadas y Check-In
TASK-010  Salidas y Check-Out
TASK-011  Estado de habitaciones
TASK-012  Notificaciones push
TASK-007  Dashboard por rol
TASK-013  Dashboard financiero
TASK-014  Cuenta de huésped y agregar cargo
TASK-015  Perfil y cerrar sesión
TASK-016  Supervisión housekeeping (Manager)
```

---

## CÓMO COMENZAR

1. Leer `docs/ai/claude-development-guide.md` (contrato completo)
2. Leer `docs/project/decisions.md` (19 decisiones confirmadas)
3. Leer `docs/architecture/architecture.md` (estructura técnica)
4. Ejecutar TASK-001 (crear proyecto Flutter)
5. Continuar en el orden indicado arriba

---

## HISTORIAL DE REVISIONES

| Fecha | Fase | Estado |
|---|---|---|
| Sesión inicial | Fase 1 — Discovery y definición | READY FOR DEVELOPMENT (sin Design System) |
| Sesión actual | Fase 2 — Consolidación + Design System + Claude Handoff | PROJECT DEFINITION READY |
