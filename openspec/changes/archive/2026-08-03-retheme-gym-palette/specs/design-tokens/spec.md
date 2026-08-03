## ADDED Requirements

### Requirement: Tokens de color con nombres agnósticos de marca

`AppTheme` SHALL exponer la paleta completa como constantes con nombres que describan el **rol semántico** del color y no el color concreto. Ningún nombre de token PUEDE contener una referencia cromática o de marca (`gold`, `navy`, `silver`, `orange`, etc.), de modo que reusar la plantilla con otra identidad requiera cambiar únicamente los valores hexadecimales.

#### Scenario: Clonar la plantilla con otra identidad de marca

- **WHEN** una persona clona el proyecto y sustituye los valores hexadecimales de los tokens en `app_theme.dart`
- **THEN** ningún nombre de token queda desalineado con su valor
- **AND** no es necesario modificar ningún archivo dentro de `lib/widgets/`

#### Scenario: Auditar los nombres de token

- **WHEN** se revisan las constantes públicas de `AppTheme`
- **THEN** ninguna contiene las cadenas `gold`, `navy`, `silver`, `orange`, `red`, `blue` ni ningún otro nombre de color

### Requirement: Separación entre tokens de superficie y tokens de acento

Cada token SHALL desempeñar un único rol. Los tokens de superficie (`darker`, `dark`, `surface`, `accent`) SHALL usarse exclusivamente como fondos, gradientes y glows. Los tokens de acento y texto (`primary`, `secondary`, `textPrimary`, `textSecondary`) SHALL usarse exclusivamente como color de primer plano, salvo `primary` en su rol de relleno del botón de acción principal.

Un mismo token NO PUEDE emplearse simultáneamente como fondo de sección y como color de texto o icono.

#### Scenario: Un token de superficie se usa como texto

- **WHEN** un widget asigna `AppTheme.accent`, `AppTheme.dark`, `AppTheme.darker` o `AppTheme.surface` a un `TextStyle.color` o al `color` de un `Icon`
- **THEN** eso constituye una violación de la especificación y debe corregirse

#### Scenario: El acento de marca pinta logo e iconos

- **WHEN** se renderizan el logo del navbar, el logo del footer, los iconos de features, el icono de comilla de testimonios y los iconos de redes sociales
- **THEN** todos usan `AppTheme.primary`

### Requirement: Contrato de contraste WCAG AA

La paleta SHALL cumplir los siguientes umbrales mínimos de contraste, verificables mediante el cálculo de luminancia relativa de WCAG 2.1:

| Par de colores | Umbral mínimo |
| --- | --- |
| `primary` sobre `darker`, `dark` y `surface` | 4.5:1 |
| `onPrimary` sobre `primary` | 4.5:1 |
| `textPrimary` sobre `darker`, `dark`, `surface` y `accent` | 4.5:1 |
| `textSecondary` sobre `darker`, `dark` y `surface` | 4.5:1 |
| `secondary` sobre `surface` | 3:1 |

Este contrato SHALL estar documentado como comentario en `lib/theme/app_theme.dart`, adyacente a las declaraciones de los tokens.

#### Scenario: El logo del navbar es legible

- **WHEN** se renderiza el logo con `primary` sobre el fondo `darker` del navbar
- **THEN** el contraste es de al menos 4.5:1

#### Scenario: El texto del botón principal es legible

- **WHEN** se renderiza un `ElevatedButton` con relleno `primary`
- **THEN** su `foregroundColor` es `onPrimary` y el contraste contra `primary` es de al menos 4.5:1
- **AND** el `foregroundColor` no es `Colors.white`

#### Scenario: Cambiar un valor rompe el contrato

- **WHEN** alguien modifica el valor de `primary` sin ajustar `onPrimary`
- **THEN** el comentario del contrato en `app_theme.dart` documenta qué pares deben reverificarse

### Requirement: Un único acento cromático

