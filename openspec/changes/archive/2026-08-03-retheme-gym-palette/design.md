## Context

`AppTheme` (`lib/theme/app_theme.dart`) concentra hoy 8 constantes de color consumidas por 24 callsites repartidos en 6 widgets. La convención del proyecto —documentada en `CLAUDE.md`— es que todo el estilo vive en `AppTheme` y los widgets solo hacen `copyWith` sobre el `TextTheme`; ese contrato se respeta bien y no hay literales `Color(0x...)` fuera del tema.

El problema no es que los valores estén "feos", es que **el modelo de roles está mal**. `primary` se usa como fondo en `hero_section.dart:33` y `cta_section.dart:22`, y como color de primer plano en `navbar.dart:27`, `footer.dart:25,93,120`, `features_section.dart:84` y `testimonials_section.dart:81,96`. Un único valor no puede satisfacer ambos usos: si es oscuro para servir de fondo, es ilegible como texto. Hoy es oscuro, y el resultado es que el logo y los iconos están en ~1.6:1 sobre `darker`.

La dirección visual objetivo proviene de una imagen de referencia: base azul-negra casi monocroma, tarjetas azul marino con **borde plateado**, **glow azul frío**, y un **único acento dorado** usado con moderación (en la referencia, las cifras son blancas y solo los pictogramas son dorados). No hay naranja ni rojo en ninguna parte de la referencia.

Restricción adicional, aportada por el usuario: esta paleta es el punto de partida de una plantilla de landing reutilizable.

## Goals / Non-Goals

**Goals:**

- Alinear la paleta con la referencia visual: superficies azul-negras, acento dorado único, estructura plateada.
- Corregir el defecto de contraste preexistente separando los roles de superficie y de primer plano.
- Dejar la paleta lista para clonarse: cambiar identidad de marca debe costar editar valores en un solo archivo.
- Codificar las invariantes de accesibilidad para que sobrevivan a futuros clones.

**Non-Goals:**

- Incorporar la imagen de referencia al hero. Requiere crear `assets/`, descomentar el bloque de assets de `pubspec.yaml` y rediseñar el layout del hero (la imagen es 4:3 y el hero es ~2.1:1, así que `BoxFit.cover` recortaría cabezas y tarjetas). Se abordará en un cambio posterior.
- Tema claro.
- Renombrar `dark` / `darker` / `surface`.
- Tipografía, espaciado, copy, estructura de secciones, o el `onSectionTap` no-op del navbar.

## Decisions

### D1. Conservar los nombres genéricos en vez de renombrar a nombres de marca

**Decisión:** mantener `primary`, `secondary`, `accent`, `dark`, `darker`, `surface`, `textPrimary`, `textSecondary`.

**Alternativa considerada:** renombrar a `navy` / `gold` / `silver`, que describe mejor *este* diseño.

**Razón del rechazo:** el objetivo de plantilla lo invalida. Un segundo cliente con identidad roja y negra tendría un token literalmente llamado `gold` conteniendo rojo — el nombre pasaría a mentir. Los nombres genéricos siguen siendo verdad tras cualquier sustitución de marca, y reducen el clonado a "editar 10 hex en un archivo". Coste: los nombres son menos evocadores al leer un widget aislado; se compensa con el comentario de roles en `app_theme.dart`.

### D2. Invertir el rol de `primary` en lugar de añadir un token nuevo

**Decisión:** `primary` pasa de azul de superficie a acento de marca dorado. `accent` absorbe el rol de superficie elevada.

**Alternativa considerada:** dejar `primary` como está y añadir un token `brandAccent` nuevo para el dorado.

**Razón del rechazo:** dejaría `primary` como un token ambiguo que sigue invitando al mismo error, y ningún callsite existente se beneficiaría. Con la inversión, los 7 callsites que ya usaban `primary` para logo e iconos **quedan correctos sin editarse** —eran semánticamente correctos todo el tiempo, solo estaban recibiendo el valor equivocado— y el diff se concentra en los 11 sitios que realmente usaban `primary` como superficie.

