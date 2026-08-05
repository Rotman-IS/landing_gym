# hero-banner

## Purpose

Define la composición visual de la sección hero: cómo se relacionan la fotografía de portada, el bloque de texto y el botón de acción en cada breakpoint, qué garantías de legibilidad y de integridad de la imagen deben cumplirse, y cómo degrada la sección cuando el asset no está disponible.

El asset de portada es `assets/images/heroBanner.webp` (1200 × 896 px). Su composición no es neutra y condiciona el diseño: dos atletas centrados sobre un fondo azul-gris texturizado, con cuatro tarjetas de métrica situadas en las esquinas del bitmap que forman parte del mensaje visual y no pueden perderse por recorte.

El contrato de contraste de [`design-tokens`](../design-tokens/spec.md) está definido frente a superficies planas. La legibilidad del texto sobre contenido fotográfico es responsabilidad de esta capability.

## Requirements

### Requirement: Presencia del banner fotográfico en el hero

La sección hero SHALL renderizar la imagen `assets/images/heroBanner.webp` como parte de su composición, en todos los anchos de viewport.

La ruta del asset SHALL declararse como constante en `AppConstants`. Ningún widget PUEDE incrustar la ruta como literal en su árbol de construcción, conforme a la convención del proyecto de mantener todo el contenido centralizado.

#### Scenario: El hero incluye la imagen

- **WHEN** se renderiza `HeroSection` en cualquier ancho de viewport
- **THEN** el árbol de widgets contiene un `Image` cuyo `AssetImage` apunta a `assets/images/heroBanner.webp`

#### Scenario: La ruta no está incrustada en el widget

- **WHEN** se busca la cadena `assets/images/` dentro de `lib/widgets/`
- **THEN** no aparece ninguna ocurrencia
- **AND** la ruta está declarada como constante en `lib/utils/constants.dart`

### Requirement: Composición apilada sin solapamiento en desktop

Con un ancho de viewport de 600 px o más, el hero SHALL disponer el bloque de texto y la imagen en **regiones verticales disjuntas**: el texto —tagline, subtítulo y botón CTA— en la banda superior, y la imagen anclada a la banda inferior.

La separación SHALL ser estructural —regiones hermanas dentro de una `Column` con reparto por `flex`— y no depender de paddings o desplazamientos calculados. Ningún elemento de texto o el botón CTA PUEDE quedar dibujado sobre el área de la imagen.

Las alturas de ambas regiones SHALL definirse proporcionalmente respecto a la altura del hero, no en píxeles fijos.

#### Scenario: Texto e imagen ocupan bandas distintas

- **WHEN** se renderiza el hero con un ancho de 1440 px
- **THEN** el rectángulo que ocupa el bloque de texto y el rectángulo que ocupa la imagen no se intersecan

#### Scenario: El reparto se mantiene entre alturas de pantalla

- **WHEN** se renderiza el hero con la misma anchura pero alturas de viewport de 768 px y de 1440 px
- **THEN** la proporción entre la altura de la región de texto y la de la región de imagen es la misma en ambos casos

#### Scenario: El CTA nunca queda sobre la fotografía

- **WHEN** se renderiza el hero en cualquier ancho de 600 px o superior
- **THEN** el botón CTA queda íntegramente dentro de la región de texto

### Requirement: La imagen se muestra completa en desktop

Con un ancho de viewport de 600 px o más, la imagen SHALL escalarse de modo que **quede contenida por entero** dentro de su región, sin recorte en ninguno de sus cuatro bordes. No PUEDE emplearse un ajuste que recorte el bitmap, como `BoxFit.cover` o `BoxFit.fitWidth`.

Esta garantía existe porque las cuatro tarjetas de métrica situadas en las esquinas del bitmap forman parte del mensaje visual: un recorte las eliminaría.

El espacio sobrante a los lados de la imagen SHALL quedar cubierto por la superficie más profunda de la paleta (`AppTheme.darker`).

#### Scenario: Las tarjetas de métrica sobreviven en una pantalla ancha

