## Why

El hero es actualmente una columna de texto centrada sobre un gradiente y dos círculos de glow: no comunica nada sobre el producto. Ya existe en el repositorio un banner fotográfico (`assets/images/heroBanner.webp`, 102 KB) con dos atletas sobre fondo negro y cuatro tarjetas de métrica en las esquinas, cuya paleta —azul profundo y dorado— coincide con los tokens de la marca. La especificación `design-tokens` ya previó este momento: exige que `darker` se aproxime al negro precisamente "para permitir que, en el futuro, contenido fotográfico con fondo negro se integre sin costura visible".

## What Changes

- El hero pasa a componer la imagen `assets/images/heroBanner.webp` bajo el bloque de texto, en lugar de mostrar únicamente el gradiente.
- **Desktop (≥ 600 px)** — composición *stacked*: el texto (tagline, subtítulo, CTA) ocupa la banda superior; la imagen se ancla al borde inferior con `BoxFit.cover` y `Alignment.bottomCenter`. La zona superior de la fotografía es fondo negro, de modo que texto y atletas no se solapan.
- **Móvil (< 600 px)** — la altura disponible no permite separar ambos bloques: la imagen pasa a ser fondo a sangre completa y el texto se superpone sobre un *scrim* (gradiente negro vertical) que garantiza la legibilidad.
- Se añade el scrim como variante traslúcida derivada en `AppTheme`, conforme al requisito de centralización de opacidades ya vigente.
- Se revisa la pertinencia de los dos círculos de glow existentes, que compiten visualmente con la fotografía.
- La ruta del asset se declara en `AppConstants`, siguiendo la convención de que todo el contenido vive allí y no incrustado en los widgets.
- Se garantiza que la imagen es decorativa a efectos de accesibilidad y que el fallo de carga del asset degrada al gradiente actual en vez de romper la sección.

No hay cambios de copy, de rutas, de dependencias ni de API. `pubspec.yaml` ya declara `assets/images/`.

## Capabilities

### New Capabilities

- `hero-banner`: composición visual de la sección hero — cómo se relacionan la fotografía, el texto y el CTA en cada breakpoint, qué garantías de legibilidad y de recorte deben cumplirse, y cómo degrada la sección si el asset no está disponible.

### Modified Capabilities

Ninguna. `design-tokens` sigue vigente sin cambios: el scrim se introduce como variante derivada de `AppTheme`, que es exactamente lo que exige el requisito *Centralización de las variantes con opacidad*, y no altera ningún token ni umbral de contraste. El contraste del texto del hero sobre la fotografía pasa a ser una garantía de `hero-banner`, no de la paleta.

## Impact

| Área | Efecto |
| --- | --- |
| `lib/widgets/hero_section.dart` | Reescritura de la composición interna. Único widget con cambios estructurales. |
| `lib/theme/app_theme.dart` | Alta de la variante traslúcida del scrim. Sin cambios en los tokens base. |
| `lib/utils/constants.dart` | Alta de la constante con la ruta del asset. |
| `assets/images/heroBanner.webp` | Ya presente y versionado. Sin cambios. |
| `pubspec.yaml` | Ya declara `assets/images/`. Sin cambios. |
| `test/widget_test.dart` | El test de render de la landing debe seguir pasando; conviene cubrir el nuevo comportamiento por breakpoint. |
| Rendimiento web | +102 KB en el LCP de la página. WebP es soportado por todos los navegadores objetivo de Flutter web. |
| Riesgo principal | El recorte de `BoxFit.cover` puede cortar las tarjetas de métrica de las esquinas en relaciones de aspecto extremas. Es el punto que `design.md` debe resolver. |
