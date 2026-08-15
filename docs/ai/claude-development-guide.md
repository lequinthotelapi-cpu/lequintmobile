# CLAUDE DEVELOPMENT GUIDE — Le Quint Mobile App

> Este documento es el contrato entre la definición del producto y Claude Code.
> Leer este documento COMPLETO antes de implementar cualquier TASK.

---

## Contexto del proyecto

### Sistema web existente
Existe un sistema web **funcional y actualmente en producción** de gestión hotelera (Le Quint Hotel), construido con Angular 16+ y Firebase. Este sistema es la fuente de verdad para:

- Reglas de negocio
- Modelos de datos y estructura de Firestore
- Colecciones y campos existentes
- Roles y permisos
- Flujos operacionales
- Validaciones
- Comportamiento esperado

**Ubicación del sistema web**: `/workspace/src/` (proyecto Angular en el mismo repositorio)

### App móvil
La app móvil Flutter es un proyecto **nuevo e independiente** que complementa el sistema web. No lo reemplaza. Comparte el mismo proyecto Firebase (`lequinthotel-ca6ef`) y accede directamente a las mismas colecciones Firestore.

**La app móvil NO debe inventar reglas de negocio.** Si el sistema web ya define un comportamiento, la app móvil debe replicarlo fielmente.

---

## Fuentes de verdad (en orden de prioridad)

1. **Sistema web** (`/workspace/src/`) — comportamiento real implementado
2. **SPECs** (`docs/specs/`) — especificaciones del MVP móvil
3. **Decisiones** (`docs/project/decisions.md`) — decisiones confirmadas
4. **Arquitectura** (`docs/architecture/`) — estructura técnica
5. **Design System** (`docs/ux/`) — identidad visual y componentes
6. **TASKs** (`docs/tasks/`) — alcance de implementación

Cuando exista conflicto entre estas fuentes, escalar en ese orden. Si el sistema web contradice una SPEC, **reportar el conflicto antes de implementar**.

---

## Protocolo de inicio de TASK

Antes de escribir una sola línea de código:

1. Leer `docs/project/PROJECT_STATUS.md` (contexto general)
2. Leer la SPEC asociada a la TASK
3. Leer las TASKs dependientes (para entender el contexto)
4. Leer los ADRs relevantes (`docs/architecture/decisions/ADR-001-006.md`)
5. Leer el Design System (`docs/ux/design-system.md`, `docs/ux/design-tokens.md`)
6. Consultar las referencias visuales (`docs/design-references/`)
7. Revisar el sistema web cuando la TASK involucre lógica de negocio existente
8. Verificar que no existen contradicciones entre las fuentes

---

## Reglas de implementación

### Reglas absolutas (nunca violar)

1. **No inventar reglas de negocio** — Si no está en la SPEC ni en el sistema web, no implementarlo
2. **No cambiar arquitectura** sin documentar el cambio y justificarlo
3. **No cambiar el alcance** de una TASK sin autorización explícita
4. **No implementar funcionalidades fuera de la TASK** — aunque parezcan obvias
5. **No modificar el sistema web** — La app móvil no modifica el código del sistema web. Puede leer y escribir en las mismas fuentes de datos Firebase cuando una SPEC lo requiera, respetando las reglas de negocio y seguridad existentes.
6. **No implementar funcionalidades para huéspedes** — están fuera del MVP (ver `docs/product/scope.md`)
7. **No hardcodear valores** que deberían venir de Firestore o de los tokens de diseño
8. **No usar `print()`** en código de producción — usar `debugPrint` solo en desarrollo

### Reglas de calidad

9. Crear tests para toda lógica de negocio crítica (ver `docs/testing/strategy.md`)
10. Manejar los estados relevantes para cada pantalla: loading, success, empty, error, offline
11. Usar `WriteBatch` para operaciones que modifican múltiples documentos
12. Usar `const` constructors donde sea posible
13. Usar `ListView.builder` para listas (nunca `Column` con children para listas largas)
14. Formatear código con `dart format` antes de entregar

### Reglas de diseño

