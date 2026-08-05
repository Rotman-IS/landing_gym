## Context

`HeroSection` es hoy un `StatelessWidget` con un `Stack` de tres capas: gradiente de fondo, dos círculos de glow posicionados fuera de los bordes, y una `Column` centrada con tagline, subtítulo y CTA. Su altura es `85%` del viewport en desktop y `70%` en móvil.

El asset a integrar es `assets/images/heroBanner.webp`: **1200 × 896 px**, relación de aspecto **1.34 (≈ 4:3)**, 102 KB. Su composición no es neutra y condiciona el diseño:

```
   [Time]                    [Kcal]     ← esquinas ocupadas por tarjetas
        ╔═══════════════╗                 de métrica (parte del bitmap)
        ║    atletas    ║               ← centro visual, no puede taparse
        ╚═══════════════╝
   [Sets]                    [Reps]

   franja superior ≈ negro puro         ← única zona libre
```

El fondo del bitmap es negro con viñeta, prácticamente idéntico a `AppTheme.darker` (`#08090B`). La especificación `design-tokens` ya exige esa cercanía al negro "para permitir que contenido fotográfico con fondo negro se integre sin costura visible": esta es la restricción que hace viable todo el diseño de abajo.

## Goals / Non-Goals

**Goals:**

- Integrar la fotografía sin recortar las cuatro tarjetas de métrica, que son parte del mensaje visual.
- Garantizar que el texto del hero nunca se superponga a los cuerpos de los atletas en desktop.
- Mantener legibilidad de tagline, subtítulo y CTA en todos los anchos, incluida la superposición forzosa de móvil.
- Degradar de forma limpia si el asset no carga.
- No introducir dependencias nuevas ni gestión de estado.

**Non-Goals:**

- Recrear las tarjetas de métrica como widgets Flutter. Se quedan dentro del bitmap en esta iteración.
- Animaciones de entrada, parallax o efectos al hacer scroll.
- Adoptar el helper `Responsive` (sigue sin usarse; este widget mantiene el patrón inline de `MediaQuery`).
- Variantes del asset por densidad (`2x/3x`) o `art direction` con recortes distintos por breakpoint.
- Corregir el `onSectionTap` no funcional del navbar.

## Decisions

### 1. Dos composiciones distintas, no una sola parametrizada

Desktop y móvil no son el mismo layout con números distintos: en desktop texto e imagen **no se solapan**, en móvil **se solapan por necesidad**. Modelarlos como una sola estructura con paddings condicionales obligaría a un `Stack` en ambos casos y perdería la garantía estructural de no-solapamiento.

```
DESKTOP (>= 600)  ── Column, sin solapamiento posible

┌──────────────────────────────────────┐
│                                      │  flex 4
│           TAGLINE                    │  región de texto
│           subtítulo                  │  (fondo: gradiente + glow)
│           [ CTA ]                    │
├──────────────────────────────────────┤
│   [Time]              [Kcal]         │  flex 6
│        ▓▓▓ atletas ▓▓▓               │  región de imagen
│   [Sets]              [Reps]         │  anclada abajo
└──────────────────────────────────────┘

MÓVIL (< 600)  ── Stack, solapamiento con scrim

┌────────────────────┐
│ ░░░ scrim ░░░░░░░░ │  ← gradiente negro vertical
│      TAGLINE       │
│     subtítulo      │
│      [ CTA ]       │
│ ▓▓ imagen cover ▓▓ │  ← a sangre, alignment center
└────────────────────┘
```

**Alternativa descartada:** un único `Stack` con la imagen a sangre en ambos breakpoints y el texto arriba. Más simple de escribir, pero en desktop el scrim tendría que ser lo bastante opaco como para apagar la fotografía justo donde está su sujeto.

### 2. `BoxFit.contain` en desktop, no `cover`

Esta es la decisión central y resuelve el riesgo principal identificado en el proposal.

