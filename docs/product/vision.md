# VISIÓN DEL PRODUCTO — Le Quint Mobile App

---

## Problema que resuelve

El personal del hotel opera con un sistema web diseñado para escritorio. Esto crea fricción operacional en tres escenarios concretos:

1. **El housekeeper** se desplaza físicamente por el hotel durante todo su turno. Para ver sus tareas asignadas o reportar que terminó una habitación, debe ir a un escritorio. Esto interrumpe su flujo de trabajo y genera retrasos en la actualización del estado de habitaciones.

2. **El recepcionista** a veces necesita ejecutar un check-in o check-out lejos de su escritorio (acompañando a un huésped, verificando una habitación). Hoy no puede hacerlo.

3. **El gerente y el propietario** quieren visibilidad del estado del hotel y los indicadores financieros desde cualquier lugar, sin necesidad de abrir una laptop.

---

## Solución

Una aplicación móvil nativa (Flutter, iOS y Android) complementaria al sistema web existente, diseñada específicamente para las necesidades operacionales del personal del hotel en movimiento.

**No es una copia del sistema web en pantalla pequeña.**

Es una selección intencional de las funcionalidades que tienen mayor valor cuando el usuario está en movimiento.

---

## Usuarios objetivo (MVP)

| Rol | Beneficio principal |
|---|---|
| Housekeeper | Gestionar su turno completo sin acercarse a un escritorio |
| Recepcionista | Ejecutar check-in/check-out y consultar información desde cualquier lugar |
| Gerente | Ver KPIs operacionales y financieros en tiempo real |
| Propietario (superadmin) | Visibilidad estratégica del negocio desde cualquier lugar |

---

## Principios de diseño

- **Móvil primero**: Cada pantalla está diseñada para pantalla pequeña y uso con una mano.
- **Acciones rápidas**: Las operaciones más frecuentes requieren el mínimo de pasos.
- **Confirmación en acciones críticas**: Check-in, check-out y completar tarea requieren confirmación explícita.
- **Feedback inmediato**: El usuario siempre sabe qué está pasando (loading, éxito, error).
- **Offline tolerante**: La app funciona con conectividad limitada y sincroniza al reconectar.

---

## Lo que NO es esta app (MVP)

- No reemplaza el sistema web
- No tiene POS completo
- No genera facturas ni PDFs
- No administra usuarios, parámetros ni permisos
- No tiene funcionalidades para huéspedes (release futuro)
