# lequintmobile

Aplicación Flutter del proyecto Lequint.

Requisitos
- Flutter SDK instalado (stable channel)
- `git` instalado

Pasos recomendados (ejecuta estos comandos en la carpeta del proyecto)

1. Inicializar el repositorio (si no está hecho):

```bash
git init
```

2. Configurar `git` SOLO para este repositorio (no tocar la configuración global):

```bash
# Desde dentro de la carpeta del repo:
git config --local user.name "Tu Nombre"
git config --local user.email "tu-email@example.com"

# Ver la configuración local:
git config --list --local
```

3. Añadir y commitear los archivos (incluye `.gitignore` que ya está creado):

```bash
git add .
git commit -m "Initial commit"
```

4. Crear el repositorio remoto en GitHub (web o `gh` CLI) y añadir el `origin`:

```bash
# ejemplo SSH
git remote add origin git@github.com:TU_USUARIO/lequintmobile.git

# ejemplo HTTPS
git remote add origin https://github.com/TU_USUARIO/lequintmobile.git
```

5. Subir la rama `main`:

```bash
git branch -M main
git push -u origin main
```

Buenas prácticas
- No subir credenciales ni archivos con secretos. Usa GitHub Secrets o variables de entorno para CI.
- Protege la rama `main` desde la configuración del repo en GitHub si lo deseas.

Contacto
- Autor: Tu Nombre
# lequintmobile

Proyecto Flutter "lequintmobile".

Descripción breve, cómo ejecutar:

- Requisitos: Flutter SDK, Android/iOS toolchains
- Ejecutar: `flutter pub get` y `flutter run`

Contribuciones: abrir issues o pull requests.
# lequintmobile

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