La región de imagen en desktop es una banda ancha y baja: con un viewport de 1440 × 900, la banda mide ≈ 1440 × 459, relación **3.1**. La imagen tiene relación **1.34**. Aplicar `cover` la escalaría al ancho de la banda (1440 × 1075) y recortaría ≈ 616 px verticales — es decir, **las cuatro tarjetas de métrica desaparecerían** junto con las cabezas de los atletas.

Con `contain` la imagen entra completa, escalada a la altura de la banda y centrada horizontalmente. En pantallas anchas quedan franjas laterales vacías que se rellenan con `AppTheme.darker`. Se paga con una imagen más pequeña en ultra-wide, no con pérdida de contenido.

| | `cover` | `contain` (elegida) |
| --- | --- | --- |
| Tarjetas de métrica | Se pierden | Siempre visibles |
| Franjas laterales | Ninguna | Sí, pero indistinguibles del fondo |
| Tamaño en ultra-wide | Máximo | Menor |
| Predecible entre anchos | No | Sí |

En móvil sí se usa `cover` con `Alignment.center`: un viewport en retrato (≈ 0.5 de relación) contra una imagen de 1.34 no admite `contain` sin dejar la mitad de la pantalla vacía. Se acepta que las tarjetas laterales se recorten en móvil; los atletas, que son el sujeto, se conservan.

### 2-bis. Los bordes de la fotografía se difuminan con una máscara

**Corrección tras la revisión visual.** La decisión 2 daba por hecho que el fondo del bitmap era negro puro y que, por tanto, rellenar las franjas laterales con `AppTheme.darker` haría invisible su límite. **Es falso**: el fondo de la fotografía es un azul-gris texturizado con viñeta, claramente más claro que `darker`. En las capturas a 1920 y 1440 el rectángulo de la imagen se recortaba con nitidez contra la sección.

Se corrige difuminando los bordes laterales y superior con dos `ShaderMask` anidadas en `BlendMode.dstIn` —una horizontal, otra vertical—. La imagen se disuelve en el fondo y el rectángulo desaparece.

Para que la máscara caiga sobre los bordes **de la imagen** y no sobre los de la región —que es mucho más ancha—, el `Image` se envuelve en un `AspectRatio` con la relación del bitmap. Bajo restricciones sueltas, `AspectRatio` reproduce exactamente el encaje de `contain`, así que la geometría no cambia; lo que cambia es que los límites del widget pasan a coincidir con los de la imagen pintada.

Los márgenes de difuminado son estrechos a propósito (7 % lateral, 9 % superior): las tarjetas de métrica arrancan hacia el 7 % del ancho y el 12 % del alto, y un desvanecido más generoso se las comería.

**Alternativas descartadas:** teñir el fondo de la región con el color medio de la fotografía —la viñeta y la textura dejan el borde todavía perceptible—; y tratar la imagen como una tarjeta explícita con `cardBorder` y esquinas redondeadas —coherente con features y testimonios, pero convierte el hero en un contenedor de tarjeta en vez de una imagen a toda página—.

No se difumina el borde inferior: la imagen está anclada al final de la sección, y ahí la costura que se ve es la que separa el hero de la sección siguiente, común a toda la landing.

### 3. La región de imagen se dimensiona por `flex`, no por altura fija

`Expanded(flex: 3)` para el texto y `Expanded(flex: 7)` para la imagen. Una altura fija en píxeles se rompería entre un portátil de 768 px de alto y un monitor de 1440. El reparto por flex mantiene la proporción y garantiza que el bloque de texto siempre tenga sitio.

El reparto arrancó en 4/6 y se ajustó a 3/7 tras la revisión visual: con 4/6, la banda de texto reservaba unos 367 px en 1920 × 1080 para un contenido que ocupa unos 190, dejando un hueco muerto muy visible entre el CTA y la fotografía.

