# DECISIONES — Le Quint Mobile App

> Registro completo de decisiones confirmadas durante la sesión de definición.
> Todas las decisiones aquí listadas son DEFINITIVAS salvo indicación explícita.

---

## DECISION-001 — Framework: Flutter
**Estado**: CONFIRMED
**Decisión**: La app móvil se construirá con Flutter.
**Justificación**: Una base de código para iOS y Android. Rendimiento nativo. UI altamente personalizable. Firebase bien soportado (FlutterFire). Cumple el requisito de sentirse diseñada específicamente para móvil.
**Consecuencias**:
- Lenguaje: Dart
- No se reutiliza código Angular del sistema web
- Se reutilizan modelos de datos, reglas de negocio y colecciones Firestore
- Requiere FlutterFire (firebase_core, cloud_firestore, firebase_auth, firebase_messaging)

---

## DECISION-002 — Plataformas: iOS y Android
**Estado**: CONFIRMED
**Decisión**: La app debe funcionar en iOS y Android.
**Consecuencias**:
- Flutter cubre ambas plataformas con una base de código
- Requiere Apple Developer Account para distribución iOS
- Requiere Google Play Console para distribución Android

---

## DECISION-003 — Distribución: App Store y Google Play
**Estado**: CONFIRMED
**Decisión**: La app se distribuirá por App Store (iOS) y Google Play (Android).

---

## DECISION-004 — Rol Propietario: mapear a Superadmin
**Estado**: CONFIRMED
**Decisión**: El perfil "Propietario" corresponde al rol `superadmin` en el sistema existente. No se crea un nuevo rol.
**Consecuencias**:
- La persona "Propietario" usa el rol `superadmin`
- Si en el futuro se necesita separar propietario de superadmin técnico, se puede crear el rol `owner`

---

## DECISION-005 — IVA: parametrizado, ignorar en MVP
**Estado**: CONFIRMED
**Decisión**: El IVA debe estar parametrizado en la sección de parámetros del sistema. Para el MVP móvil no se implementan funcionalidades que requieran cálculo de IVA en el cliente. La inconsistencia 13%/19% del sistema web se ignora hasta que se resuelva allí.
**Consecuencias**:
- La app móvil no calcula IVA en el MVP
- En check-in, la guestAccount se crea con IVA = 0 y un TODO comentado en el código

---

## DECISION-006 — Offline: soporte parcial con Firestore nativo
**Estado**: CONFIRMED
**Decisión**: La app soporta modo offline mediante la persistencia nativa de Firestore. La mayoría de funcionalidades son de consulta. Las escrituras offline se encolan y sincronizan automáticamente al reconectar.
**Consecuencias**:
- `persistenceEnabled: true` en la configuración de Firestore
- No se requiere lógica de sincronización manual para el MVP
- Banner informativo cuando no hay conexión

---

## DECISION-007 — Notificaciones push: Firebase Cloud Messaging
**Estado**: CONFIRMED
**Decisión**: La app móvil recibirá notificaciones push usando FCM, reutilizando la infraestructura existente del sistema web.
**Consecuencias**:
- Requiere `firebase_messaging` en Flutter
- Requiere configuración de APNs para iOS
- La app registra su token FCM en `users/{uid}.fcmToken` al hacer login

---

## DECISION-008 — Navegación: Bottom nav + menú secundario
**Estado**: CONFIRMED
**Decisión**: Navegación principal con bottom navigation bar diferenciada por rol (4-5 ítems). Secciones adicionales accesibles desde un ítem "Más" que abre un bottom sheet.

---

## DECISION-009 — Dashboards diferenciados por rol
**Estado**: CONFIRMED
**Decisión**: Cada rol tiene su propio dashboard adaptado a sus responsabilidades.
- **Superadmin/Admin**: KPIs operacionales + financieros + estado habitaciones + tareas
- **Manager**: KPIs operacionales + financieros + estado habitaciones + supervisión tareas
- **Receptionist**: Llegadas/salidas del día + estado habitaciones + cuentas abiertas
- **Housekeeper**: Solo sus tareas asignadas del día

---

## DECISION-010 — Check-in/Check-out con confirmación explícita
**Estado**: CONFIRMED
**Decisión**: El flujo de check-in y check-out incluye una pantalla/modal de confirmación antes de ejecutar la acción. No se permite acción directa sin confirmación.
**Flujo**: Lista → Tap en reserva → Detalle → Botón acción → Dialog de confirmación → Ejecutar.

---

## DECISION-011 — Completar tarea: mismos campos que sistema web
**Estado**: CONFIRMED
**Decisión**: El formulario de completar tarea mantiene los mismos campos que el sistema web: duración real (minutos, requerido), notas de completación (opcional), checkbox "¿requiere mantenimiento?" + notas de mantenimiento si aplica.

---

## DECISION-012 — Proyecto Flutter: repositorio nuevo independiente
**Estado**: CONFIRMED
**Decisión**: La app móvil Flutter se desarrollará en un repositorio/carpeta nuevo, completamente independiente del proyecto Angular existente. La documentación en `/workspace/docs/` se migrará a ese nuevo proyecto cuando esté creado.
**Consecuencias**:
- TASK-001 incluye `flutter create` y la estructura inicial completa
- Las rutas en las TASKs son relativas al proyecto Flutter, no al workspace Angular
- El mismo proyecto Firebase (`lequinthotel-ca6ef`) es compartido por ambos proyectos

---

## DECISION-013 — Nombre de la app: Le Quint
**Estado**: CONFIRMED
**Decisión**: El nombre de la aplicación móvil es **Le Quint**.

---

## DECISION-014 — Agregar cargo: desde catálogo de productos
**Estado**: CONFIRMED
**Decisión**: El flujo de agregar cargo a habitación en móvil es similar al POS web: seleccionar productos del catálogo, agregar a carrito simple, confirmar cargo a la cuenta del huésped. No requiere caja abierta (solo cargo a habitación, no venta directa).

---

## DECISION-015 — Dashboard financiero: período por defecto = mes actual
**Estado**: CONFIRMED
**Decisión**: El dashboard financiero abre mostrando el mes actual por defecto, igual que el sistema web.

---

## DECISION-016 — Housekeeper ve todas las habitaciones
**Estado**: CONFIRMED
**Decisión**: En la pantalla de habitaciones, el housekeeper ve todas las habitaciones del hotel (no solo las asignadas), para orientarse espacialmente.

---

## DECISION-017 — Backend: Firebase reutilizado directamente
**Estado**: CONFIRMED
**Decisión**: La app móvil accede directamente a Firestore con el mismo usuario Firebase Auth. No se crea una API REST intermedia. Las Firestore Rules existentes aplican automáticamente.

---

## DECISION-018 — Idioma: español únicamente
**Estado**: CONFIRMED
**Decisión**: La app móvil está en español únicamente, igual que el sistema web. No se implementa soporte multiidioma en el MVP.

---

## DECISION-019 — Mapa de habitaciones: lista/grid (no SVG)
**Estado**: CONFIRMED
**Decisión**: La vista de habitaciones en móvil es lista/grid con colores de estado. El mapa SVG interactivo del sistema web no se porta a móvil.
