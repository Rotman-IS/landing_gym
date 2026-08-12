## Context

El repositorio conserva la identidad y la documentacion que genero `flutter create`: `name: landing_gym`, `description: A new Flutter project.` y un `README.md` de doce lineas que enlaza al codelab de Flutter. El codigo, en cambio, esta cuidado —paleta con contrato WCAG explicito, cuatro capabilities especificadas en `openspec/specs/`, suite de tests con tres grupos— y esa distancia entre lo que el proyecto es y lo que aparenta al abrirlo es justamente lo que este cambio cierra.

Dos restricciones condicionan el diseno:

1. **El renombrado del paquete no es simetrico.** Cambiar `name` en `pubspec.yaml` rompe unicamente los imports `package:landing_gym/...`, y esos viven solo en `test/widget_test.dart` (siete lineas): los widgets de `lib/` se importan entre si con rutas relativas. En cambio, los identificadores nativos (`com.example.landing_gym` en Android y macOS, el directorio del paquete Kotlin, el `pbxproj` de macOS, los `BINARY_NAME` de Linux y Windows) exigirian mover archivos y editar proyectos Xcode y Gradle.

2. **Las capturas no existen todavia.** El autor las tomara despues. El README tiene que quedar completo y presentable hoy, sin iconos de imagen rota, y absorber las capturas manana sin que nadie tenga que reabrir el documento a reorganizar secciones.

## Goals / Non-Goals

**Goals:**

- Que el paquete se llame `basic_landing` y su descripcion diga que es, con la suite de tests compilando tras el cambio.
- Que `README.md` deje a un tercero correr, entender y re-marcar la landing sin abrir codigo fuente.
- Que la guia de personalizacion documente **todos** los puntos de edicion de cada tarea, incluidos los dos casos que requieren tocar varios archivos.
- Que las capturas tengan un lugar y un nombre definidos de antemano, y que anadirlas sea copiar archivos.
- Que ninguna afirmacion de la documentacion contradiga el codigo, lo que incluye corregir la nota obsoleta de `CLAUDE.md`.

**Non-Goals:**

- Renombrar identificadores nativos de Android, iOS, macOS, Linux o Windows.
- Cambiar el contenido de la landing: `Iron Gym` sigue siendo el copy de demostracion. Se renombra el paquete, no la marca ficticia.
- Tomar las capturas. Este cambio prepara los huecos; el autor pone las imagenes.
- Publicar el sitio o configurar CI/CD. El README documenta como hacer el build; no se automatiza nada.
- Adoptar el helper `Responsive`, hoy sin uso. El README lo describe tal como esta.

## Decisions

### Renombrar solo la identidad Dart y la visible en web

`pubspec.yaml`, los imports de `test/`, `web/index.html` y `web/manifest.json`. Nada mas.

*Alternativa considerada:* renombrado total, incluido `com.example.basic_landing` y el directorio Kotlin. Se descarta porque implica `git mv` de la carpeta del paquete Kotlin, editar `build.gradle`, `AppInfo.xcconfig` y tres referencias en el `pbxproj` de macOS, cuyo resultado no puede verificarse sin ejecutar builds nativas que este proyecto —una landing web— nunca correra. El riesgo de dejar builds rotas sin que nadie lo note supera el beneficio de una consistencia que solo se aprecia leyendo `grep`.

*Alternativa considerada:* `flutter create --project-name basic_landing .` para regenerar el andamiaje. Se descarta porque sobrescribiria `web/index.html` y los proyectos nativos, perdiendo cualquier ajuste hecho a mano.

La divergencia resultante se documenta en el README para que un lector futuro no la lea como un renombrado a medias.

### El renombrado va antes que el README

El README cita el nombre del paquete y el comando `flutter run`. Escribirlo primero significa escribirlo con el nombre viejo y volver a editarlo. Se renombra, se verifica con `flutter analyze` y `flutter test`, y recien entonces se documenta lo que quedo.

### Placeholders como archivos PNG reales, no como comentarios

El README referencia `docs/screenshots/01-hero-desktop.png` con sintaxis de imagen normal, y ese archivo **existe desde el primer commit**: es un PNG generado, del tamano exacto de la captura esperada, con fondo en la superficie oscura de la paleta y un rotulo que dice que va ahi y a que ancho tomarlo.

Anadir una captura real es entonces sobrescribir el archivo. Cero ediciones al README, cero riesgo de que el orden de las secciones se descoloque, y el documento se ve intencional —no inacabado— mientras las capturas no lleguen.

*Alternativa considerada:* dejar las referencias comentadas en HTML y descomentarlas al tener las imagenes. Evita el icono roto, pero obliga a editar el README por cada captura, que es exactamente la friccion que se quiere quitar, y deja la seccion "Vista previa" vacia mientras tanto.

