# OPEN QUESTIONS — Le Quint Mobile App

> Solo se listan preguntas genuinamente pendientes.
> Todas las preguntas respondidas durante la sesión de definición están cerradas y registradas en `decisions.md`.

---

## OQ-012 — Múltiples tokens FCM por usuario
**Pregunta**: ¿Se debe soportar múltiples tokens FCM por usuario para que notificaciones lleguen a todos sus dispositivos simultáneamente?
**Contexto**: El campo `users/{uid}.fcmToken` en Firestore es un solo string. Si el usuario instala la app en dos dispositivos, solo el último en hacer login recibirá notificaciones push.
**Impacto**: Arquitectura de notificaciones. Requiere cambiar `fcmToken: string` a `fcmTokens: string[]` en Firestore.
**Estado**: OPEN — no bloquea el MVP. Para el MVP un solo token es suficiente.

---

## Preguntas cerradas (referencia)

Todas las siguientes fueron respondidas durante la sesión de definición y están registradas en `decisions.md`:

| Pregunta original | Respuesta | Decisión |
|---|---|---|
| Framework de la app | Flutter | DECISION-001 |
| Plataformas objetivo | iOS y Android | DECISION-002 |
| Distribución | App Store y Google Play | DECISION-003 |
| Rol del propietario | Superadmin | DECISION-004 |
| IVA inconsistente | Ignorar en MVP, parametrizar | DECISION-005 |
| Funcionalidad offline | Sí, Firestore nativo | DECISION-006 |
| Notificaciones push | Sí, FCM | DECISION-007 |
| Navegación principal | Bottom nav + menú secundario | DECISION-008 |
| Dashboard por rol | Sí, diferenciados | DECISION-009 |
| Flujo check-in | Con confirmación explícita | DECISION-010 |
| Campos completar tarea | Mismos que sistema web | DECISION-011 |
| Repositorio | Nuevo proyecto Flutter independiente | DECISION-012 |
| Nombre de la app | Le Quint | DECISION-013 |
| Agregar cargo | Desde catálogo de productos | DECISION-014 |
| Período dashboard financiero | Mes actual por defecto | DECISION-015 |
| Habitaciones del housekeeper | Todas | DECISION-016 |
| Mapa de habitaciones | Lista/grid (sin SVG) | DECISION-019 |
| Idioma | Español únicamente | DECISION-018 |