Consecuencia a vigilar: `primary` deja de ser oscuro. Cualquier suposición futura de "primary es un fondo" se rompe. Por eso se marca como BREAKING en la propuesta.

### D3. La paleta

```dart
// superficies (luminancia creciente)
darker        = #08090B   // navbar, footer, testimonials
dark          = #101822   // features, extremo oscuro del gradiente CTA
surface       = #1B2A42   // tarjetas
accent        = #2C4B78   // gradientes, glow, extremo claro del CTA

// acento de marca
primary       = #C9A24D   // logo, iconos, estrellas, relleno del botón
primaryHover  = #E4C982   // estados hover
onPrimary     = #0A0F16   // texto sobre primary

// estructura y texto
secondary     = #AEB6BF   // bordes, iconos utilitarios
textPrimary   = #F2F4F6
textSecondary = #9AA5B1
```

Contrastes verificados (WCAG 2.1, luminancia relativa):

| | `darker` | `dark` | `surface` | `accent` |
| --- | --- | --- | --- | --- |
| `primary` | 8.3:1 | 7.4:1 | 6.0:1 | 3.7:1 |
| `secondary` | 9.7:1 | 8.7:1 | 7.0:1 | 4.3:1 |
| `textPrimary` | 18:1 | 16:1 | 13:1 | 8.0:1 |
| `textSecondary` | 8.0:1 | 7.2:1 | 5.8:1 | 3.5:1 |

`onPrimary` sobre `primary`: **8.0:1**.

La columna `accent` es la única con valores bajos, y es aceptable porque `accent` solo aparece como extremo de gradiente y como glow: ningún texto de cuerpo se apoya sobre él en estado sólido. Esta restricción está codificada en la spec (el gradiente del CTA debe ir de `dark` a `accent`, no entre dos superficies elevadas).

### D4. `darker` casi negro (#08090B) en vez de un azul oscuro

Aunque este cambio no incorpora la imagen, se elige un negro casi puro para el fondo más profundo. La referencia tiene bordes de negro puro con viñeta; si el fondo de página es azulado, cuando se añada contenido fotográfico habrá una costura visible en el borde de la imagen. Con `#08090B` la foto se disuelve en la página. Cuesta cero ahora y evita rehacer la paleta después.

### D5. Blanco sobre dorado es el error más probable de esta migración

`app_theme.dart:76` y `cta_section.dart:47-48` definen botones con relleno claro y texto blanco o `primary`. Al volverse `primary` dorado, mantener `foregroundColor: Colors.white` produce **2.15:1** — ilegible, y es un fallo silencioso: compila, se ve "bien" en un vistazo rápido, y falla auditoría. Por eso `onPrimary` es un token explícito y no un `Colors.black` improvisado en el callsite, y por eso la spec lo cubre con un escenario propio.

### D6. Tokens derivados para las opacidades

Hoy hay `.withOpacity()` con valores 0.05, 0.1, 0.2, 0.3 y 0.5 repartidos en 6 widgets. Para una plantilla eso es inaceptable: quien la clone no los va a encontrar. Se centralizan tres:

```dart
static Color get cardBorder => secondary.withOpacity(0.35);
static Color get glow       => accent.withOpacity(0.28);
static Color get glowSoft   => primary.withOpacity(0.10);
```

Nótese que las opacidades **suben** respecto de las actuales (0.3 → 0.35 en bordes, 0.1 → 0.28 en el glow). Sin la fotografía, los bordes plateados y el glow son lo único que aporta atmósfera; a los niveles actuales son imperceptibles y el resultado sería un landing oscuro genérico.

Se usan getters y no `const` porque `withOpacity` no es evaluable en tiempo de compilación. El coste es que los widgets que los consumen dejan de poder ser `const` en esa rama; es un `Container` por widget y no afecta al rendimiento de forma medible.

