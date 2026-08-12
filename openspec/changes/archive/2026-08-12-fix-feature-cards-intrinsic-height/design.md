## Context

`FeaturesSection` usa hoy `GridView.count(shrinkWrap: true, physics: NeverScrollableScrollPhysics, childAspectRatio: isMobile ? 1.2 : 1)`. El grid no es scrollable ni virtualiza nada: solo se usa como repartidor de celdas. Su contrato es que la altura de la celda se **deriva** del ancho de la celda vía `childAspectRatio`, y el hijo recibe restricciones apretadas (tight) en ambos ejes. El contenido no participa en la decisión.

A 1024 px de ancho el resultado es:

```
1024 − 128 (padding 64×2) − 72 (spacing 24×3) = 824 / 4 = 206 px de ancho de celda
childAspectRatio: 1                            → 206 px de ALTO impuesto
− 48 (padding interno 24×2)                    → 158 px para el contenido
contenido real: icono 48 + 16 + título 2 líneas ~48 + 8 + descripción 5 líneas ~95 ≈ 215 px
                                               → ~57 px de overflow
```

1024x600 y 1024x1366 son el mismo caso: la sección vive dentro de un `SingleChildScrollView`, así que la altura del viewport es irrelevante y solo cuenta el ancho. El salto de 1023 → 1024 duplica de golpe las columnas (celda de 451 px a 206 px), por lo que el **piso** de la rama escritorio es su peor caso.

Restricciones del repo: el copy vive en `AppConstants` y está pensado para cambiar; el estilo vive en `AppTheme`; el responsive se hace con checks inline de `MediaQuery` en cada sección. Es una landing estática sin estado ni routing.

## Goals / Non-Goals

**Goals:**
- Que la altura de la tarjeta sea función del contenido, no del ancho.
- Eliminar la clase entera de bug: cambiar el copy o el tamaño de fuente no debe volver a producir overflow.
- Conservar la retícula visual: alturas alineadas dentro de una fila, mismos anchos, mismas separaciones de 24 px.
- Conservar los breakpoints y el conteo de columnas actuales (1 / 2 / 4).
- No introducir dependencias ni un helper de layout nuevo.

**Non-Goals:**
- Rediseñar la tarjeta, cambiar tipografías, colores o el copy.
- Adoptar el helper `Responsive` (sigue sin usarse; ese debate es aparte).
- Tocar otras secciones. Se verificó que `features_section.dart` es el único uso de `GridView`/`childAspectRatio` de layout; el `AspectRatio` de `hero_section.dart` encaja un bitmap 1200x896 y es intencional.
- Añadir un breakpoint intermedio de 3 columnas.

## Decisions

### Decisión 1: `Column` de `Row`s con `IntrinsicHeight`, en lugar de `GridView.count`

La retícula pasa a construirse troceando `AppConstants.features` en filas de `n` columnas y emitiendo, por fila, un `IntrinsicHeight` que envuelve un `Row` con `crossAxisAlignment: CrossAxisAlignment.stretch` y cada tarjeta en un `Expanded`.

```
Column
 └─ IntrinsicHeight                 ← mide el hijo más alto de la fila
     └─ Row(crossAxisAlignment: stretch)
         ├─ Expanded(_FeatureCard)  ← ancho: 1/n del disponible
         ├─ SizedBox(width: 24)
         └─ Expanded(_FeatureCard)  ← alto: el de la fila
```

Por qué funciona: `Expanded` resuelve el ancho sin cálculo explícito, así que **no hace falta `LayoutBuilder` ni conocer el ancho real**. `IntrinsicHeight` mide la altura natural del hijo más alto y `stretch` la impone a todos, de modo que la altura sube desde el contenido en vez de bajar desde el ancho. Ese es exactamente el sentido de flujo invertido respecto a `childAspectRatio`.

**Alternativas consideradas:**