La interfaz SHALL usar `primary` como único acento cromático saturado. No PUEDE existir ningún otro color saturado en la interfaz —en particular, ningún naranja ni rojo— fuera de la familia `primary` / `primaryHover`.

Los elementos que son texto informativo o utilería estructural NO PUEDEN usar `primary`: los nombres de los testimonios SHALL usar `textPrimary`, y los iconos de contacto del footer SHALL usar `secondary`.

#### Scenario: Buscar colores saturados residuales

- **WHEN** se revisan las asignaciones de color en `lib/`
- **THEN** no aparece ningún naranja ni rojo, ni como constante ni como literal `Color(0x...)`

#### Scenario: El nombre de un testimonio no es un acento

- **WHEN** se renderiza el nombre de una persona en una tarjeta de testimonio
- **THEN** usa `textPrimary` y no `primary`

### Requirement: Jerarquía de profundidad entre superficies

Las cuatro superficies SHALL mantener una escala de luminancia estrictamente creciente en el orden `darker` < `dark` < `surface` < `accent`, de modo que la elevación se perciba sin depender de sombras.

El fondo más profundo (`darker`) SHALL aproximarse al negro para permitir que, en el futuro, contenido fotográfico con fondo negro se integre sin costura visible.

#### Scenario: Comparar la luminancia de las superficies

- **WHEN** se calcula la luminancia relativa de los cuatro tokens de superficie
- **THEN** cada uno es estrictamente mayor que el anterior en el orden `darker` < `dark` < `surface` < `accent`

#### Scenario: Una tarjeta se distingue de su sección

- **WHEN** una tarjeta con fondo `surface` se sitúa sobre una sección con fondo `dark` o `darker`
- **THEN** la diferencia de luminancia es perceptible sin necesidad de sombra

### Requirement: Centralización de las variantes con opacidad

Las variantes traslúcidas de los tokens SHALL declararse como miembros derivados de `AppTheme` (`cardBorder`, `glow`, `glowSoft`). Los widgets NO PUEDEN invocar `.withOpacity()` sobre un token de color directamente en su árbol de construcción.

#### Scenario: Ajustar la intensidad de todos los bordes

- **WHEN** se necesita cambiar la opacidad de los bordes de todas las tarjetas
- **THEN** basta con editar `AppTheme.cardBorder` en un único punto

#### Scenario: Buscar opacidades dispersas

- **WHEN** se buscan llamadas a `.withOpacity(` dentro de `lib/widgets/`
- **THEN** no se encuentra ninguna aplicada sobre una constante de `AppTheme`

### Requirement: Bordes de tarjeta visibles

Toda tarjeta de contenido —features y testimonios— SHALL delimitarse con un borde derivado de `secondary` con opacidad suficiente para percibirse a simple vista. Todas las tarjetas SHALL usar el mismo token de borde, sin variar por sección.

#### Scenario: Bordes consistentes entre secciones

- **WHEN** se comparan una tarjeta de features y una de testimonios
- **THEN** ambas usan `AppTheme.cardBorder` con idéntico color y opacidad

### Requirement: Gradiente del CTA con rango tonal suficiente

La sección CTA SHALL usar un gradiente que vaya de una superficie profunda a una elevada (`dark` → `accent`), y su botón SHALL rellenarse con `primary` y rotularse con `onPrimary`.

El gradiente NO PUEDE construirse entre dos superficies elevadas adyacentes, dado que ello reduciría el contraste del botón por debajo de lo aceptable en el extremo más claro.

#### Scenario: El botón resalta sobre el gradiente

- **WHEN** se renderiza la sección CTA
- **THEN** el gradiente va de `dark` a `accent`
- **AND** el botón `primary` contrasta al menos 3:1 contra ambos extremos del gradiente

#### Scenario: El CTA ya no usa colores cálidos

- **WHEN** se renderiza la sección CTA
- **THEN** el gradiente no contiene naranja ni rojo
- **AND** el botón no tiene relleno blanco