- **WHEN** se renderiza el hero con un viewport de 1920 × 1080 px
- **THEN** la imagen se muestra completa y las cuatro esquinas del bitmap son visibles

#### Scenario: Las tarjetas de métrica sobreviven en una banda muy achatada

- **WHEN** se renderiza el hero con un viewport de 1440 × 700 px, donde la región de imagen es mucho más ancha que alta
- **THEN** la imagen sigue mostrándose completa, escalada a la altura disponible
- **AND** no se recorta ninguno de sus bordes

#### Scenario: Las franjas laterales usan la superficie mas profunda

- **WHEN** la imagen no llena todo el ancho de su región
- **THEN** el color que ocupa el espacio restante es `AppTheme.darker`

### Requirement: Disolución del borde rectangular de la fotografía

El fondo del bitmap no es negro puro, sino un azul-gris texturizado con viñeta, perceptiblemente más claro que `AppTheme.darker`. Por tanto, cubrir el espacio sobrante con esa superficie **no basta** para ocultar el límite de la imagen: su borde recto se recorta contra la sección.

Con un ancho de viewport de 600 px o más, los bordes laterales y superior de la fotografía SHALL difuminarse hasta la transparencia mediante una máscara, de modo que la imagen se funda con el fondo de la sección en lugar de leerse como un rectángulo pegado encima.

La caja del widget enmascarado SHALL tener exactamente la relación de aspecto del bitmap, para que la máscara se alinee con los bordes reales de la imagen y no con los de la región que la contiene.

Los márgenes de difuminado SHALL ser lo bastante estrechos como para no borrar las tarjetas de métrica, que arrancan aproximadamente al 7 % del ancho y al 12 % del alto del bitmap.

El borde inferior NO SE difumina: la imagen está anclada al final de la sección, y la costura visible en ese punto es la que separa el hero de la sección siguiente.

#### Scenario: El borde de la fotografía no se lee como un rectángulo

- **WHEN** se renderiza el hero con un viewport de 1920 × 1080 px
- **THEN** los bordes laterales y superior de la imagen se desvanecen gradualmente hacia el fondo de la sección
- **AND** no se percibe una arista recta que delimite el bitmap

#### Scenario: La máscara se alinea con la imagen, no con la región

- **WHEN** la imagen ocupa solo una fracción del ancho de su región
- **THEN** el difuminado arranca en los bordes de la propia imagen
- **AND** no en los bordes de la región que la contiene

#### Scenario: El difuminado no se come las tarjetas de métrica

- **WHEN** se aplica la máscara de bordes
- **THEN** las cuatro tarjetas de métrica siguen siendo legibles por completo

### Requirement: Fondo a sangre con scrim en móvil

Con un ancho de viewport inferior a 600 px, la altura disponible no permite bandas disjuntas. El hero SHALL entonces mostrar la imagen como **fondo a sangre completa**, cubriendo toda la superficie de la sección, con el bloque de texto superpuesto.

La imagen SHALL escalarse cubriendo la sección y centrarse, de modo que los atletas —el sujeto de la fotografía— permanezcan visibles. Se acepta el recorte de las tarjetas de métrica laterales en este breakpoint.

Entre la imagen y el texto SHALL interponerse un **scrim**: un gradiente vertical que va de opaco en la parte superior —donde vive el texto— a transparente en la inferior. El texto NO PUEDE dibujarse directamente sobre la fotografía sin esa capa intermedia.

#### Scenario: La imagen cubre toda la sección

- **WHEN** se renderiza el hero con un viewport de 390 × 844 px
- **THEN** la imagen ocupa el ancho y el alto completos de la sección, sin franjas vacías

#### Scenario: El sujeto de la fotografía se conserva

- **WHEN** la imagen se recorta para cubrir un viewport en retrato
- **THEN** el recorte se toma desde el centro del bitmap

#### Scenario: Existe una capa entre imagen y texto

- **WHEN** se inspecciona el orden de pintado del hero en móvil
- **THEN** entre la imagen y el bloque de texto hay una capa de scrim con gradiente vertical de opaco a transparente

