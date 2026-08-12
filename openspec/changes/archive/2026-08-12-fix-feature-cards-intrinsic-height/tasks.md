## 1. Reemplazar la retícula en FeaturesSection

- [x] 1.1 Consolidar la lectura de `MediaQuery.of(context).size.width` en una sola variable local en `FeaturesSection.build` y derivar de ella `isMobile`, `isTablet` y el número de columnas (`1` / `2` / `4`), conservando los umbrales 600 y 1024.
- [x] 1.2 Añadir un helper privado que trocee `AppConstants.features` en filas de `n` elementos, rellenando la última fila incompleta hasta `n` ranuras.
- [x] 1.3 Sustituir el `GridView.count` por un `Column` de filas: cada fila es un `IntrinsicHeight` con un `Row(crossAxisAlignment: CrossAxisAlignment.stretch)` cuyos hijos son `Expanded(_FeatureCard(...))`, con `SizedBox(width: 24)` entre tarjetas y `SizedBox(height: 24)` entre filas.
- [x] 1.4 Renderizar las ranuras de relleno de la última fila como `Expanded(child: SizedBox.shrink())` para que no estiren las tarjetas presentes.
- [x] 1.5 Eliminar `childAspectRatio`, `shrinkWrap` y `physics` junto con el `GridView`, y comprobar que no queda ninguna constante de alto/ratio huérfana en el archivo.
- [x] 1.6 Añadir un comentario breve junto al `IntrinsicHeight` explicando por qué su coste es aceptable aquí (pocas filas, contenido estático) y que no debe replicarse en listas largas.

## 2. Ajustar la tarjeta

- [x] 2.1 Verificar que el `Container` de `_FeatureCard` no impone alto propio y que recibe el alto de la fila vía `stretch`.
- [x] 2.2 Conservar `mainAxisAlignment: MainAxisAlignment.center` en su `Column` para centrar el contenido cuando la tarjeta se estira, y dejar sin tocar color, borde, radio, padding, icono y estilos de texto.

## 3. Verificación

- [x] 3.1 Ejecutar `flutter analyze` sin nuevos avisos.
- [x] 3.2 Ejecutar `flutter test` y confirmar que `test/widget_test.dart` sigue pasando. — 19/20 verdes. `App renders landing screen` falla, pero **ya fallaba antes de este cambio**: monta la landing completa en el viewport por defecto de 800x600 y ahí desbordan horizontalmente el `Row` del `Navbar` y el `_InfoRow` del `Footer`. Verificado con `git stash`: mismas dos excepciones antes y después. Ajeno a esta capability.
- [x] 3.3 Añadir una prueba de widget que renderice la landing fijando el tamaño del surface a 360, 599, 600, 1023, 1024, 1280 y 1920 px de ancho y que falle si `tester.takeException()` devuelve un error de overflow en cualquiera de esos anchos.
- [x] 3.4 Añadir una prueba que verifique el conteo de columnas por breakpoint (1 columna bajo 600, 2 entre 600 y 1023, 4 desde 1024).
- [x] 3.5 Añadir una prueba que verifique alturas iguales entre tarjetas de la misma fila con descripciones de distinta longitud.
- [x] 3.6 Añadir una prueba de regresión de copy: renderizar con una descripción notablemente más larga y confirmar que la tarjeta crece sin desbordar. — **Desviación**: el copy de `AppConstants` es `const` y no se puede inyectar desde una prueba, así que la exigencia se aplica con `TextScaler.linear(1.6)`. Somete al layout a lo mismo (más alto de contenido en el mismo ancho de columna) y de paso cubre accesibilidad.
- [x] 3.7 Comprobar visualmente a 1024 px que el texto descriptivo completo es visible y no aparece la franja de overflow. — **Desviación**: hecho con `flutter build web` + Chrome headless en vez de `flutter run -d chrome`, y con una ventana alta en vez de 1024x600 / 1024x1366. Motivo: el hero mide el 85% del alto del viewport, así que en una ventana de 600 o 1366 px de alto la sección queda fuera de cuadro y headless no puede desplazarla. El alto del viewport no influye en esta retícula (la sección vive en un `SingleChildScrollView`; solo cuenta el ancho), así que la comprobación a 1024 px de ancho cubre ambas resoluciones. Resultado: 4 tarjetas en una fila, alturas idénticas, bordes inferiores alineados, texto completo, sin franja de overflow.

## 4. Hallazgo adicional

- [x] 4.1 El bug era más amplio de lo reportado: al reproducirlo con el `GridView` original se confirmó desbordamiento también a 360 px (rama móvil, `childAspectRatio: 1.2`), no solo a 1024. El cambio lo corrige en todo el barrido de anchos.
- [x] 4.2 Se verificó que las pruebas nuevas son rojas contra el layout antiguo (`GridView` + `childAspectRatio`) y verdes contra el nuevo, para descartar que pasen de forma vacía.