*Alternativa considerada:* placeholders SVG. Se descarta porque el autor guardara PNG y tendria que editar la extension en el README, reintroduciendo la edicion manual.

Los placeholders se generan con Pillow, ya disponible en el `python3` del sistema. Es una utilidad de un solo uso: no se agrega ninguna dependencia al proyecto Flutter.

### La guia de personalizacion se organiza como tabla intencion → archivo

La arquitectura del proyecto hace que casi todo el re-marcado se resuelva en dos archivos (`constants.dart` y `app_theme.dart`), y esa es la propiedad mas vendible del repo. Una tabla "quiero cambiar X → toco Y" lo hace evidente de un vistazo, mucho mas que una descripcion archivo por archivo.

Las dos excepciones multi-archivo —el `case` del mapeo de iconos y el trio `navLinks` / `sectionIds` / `KeyedSubtree`— se documentan con su propio bloque, no como una fila de la tabla: son la trampa real del proyecto y merecen mas que una celda. Un lector que siga la tabla y omita el `case` obtiene un icono por defecto sin ningun aviso; uno que omita el `KeyedSubtree` obtiene un enlace que no hace nada, porque `_scrollTo` ignora en silencio los destinos que no resuelve.

### Toda cifra del README se verifica contra el repositorio

Las versiones (`sdk: >=3.1.5 <4.0.0`, `flutter_lints: ^2.0.0`, `cupertino_icons: ^1.0.2`, `version: 1.0.0+1`), los breakpoints (600 / 1024), el arbol de `lib/` y los nombres de los grupos de test se toman de los archivos, no de memoria. Documentacion que miente es peor que no tenerla, y este proyecto ya tiene un ejemplo vivo: `CLAUDE.md` afirma que la navegacion del navbar es un no-op cuando lleva tiempo implementada.

### Encabezado sin badges, y licencia MIT declarada de verdad

El encabezado lleva titulo, tagline y descripcion, sin bloque de badges. Un badge de shields.io es una peticion a un servicio externo por cada visita al repositorio y aporta datos que el propio README ya expone en su tabla de stack, esta vez leidos del `pubspec.yaml` real.

Se agrega un archivo `LICENSE` con el texto MIT a nombre de Rotman-IS. La alternativa —anunciar MIT sin archivo— se descarta por la misma regla que gobierna el resto del documento: la documentacion no afirma nada que el repositorio no respalde. La licencia se menciona en una seccion final del README, enlazando al archivo.

## Risks / Trade-offs

- **El renombrado deja el proyecto en un estado inconsistente entre Dart y nativo** → Se asume a conciencia y se documenta en el README con su razon, para que no se lea como un descuido. Si algun dia se necesita una build nativa con identidad propia, el renombrado completo es un cambio separado y acotado.

- **`pubspec.lock`, `.dart_tool/` y `landing_gym.iml` referencian el nombre viejo** → Son artefactos regenerables. Se ejecuta `flutter pub get` tras el cambio y se deja que el toolchain los reescriba; no se editan a mano. El `.iml` lo regenera el IDE.

- **Los placeholders pueden quedarse para siempre si el autor nunca toma las capturas** → El rotulo de cada placeholder dice explicitamente que es un marcador y que captura espera, asi que el estado provisional es legible en el propio documento en vez de aparentar una captura real.

- **El peso de los placeholders entra al repositorio** → Son PNG planos, de un color y un rotulo; unos pocos KB cada uno. Y seran sobrescritos, no acumulados.

- **El README puede envejecer respecto al codigo** → Se acota el riesgo documentando estructura y convenciones —que cambian poco— y evitando transcribir contenido que ya vive en `constants.dart`. La spec `project-documentation` fija la regla de que ninguna afirmacion contradiga el codigo, y queda como criterio verificable en cambios futuros.

## Migration Plan

1. Renombrar en `pubspec.yaml`, actualizar los siete imports de `test/widget_test.dart` y las cadenas de `web/`.
2. `flutter pub get` → `flutter analyze` → `flutter test`. Los tres tienen que pasar antes de tocar documentacion; si alguno falla, el fallo esta en el renombrado y no en el README.
3. Generar los placeholders y escribir el README contra el estado ya verificado.
4. Corregir `CLAUDE.md`.

Rollback: el cambio no toca logica de aplicacion ni assets de la landing. Revertir el commit deja el proyecto exactamente como estaba.

## Open Questions

- El nombre de la marca ficticia (`Iron Gym`) y el nombre del paquete (`basic_landing`) quedan deliberadamente desacoplados. Si en algun momento se decide que el repo es un *template* generico en vez de una demo de gimnasio, el copy de `constants.dart` seria lo siguiente en revisarse — fuera del alcance de este cambio.
- ~~La licencia no esta declarada en el repositorio.~~ **Resuelto:** se agrega `LICENSE` con MIT a nombre de Rotman-IS, y el encabezado del README va sin badges.
