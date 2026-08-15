# ASSUMPTIONS — Le Quint Mobile App

> Solo se listan suposiciones que siguen siendo suposiciones.
> Todo lo que fue confirmado está en `decisions.md`.

---

## ASSUMPTION-001 — Nombre del hotel
**Enunciado**: El hotel opera con el nombre "Le Quint Hotel" (inferido del proyecto Firebase `lequinthotel-ca6ef` y confirmado por el nombre de la app).
**Estado**: CONFIRMED implícitamente por DECISION-013 (nombre de la app = "Le Quint").

## ASSUMPTION-003 — Firebase como backend único
**Enunciado**: El backend de la app móvil es Firebase (Firestore + Auth), reutilizando las mismas colecciones del sistema web. No se requiere nuevo backend.
**Estado**: CONFIRMED → ver DECISION-017.

## ASSUMPTION-005 — Sistema de sesiones reutilizado
**Enunciado**: La app móvil usa el mismo sistema de autenticación Firebase Auth y el mismo control de sesiones (heartbeat, maxSessions) que el sistema web, adaptando el heartbeat al ciclo de vida móvil (AppLifecycleObserver en lugar de setInterval).
**Estado**: CONFIRMED — implementado en SPEC-001 y TASK-004.

## ASSUMPTION-006 — Rol housekeeper = personal de limpieza/operación
**Enunciado**: El rol `housekeeper` del sistema web corresponde al perfil "Personal de servicios generales / operación" del brief. Incluye personal de limpieza y puede incluir personal de mantenimiento básico.
**Estado**: CONFIRMED implícitamente — las SPECs y TASKs están diseñadas sobre esta base.
