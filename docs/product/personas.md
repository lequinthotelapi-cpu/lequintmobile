# PERSONAS — Le Quint Mobile App

**Basado en**: Análisis del sistema web existente + roles confirmados

---

## PERSONA 1 — Recepcionista

**Rol en sistema**: `receptionist`
**Nombre representativo**: Carlos (Recepcionista de turno)

### Contexto
Trabaja en el mostrador de recepción. Tiene acceso a una computadora de escritorio, pero frecuentemente necesita moverse: acompañar huéspedes, verificar habitaciones, atender llamadas. Su turno empieza con una revisión de llegadas y salidas del día.

### Responsabilidades principales
- Recibir y registrar llegadas (check-in)
- Gestionar salidas (check-out)
- Verificar estado de reservas
- Atender solicitudes de huéspedes en casa
- Registrar ventas de productos (POS)
- Gestionar cuentas de huéspedes

### Tareas frecuentes (diarias)
1. Revisar llegadas del día al inicio del turno
2. Ejecutar check-in cuando llega un huésped
3. Revisar salidas del día
4. Ejecutar check-out cuando sale un huésped
5. Verificar estado de habitaciones
6. Consultar cuenta de un huésped en casa
7. Registrar un cargo a una habitación (consumo de minibar, servicio, etc.)
8. Buscar información de un huésped

### Situaciones urgentes
- Huésped llega y no encuentra su reserva
- Huésped quiere hacer check-out pero tiene saldo pendiente
- Habitación asignada no está lista (sucia o en mantenimiento)
- Solicitud de cargo urgente a habitación

### Qué necesita en móvil
- Ver llegadas del día de un vistazo
- Ejecutar check-in rápido
- Ver salidas del día
- Ejecutar check-out
- Ver estado actual de habitaciones
- Consultar cuenta de huésped (saldo, cargos)
- Agregar cargo simple a habitación
- Buscar huésped por nombre o número de habitación
- Recibir notificaciones push de eventos importantes

### Qué NO necesita en móvil
- Crear reservas complejas (mejor en escritorio)
- Gestionar facturas y PDFs
- Administrar usuarios o parámetros
- Ver reportes financieros detallados

---

## PERSONA 2 — Housekeeper (Personal de Limpieza/Operación)

**Rol en sistema**: `housekeeper`
**Nombre representativo**: María (Camarera de pisos)

### Contexto
Se desplaza físicamente por todo el hotel durante su turno. Nunca está frente a una computadora mientras trabaja. Actualmente tiene que ir a recepción o a una computadora para ver sus tareas asignadas o reportar que terminó una habitación. Esto genera fricción operacional significativa.

### Responsabilidades principales
- Limpiar habitaciones asignadas
- Reportar estado de habitaciones
- Reportar problemas o daños encontrados
- Completar tareas de mantenimiento básico

### Tareas frecuentes (diarias)
1. Ver qué habitaciones tiene asignadas hoy
2. Ver el tipo y prioridad de cada tarea
3. Marcar una tarea como iniciada
4. Marcar una tarea como completada
5. Reportar si encontró un problema que requiere mantenimiento
6. Ver el estado actual de sus tareas (cuántas pendientes, cuántas completadas)

### Situaciones urgentes
- Habitación marcada como urgente (huésped llegando pronto)
- Encontró daño o problema en habitación
- Tarea reasignada de último momento

### Qué necesita en móvil
- Ver SOLO sus tareas asignadas (no las de todos)
- Ver prioridad y tipo de cada tarea claramente
- Iniciar una tarea con un tap
- Completar una tarea con un tap (duración, notas, ¿requiere mantenimiento?)
- Recibir notificación push cuando le asignan una nueva tarea
- Ver en qué habitación está cada tarea (número, piso)

### Qué NO necesita en móvil
- Ver tareas de otros empleados
- Crear tareas
- Asignar tareas
- Ver reportes financieros
- Gestionar reservas o huéspedes

### Nota importante
Esta persona es la que más se beneficia de la app móvil. Su flujo de trabajo actual depende de ir físicamente a un escritorio. La app móvil elimina esa fricción completamente.