15. Seguir el Design System (`docs/ux/design-system.md`) — no Material Design estándar
16. Usar los tokens de `design-tokens.md` — no hardcodear colores ni tamaños
17. Los colores de estado de habitaciones y prioridades son IDÉNTICOS al sistema web
18. Consultar las referencias visuales para entender la intención, no para copiar literalmente
19. Fondo de la app: gradiente oscuro (no fondo blanco)
20. Glass cards para KPIs y cards de información (no para listas largas)

---

## Libertad creativa de Claude

Claude tiene libertad para mejorar dentro de los límites del Design System:

### Puede mejorar
- Composición y spacing dentro de una pantalla
- Microinteracciones y animaciones (dentro de `interaction.md`)
- Accesibilidad (siempre mejorar, nunca degradar)
- Responsive behavior para diferentes tamaños de pantalla
- Patrones móviles más apropiados que los wireframes de las SPECs
- Jerarquía visual dentro de una pantalla
- Reutilización de widgets (crear componentes más granulares si tiene sentido)

### No puede cambiar
- Propósito o alcance de una pantalla
- Reglas de negocio
- Colores de estado (habitaciones, prioridades)
- Paleta de colores principal
- Estilo general (glass sobre fondo oscuro)
- Criterios de aceptación de la TASK
- Arquitectura de capas (Presentation → Domain → Infrastructure)

---

## Cómo estudiar el sistema web

Cuando una TASK involucre lógica de negocio, revisar:

```
/workspace/src/app/core/services/          ← servicios con lógica de negocio
/workspace/src/app/domain/models/          ← modelos de datos
/workspace/src/app/core/repositories/     ← acceso a Firestore
/workspace/src/app/features/private/      ← componentes de UI (referencia funcional)
/workspace/firestore.rules                ← reglas de seguridad
```

### Servicios clave del sistema web

| Servicio | Archivo | Relevancia móvil |
|---|---|---|
| `AuthService` | `auth.service.ts` | ALTA — sesiones, heartbeat, roles |
| `BookingService` | `booking.service.ts` | ALTA — checkIn(), checkOut() |
| `HousekeepingService` | `housekeeping.service.ts` | ALTA — startTask(), completeTask() |
| `RoomStatusService` | `room-status.service.ts` | ALTA — estado `reserved` calculado |
| `GuestAccountService` | `guest-account.service.ts` | ALTA — cargos, totales |
| `FinancialReportsService` | (en features/reports) | MEDIA — cálculos RevPAR, ADR |
| `ProductService` | `product.service.ts` | MEDIA — catálogo para cargos |

### Clasificación de reutilización

| Funcionalidad | Tipo | Notas |
|---|---|---|
| Auth + sesiones | Reutilización directa | Mismas colecciones, adaptar heartbeat |
| Check-in / Check-out | Reutilización directa | Misma lógica, WriteBatch |
| Estado habitaciones | Reutilización directa | `reserved` calculado igual |
| Housekeeping tasks | Reutilización directa | Mismas colecciones y estados |
| Dashboard financiero | Reutilización con adaptación | Mismos cálculos, UI diferente |
| Notificaciones push | Reutilización con adaptación | FCM existente, adaptar a Flutter |
| Agregar cargo | Reutilización con adaptación | Sin caja abierta, solo cargo a cuenta |
| Mapa de habitaciones | No reutilizar | SVG → lista/grid (DECISION-019) |
| POS completo | No reutilizar | Fuera del MVP |

---

