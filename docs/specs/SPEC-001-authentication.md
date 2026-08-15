# SPEC-001 — Autenticación

**ID**: SPEC-001
**Nombre**: Autenticación (Login, Sesiones, Logout)
**Estado**: READY_FOR_DEVELOPMENT
**Prioridad**: Must Have
**Release**: MVP
**Personas afectadas**: Todos los roles

---

## Objetivo

Permitir que el personal del hotel inicie sesión de forma segura en la app móvil, mantenga su sesión activa durante el turno, y cierre sesión correctamente.

## Contexto

El sistema web ya tiene autenticación con Firebase Auth + control de sesiones concurrentes en Firestore. La app móvil reutiliza exactamente la misma infraestructura, adaptando el heartbeat al ciclo de vida móvil.

## Actores

- Todos los roles: superadmin, admin, manager, receptionist, housekeeper

## Precondiciones

- El usuario debe existir en Firestore (`users/{uid}`)
- El usuario debe estar activo (`active: true`)
- El usuario no debe haber expirado (`activeUntil` no vencido)
- No debe haber alcanzado el límite de sesiones (`activeSessionsCount < maxSessions`)

## Flujo principal — Login

1. Usuario abre la app
2. App verifica si hay sesión activa en Firebase Auth
3. Si no hay sesión → mostrar LoginScreen
4. Usuario ingresa email y contraseña
5. App llama a `FirebaseAuth.signInWithEmailAndPassword()`
6. App obtiene datos del usuario desde `users/{uid}`
7. App verifica: `active == true`
8. App verifica: `activeUntil` no vencido (si existe)
9. App limpia sesiones inactivas (heartbeat > 15 min) dentro de transacción
10. App verifica: `activeSessionsCount < maxSessions` (superadmin sin límite)
11. App crea nueva sesión en `users/{uid}.sessions.{sessionId}`
12. App incrementa `activeSessionsCount`
13. App inicia heartbeat (timer cada 5 min, solo en foreground)
14. App navega a HomeScreen según rol del usuario

## Flujos alternativos

**FA-001 — Sesión activa al abrir la app**
- Si Firebase Auth tiene token válido → verificar usuario en Firestore → navegar directamente a HomeScreen según rol
- Si el token expiró → mostrar LoginScreen

**FA-002 — Superadmin**
- No tiene límite de sesiones (`maxSessions` ignorado)
- Puede tener múltiples sesiones simultáneas

## Excepciones

| Código | Condición | Mensaje al usuario |
|---|---|---|
| AUTH-001 | Credenciales incorrectas | "Correo o contraseña incorrectos" |
| AUTH-002 | Usuario inactivo | "Tu cuenta está inactiva. Contacta al administrador." |
| AUTH-003 | Usuario expirado | "Tu cuenta ha expirado. Contacta al administrador." |
| AUTH-004 | Límite de sesiones | "Límite de sesiones alcanzado. Cierra otra sesión e intenta nuevamente." |
| AUTH-005 | Sin conexión | "Sin conexión. Verifica tu red e intenta nuevamente." |
| AUTH-006 | Error genérico Firebase | "Error al iniciar sesión. Intenta nuevamente." |

## Flujo — Logout

1. Usuario tap en "Cerrar sesión" (desde ProfileScreen)
2. App muestra confirmación: "¿Cerrar sesión?"
3. Usuario confirma
4. App detiene heartbeat
5. App elimina sesión de `users/{uid}.sessions.{sessionId}`
6. App decrementa `activeSessionsCount`
7. App llama a `FirebaseAuth.signOut()`
8. App navega a LoginScreen

## Flujo — Heartbeat (sesión activa)

- Timer cada 5 minutos mientras la app está en **foreground**
- Al ir a **background** (`AppLifecycleState.paused`): pausar timer
- Al volver a **foreground** (`AppLifecycleState.resumed`): reanudar timer + enviar heartbeat inmediato
- Al hacer logout: cancelar timer
- Heartbeat escribe: `users/{uid}.sessions.{sessionId}.lastHeartbeat = serverTimestamp()`