---

## PERSONA 3 — Gerente

**Rol en sistema**: `manager`
**Nombre representativo**: Roberto (Gerente de operaciones)

### Contexto
Supervisa la operación del hotel. Tiene acceso al sistema web en su oficina, pero frecuentemente está en reuniones, recorriendo el hotel o fuera de la propiedad. Necesita visibilidad del estado operacional y financiero en tiempo real desde cualquier lugar.

### Responsabilidades principales
- Supervisar operación diaria
- Monitorear indicadores financieros
- Gestionar incidencias
- Aprobar operaciones importantes
- Supervisar equipo de trabajo

### Tareas frecuentes
1. Revisar KPIs del día (ocupación, ingresos, llegadas/salidas)
2. Ver estado general de habitaciones
3. Revisar reportes financieros del período
4. Verificar estado de cuentas abiertas (por cobrar)
5. Supervisar tareas de housekeeping
6. Revisar reservas del día y próximos días

### Situaciones urgentes
- Ocupación inusualmente baja o alta
- Cuenta con saldo elevado sin pagar
- Problema operacional reportado

### Qué necesita en móvil
- Dashboard con KPIs operacionales del día
- Reportes financieros básicos (ingresos, ocupación, RevPAR)
- Estado de habitaciones (resumen)
- Estado de cuentas abiertas (por cobrar)
- Notificaciones de eventos importantes
- Vista de reservas del día y próximos días

### Qué NO necesita en móvil
- Ejecutar check-in/check-out (no es su tarea operativa)
- Gestionar tareas de housekeeping directamente
- Administrar usuarios o parámetros del sistema

---

## PERSONA 4 — Propietario / Superadmin

**Rol en sistema**: `superadmin`
**Nombre representativo**: Ana (Propietaria del hotel)

### Contexto
Puede estar en el hotel o fuera de él. No opera el sistema diariamente, pero quiere visibilidad estratégica en cualquier momento. Le interesa la salud financiera del negocio, la ocupación y el desempeño general. No necesita ejecutar operaciones del día a día.

### Responsabilidades principales
- Visión estratégica del negocio
- Monitoreo de indicadores clave
- Toma de decisiones basada en datos

### Tareas frecuentes
1. Ver ocupación actual y del período
2. Ver ingresos del período (día, semana, mes)
3. Ver KPIs financieros (RevPAR, ADR)
4. Ver estado general del hotel de un vistazo
5. Recibir alertas de situaciones críticas

### Qué necesita en móvil
- Dashboard ejecutivo con KPIs clave
- Reportes financieros con filtros de período
- Ocupación en tiempo real
- Alertas críticas (notificaciones push)
- Vista de alto nivel, no operacional

### Qué NO necesita en móvil
- Operaciones del día a día (check-in, check-out, tareas)
- Gestión de usuarios o parámetros desde móvil
- Detalle de cuentas individuales

---

## RESUMEN DE NECESIDADES POR PERSONA

| Funcionalidad | Recepcionista | Housekeeper | Gerente | Propietario |
|---|:---:|:---:|:---:|:---:|
| Dashboard KPIs operacionales | ✓ | — | ✓ | ✓ |
| Dashboard financiero / reportes | — | — | ✓ | ✓ |
| Llegadas del día | ✓ | — | ✓ | — |
| Salidas del día | ✓ | — | ✓ | — |
| Check-in | ✓ | — | — | — |
| Check-out | ✓ | — | — | — |
| Estado de habitaciones | ✓ | — | ✓ | — |
| Mis tareas asignadas | — | ✓ | — | — |
| Completar tarea | — | ✓ | — | — |
| Supervisar todas las tareas | — | — | ✓ | — |
| Cuenta de huésped (consulta) | ✓ | — | ✓ | — |
| Agregar cargo a habitación | ✓ | — | — | — |
| Buscar huésped | ✓ | — | — | — |
| Notificaciones push | ✓ | ✓ | ✓ | ✓ |
| Perfil / cerrar sesión | ✓ | ✓ | ✓ | ✓ |
