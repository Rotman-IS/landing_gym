# basic_landing

**Plantilla de landing page en Flutter.** Una sola pantalla, contenido en español, cero dependencias externas y todo el texto y el color centralizados en dos archivos, para que re-marcarla sea cuestión de minutos.

El contenido que trae de fábrica es una demo: un gimnasio ficticio llamado **Iron Gym**.

---

## Vista previa

![Hero en desktop](docs/screenshots/01-hero-desktop.png)

| Móvil | Servicios |
|:---:|:---:|
| ![Hero en móvil](docs/screenshots/02-hero-mobile.png) | ![Sección de servicios](docs/screenshots/03-features.png) |

![Testimonios y llamada a la acción](docs/screenshots/04-testimonials-cta.png)


---

## Qué es

Una landing page de marketing de **una sola pantalla**, pensada como punto de partida para adaptar a cualquier marca.

Lo que **no** tiene, a propósito:

- **Sin backend.** No hay peticiones de red ni formularios que envíen nada.
- **Sin routing.** Una única ruta; el navbar navega desplazando el scroll, no cambiando de pantalla.
- **Sin gestión de estado.** No hay Provider, Riverpod, Bloc ni equivalentes. El único estado es el `ScrollController` de la pantalla.
- **Sin dependencias de terceros.** Solo Flutter y Material.

Esa austeridad es la característica principal: todo el proyecto se lee de una sentada.

## Características

- **Responsive por breakpoints.** Tres rangos —móvil por debajo de 600 px, tablet entre 600 y 1024, desktop por encima— que ajustan padding, tamaños de fuente y número de columnas.
- **Tema oscuro con contrato de contraste.** La paleta está documentada en [app_theme.dart](lib/theme/app_theme.dart) con los pares que deben verificarse contra WCAG 2.1 al cambiar cualquier color.
- **Navegación con scroll suave.** Los enlaces del navbar desplazan hasta su sección en 600 ms con `Curves.easeInOut`.
- **Contenido centralizado.** Todo el copy, los datos de contacto y las redes viven en un solo archivo.
- **Cinco secciones** compuestas en orden: hero, servicios, testimonios, llamada a la acción y pie.
- **Suite de tests de layout** que cubre los breakpoints, la integridad de la imagen del hero y la navegación.

## Stack

| | |
|---|---|
| Framework | Flutter + Material, tema oscuro únicamente |
| SDK de Dart | `>=3.1.5 <4.0.0` |
| Dependencias | `cupertino_icons: ^1.0.2` |
| Dev dependencies | `flutter_test`, `flutter_lints: ^2.0.0` |
| Versión | `1.0.0+1` |
| Plataformas | Android · iOS · Web · macOS · Linux · Windows |

El destino natural de una landing es **web**; el resto de las plataformas viene del andamiaje de `flutter create` y no se ha ajustado.

## Instalación y ejecución

```bash
flutter pub get           # instalar dependencias
flutter run -d chrome     # ejecutar en el navegador
```

Para ver los tres breakpoints sin cambiar de dispositivo, abrí las DevTools del navegador y alterná el ancho de la ventana entre 390, 800 y 1440 px.

> **Nota sobre el SDK.** El archivo [android/local.properties](android/local.properties) está versionado y contiene la ruta al SDK de Flutter de la máquina donde se creó (`flutter.sdk=...`). Si compilás para Android, ajustá esa ruta a la tuya. Esperá que ese archivo aparezca modificado con frecuencia.

## Estructura del proyecto

```
lib/
├── main.dart .......................... LandingGymApp: MaterialApp con tema oscuro
├── screens/
│   └── landing_screen.dart ............ navbar fijo + scroll con las cinco secciones
├── theme/
│   └── app_theme.dart ................. paleta, TextTheme y contrato de contraste
├── utils/
│   ├── constants.dart ................. TODO el contenido y las medidas de espaciado
│   └── responsive.dart ................ helper de breakpoints, hoy sin uso (ver abajo)
└── widgets/
    ├── navbar.dart .................... enlaces en desktop, menú hamburguesa en móvil
    ├── hero_section.dart .............. portada con imagen, tagline y CTA
    ├── features_section.dart .......... retícula de servicios, 1 / 2 / 4 columnas
    ├── testimonials_section.dart ...... tres tarjetas de testimonio
    ├── cta_section.dart ............... bloque de conversión
    └── footer.dart .................... contacto y redes sociales

assets/images/heroBanner.webp .......... imagen de portada (1200 × 896)
docs/screenshots/ ...................... capturas para este README
openspec/ .............................. especificaciones y changes del proyecto
test/widget_test.dart .................. suite de tests de layout
```

Sobre [responsive.dart](lib/utils/responsive.dart): existe un helper `Responsive` con los mismos breakpoints de 600 y 1024, **pero ningún widget lo usa**. Cada sección resuelve la responsividad con una comprobación en línea:

```dart
final isMobile = MediaQuery.of(context).size.width < 600;
```

Si tocás este código, elegí uno de los dos caminos y sostenelo dentro de cada widget: o adoptás `Responsive` de forma consistente, o seguís el patrón en línea. Mezclarlos dentro de un mismo widget es lo único que hay que evitar.

---

## Personalización

La regla del proyecto es que **los widgets no contienen ni texto ni color**: leen todo de `AppConstants` y de `AppTheme`. Por eso, casi cualquier re-marcado se resuelve en dos archivos.

