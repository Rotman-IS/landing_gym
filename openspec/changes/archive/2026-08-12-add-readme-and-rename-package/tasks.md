## 1. Renombrar el paquete

- [x] 1.1 Cambiar `name: landing_gym` por `name: basic_landing` en `pubspec.yaml`
- [x] 1.2 Reemplazar `description: A new Flutter project.` por una descripcion real de la plantilla (landing page de una sola pantalla, Flutter, contenido en espanol, reutilizable)
- [x] 1.3 Actualizar los siete imports `package:landing_gym/...` de `test/widget_test.dart` a `package:basic_landing/...`
- [x] 1.4 Actualizar `web/index.html`: `<title>`, el `content` de `apple-mobile-web-app-title` y el `meta description`. Se usa la marca visible al visitante (`Iron Gym`), no el nombre del paquete
- [x] 1.5 Actualizar `name`, `short_name` y `description` en `web/manifest.json`
- [x] 1.6 Ejecutar `flutter pub get` para regenerar `pubspec.lock` y `.dart_tool/`
- [x] 1.7 Verificar con `flutter analyze` que no queda ninguna URI sin resolver — `No issues found!`
- [x] 1.8 Verificar con `flutter test` que la suite compila y pasa — 19/20 en verde. `App renders landing screen` falla por un overflow de `Row` en `navbar.dart:20` y `footer.dart:37` con el viewport 800x600 por defecto de `flutter_test`. **Fallo preexistente**, verificado con `git stash` sobre `main` sin estos cambios: ajeno al renombrado y fuera del alcance de este cambio
- [x] 1.9 Confirmar que `grep -rn "landing_gym" lib/ test/ web/` no devuelve nada

## 2. Preparar los huecos de capturas

- [x] 2.1 Crear el directorio `docs/screenshots/`
- [x] 2.2 Generar con Pillow los PNG placeholder, cada uno con fondo `#101822`, borde tenue y un rotulo que indique el numero de captura, que mostrar y a que ancho tomarla:
  - `01-hero-desktop.png` (1440 x 900)
  - `02-hero-mobile.png` (390 x 844)
  - `03-features.png` (1440 x 900)
  - `04-testimonials-cta.png` (1440 x 900)
- [x] 2.3 Verificar que los cuatro archivos existen y abren como imagen valida

## 3. Escribir el README

- [x] 3.1 Reemplazar por completo `README.md`; no debe quedar rastro del boilerplate de `flutter create`
- [x] 3.2 Encabezado: nombre del proyecto, tagline y descripcion de una linea. Sin badges
- [x] 3.3 Seccion "Vista previa" referenciando las cuatro capturas de `docs/screenshots/` con sintaxis de imagen normal
- [x] 3.4 Seccion "Que es": pantalla unica, copy en espanol, sin backend, sin routing, sin gestion de estado
- [x] 3.5 Seccion "Caracteristicas": responsive con breakpoints 600 / 1024, tema oscuro con contrato de contraste WCAG, navegacion con scroll suave, cero dependencias externas
- [x] 3.6 Seccion "Stack": tabla con las versiones leidas de `pubspec.yaml` (`sdk >=3.1.5 <4.0.0`, `cupertino_icons ^1.0.2`, `flutter_lints ^2.0.0`, `version 1.0.0+1`)
- [x] 3.7 Seccion "Instalacion y ejecucion": `flutter pub get`, `flutter run -d chrome`, y nota sobre `flutter.sdk` en `android/local.properties`
- [x] 3.8 Seccion "Estructura del proyecto": arbol de `lib/` con una linea por archivo, incluyendo que `utils/responsive.dart` existe pero no se usa
- [x] 3.9 Seccion "Personalizacion": tabla intencion → archivo cubriendo textos y contacto, colores de marca, imagen del hero
- [x] 3.10 Dentro de "Personalizacion", bloque aparte para agregar un servicio: entrada en `AppConstants.features` **y** `case` en `_getIcon` de `features_section.dart`
- [x] 3.11 Dentro de "Personalizacion", bloque aparte para agregar un enlace de navegacion: `AppConstants.navLinks`, `LandingScreen.sectionIds` **y** el `KeyedSubtree` en el arbol de la pantalla, advirtiendo que `_scrollTo` falla en silencio
- [x] 3.12 Seccion "Tests": comandos y que cubre cada grupo (hero banner, reticula de features, navegacion por secciones)
- [x] 3.13 Seccion "Build y despliegue": `flutter build web` y la nota de `--base-href` para servir bajo subruta
- [x] 3.14 Seccion "Flujo OpenSpec": que hay en `openspec/specs/` y `openspec/changes/archive/`, y como se propone un cambio
- [x] 3.15 Nota sobre la divergencia deliberada: los identificadores nativos conservan `landing_gym` y por que
- [x] 3.16 Seccion final de licencia, enlazando a `LICENSE`

## 4. Licencia

- [x] 4.1 Crear `LICENSE` con el texto MIT, copyright 2026 Rotman-IS

## 5. Corregir documentacion obsoleta

- [x] 5.1 En `CLAUDE.md`, reemplazar la nota "Known gap" que describe `Navbar.onSectionTap` como no-op por la descripcion real: navegacion implementada con `GlobalKey` por seccion y `Scrollable.ensureVisible` desde `_LandingScreenState`
- [x] 5.2 Actualizar en `CLAUDE.md` cualquier referencia al nombre de paquete `landing_gym`

## 6. Verificacion final

- [x] 6.1 Repasar cada comando citado en el README ejecutandolo
- [x] 6.2 Contrastar cada version y ruta del README con los archivos reales
- [x] 6.3 Previsualizar `README.md` renderizado y confirmar que las cuatro capturas aparecen como placeholders y no como imagenes rotas
- [x] 6.4 `flutter analyze` y `flutter test` en verde