| Alternativa | Por qué no |
|---|---|
| `Wrap` con `SizedBox(width:)` por tarjeta | Mide por contenido, pero requiere `LayoutBuilder` para calcular el ancho a mano y **no puede igualar alturas** dentro de una fila: la retícula se ve escalonada. |
| `GridView` con `mainAxisExtent` (px fijos) | Desacopla alto de ancho, pero sigue siendo un número fijo: el texto más largo define la altura de todas y vuelve a romperse si crece. No cumple el goal principal. |
| Subir el breakpoint de escritorio a 1200 | Arregla solo el ancho reportado. Deja el ratio fijo intacto y el bug latente. |
| `maxLines` + ellipsis en la descripción | Nunca desborda, pero recorta copy de marketing. Cura peor que la enfermedad. |

### Decisión 2: Los breakpoints siguen leyéndose de `MediaQuery`, no de `LayoutBuilder`

Se mantiene el patrón inline del repo (`MediaQuery.of(context).size.width < 600` / `< 1024`). Cambiar a `LayoutBuilder` para decidir columnas movería los umbrales efectivos, porque el ancho local ya tiene descontado el padding de 128 px: a 1024 px de viewport el ancho local es 896 y la sección caería en la rama de 2 columnas. Eso alteraría el diseño más allá del bug. `LayoutBuilder` no aporta nada aquí porque `Expanded` ya resuelve el ancho.

Sí se consolida la lectura de `MediaQuery` en una sola llamada (hoy se llama tres veces en `build`) — limpieza incidental sin cambio de comportamiento.

### Decisión 3: Filas incompletas se rellenan con huecos, no estirando las tarjetas

Con 4 features y 1/2/4 columnas las filas siempre salen completas hoy, pero la construcción no debe depender de eso: añadir una quinta feature en `AppConstants` no debe producir una tarjeta de ancho doble. La última fila se completa con `Expanded(child: SizedBox.shrink())` hasta llenar `n` ranuras.

### Decisión 4: `_FeatureCard` no cambia por dentro, salvo poder estirarse

Se conserva `mainAxisAlignment: MainAxisAlignment.center` en su `Column`, que es lo que centra verticalmente el contenido cuando la tarjeta se estira para igualar a una hermana más alta. El `Container` de la tarjeta no lleva alto fijo: recibe el alto de la fila por `stretch`. Colores, borde, radio y padding quedan intactos.

## Risks / Trade-offs

- **`IntrinsicHeight` es caro** (fuerza un pase de medición extra por fila, con coste potencialmente cuadrático en árboles anidados) → Aquí hay como mucho 4 filas de contenido trivial (icono + dos textos) en una landing estática sin animación ni scroll virtualizado. El coste es despreciable. Se documenta con un comentario en el código para que nadie lo replique a ciegas en una lista larga.
- **A 1024 px la tarjeta queda estrecha y alta** (descripción a ~5 líneas): el layout ya no desborda, pero tampoco es bonito → Fuera de alcance de este cambio. Si molesta visualmente, el arreglo separado es un breakpoint intermedio de 3 columnas; queda anotado como pregunta abierta, no como tarea.
- **Se pierde la garantía de retícula perfectamente cuadrada** que daba `childAspectRatio` → Es intencional: esa garantía era precisamente la causa del bug. Las alturas siguen alineadas por fila, que es lo que el ojo percibe como retícula.
- **Los tests de overflow pueden pasar en falso** si se comprueban con un tamaño de pantalla por defecto → Las pruebas deben fijar explícitamente el tamaño del surface para cada ancho del barrido, y comprobar `tester.takeException()`.

## Migration Plan

Cambio contenido en un solo archivo, sin migración de datos, sin flags y sin superficie pública. Rollback = revertir el commit.

## Open Questions

- ¿Se quiere un breakpoint intermedio de 3 columnas para el rango 1024–1279, donde 4 columnas quedan estrechas? Fuera de alcance aquí; se decide viendo el resultado ya sin overflow.
- ¿Adoptar el helper `Responsive` en toda la app o eliminarlo? Sigue sin usarse y este cambio no lo resuelve.
