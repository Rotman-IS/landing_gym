## Why

En la sección "¿Por qué elegirnos?" las tarjetas de features desbordan por abajo a 1024px de ancho (PC pequeña 1024x600, iPad Pro vertical 1024x1366). La causa es que `GridView.count` con `childAspectRatio: 1` deriva la **altura** de la celda del ancho disponible, no del contenido: a 1024px exactos la rama desktop reparte el ancho en 4 columnas de 206px, lo que deja 158px de alto útil para un contenido que necesita ~215px. El copy vive en `AppConstants` y está diseñado para cambiar, así que cualquier arreglo basado en un ratio fijo vuelve a romperse con el siguiente texto o traducción.

## What Changes

- Reemplazar `GridView.count` en `FeaturesSection` por un layout que **mide la altura por contenido**, de forma que la tarjeta nunca imponga un alto menor al que su texto necesita.
- Igualar la altura de las tarjetas **dentro de cada fila** (no globalmente), para conservar la retícula visual que el grid daba hoy.
- Eliminar `childAspectRatio` del widget: deja de existir un número mágico que acopla alto con ancho.
- Mantener sin cambios los breakpoints y el conteo de columnas actuales (1 col `<600` / 2 col `600–1023` / 4 col `>=1024`) y el patrón inline de `MediaQuery` que usa el resto de las secciones. El reparto horizontal pasa a resolverse solo, sin cálculo explícito de anchos.
- Conservar el resto de la apariencia sin cambios: mismos colores, tipografías, paddings, `crossAxisSpacing`/`mainAxisSpacing` de 24 y radio de borde.

No hay cambios de copy, de tokens de tema ni de constantes.

## Capabilities

### New Capabilities
- `features-section-layout`: Comportamiento de la retícula de tarjetas de la sección "¿Por qué elegirnos?": conteo de columnas por breakpoint, dimensionado vertical por contenido, alineación de alturas por fila y ausencia de desbordamiento en cualquier ancho de viewport.

### Modified Capabilities
<!-- Ninguna. `design-tokens`, `hero-banner` y `navbar-section-navigation` no cambian sus requisitos. -->

## Impact

- **Código**: `lib/widgets/features_section.dart` — único archivo con lógica de layout afectada. `FeaturesSection.build` (retícula) y `_FeatureCard` (necesita poder estirarse verticalmente).
- **Sin impacto**: `lib/utils/constants.dart`, `lib/theme/app_theme.dart`, `lib/screens/landing_screen.dart` y el resto de widgets. Se verificó que `features_section.dart` es el único uso de `GridView`/`childAspectRatio` de layout del proyecto; el `AspectRatio` de `hero_section.dart` es intencional para encajar un bitmap y no se toca.
- **Dependencias**: ninguna nueva. Solo widgets de `flutter/material`.
- **Tests**: `test/widget_test.dart` debe seguir pasando; se añaden pruebas de layout a varios anchos.
- **Riesgo**: bajo y contenido a una sección estática sin estado.
