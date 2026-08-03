## Why

La paleta actual mezcla un azul pizarra (`primary #2C3F59`) con naranja (`secondary #FF8F00`) y rojo (`accent #FF3D00`), una combinación que no corresponde a la dirección visual de referencia: base azul-negra monocroma con un único acento dorado y bordes plateados.

Además hay un defecto de accesibilidad preexistente: `primary` se usa a la vez como color de superficie (glow del hero, gradiente del CTA) y como color de texto e icono (logo, iconos de features, estrellas). Sobre `darker #121427` ese azul da ~1.6:1 de contraste, muy por debajo del mínimo WCAG AA de 4.5:1 — el logo y los iconos son prácticamente ilegibles hoy.

El objetivo secundario es que esta paleta sirva como base de una plantilla de landing reutilizable, por lo que los tokens deben permanecer con nombres genéricos e independientes de marca.

## What Changes

- Se redefinen los 8 tokens de color existentes en `AppTheme` y se añaden 2 nuevos (`onPrimary`, `primaryHover`), conservando los nombres genéricos actuales.
- **Se invierte el rol de `primary`**: pasa de ser un azul de superficie a ser el acento de marca (dorado), que es el color con el que ya se pintan logo e iconos. **BREAKING** para cualquier código futuro que asuma que `primary` es oscuro.
- `accent` pasa a ser la superficie elevada (azul), y `secondary` pasa a ser el color de estructura (plateado, bordes e iconos utilitarios).
- Se reasignan 11 callsites en los widgets donde `primary` se usaba como superficie, y donde el acento debe retirarse en favor de texto o estructura.
- Se añaden tokens derivados (`cardBorder`, `glow`, `glowSoft`) para centralizar las opacidades que hoy están dispersas en 6 widgets.
- Se corrige el `foregroundColor` de los botones: blanco sobre dorado da 2.15:1 e incumple AA; pasa a `onPrimary` oscuro (8.0:1).
- Se documenta un contrato de contraste como comentario en `app_theme.dart` para que futuros clones de la plantilla no rompan la accesibilidad al cambiar los hex.

Fuera de alcance en este cambio:

- No se incorpora la imagen de referencia como fondo del hero (requiere `assets/`, configuración de `pubspec.yaml` y rediseño del layout del hero).
- No se introduce tema claro ni se renombran `dark`/`darker`/`surface`.
- No se cambian tipografías, espaciados, copys ni estructura de secciones.

## Capabilities

### New Capabilities
- `design-tokens`: define el conjunto de tokens de color de la aplicación, el rol semántico de cada uno, el contrato de contraste que deben cumplir y las reglas de asignación de tokens a elementos de interfaz.

### Modified Capabilities

(ninguna — no existen specs previas en `openspec/specs/`)

## Impact

Código afectado:

- `lib/theme/app_theme.dart` — valores de los 8 tokens, 2 tokens nuevos, 3 tokens derivados, `foregroundColor` del `elevatedButtonTheme`, comentario del contrato de contraste.
- `lib/widgets/hero_section.dart` — glows (líneas 33, 45).
- `lib/widgets/cta_section.dart` — gradiente y botón (líneas 22, 47, 48).
- `lib/widgets/features_section.dart` — borde de tarjeta (línea 74).
- `lib/widgets/testimonials_section.dart` — borde de tarjeta y color del nombre (líneas 73, 96).
- `lib/widgets/footer.dart` — iconos de contacto y borde social (líneas 93, 117).

Sin cambios necesarios: `lib/widgets/navbar.dart`, `lib/main.dart`, `lib/utils/constants.dart`. Los 7 callsites que ya usaban `AppTheme.primary` para logo e iconos quedan correctos automáticamente al cambiar el valor del token.

Sin impacto en dependencias, API ni build. `flutter analyze` y `flutter test` deben seguir pasando; el test existente solo verifica que la pantalla renderiza.