## Reglas de negocio

1. `superadmin` no tiene límite de sesiones
2. Sesiones con `lastHeartbeat` > 15 minutos se consideran inactivas y se limpian en el próximo login
3. El `sessionId` se genera como `${timestamp}_${randomString}`
4. El token FCM se guarda en `users/{uid}.fcmToken` al hacer login exitoso

## Datos

**Input login**: `email: string`, `password: string`

**Estructura sesión en Firestore**:
```
users/{uid}/sessions/{sessionId}: {
  createdAt: Timestamp,
  lastHeartbeat: Timestamp,
  role: UserRole,
  platform: 'mobile'   // nuevo campo para distinguir de sesiones web
}
```

## UI/UX

**LoginScreen**:
- Logo "Le Quint" centrado
- Campo email (teclado email, autocompletado)
- Campo contraseña (oculta, toggle mostrar/ocultar)
- Botón "Iniciar sesión" (deshabilitado mientras loading)
- Loading indicator sobre el botón al procesar
- Mensaje de error debajo del formulario (específico por tipo)
- Sin opción de registro (usuarios creados solo desde sistema web)

**Estados**:
- Idle: formulario vacío
- Loading: botón con spinner, campos deshabilitados
- Error: mensaje de error visible, campos habilitados
- Success: navegación automática

## Permisos

- Pantalla pública (no requiere autenticación previa)
- Todos los roles pueden hacer login

## Criterios de aceptación

- [ ] Login exitoso con credenciales válidas navega al HomeScreen correcto según rol
- [ ] Login con credenciales incorrectas muestra mensaje específico
- [ ] Login con usuario inactivo muestra mensaje específico
- [ ] Login con límite de sesiones alcanzado muestra mensaje específico
- [ ] Al abrir la app con sesión activa, no pide login nuevamente
- [ ] Logout limpia la sesión en Firestore y navega a LoginScreen
- [ ] Heartbeat se pausa cuando la app va a background
- [ ] Heartbeat se reanuda cuando la app vuelve a foreground
- [ ] Token FCM se guarda en Firestore al hacer login exitoso
- [ ] Sin conexión muestra mensaje apropiado

## Consideraciones técnicas

- Usar `flutter_secure_storage` para almacenar el sessionId localmente
- El `sessionId` debe persistir entre reinicios de la app para poder limpiar la sesión correctamente
- Usar `WidgetsBindingObserver` para detectar cambios de ciclo de vida
- Las operaciones de sesión en Firestore deben usar `runTransaction` para atomicidad

## Testing

- Unit: lógica de validación de sesiones, limpieza de sesiones inactivas
- Widget: LoginScreen con credenciales inválidas muestra error, botón deshabilitado durante loading
- Integration: flujo completo login → dashboard → logout

---

## UX / DESIGN REQUIREMENTS

**Design System**: `docs/ux/design-system.md`
**Visual Direction**: `docs/ux/visual-direction.md`
**Tokens**: `docs/ux/design-tokens.md`
**Componentes**: `docs/ux/components.md`
**Referencias**: `docs/design-references/controls.jpg`, `docs/design-references/general.jpg`

### Elementos REQUIRED
- Fondo: gradiente oscuro (`backgroundGradientTop` → `backgroundGradientBottom`)
- Logo "Le Quint": centrado, tipografía premium, sin fondo de card
- Campos email y contraseña: componente `AppTextInput` con fondo glass sutil
- Botón "Iniciar sesión": `PrimaryButton` ancho completo
- Estado loading: spinner en el botón, campos deshabilitados
- Mensaje de error: debajo del formulario, `errorBg` + texto `error`
- Sin opción de registro visible

### Elementos FLEXIBLE
- Posición exacta del logo (centrado vertical o en el tercio superior)
- Animación de entrada de la pantalla
- Decoración adicional del fondo (sutil, no distractiva)
