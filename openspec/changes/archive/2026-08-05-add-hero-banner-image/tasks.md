## 1. Tokens y constantes

- [x] 1.1 Añadir a `AppTheme` el par de miembros derivados del scrim (variante opaca y variante transparente de la superficie profunda), junto a `glow` y `glowSoft`, con nombres por rol y sin referencias cromáticas
- [x] 1.2 Documentar en el comentario de `app_theme.dart` que la opacidad del scrim se calibra contra la zona más clara de la fotografía bajo la banda de texto, no contra su promedio
- [x] 1.3 Añadir a `AppConstants` la constante con la ruta `assets/images/heroBanner.webp`
- [x] 1.4 Verificar que `pubspec.yaml` declara `assets/images/` y que `flutter pub get` resuelve el bundle sin avisos

## 2. Composición de desktop

- [x] 2.1 Reestructurar `HeroSection` para que, con ancho ≥ 600 px, use una `Column` con dos regiones hermanas repartidas por `flex` (texto arriba, imagen abajo) en lugar del `Stack` centrado actual
- [x] 2.2 Mover el bloque de tagline, subtítulo y CTA a la región superior, conservando los tamaños de fuente y el `padding` horizontal actuales
- [x] 2.3 Renderizar la imagen en la región inferior con un ajuste que la contenga por entero, anclada al borde inferior y centrada horizontalmente
- [x] 2.4 Asegurar que el espacio sobrante a los lados de la imagen queda cubierto por `AppTheme.darker`, de modo que el límite del bitmap no sea perceptible
- [x] 2.5 Fijar una calidad de filtrado explícita en el `Image` para el escalado en pantallas grandes

## 3. Composición de móvil

- [x] 3.1 Con ancho < 600 px, renderizar la imagen como fondo a sangre que cubra toda la sección, con recorte tomado desde el centro
- [x] 3.2 Interponer la capa de scrim entre la imagen y el texto, como gradiente vertical de opaco arriba a transparente abajo, usando los miembros de `AppTheme` de la tarea 1.1
- [x] 3.3 Mantener el bloque de texto por encima del scrim con la disposición centrada actual

## 4. Ornamentos y limpieza

- [x] 4.1 Retirar el círculo de glow anclado al borde inferior izquierdo
- [x] 4.2 Conservar el glow superior derecho y comprobar que se pinta por detrás de la imagen
- [x] 4.3 Verificar que `hero_section.dart` no contiene ninguna llamada a `.withValues(alpha:` ni `.withOpacity(` sobre una constante de `AppTheme`, ni la ruta del asset como literal

## 5. Robustez y accesibilidad

- [x] 5.1 Añadir un `errorBuilder` al `Image` que devuelva un widget vacío, de modo que un fallo de carga deje el hero con su gradiente, tagline, subtítulo y CTA
- [x] 5.2 Excluir la imagen de la capa semántica por ser decorativa, y comprobar que tagline, subtítulo y CTA siguen siendo alcanzables

## 6. Verificación

- [x] 6.1 Ampliar `test/widget_test.dart` fijando el tamaño de la superficie de prueba para ejercitar explícitamente ambos breakpoints, ya que el viewport por defecto de 800 × 600 cae siempre en la rama desktop
- [x] 6.2 Cubrir con un test que en desktop los rectángulos del bloque de texto y de la imagen no se intersecan
- [x] 6.3 Cubrir con un test que un fallo de carga del asset deja el hero renderizando texto y CTA sin error en pantalla
- [x] 6.4 Ejecutar `flutter analyze` y `flutter test` sin errores
- [x] 6.5 Revisar visualmente con `flutter run -d chrome` en 1920 × 1080, 1440 × 700 y 390 × 844, confirmando que las cuatro tarjetas de métrica sobreviven en los dos primeros y que el texto es legible en el tercero
- [x] 6.6 Ajustar el reparto `flex` entre texto e imagen si la revisión visual lo aconseja

## 7. Correcciones surgidas de la revisión visual

- [x] 7.1 Ajustar el reparto de 4/6 a 3/7: con 4/6 quedaba un hueco muerto muy visible entre el CTA y la fotografía
- [x] 7.2 Difuminar los bordes laterales y superior de la imagen con `ShaderMask` en `BlendMode.dstIn`, dado que el fondo del bitmap resultó ser un azul-gris texturizado y no negro puro, y su borde recto se recortaba contra la sección
- [x] 7.3 Envolver la imagen en un `AspectRatio` con la relación del bitmap para que la máscara se alinee con los bordes de la imagen y no con los de la región
- [x] 7.4 Calibrar los márgenes de difuminado (7 % lateral, 9 % superior) para no borrar las tarjetas de métrica
- [x] 7.5 Reverificar visualmente en 1920 × 1080 y 1440 × 700 que las tarjetas siguen íntegras y el borde ya no se percibe
