# SCOPE — Le Quint Mobile App

---

## IN SCOPE — MVP

Funcionalidades que estarán en el release inicial.

### Autenticación
- Login con email y contraseña (Firebase Auth)
- Control de sesiones (heartbeat adaptado a ciclo de vida móvil)
- Logout
- Protección de rutas por rol

### Dashboard Operacional (todos los roles)
- Llegadas hoy, salidas hoy
- Habitaciones por estado (ocupadas, disponibles, sucias, en limpieza, mantenimiento)
- Cuentas abiertas
- Accesos rápidos a funciones principales

### Dashboard Financiero (Manager, Superadmin)
- Ingresos del período
- Tasa de ocupación
- RevPAR, ADR
- Por cobrar (cuentas abiertas)
- Filtros: hoy, semana, mes

### Front Desk — Recepción (Receptionist)
- Ver llegadas del día
- Ejecutar check-in
- Ver salidas del día
- Ejecutar check-out
- Ver huéspedes en casa

### Habitaciones (Receptionist, Manager, Housekeeper)
- Vista de todas las habitaciones con estado actual
- Filtro por estado
- Detalle de habitación

### Housekeeping — Vista Housekeeper
- Ver mis tareas asignadas
- Iniciar tarea
- Completar tarea (duración, notas, ¿requiere mantenimiento?)
- Recibir notificación push al asignarme una tarea

### Housekeeping — Vista Manager/Admin
- Ver todas las tareas del día
- Estado por empleado
- Tareas urgentes y vencidas

### Cuentas de Huéspedes (Receptionist, Manager)
- Consultar cuenta de huésped (solo lectura)
- Ver cargos y pagos
- Ver saldo pendiente
- Agregar cargo simple a habitación

### Notificaciones
- Recibir notificaciones push (FCM)
- Ver lista de notificaciones
- Marcar como leída

### Perfil
- Ver datos del usuario
- Cerrar sesión

---

## OUT OF SCOPE — MVP

Funcionalidades deliberadamente excluidas del release inicial.

### Excluidas por complejidad en móvil
- POS completo (venta directa con caja)
- Caja registradora (abrir/cerrar, transacciones)
- Generación de facturas y PDF
- Calendario de reservas
- Mapa SVG de habitaciones

### Excluidas por ser administración pura
- Gestión de usuarios
- Gestión de parámetros del sistema
- Gestión de permisos por rol
- Gestión de empleados

### Excluidas por baja frecuencia en móvil
- Gestión de productos e inventario
- Movimientos de inventario
- Gastos operativos
- Historial de transacciones de caja
- Reportes detallados de inventario

### Excluidas por decisión de alcance
- Crear reservas (formulario complejo, mejor en escritorio)
- Agregar pagos a cuentas (operación financiera sensible, MVP)
- Crear/editar huéspedes (mejor en escritorio)

---

## FUTURE — Releases Posteriores

### Release 2 — Operaciones extendidas
- Crear reservas desde móvil
- Confirmar/cancelar reservas
- Agregar pagos a cuentas de huéspedes
- Crear y asignar tareas de housekeeping
- Calendario de reservas simplificado

### Release 3 — Finanzas extendidas
- POS simplificado (solo carga a habitación con catálogo)
- Consulta de caja (solo lectura)
- Reportes exportables

### Release 4 — Huéspedes (FUTURE — fuera del alcance actual)
- Acceso del huésped a la app
- Ver información de su estadía
- Solicitar servicios
- Comunicación con recepción
- Check-in online

---

## DECISIONES DE ALCANCE

| Decisión | Justificación |
|---|---|
| No POS completo en MVP | Requiere caja abierta, manejo de efectivo, impresora. Operación de escritorio. |
| No crear reservas en MVP | Formulario de 5+ pasos con búsqueda de disponibilidad. Mejor en escritorio. |
| No facturación en MVP | PDF e impresión son operaciones de escritorio. |
| No administración en MVP | Sin valor diferencial en móvil. |
| Sí check-in/check-out | Operación core que puede ocurrir lejos del escritorio. |
| Sí housekeeping completo | Caso de uso más claro: el housekeeper nunca está en un escritorio. |
| Sí dashboard financiero | Gerente y propietario necesitan KPIs desde cualquier lugar. |
