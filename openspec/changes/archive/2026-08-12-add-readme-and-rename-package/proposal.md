## Why

El proyecto se presenta con la identidad por defecto que genero `flutter create`: el paquete se llama `landing_gym` y su `description` sigue siendo *"A new Flutter project."*, mientras el `README.md` es todavia el boilerplate de Flutter, sin una sola linea sobre que es esto ni como usarlo. Quien abre el repo hoy no puede responder que hace, como correrlo ni como adaptarlo a otra marca.

Ademas, el nombre `landing_gym` describe el *contenido de ejemplo* (un gimnasio) y no lo que el proyecto realmente es: una plantilla de landing estatica reutilizable. Renombrarla a `basic_landing` alinea la identidad del paquete con su proposito y hace obvio que el gimnasio es solo el contenido de demostracion.

## What Changes

- **BREAKING** El nombre del paquete Dart pasa de `landing_gym` a `basic_landing`. Todo import `package:landing_gym/...` deja de resolver y debe actualizarse.
- `pubspec.yaml` recibe una `description` real que describe la plantilla en vez del texto por defecto.
- Los identificadores visibles al usuario en la build web (`web/index.html` `<title>` y `apple-mobile-web-app-title`, `web/manifest.json` `name`/`short_name`) pasan a reflejar la nueva identidad.
- El `README.md` boilerplate se reemplaza por documentacion completa del proyecto en espanol: que es, stack real, instalacion, estructura, guia de personalizacion, tests, build y deploy, y el flujo OpenSpec.
- Se introduce `docs/screenshots/` como ubicacion convenida para las capturas, con referencias declaradas en el README para que el autor las agregue despues sin tocar la estructura del documento.
- Se corrige la afirmacion obsoleta de `CLAUDE.md` que describe `Navbar.onSectionTap` como un no-op; la navegacion por secciones ya esta implementada.

## Capabilities

### New Capabilities
- `project-documentation`: que debe contener el README para que un tercero pueda correr, entender y re-marcar la landing, incluyendo la convencion de capturas y la regla de que la documentacion refleje el codigo real.
- `package-identity`: cual es el nombre y la descripcion canonicos del paquete, y en que archivos esa identidad debe mantenerse consistente.

### Modified Capabilities
<!-- Ninguna. Las specs existentes (design-tokens, features-section-layout, hero-banner,
     navbar-section-navigation) describen comportamiento de UI que este cambio no altera. -->

## Impact

- `pubspec.yaml` — `name` y `description`.
- `test/widget_test.dart` — siete imports `package:landing_gym/...`.
- `web/index.html`, `web/manifest.json` — cadenas visibles al usuario.
- `README.md` — reescritura completa.
- `docs/screenshots/` — directorio nuevo, inicialmente con placeholders.
- `LICENSE` — archivo nuevo, MIT.
- `CLAUDE.md` — correccion de la seccion "Known gap".
- Regenerados por el toolchain, no editados a mano: `.dart_tool/`, `pubspec.lock`, `landing_gym.iml`.

**Fuera de alcance:** los identificadores nativos (`com.example.landing_gym` en Android y macOS, el directorio Kotlin `android/app/src/main/kotlin/com/example/landing_gym/`, `PRODUCT_NAME` de macOS, `BINARY_NAME` de Linux/Windows, el `pbxproj` de macOS). Cambiarlos exige mover archivos y editar proyectos Xcode/Gradle, con riesgo real de romper builds nativas, a cambio de cero beneficio para una landing cuyo destino es web. Quedan como deuda documentada.