| Quiero cambiar… | Toco… |
|---|---|
| Nombre de la marca, tagline, textos de las secciones | [lib/utils/constants.dart](lib/utils/constants.dart) |
| Teléfono, correo, dirección, redes sociales | [lib/utils/constants.dart](lib/utils/constants.dart) |
| Testimonios | `AppConstants.testimonials` |
| Colores de marca | [lib/theme/app_theme.dart](lib/theme/app_theme.dart) |
| Tipografías y tamaños | El `TextTheme` de `AppTheme` |
| Imagen de portada | Reemplazar `assets/images/heroBanner.webp` conservando el nombre |
| Título de la pestaña del navegador | [web/index.html](web/index.html) y [web/manifest.json](web/manifest.json) |

### Cambiar los colores

Editá únicamente los tokens de la parte superior de `AppTheme`. Sus nombres describen el **rol**, no el color, justamente para que la paleta se pueda reusar con otra identidad:

```dart
static const Color darker  = Color(0xFF08090B);  // fondo más profundo
static const Color dark    = Color(0xFF101822);  // fondo de la app
static const Color surface = Color(0xFF1B2A42);  // tarjetas
static const Color primary = Color(0xFFC9A24D);  // único color saturado
```

Al terminar, reverificá los pares de contraste listados en los comentarios de ese archivo. El contrato exige 4.5:1 para todo texto e icono, y 3:1 para bordes.

### Agregar un servicio ⚠️ dos archivos

Los iconos se guardan como **cadenas de texto** en las constantes, así que agregar un servicio requiere dos ediciones:

**1.** Una entrada en `AppConstants.features`, en [constants.dart](lib/utils/constants.dart):

```dart
{
  'icon': 'pool',
  'title': 'Natación',
  'description': 'Piscina climatizada de 25 metros.',
},
```

**2.** Un `case` en `_getIcon`, al final de [features_section.dart](lib/widgets/features_section.dart#L159):

```dart
case 'pool':
  return Icons.pool;
```

Si te olvidás del segundo paso **no vas a ver ningún error**: el `default` devuelve `Icons.star` y la tarjeta se dibuja con una estrella.

### Agregar un enlace de navegación ⚠️ tres archivos

**1.** Una entrada en `AppConstants.navLinks`:

```dart
{'label': 'Precios', 'section': 'pricing'},
```

**2.** El identificador en `LandingScreen.sectionIds`, en [landing_screen.dart](lib/screens/landing_screen.dart#L23):

```dart
static const List<String> sectionIds = ['hero', 'features', 'testimonials', 'cta', 'pricing'];
```

**3.** El `KeyedSubtree` correspondiente dentro de la `Column` de la pantalla:

```dart
KeyedSubtree(
  key: _sectionKeys['pricing'],
  child: const PricingSection(),
),
```

Igual que antes, omitir un paso falla **en silencio**: `_scrollTo` ignora a propósito los destinos que no puede resolver, así que el enlace simplemente no hace nada. El test `cada link del navbar tiene una seccion registrada` cubre el hueco entre los pasos 1 y 2.

---

## Tests

```bash
flutter test                                              # toda la suite
flutter test --plain-name 'el numero de columnas sigue los breakpoints'   # un solo test
flutter analyze                                           # lint
```

La suite vive en [test/widget_test.dart](test/widget_test.dart) y se organiza en tres grupos:

| Grupo | Qué verifica |
|---|---|
| `hero banner` | Que texto e imagen no se solapen en desktop, que la imagen no se recorte, que en móvil vaya a sangre, que sea decorativa para lectores de pantalla y que un fallo de carga no rompa la sección |
| `reticula de features` | Que ningún ancho desborde las tarjetas, que el número de columnas siga los breakpoints y que las tarjetas de una fila compartan alto |
| `navegacion por secciones` | Que cada enlace del navbar tenga una sección registrada y que tocarlo desplace la vista, en desktop y en móvil |

El viewport por defecto de `flutter_test` es 800 × 600, que cae siempre en la rama desktop. Los tests fijan el tamaño explícitamente para ejercitar ambos breakpoints.

## Build y despliegue

```bash
flutter build web
```

El resultado queda en `build/web/` y es un sitio estático: se puede servir desde cualquier hosting sin backend.

Si vas a servirlo bajo una subruta —GitHub Pages, por ejemplo, donde el sitio vive en `usuario.github.io/repo/`— indicá la base:

```bash
flutter build web --base-href /repo/
```

Omitirlo hace que los assets se pidan desde la raíz del dominio y la página cargue en blanco.

## Flujo OpenSpec

El diseño de este proyecto está versionado con [OpenSpec](https://github.com/Fission-AI/OpenSpec). No es necesario para ejecutar la landing, pero explica por qué el código está como está.

```
openspec/
├── specs/                # comportamiento vigente, por capability
│   ├── design-tokens/            reglas de la paleta y contrato de contraste
│   ├── features-section-layout/  comportamiento de la retícula
│   ├── hero-banner/              composición del hero en cada breakpoint
│   └── navbar-section-navigation/ navegación por secciones
└── changes/archive/      cambios ya aplicados, con su propuesta y su diseño
```

Antes de tocar el layout de una sección, leé su spec: contiene decisiones ya tomadas y sus razones. Para proponer un cambio nuevo:

```bash
openspec new change "<nombre-en-kebab-case>"
openspec status --change "<nombre>"
```

## Nota sobre el nombre del paquete

El paquete Dart se llama `basic_landing`, pero los **identificadores nativos conservan el nombre anterior**, `landing_gym`: el `applicationId` de Android, el directorio del paquete Kotlin, el `PRODUCT_NAME` de macOS y los `BINARY_NAME` de Linux y Windows.

Es deliberado. Renombrarlos exige mover directorios de código fuente y editar proyectos de Xcode y Gradle, y el resultado no se puede verificar sin ejecutar builds nativas que esta landing —cuyo destino es web— nunca va a correr. Si algún día necesitás una build nativa con identidad propia, es un cambio aparte y acotado.

## Licencia

MIT. Ver [LICENSE](LICENSE).
