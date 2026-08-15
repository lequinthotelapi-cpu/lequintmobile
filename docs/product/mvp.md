# MVP — Le Quint Mobile App

**Framework**: Flutter (iOS + Android)

---

## Definición del MVP

El MVP es la versión mínima que entrega valor real a los 4 perfiles de usuario, sin intentar replicar el sistema web completo.

**Principio rector**: Cada funcionalidad incluida debe responder a la pregunta: *"¿Esto es significativamente mejor hacerlo desde el móvil que desde el escritorio?"*

---

## Must Have — Bloque 1: Fundación

Estas funcionalidades son prerequisito para todo lo demás.

| ID | Funcionalidad | Rol | Justificación |
|---|---|---|---|
| F-018 | Autenticación (login/logout) | Todos | Sin esto no hay app |
| F-011 | Notificaciones push (FCM) | Todos | Diferenciador clave del móvil |
| F-012 | Ver notificaciones | Todos | Complemento de F-011 |

---

## Must Have — Bloque 2: Housekeeper

El caso de uso más claro y de mayor impacto operacional inmediato.

| ID | Funcionalidad | Rol | Justificación |
|---|---|---|---|
| F-008 | Ver mis tareas asignadas | Housekeeper | Elimina fricción de ir al escritorio |
| F-010 | Iniciar tarea | Housekeeper | Parte del flujo de trabajo |
| F-009 | Completar tarea | Housekeeper | Reportar en tiempo real desde la habitación |

**Impacto**: El housekeeper puede gestionar su turno completo desde el móvil sin acercarse a un escritorio.

---

## Must Have — Bloque 3: Recepción

Operaciones core del recepcionista que pueden ocurrir lejos del escritorio.

| ID | Funcionalidad | Rol | Justificación |
|---|---|---|---|
| F-001 | Dashboard operacional | Receptionist | Primera pantalla al iniciar turno |
| F-003 | Ver llegadas del día | Receptionist | Consulta frecuente |
| F-004 | Ejecutar check-in | Receptionist | Operación core |
| F-005 | Ver salidas del día | Receptionist | Consulta frecuente |
| F-006 | Ejecutar check-out | Receptionist | Operación core |
| F-007 | Ver estado de habitaciones | Receptionist | Consulta frecuente |

---

## Must Have — Bloque 4: Gerencia y Propietario

Visibilidad estratégica desde cualquier lugar.

| ID | Funcionalidad | Rol | Justificación |
|---|---|---|---|
| F-001 | Dashboard operacional | Manager, Superadmin | Estado del hotel en tiempo real |
| F-002 | Dashboard financiero / KPIs | Manager, Superadmin | Visibilidad financiera sin laptop |
| F-007 | Ver estado de habitaciones | Manager | Supervisión operacional |

---

## Should Have — Bloque 5: Valor adicional

Agregan valor significativo sin complejidad excesiva.

| ID | Funcionalidad | Rol | Justificación |
|---|---|---|---|
| F-013 | Consultar cuenta de huésped | Receptionist, Manager | Consulta rápida de saldo |
| F-014 | Agregar cargo a habitación | Receptionist | Cargo rápido sin POS completo |
| F-015 | Supervisar tareas (manager) | Manager | Visibilidad del equipo de limpieza |
| F-016 | Huéspedes en casa | Receptionist, Manager | Quién está en el hotel ahora |
| F-017 | Buscar huésped | Receptionist | Búsqueda rápida |

---

## Could Have — Bloque 6: Extensiones

Útiles pero no críticos para el MVP.

| ID | Funcionalidad | Rol | Justificación |
|---|---|---|---|
| F-020 | Ver lista de reservas | Receptionist, Manager | Consulta histórica |
| F-021 | Confirmar/cancelar reserva | Receptionist | Acción simple |
| F-022 | Asignar tarea | Manager | Gestión de equipo |
| F-023 | Crear tarea | Manager | Gestión operacional |

---

## Won't Have — Excluido del MVP

Ver `scope.md` para justificaciones detalladas.

---

## Estimación de Complejidad por Bloque

| Bloque | Funcionalidades | Complejidad estimada |
|---|---|---|
| Fundación (auth + notificaciones) | 3 | Alta (FCM, sesiones, seguridad) |
| Housekeeper | 3 | Media |
| Recepción | 6 | Media-Alta (check-in/out con lógica de negocio) |
| Gerencia/Propietario | 3 | Media (cálculos financieros) |
| Should Have | 5 | Media |
| Could Have | 4 | Baja-Media |

---

## Criterio de Éxito del MVP

El MVP es exitoso si:

1. Un housekeeper puede gestionar su turno completo (ver tareas, iniciar, completar) sin acercarse a un escritorio.
2. Un recepcionista puede ejecutar check-in y check-out desde el móvil.
3. Un gerente puede ver el estado del hotel y los KPIs financieros del día desde cualquier lugar.
4. Las notificaciones push llegan en tiempo real a los dispositivos.
5. La app funciona en iOS y Android.
6. La app es segura: autenticación, sesiones, permisos por rol.