Como el bloque de texto podría desbordar su banda en viewports muy bajos, va envuelto en un `FittedBox(scaleDown)`. Ese `FittedBox` necesita a su vez un `SizedBox` con la anchura disponible: sin él recibiría restricciones horizontales infinitas y el texto dejaría de hacer wrap.

### 4. El scrim se declara en `AppTheme`, no en el widget

El requisito *Centralización de las variantes con opacidad* de `design-tokens` prohíbe llamar a `.withValues(alpha:)` sobre un token dentro del árbol de construcción de un widget. El scrim se añade como par de miembros derivados —una variante opaca y una transparente del fondo profundo— junto a `glow` y `glowSoft`. Nombres por rol, sin referencias cromáticas, como manda la misma spec.

El scrim es un `LinearGradient` vertical de opaco arriba a transparente abajo: oscurece la banda donde vive el texto y deja limpia la banda donde están los atletas.

### 5. Se retira el glow inferior izquierdo, se conserva el superior derecho

El círculo inferior quedaba a la altura que ahora ocupa la fotografía, que ya trae su propia viñeta; sumar un glow encima ensucia el borde. El superior derecho sigue cumpliendo su función de dar profundidad a la banda de texto y se mantiene.

### 6. La ruta del asset vive en `AppConstants`

Por la convención del proyecto —todo el contenido en constantes, los widgets no incrustan literales—. Se añade como `String` junto al resto de contenido.

### 7. Fallo de carga: degradar, no romper

`Image.asset` con `errorBuilder` que devuelve un widget vacío. Si el asset falta o el decodificador falla, la sección se queda con el gradiente y el texto actuales — exactamente el hero de hoy. Nada de excepciones en pantalla.

La imagen es decorativa: se excluye de la capa semántica para que un lector de pantalla no anuncie un elemento sin significado. El mensaje ya está en el tagline.

## Risks / Trade-offs

| Riesgo | Mitigación |
| --- | --- |
| En pantallas muy anchas (≥ 2000 px) la imagen `contain` se ve pequeña y aislada en el centro. | Mitigado en parte por el reparto 3/7 y por el difuminado de bordes, que evita que la imagen se lea como un recorte pegado. Si sigue molestando, la siguiente iteración recrea las tarjetas como widgets y libera el recorte. |
| En móvil, `cover` recorta las tarjetas de métrica laterales. | Aceptado explícitamente: fue la elección de composición para móvil. Los atletas, que son el sujeto, se conservan al usar `Alignment.center`. |
| El texto de móvil se apoya sobre una fotografía de luminancia variable; el contrato de contraste de `design-tokens` está definido contra superficies planas, no contra un bitmap. | El scrim garantiza un suelo de luminancia bajo la banda de texto. Su opacidad debe validarse contra la zona más clara de la imagen en esa banda, no contra su promedio. |
| +102 KB en el LCP de la landing. | WebP a 1200 px es un tamaño razonable para un hero; no se añaden variantes de densidad. Cabe `precacheImage` si se observa un parpadeo en el primer render. |
| Al escalar 1200 px hacia arriba en pantallas grandes puede verse blanda. | Fijar una calidad de filtrado explícita en el `Image`; no se sube la resolución del asset en esta iteración. |
| `flutter test` renderiza con un viewport por defecto de 800 × 600, que cae en la rama desktop; la rama móvil quedaría sin cubrir por accidente. | Los tests deben fijar el tamaño de la superficie de prueba explícitamente para ejercitar ambos breakpoints. |

## Open Questions

- ¿Se recrean las tarjetas de métrica como widgets Flutter en una iteración posterior? Resolvería a la vez el recorte en móvil, el escalado blando y el tamaño en ultra-wide, y permitiría editar sus valores desde `AppConstants`. Requiere una versión del asset sin tarjetas.
- El reparto 4/6 entre texto e imagen es un punto de partida razonable; conviene ajustarlo al ver el resultado real.