## Estructura del proyecto Flutter

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart        ← colores de estado (IDÉNTICOS al sistema web)
│   │   └── app_routes.dart        ← rutas nombradas
│   ├── errors/
│   │   └── app_exception.dart     ← excepciones tipadas
│   └── extensions/
│       └── date_extensions.dart
│
├── domain/
│   ├── models/                    ← modelos Dart equivalentes a los TypeScript del web
│   └── repositories/              ← interfaces de repositorios
│
├── infrastructure/
│   ├── firebase/                  ← implementaciones Firebase
│   └── services/                  ← FCM, conectividad, sesiones
│
├── application/                   ← providers Riverpod
│
├── presentation/
│   ├── auth/
│   ├── shell/
│   ├── dashboard/
│   ├── rooms/
│   ├── front_desk/
│   ├── housekeeping/
│   ├── guest_accounts/
│   ├── notifications/
│   ├── profile/
│   └── shared/
│       ├── widgets/               ← componentes del Design System
│       └── dialogs/
│
├── firebase_options.dart
└── main.dart
```

Ver `docs/architecture/architecture.md` para la especificación completa.

---

## Firebase

- **Project ID**: `lequinthotel-ca6ef`
- **Colecciones**: users, rooms, bookings, guestAccounts, housekeepingTasks, notifications, products, sales
- **Offline**: `persistenceEnabled: true` en la configuración de Firestore
- **FCM**: token guardado en `users/{uid}.fcmToken`

**Compatibilidad obligatoria**: La app móvil no debe cambiar unilateralmente la estructura de Firestore ni las reglas existentes. Si una funcionalidad requiere cambios, debe identificarlos y escalarlo antes de implementarlos. Si una funcionalidad requiere cambios en Firestore, identificarlo explícitamente y escalar.

---

## Operaciones atómicas (WriteBatch obligatorio)

| Operación | Documentos afectados |
|---|---|
| Check-in | guestAccounts (create) + rooms (update) + bookings (update) |
| Check-out | rooms (update) + bookings (update) |
| Completar tarea | housekeepingTasks (update) + rooms (update) + housekeepingTasks (create, si mantenimiento) |
| Agregar cargo | guestAccounts (update) + products (update × N) |

---

## Definition of Done

Una TASK está terminada cuando:

- [ ] El código compila sin errores ni warnings
- [ ] `flutter analyze` pasa sin issues
- [ ] `dart format` aplicado
- [ ] Unit tests para lógica de negocio crítica
- [ ] Widget tests para pantallas críticas
- [ ] Estados de UI relevantes correctamente implementados según la naturaleza de la pantalla. (loading, success, empty, error, offline)
- [ ] Design System respetado (tokens, componentes, glass, fondo oscuro)
- [ ] Criterios de aceptación de la TASK cumplidos
- [ ] Criterios de aceptación de la SPEC cumplidos
- [ ] No hay `print()` en código de producción
- [ ] Errores de negocio muestran mensajes específicos en español
- [ ] Accesibilidad básica (áreas táctiles ≥ 44px, Semantics en íconos interactivos)

---

## Entrega de cada TASK

Al completar una TASK, proporcionar:

```
## Resumen de implementación — TASK-XXX

### Archivos creados/modificados
- lib/path/to/file.dart — descripción

### Tests implementados
- test/path/to/test.dart — qué se testea

### Decisiones tomadas durante implementación
- [decisión] — [justificación]

### Problemas encontrados
- [problema] — [cómo se resolvió]

### Pendientes / TODOs
- [TODO] — [razón]

### Cómo verificar
1. [paso de verificación]
2. [paso de verificación]
```

---

## Manejo de ambigüedades y conflictos

### Si encuentras una ambigüedad
1. Revisar el sistema web para ver cómo está implementado
2. Si el sistema web lo aclara → implementar igual
3. Si sigue siendo ambiguo → documentar la decisión tomada en el resumen de la TASK

### Si existe una contradicción que afecta reglas de negocio, seguridad, arquitectura, datos o criterios de aceptación
1. **Detener la implementación y escalar**
2. Reportar: qué contradice qué, cuál es el impacto
3. Esperar resolución antes de continuar

### Si una funcionalidad requiere cambios en el sistema web
1. Identificarlo explícitamente
2. No implementar el cambio en el sistema web
3. Buscar una alternativa que no requiera modificar el sistema web
4. Si no hay alternativa, reportar y escalar

---

## Idioma

- **UI y strings**: español (igual que el sistema web)
- **Código** (variables, métodos, clases, comentarios técnicos): inglés
- **Mensajes de error al usuario**: español, específicos
- **Documentación técnica**: español

---

## Contexto persistente

Esta documentación en `/docs/` es la fuente de verdad. No depender de memoria de conversaciones anteriores. Al iniciar una nueva sesión:

1. Leer `docs/project/PROJECT_STATUS.md`
2. Identificar la primera TASK con estado PENDING
3. Seguir el protocolo de inicio de TASK descrito arriba
