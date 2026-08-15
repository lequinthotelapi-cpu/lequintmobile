# REFERENCIAS VISUALES — Le Quint Mobile App

> Guía para interpretar y utilizar las referencias visuales durante la implementación.

---

## Archivos de referencia

Ubicación: `docs/design-references/`

| Archivo | Contenido | Uso principal |
|---|---|---|
| `dashboard.jpg` | Dashboard con KPIs sobre fondo oscuro | Estructura de dashboards, jerarquía de KPIs |
| `glass-effect.jpg` | Cards con efecto glassmorphism | Implementación del glass, niveles de blur/opacidad |
| `colors.jpg` | Paleta de colores y gradientes | Referencia de tonos, no copiar valores exactos |
| `controls.jpg` | Inputs, botones, chips, controles | Estilo de controles de formulario |
| `general.jpg` | Vista general de la UI | Composición, spacing, densidad de información |

---

## Cómo usar estas referencias

### Lo que Claude DEBE hacer
1. Leer el Design System (`design-system.md`) y los tokens (`design-tokens.md`) primero
2. Usar las referencias para entender la **intención visual** y el **espíritu del diseño**
3. Aplicar los tokens definidos para implementar ese espíritu
4. Mejorar la composición y el spacing donde sea apropiado para móvil

### Lo que Claude NO debe hacer
- Copiar literalmente los layouts de las referencias (son inspiración, no wireframes)
- Extraer colores exactos de las imágenes (usar los tokens definidos)
- Implementar efectos que perjudiquen el rendimiento o la legibilidad
- Ignorar las referencias y diseñar desde cero sin contexto visual

---

## Interpretación por referencia

### dashboard.jpg — Lecciones clave
- Los KPIs más importantes ocupan el mayor espacio visual
- Los números son grandes y el label es pequeño — jerarquía clara
- Las cards tienen separación entre sí — no están pegadas
- El fondo oscuro hace que los números blancos destaquen naturalmente
- Los accesos rápidos son botones compactos, no cards grandes

**Aplicación en Le Quint**: Los dashboards de manager y superadmin deben tener esta densidad de información. El dashboard del housekeeper es más simple.

### glass-effect.jpg — Lecciones clave
- El glass funciona porque hay un fondo con textura/gradiente detrás
- El blur es moderado — se puede intuir el fondo pero no distraer
- El borde del glass es muy sutil — 1px, no un borde grueso
- El contenido dentro del glass tiene contraste suficiente
- No toda la UI es glass — hay elementos sólidos también

**Aplicación en Le Quint**: Usar glass en cards de información y KPIs. No en listas largas. No en botones primarios.

### colors.jpg — Lecciones clave
- La paleta base es oscura (navy, slate)
- Los acentos son brillantes pero se usan con moderación
- Los colores de estado son saturados y reconocibles
- Los gradientes son sutiles en backgrounds, no en elementos de UI

**Aplicación en Le Quint**: Los tokens de color en `design-tokens.md` ya capturan esta paleta. No desviarse de ellos.

### controls.jpg — Lecciones clave
- Los inputs tienen fondo semitransparente, no blanco
- Los botones primarios son sólidos con color de acento
- Los chips son pequeños y redondeados
- Los controles tienen suficiente padding para ser cómodos en móvil

**Aplicación en Le Quint**: Los componentes en `components.md` implementan estos patrones.

### general.jpg — Lecciones clave
- El spacing es generoso — no abarrotar
- Las secciones se separan por espacio, no por líneas
- La iconografía es de línea fina, moderna
- La densidad de información varía por pantalla

**Aplicación en Le Quint**: Usar `screenPadding: 20px` y `sectionGap: 24px` consistentemente.

---

## Libertad creativa de Claude

Claude puede y debe:
- Mejorar la composición para pantallas móviles específicas
- Adaptar el spacing para diferentes densidades de contenido
- Crear microinteracciones que mejoren la experiencia
- Proponer mejores patrones móviles cuando las referencias sean de desktop
- Mejorar la accesibilidad sin comprometer la estética

Claude no puede:
- Cambiar la paleta de colores principal
- Cambiar el estilo general (glass sobre fondo oscuro)
- Cambiar los colores de estado de habitaciones y prioridades
- Implementar un estilo completamente diferente al definido

---

## Nota sobre las referencias

Las referencias son inspiración visual de alta calidad, no diseños finales de la app.
La app móvil Le Quint debe tener su propia identidad dentro de este estilo,
adaptada específicamente a las necesidades operativas del personal del hotel.