### Requirement: Legibilidad del texto del hero sobre contenido fotográfico

El tagline, el subtítulo y el rótulo del botón CTA SHALL mantener un contraste mínimo de 4.5:1 frente al fondo efectivo sobre el que se dibujan, incluido el caso en que ese fondo es la fotografía atenuada por el scrim.

La opacidad del scrim SHALL calibrarse contra la **zona más clara** de la imagen que quede bajo la banda de texto, no contra su luminancia promedio.

El contrato de contraste de la especificación `design-tokens` está definido frente a superficies planas; este requisito lo extiende al fondo fotográfico y es responsabilidad de esta capability, no de la paleta.

#### Scenario: El tagline es legible sobre la fotografía

- **WHEN** se renderiza el hero en móvil con la imagen de fondo
- **THEN** el contraste entre `textPrimary` y el fondo efectivo bajo el tagline es de al menos 4.5:1

#### Scenario: La calibración considera el peor caso

- **WHEN** se valida la opacidad del scrim
- **THEN** la medida se toma sobre el píxel más claro de la imagen situado bajo la banda de texto

### Requirement: Centralización de la variante traslúcida del scrim

Los colores del scrim SHALL declararse como miembros derivados de `AppTheme`, junto a `cardBorder`, `glow` y `glowSoft`. `HeroSection` NO PUEDE aplicar `.withValues(alpha:)` sobre un token de color dentro de su árbol de construcción.

Sus nombres SHALL describir el rol y no contener referencias cromáticas ni de marca, conforme a la especificación `design-tokens`.

#### Scenario: Ajustar la intensidad del scrim en un solo punto

- **WHEN** se necesita oscurecer o aclarar el scrim del hero
- **THEN** basta con editar el miembro correspondiente de `AppTheme`

#### Scenario: El widget no calcula opacidades

- **WHEN** se buscan llamadas a `.withValues(alpha:` o `.withOpacity(` dentro de `lib/widgets/hero_section.dart`
- **THEN** no se encuentra ninguna aplicada sobre una constante de `AppTheme`

### Requirement: Degradación ante fallo de carga del asset

Si la imagen no puede cargarse o decodificarse, el hero SHALL seguir renderizando su gradiente de fondo, el tagline, el subtítulo y el botón CTA. NO PUEDE mostrarse un icono de error, un hueco roto ni propagarse una excepción a la pantalla.

#### Scenario: El asset falta en el bundle

- **WHEN** se renderiza el hero y la carga de `heroBanner.webp` falla
- **THEN** la sección muestra el gradiente, el tagline, el subtítulo y el botón CTA
- **AND** no aparece ningún indicador de error en pantalla
- **AND** no se propaga ninguna excepción

### Requirement: La imagen es decorativa a efectos de accesibilidad

La imagen del hero SHALL excluirse de la capa semántica: no aporta información que no esté ya en el tagline y el subtítulo. Un lector de pantalla NO PUEDE anunciarla como un elemento con contenido.

#### Scenario: Un lector de pantalla recorre el hero

- **WHEN** se inspecciona el árbol de semántica de `HeroSection`
- **THEN** la imagen no genera ningún nodo semántico
- **AND** el tagline, el subtítulo y el botón CTA sí son alcanzables

### Requirement: Ornamentos de fondo compatibles con la fotografía

El hero SHALL mostrar un único ornamento de glow, anclado a su esquina superior derecha, cuya función es dar profundidad a la banda de texto. NO PUEDE existir ningún ornamento anclado al borde inferior de la sección, cuya posición ocupa la fotografía —que ya aporta su propia viñeta—.

Ningún ornamento decorativo PUEDE dibujarse por encima de la imagen.

#### Scenario: No queda glow bajo la fotografía

- **WHEN** se renderiza el hero
- **THEN** no existe ningún círculo de glow anclado al borde inferior izquierdo de la sección

#### Scenario: Los ornamentos quedan detrás de la imagen

- **WHEN** se inspecciona el orden de pintado del hero
- **THEN** los ornamentos decorativos se pintan antes que la imagen