### D7. Retirar el acento de dos sitios en lugar de recolorearlo

`testimonials_section.dart:96` (nombre de la persona) y `footer.dart:93` (iconos de contacto) usan hoy `primary`. Al volverse dorado quedarían legibles, así que la corrección no es de contraste sino de significado: un nombre es texto (`textPrimary`) y un icono de contacto es utilería (`secondary`). Si el dorado aparece en el logo, el CTA, los iconos de features, las estrellas, los nombres y los iconos de contacto, deja de señalar "esto importa" y pasa a ser color de relleno. La referencia respalda esto: sus cifras son blancas, solo los pictogramas son dorados.

### D8. El contrato de contraste va como comentario en `app_theme.dart`

**Alternativa considerada:** un documento aparte, o un test automatizado que calcule luminancias.

**Razón:** el comentario se lee justo donde se edita el valor, que es el momento exacto en que alguien puede romperlo. Un archivo aparte no se abre. Un test sería mejor garantía, pero implicaría escribir un cálculo de luminancia WCAG a mano para un landing estático — desproporcionado ahora. Si la plantilla llega a usarse en varios proyectos, el test se vuelve rentable y se puede añadir entonces.

## Risks / Trade-offs

- **`primary` deja de ser oscuro y algún código futuro lo asume** → marcado BREAKING en la propuesta; el comentario de roles en `app_theme.dart` declara explícitamente qué tokens son fondo y cuáles primer plano.
- **Blanco sobre dorado sobrevive en algún callsite y falla en silencio** → los dos únicos sitios con `foregroundColor` claro (`app_theme.dart:76`, `cta_section.dart:48`) están enumerados en `tasks.md`; la verificación final incluye buscar `Colors.white` en `lib/`.
- **El gradiente del CTA pierde impacto respecto al naranja→rojo actual** → mitigado por D3: el gradiente arranca en `dark` (no en `surface`), de modo que el botón dorado contrasta 7.4:1 en el extremo oscuro. Es un cambio deliberado de registro: de "alarma" a "premium".
- **Sin la fotografía, la paleta sola podría leerse como genérica** → mitigado por D6 subiendo bordes y glow. Es el riesgo real de este cambio y solo se puede evaluar viéndolo; conviene revisar en navegador antes de dar por bueno.
- **Los getters derivados rompen `const` en algunos constructores** → impacto nulo en la práctica; son contenedores de sección, no elementos en listas largas.
- **`dark`/`darker` describen valor y no rol** → aceptado conscientemente. Morderá el día que la plantilla necesite tema claro, porque `darker` contendría el color más claro. No se renombra ahora porque el churn no se justifica con un solo tema.

## Migration Plan

No hay estado persistido, API ni consumidores externos: el cambio es puramente visual y se aplica en un solo commit.

1. Reescribir los tokens de `app_theme.dart` (incluye el contrato de contraste y el comentario de roles).
2. Reasignar los 11 callsites de widgets.
3. `flutter analyze` — debe quedar limpio.
4. `flutter test` — el test existente solo verifica renderizado; debe seguir pasando.
5. Verificación manual en `flutter run -d chrome`, recorriendo las 6 secciones y comprobando específicamente logo, iconos de features, estrellas, bordes de tarjeta y botón del CTA.

Rollback: revertir el commit. No hay migración de datos ni pasos de despliegue.

## Open Questions

- ¿La subida de opacidades de D6 (bordes 0.35, glow 0.28) es suficiente sin la fotografía, o se queda corta? Solo se puede resolver mirándolo en el navegador. Si se queda corto, el ajuste es un valor en un getter.
- Cuando se incorpore la imagen del hero en un cambio posterior, hay que decidir entre layout partido (texto izquierda / imagen derecha, respeta el 4:3) o full-bleed con scrim. Queda fuera de este cambio pero condiciona si `accent` se sigue necesitando como glow en el hero.
